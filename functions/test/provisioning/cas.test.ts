import assert from "node:assert/strict";
import test from "node:test";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import {
  applyCASMutation,
  matchesExpectedCAS,
  passesLeaseFence,
  passesGenerationFence,
} from "../../src/provisioning/cas.ts";
import { FirestoreStore } from "../../src/provisioning/firestore_store.ts";
import { MemoryStore } from "../../src/provisioning/memory_store.ts";
import { createEvent, createInitialState, reduce, type ExpectedCAS, type OperationState } from "../../src/provisioning/model.ts";
import type { Store } from "../../src/provisioning/store.ts";

const LIVE_LEASE = 4_102_444_800_000;

const pending = (): OperationState => createInitialState({
  operationId: "123e4567-e89b-42d3-a456-426614174000", fingerprint: "a".repeat(64), status: "pending", phase: "dispatch_pending",
  normalizedPayload: { email: "employee@example.com", nombre: "Ana", apellido1: "Lopez", apellido2: null, employeeId: "", weeklyHours: 40, dni: null, telefono: null, cargo: null, departamento: null, empresa: null, scheduleId: null, calendarId: null, fechaInicio: null, fechaFin: null, role: "employee", isSupervisor: false, supervisorId: null, isActive: true },
  intendedUid: "uid-employee", generation: 0, version: 0, ownerToken: null, leaseExpiresAt: null, currentDispatchId: null, authAttempted: false, authAttempt: null, createdAt: 0, updatedAt: 0,
});

const expectedFor = (state: OperationState): ExpectedCAS => ({ fingerprint: state.fingerprint, status: state.status, phase: state.phase, generation: state.generation, version: state.version, ownerToken: state.ownerToken, currentDispatchId: state.currentDispatchId, leaseExpiresAt: state.leaseExpiresAt });

function activeState(): OperationState {
  const before = pending();
  const result = reduce(before, {
    expected: expectedFor(before),
    observedAt: 1,
    event: createEvent("acquire", { ownerToken: "b".repeat(64), leaseExpiresAt: LIVE_LEASE }),
  });
  assert.equal(result.type, "success");
  return result.state;
}

async function storeOutcomes(store: Store): Promise<readonly string[]> {
  const before = activeState();
  const expected = expectedFor(before);
  await store.transaction((transaction) => transaction.write("operation", before));

  const staleExpectations: readonly ExpectedCAS[] = [
    { ...expected, fingerprint: "c".repeat(64) },
    { ...expected, status: "pending" },
    { ...expected, phase: "auth_create" },
    { ...expected, generation: expected.generation + 1 },
    { ...expected, version: expected.version + 1 },
    { ...expected, ownerToken: "c".repeat(64) },
    { ...expected, currentDispatchId: "dispatch-2" },
    { ...expected, leaseExpiresAt: 11 },
  ];
  const outcomes: string[] = [];
  for (const stale of staleExpectations) {
    const result = await applyCASMutation(store, "operation", stale, "auth_intent", (state, observedAt) => ({ ...state, version: state.version + 1, updatedAt: observedAt }));
    outcomes.push(result);
    assert.equal(result, "cas_mismatch");
    const persisted = await store.transaction((transaction) => transaction.read("operation"));
    assert.deepEqual(persisted, before);
  }

  const expiredState = { ...before, leaseExpiresAt: 0 };
  const expiredExpected = expectedFor(expiredState);
  await store.transaction((transaction) => transaction.write("operation", expiredState));
  const expired = await applyCASMutation(store, "operation", expiredExpected, "auth_intent", (state, observedAt) => ({ ...state, version: state.version + 1, updatedAt: observedAt }));
  outcomes.push(expired);
  assert.equal(expired, "lease_not_live");

  const invalidGeneration = await applyCASMutation(store, "operation", expiredExpected, "takeover", (state, observedAt) => ({ ...state, generation: state.generation + 2, version: state.version + 1, updatedAt: observedAt }));
  outcomes.push(invalidGeneration);
  assert.equal(invalidGeneration, "generation_fence");

  await store.transaction((transaction) => transaction.write("operation", before));
  let appliedAt: number | undefined;
  const applied = await applyCASMutation(store, "operation", expected, "auth_intent", (state, observedAt) => {
    appliedAt = observedAt;
    return { ...state, version: state.version + 1, updatedAt: observedAt };
  });
  outcomes.push(applied);
  assert.equal(applied, "applied");
  const persisted = await store.transaction((transaction) => transaction.read("operation"));
  assert.deepEqual(persisted, { ...before, version: before.version + 1, updatedAt: appliedAt });
  return outcomes;
}

interface CrashPointOutcome {
  readonly outcomes: readonly [string, string];
  readonly state: OperationState;
  readonly authoritativeUpdatedAt: number;
}

