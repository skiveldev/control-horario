import assert from "node:assert/strict";
import test from "node:test";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { FirestoreWorkerStore } from "../../src/provisioning/boundaries.ts";
import { deriveAuditEventId, deriveDispatchId, deriveOwnerToken } from "../../src/provisioning/ids.ts";
import {
  acquireInitialPending,
  processProvisioningTask,
  terminalizeActiveCurrent,
  terminalizeInitialPending,
  takeoverExpiredCurrent,
} from "../../src/provisioning/worker.ts";

const now = 1_700_000_000_000;
const operationId = "82ac2574-9e1c-4d72-a6de-55624774f96c";
const fingerprint = "a".repeat(64);
const submittedByDigest = "b".repeat(64);
const parallelRepetitions = 4;

function payload() {
  return {
    email: "ana@example.com", nombre: "Ana", apellido1: "García", apellido2: null,
    employeeId: "EMP-7", weeklyHours: 40, dni: null, telefono: null, cargo: null,
    departamento: null, empresa: null, scheduleId: null, calendarId: null,
    fechaInicio: null, fechaFin: null, role: "employee", isSupervisor: false,
    supervisorId: null, isActive: true,
  };
}

function pending() {
  return {
    schemaVersion: 1, operationId, fingerprint, normalizedPayload: payload(), intendedUid: "uid-ana",
    submittedByDigest, status: "pending", phase: "dispatch_pending", generation: 0, version: 0,
    ownerToken: null, leaseExpiresAt: null, currentDispatchId: null, authAttempted: false,
    authAttempt: null, createdAt: now, updatedAt: now,
  };
}

function dispatch(boundary = "acquire", generation = 0, sourceVersion = 0) {
  const dispatchId = deriveDispatchId(operationId, boundary, generation, sourceVersion);
  return {
    schemaVersion: 1, dispatchId, taskId: dispatchId, operationId, fingerprint, boundary,
    generation, sourceVersion, ownerSeed: deriveOwnerToken(dispatchId, generation),
    enqueued: true, enqueuedAt: now, enqueueSource: "trigger", enqueueEventId: "c".repeat(64),
    workerAck: null, workerAckAt: null, createdAt: now,
  };
}

function active(options: { owner?: string; lease?: number; generation?: number; version?: number } = {}) {
  const generation = options.generation ?? 0;
  const version = options.version ?? 1;
  const lease = options.lease ?? Date.now() + 60_000;
  const current = dispatch("auth_preflight", generation, version);
  const owner = deriveOwnerToken(current.dispatchId, generation);
  return {
    operation: {
      ...pending(), status: "active", phase: "auth_preflight", generation, version,
      ownerToken: options.owner ?? owner, leaseExpiresAt: lease,
      currentDispatchId: current.dispatchId, updatedAt: now + 1,
    },
    dispatch: current,
  };
}

async function withFirestore(name: string, work: (firestore: Firestore) => Promise<void>) {
  const app = initializeApp({ projectId: name }, name);
  try { await work(getFirestore(app)); } finally { await deleteApp(app); }
}

async function repeatParallel(work: (iteration: number) => Promise<void>) {
  for (let iteration = 0; iteration < parallelRepetitions; iteration += 1) await work(iteration);
}

async function seed(firestore: Firestore, operation: Record<string, unknown>, source: Record<string, unknown>) {
  await firestore.collection("provisioningOperations").doc(operationId).set(operation);
  await firestore.collection("provisioningDispatch").doc(source.dispatchId as string).set(source);
}

async function snapshot(firestore: Firestore, sourceId: string) {
  const [operation, source, audits] = await Promise.all([
    firestore.collection("provisioningOperations").doc(operationId).get(),
    firestore.collection("provisioningDispatch").doc(sourceId).get(),
    firestore.collection("provisioningAudit").get(),
  ]);
  return { operation: operation.data(), source: source.data(), audits: audits.docs.map((entry) => entry.data()) };
}

const emulator = { skip: !process.env.FIRESTORE_EMULATOR_HOST };

