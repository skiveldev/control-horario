import type { EventType, ExpectedCAS, OperationState } from "./model.ts";
import type { Store } from "./store.ts";

export type CASMutationOutcome =
  | "applied"
  | "not_found"
  | "cas_mismatch"
  | "lease_not_live"
  | "generation_fence";

/** Compares every state field that authorizes a persisted operation mutation. */
export function matchesExpectedCAS(state: OperationState, expected: ExpectedCAS): boolean {
  return state.fingerprint === expected.fingerprint
    && state.status === expected.status
    && state.phase === expected.phase
    && state.generation === expected.generation
    && state.version === expected.version
    && state.ownerToken === expected.ownerToken
    && state.currentDispatchId === expected.currentDispatchId
    && state.leaseExpiresAt === expected.leaseExpiresAt;
}

/** Applies the event-specific lease liveness rule without terminalization policy. */
export function passesLeaseFence(state: OperationState, observedAt: number, eventType: EventType): boolean {
  if (eventType === "acquire") return state.status === "pending" && state.leaseExpiresAt === null;
  if (state.status !== "active" || state.leaseExpiresAt === null) return false;
  return eventType === "takeover"
    ? state.leaseExpiresAt <= observedAt
    : state.leaseExpiresAt > observedAt;
}

/** Generation may change by exactly one, and only for an expired-lease takeover. */
export function passesGenerationFence(before: OperationState, after: OperationState, eventType: EventType): boolean {
  return eventType === "takeover"
    ? after.generation === before.generation + 1
    : after.generation === before.generation;
}

/**
 * Applies one store transaction only when the persisted tuple, lease, and
 * generation fence all authorize the supplied mutation. This primitive owns
 * no terminalization, dispatch, or retry policy.
 */
export async function applyCASMutation(
  store: Store,
  key: string,
  expected: ExpectedCAS,
  eventType: EventType,
  mutate: (state: OperationState, observedAt: number) => OperationState,
): Promise<CASMutationOutcome> {
  return store.transaction(async (transaction) => {
    const current = await transaction.read(key);
    if (current === null) return "not_found";
    if (!matchesExpectedCAS(current, expected)) return "cas_mismatch";
    const observedAt = transaction.authoritativeNow();
    if (!passesLeaseFence(current, observedAt, eventType)) return "lease_not_live";

    const next = mutate(current, observedAt);
    if (!passesGenerationFence(current, next, eventType)) return "generation_fence";
    transaction.write(key, next);
    return "applied";
  });
}
