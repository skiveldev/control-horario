import assert from "node:assert/strict";
import test from "node:test";
import type { WorkerRecord, WorkerStore, WorkerTransaction } from "../../src/provisioning/boundaries.ts";
import { deriveDispatchId, deriveOwnerToken } from "../../src/provisioning/ids.ts";
import { processProvisioningTask } from "../../src/provisioning/worker.ts";

const operationId = "82ac2574-9e1c-4d72-a6de-55624774f96c";
const fingerprint = "a".repeat(64);
const dispatchId = deriveDispatchId(operationId, "acquire", 0, 0);
const now = 1_700_000_000_000;

function operation(): WorkerRecord {
  return {
    schemaVersion: 1, operationId, fingerprint,
    normalizedPayload: {
      email: "ana@example.com", nombre: "Ana", apellido1: "García", apellido2: null,
      employeeId: "EMP-7", weeklyHours: 40, dni: null, telefono: null, cargo: null,
      departamento: null, empresa: null, scheduleId: null, calendarId: null,
      fechaInicio: null, fechaFin: null, role: "employee", isSupervisor: false,
      supervisorId: null, isActive: true,
    },
    intendedUid: "uid-ana", submittedByDigest: "b".repeat(64),
    status: "pending", phase: "dispatch_pending", generation: 0, version: 0,
    ownerToken: null, leaseExpiresAt: null, currentDispatchId: null,
    authAttempted: false, authAttempt: null, createdAt: now, updatedAt: now,
  };
}

function dispatch(): WorkerRecord {
  return {
    schemaVersion: 1, dispatchId, taskId: dispatchId, operationId, fingerprint,
    boundary: "acquire", generation: 0, sourceVersion: 0,
    ownerSeed: deriveOwnerToken(dispatchId, 0), enqueued: true, enqueuedAt: now,
    enqueueSource: "trigger", enqueueEventId: "c".repeat(64), workerAck: null,
    workerAckAt: null, createdAt: now,
  };
}

class Store implements WorkerStore {
  readonly operations = new Map<string, WorkerRecord>([[operationId, operation()]]);
  readonly dispatches = new Map<string, WorkerRecord>([[dispatchId, dispatch()]]);
  readonly audits = new Map<string, WorkerRecord>();
  failTransactions = false;

  async transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
    if (this.failTransactions) throw new Error("durable store unavailable");
    const operations = new Map(this.operations);
    const dispatches = new Map(this.dispatches);
    const audits = new Map(this.audits);
    const transaction: WorkerTransaction = {
      now,
      readOperation: async (id) => operations.get(id) ?? null,
      readDispatch: async (id) => dispatches.get(id) ?? null,
      readAudit: async (id) => audits.get(id) ?? null,
      readProfile: async () => null,
      writeOperation: (id, value) => operations.set(id, value),
      writeDispatch: (id, value) => dispatches.set(id, value),
      createDispatch: (id, value) => {
        if (dispatches.has(id)) throw new Error("dispatch conflict");
        dispatches.set(id, value);
      },
      createAudit: (id, value) => {
        if (audits.has(id)) throw new Error("audit conflict");
        audits.set(id, value);
      },
      writeProfile: () => {},
    };
    const result = await work(transaction);
    this.operations.clear(); this.dispatches.clear(); this.audits.clear();
    for (const [id, value] of operations) this.operations.set(id, value);
    for (const [id, value] of dispatches) this.dispatches.set(id, value);
    for (const [id, value] of audits) this.audits.set(id, value);
    return result;
  }
}

function snapshot(store: Store) {
  return structuredClone({ operations: [...store.operations], dispatches: [...store.dispatches], audits: [...store.audits] });
}

test("retry counts 0 through 7 enter normal acquisition work", async () => {
  for (let retryCount = 0; retryCount <= 7; retryCount += 1) {
    const store = new Store();
    await processProvisioningTask(store, dispatchId, retryCount);
    assert.equal(store.operations.get(operationId)?.status, "active", `retry ${retryCount}`);
    assert.equal(store.dispatches.get(dispatchId)?.workerAck, "processed", `retry ${retryCount}`);
  }
});

test("reserved retries 8 through 11 terminalize without normal acquisition", async () => {
  for (let retryCount = 8; retryCount <= 11; retryCount += 1) {
    const store = new Store();
    await processProvisioningTask(store, dispatchId, retryCount);
    const terminal = store.operations.get(operationId)!;
    assert.equal(terminal.status, "failed", `retry ${retryCount}`);
    assert.equal(terminal.phase, "terminal", `retry ${retryCount}`);
    assert.equal((terminal.retryEvidence as { maxRetryCountSeen: number }).maxRetryCountSeen, retryCount);
    assert.equal(store.dispatches.get(dispatchId)?.workerAck, "terminalized", `retry ${retryCount}`);
    assert.equal(store.dispatches.size, 1, `retry ${retryCount} must not create normal work`);
  }
});

test("committed terminal state is a successful idempotent reserved retry", async () => {
  const store = new Store();
  await processProvisioningTask(store, dispatchId, 8);
  const committed = snapshot(store);
  await processProvisioningTask(store, dispatchId, 11);
  assert.deepEqual(snapshot(store), committed);
});

test("invalid retry metadata fails closed before work", async () => {
  for (const retryCount of [-1, 12, 1.5, NaN, Infinity, undefined, null, "8", {}]) {
    const store = new Store();
    const before = snapshot(store);
    await assert.rejects(() => processProvisioningTask(store, dispatchId, retryCount), /invalid provisioning task retry count/);
    assert.deepEqual(snapshot(store), before, String(retryCount));
  }
});

test("durable terminalization failure remains retryable without an exhaustion success", async () => {
  for (const retryCount of [8, 11]) {
    const store = new Store();
    store.failTransactions = true;
    const before = snapshot(store);
    await assert.rejects(() => processProvisioningTask(store, dispatchId, retryCount), /durable-store outage|durable store unavailable/);
    assert.deepEqual(snapshot(store), before, `retry ${retryCount}`);
  }

  const recovered = new Store();
  recovered.failTransactions = true;
  await assert.rejects(() => processProvisioningTask(recovered, dispatchId, 8), /durable store unavailable/);
  recovered.failTransactions = false;
  await processProvisioningTask(recovered, dispatchId, 9);
  assert.equal(recovered.operations.get(operationId)?.status, "failed");
  assert.equal(recovered.dispatches.get(dispatchId)?.workerAck, "terminalized");
});