async function crashPointOutcomes(store: Store): Promise<CrashPointOutcome> {
  const before = activeState();
  const expected = expectedFor(before);
  await store.transaction((transaction) => transaction.write("crash-point", before));

  await assert.rejects(
    store.transaction((transaction) => {
      transaction.write("crash-point", { ...before, version: before.version + 1, updatedAt: 5 });
      transaction.abort("simulated crash before commit");
    }),
    (error: unknown) => error instanceof Error && error.name === "StoreTransactionAborted",
  );
  const afterAbort = await store.transaction((transaction) => transaction.read("crash-point"));
  assert.deepEqual(afterAbort, before);

  let retryAt: number | undefined;
  const retry = await applyCASMutation(store, "crash-point", expected, "auth_intent", (state, observedAt) => {
    retryAt = observedAt;
    return { ...state, version: state.version + 1, updatedAt: observedAt };
  });
  assert.equal(retry, "applied");
  const reentry = await applyCASMutation(store, "crash-point", expected, "auth_intent", (state, observedAt) => ({ ...state, version: state.version + 1, updatedAt: observedAt }));
  assert.equal(reentry, "cas_mismatch");

  const persisted = await store.transaction((transaction) => transaction.read("crash-point"));
  assert.deepEqual(persisted, { ...before, version: before.version + 1, updatedAt: retryAt });
  if (retryAt === undefined) throw new Error("the store must provide an authoritative transaction time");
  assert.ok(Number.isInteger(retryAt) && retryAt > before.updatedAt, "the store authoritative clock advances updatedAt");
  return {
    outcomes: [retry, reentry],
    state: persisted!,
    authoritativeUpdatedAt: retryAt,
  };
}

test("CAS primitives reject every stale tuple field and preserve takeover generation rules", () => {
  const state = pending();
  assert.equal(matchesExpectedCAS(state, expectedFor(state)), true);
  assert.equal(matchesExpectedCAS(state, { ...expectedFor(state), version: 1 }), false);
  assert.equal(passesLeaseFence({ ...state, status: "active", phase: "auth_preflight", ownerToken: "b".repeat(64), leaseExpiresAt: 10 }, 5, "auth_intent"), true);
  assert.equal(passesLeaseFence({ ...state, status: "active", phase: "auth_preflight", ownerToken: "b".repeat(64), leaseExpiresAt: 5 }, 5, "auth_intent"), false);
  assert.equal(passesGenerationFence(state, { ...state, generation: 1 }, "takeover"), true);
  assert.equal(passesGenerationFence(state, { ...state, generation: 1 }, "acquire"), false);
});

test("CAS mutations have byte-equal stale, lease, generation, and live outcomes in both stores", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST, "Firestore emulator must be running");
  const app = initializeApp({ projectId: "p1b-cas-test" }, "p1b-cas-test");
  try {
    const memory = await storeOutcomes(new MemoryStore());
    const firestore = await storeOutcomes(new FirestoreStore(getFirestore(app)));
    assert.deepEqual(firestore, memory);
  } finally {
    await deleteApp(app);
  }
});

test("abort, retry, and stale idempotent re-entry have byte-equal store outcomes", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST, "Firestore emulator must be running");
  const app = initializeApp({ projectId: "p1b-crash-test" }, "p1b-crash-test");
  try {
    const memory = await crashPointOutcomes(new MemoryStore());
    const firestore = await crashPointOutcomes(new FirestoreStore(getFirestore(app)));
    assert.deepEqual(firestore.outcomes, memory.outcomes);
    const withoutClock = ({ updatedAt: _updatedAt, ...state }: OperationState) => state;
    assert.deepEqual(withoutClock(firestore.state), withoutClock(memory.state));
    for (const outcome of [memory, firestore]) {
      assert.equal(outcome.state.updatedAt, outcome.authoritativeUpdatedAt);
      assert.equal(outcome.state.version, 2);
      assert.ok(outcome.authoritativeUpdatedAt > 1);
    }
  } finally {
    await deleteApp(app);
  }
});

test("CAS obtains lease time from its transaction instead of a caller timestamp", async () => {
  const before = activeState();
  const expected = expectedFor(before);
  let persisted = before;
  let suppliedToMutation: number | undefined;
  const store: Store = {
    transaction: async (work) => work({
      read: async () => persisted,
      write: (_key, state) => { persisted = state; },
      abort: (message) => { throw new Error(message); },
      compareAndSwap: async () => ({ type: "failure", reason: "unsupported_event" }),
      authoritativeNow: () => 5,
    }),
  };
  const outcome = await applyCASMutation(store, "operation", expected, "auth_intent", (state, observedAt) => {
    suppliedToMutation = observedAt;
    return { ...state, version: state.version + 1, updatedAt: observedAt };
  });
  assert.equal(outcome, "applied");
  assert.equal(suppliedToMutation, 5);
  assert.equal(persisted.updatedAt, 5);
});
