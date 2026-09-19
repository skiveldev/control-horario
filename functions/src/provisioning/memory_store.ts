import type { OperationState, ReducerRequest, TransitionResult } from "./model.ts";
import type { Store, StoreTransaction } from "./store.ts";

function copyState(state: OperationState): OperationState {
  return JSON.parse(JSON.stringify(state)) as OperationState;
}

class MemoryTransaction implements StoreTransaction {
  private readonly entries: Map<string, OperationState>;
  private readonly transactionNow: number;

  constructor(entries: Map<string, OperationState>, transactionNow: number) {
    this.entries = entries;
    this.transactionNow = transactionNow;
  }

  async read(key: string): Promise<OperationState | null> {
    const state = this.entries.get(key);
    return state === undefined ? null : copyState(state);
  }

  authoritativeNow(): number {
    return this.transactionNow;
  }

  write(key: string, state: OperationState): void {
    this.entries.set(key, copyState(state));
  }

  abort(message: string): never {
    const error = new Error(message);
    error.name = "StoreTransactionAborted";
    throw error;
  }

  async compareAndSwap(key: string, request: ReducerRequest, transition: (state: OperationState, request: ReducerRequest) => TransitionResult): Promise<TransitionResult> {
    const state = this.entries.get(key);
    if (state === undefined) return { type: "failure", reason: "not_found" };
    const result = transition(copyState(state), request);
    if (result.type === "success") this.entries.set(key, copyState(result.state));
    return result;
  }
}

/** Strict reference implementation: commits only when its transaction completes. */
export class MemoryStore implements Store {
  #entries = new Map<string, OperationState>();
  #tail: Promise<void> = Promise.resolve();
  #clock: () => number;

  constructor(clock: () => number = Date.now) {
    this.#clock = clock;
  }

  async transaction<T>(work: (transaction: StoreTransaction) => Promise<T> | T): Promise<T> {
    let release!: () => void;
    const previous = this.#tail;
    this.#tail = new Promise<void>((resolve) => { release = resolve; });
    await previous;
    try {
      const working = new Map<string, OperationState>();
      for (const [key, state] of this.#entries) working.set(key, copyState(state));
      const result = await work(new MemoryTransaction(working, this.#clock()));
      this.#entries = working;
      return result;
    } finally {
      release();
    }
  }
}
