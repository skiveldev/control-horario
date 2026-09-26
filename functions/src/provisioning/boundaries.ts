import type { Auth } from "firebase-admin/auth";
import type { Firestore, Transaction } from "firebase-admin/firestore";
import type { AuditEvent } from "./audit.ts";
import type { AuthorizationPort, AuthorizationProfile } from "./authz.ts";
import type {
  InitialSubmissionStore,
  InitialSubmissionTransaction,
} from "./submit.ts";

export type WorkerRecord = Record<string, unknown>;
export interface AuthIdentity { readonly uid: string; readonly email: string | null }
export type AuthCreateOutcome =
  | { readonly kind: "created"; readonly identity: AuthIdentity }
  | { readonly kind: "definite_no_effect"; readonly code: string };
export interface AuthReader {
  readByUid(uid: string): Promise<AuthIdentity | null>;
  readByEmail(email: string): Promise<AuthIdentity | null>;
}
/** The only create boundary: thrown failures are intentionally ambiguous. */
export interface AuthCreator {
  createUser(uid: string, email: string): Promise<AuthCreateOutcome>;
}
export interface WorkerTransaction {
  readonly now: number;
  readOperation(operationId: string): Promise<WorkerRecord | null>;
  readDispatch(dispatchId: string): Promise<WorkerRecord | null>;
  readAudit(eventId: string): Promise<WorkerRecord | null>;
  readProfile(userId: string): Promise<WorkerRecord | null>;
  writeOperation(operationId: string, operation: WorkerRecord): void;
  writeDispatch(dispatchId: string, dispatch: WorkerRecord): void;
  createDispatch(dispatchId: string, dispatch: WorkerRecord): void;
  createAudit(eventId: string, audit: WorkerRecord): void;
  writeProfile(userId: string, profile: WorkerRecord): void;
}
export interface WorkerStore {
  transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T>;
}

export class FirebaseAuthReader implements AuthReader {
  private readonly auth: Auth;

  constructor(auth: Auth) { this.auth = auth; }
  async createUser(uid: string, email: string): Promise<AuthCreateOutcome> {
    const user = await this.auth.createUser({ uid, email });
    return { kind: "created", identity: { uid: user.uid, email: user.email ?? null } };
  }
  async readByUid(uid: string): Promise<AuthIdentity | null> {
    try { const user = await this.auth.getUser(uid); return { uid: user.uid, email: user.email ?? null }; }
    catch (error) { if ((error as { code?: string }).code === "auth/user-not-found") return null; throw error; }
  }
  async readByEmail(email: string): Promise<AuthIdentity | null> {
    try { const user = await this.auth.getUserByEmail(email); return { uid: user.uid, email: user.email ?? null }; }
    catch (error) { if ((error as { code?: string }).code === "auth/user-not-found") return null; throw error; }
  }
}

class FirestoreWorkerTransaction implements WorkerTransaction {
  readonly now: number;
  private readonly db: Firestore;
  private readonly transaction: Transaction;

  constructor(db: Firestore, transaction: Transaction, now: number) {
    this.db = db;
    this.transaction = transaction;
    this.now = now;
  }
  private ref(collection: string, id: string) { return this.db.collection(collection).doc(id); }
  private async read(collection: string, id: string): Promise<WorkerRecord | null> {
    const snapshot = await this.transaction.get(this.ref(collection, id));
    return snapshot.exists ? snapshot.data() as WorkerRecord : null;
  }
  readOperation(id: string) { return this.read("provisioningOperations", id); }
  readDispatch(id: string) { return this.read("provisioningDispatch", id); }
  readAudit(id: string) { return this.read("provisioningAudit", id); }
  readProfile(id: string) { return this.read("users", id); }
  writeOperation(id: string, value: WorkerRecord) { this.transaction.set(this.ref("provisioningOperations", id), value); }
  writeDispatch(id: string, value: WorkerRecord) { this.transaction.set(this.ref("provisioningDispatch", id), value); }
  createDispatch(id: string, value: WorkerRecord) { this.transaction.create(this.ref("provisioningDispatch", id), value); }
  createAudit(id: string, value: WorkerRecord) { this.transaction.create(this.ref("provisioningAudit", id), value); }
  writeProfile(id: string, value: WorkerRecord) { this.transaction.set(this.ref("users", id), value); }
}
class FirestoreInitialSubmissionTransaction implements InitialSubmissionTransaction {
  private readonly db: Firestore;
  private readonly transaction: Transaction;
  private readonly transactionNow: number;

  constructor(db: Firestore, transaction: Transaction, transactionNow: number) {
    this.db = db;
    this.transaction = transaction;
    this.transactionNow = transactionNow;
  }
  now() { return this.transactionNow; }
  async readOperation(operationId: string): Promise<WorkerRecord | null> {
    const snapshot = await this.transaction.get(this.db.collection("provisioningOperations").doc(operationId));
    return snapshot.exists ? snapshot.data() as WorkerRecord : null;
  }
  createOperation(operation: WorkerRecord) {
    this.transaction.create(this.db.collection("provisioningOperations").doc(operation.operationId as string), operation);
  }
  createDispatch(dispatch: WorkerRecord) {
    this.transaction.create(this.db.collection("provisioningDispatch").doc(dispatch.dispatchId as string), dispatch);
  }
}

/** Firestore transaction adapter for the two create-if-absent submission records. */
export class FirestoreInitialSubmissionStore implements InitialSubmissionStore {
  private readonly db: Firestore;

  constructor(db: Firestore) { this.db = db; }
  transaction<T>(work: (transaction: InitialSubmissionTransaction) => Promise<T> | T): Promise<T> {
    return this.db.runTransaction(async (transaction) => {
      const clock = await transaction.get(this.db.collection("provisioningWorkerClock").doc("server"));
      return await work(new FirestoreInitialSubmissionTransaction(this.db, transaction, clock.readTime.toMillis()));
    });
  }
}

/** Firestore adapter for the existing authorization read and denial-audit boundary. */
export class FirestoreAuthorizationPort implements AuthorizationPort {
  private readonly db: Firestore;

  constructor(db: Firestore) { this.db = db; }
  async readUser(uid: string): Promise<AuthorizationProfile | null> {
    const snapshot = await this.db.collection("users").doc(uid).get();
    if (!snapshot.exists) return null;
    const value = snapshot.data() as WorkerRecord;
    return { role: typeof value.role === "string" ? value.role : "", isActive: value.isActive === true };
  }
  async writeDenialAudit(event: AuditEvent): Promise<void> {
    await this.db.collection("provisioningAudit").doc(event.eventId).create(event);
  }
  now() { return Date.now(); }
}

export class FirestoreWorkerStore implements WorkerStore {
  private readonly db: Firestore;

  constructor(db: Firestore) { this.db = db; }
  transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
    return this.db.runTransaction(async (transaction) => {
      const clock = await transaction.get(this.db.collection("provisioningWorkerClock").doc("server"));
      return work(new FirestoreWorkerTransaction(this.db, transaction, clock.readTime.toMillis()));
    });
  }
}
