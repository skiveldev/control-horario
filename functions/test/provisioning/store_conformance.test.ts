import assert from "node:assert/strict";
import test from "node:test";
import type { Store } from "../../src/provisioning/store.ts";
import { createEvent, createInitialState, reduce, type ModelEvent, type OperationState, type ReducerRequest } from "../../src/provisioning/model.ts";
import {
  CANONICAL_P1A_TRANSITION_VECTOR_LEDGER,
  type CanonicalP1aTransitionVector,
} from "./fixtures.ts";

const initial = (): OperationState => createInitialState({
  operationId: "123e4567-e89b-42d3-a456-426614174000", fingerprint: "a".repeat(64), status: "pending", phase: "dispatch_pending",
  normalizedPayload: { email: "employee@example.com", nombre: "Ana", apellido1: "Lopez", apellido2: null, employeeId: "", weeklyHours: 40, dni: null, telefono: null, cargo: null, departamento: null, empresa: null, scheduleId: null, calendarId: null, fechaInicio: null, fechaFin: null, role: "employee", isSupervisor: false, supervisorId: null, isActive: true },
  intendedUid: "uid-1", generation: 0, version: 0, ownerToken: null, leaseExpiresAt: null, currentDispatchId: null, authAttempted: false, authAttempt: null, createdAt: 0, updatedAt: 0,
});

const request = (state: OperationState, observedAt: number, event: ModelEvent): ReducerRequest => ({
  expected: { fingerprint: state.fingerprint, status: state.status, phase: state.phase, generation: state.generation, version: state.version, ownerToken: state.ownerToken, currentDispatchId: state.currentDispatchId, leaseExpiresAt: state.leaseExpiresAt },
  observedAt, event,
});

/** Runs the frozen P1a transition ledger through a store transaction port. */
export async function runFrozenVectors(
  store: Store,
  ledger: readonly CanonicalP1aTransitionVector[] = CANONICAL_P1A_TRANSITION_VECTOR_LEDGER,
): Promise<string[]> {
  const outcomes: string[] = [];
  const reset = async () => store.transaction((transaction) => transaction.write("operation", initial()));
  const apply = async (vector: CanonicalP1aTransitionVector["steps"][number]): Promise<void> => store.transaction(async (transaction) => {
    const current = await transaction.read("operation");
    assert.ok(current, "operation must exist");
    const command = request(current, vector.observedAt, createEvent(vector.event.type, vector.event.payload));
    const expected = reduce(current, command);
    const actual = await transaction.compareAndSwap("operation", command, reduce);
    assert.deepEqual(actual, expected);
    assert.equal(actual.type, "success", `canonical ${vector.event.type} at ${vector.observedAt} must succeed; ${actual.type === "failure" ? actual.reason : ""}`);
    if (actual.type === "success") {
      assert.equal(actual.state.status, vector.expected.status);
      assert.equal(actual.state.phase, vector.expected.phase);
    }
    outcomes.push(JSON.stringify(actual));
  });
  for (const vector of ledger) {
    await reset();
    for (const step of vector.steps) await apply(step);
  }
  return outcomes;
}

test("Store exposes an async transaction boundary", () => {
  const store: Store = {
    transaction: async (work) => work({
      read: async () => null,
      authoritativeNow: () => 0,
      write: () => undefined,
      abort: (message) => {
        const error = new Error(message);
        error.name = "StoreTransactionAborted";
        throw error;
      },
      compareAndSwap: async () => ({ type: "failure", reason: "unsupported_event" }),
    }),
  };
  return store.transaction(async (transaction) => {
    assert.equal(await transaction.read("missing"), null);
  });
});

test("MemoryStore preserves all eight frozen P1a success outcomes", async () => {
  const { MemoryStore } = await import("../../src/provisioning/memory_store.ts");
  const outcomes = await runFrozenVectors(new MemoryStore());
  assert.equal(outcomes.filter((outcome) => outcome.includes('"success"')).length, 13);
});

test("conformance executes the canonical frozen P1a ledger exactly once per vector", async () => {
  const { MemoryStore } = await import("../../src/provisioning/memory_store.ts");
  const outcomes = await runFrozenVectors(new MemoryStore());
  assert.equal(outcomes.length, CANONICAL_P1A_TRANSITION_VECTOR_LEDGER.flatMap((vector) => vector.steps).length);
});

test("conformance count changes when a canonical frozen P1a vector is deleted or added", async () => {
  const { MemoryStore } = await import("../../src/provisioning/memory_store.ts");
  const deleted = CANONICAL_P1A_TRANSITION_VECTOR_LEDGER.slice(1);
  const added = Object.freeze([...CANONICAL_P1A_TRANSITION_VECTOR_LEDGER, CANONICAL_P1A_TRANSITION_VECTOR_LEDGER[0]!]);
  const deletedOutcomes = await runFrozenVectors(new MemoryStore(), deleted);
  const addedOutcomes = await runFrozenVectors(new MemoryStore(), added);
  assert.equal(deletedOutcomes.length, deleted.flatMap((vector) => vector.steps).length);
  assert.equal(addedOutcomes.length, added.flatMap((vector) => vector.steps).length);
  assert.notEqual(deletedOutcomes.length, addedOutcomes.length);
});
