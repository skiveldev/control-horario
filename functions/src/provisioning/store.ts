import type { OperationState, ReducerRequest, TransitionResult } from "./model.ts";

/** Domain persistence port. Firebase-specific APIs belong only in adapters. */
export interface StoreTransaction {
  read(key: string): Promise<OperationState | null>;
  /** Returns the transaction's backend-authoritative read time in milliseconds. */
  authoritativeNow(): number;
  write(key: string, state: OperationState): void;
  abort(message: string): never;
  compareAndSwap(
    key: string,
    request: ReducerRequest,
    transition: (state: OperationState, request: ReducerRequest) => TransitionResult,
  ): Promise<TransitionResult>;
}

export interface Store {
  transaction<T>(work: (transaction: StoreTransaction) => Promise<T> | T): Promise<T>;
}
