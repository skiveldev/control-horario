import type { Firestore, Transaction } from "firebase-admin/firestore";
import type { OperationState, ReducerRequest, TransitionResult } from "./model.ts";
import type { Store, StoreTransaction } from "./store.ts";

function copyState(state: OperationState): OperationState {
  return JSON.parse(JSON.stringify(state)) as OperationState;
}

class FirestoreTransaction implements StoreTransaction {
  private readonly firestore: Firestore;
  private readonly transaction: Transaction;
  private transactionNow: number | null = null;

  constructor(firestore: Firestore, transaction: Transaction) {
    this.firestore = firestore;
    this.transaction = transaction;
  }

  private document(key: string) {
    return this.firestore.collection("p1bOperations").doc(key);
  }

  async read(key: string): Promise<OperationState | null> {
    const snapshot = await this.transaction.get(this.document(key));
    this.transactionNow = snapshot.readTime.toMillis();
    return snapshot.exists ? copyState(snapshot.data() as OperationState) : null;
  }

  authoritativeNow(): number {
    if (this.transactionNow === null) throw new Error("A Firestore read is required before obtaining transaction time");
    return this.transactionNow;
  }

  write(key: string, state: OperationState): void {
    this.transaction.set(this.document(key), copyState(state));
  }

  abort(message: string): never {
    const error = new Error(message);
    error.name = "StoreTransactionAborted";
    throw error;
  }

  async compareAndSwap(key: string, request: ReducerRequest, transition: (state: OperationState, request: ReducerRequest) => TransitionResult): Promise<TransitionResult> {
    const state = await this.read(key);
    if (state === null) return { type: "failure", reason: "not_found" };
    const result = transition(state, request);
    if (result.type === "success") this.write(key, result.state);
    return result;
  }
}

/** Firestore transaction adapter; this is the only P1b module importing firebase-admin. */
export class FirestoreStore implements Store {
  private readonly firestore: Firestore;

  constructor(firestore: Firestore) {
    this.firestore = firestore;
  }

  transaction<T>(work: (transaction: StoreTransaction) => Promise<T> | T): Promise<T> {
    return this.firestore.runTransaction(async (transaction) => await work(new FirestoreTransaction(this.firestore, transaction)));
  }
}