test("P3.53 real parallel Firestore clients terminalize exact live owners once and fence foreign owners", emulator, async () => {
  await repeatParallel(async (iteration) => withFirestore(`p3-concurrency-live-owner-${iteration}`, async (firestore) => {
    const record = active();
    await seed(firestore, record.operation, record.dispatch);
    const first = new FirestoreWorkerStore(firestore);
    const secondApp = initializeApp({ projectId: `p3-concurrency-live-owner-${iteration}` }, `p3-concurrency-live-owner-second-${iteration}`);
    try {
      const second = new FirestoreWorkerStore(getFirestore(secondApp));
      await Promise.all([
        terminalizeActiveCurrent(first, record.dispatch.dispatchId, { retryCount: 8, executionCount: 9 }),
        terminalizeActiveCurrent(second, record.dispatch.dispatchId, { retryCount: 8, executionCount: 9 }),
      ]);
      const terminal = await snapshot(firestore, record.dispatch.dispatchId);
      assert.equal(terminal.operation?.status, "failed", "exact live owner may terminalize");
      assert.equal(terminal.source?.workerAck, "terminalized");
      assert.equal(terminal.audits.length, 1, "parallel exact-owner terminalization converges once");

      const foreign = active({ owner: "f".repeat(64) });
      await seed(firestore, foreign.operation, foreign.dispatch);
      const before = await snapshot(firestore, foreign.dispatch.dispatchId);
      await terminalizeActiveCurrent(first, foreign.dispatch.dispatchId, { retryCount: 8, executionCount: 9 });
      assert.deepEqual(await snapshot(firestore, foreign.dispatch.dispatchId), before, "foreign live owner cannot be stolen");
    } finally { await deleteApp(secondApp); }
  }));
});

test("P3.53 expired parallel takeover commits, rereads, fences, then terminalizes after lease expiry", emulator, async () => {
  await repeatParallel(async (iteration) => withFirestore(`p3-concurrency-expired-takeover-${iteration}`, async (firestore) => {
    const record = active({ lease: now - 1 });
    await seed(firestore, record.operation, record.dispatch);
    const first = new FirestoreWorkerStore(firestore);
    const secondApp = initializeApp({ projectId: `p3-concurrency-expired-takeover-${iteration}` }, `p3-concurrency-expired-takeover-second-${iteration}`);
    try {
      const second = new FirestoreWorkerStore(getFirestore(secondApp));
      await Promise.all([
        takeoverExpiredCurrent(first, record.dispatch.dispatchId),
        takeoverExpiredCurrent(second, record.dispatch.dispatchId),
      ]);
      await Promise.all([
        terminalizeActiveCurrent(first, record.dispatch.dispatchId, { retryCount: 8, executionCount: 9 }),
        terminalizeActiveCurrent(second, record.dispatch.dispatchId, { retryCount: 8, executionCount: 9 }),
      ]);
      const takenOver = await snapshot(firestore, record.dispatch.dispatchId);
      assert.equal(takenOver.operation?.status, "active");
      assert.equal(takenOver.operation?.generation, 1);
      assert.equal(takenOver.operation?.version, 2);
      assert.equal(takenOver.source?.workerAck, null);
      assert.equal(takenOver.audits.length, 1, "parallel takeover converges once without stealing its live lease");

      await firestore.collection("provisioningOperations").doc(operationId).set({ ...takenOver.operation, leaseExpiresAt: now - 1 });
      await terminalizeActiveCurrent(first, record.dispatch.dispatchId, { retryCount: 8, executionCount: 9 });
      const persisted = await snapshot(firestore, record.dispatch.dispatchId);
      assert.equal(persisted.operation?.status, "failed");
      assert.equal(persisted.operation?.phase, "terminal");
      assert.equal(persisted.operation?.generation, 2);
      assert.equal(persisted.operation?.version, 4);
      assert.equal(persisted.operation?.ownerToken, null);
      assert.equal(persisted.operation?.leaseExpiresAt, null);
      assert.equal(persisted.source?.workerAck, "terminalized");
      assert.equal(persisted.audits.length, 3, "a later expired lease terminalizes after bounded takeover convergence");
    } finally { await deleteApp(secondApp); }
  }));
});

test("P3.53 pending terminalization rejects representative guarded tuple mismatches and reclassifies active and terminal records", emulator, async () => {
  await repeatParallel(async (iteration) => withFirestore(`p3-concurrency-pending-guard-${iteration}`, async (firestore) => {
    const source = dispatch();
    const operation = pending();
    const operationMutations: readonly [string, (value: Record<string, unknown>) => Record<string, unknown>][] = [
      ["fingerprint", (value) => ({ ...value, fingerprint: "d".repeat(64) })],
      ["updatedAt", (value) => ({ ...value, updatedAt: now + 1 })],
      ["status", (value) => ({ ...value, status: "active", phase: "auth_preflight", version: 1, ownerToken: deriveOwnerToken(dispatch("auth_preflight", 0, 1).dispatchId, 0), leaseExpiresAt: now + 60_000, currentDispatchId: dispatch("auth_preflight", 0, 1).dispatchId })],
    ];
    const sourceMutations: readonly [string, (value: Record<string, unknown>) => Record<string, unknown>][] = [
      ["taskId", (value) => ({ ...value, taskId: "d".repeat(64) })],
      ["ownerSeed", (value) => ({ ...value, ownerSeed: "d".repeat(64) })],
      ["workerAck", (value) => ({ ...value, workerAck: "processed", workerAckAt: now })],
    ];
    for (const [name, mutate] of [...operationMutations, ...sourceMutations]) {
      await seed(firestore, operationMutations.some(([key]) => key === name) ? mutate(operation) : operation, sourceMutations.some(([key]) => key === name) ? mutate(source) : source);
      const store = new FirestoreWorkerStore(firestore);
      const before = await snapshot(firestore, source.dispatchId);
      await terminalizeInitialPending(store, source.dispatchId, { retryCount: 8, executionCount: 9 });
      assert.deepEqual(await snapshot(firestore, source.dispatchId), before, `${name} mismatch is a no-op`);
    }
    await seed(firestore, active().operation, active().dispatch);
    assert.equal(await terminalizeInitialPending(new FirestoreWorkerStore(firestore), source.dispatchId, { retryCount: 8, executionCount: 9 }), false, "active is reclassified, not pending-terminalized");
    await seed(firestore, { ...pending(), status: "failed", phase: "terminal", version: 1 }, { ...source, workerAck: "terminalized", workerAckAt: now });
    assert.equal(await terminalizeInitialPending(new FirestoreWorkerStore(firestore), source.dispatchId, { retryCount: 9, executionCount: 10 }), true, "terminal replay is idempotently classified");
  }));
});

test("P3.54 duplicate and out-of-order reserved deliveries converge, while failed terminal persistence retries", emulator, async () => {
  await repeatParallel(async (iteration) => withFirestore(`p3-concurrency-terminal-retry-${iteration}`, async (firestore) => {
    const source = dispatch();
    await seed(firestore, pending(), source);
    const auditId = deriveAuditEventId(operationId, "failure", "terminal_failure", 0, 0);
    await firestore.collection("provisioningAudit").doc(auditId).set({ invalid: true });
    const store = new FirestoreWorkerStore(firestore);
    await assert.rejects(() => processProvisioningTask(store, source.dispatchId, 8));
    const failed = await snapshot(firestore, source.dispatchId);
    assert.equal(failed.operation?.status, "pending", "failed terminal persistence rolls back operation");
    assert.equal(failed.source?.workerAck, null, "failed terminal persistence rolls back acknowledgement");
    await firestore.collection("provisioningAudit").doc(auditId).delete();
    await Promise.all([processProvisioningTask(store, source.dispatchId, 8), processProvisioningTask(store, source.dispatchId, 9)]);
    await acquireInitialPending(store, source.dispatchId);
    const terminal = await snapshot(firestore, source.dispatchId);
    assert.equal(terminal.operation?.status, "failed");
    assert.equal(terminal.source?.workerAck, "terminalized");
    const stable = structuredClone(terminal);
    await Promise.all([processProvisioningTask(store, source.dispatchId, 10), processProvisioningTask(store, source.dispatchId, 11)]);
    assert.deepEqual(await snapshot(firestore, source.dispatchId), stable, "duplicate and out-of-order terminal deliveries converge");
  }));
});
