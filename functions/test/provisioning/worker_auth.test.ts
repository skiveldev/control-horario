import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import test from "node:test";
import { createProvisioningWorkerRuntime, onTaskDispatched } from "../../src/index.ts";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import {
  FirebaseAuthReader,
  FirestoreWorkerStore,
  type AuthCreateOutcome,
  type AuthCreator,
  type AuthIdentity,
  type AuthReader,
  type WorkerRecord,
  type WorkerStore,
  type WorkerTransaction,
} from "../../src/provisioning/boundaries.ts";
import { deriveAuditEventId, deriveDispatchId, deriveOwnerToken } from "../../src/provisioning/ids.ts";
import { isValidAuditEvent } from "../../src/provisioning/audit.ts";
import { isValidDispatch, isValidOperation } from "../../src/provisioning/schemas.ts";
import {
  acquireInitialPending,
  acknowledgeStaleDelivery,
  classifyProvisioningDelivery,
  completeProfileCommit,
  createAuthUser,
  preflightAuth,
  persistAuthIntent,
  takeoverExpiredCurrent,
  terminalizeActiveCurrent,
  terminalizeInitialPending,
  processProvisioningTask,
} from "../../src/provisioning/worker.ts";

const operationId = "82ac2574-9e1c-4d72-a6de-55624774f96c";
const otherOperationId = "92ac2574-9e1c-4d72-a6de-55624774f96c";
const fingerprint = "a".repeat(64);
const otherFingerprint = "f".repeat(64);
const ownerSeed = "b".repeat(64);
const submittedByDigest = "c".repeat(64);
const ownerToken = "d".repeat(64);
const now = 1_700_000_000_000;

function functionsEmulatorProjectId(): string {
  return process.env.GCLOUD_PROJECT || "demo-no-project";
}

function taskEndpointUrl(projectId: string): string {
  return `http://${process.env.FUNCTIONS_EMULATOR_HOST}/${projectId}/us-central1/onTaskDispatched`;
}

const payload = {
  email: "ana@example.com", nombre: "Ana", apellido1: "García", apellido2: null,
  employeeId: "EMP-7", weeklyHours: 40, dni: null, telefono: null, cargo: null,
  departamento: null, empresa: null, scheduleId: null, calendarId: null,
  fechaInicio: null, fechaFin: null, role: "employee", isSupervisor: false,
  supervisorId: null, isActive: true,
};

type RecordValue = Record<string, unknown>;

function operation(active = false): RecordValue {
  const boundary = "auth_preflight";
  const dispatchId = deriveDispatchId(operationId, boundary, 0, 1);
  return {
    schemaVersion: 1, operationId, fingerprint,
    normalizedPayload: payload,
    intendedUid: "uid-ana", submittedByDigest,
    status: active ? "active" : "pending", phase: active ? boundary : "dispatch_pending",
    generation: 0, version: active ? 1 : 0, ownerToken: active ? ownerToken : null,
    leaseExpiresAt: active ? now + 60_000 : null, currentDispatchId: active ? dispatchId : null,
    authAttempted: false, authAttempt: null, createdAt: now, updatedAt: now,
  };
}

function dispatch(active = false, sourceVersion = active ? 1 : 0): RecordValue {
  const boundary = active ? "auth_preflight" : "acquire";
  const dispatchId = deriveDispatchId(operationId, boundary, 0, sourceVersion);
  return {
    schemaVersion: 1, dispatchId, taskId: dispatchId, operationId, fingerprint, boundary,
    generation: 0, sourceVersion, ownerSeed, enqueued: true, enqueuedAt: now,
    enqueueSource: "trigger", enqueueEventId: "e".repeat(64), workerAck: null,
    workerAckAt: null, createdAt: now,
  };
}

function activeDispatch(
  generation: number,
  sourceVersion: number,
  boundary = "auth_preflight",
  createdAt = now,
): RecordValue {
  const dispatchId = deriveDispatchId(operationId, boundary, generation, sourceVersion);
  return {
    ...dispatch(true, sourceVersion), dispatchId, taskId: dispatchId, boundary,
    generation, sourceVersion, ownerSeed: deriveOwnerToken(dispatchId, generation), createdAt,
  };
}

function activeOperation(
  dispatchId: string,
  generation: number,
  version: number,
  phase = "auth_preflight",
  createdAt = now,
  updatedAt = now + 100,
): RecordValue {
  return {
    ...operation(true), phase, generation, version, currentDispatchId: dispatchId,
    createdAt, updatedAt,
  };
}

function classify(
  operationRecord: RecordValue | null,
  dispatchRecord: RecordValue | null,
  overrides: Partial<Record<"deliveryDispatchId" | "dispatchDocumentId", string>> = {},
) {
  const dispatchId = dispatchRecord?.dispatchId as string;
  return classifyProvisioningDelivery({
    deliveryDispatchId: overrides.deliveryDispatchId ?? dispatchId,
    dispatchDocumentId: overrides.dispatchDocumentId ?? dispatchId,
    operationSnapshot: operationRecord,
    dispatchSnapshot: dispatchRecord,
  });
}

test("accepts only exact pending-initial and active-current trusted snapshot tuples", () => {
  const initialOperation = operation();
  const initialDispatch = dispatch();
  assert.equal(isValidOperation(initialOperation), true);
  assert.equal(isValidDispatch(initialDispatch), true);
  assert.equal(classify(initialOperation, initialDispatch), "eligible");
  assert.equal(classify(operation(true), dispatch(true)), "eligible");
});

test("requires exact pending tuple and timestamp coherence", () => {
  const initialOperation = operation();
  const initialDispatch = dispatch();
  const vectors: readonly [string, RecordValue, RecordValue, string][] = [
    ["equal timestamps", initialOperation, initialDispatch, "eligible"],
    ["wrong pending boundary", initialOperation, activeDispatch(0, 0, "auth_preflight"), "mismatch"],
    ["wrong pending generation", initialOperation, activeDispatch(1, 0, "acquire"), "mismatch"],
    ["wrong pending source version", initialOperation, activeDispatch(0, 1, "acquire"), "mismatch"],
    ["operation updated after dispatch", { ...initialOperation, updatedAt: now + 1 }, initialDispatch, "mismatch"],
    ["dispatch created after operation", initialOperation, { ...initialDispatch, createdAt: now + 1 }, "mismatch"],
  ];
  for (const [name, operationRecord, dispatchRecord, expected] of vectors) {
    assert.equal(classify(operationRecord, dispatchRecord), expected, name);
  }
});

test("classifies the active retained temporal matrix without inferring issuance", () => {
  const currentId = "f".repeat(64);
  const relationVectors: readonly [string, number, number, readonly [string, string]][] = [
    ["lower generation lower source version", 1, 4, ["eligible", "stale_eligible"]],
    ["lower generation same source version", 1, 5, ["mismatch", "mismatch"]],
    ["lower generation future source version", 1, 6, ["mismatch", "mismatch"]],
    ["same generation lower source version", 2, 4, ["eligible", "stale_eligible"]],
    ["same generation same source version", 2, 5, ["eligible", "mismatch"]],
    ["same generation future source version", 2, 6, ["mismatch", "mismatch"]],
    ["future generation lower source version", 3, 4, ["mismatch", "mismatch"]],
    ["future generation same source version", 3, 5, ["mismatch", "mismatch"]],
    ["future generation future source version", 3, 6, ["mismatch", "mismatch"]],
  ];
  for (const [name, dispatchGeneration, sourceVersion, [current, noncurrent]] of relationVectors) {
    const dispatchRecord = activeDispatch(dispatchGeneration, sourceVersion);
    assert.equal(classify(activeOperation(dispatchRecord.dispatchId as string, 2, 5), dispatchRecord), current, `${name} current`);
    assert.equal(classify(activeOperation(currentId, 2, 5), dispatchRecord), noncurrent, `${name} noncurrent`);
  }

  const retained = activeDispatch(2, 4);
  const active = activeOperation(retained.dispatchId as string, 2, 5);
  const adversarialVectors: readonly [string, RecordValue, RecordValue, string][] = [
    ["wrong active boundary", active, activeDispatch(2, 4, "auth_create"), "mismatch"],
    ["dispatch at operation updated boundary", active, { ...retained, createdAt: now + 100 }, "eligible"],
    ["dispatch before operation lifetime", active, { ...retained, createdAt: now - 1 }, "mismatch"],
    ["dispatch after operation lifetime", active, { ...retained, createdAt: now + 101 }, "mismatch"],
  ];
  for (const [name, operationRecord, dispatchRecord, expected] of adversarialVectors) {
    assert.equal(classify(operationRecord, dispatchRecord), expected, name);
  }
});

test("classifies valid dispatch self-identity conflicts as corrupt", () => {
  const initial = dispatch();
  const otherId = "f".repeat(64);
  assert.equal(classify(operation(), initial, { dispatchDocumentId: otherId }), "corrupt");
  assert.equal(classify(operation(), { ...initial, taskId: otherId }), "corrupt");
  assert.equal(classify(operation(), { ...initial, dispatchId: otherId, taskId: otherId }), "corrupt");
});

test("classifies request and cross-record identity conflicts as mismatch", () => {
  const initial = dispatch();
  assert.equal(classify(operation(), initial, { deliveryDispatchId: otherFingerprint }), "mismatch");
  assert.equal(classify({ ...operation(), operationId: otherOperationId }, initial), "mismatch");
  assert.equal(classify({ ...operation(), fingerprint: otherFingerprint }, initial), "mismatch");
});

test("preserves orphan, terminal, and duplicate precedence after trusted identity checks", () => {
  const initial = dispatch();
  assert.equal(classify(null, initial), "orphan");
  assert.equal(classifyProvisioningDelivery({
    deliveryDispatchId: initial.dispatchId,
    dispatchDocumentId: initial.dispatchId,
    operationSnapshot: operation(),
    dispatchSnapshot: null,
  }), "orphan");
  const terminal = {
    ...operation(true), status: "failed", phase: "terminal", ownerToken: null,
    leaseExpiresAt: null, currentDispatchId: null,
  };
  assert.equal(classify(terminal, { ...initial, workerAck: "stale", workerAckAt: now }), "terminal");
  assert.equal(classify(operation(), { ...initial, workerAck: "stale", workerAckAt: now }), "duplicate");
});

test("fails closed for malformed exact envelopes, snapshots, accessors, and reflection", () => {
  const initial = dispatch();
  assert.equal(classifyProvisioningDelivery({
    deliveryDispatchId: initial.dispatchId,
    dispatchDocumentId: initial.dispatchId,
    operationSnapshot: operation(),
    dispatchSnapshot: initial,
    unexpected: true,
  }), "malformed");
  assert.equal(classify(operation(), { ...initial, taskId: 1 }), "malformed");
  const { workerAckAt: _workerAckAt, ...missingDispatchField } = initial;
  assert.equal(classify(operation(), missingDispatchField), "malformed");
  assert.equal(classify({ ...operation(), unexpected: true }, initial), "malformed");

  const accessorEnvelope: RecordValue = {
    deliveryDispatchId: initial.dispatchId,
    dispatchDocumentId: initial.dispatchId,
    operationSnapshot: operation(),
    dispatchSnapshot: initial,
  };
  let getterInvoked = false;
  Object.defineProperty(accessorEnvelope, "dispatchDocumentId", {
    get() { getterInvoked = true; throw new Error("must not read"); },
  });
  assert.equal(classifyProvisioningDelivery(accessorEnvelope), "malformed");
  assert.equal(getterInvoked, false);

  const accessorOperation = operation();
  Object.defineProperty(accessorOperation, "operationId", {
    get() { getterInvoked = true; throw new Error("must not read"); },
  });
  assert.equal(classify(accessorOperation, initial), "malformed");
  assert.equal(getterInvoked, false);
  const throwingProxy = new Proxy(operation(), { ownKeys() { throw new Error("reflection failed"); } });
  assert.equal(classify(throwingProxy, initial), "malformed");
});

test("classification retains caller snapshots and has no external effect", () => {
  const active = operation(true);
  const current = dispatch(true);
  const envelope = {
    deliveryDispatchId: current.dispatchId,
    dispatchDocumentId: current.dispatchId,
    operationSnapshot: active,
    dispatchSnapshot: current,
  };
  const before = structuredClone(envelope);
  assert.equal(classifyProvisioningDelivery(envelope), "eligible");
  assert.deepEqual(envelope, before);
  assert.equal(envelope.operationSnapshot, active);
  assert.equal(envelope.dispatchSnapshot, current);
});

class ReferenceWorkerTransaction implements WorkerTransaction {
  readonly now = now;
  readonly records = new Map<string, WorkerRecord>();
  writes = 0;

  async readOperation(_operationId: string): Promise<WorkerRecord | null> { return null; }
  async readDispatch(_dispatchId: string): Promise<WorkerRecord | null> { return null; }
  async readAudit(eventId: string): Promise<WorkerRecord | null> {
    return this.records.get(eventId) ?? null;
  }
  async readProfile(_userId: string): Promise<WorkerRecord | null> { return null; }
  writeOperation(_operationId: string, _operation: WorkerRecord): void { this.writes += 1; }
  writeDispatch(_dispatchId: string, _dispatch: WorkerRecord): void { this.writes += 1; }
  createDispatch(_dispatchId: string, _dispatch: WorkerRecord): void { this.writes += 1; }
  createAudit(_eventId: string, _audit: WorkerRecord): void { this.writes += 1; }
  writeProfile(_userId: string, _profile: WorkerRecord): void { this.writes += 1; }
}

async function readAuditThroughPort(
  transaction: WorkerTransaction,
  eventId: string,
): Promise<WorkerRecord | null> {
  return transaction.readAudit(eventId);
}

const auditEventId = "e".repeat(64);
const auditRecord: WorkerRecord = {
  schemaVersion: 1,
  eventId: auditEventId,
  operationId,
  correlationId: "f".repeat(64),
  category: "progress",
  stage: "dispatch",
  outcome: "accepted",
  code: "none",
  actorUidDigest: null,
  intendedUidDigest: null,
  dispatchId: null,
  generation: null,
  sourceVersion: null,
  createdAt: now,
};

test("reference WorkerTransaction returns audit records and missing audits without writes", async () => {
  const transaction = new ReferenceWorkerTransaction();
  transaction.records.set(auditEventId, auditRecord);

  assert.equal(await readAuditThroughPort(transaction, auditEventId), auditRecord);
  assert.equal(await readAuditThroughPort(transaction, "d".repeat(64)), null);
  assert.equal(transaction.writes, 0);
});

test("Firestore worker store reads existing and missing audit records without writes", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-read-audit-worker" }, "p3-read-audit-worker");
  try {
    const firestore = getFirestore(app);
    await firestore.collection("provisioningAudit").doc(auditEventId).set(auditRecord);
    const store = new FirestoreWorkerStore(firestore);

    assert.deepEqual(await store.transaction((transaction) => transaction.readAudit(auditEventId)), auditRecord);
    assert.equal(await store.transaction((transaction) => transaction.readAudit("d".repeat(64))), null);
    assert.deepEqual(await firestore.collection("provisioningAudit").doc(auditEventId).get().then((snapshot) => snapshot.data()), auditRecord);
  } finally {
    await deleteApp(app);
  }
});

test("Firestore worker store propagates an injected audit get failure without writes", async () => {
  const failure = new Error("audit read failed");
  const reads: string[] = [];
  let writes = 0;
  const db = {
    collection(collection: string) {
      return { doc(id: string) { return { collection, id }; } };
    },
    async runTransaction<T>(work: (transaction: {
      get(reference: { readonly collection: string; readonly id: string }): Promise<unknown>;
      set(): void;
      create(): void;
    }) => Promise<T>): Promise<T> {
      return work({
        async get(reference) {
          reads.push(`${reference.collection}/${reference.id}`);
          if (reference.collection === "provisioningWorkerClock") {
            return { readTime: { toMillis: () => now } };
          }
          throw failure;
        },
        set() { writes += 1; },
        create() { writes += 1; },
      });
    },
  } as unknown as Firestore;

  await assert.rejects(
    () => new FirestoreWorkerStore(db).transaction((transaction) => transaction.readAudit(auditEventId)),
    failure,
  );
  assert.deepEqual(reads, ["provisioningWorkerClock/server", `provisioningAudit/${auditEventId}`]);
  assert.equal(writes, 0);
});

class StrictWorkerStore implements WorkerStore {
  readonly operations = new Map<string, WorkerRecord>();
  readonly dispatches = new Map<string, WorkerRecord>();
  readonly audits = new Map<string, WorkerRecord>();
      readonly profiles = new Map<string, WorkerRecord>();
  readonly calls: string[] = [];
  now = now + 1_000;
  failAuditCreate = false;
  failDispatchCreateAfterAbsentRead = false;

  async transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
    const operations = new Map(this.operations);
    const dispatches = new Map(this.dispatches);
    const audits = new Map(this.audits);
        const profiles = new Map(this.profiles);
    const absentDispatchReads = new Set<string>();
    const transaction: WorkerTransaction = {
      now: this.now,
      readOperation: async (id) => { this.calls.push(`readOperation:${id}`); return operations.get(id) ?? null; },
      readDispatch: async (id) => {
        this.calls.push(`readDispatch:${id}`);
        const record = dispatches.get(id) ?? null;
        if (record === null) absentDispatchReads.add(id);
        return record;
      },
      readAudit: async (id) => { this.calls.push(`readAudit:${id}`); return audits.get(id) ?? null; },
          readProfile: async (id) => { this.calls.push(`readProfile:${id}`); return profiles.get(id) ?? null; },
      writeOperation: (id, value) => { this.calls.push(`writeOperation:${id}`); operations.set(id, value); },
      writeDispatch: (id, value) => { this.calls.push(`writeDispatch:${id}`); dispatches.set(id, value); },
      createDispatch: (id, value) => {
        this.calls.push(`createDispatch:${id}`);
        if (this.failDispatchCreateAfterAbsentRead && absentDispatchReads.has(id)) {
          throw new Error("dispatch create after absent read conflict");
        }
        if (dispatches.has(id)) throw new Error("dispatch create conflict");
        dispatches.set(id, value);
      },
      writeProfile: (id, value) => { this.calls.push(`writeProfile:${id}`); profiles.set(id, value); },
          createAudit: (id, value) => {
        this.calls.push(`createAudit:${id}`);
        if (this.failAuditCreate || audits.has(id)) throw new Error("audit create conflict");

        audits.set(id, value);
      },
    };
    const result = await work(transaction);
    this.operations.clear(); this.dispatches.clear(); this.audits.clear(); this.profiles.clear();
    for (const [id, value] of operations) this.operations.set(id, value);
    for (const [id, value] of dispatches) this.dispatches.set(id, value);
    for (const [id, value] of audits) this.audits.set(id, value);
        for (const [id, value] of profiles) this.profiles.set(id, value);
    return result;
  }
}

function strictStoreSnapshot(store: StrictWorkerStore) {
  return structuredClone({
    operations: [...store.operations],
    dispatches: [...store.dispatches],
    audits: [...store.audits],
        profiles: [...store.profiles],
  });
}

test("StrictWorkerStore creates an absent dispatch exactly once", async () => {
  const store = new StrictWorkerStore();
  const candidate = dispatch();
  const dispatchId = candidate.dispatchId as string;

  await store.transaction(async (transaction) => {
    transaction.createDispatch(dispatchId, candidate);
  });

  assert.equal(store.dispatches.size, 1);
  assert.equal(store.dispatches.get(dispatchId), candidate);
});

test("StrictWorkerStore duplicate dispatch creation rejects without overwriting staged maps", async () => {
  const store = new StrictWorkerStore();
  const existingDispatch = dispatch();
  const replacement = { ...existingDispatch, ownerSeed: "f".repeat(64) };
  store.operations.set(operationId, operation());
  store.dispatches.set(existingDispatch.dispatchId as string, existingDispatch);
  store.audits.set(auditEventId, auditRecord);
  const before = strictStoreSnapshot(store);

  await assert.rejects(
    () => store.transaction(async (transaction) => {
      transaction.writeOperation(operationId, operation(true));
      transaction.createAudit("d".repeat(64), { ...auditRecord, eventId: "d".repeat(64) });
      transaction.createDispatch(existingDispatch.dispatchId as string, replacement);
    }),
    /dispatch create conflict/,
  );

  assert.deepEqual(strictStoreSnapshot(store), before);
});

test("StrictWorkerStore rolls back all maps after a later callback failure", async () => {
  const store = new StrictWorkerStore();
  const existingDispatch = dispatch();
  store.operations.set(operationId, operation());
  store.dispatches.set(existingDispatch.dispatchId as string, existingDispatch);
  store.audits.set(auditEventId, auditRecord);
  const before = strictStoreSnapshot(store);
  const created = { ...dispatch(), dispatchId: "d".repeat(64), taskId: "d".repeat(64) };

  await assert.rejects(
    () => store.transaction(async (transaction) => {
      transaction.writeOperation(operationId, operation(true));
      transaction.createDispatch(created.dispatchId as string, created);
      transaction.createAudit("f".repeat(64), { ...auditRecord, eventId: "f".repeat(64) });
      throw new Error("injected callback failure");
    }),
    /injected callback failure/,
  );

  assert.deepEqual(strictStoreSnapshot(store), before);
});

interface AcquisitionRecords {
      readonly operation: RecordValue;
      readonly source: RecordValue;
      readonly sourceId: string;
      readonly nextId: string;
      readonly auditId: string;
    }

    function acquisitionRecords(overrides: { readonly operation?: RecordValue; readonly source?: RecordValue } = {}): AcquisitionRecords {
      const initial = overrides.operation ?? operation();
      const sourceId = deriveDispatchId(initial.operationId as string, "acquire", 0, 0);
      const source = {
        ...dispatch(), ...overrides.source, dispatchId: sourceId, taskId: sourceId,
        operationId: initial.operationId, fingerprint: initial.fingerprint,
        ownerSeed: deriveOwnerToken(sourceId, 0), generation: 0, sourceVersion: 0,
      };
      return { operation: initial, source, sourceId, nextId: deriveDispatchId(initial.operationId as string, "auth_preflight", 0, 1), auditId: deriveAuditEventId(initial.operationId as string, "progress", "state_transition", 0, 0) };
    }

    function acquisitionAudit(records: AcquisitionRecords, createdAt: number): WorkerRecord {
      return {
        schemaVersion: 1, eventId: records.auditId, operationId: records.operation.operationId,
        correlationId: createHash("sha256").update(`provision-correlation:v1\0${records.operation.operationId as string}`, "utf8").digest("hex"),
        category: "progress", stage: "state_transition", outcome: "started", code: "success",
        actorUidDigest: null, intendedUidDigest: null, dispatchId: records.sourceId,
        generation: 0, sourceVersion: 0, createdAt,
      };
    }

    function seedAcquisition(store: StrictWorkerStore, records: AcquisitionRecords): void {
      store.operations.set(records.operation.operationId as string, records.operation);
      store.dispatches.set(records.sourceId, records.source);
    }

    function assertAcquired(store: StrictWorkerStore, records: AcquisitionRecords, auditCreatedAt = store.now): void {
      assert.deepEqual(store.calls.slice(0, 4), [
        `readDispatch:${records.sourceId}`, `readOperation:${records.operation.operationId}`,
        `readAudit:${records.auditId}`, `readDispatch:${records.nextId}`,
      ]);
      assert.deepEqual(store.operations.get(records.operation.operationId as string), {
        ...records.operation, status: "active", phase: "auth_preflight", version: 1,
        ownerToken: deriveOwnerToken(records.sourceId, 0), leaseExpiresAt: store.now + 60_000,
        currentDispatchId: records.nextId, updatedAt: store.now,
      });
      assert.deepEqual(store.dispatches.get(records.sourceId), { ...records.source, workerAck: "processed", workerAckAt: store.now });
      assert.deepEqual(store.audits.get(records.auditId), acquisitionAudit(records, auditCreatedAt));
      assert.deepEqual(store.dispatches.get(records.nextId), {
        schemaVersion: 1, dispatchId: records.nextId, taskId: records.nextId,
        operationId: records.operation.operationId, fingerprint: records.operation.fingerprint,
        boundary: "auth_preflight", generation: 0, sourceVersion: 1,
        ownerSeed: deriveOwnerToken(records.nextId, 0), enqueued: false, enqueuedAt: null,
        enqueueSource: null, enqueueEventId: null, workerAck: null, workerAckAt: null, createdAt: store.now,
      });
    }

    function assertUnchanged(store: StrictWorkerStore, before: unknown, label: string): void {
      assert.deepEqual(strictStoreSnapshot(store), before, label);
      assert.equal(store.calls.some((call) => call.startsWith("write") || call.startsWith("create")), false, `${label} writes`);
    }

    test("ACQ-OK reads four trusted records before atomically acquiring the exact pending tuple", async () => {
      const store = new StrictWorkerStore(); const records = acquisitionRecords(); seedAcquisition(store, records);
      await acquireInitialPending(store, records.sourceId);
      assertAcquired(store, records);
    });

    test("ACQ-FENCE-operation rejects every malformed or broken pending field and accepts legal payload and identity values", async () => {
      const invalid: readonly [string, (value: RecordValue) => RecordValue][] = [
        ["schemaVersion", (v) => ({ ...v, schemaVersion: 2 })], ["operationId", (v) => ({ ...v, operationId: "not-an-operation-id" })],
        ["fingerprint", (v) => ({ ...v, fingerprint: "invalid" })], ["normalizedPayload", (v) => ({ ...v, normalizedPayload: {} })],
        ["intendedUid", (v) => ({ ...v, intendedUid: null })], ["submittedByDigest", (v) => ({ ...v, submittedByDigest: "invalid" })],
        ["status", (v) => ({ ...v, status: "active" })], ["phase", (v) => ({ ...v, phase: "auth_preflight" })],
        ["generation", (v) => ({ ...v, generation: 1 })], ["version", (v) => ({ ...v, version: 1 })],
        ["ownerToken", (v) => ({ ...v, ownerToken })], ["leaseExpiresAt", (v) => ({ ...v, leaseExpiresAt: now })],
        ["currentDispatchId", (v) => ({ ...v, currentDispatchId: "f".repeat(64) })], ["authAttempted", (v) => ({ ...v, authAttempted: true })],
        ["authAttempt", (v) => ({ ...v, authAttempt: {} })], ["createdAt", (v) => ({ ...v, createdAt: now + 0.5 })],
        ["updatedAt", (v) => ({ ...v, updatedAt: now + 1 })],
      ];
      for (const [field, mutate] of invalid) {
        const store = new StrictWorkerStore(); const records = acquisitionRecords({ operation: mutate(operation()) }); seedAcquisition(store, records);
        const before = strictStoreSnapshot(store); await acquireInitialPending(store, records.sourceId); assertUnchanged(store, before, `operation ${field}`);
      }
      const legal = acquisitionRecords({
        operation: { ...operation(), normalizedPayload: { ...payload, employeeId: "EMP-8" }, intendedUid: "uid-legal", submittedByDigest: "e".repeat(64), createdAt: now + 2, updatedAt: now + 2 },
        source: { ...dispatch(), createdAt: now + 2 },
      });
      const legalStore = new StrictWorkerStore(); seedAcquisition(legalStore, legal); await acquireInitialPending(legalStore, legal.sourceId); assertAcquired(legalStore, legal);
    });

    test("ACQ-FENCE-source rejects every immutable-source mutation and accepts empty, trigger, and sweeper enqueue tuples", async () => {
      const invalid: readonly [string, (value: RecordValue) => RecordValue][] = [
        ["schemaVersion", (v) => ({ ...v, schemaVersion: 2 })], ["dispatchId", (v) => ({ ...v, dispatchId: "f".repeat(64) })],
        ["taskId", (v) => ({ ...v, taskId: "f".repeat(64) })], ["operationId", (v) => ({ ...v, operationId: otherOperationId })],
        ["fingerprint", (v) => ({ ...v, fingerprint: otherFingerprint })], ["boundary", (v) => ({ ...v, boundary: "auth_preflight" })],
        ["generation", (v) => ({ ...v, generation: 1 })], ["sourceVersion", (v) => ({ ...v, sourceVersion: 1 })],
        ["ownerSeed", (v) => ({ ...v, ownerSeed: "f".repeat(64) })], ["enqueued", (v) => ({ ...v, enqueued: "true" })],
        ["enqueuedAt", (v) => ({ ...v, enqueuedAt: null })], ["enqueueSource", (v) => ({ ...v, enqueueSource: "other" })],
        ["enqueueEventId", (v) => ({ ...v, enqueueEventId: "invalid" })], ["workerAck", (v) => ({ ...v, workerAck: "processed", workerAckAt: now })],
        ["workerAckAt", (v) => ({ ...v, workerAckAt: now })], ["createdAt", (v) => ({ ...v, createdAt: now + 1 })],
      ];
      for (const [field, mutate] of invalid) {
        const store = new StrictWorkerStore(); const records = acquisitionRecords();
        Object.assign(records.source, mutate(records.source)); seedAcquisition(store, records);
        const before = strictStoreSnapshot(store); await acquireInitialPending(store, records.sourceId); assertUnchanged(store, before, `source ${field}`);
      }
      for (const [name, enqueue] of [
        ["empty", { enqueued: false, enqueuedAt: null, enqueueSource: null, enqueueEventId: null }],
        ["trigger", { enqueued: true, enqueuedAt: now, enqueueSource: "trigger", enqueueEventId: "e".repeat(64) }],
        ["sweeper", { enqueued: true, enqueuedAt: now, enqueueSource: "sweeper", enqueueEventId: "f".repeat(64) }],
      ] as const) {
        const store = new StrictWorkerStore(); const records = acquisitionRecords({ source: { ...dispatch(), ...enqueue } }); seedAcquisition(store, records);
        await acquireInitialPending(store, records.sourceId); assertAcquired(store, records);
        assert.equal(store.dispatches.get(records.sourceId)!.enqueueSource, enqueue.enqueueSource, name);
      }
    });

    test("ACQ-MATCHING-AUDIT and ACQ-PROCESSED-REPLAY preserve immutable bytes", async () => {
      const store = new StrictWorkerStore(); const records = acquisitionRecords(); seedAcquisition(store, records);
      const originalAudit = acquisitionAudit(records, now - 1); store.audits.set(records.auditId, originalAudit);
      await acquireInitialPending(store, records.sourceId); assertAcquired(store, records, now - 1);
      assert.equal(store.audits.get(records.auditId), originalAudit); assert.equal(store.calls.some((call) => call.startsWith("createAudit")), false);
      const beforeReplay = strictStoreSnapshot(store); store.calls.length = 0; await acquireInitialPending(store, records.sourceId); assertUnchanged(store, beforeReplay, "processed replay");
    });

    test("ACQ-ROLLBACK restores every map after an absent next-dispatch read conflicts at create", async () => {
      const store = new StrictWorkerStore();
      const records = acquisitionRecords();
      seedAcquisition(store, records);
      const before = strictStoreSnapshot(store);
      store.failDispatchCreateAfterAbsentRead = true;

      await assert.rejects(
        () => acquireInitialPending(store, records.sourceId),
        /dispatch create after absent read conflict/,
      );

      assert.deepEqual(store.calls.slice(0, 4), [
        `readDispatch:${records.sourceId}`,
        `readOperation:${records.operation.operationId}`,
        `readAudit:${records.auditId}`,
        `readDispatch:${records.nextId}`,
      ]);
      assert.deepEqual(strictStoreSnapshot(store), before);
      assert.equal(store.dispatches.has(records.nextId), false);
      assert.equal(store.audits.has(records.auditId), false);
      assert.deepEqual(store.operations.get(records.operation.operationId as string), records.operation);
      assert.deepEqual(store.dispatches.get(records.sourceId), records.source);
    });

    test("ACQ-ROLLBACK restores every map on audit, next-dispatch, create, and CAS failures", async () => {
      const cases: readonly [string, boolean, (store: StrictWorkerStore, records: AcquisitionRecords) => void][] = [
        ["audit identity mismatch", true, (s, r) => s.audits.set(r.auditId, { ...acquisitionAudit(r, now), code: "internal" })],
        ["conflicting next dispatch", true, (s, r) => s.dispatches.set(r.nextId, { ...dispatch(), dispatchId: r.nextId, taskId: r.nextId, boundary: "auth_preflight", sourceVersion: 1 })],
        ["audit create conflict", true, (s) => { s.failAuditCreate = true; }],
        ["CAS failure", false, (s) => s.operations.set(operationId, { ...operation(), updatedAt: now + 1 })],
      ];
      for (const [name, rejects, setup] of cases) {
        const store = new StrictWorkerStore(); const records = acquisitionRecords(); seedAcquisition(store, records); setup(store, records);
        const before = strictStoreSnapshot(store);
        if (rejects) await assert.rejects(() => acquireInitialPending(store, records.sourceId), /audit identity mismatch|next dispatch conflict|audit create conflict/, name);
        else await acquireInitialPending(store, records.sourceId);
        assert.deepEqual(strictStoreSnapshot(store), before, name);
      }
    });

    function staleRecords() {
  const currentDispatchId = "f".repeat(64);
  const staleDispatch = activeDispatch(0, 4);
  return {
    staleDispatch,
    operation: activeOperation(currentDispatchId, 0, 5),
    eventId: deriveAuditEventId(operationId, "progress", "stale_delivery", 0, 4),
  };
}

function staleAudit(dispatchRecord: RecordValue, createdAt: number): WorkerRecord {
  return {
    schemaVersion: 1,
    eventId: deriveAuditEventId(operationId, "progress", "stale_delivery", dispatchRecord.generation as number, dispatchRecord.sourceVersion as number),
    operationId,
    correlationId: createHash("sha256").update(`provision-correlation:v1\0${operationId}`, "utf8").digest("hex"),
    category: "progress",
    stage: "stale_delivery",
    outcome: "stale",
    code: "stale-dispatch",
    actorUidDigest: null,
    intendedUidDigest: null,
    dispatchId: dispatchRecord.dispatchId,
    generation: dispatchRecord.generation,
    sourceVersion: dispatchRecord.sourceVersion,
    createdAt,
  };
}

test("atomically acknowledges only a trusted stale delivery and creates the exact immutable audit", async () => {
  const store = new StrictWorkerStore();
  const records = staleRecords();
  store.operations.set(operationId, records.operation);
  store.dispatches.set(records.staleDispatch.dispatchId as string, records.staleDispatch);
  const beforeOperation = structuredClone(records.operation);

  await acknowledgeStaleDelivery(store, records.staleDispatch.dispatchId as string);

  const acknowledged = store.dispatches.get(records.staleDispatch.dispatchId as string)!;
  const audit = store.audits.get(records.eventId)!;
  assert.deepEqual(store.calls.slice(0, 3), [
    `readDispatch:${records.staleDispatch.dispatchId}`,
    `readOperation:${operationId}`,
    `readAudit:${records.eventId}`,
  ]);
  assert.ok(store.calls.slice(3).every((call) => call.startsWith("write") || call.startsWith("create")));
  assert.equal(acknowledged.workerAck, "stale");
  assert.equal(acknowledged.workerAckAt, store.now);
  assert.equal(isValidAuditEvent(audit), true);
  assert.deepEqual(audit, staleAudit(records.staleDispatch, store.now));
  assert.deepEqual(store.operations.get(operationId), beforeOperation);

  const beforeReplay = structuredClone(audit);
  await acknowledgeStaleDelivery(store, records.staleDispatch.dispatchId as string);
  assert.deepEqual(store.audits.get(records.eventId), beforeReplay);
  assert.equal(store.calls.filter((call) => call.startsWith("createAudit")).length, 1);
  assert.equal(store.calls.filter((call) => call.startsWith("writeOperation")).length, 0);
});

test("retries one Firestore closed-transaction stale replay without duplicating writes", async () => {
  const strictStore = new StrictWorkerStore();
  const records = staleRecords();
  strictStore.operations.set(operationId, records.operation);
  strictStore.dispatches.set(records.staleDispatch.dispatchId as string, records.staleDispatch);
  let attempts = 0;
  const store: WorkerStore = {
    transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
      attempts += 1;
      if (attempts === 1) {
        return Promise.reject(Object.assign(new Error("INVALID_ARGUMENT: transaction invalid or closed"), { code: 3 }));
      }
      return strictStore.transaction(work);
    },
  };

  await acknowledgeStaleDelivery(store, records.staleDispatch.dispatchId as string);

  assert.equal(attempts, 2);
  assert.equal(strictStore.dispatches.get(records.staleDispatch.dispatchId as string)?.workerAck, "stale");
  assert.deepEqual(strictStore.audits.get(records.eventId), staleAudit(records.staleDispatch, strictStore.now));
});

test("fails closed for non-stale, conflicting audit, and audit-create rollback paths", async () => {
  const records = staleRecords();
  const noWriteStore = new StrictWorkerStore();
  noWriteStore.operations.set(operationId, { ...records.operation, currentDispatchId: records.staleDispatch.dispatchId });
  noWriteStore.dispatches.set(records.staleDispatch.dispatchId as string, records.staleDispatch);
  await acknowledgeStaleDelivery(noWriteStore, records.staleDispatch.dispatchId as string);
  assert.equal(noWriteStore.calls.some((call) => call.startsWith("write") || call.startsWith("create")), false);

  const conflictStore = new StrictWorkerStore();
  conflictStore.operations.set(operationId, records.operation);
  conflictStore.dispatches.set(records.staleDispatch.dispatchId as string, records.staleDispatch);
  conflictStore.audits.set(records.eventId, { ...staleAudit(records.staleDispatch, now - 1), code: "internal" });
  await assert.rejects(() => acknowledgeStaleDelivery(conflictStore, records.staleDispatch.dispatchId as string), /audit identity mismatch/);
  assert.equal(conflictStore.dispatches.get(records.staleDispatch.dispatchId as string)!.workerAck, null);

  const rollbackStore = new StrictWorkerStore();
  rollbackStore.operations.set(operationId, records.operation);
  rollbackStore.dispatches.set(records.staleDispatch.dispatchId as string, records.staleDispatch);
  rollbackStore.failAuditCreate = true;
  await assert.rejects(() => acknowledgeStaleDelivery(rollbackStore, records.staleDispatch.dispatchId as string), /audit create conflict/);
  assert.equal(rollbackStore.dispatches.get(records.staleDispatch.dispatchId as string)!.workerAck, null);
  assert.equal(rollbackStore.audits.has(records.eventId), false);
});

test("never writes for every non-stale classification", async () => {
  const stale = staleRecords();
  const initial = dispatch();
  const terminal = {
    ...operation(true), status: "failed", phase: "terminal", ownerToken: null,
    leaseExpiresAt: null, currentDispatchId: null,
  };
  const vectors: readonly [string, WorkerRecord | null, WorkerRecord | null][] = [
    ["orphan", null, null],
    ["malformed", {}, null],
    ["operation orphan", initial, null],
    ["mismatch", initial, { ...operation(), operationId: otherOperationId }],
    ["terminal", initial, terminal],
    ["duplicate", { ...initial, workerAck: "stale", workerAckAt: now }, operation()],
    ["eligible pending", initial, operation()],
    ["eligible current", dispatch(true), operation(true)],
  ];
  for (const [name, dispatchRecord, operationRecord] of vectors) {
    const store = new StrictWorkerStore();
    if (dispatchRecord !== null) store.dispatches.set(dispatchRecord.dispatchId as string, dispatchRecord);
    if (operationRecord !== null && dispatchRecord !== null) store.operations.set(dispatchRecord.operationId as string, operationRecord);
    await acknowledgeStaleDelivery(store, dispatchRecord?.dispatchId as string);
    assert.equal(store.calls.some((call) => call.startsWith("write") || call.startsWith("create")), false, name);
  }
});

test("Firestore transactions converge concurrent stale delivery replay without changing the operation", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-stale-ack-worker" }, "p3-stale-ack-worker");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = staleRecords();
    await firestore.collection("provisioningOperations").doc(operationId).set(records.operation);
    await firestore.collection("provisioningDispatch").doc(records.staleDispatch.dispatchId as string).set(records.staleDispatch);
    const operationBefore = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());

    await Promise.all([
      acknowledgeStaleDelivery(store, records.staleDispatch.dispatchId as string),
      acknowledgeStaleDelivery(store, records.staleDispatch.dispatchId as string),
    ]);
    const audit = await firestore.collection("provisioningAudit").doc(records.eventId).get().then((snapshot) => snapshot.data());
    const acknowledged = await firestore.collection("provisioningDispatch").doc(records.staleDispatch.dispatchId as string).get().then((snapshot) => snapshot.data());
    assert.equal(isValidAuditEvent(audit), true);
    assert.equal(acknowledged?.workerAck, "stale");
    assert.deepEqual(await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data()), operationBefore);

    const stableAudit = structuredClone(audit);
    await acknowledgeStaleDelivery(store, records.staleDispatch.dispatchId as string);
    assert.deepEqual(await firestore.collection("provisioningAudit").doc(records.eventId).get().then((snapshot) => snapshot.data()), stableAudit);
  } finally {
    await deleteApp(app);
  }
});

test("Firestore create precondition atomically rejects stale acknowledgement when audit exists", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-stale-ack-create-conflict" }, "p3-stale-ack-create-conflict");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = staleRecords();
    await firestore.collection("provisioningOperations").doc(operationId).set(records.operation);
    await firestore.collection("provisioningDispatch").doc(records.staleDispatch.dispatchId as string).set(records.staleDispatch);
    await firestore.collection("provisioningAudit").doc(records.eventId).create({
      ...staleAudit(records.staleDispatch, now - 1), code: "internal",
    });
    const operationBefore = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
    const dispatchBefore = await firestore.collection("provisioningDispatch").doc(records.staleDispatch.dispatchId as string).get().then((snapshot) => snapshot.data());
    const auditBefore = await firestore.collection("provisioningAudit").doc(records.eventId).get().then((snapshot) => snapshot.data());

    await assert.rejects(
      () => store.transaction(async (transaction) => {
        const staleDispatch = await transaction.readDispatch(records.staleDispatch.dispatchId as string);
        assert.ok(staleDispatch);
        transaction.writeDispatch(staleDispatch.dispatchId as string, {
          ...staleDispatch, workerAck: "stale", workerAckAt: transaction.now,
        });
        transaction.createAudit(records.eventId, staleAudit(records.staleDispatch, transaction.now));
      }),
      (error: unknown) => {
        assert.equal((error as { code?: unknown }).code, 6, "expected Firestore ALREADY_EXISTS (code 6)");
        return true;
      },
    );

    assert.deepEqual(await firestore.collection("provisioningDispatch").doc(records.staleDispatch.dispatchId as string).get().then((snapshot) => snapshot.data()), dispatchBefore);
    assert.deepEqual(await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data()), operationBefore);
    assert.deepEqual(await firestore.collection("provisioningAudit").doc(records.eventId).get().then((snapshot) => snapshot.data()), auditBefore);
  } finally {
    await deleteApp(app);
  }
});

async function realAcquisitionSnapshots(firestore: Firestore, records: AcquisitionRecords) {
  return {
    operation: await firestore.collection("provisioningOperations").doc(records.operation.operationId as string).get().then((snapshot) => snapshot.data()),
    source: await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data()),
    audit: await firestore.collection("provisioningAudit").doc(records.auditId).get().then((snapshot) => snapshot.data()),
    next: await firestore.collection("provisioningDispatch").doc(records.nextId).get().then((snapshot) => snapshot.data()),
  };
}

function expectedRealAcquisition(records: AcquisitionRecords, transactionNow: number) {
  return {
    operation: {
      ...records.operation, status: "active", phase: "auth_preflight", version: 1,
      ownerToken: deriveOwnerToken(records.sourceId, 0), leaseExpiresAt: transactionNow + 60_000,
      currentDispatchId: records.nextId, updatedAt: transactionNow,
    },
    source: { ...records.source, workerAck: "processed", workerAckAt: transactionNow },
    next: {
      schemaVersion: 1, dispatchId: records.nextId, taskId: records.nextId,
      operationId: records.operation.operationId, fingerprint: records.operation.fingerprint,
      boundary: "auth_preflight", generation: 0, sourceVersion: 1,
      ownerSeed: deriveOwnerToken(records.nextId, 0), enqueued: false, enqueuedAt: null,
      enqueueSource: null, enqueueEventId: null, workerAck: null, workerAckAt: null, createdAt: transactionNow,
    },
  };
}

test("REAL-ACQ-ONE-WINNER converges competing initial acquisitions", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-real-acq-one-winner" }, "p3-real-acq-one-winner");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = acquisitionRecords();
    await firestore.collection("provisioningOperations").doc(records.operation.operationId as string).set(records.operation);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    let releaseStart!: () => void;
    const start = new Promise<void>((resolve) => { releaseStart = resolve; });
    const workers = [
      (async () => { await start; await acquireInitialPending(store, records.sourceId); })(),
      (async () => { await start; await acquireInitialPending(store, records.sourceId); })(),
    ];
    releaseStart();
    await Promise.all(workers);

    const persisted = await realAcquisitionSnapshots(firestore, records);
    const expected = expectedRealAcquisition(records, persisted.operation!.updatedAt as number);
    assert.equal(isValidOperation(persisted.operation), false, "acquired operation is no longer an initial operation");
    assert.deepEqual(persisted.operation, expected.operation);
    assert.deepEqual(persisted.source, expected.source);
    assert.deepEqual(persisted.next, expected.next);
    assert.deepEqual(persisted.audit, acquisitionAudit(records, persisted.operation!.updatedAt as number));
    const stable = structuredClone(persisted);
    await acquireInitialPending(store, records.sourceId);
    assert.deepEqual(await realAcquisitionSnapshots(firestore, records), stable);
  } finally {
    await deleteApp(app);
  }
});

test("P3.17 REAL-ACQ-TWO-APPS converges two independently initialized clients without return-value winner inference", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const projectId = "p3-real-acq-two-app-concurrency";
  const firstApp = initializeApp({ projectId }, "p3-real-acq-two-app-first");
  const secondApp = initializeApp({ projectId }, "p3-real-acq-two-app-second");
  try {
    const firstFirestore = getFirestore(firstApp);
    const secondFirestore = getFirestore(secondApp);
    const firstStore = new FirestoreWorkerStore(firstFirestore);
    const secondStore = new FirestoreWorkerStore(secondFirestore);
    const records = acquisitionRecords();
    await firstFirestore.collection("provisioningOperations").doc(records.operation.operationId as string).set(records.operation);
    await firstFirestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    let releaseStart!: () => void;
    const start = new Promise<void>((resolve) => { releaseStart = resolve; });
    const workers = [
      (async () => { await start; await acquireInitialPending(firstStore, records.sourceId); })(),
      (async () => { await start; await acquireInitialPending(secondStore, records.sourceId); })(),
    ];
    releaseStart();
    await Promise.all(workers);

    const persisted = await realAcquisitionSnapshots(firstFirestore, records);
    const persistedOperation = persisted.operation;
    const persistedSource = persisted.source;
    assert.ok(persistedOperation, "acquisition persists an operation");
    assert.ok(persistedSource, "acquisition persists its source dispatch");
    const transactionNow = persistedOperation["updatedAt"];
    assert.ok(typeof transactionNow === "number", "operation updatedAt is a transaction timestamp");
    const generation = persistedOperation["generation"];
    const version = persistedOperation["version"];
    const persistedOwner = persistedOperation["ownerToken"];
    const leaseExpiresAt = persistedOperation["leaseExpiresAt"];
    const workerAck = persistedSource["workerAck"];
    assert.ok(typeof generation === "number", "operation generation is numeric");
    assert.ok(typeof version === "number", "operation version is numeric");
    assert.ok(typeof persistedOwner === "string", "operation owner token is present");
    assert.ok(typeof leaseExpiresAt === "number", "operation lease expiry is numeric");
    assert.ok(typeof workerAck === "string", "source acknowledgement is present");
    assert.equal(generation, 0);
    assert.equal(version, 1);
    assert.equal(persistedOwner, deriveOwnerToken(records.sourceId, 0));
    assert.equal(leaseExpiresAt, transactionNow + 60_000);
    assert.equal(workerAck, "processed");
    const expected = expectedRealAcquisition(records, transactionNow);
    assert.deepEqual(persistedOperation, expected.operation);
    assert.deepEqual(persistedSource, expected.source);
    assert.deepEqual(persisted.next, expected.next);
    assert.deepEqual(persisted.audit, acquisitionAudit(records, transactionNow));
    const stable = structuredClone(persisted);
    await acquireInitialPending(secondStore, records.sourceId);
    assert.deepEqual(await realAcquisitionSnapshots(firstFirestore, records), stable);
  } finally {
    await deleteApp(firstApp);
    await deleteApp(secondApp);
  }
});

test("REAL-ACQ-MATCHING-AUDIT preserves its original timestamp while acquiring", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-real-acq-matching-audit" }, "p3-real-acq-matching-audit");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = acquisitionRecords();
    const existingAudit = acquisitionAudit(records, now - 1);
    await firestore.collection("provisioningOperations").doc(records.operation.operationId as string).set(records.operation);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    await firestore.collection("provisioningAudit").doc(records.auditId).set(existingAudit);
    await acquireInitialPending(store, records.sourceId);

    const persisted = await realAcquisitionSnapshots(firestore, records);
    const expected = expectedRealAcquisition(records, persisted.operation!.updatedAt as number);
    assert.deepEqual(persisted.operation, expected.operation);
    assert.deepEqual(persisted.source, expected.source);
    assert.deepEqual(persisted.next, expected.next);
    assert.deepEqual(persisted.audit, existingAudit);
  } finally {
    await deleteApp(app);
  }
});

test("REAL-ACQ-PROCESSED-REPLAY leaves every persisted acquisition record byte-identical", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-real-acq-processed-replay" }, "p3-real-acq-processed-replay");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = acquisitionRecords();
    await firestore.collection("provisioningOperations").doc(records.operation.operationId as string).set(records.operation);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    await acquireInitialPending(store, records.sourceId);
    const beforeReplay = await realAcquisitionSnapshots(firestore, records);
    await acquireInitialPending(store, records.sourceId);
    assert.deepEqual(await realAcquisitionSnapshots(firestore, records), beforeReplay);
  } finally {
    await deleteApp(app);
  }
});

test("REAL-ACQ-CODE6-ROLLBACK rejects four staged writes without prior audit read", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-real-acq-code6-rollback" }, "p3-real-acq-code6-rollback");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = acquisitionRecords();
    const conflictingAudit = { ...acquisitionAudit(records, now - 1), code: "internal" };
    await firestore.collection("provisioningOperations").doc(records.operation.operationId as string).set(records.operation);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    await firestore.collection("provisioningAudit").doc(records.auditId).set(conflictingAudit);
    const before = await realAcquisitionSnapshots(firestore, records);

    await assert.rejects(
      () => store.transaction(async (transaction) => {
        const source = await transaction.readDispatch(records.sourceId);
        const operationRecord = await transaction.readOperation(records.operation.operationId as string);
        assert.ok(source); assert.ok(operationRecord);
        const expected = expectedRealAcquisition(records, transaction.now);
        transaction.writeOperation(records.operation.operationId as string, expected.operation);
        transaction.writeDispatch(records.sourceId, expected.source);
        transaction.createDispatch(records.nextId, expected.next);
        transaction.createAudit(records.auditId, acquisitionAudit(records, transaction.now));
      }),
      (error: unknown) => {
        assert.equal((error as { code?: unknown }).code, 6, "expected Firestore ALREADY_EXISTS (code 6)");
        return true;
      },
    );

    assert.deepEqual(await realAcquisitionSnapshots(firestore, records), before);
    assert.equal((await firestore.collection("provisioningDispatch").doc(records.nextId).get()).exists, false);
  } finally {
    await deleteApp(app);
  }
});

interface TakeoverRecords {
  readonly operation: RecordValue;
  readonly source: RecordValue;
  readonly sourceId: string;
  readonly auditId: string;
}

function takeoverRecords(): TakeoverRecords {
  const source = activeDispatch(0, 1);
  const sourceId = source.dispatchId as string;
  const operation = {
    ...activeOperation(sourceId, 0, 1),
    ownerToken: deriveOwnerToken(sourceId, 0),
    leaseExpiresAt: now,
  };
  return {
    operation,
    source,
    sourceId,
    auditId: deriveAuditEventId(operationId, "progress", "state_transition", 0, 1),
  };
}

function takeoverAudit(records: TakeoverRecords, createdAt: number, operationRecord = records.operation): WorkerRecord {
  return {
    schemaVersion: 1,
    eventId: deriveAuditEventId(operationRecord.operationId as string, "progress", "state_transition", operationRecord.generation as number, operationRecord.version as number),
    operationId: operationRecord.operationId,
    correlationId: createHash("sha256").update(`provision-correlation:v1\0${operationRecord.operationId as string}`, "utf8").digest("hex"),
    category: "progress", stage: "state_transition", outcome: "started", code: "success",
    actorUidDigest: null, intendedUidDigest: null, dispatchId: records.sourceId,
    generation: operationRecord.generation, sourceVersion: operationRecord.version, createdAt,
  };
}

function seedTakeover(store: StrictWorkerStore, records: TakeoverRecords): void {
  store.operations.set(operationId, records.operation);
  store.dispatches.set(records.sourceId, records.source);
}

function expectedTakeover(records: TakeoverRecords, transactionNow: number, operationRecord = records.operation): RecordValue {
  const generation = (operationRecord.generation as number) + 1;
  return {
    ...operationRecord,
    generation,
    version: (operationRecord.version as number) + 1,
    ownerToken: deriveOwnerToken(records.sourceId, generation),
    leaseExpiresAt: transactionNow + 60_000,
    updatedAt: transactionNow,
  };
}

class RecordingAuthReader implements AuthReader {
  readonly calls: string[] = [];
  private readonly uidIdentity: AuthIdentity | null;
  private readonly emailIdentity: AuthIdentity | null;

  constructor(uidIdentity: AuthIdentity | null, emailIdentity: AuthIdentity | null) {
    this.uidIdentity = uidIdentity;
    this.emailIdentity = emailIdentity;
  }

  async readByUid(uid: string): Promise<AuthIdentity | null> {
    this.calls.push(`uid:${uid}`);
    return this.uidIdentity;
  }

  async readByEmail(email: string): Promise<AuthIdentity | null> {
    this.calls.push(`email:${email}`);
    return this.emailIdentity;
  }
}

function preflightRecords() {
  const active = operation(true);
  const source = dispatch(true);
  return { active, source, sourceId: source.dispatchId as string };
}

function seedPreflight(store: StrictWorkerStore, records: ReturnType<typeof preflightRecords>): void {
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
}

test("PF-RED reads both Auth indexes before any mutation and leaves absent identities for intent", async () => {
  const store = new StrictWorkerStore();
  const records = preflightRecords();
  seedPreflight(store, records);
  const before = strictStoreSnapshot(store);
  const auth = new RecordingAuthReader(null, null);

  await preflightAuth(store, auth, records.sourceId);

  assert.deepEqual(auth.calls, ["uid:uid-ana", "email:ana@example.com"]);
  assert.deepEqual(strictStoreSnapshot(store), before);
  assert.equal(store.calls.some((call) => call.startsWith("write") || call.startsWith("create")), false);
});

test("PF-RED classifies either pre-intent foreign Auth index as failed already-exists without Auth mutation", async () => {
  for (const [name, uidIdentity, emailIdentity] of [
    ["foreign uid", { uid: "foreign-uid", email: "ana@example.com" }, null],
    ["foreign email", null, { uid: "foreign-email-uid", email: "ana@example.com" }],
  ] as const) {
    const store = new StrictWorkerStore();
    const records = preflightRecords();
    seedPreflight(store, records);
    const auth = new RecordingAuthReader(uidIdentity, emailIdentity);

    await preflightAuth(store, auth, records.sourceId);

    assert.deepEqual(auth.calls, ["uid:uid-ana", "email:ana@example.com"], name);
    assert.deepEqual(store.operations.get(operationId), {
      ...records.active,
      status: "failed",
      phase: "terminal",
      version: 2,
      ownerToken: null,
      leaseExpiresAt: null,
      updatedAt: store.now,
    }, name);
    assert.deepEqual(store.dispatches.get(records.sourceId), records.source, name);
    assert.equal(store.calls.some((call) => call.startsWith("writeDispatch") || call.startsWith("create")), false, name);
  }
});

test("PF-RED fails closed on an Auth read error without operation or dispatch mutation", async () => {
  const store = new StrictWorkerStore();
  const records = preflightRecords();
  seedPreflight(store, records);
  const before = strictStoreSnapshot(store);
  const failure = new Error("Auth read failed");
  const auth: AuthReader = {
    async readByUid() { return null; },
    async readByEmail() { throw failure; },
  };

  await assert.rejects(() => preflightAuth(store, auth, records.sourceId), failure);
  assert.deepEqual(strictStoreSnapshot(store), before);
  assert.equal(store.calls.some((call) => call.startsWith("write") || call.startsWith("create")), false);
});

test("P3.44c RED routes an exact preflight dispatch through Auth reads and intent persistence", async () => {
  const store = new StrictWorkerStore();
  const records = preflightRecords();
  const auth = new RecordingAuthCreator(
    { kind: "definite_no_effect", code: "unused" },
    null,
    null,
  );
  seedPreflight(store, records);

  await createProvisioningWorkerRuntime({ store, auth }).handleTask({
    dispatchId: records.sourceId,
    retryCount: 0,
  });

  assert.deepEqual(auth.calls, ["uid:uid-ana", "email:ana@example.com"]);
  assert.equal(store.operations.get(operationId)?.phase, "auth_create");
  assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed");
});

test("P3.44c TRIANGULATE routes a task endpoint preflight dispatch through Firebase Auth", {
  skip: !process.env.FUNCTIONS_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST,
}, async () => {
  const projectId = functionsEmulatorProjectId();
  const app = initializeApp({ projectId }, "p3-worker-runtime-routing");
  try {
    const firestore = getFirestore(app);
    const records = preflightRecords();
    records.active.leaseExpiresAt = Date.now() + 60_000;
    await firestore.collection("provisioningOperations").doc(operationId).set(records.active);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    const queueName = `projects/${projectId}/locations/us-central1/queues/provisioning-dispatch`;
    const response = await fetch(
      taskEndpointUrl(projectId),
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CloudTasks-QueueName": queueName,
          "X-CloudTasks-TaskName": `${queueName}/tasks/${records.sourceId}`,
          "X-CloudTasks-TaskRetryCount": "0",
          "X-CloudTasks-TaskExecutionCount": "1",
          "X-CloudTasks-TaskETA": "2026-01-01T00:00:00.000Z",
        },
        body: JSON.stringify({ data: { dispatchId: records.sourceId } }),
      },
    );
    assert.equal(response.status, 204);
    assert.equal((await firestore.collection("provisioningOperations").doc(operationId).get()).data()?.phase, "auth_create");
    assert.equal((await firestore.collection("provisioningDispatch").doc(records.sourceId).get()).data()?.workerAck, "processed");
    await firestore.collection("provisioningOperations").doc(operationId).delete();
    await firestore.collection("provisioningDispatch").doc(records.sourceId).delete();
  } finally {
    await deleteApp(app);
  }
});

test("TK-OK atomically takes over an expired current source without acknowledging or advancing it", async () => {
  const store = new StrictWorkerStore(); const records = takeoverRecords(); seedTakeover(store, records);
  const sourceBefore = structuredClone(records.source);
  const result = await takeoverExpiredCurrent(store, records.sourceId);
  assert.deepEqual(store.calls.slice(0, 3), [`readDispatch:${records.sourceId}`, `readOperation:${operationId}`, `readAudit:${records.auditId}`]);
  assert.deepEqual(store.operations.get(operationId), expectedTakeover(records, store.now));
  assert.deepEqual(store.dispatches.get(records.sourceId), sourceBefore);
  assert.deepEqual(store.audits.get(records.auditId), takeoverAudit(records, store.now));
  assert.deepEqual(result, { takeoverCommitted: true });
  assert.equal(store.calls.some((call) => call.startsWith("createDispatch")), false);
});

test("TK-FENCE rejects untrusted or live sources without audit or operation writes", async () => {
  const cases: readonly [string, (records: TakeoverRecords) => void][] = [
    ["acknowledged source", (records) => { records.source.workerAck = "processed"; records.source.workerAckAt = now; }],
    ["source identity drift", (records) => { records.source.taskId = "f".repeat(64); }],
    ["source owner-seed drift", (records) => { records.source.ownerSeed = "f".repeat(64); }],
    ["source no longer current", (records) => { records.operation.currentDispatchId = "f".repeat(64); }],
    ["source boundary drift", (records) => { records.source.boundary = "auth_create"; }],
    ["live operation lease", (records) => { records.operation.leaseExpiresAt = now + 1_001; }],
  ];
  for (const [name, mutate] of cases) {
    const store = new StrictWorkerStore(); const records = takeoverRecords(); mutate(records); seedTakeover(store, records);
    const before = strictStoreSnapshot(store);
    assert.equal(await takeoverExpiredCurrent(store, records.sourceId), null, name);
    assertUnchanged(store, before, name);
  }
});

test("TK-REPEAT derives the next generation and audit identity from the latest retained-source operation", async () => {
  const store = new StrictWorkerStore(); const records = takeoverRecords(); seedTakeover(store, records);
  await takeoverExpiredCurrent(store, records.sourceId);
  const first = store.operations.get(operationId)!;
  const firstAuditId = records.auditId;
  store.now += 60_001;
  const expired = { ...first, leaseExpiresAt: store.now };
  store.operations.set(operationId, expired);
  const result = await takeoverExpiredCurrent(store, records.sourceId);
  const expected = expectedTakeover(records, store.now, expired);
  const secondAuditId = deriveAuditEventId(operationId, "progress", "state_transition", 1, 2);
  assert.deepEqual(result, { takeoverCommitted: true });
  assert.deepEqual(store.operations.get(operationId), expected);
  assert.deepEqual(store.dispatches.get(records.sourceId), records.source);
  assert.notEqual(secondAuditId, firstAuditId);
  assert.deepEqual(store.audits.get(secondAuditId), takeoverAudit(records, store.now, expired));
});

test("TK-ROLLBACK preserves source and operation bytes when the takeover audit conflicts", async () => {
  const store = new StrictWorkerStore(); const records = takeoverRecords(); seedTakeover(store, records);
  store.audits.set(records.auditId, { ...takeoverAudit(records, now - 1), code: "internal" });
  const before = strictStoreSnapshot(store);
  await assert.rejects(() => takeoverExpiredCurrent(store, records.sourceId), /audit identity mismatch/);
  assert.deepEqual(strictStoreSnapshot(store), before);
});

test("REAL-TK-ONE-WINNER preserves a matching replay timestamp and source bytes", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-real-ordinary-takeover" }, "p3-real-ordinary-takeover");
  try {
    const firestore = getFirestore(app); const store = new FirestoreWorkerStore(firestore); const records = takeoverRecords();
    await firestore.collection("provisioningOperations").doc(operationId).set(records.operation);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    await Promise.all([takeoverExpiredCurrent(store, records.sourceId), takeoverExpiredCurrent(store, records.sourceId)]);
    const operationAfter = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
    const sourceAfter = await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data());
    const auditAfter = await firestore.collection("provisioningAudit").doc(records.auditId).get().then((snapshot) => snapshot.data());
    assert.equal(operationAfter?.generation, 1); assert.equal(operationAfter?.version, 2);
    assert.deepEqual(sourceAfter, records.source); assert.equal(auditAfter?.eventId, records.auditId);
    const stableAudit = structuredClone(auditAfter);
    await takeoverExpiredCurrent(store, records.sourceId);
    assert.deepEqual(await firestore.collection("provisioningAudit").doc(records.auditId).get().then((snapshot) => snapshot.data()), stableAudit);
  } finally { await deleteApp(app); }
});

test("REAL-TK-MATCHING-AUDIT preserves first-insert timestamp and conflict rolls back", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-real-ordinary-takeover-audit" }, "p3-real-ordinary-takeover-audit");
  try {
    const firestore = getFirestore(app); const store = new FirestoreWorkerStore(firestore); const records = takeoverRecords();
    const matching = takeoverAudit(records, now - 1);
    await firestore.collection("provisioningOperations").doc(operationId).set(records.operation);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    await firestore.collection("provisioningAudit").doc(records.auditId).set(matching);
    await takeoverExpiredCurrent(store, records.sourceId);
    assert.deepEqual(await firestore.collection("provisioningAudit").doc(records.auditId).get().then((snapshot) => snapshot.data()), matching);

    const conflictApp = initializeApp({ projectId: "p3-real-ordinary-takeover-conflict" }, "p3-real-ordinary-takeover-conflict");
    try {
      const conflictFirestore = getFirestore(conflictApp); const conflictStore = new FirestoreWorkerStore(conflictFirestore); const conflict = takeoverRecords();
      await conflictFirestore.collection("provisioningOperations").doc(operationId).set(conflict.operation);
      await conflictFirestore.collection("provisioningDispatch").doc(conflict.sourceId).set(conflict.source);
      await conflictFirestore.collection("provisioningAudit").doc(conflict.auditId).set({ ...takeoverAudit(conflict, now - 1), code: "internal" });
      const operationBefore = await conflictFirestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
      const sourceBefore = await conflictFirestore.collection("provisioningDispatch").doc(conflict.sourceId).get().then((snapshot) => snapshot.data());
      const auditBefore = await conflictFirestore.collection("provisioningAudit").doc(conflict.auditId).get().then((snapshot) => snapshot.data());
      await assert.rejects(() => takeoverExpiredCurrent(conflictStore, conflict.sourceId), /audit identity mismatch/);
      assert.deepEqual(await conflictFirestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data()), operationBefore);
      assert.deepEqual(await conflictFirestore.collection("provisioningDispatch").doc(conflict.sourceId).get().then((snapshot) => snapshot.data()), sourceBefore);
      assert.deepEqual(await conflictFirestore.collection("provisioningAudit").doc(conflict.auditId).get().then((snapshot) => snapshot.data()), auditBefore);
    } finally { await deleteApp(conflictApp); }
  } finally { await deleteApp(app); }
});

function intentRecords() {
  const active = operation(true);
  const source = dispatch(true);
  const sourceId = source.dispatchId as string;
  const nextId = deriveDispatchId(operationId, "auth_create", 0, 2);
  const auditId = deriveAuditEventId(operationId, "progress", "auth_intent", 0, 1);
  return { active, source, sourceId, nextId, auditId };
}

function intentAudit(records: ReturnType<typeof intentRecords>, createdAt: number): WorkerRecord {
  return {
    schemaVersion: 1, eventId: records.auditId, operationId,
    correlationId: createHash("sha256").update(`provision-correlation:v1\0${operationId}`, "utf8").digest("hex"),
    category: "progress", stage: "auth_intent", outcome: "started", code: "auth-intent",
    actorUidDigest: null, intendedUidDigest: null, dispatchId: records.sourceId,
    generation: 0, sourceVersion: 1, createdAt,
  };
}

test("INTENT-RED atomically persists the Auth intent, audit, next dispatch, and source acknowledgement", async () => {
  const store = new StrictWorkerStore();
  const records = intentRecords();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);

  await persistAuthIntent(store, records.sourceId);

  assert.deepEqual(store.calls.slice(0, 4), [
    `readDispatch:${records.sourceId}`, `readOperation:${operationId}`,
    `readAudit:${records.auditId}`, `readDispatch:${records.nextId}`,
  ]);
  assert.deepEqual(store.operations.get(operationId), {
    ...records.active, phase: "auth_create", version: 2, currentDispatchId: records.nextId,
    authAttempted: true,
    authAttempt: {
      attemptId: records.nextId, intentAt: store.now, callStartedAt: null, result: "intent",
      returnedUid: null, returnedEmail: null, proof: null,
    },
    updatedAt: store.now,
  });
  assert.deepEqual(store.dispatches.get(records.sourceId), {
    ...records.source, workerAck: "processed", workerAckAt: store.now,
  });
  assert.deepEqual(store.dispatches.get(records.nextId), {
    schemaVersion: 1, dispatchId: records.nextId, taskId: records.nextId,
    operationId, fingerprint, boundary: "auth_create", generation: 0, sourceVersion: 2,
    ownerSeed: deriveOwnerToken(records.nextId, 0), enqueued: false, enqueuedAt: null,
    enqueueSource: null, enqueueEventId: null, workerAck: null, workerAckAt: null, createdAt: store.now,
  });
  assert.deepEqual(store.audits.get(records.auditId), intentAudit(records, store.now));
});

test("INTENT-RED fails closed on source/current fences and rolls back audit or dispatch conflicts", async () => {
  const cases: readonly [string, (records: ReturnType<typeof intentRecords>, store: StrictWorkerStore) => void, boolean][] = [
    ["source boundary", (records) => { records.source.boundary = "auth_create"; }, false],
    ["source version", (records) => { records.source.sourceVersion = 2; }, false],
    ["source fingerprint", (records) => { records.source.fingerprint = otherFingerprint; }, false],
    ["current dispatch", (records) => { records.active.currentDispatchId = "f".repeat(64); }, false],
    ["audit conflict", (records, store) => { store.audits.set(records.auditId, { ...intentAudit(records, now), code: "internal" }); }, true],
    ["next dispatch conflict", (records, store) => { store.dispatches.set(records.nextId, { ...records.source, dispatchId: records.nextId, taskId: records.nextId, boundary: "auth_create", sourceVersion: 2 }); }, true],
  ];
  for (const [name, arrange, rejects] of cases) {
    const store = new StrictWorkerStore();
    const records = intentRecords();
    arrange(records, store);
    store.operations.set(operationId, records.active);
    store.dispatches.set(records.sourceId, records.source);
    const before = strictStoreSnapshot(store);
    if (rejects) await assert.rejects(() => persistAuthIntent(store, records.sourceId), /audit identity mismatch|next dispatch conflict/, name);
    else await persistAuthIntent(store, records.sourceId);
    assert.deepEqual(strictStoreSnapshot(store), before, name);
  }
});

test("INTENT-TRIANGULATE preserves a matching audit timestamp and makes processed replay a no-op", async () => {
  const store = new StrictWorkerStore();
  const records = intentRecords();
  const matchingAudit = intentAudit(records, now - 1);
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  store.audits.set(records.auditId, matchingAudit);

  await persistAuthIntent(store, records.sourceId);

  assert.equal(store.audits.get(records.auditId), matchingAudit);
  const beforeReplay = strictStoreSnapshot(store);
  await persistAuthIntent(store, records.sourceId);
  assert.deepEqual(strictStoreSnapshot(store), beforeReplay);
});

test("REAL-INTENT atomically commits one persisted Auth intent transaction", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-real-auth-intent" }, "p3-real-auth-intent");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = intentRecords();
    records.active.leaseExpiresAt = Date.now() + 60_000;
    await firestore.collection("provisioningOperations").doc(operationId).set(records.active);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);

    await persistAuthIntent(store, records.sourceId);

    const operationAfter = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
    const sourceAfter = await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data());
    const nextAfter = await firestore.collection("provisioningDispatch").doc(records.nextId).get().then((snapshot) => snapshot.data());
    const auditAfter = await firestore.collection("provisioningAudit").doc(records.auditId).get().then((snapshot) => snapshot.data());
    const transactionNow = operationAfter!.updatedAt as number;
    assert.deepEqual(operationAfter, {
      ...records.active, phase: "auth_create", version: 2, currentDispatchId: records.nextId,
      authAttempted: true,
      authAttempt: {
        attemptId: records.nextId, intentAt: transactionNow, callStartedAt: null, result: "intent",
        returnedUid: null, returnedEmail: null, proof: null,
      },
      updatedAt: transactionNow,
    });
    assert.deepEqual(sourceAfter, { ...records.source, workerAck: "processed", workerAckAt: transactionNow });
    assert.deepEqual(nextAfter, {
      schemaVersion: 1, dispatchId: records.nextId, taskId: records.nextId,
      operationId, fingerprint, boundary: "auth_create", generation: 0, sourceVersion: 2,
      ownerSeed: deriveOwnerToken(records.nextId, 0), enqueued: false, enqueuedAt: null,
      enqueueSource: null, enqueueEventId: null, workerAck: null, workerAckAt: null, createdAt: transactionNow,
    });
    assert.deepEqual(auditAfter, intentAudit(records, transactionNow));
  } finally {
    await deleteApp(app);
  }
});


class RecordingAuthCreator implements AuthCreator, AuthReader {
  readonly calls: string[] = [];
  private readonly outcome: AuthCreateOutcome;
  private readonly uidIdentity: AuthIdentity | null;
  private readonly emailIdentity: AuthIdentity | null;

  constructor(
    outcome: AuthCreateOutcome,
    uidIdentity: AuthIdentity | null,
    emailIdentity: AuthIdentity | null,
  ) {
    this.outcome = outcome;
    this.uidIdentity = uidIdentity;
    this.emailIdentity = emailIdentity;
  }

  async createUser(uid: string, email: string): Promise<AuthCreateOutcome> {
    this.calls.push(`create:${uid}:${email}`);
    return this.outcome;
  }

  async readByUid(uid: string): Promise<AuthIdentity | null> {
    this.calls.push(`uid:${uid}`);
    return this.uidIdentity;
  }

  async readByEmail(email: string): Promise<AuthIdentity | null> {
    this.calls.push(`email:${email}`);
    return this.emailIdentity;
  }
}

function authCreateRecords(callStarted = false) {
  const sourceId = deriveDispatchId(operationId, "auth_create", 0, 2);
  const source = activeDispatch(0, 2, "auth_create");
  const active = {
    ...operation(true), phase: "auth_create", version: 2, currentDispatchId: sourceId,
    authAttempted: true,
    authAttempt: {
      attemptId: sourceId, intentAt: now, callStartedAt: callStarted ? now + 1 : null,
      result: callStarted ? "call_started" : "intent", returnedUid: null, returnedEmail: null, proof: null,
    },
  };
  return {
    active, source, sourceId,
    profileDispatchId: deriveDispatchId(operationId, "profile_commit", 0, 4),
    preflightDispatchId: deriveDispatchId(operationId, "auth_preflight", 0, 4),
  };
}

test("AUTH-CREATE-RED persists call_started before one create, verifies both indexes, and commits proof", async () => {
  const store = new StrictWorkerStore();
  const records = authCreateRecords();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  const auth = new RecordingAuthCreator(
    { kind: "created", identity: { uid: "uid-ana", email: "ana@example.com" } },
    { uid: "uid-ana", email: "ana@example.com" },
    { uid: "uid-ana", email: "ana@example.com" },
  );

  await createAuthUser(store, auth, records.sourceId);

  assert.deepEqual(auth.calls, ["create:uid-ana:ana@example.com", "uid:uid-ana", "email:ana@example.com"]);
  assert.deepEqual(store.operations.get(operationId), {
    ...records.active, phase: "profile_commit", version: 4, currentDispatchId: records.profileDispatchId,
    authAttempt: {
      ...records.active.authAttempt as RecordValue, callStartedAt: store.now, result: "confirmed",
      returnedUid: "uid-ana", returnedEmail: "ana@example.com",
      proof: { attemptId: records.sourceId, confirmedAt: store.now, uidRead: "uid-ana", emailRead: "ana@example.com" },
    },
    updatedAt: store.now,
  });
  assert.deepEqual(store.dispatches.get(records.sourceId), { ...records.source, workerAck: "processed", workerAckAt: store.now });
  assert.equal(store.dispatches.get(records.profileDispatchId)?.boundary, "profile_commit");
  assert.equal(store.audits.size, 1);
});

test("AUTH-CREATE-RED never repeats a persisted call_started attempt and routes it to manual recovery", async () => {
  const store = new StrictWorkerStore();
  const records = authCreateRecords(true);
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  const auth = new RecordingAuthCreator(
    { kind: "created", identity: { uid: "uid-ana", email: "ana@example.com" } },
    { uid: "uid-ana", email: "ana@example.com" },
    { uid: "uid-ana", email: "ana@example.com" },
  );

  await createAuthUser(store, auth, records.sourceId);

  assert.deepEqual(auth.calls, ["uid:uid-ana", "email:ana@example.com"]);
  assert.equal(store.operations.get(operationId)?.status, "manual_recovery");
  assert.equal((store.operations.get(operationId)?.authAttempt as RecordValue).result, "ambiguous");
  assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed");
});

test("AUTH-CREATE-RED returns only definite no-effect outcomes to auth_preflight", async () => {
  const store = new StrictWorkerStore();
  const records = authCreateRecords();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  const auth = new RecordingAuthCreator({ kind: "definite_no_effect", code: "invalid-argument" }, null, null);

  await createAuthUser(store, auth, records.sourceId);

  assert.deepEqual(auth.calls, ["create:uid-ana:ana@example.com"]);
  assert.equal(store.operations.get(operationId)?.phase, "auth_preflight");
  assert.equal((store.operations.get(operationId)?.authAttempt as RecordValue).result, "definite_no_effect");
  assert.equal(store.operations.get(operationId)?.currentDispatchId, records.preflightDispatchId);
  assert.equal(store.dispatches.get(records.preflightDispatchId)?.boundary, "auth_preflight");
});

test("AUTH-CREATE-RED treats malformed returns and mismatched reads as ambiguity without deletion", async () => {
  const store = new StrictWorkerStore();
  const records = authCreateRecords();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  const auth = new RecordingAuthCreator(
    { kind: "created", identity: { uid: "wrong-uid", email: "ana@example.com" } },
    { uid: "uid-ana", email: "ana@example.com" },
    { uid: "uid-ana", email: "ana@example.com" },
  );

  await createAuthUser(store, auth, records.sourceId);

  assert.deepEqual(auth.calls, ["create:uid-ana:ana@example.com", "uid:uid-ana", "email:ana@example.com"]);
  assert.equal(store.operations.get(operationId)?.status, "manual_recovery");
  assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed");
});

test("AUTH-CREATE-RED routes null and invalid runtime output to manual recovery without throwing", async () => {
  for (const [name, outcome] of [
    ["null", null],
    ["invalid identity", { kind: "created", identity: null }],
    ["unknown kind", { kind: "unknown" }],
  ] as const) {
    const store = new StrictWorkerStore();
    const records = authCreateRecords();
    store.operations.set(operationId, records.active);
    store.dispatches.set(records.sourceId, records.source);
    const auth = new RecordingAuthCreator(
      outcome as unknown as AuthCreateOutcome,
      null,
      null,
    );

    await createAuthUser(store, auth, records.sourceId);

    assert.deepEqual(auth.calls, ["create:uid-ana:ana@example.com"], name);
    assert.equal(store.operations.get(operationId)?.status, "manual_recovery", name);
    assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed", name);
  }
});


test("AUTH-CREATE-TRIANGULATE treats a thrown timeout as ambiguous without a second create", async () => {
  const store = new StrictWorkerStore();
  const records = authCreateRecords();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  const calls: string[] = [];
  const auth: AuthCreator & AuthReader = {
    async createUser() { calls.push("create"); throw new Error("timeout"); },
    async readByUid() { calls.push("uid"); return null; },
    async readByEmail() { calls.push("email"); return null; },
  };

  await createAuthUser(store, auth, records.sourceId);

  assert.deepEqual(calls, ["create"]);
  assert.equal(store.operations.get(operationId)?.status, "manual_recovery");
  assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed");
});

function profileCommitRecords() {
  const sourceId = deriveDispatchId(operationId, "profile_commit", 0, 4);
  return {
    sourceId,
    source: activeDispatch(0, 4, "profile_commit"),
    active: {
      ...operation(true), phase: "profile_commit", version: 4, currentDispatchId: sourceId, authAttempted: true,
      authAttempt: {
        attemptId: deriveDispatchId(operationId, "auth_create", 0, 2), intentAt: now - 2, callStartedAt: now - 1,
        result: "confirmed", returnedUid: "uid-ana", returnedEmail: "ana@example.com",
        proof: { attemptId: deriveDispatchId(operationId, "auth_create", 0, 2), confirmedAt: now, uidRead: "uid-ana", emailRead: "ana@example.com" },
      },
    },
  };
}

function completedProfile(): WorkerRecord {
  return {
    ...payload, displayName: "Ana García", userId: "uid-ana", provisioningOperationId: operationId,
    provisioningFingerprint: fingerprint, provisioningSchemaVersion: 1, provisionedBy: "trusted-backend", provisionedAt: now,
  };
}

function profileAudit(sourceId: string, createdAt: number): WorkerRecord {
  return {
    schemaVersion: 1, eventId: deriveAuditEventId(operationId, "success", "terminal_success", 0, 4), operationId,
    correlationId: createHash("sha256").update(`provision-correlation:v1\0${operationId}`, "utf8").digest("hex"),
    category: "success", stage: "terminal_success", outcome: "completed", code: "success", actorUidDigest: null,
    intendedUidDigest: null, dispatchId: sourceId, generation: 0, sourceVersion: 4, createdAt,
  };
}

function matchingAuth(): RecordingAuthReader {
  return new RecordingAuthReader({ uid: "uid-ana", email: "ana@example.com" }, { uid: "uid-ana", email: "ana@example.com" });
}

test("PROFILE-COMMIT-RED derives profile display names and rejects incomplete persisted Auth correlation", async () => {
  const source = await readFile(new URL("../../src/provisioning/worker.ts", import.meta.url), "utf8");
  const profileCommitSource = source.slice(source.indexOf("export async function completeProfileCommit"));
  assert.match(profileCommitSource, /deriveDisplayName\(/, "profile commit must delegate display-name derivation");
  assert.match(profileCommitSource, /hasCompletePersistedAuthCorrelation\(/, "profile commit must explicitly require persisted Auth correlation");

  const mutations: readonly [string, (attempt: RecordValue) => void][] = [
    ["non-confirmed result", (attempt) => { attempt.result = "call_started"; }],
    ["missing proof", (attempt) => { attempt.proof = null; }],
    ["proof attempt mismatch", (attempt) => { (attempt.proof as RecordValue).attemptId = "f".repeat(64); }],
    ["returned UID mismatch", (attempt) => { attempt.returnedUid = "other-uid"; }],
    ["proof UID mismatch", (attempt) => { (attempt.proof as RecordValue).uidRead = "other-uid"; }],
    ["returned email mismatch", (attempt) => { attempt.returnedEmail = "other@example.com"; }],
    ["proof email mismatch", (attempt) => { (attempt.proof as RecordValue).emailRead = "other@example.com"; }],
  ];
  for (const [name, mutate] of mutations) {
    const store = new StrictWorkerStore();
    const records = profileCommitRecords();
    mutate(records.active.authAttempt as RecordValue);
    store.operations.set(operationId, records.active);
    store.dispatches.set(records.sourceId, records.source);
    const before = strictStoreSnapshot(store);

    await completeProfileCommit(store, matchingAuth(), records.sourceId);

    assert.deepEqual(strictStoreSnapshot(store), before, name);
  }
});

test("PROFILE-COMMIT-RED atomically writes provenance, completion, success audit, and source acknowledgement", async () => {
  const store = new StrictWorkerStore(); const records = profileCommitRecords(); const auth = matchingAuth();
  store.operations.set(operationId, records.active); store.dispatches.set(records.sourceId, records.source);
  await completeProfileCommit(store, auth, records.sourceId);
  assert.deepEqual(auth.calls, ["uid:uid-ana", "email:ana@example.com"]);
  assert.deepEqual(store.operations.get(operationId), { ...records.active, status: "completed", phase: "terminal", version: 5, ownerToken: null, leaseExpiresAt: null, currentDispatchId: records.sourceId, updatedAt: store.now });
  assert.deepEqual(store.dispatches.get(records.sourceId), { ...records.source, workerAck: "processed", workerAckAt: store.now });
  assert.deepEqual(store.profiles.get("uid-ana"), { ...completedProfile(), provisionedAt: store.now });
  assert.deepEqual(store.audits.get(profileAudit(records.sourceId, store.now).eventId as string), profileAudit(records.sourceId, store.now));
});

test("PROFILE-COMMIT-RED preserves a matching profile and completed replay while failures roll back", async () => {
  const store = new StrictWorkerStore(); const records = profileCommitRecords(); const existing = completedProfile();
  store.operations.set(operationId, records.active); store.dispatches.set(records.sourceId, records.source); store.profiles.set("uid-ana", existing);
  await completeProfileCommit(store, matchingAuth(), records.sourceId);
  assert.equal(store.profiles.get("uid-ana"), existing);
  const replay = strictStoreSnapshot(store); await completeProfileCommit(store, matchingAuth(), records.sourceId); assert.deepEqual(strictStoreSnapshot(store), replay);
  const failing = new StrictWorkerStore(); const failureRecords = profileCommitRecords(); failing.failAuditCreate = true;
  failing.operations.set(operationId, failureRecords.active); failing.dispatches.set(failureRecords.sourceId, failureRecords.source);
  const before = strictStoreSnapshot(failing);
  await assert.rejects(() => completeProfileCommit(failing, matchingAuth(), failureRecords.sourceId), /audit create conflict/);
  assert.deepEqual(strictStoreSnapshot(failing), before);
});

function profileConflictAudit(sourceId: string, createdAt: number): WorkerRecord {
  return {
    schemaVersion: 1,
    eventId: deriveAuditEventId(operationId, "failure", "terminal_failure", 0, 4),
    operationId,
    correlationId: createHash("sha256").update(`provision-correlation:v1\0${operationId}`, "utf8").digest("hex"),
    category: "failure",
    stage: "terminal_failure",
    outcome: "failed",
    code: "manual-recovery",
    actorUidDigest: null,
    intendedUidDigest: null,
    dispatchId: sourceId,
    generation: 0,
    sourceVersion: 4,
    createdAt,
  };
}

test("PROFILE-CONFLICT-RED atomically routes a conflicting profile to manual recovery with its exact audit", async () => {
  const store = new StrictWorkerStore();
  const records = profileCommitRecords();
  const conflict = { ...completedProfile(), provisioningOperationId: otherOperationId };
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  store.profiles.set("uid-ana", conflict);

  await completeProfileCommit(store, matchingAuth(), records.sourceId);

  assert.deepEqual(store.operations.get(operationId), {
    ...records.active,
    status: "manual_recovery",
    phase: "terminal",
    version: 5,
    ownerToken: null,
    leaseExpiresAt: null,
    updatedAt: store.now,
  });
  assert.deepEqual(store.dispatches.get(records.sourceId), {
    ...records.source,
    workerAck: "processed",
    workerAckAt: store.now,
  });
  assert.equal(store.profiles.get("uid-ana"), conflict, "conflicting profile is never overwritten or deleted");
  assert.deepEqual(store.audits.get(profileConflictAudit(records.sourceId, store.now).eventId as string), profileConflictAudit(records.sourceId, store.now));
});

test("PROFILE-CONFLICT-TRIANGULATE preserves matching audit time, replay bytes, and rollback on audit identity drift", async () => {
  const records = profileCommitRecords();
  const conflict = { ...completedProfile(), provisioningOperationId: otherOperationId };
  const audit = profileConflictAudit(records.sourceId, now - 1);
  const matching = new StrictWorkerStore();
  matching.operations.set(operationId, records.active);
  matching.dispatches.set(records.sourceId, records.source);
  matching.profiles.set("uid-ana", conflict);
  matching.audits.set(audit.eventId as string, audit);

  await completeProfileCommit(matching, matchingAuth(), records.sourceId);

  assert.equal(matching.audits.get(audit.eventId as string), audit, "matching audit keeps first-insert timestamp");
  const replay = strictStoreSnapshot(matching);
  await completeProfileCommit(matching, matchingAuth(), records.sourceId);
  assert.deepEqual(strictStoreSnapshot(matching), replay, "processed conflict replay is a no-op");

  const mismatched = new StrictWorkerStore();
  const mismatchRecords = profileCommitRecords();
  mismatched.operations.set(operationId, mismatchRecords.active);
  mismatched.dispatches.set(mismatchRecords.sourceId, mismatchRecords.source);
  mismatched.profiles.set("uid-ana", conflict);
  mismatched.audits.set(
    profileConflictAudit(mismatchRecords.sourceId, now).eventId as string,
    { ...profileConflictAudit(mismatchRecords.sourceId, now), code: "internal" },
  );
  const before = strictStoreSnapshot(mismatched);

  await assert.rejects(
    () => completeProfileCommit(mismatched, matchingAuth(), mismatchRecords.sourceId),
    /audit identity mismatch/,
  );
  assert.deepEqual(strictStoreSnapshot(mismatched), before, "audit conflict rolls back every profile-conflict write");
});

test("REAL-PROFILE-CONFLICT-RED atomically persists manual recovery without deleting the conflicting Firestore profile", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-real-profile-conflict" }, "p3-real-profile-conflict");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = profileCommitRecords();
    const conflict = { ...completedProfile(), provisioningOperationId: otherOperationId };
    (records.active as RecordValue).leaseExpiresAt = Date.now() + 60_000;
    await firestore.collection("provisioningOperations").doc(operationId).set(records.active);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    await firestore.collection("users").doc("uid-ana").set(conflict);

    await completeProfileCommit(store, matchingAuth(), records.sourceId);

    const operationAfter = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
    const dispatchAfter = await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data());
    const auditAfter = await firestore.collection("provisioningAudit").doc(profileConflictAudit(records.sourceId, 0).eventId as string).get().then((snapshot) => snapshot.data());
    assert.equal(operationAfter?.status, "manual_recovery");
    assert.equal(operationAfter?.phase, "terminal");
    assert.equal(dispatchAfter?.workerAck, "processed");
    assert.deepEqual(await firestore.collection("users").doc("uid-ana").get().then((snapshot) => snapshot.data()), conflict);
    assert.deepEqual(auditAfter, profileConflictAudit(records.sourceId, operationAfter!.updatedAt as number));
  } finally {
    await deleteApp(app);
  }
});

test("REAL-PROFILE-COMMIT commits the Auth-checked completion through Firestore", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-real-profile-commit" }, "p3-real-profile-commit");
  try {
    const firestore = getFirestore(app); const store = new FirestoreWorkerStore(firestore); const records = profileCommitRecords();
    (records.active as RecordValue).leaseExpiresAt = Date.now() + 60_000;
    await firestore.collection("provisioningOperations").doc(operationId).set(records.active);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    await completeProfileCommit(store, matchingAuth(), records.sourceId);
    assert.equal((await firestore.collection("provisioningOperations").doc(operationId).get()).data()?.status, "completed");
    assert.equal((await firestore.collection("provisioningDispatch").doc(records.sourceId).get()).data()?.workerAck, "processed");
    assert.equal((await firestore.collection("users").doc("uid-ana").get()).data()?.provisioningOperationId, operationId);
  } finally { await deleteApp(app); }
});

test("AUTH-CRASH-RED reconstructs call_started with both Auth indexes before manual recovery", async () => {
  const store = new StrictWorkerStore();
  const records = authCreateRecords(true);
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  const auth = new RecordingAuthCreator(
    { kind: "created", identity: { uid: "uid-ana", email: "ana@example.com" } },
    { uid: "uid-ana", email: "ana@example.com" },
    { uid: "uid-ana", email: "ana@example.com" },
  );

  await createAuthUser(store, auth, records.sourceId);

  assert.deepEqual(auth.calls, ["uid:uid-ana", "email:ana@example.com"]);
  assert.equal(store.operations.get(operationId)?.status, "manual_recovery");
  assert.equal((store.operations.get(operationId)?.authAttempt as RecordValue).result, "ambiguous");
  assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed");
});

test("AUTH-PROOF-COMMIT-RED reconstructs after an Auth proof transaction crash without a second create", async () => {
  const store = new StrictWorkerStore();
  const records = authCreateRecords();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  store.failAuditCreate = true;
  const auth = new RecordingAuthCreator(
    { kind: "created", identity: { uid: "uid-ana", email: "ana@example.com" } },
    { uid: "uid-ana", email: "ana@example.com" },
    { uid: "uid-ana", email: "ana@example.com" },
  );

  await assert.rejects(() => createAuthUser(store, auth, records.sourceId), /audit create conflict/);
  assert.equal((store.operations.get(operationId)?.authAttempt as RecordValue).result, "call_started");
  store.failAuditCreate = false;
  auth.calls.length = 0;

  await createAuthUser(store, auth, records.sourceId);

  assert.deepEqual(auth.calls, ["uid:uid-ana", "email:ana@example.com"]);
  assert.equal(store.operations.get(operationId)?.status, "manual_recovery");
  assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed");
});

test("AUTH-READ-TRIANGULATE records an ambiguous result when either reconstruction read fails", async () => {
  for (const [name, uidIdentity, emailIdentity] of [
    ["uid missing", null, { uid: "uid-ana", email: "ana@example.com" }],
    ["email missing", { uid: "uid-ana", email: "ana@example.com" }, null],
  ] as const) {
    const store = new StrictWorkerStore();
    const records = authCreateRecords();
    store.operations.set(operationId, records.active);
    store.dispatches.set(records.sourceId, records.source);
    const auth = new RecordingAuthCreator(
      { kind: "created", identity: { uid: "uid-ana", email: "ana@example.com" } },
      uidIdentity,
      emailIdentity,
    );

    await createAuthUser(store, auth, records.sourceId);

    assert.deepEqual(auth.calls, ["create:uid-ana:ana@example.com", "uid:uid-ana", "email:ana@example.com"], name);
    assert.equal(store.operations.get(operationId)?.status, "manual_recovery", name);
    assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed", name);
  }
});

test("PROFILE-COMMIT-TRIANGULATE retries a crashed completion commit without rewriting the profile", async () => {
  const store = new StrictWorkerStore();
  const records = profileCommitRecords();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  store.failAuditCreate = true;
  const before = strictStoreSnapshot(store);

  await assert.rejects(() => completeProfileCommit(store, matchingAuth(), records.sourceId), /audit create conflict/);
  assert.deepEqual(strictStoreSnapshot(store), before);
  store.failAuditCreate = false;

  await completeProfileCommit(store, matchingAuth(), records.sourceId);

  assert.equal(store.operations.get(operationId)?.status, "completed");
  assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed");
  assert.deepEqual(store.profiles.get("uid-ana"), { ...completedProfile(), provisionedAt: store.now });
});

test("P3.15a before Auth intent commit rolls back, then committed intent replay is byte-stable", async () => {
  const store = new StrictWorkerStore();
  const records = intentRecords();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  store.failAuditCreate = true;
  const beforeIntentCommit = strictStoreSnapshot(store);

  await assert.rejects(() => persistAuthIntent(store, records.sourceId), /audit create conflict/);
  assert.deepEqual(strictStoreSnapshot(store), beforeIntentCommit, "before Auth intent commit rolls back every write");
  store.failAuditCreate = false;

  await persistAuthIntent(store, records.sourceId);
  const afterCommittedIntent = strictStoreSnapshot(store);
  await persistAuthIntent(store, records.sourceId);
  assert.deepEqual(strictStoreSnapshot(store), afterCommittedIntent, "after committed Auth intent replay is a no-op");
});

test("P3.15a after persisted call_started before Auth call preserves matching identities as manual recovery", async () => {
  const store = new StrictWorkerStore();
  const records = authCreateRecords(true);
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  const auth = new RecordingAuthCreator(
    { kind: "created", identity: { uid: "uid-ana", email: "ana@example.com" } },
    { uid: "uid-ana", email: "ana@example.com" },
    { uid: "uid-ana", email: "ana@example.com" },
  );

  await createAuthUser(store, auth, records.sourceId);

  assert.deepEqual(auth.calls, ["uid:uid-ana", "email:ana@example.com"], "both recovery indexes are read");
  assert.equal(store.operations.get(operationId)?.status, "manual_recovery", "matching reads cannot reconstruct ownership proof");
  assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed");
});

test("P3.15a after Auth call return before reads preserves matching identities as manual recovery", async () => {
  const store = new StrictWorkerStore();
  const records = authCreateRecords(true);
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  const auth = new RecordingAuthCreator(
    { kind: "created", identity: { uid: "uid-ana", email: "ana@example.com" } },
    { uid: "uid-ana", email: "ana@example.com" },
    { uid: "uid-ana", email: "ana@example.com" },
  );

  await createAuthUser(store, auth, records.sourceId);

  assert.equal(auth.calls.includes("create:uid-ana:ana@example.com"), false, "replay never repeats Auth create");
  assert.equal(store.operations.get(operationId)?.status, "manual_recovery", "lost return/proof remains ambiguous");
});

async function assertSingleAuthReadFailure(
  failedRead: "uid" | "email",
): Promise<void> {
  const store = new StrictWorkerStore();
  const records = authCreateRecords();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  const calls: string[] = [];
  const auth: AuthCreator & AuthReader = {
    async createUser() {
      calls.push("create");
      return { kind: "created", identity: { uid: "uid-ana", email: "ana@example.com" } };
    },
    async readByUid() {
      calls.push("uid");
      if (failedRead === "uid") throw new Error("uid read failed");
      return { uid: "uid-ana", email: "ana@example.com" };
    },
    async readByEmail() {
      calls.push("email");
      if (failedRead === "email") throw new Error("email read failed");
      return { uid: "uid-ana", email: "ana@example.com" };
    },
  };

  await createAuthUser(store, auth, records.sourceId);

  assert.deepEqual(calls, ["create", "uid", "email"], `${failedRead} failure still observes the other index`);
  assert.equal(store.operations.get(operationId)?.status, "manual_recovery");
  assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed");
}

test("P3.15a UID read failure still observes email before manual recovery", async () => {
  await assertSingleAuthReadFailure("uid");
});

test("P3.15a email read failure still observes UID before manual recovery", async () => {
  await assertSingleAuthReadFailure("email");
});

test("P3.15a after committed completion replay leaves every record byte-identical", async () => {
  const store = new StrictWorkerStore();
  const records = profileCommitRecords();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);

  await completeProfileCommit(store, matchingAuth(), records.sourceId);
  const afterCommittedCompletion = strictStoreSnapshot(store);
  await completeProfileCommit(store, matchingAuth(), records.sourceId);

  assert.deepEqual(strictStoreSnapshot(store), afterCommittedCompletion, "after committed completion replay is a no-op");
});


test("P3.19 posts the exact Cloud Tasks envelope to the Functions emulator and acquires the persisted dispatch", {
  skip: !process.env.FUNCTIONS_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  assert.ok(onTaskDispatched, "the genuine task-queue export is available to the Functions emulator");
  const projectId = functionsEmulatorProjectId();
  const app = initializeApp({ projectId }, "p3-task-endpoint");
  try {
    const firestore = getFirestore(app);
    const records = acquisitionRecords();
    await firestore.collection("provisioningOperations").doc(operationId).set(records.operation);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);

    const queueName = `projects/${projectId}/locations/us-central1/queues/provisioning-dispatch`;
    const response = await fetch(
      taskEndpointUrl(projectId),
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CloudTasks-QueueName": queueName,
          "X-CloudTasks-TaskName": `${queueName}/tasks/${records.sourceId}`,
          "X-CloudTasks-TaskRetryCount": "0",
          "X-CloudTasks-TaskExecutionCount": "1",
          "X-CloudTasks-TaskETA": "2026-01-01T00:00:00.000Z",
        },
        body: JSON.stringify({ data: { dispatchId: records.sourceId } }),
      },
    );

    assert.equal(response.status, 204, "the task endpoint acknowledges the accepted initial delivery");
    const persisted = await realAcquisitionSnapshots(firestore, records);
    const transactionNow = persisted.operation?.updatedAt;
    assert.equal(typeof transactionNow, "number", "the worker persisted its transaction timestamp");
    const expected = expectedRealAcquisition(records, transactionNow as number);
    assert.deepEqual(persisted.operation, expected.operation);
    assert.deepEqual(persisted.source, expected.source);
    assert.deepEqual(persisted.next, expected.next);
    assert.deepEqual(persisted.audit, acquisitionAudit(records, transactionNow as number));
  } finally {
    await deleteApp(app);
  }
});


function pendingTerminalizationAudit(records: AcquisitionRecords, createdAt: number): WorkerRecord {
  return {
    schemaVersion: 1,
    eventId: deriveAuditEventId(records.operation.operationId as string, "failure", "terminal_failure", 0, 0),
    operationId: records.operation.operationId as string,
    correlationId: createHash("sha256").update(`provision-correlation:v1\0${records.operation.operationId as string}`, "utf8").digest("hex"),
    category: "failure",
    stage: "terminal_failure",
    outcome: "failed",
    code: "unavailable",
    actorUidDigest: null,
    intendedUidDigest: null,
    dispatchId: records.sourceId,
    generation: 0,
    sourceVersion: 0,
    createdAt,
  };
}

test("P3.21 RED terminalizes only the exact initial pending tuple with immutable unavailable evidence", async () => {
  const store = new StrictWorkerStore();
  const records = acquisitionRecords();
  seedAcquisition(store, records);

  await terminalizeInitialPending(store, records.sourceId, { retryCount: 8, executionCount: 9 });

  const audit = pendingTerminalizationAudit(records, store.now);
  assert.deepEqual(store.calls.slice(0, 3), [
    `readDispatch:${records.sourceId}`,
    `readOperation:${records.operation.operationId}`,
    `readAudit:${audit.eventId}`,
  ]);
  assert.deepEqual(store.operations.get(records.operation.operationId as string), {
    ...records.operation,
    status: "failed",
    phase: "terminal",
    version: 1,
    ownerToken: null,
    leaseExpiresAt: null,
    currentDispatchId: null,
    terminalCode: "unavailable",
    failureEvidence: [{
      eventId: audit.eventId,
      boundary: "acquire",
      code: "unavailable",
      class: "infrastructure",
      generation: 0,
      version: 0,
      recordedAt: store.now,
    }],
    retryEvidence: {
      committedFailureCount: 1,
      maxRetryCountSeen: 8,
      maxExecutionCountSeen: 9,
      lastRetryReasonCode: "unavailable",
    },
    updatedAt: store.now,
  });
  assert.deepEqual(store.dispatches.get(records.sourceId), {
    ...records.source,
    workerAck: "terminalized",
    workerAckAt: store.now,
  });
  assert.deepEqual(store.audits.get(audit.eventId as string), audit);
});

test("P3.21 RED preserves every record when the initial source tuple or retry evidence is not exact", async () => {
  const cases: readonly [string, (records: AcquisitionRecords) => void, { readonly retryCount: number; readonly executionCount: number }][] = [
    ["acknowledged source", (records) => { records.source.workerAck = "processed"; records.source.workerAckAt = now; }, { retryCount: 8, executionCount: 9 }],
    ["source owner seed", (records) => { records.source.ownerSeed = "f".repeat(64); }, { retryCount: 8, executionCount: 9 }],
    ["source fingerprint", (records) => { records.source.fingerprint = otherFingerprint; }, { retryCount: 8, executionCount: 9 }],
    ["noninitial operation", (records) => { records.operation.version = 1; }, { retryCount: 8, executionCount: 9 }],
    ["noninteger execution count", () => {}, { retryCount: 8, executionCount: 8.5 }],
  ];
  for (const [name, mutate, evidence] of cases) {
    const store = new StrictWorkerStore();
    const records = acquisitionRecords();
    mutate(records);
    seedAcquisition(store, records);
    const before = strictStoreSnapshot(store);

    await terminalizeInitialPending(store, records.sourceId, evidence);

    assertUnchanged(store, before, name);
  }
});


test("ODD-007 re-enters only recognized closed pending terminalizations within the eight-attempt ceiling", async () => {
      const records = acquisitionRecords();
      const strictStore = new StrictWorkerStore();
      seedAcquisition(strictStore, records);
      const closed = Object.assign(new Error("outer wrapper"), {
        cause: Object.assign(new Error("Transaction is invalid or closed"), { code: "3" }),
      });
      let attempts = 0;
      const retryingStore: WorkerStore = {
        transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
          attempts += 1;
          return attempts === 1 ? Promise.reject(closed) : strictStore.transaction(work);
        },
      };

      assert.equal(await terminalizeInitialPending(retryingStore, records.sourceId, { retryCount: 8, executionCount: 9 }), true);
      assert.equal(attempts, 2, "one closed transaction gets exactly one re-entry");
      assert.equal(strictStore.operations.get(operationId)?.status, "failed");
      assert.equal(strictStore.dispatches.get(records.sourceId)?.workerAck, "terminalized");
      assert.deepEqual(strictStore.audits.get(pendingTerminalizationAudit(records, strictStore.now).eventId as string), pendingTerminalizationAudit(records, strictStore.now));

      const nonmatching = new Error("Transaction is invalid or closed");
      let nonmatchingAttempts = 0;
      const nonmatchingStore: WorkerStore = {
        transaction<T>(): Promise<T> {
          nonmatchingAttempts += 1;
          return Promise.reject(nonmatching);
        },
      };
      await assert.rejects(
        () => terminalizeInitialPending(nonmatchingStore, records.sourceId, { retryCount: 8, executionCount: 9 }),
        (error: unknown) => error === nonmatching,
      );
      assert.equal(nonmatchingAttempts, 1, "nonmatching errors still propagate");

      let exhaustedAttempts = 0;
      const exhaustedStore: WorkerStore = {
        transaction<T>(): Promise<T> {
          exhaustedAttempts += 1;
          return Promise.reject(closed);
        },
      };
      await assert.rejects(
        () => terminalizeInitialPending(exhaustedStore, records.sourceId, { retryCount: 8, executionCount: 9 }),
        /closed Firestore transaction retry exhausted/,
      );
      assert.equal(exhaustedAttempts, 8, "closed-transaction re-entry remains capped at eight attempts");
    });

    test("P3.22 GREEN commits pending terminalization atomically through Firestore and preserves its audit on replay", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-pending-terminalization" }, "p3-pending-terminalization");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = acquisitionRecords();
    const audit = pendingTerminalizationAudit(records, now);
    await firestore.collection("provisioningOperations").doc(records.operation.operationId as string).set(records.operation);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);

    await terminalizeInitialPending(store, records.sourceId, { retryCount: 8, executionCount: 9 });

    const operationAfter = await firestore.collection("provisioningOperations").doc(records.operation.operationId as string).get().then((snapshot) => snapshot.data());
    const sourceAfter = await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data());
    const auditAfter = await firestore.collection("provisioningAudit").doc(audit.eventId as string).get().then((snapshot) => snapshot.data());
    const transactionNow = operationAfter?.updatedAt;
    assert.equal(typeof transactionNow, "number");
    assert.deepEqual(operationAfter, {
      ...records.operation,
      status: "failed",
      phase: "terminal",
      version: 1,
      ownerToken: null,
      leaseExpiresAt: null,
      currentDispatchId: null,
      terminalCode: "unavailable",
      failureEvidence: [{
        eventId: audit.eventId,
        boundary: "acquire",
        code: "unavailable",
        class: "infrastructure",
        generation: 0,
        version: 0,
        recordedAt: transactionNow,
      }],
      retryEvidence: {
        committedFailureCount: 1,
        maxRetryCountSeen: 8,
        maxExecutionCountSeen: 9,
        lastRetryReasonCode: "unavailable",
      },
      updatedAt: transactionNow,
    });
    assert.deepEqual(sourceAfter, { ...records.source, workerAck: "terminalized", workerAckAt: transactionNow });
    assert.deepEqual(auditAfter, pendingTerminalizationAudit(records, transactionNow as number));

    const stable = structuredClone({ operationAfter, sourceAfter, auditAfter });
    await terminalizeInitialPending(store, records.sourceId, { retryCount: 9, executionCount: 10 });
    assert.deepEqual({
      operationAfter: await firestore.collection("provisioningOperations").doc(records.operation.operationId as string).get().then((snapshot) => snapshot.data()),
      sourceAfter: await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data()),
      auditAfter: await firestore.collection("provisioningAudit").doc(audit.eventId as string).get().then((snapshot) => snapshot.data()),
    }, stable);
  } finally {
    await deleteApp(app);
  }
});


test("P3.23 RED rereads a pending-predicate mismatch and returns success without writes", async () => {
  const cases: readonly [string, RecordValue][] = [
    ["active", {
      ...activeOperation("f".repeat(64), 0, 1),
      authAttempted: false,
      authAttempt: null,
    }],
    ["terminal", {
      ...operation(),
      status: "failed",
      phase: "terminal",
      ownerToken: null,
      leaseExpiresAt: null,
      currentDispatchId: null,
    }],
    ["second mismatch", { ...operation(), version: 1 }],
  ];
  for (const [name, replacementOperation] of cases) {
    const store = new StrictWorkerStore();
    const records = acquisitionRecords();
    seedAcquisition(store, records);
    store.operations.set(operationId, replacementOperation);
    const before = strictStoreSnapshot(store);

    await terminalizeInitialPending(store, records.sourceId, { retryCount: 8, executionCount: 9 });

    assert.deepEqual(strictStoreSnapshot(store), before, name);
    assert.deepEqual(store.calls, [
      `readDispatch:${records.sourceId}`,
      `readOperation:${operationId}`,
      `readDispatch:${records.sourceId}`,
      `readOperation:${operationId}`,
    ], `${name} is reread before returning success`);
    assert.equal(store.calls.some((call) => call.startsWith("write") || call.startsWith("create")), false, `${name} writes`);
  }
});

test("P3.24 GREEN treats a second pending predicate loss as a successful no-op", async () => {
  const strictStore = new StrictWorkerStore();
  const records = acquisitionRecords();
  seedAcquisition(strictStore, records);
  const mismatch = { ...records.operation, version: 1 };
  let transactionCount = 0;
  const store: WorkerStore = {
    transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
      transactionCount += 1;
      strictStore.operations.set(
        operationId,
        transactionCount === 2 ? records.operation : mismatch,
      );
      return strictStore.transaction(work);
    },
  };

  await terminalizeInitialPending(store, records.sourceId, { retryCount: 8, executionCount: 9 });

  assert.equal(transactionCount, 3, "mismatch, exact-pending reread, then guarded retry");
  assert.deepEqual(strictStore.operations.get(operationId), mismatch);
  assert.deepEqual(strictStore.dispatches.get(records.sourceId), records.source);
  assert.equal(strictStore.audits.size, 0);
  assert.equal(strictStore.calls.some((call) => call.startsWith("write") || call.startsWith("create")), false);
});

function activeTerminalizationRecords(phase: "auth_preflight" | "auth_create" = "auth_preflight") {
  const sourceId = deriveDispatchId(operationId, phase, 0, phase === "auth_preflight" ? 1 : 2);
  const source = activeDispatch(0, phase === "auth_preflight" ? 1 : 2, phase);
  const token = deriveOwnerToken(sourceId, 0);
  const active = phase === "auth_preflight"
    ? { ...operation(true), ownerToken: token, currentDispatchId: sourceId, leaseExpiresAt: now + 60_000 }
    : {
      ...authCreateRecords().active,
      ownerToken: token,
      currentDispatchId: sourceId,
      leaseExpiresAt: now + 60_000,
    };
  return { active, source, sourceId, token };
}

function activeTerminalizationAudit(
  records: ReturnType<typeof activeTerminalizationRecords>,
  code: "unavailable" | "internal",
  createdAt: number,
): WorkerRecord {
  return {
    schemaVersion: 1,
    eventId: deriveAuditEventId(operationId, "failure", "terminal_failure", 0, records.active.version as number),
    operationId,
    correlationId: createHash("sha256").update(`provision-correlation:v1\0${operationId}`, "utf8").digest("hex"),
    category: "failure",
    stage: "terminal_failure",
    outcome: "failed",
    code,
    actorUidDigest: null,
    intendedUidDigest: null,
    dispatchId: records.sourceId,
    generation: 0,
    sourceVersion: records.active.version as number,
    createdAt,
  };
}

test("P3.25 RED requires the complete live current-owner CAS tuple before safe active terminalization", async () => {
  const records = activeTerminalizationRecords();
  const store = new StrictWorkerStore();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);

  await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

  const audit = activeTerminalizationAudit(records, "unavailable", store.now);
  assert.deepEqual(store.operations.get(operationId), {
    ...records.active,
    status: "failed",
    phase: "terminal",
    version: 2,
    ownerToken: null,
    leaseExpiresAt: null,
    terminalCode: "unavailable",
    failureEvidence: [{
      eventId: audit.eventId,
      boundary: "auth_preflight",
      code: "unavailable",
      class: "infrastructure",
      generation: 0,
      version: 1,
      recordedAt: store.now,
    }],
    retryEvidence: {
      committedFailureCount: 1,
      maxRetryCountSeen: 8,
      maxExecutionCountSeen: 9,
      lastRetryReasonCode: "unavailable",
    },
    updatedAt: store.now,
  });
  assert.deepEqual(store.dispatches.get(records.sourceId), { ...records.source, workerAck: "terminalized", workerAckAt: store.now });
  assert.deepEqual(store.audits.get(audit.eventId), audit);
});

test("P3.25 RED fails closed for each incomplete active CAS tuple and preserves every record", async () => {
  const mutations: readonly [string, (records: ReturnType<typeof activeTerminalizationRecords>) => void][] = [
    ["fingerprint", (records) => { records.active.fingerprint = otherFingerprint; }],
    ["status", (records) => { records.active.status = "pending"; records.active.phase = "dispatch_pending"; }],
    ["phase", (records) => { records.active.phase = "auth_create"; }],
    ["generation", (records) => { records.active.generation = 1; }],
    ["version", (records) => { records.active.version = 2; }],
    ["owner token", (records) => { records.active.ownerToken = "f".repeat(64); }],
    ["current dispatch", (records) => { records.active.currentDispatchId = "f".repeat(64); }],
  ];
  for (const [name, mutate] of mutations) {
    const records = activeTerminalizationRecords();
    mutate(records);
    const store = new StrictWorkerStore();
    store.operations.set(operationId, records.active);
    store.dispatches.set(records.sourceId, records.source);
    const before = strictStoreSnapshot(store);

    await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

    assert.deepEqual(strictStoreSnapshot(store), before, name);
  }
});

test("P3.25 RED routes non-preflight active work to atomic internal manual recovery and rolls back audit drift", async () => {
  const records = activeTerminalizationRecords("auth_create");
  const store = new StrictWorkerStore();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);

  await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

  const audit = activeTerminalizationAudit(records, "internal", store.now);
  assert.deepEqual(store.operations.get(operationId), {
    ...records.active,
    status: "manual_recovery",
    phase: "terminal",
    version: 3,
    ownerToken: null,
    leaseExpiresAt: null,
    recoveryCode: "internal",
    failureEvidence: [{
      eventId: audit.eventId,
      boundary: "auth_create",
      code: "internal",
      class: "recovery",
      generation: 0,
      version: 2,
      recordedAt: store.now,
    }],
    retryEvidence: {
      committedFailureCount: 1,
      maxRetryCountSeen: 8,
      maxExecutionCountSeen: 9,
      lastRetryReasonCode: "internal",
    },
    updatedAt: store.now,
  });
  assert.deepEqual(store.dispatches.get(records.sourceId), { ...records.source, workerAck: "terminalized", workerAckAt: store.now });
  assert.deepEqual(store.audits.get(audit.eventId), audit);

  const conflictRecords = activeTerminalizationRecords();
  const conflictStore = new StrictWorkerStore();
  const conflictAudit = activeTerminalizationAudit(conflictRecords, "unavailable", now - 1);
  conflictStore.operations.set(operationId, conflictRecords.active);
  conflictStore.dispatches.set(conflictRecords.sourceId, conflictRecords.source);
  conflictStore.audits.set(conflictAudit.eventId, { ...conflictAudit, code: "internal" });
  const before = strictStoreSnapshot(conflictStore);
  await assert.rejects(
    () => terminalizeActiveCurrent(conflictStore, conflictRecords.sourceId, { retryCount: 8, executionCount: 9 }),
    /audit identity mismatch/,
  );
  assert.deepEqual(strictStoreSnapshot(conflictStore), before);
});

test("P3.26 GREEN commits exact active safe terminalization atomically through Firestore", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-active-terminalization" }, "p3-active-terminalization");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = activeTerminalizationRecords();
    records.active.leaseExpiresAt = Date.now() + 60_000;
    await firestore.collection("provisioningOperations").doc(operationId).set(records.active);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);

    await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

    const operationAfter = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
    const transactionNow = operationAfter?.updatedAt as number;
    const audit = activeTerminalizationAudit(records, "unavailable", transactionNow);
    assert.deepEqual(operationAfter, {
      ...records.active,
      status: "failed",
      phase: "terminal",
      version: 2,
      ownerToken: null,
      leaseExpiresAt: null,
      terminalCode: "unavailable",
      failureEvidence: [{
        eventId: audit.eventId,
        boundary: "auth_preflight",
        code: "unavailable",
        class: "infrastructure",
        generation: 0,
        version: 1,
        recordedAt: transactionNow,
      }],
      retryEvidence: {
        committedFailureCount: 1,
        maxRetryCountSeen: 8,
        maxExecutionCountSeen: 9,
        lastRetryReasonCode: "unavailable",
      },
      updatedAt: transactionNow,
    });
    assert.deepEqual(
      await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data()),
      { ...records.source, workerAck: "terminalized", workerAckAt: transactionNow },
    );
    assert.deepEqual(
      await firestore.collection("provisioningAudit").doc(audit.eventId).get().then((snapshot) => snapshot.data()),
      audit,
    );
  } finally {
    await deleteApp(app);
  }
});

test("P3.22 TRIANGULATE preserves a matching failure audit timestamp and rolls back an audit conflict", async () => {
  const matchingStore = new StrictWorkerStore();
  const matchingRecords = acquisitionRecords();
  const matchingAudit = pendingTerminalizationAudit(matchingRecords, now - 1);
  seedAcquisition(matchingStore, matchingRecords);
  matchingStore.audits.set(matchingAudit.eventId as string, matchingAudit);

  await terminalizeInitialPending(matchingStore, matchingRecords.sourceId, { retryCount: 8, executionCount: 9 });

  assert.equal(matchingStore.audits.get(matchingAudit.eventId as string), matchingAudit);
  assert.equal(matchingStore.dispatches.get(matchingRecords.sourceId)?.workerAck, "terminalized");

  const conflictStore = new StrictWorkerStore();
  const conflictRecords = acquisitionRecords();
  const conflictAudit = pendingTerminalizationAudit(conflictRecords, now - 1);
  seedAcquisition(conflictStore, conflictRecords);
  conflictStore.audits.set(conflictAudit.eventId as string, { ...conflictAudit, code: "internal" });
  const before = strictStoreSnapshot(conflictStore);

  await assert.rejects(
    () => terminalizeInitialPending(conflictStore, conflictRecords.sourceId, { retryCount: 8, executionCount: 9 }),
    /audit identity mismatch/,
  );
  assert.deepEqual(strictStoreSnapshot(conflictStore), before);
});

test("P3.27 RED rejects an unexpired foreign owner without mutating the operation, dispatch, or audit", async () => {
  const records = activeTerminalizationRecords();
  records.active.ownerToken = "f".repeat(64);
  const store = new StrictWorkerStore();
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);
  const before = strictStoreSnapshot(store);

  await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

  assert.deepEqual(strictStoreSnapshot(store), before);
  assert.deepEqual(store.calls, [
    `readDispatch:${records.sourceId}`,
    `readOperation:${operationId}`,
  ]);
  assert.equal(store.calls.some((call) => call.startsWith("write") || call.startsWith("create")), false);
});

test("P3.28 GREEN treats a foreign-owner CAS reread mismatch as successful and mutation-free in Firestore", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-foreign-owner-live-lease" }, "p3-foreign-owner-live-lease");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = activeTerminalizationRecords();
    records.active.leaseExpiresAt = Date.now() + 60_000;
    records.active.ownerToken = "f".repeat(64);
    await firestore.collection("provisioningOperations").doc(operationId).set(records.active);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    const beforeOperation = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
    const beforeDispatch = await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data());

    await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

    assert.deepEqual(await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data()), beforeOperation);
    assert.deepEqual(await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data()), beforeDispatch);
    assert.equal((await firestore.collection("provisioningAudit").get()).empty, true);
  } finally {
    await deleteApp(app);
  }
});

function closedTransactionTakeoverStore(failure: Error): { readonly store: WorkerStore; readonly strictStore: StrictWorkerStore; readonly records: ReturnType<typeof activeTerminalizationRecords>; readonly attempts: () => number } {
      const strictStore = new StrictWorkerStore();
      const records = activeTerminalizationRecords();
      records.active.leaseExpiresAt = strictStore.now;
      strictStore.operations.set(operationId, records.active);
      strictStore.dispatches.set(records.sourceId, records.source);
      let transactions = 0;
      const store: WorkerStore = {
        async transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
          transactions += 1;
          if (transactions === 1) throw failure;
          const result = await strictStore.transaction(work);
          if (transactions === 2) {
            const takenOver = strictStore.operations.get(operationId)!;
            strictStore.operations.set(operationId, { ...takenOver, ownerToken: "f".repeat(64) });
          }
          return result;
        },
      };
      return { store, strictStore, records, attempts: () => transactions };
    }

    async function assertClosedTransactionTakeoverReentry(failure: Error): Promise<void> {
      const { store, strictStore, records, attempts } = closedTransactionTakeoverStore(failure);
      assert.equal(await takeoverExpiredCurrent(store, records.sourceId), null);
      assert.equal(attempts(), 3, "one failed takeover, one bounded re-entry, then authoritative reread");
      assert.equal(strictStore.operations.get(operationId)?.status, "active");
      assert.equal(strictStore.dispatches.get(records.sourceId)?.workerAck, null);
      assert.equal(strictStore.audits.size, 1, "takeover alone never terminalizes without its valid reread tuple");
    }

    test("P3.54 RED accepts real closed-transaction wrapper shapes only when code and message share a cause node", async () => {
      for (const failure of [
        Object.assign(new Error("Transaction is invalid or closed"), { code: 3 }),
        Object.assign(new Error("Transaction invalid or closed"), { code: "3" }),
        Object.assign(new Error("transaction is invalid or closed"), { code: "INVALID_ARGUMENT" }),
        Object.assign(new Error("outer wrapper"), { cause: Object.assign(new Error("Transaction is invalid or closed"), { code: "3" }) }),
      ]) {
        await assertClosedTransactionTakeoverReentry(failure);
      }
    });

    test("P3.54 RED propagates nonmatching, split-node, and cyclic closed-transaction wrapper shapes", async () => {
      const codeWithoutMessage = Object.assign(new Error("unrelated failure"), { code: 3 });
      const messageWithoutCode = new Error("Transaction is invalid or closed");
      const splitAcrossNodes = Object.assign(new Error("outer wrapper"), {
        code: 3,
        cause: Object.assign(new Error("Transaction is invalid or closed"), { code: "unavailable" }),
      });
      const cycle = Object.assign(new Error("outer wrapper"), { code: "unavailable" }) as Error & { cause?: unknown };
      cycle.cause = cycle;
      for (const failure of [codeWithoutMessage, messageWithoutCode, splitAcrossNodes, cycle]) {
        const { store, records } = closedTransactionTakeoverStore(failure);
        await assert.rejects(
          () => takeoverExpiredCurrent(store, records.sourceId),
          (error: unknown) => error === failure,
          "only a same-node closed-transaction tuple can re-enter",
        );
      }
    });

    test("P3.29 RED takes over an exact expired active tuple before terminalizing with the new generation and version", async () => {
  const records = activeTerminalizationRecords();
  const store = new StrictWorkerStore();
  records.active.leaseExpiresAt = store.now;
  store.operations.set(operationId, records.active);
  store.dispatches.set(records.sourceId, records.source);

  await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

  const takeoverAuditId = deriveAuditEventId(operationId, "progress", "state_transition", 0, 1);
  const terminalAuditId = deriveAuditEventId(operationId, "failure", "terminal_failure", 1, 2);
  assert.deepEqual(store.operations.get(operationId), {
    ...records.active,
    status: "failed",
    phase: "terminal",
    generation: 1,
    version: 3,
    ownerToken: null,
    leaseExpiresAt: null,
    terminalCode: "unavailable",
    failureEvidence: [{
      eventId: terminalAuditId,
      boundary: "auth_preflight",
      code: "unavailable",
      class: "infrastructure",
      generation: 1,
      version: 2,
      recordedAt: store.now,
    }],
    retryEvidence: {
      committedFailureCount: 1,
      maxRetryCountSeen: 8,
      maxExecutionCountSeen: 9,
      lastRetryReasonCode: "unavailable",
    },
    updatedAt: store.now,
  });
  assert.deepEqual(store.dispatches.get(records.sourceId), {
    ...records.source,
    workerAck: "terminalized",
    workerAckAt: store.now,
  });
  assert.equal(store.audits.size, 2);
  assert.equal(store.audits.get(takeoverAuditId)?.generation, 0);
  assert.equal(store.audits.get(takeoverAuditId)?.sourceVersion, 1);
  assert.equal(store.audits.get(terminalAuditId)?.generation, 1);
  assert.equal(store.audits.get(terminalAuditId)?.sourceVersion, 2);
});

test("P3.29 RED keeps a completed takeover bounded when the terminalization tuple loses CAS", async () => {
  const strictStore = new StrictWorkerStore();
  const records = activeTerminalizationRecords();
  records.active.leaseExpiresAt = strictStore.now;
  strictStore.operations.set(operationId, records.active);
  strictStore.dispatches.set(records.sourceId, records.source);
  let transactions = 0;
  const store: WorkerStore = {
    async transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
      transactions += 1;
      if (transactions === 3) {
        const takenOver = strictStore.operations.get(operationId)!;
        strictStore.operations.set(operationId, { ...takenOver, ownerToken: "f".repeat(64) });
      }
      return strictStore.transaction(work);
    },
  };

  await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

  assert.equal(transactions, 3);
  assert.equal(strictStore.operations.get(operationId)?.status, "active");
  assert.equal(strictStore.operations.get(operationId)?.generation, 1);
  assert.equal(strictStore.operations.get(operationId)?.version, 2);
  assert.equal(strictStore.dispatches.get(records.sourceId)?.workerAck, null);
  assert.equal(strictStore.audits.size, 1);
});

test("P3.30 GREEN terminalizes an expired active tuple through the Auth and Firestore emulators", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-expired-active-terminalization" }, "p3-expired-active-terminalization");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = activeTerminalizationRecords();
    records.active.leaseExpiresAt = Date.now() - 1;
    await firestore.collection("provisioningOperations").doc(operationId).set(records.active);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);

    await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

    const terminal = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
    const source = await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data());
    assert.equal(terminal?.status, "failed");
    assert.equal(terminal?.phase, "terminal");
    assert.equal(terminal?.generation, 1);
    assert.equal(terminal?.version, 3);
    assert.equal(source?.workerAck, "terminalized");
    assert.equal((await firestore.collection("provisioningAudit").get()).size, 2);
  } finally {
    await deleteApp(app);
  }
});

test("P3.27 RED discards a conflicted terminalization buffer before a foreign owner wins the retry", async () => {
  const records = activeTerminalizationRecords();
  const foreign = { ...records.active, ownerToken: "f".repeat(64) };
  let attempts = 0;
  let committedOperation: WorkerRecord = records.active;
  let committedDispatch: WorkerRecord = records.source;
  const committedAudits = new Map<string, WorkerRecord>();
  const committedWorkerWrites: string[] = [];
  const discardedWorkerWrites: string[] = [];
  const store: WorkerStore = {
    async transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
      attempts += 1;
      const attempt = attempts;
      let bufferedOperation: WorkerRecord | undefined;
      let bufferedDispatch: WorkerRecord | undefined;
      const bufferedAudits = new Map<string, WorkerRecord>();
      const bufferedWorkerWrites: string[] = [];
      const result = await work({
        now,
        async readOperation() { return committedOperation; },
        async readDispatch() { return committedDispatch; },
        async readAudit(eventId) { return committedAudits.get(eventId) ?? null; },
        async readProfile() { return null; },
        writeOperation(_operationId, operation) { bufferedWorkerWrites.push("operation"); bufferedOperation = operation; },
        writeDispatch(_dispatchId, dispatch) { bufferedWorkerWrites.push("dispatch"); bufferedDispatch = dispatch; },
        createDispatch() { bufferedWorkerWrites.push("next-dispatch"); },
        createAudit(eventId, audit) { bufferedWorkerWrites.push("audit"); bufferedAudits.set(eventId, audit); },
        writeProfile() { bufferedWorkerWrites.push("profile"); },
      });
      if (attempt === 1) {
        discardedWorkerWrites.push(...bufferedWorkerWrites);
        committedOperation = foreign;
        throw Object.assign(new Error("INVALID_ARGUMENT: transaction invalid or closed"), { code: 3 });
      }
      if (bufferedOperation !== undefined) { committedWorkerWrites.push("operation"); committedOperation = bufferedOperation; }
      if (bufferedDispatch !== undefined) { committedWorkerWrites.push("dispatch"); committedDispatch = bufferedDispatch; }
      for (const [eventId, audit] of bufferedAudits) { committedWorkerWrites.push("audit"); committedAudits.set(eventId, audit); }
      return result;
    },
  };

  await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

  assert.equal(attempts, 2);
  assert.deepEqual(discardedWorkerWrites, ["operation", "dispatch", "audit"]);
  assert.deepEqual(committedWorkerWrites, []);
  assert.deepEqual(committedOperation, foreign);
  assert.equal(committedDispatch.workerAck, null);
  assert.equal(committedAudits.size, 0);
});

test("P3.31 RED preserves terminal bytes and an existing acknowledgement without replay mutation", async () => {
  const records = activeTerminalizationRecords();
  const audit = activeTerminalizationAudit(records, "unavailable", now - 1);
  const terminal = {
    ...records.active,
    status: "failed",
    phase: "terminal",
    version: 2,
    ownerToken: null,
    leaseExpiresAt: null,
    currentDispatchId: null,
    terminalCode: "unavailable",
    failureEvidence: [{
      eventId: audit.eventId,
      boundary: "auth_preflight",
      code: "unavailable",
      class: "infrastructure",
      generation: 0,
      version: 1,
      recordedAt: now - 1,
    }],
    retryEvidence: {
      committedFailureCount: 1,
      maxRetryCountSeen: 8,
      maxExecutionCountSeen: 9,
      lastRetryReasonCode: "unavailable",
    },
    updatedAt: now - 1,
  };
  const acknowledged = { ...records.source, workerAck: "terminalized", workerAckAt: now - 1 };
  const store = new StrictWorkerStore();
  store.operations.set(operationId, terminal);
  store.dispatches.set(records.sourceId, acknowledged);
  store.audits.set(audit.eventId, audit);
  const before = strictStoreSnapshot(store);

  await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

  assert.deepEqual(strictStoreSnapshot(store), before);
  assert.deepEqual(store.calls, [
    `readDispatch:${records.sourceId}`,
    `readOperation:${operationId}`,
  ]);
  assert.equal(store.calls.some((call) => call.startsWith("write") || call.startsWith("create")), false);
});

test("P3.31 RED treats an existing terminal dispatch acknowledgement as idempotent without a version-only write", async () => {
  const records = activeTerminalizationRecords();
  const terminal = {
    ...records.active,
    status: "manual_recovery",
    phase: "terminal",
    version: 2,
    ownerToken: null,
    leaseExpiresAt: null,
    currentDispatchId: null,
    recoveryCode: "internal",
    failureEvidence: [],
    retryEvidence: {
      committedFailureCount: 1,
      maxRetryCountSeen: 8,
      maxExecutionCountSeen: 9,
      lastRetryReasonCode: "internal",
    },
    updatedAt: now - 1,
  };
  const acknowledged = { ...records.source, workerAck: "terminalized", workerAckAt: now - 1 };
  const store = new StrictWorkerStore();
  store.operations.set(operationId, terminal);
  store.dispatches.set(records.sourceId, acknowledged);
  const before = strictStoreSnapshot(store);

  await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

  assert.deepEqual(strictStoreSnapshot(store), before);
  assert.deepEqual(store.calls, [
    `readDispatch:${records.sourceId}`,
    `readOperation:${operationId}`,
  ]);
  assert.equal(store.calls.some((call) => call.startsWith("write") || call.startsWith("create")), false);
});

test("P3.32 GREEN preserves terminal operation, acknowledged dispatch, and audit bytes through Auth and Firestore", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-terminal-idempotency" }, "p3-terminal-idempotency");
  try {
    const firestore = getFirestore(app);
    const store = new FirestoreWorkerStore(firestore);
    const records = activeTerminalizationRecords();
    const audit = activeTerminalizationAudit(records, "unavailable", now - 1);
    const terminal = {
      ...records.active,
      status: "failed",
      phase: "terminal",
      version: 2,
      ownerToken: null,
      leaseExpiresAt: null,
      currentDispatchId: null,
      terminalCode: "unavailable",
      failureEvidence: [{
        eventId: audit.eventId,
        boundary: "auth_preflight",
        code: "unavailable",
        class: "infrastructure",
        generation: 0,
        version: 1,
        recordedAt: now - 1,
      }],
      retryEvidence: {
        committedFailureCount: 1,
        maxRetryCountSeen: 8,
        maxExecutionCountSeen: 9,
        lastRetryReasonCode: "unavailable",
      },
      updatedAt: now - 1,
    };
    const acknowledged = { ...records.source, workerAck: "terminalized", workerAckAt: now - 1 };
    await firestore.collection("provisioningOperations").doc(operationId).set(terminal);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(acknowledged);
    await firestore.collection("provisioningAudit").doc(audit.eventId).set(audit);
    const before = {
      operation: await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data()),
      dispatch: await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data()),
      audit: await firestore.collection("provisioningAudit").doc(audit.eventId).get().then((snapshot) => snapshot.data()),
    };

    await terminalizeActiveCurrent(store, records.sourceId, { retryCount: 8, executionCount: 9 });

    assert.deepEqual(await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data()), before.operation);
    assert.deepEqual(await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data()), before.dispatch);
    assert.deepEqual(await firestore.collection("provisioningAudit").doc(audit.eventId).get().then((snapshot) => snapshot.data()), before.audit);
  } finally {
    await deleteApp(app);
  }
});


test("P3.33 RED permits only retryCount 0–7 guarded work, reserves 8–11 for terminalization, and rejects invalid counts before mutation", async () => {
  for (const retryCount of [0, 1, 2, 3, 4, 5, 6, 7]) {
    const store = new StrictWorkerStore();
    const records = acquisitionRecords();
    seedAcquisition(store, records);

    await processProvisioningTask(store, records.sourceId, retryCount);

    assert.equal(store.operations.get(operationId)?.status, "active", `retry ${retryCount} may perform guarded work`);
    assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "processed");
  }

  for (const retryCount of [8, 9, 10, 11]) {
    const store = new StrictWorkerStore();
    const records = acquisitionRecords();
    seedAcquisition(store, records);

    await processProvisioningTask(store, records.sourceId, retryCount);

    assert.equal(store.operations.get(operationId)?.status, "failed", `retry ${retryCount} terminalizes only`);
    assert.equal(store.operations.get(operationId)?.phase, "terminal");
    assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "terminalized");
  }

  for (const retryCount of [-1, 1.5, Number.NaN, 12, "8", null]) {
    const store = new StrictWorkerStore();
    const records = acquisitionRecords();
    seedAcquisition(store, records);
    const before = strictStoreSnapshot(store);

    await assert.rejects(
      () => processProvisioningTask(store, records.sourceId, retryCount),
      (error: unknown) => (error as { readonly code?: unknown }).code === "unavailable",
      `retry ${String(retryCount)} fails retryably before mutation`,
    );
    assert.deepEqual(strictStoreSnapshot(store), before);
  }
});

test("P3.33 RED surfaces a durable-store outage with operational alert and runbook semantics on the last reserved attempt", async () => {
  const alerts: unknown[][] = [];
  const originalError = console.error;
  console.error = (...values: unknown[]) => { alerts.push(values); };
  const unavailableStore: WorkerStore = {
    async transaction<T>(): Promise<T> {
      throw new Error("durable store unavailable");
    },
  };

  try {
    await assert.rejects(
      () => processProvisioningTask(unavailableStore, "f".repeat(64), 11),
      (error: unknown) => {
        const failure = error as { readonly code?: unknown; readonly message?: unknown };
        return failure.code === "unavailable"
          && typeof failure.message === "string"
          && failure.message.includes("outage")
          && failure.message.includes("outbox-recovery-runbook.md");
      },
    );
  } finally {
    console.error = originalError;
  }

  assert.deepEqual(alerts, [[{
    eventCode: "retry-exhausted",
    resultCode: null,
    reasonCode: "unavailable",
    digests: [{
      domain: "provision-dispatch:v1",
      value: createHash("sha256").update(`provision-dispatch:v1\0${"f".repeat(64)}`, "utf8").digest("hex"),
    }],
  }]]);
});

test("P3.34 GREEN rejects malformed retry metadata with 5xx before endpoint mutation and terminalizes retry 8 through aligned emulators", {
  skip: !process.env.FUNCTIONS_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST,
}, async () => {
  const projectId = functionsEmulatorProjectId();
  const app = initializeApp({ projectId }, "p3-task-retry-protocol");
  try {
    const firestore = getFirestore(app);
    const invalidRecords = acquisitionRecords();
    await firestore.collection("provisioningOperations").doc(operationId).set(invalidRecords.operation);
    await firestore.collection("provisioningDispatch").doc(invalidRecords.sourceId).set(invalidRecords.source);
    await firestore.collection("provisioningAudit").doc(invalidRecords.auditId).delete();
    await firestore.collection("provisioningDispatch").doc(invalidRecords.nextId).delete();
    const queueName = `projects/${projectId}/locations/us-central1/queues/provisioning-dispatch`;
    const headers = (retryCount: string, dispatchId: string) => ({
      "Content-Type": "application/json",
      "X-CloudTasks-QueueName": queueName,
      "X-CloudTasks-TaskName": `${queueName}/tasks/${dispatchId}`,
      "X-CloudTasks-TaskRetryCount": retryCount,
      "X-CloudTasks-TaskExecutionCount": "1",
      "X-CloudTasks-TaskETA": "2026-01-01T00:00:00.000Z",
    });

    const rejected = await fetch(
      taskEndpointUrl(projectId),
      { method: "POST", headers: headers("-1", invalidRecords.sourceId), body: JSON.stringify({ data: { dispatchId: invalidRecords.sourceId } }) },
    );
    assert.equal(rejected.status, 500);
    assert.deepEqual(await realAcquisitionSnapshots(firestore, invalidRecords), {
      operation: invalidRecords.operation,
      source: invalidRecords.source,
      audit: undefined,
      next: undefined,
    });

    const terminalRecords = acquisitionRecords({
      operation: { ...operation(), operationId: otherOperationId },
      source: { ...dispatch(), operationId: otherOperationId },
    });
    await firestore.collection("provisioningOperations").doc(otherOperationId).set(terminalRecords.operation);
    await firestore.collection("provisioningDispatch").doc(terminalRecords.sourceId).set(terminalRecords.source);
    const terminalized = await fetch(
      taskEndpointUrl(projectId),
      { method: "POST", headers: headers("8", terminalRecords.sourceId), body: JSON.stringify({ data: { dispatchId: terminalRecords.sourceId } }) },
    );
    assert.equal(terminalized.status, 204);
    assert.equal((await firestore.collection("provisioningOperations").doc(otherOperationId).get()).data()?.status, "failed");
    assert.equal((await firestore.collection("provisioningDispatch").doc(terminalRecords.sourceId).get()).data()?.workerAck, "terminalized");
  } finally {
    await deleteApp(app);
  }
});


test("P3.35 RED reserves attempts 8–11 for terminalization, retries a failed transaction, and preserves committed terminal replays", async () => {
  for (const retryCount of [8, 9, 10, 11]) {
    const store = new StrictWorkerStore();
    const records = acquisitionRecords();
    seedAcquisition(store, records);

    await processProvisioningTask(store, records.sourceId, retryCount);

    assert.equal(store.operations.get(operationId)?.status, "failed", `retry ${retryCount} terminalizes`);
    assert.equal(store.dispatches.get(records.sourceId)?.workerAck, "terminalized");
    assert.equal(store.calls.some((call) => call.startsWith("createDispatch")), false, `retry ${retryCount} does no normal work`);
  }

  const failedStore = new StrictWorkerStore();
  const failedRecords = acquisitionRecords();
  seedAcquisition(failedStore, failedRecords);
  const beforeFailure = strictStoreSnapshot(failedStore);
  failedStore.failAuditCreate = true;
  await assert.rejects(
    () => processProvisioningTask(failedStore, failedRecords.sourceId, 8),
    /audit create conflict/,
  );
  assert.deepEqual(strictStoreSnapshot(failedStore), beforeFailure);
  failedStore.failAuditCreate = false;
  await processProvisioningTask(failedStore, failedRecords.sourceId, 9);
  assert.equal(failedStore.operations.get(operationId)?.status, "failed");
  assert.equal(failedStore.dispatches.get(failedRecords.sourceId)?.workerAck, "terminalized");

  const replayStore = new StrictWorkerStore();
  const replayRecords = acquisitionRecords();
  seedAcquisition(replayStore, replayRecords);
  await processProvisioningTask(replayStore, replayRecords.sourceId, 8);
  const replayBefore = strictStoreSnapshot(replayStore);
  let replayTransactions = 0;
  const replayGuard: WorkerStore = {
    transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
      replayTransactions += 1;
      if (replayTransactions === 3) throw new Error("unexpected active terminalization");
      return replayStore.transaction(work);
    },
  };

  await processProvisioningTask(replayGuard, replayRecords.sourceId, 9);

  assert.equal(replayTransactions, 2);
  assert.deepEqual(strictStoreSnapshot(replayStore), replayBefore);
});

test("P3.51 characterizes Firebase Auth identity, recovery, provenance, and atomic completion", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-auth-matrix" }, "p3-auth-matrix");
  try {
    const firestore = getFirestore(app);
    const auth = getAuth(app);
    const store = new FirestoreWorkerStore(firestore);
    const reader = new FirebaseAuthReader(auth);

    const uidForeign = intentRecords();
    uidForeign.active.leaseExpiresAt = Date.now() + 60_000;
    await auth.createUser({ uid: "uid-ana", email: "foreign-uid@example.com" });
    await firestore.collection("provisioningOperations").doc(operationId).set(uidForeign.active);
    await firestore.collection("provisioningDispatch").doc(uidForeign.sourceId).set(uidForeign.source);
    await preflightAuth(store, reader, uidForeign.sourceId);
    assert.equal((await firestore.collection("provisioningOperations").doc(operationId).get()).data()?.status, "failed", "foreign pre-attempt UID fails before Auth creation");
    assert.equal((await auth.getUser("uid-ana")).email, "foreign-uid@example.com", "foreign UID identity is never deleted");
    await auth.deleteUser("uid-ana"); // Test setup only; production never deletes Auth identities.

    const foreign = intentRecords();
    foreign.active.leaseExpiresAt = Date.now() + 60_000;
    await auth.createUser({ uid: "foreign-uid", email: "ana@example.com" });
    await firestore.collection("provisioningOperations").doc(operationId).set(foreign.active);
    await firestore.collection("provisioningDispatch").doc(foreign.sourceId).set(foreign.source);
    await preflightAuth(store, reader, foreign.sourceId);
    const foreignAfter = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
    assert.equal(foreignAfter?.status, "failed", "foreign pre-attempt email fails before Auth creation");
    await assert.rejects(
      () => auth.getUser("uid-ana"),
      (error: unknown) => (error as { readonly code?: unknown }).code === "auth/user-not-found",
    );
    assert.equal((await auth.getUser("foreign-uid")).email, "ana@example.com", "foreign identity is never deleted");
    await auth.deleteUser("foreign-uid"); // Test setup only; production never deletes Auth identities.

    const created = intentRecords();
    created.active.leaseExpiresAt = Date.now() + 60_000;
    await firestore.collection("provisioningOperations").doc(operationId).set(created.active);
    await firestore.collection("provisioningDispatch").doc(created.sourceId).set(created.source);
    await persistAuthIntent(store, created.sourceId);
    await createAuthUser(store, reader, created.nextId);
    const afterCreate = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
    assert.deepEqual(
      afterCreate?.authAttempt?.proof,
      { attemptId: created.nextId, confirmedAt: afterCreate?.updatedAt, uidRead: "uid-ana", emailRead: "ana@example.com" },
      "exact create result requires both persisted Auth index reads",
    );
    assert.equal((await auth.getUser("uid-ana")).email, "ana@example.com");
    assert.equal((await auth.getUserByEmail("ana@example.com")).uid, "uid-ana");

    const profileId = afterCreate?.currentDispatchId as string;
    await completeProfileCommit(store, reader, profileId);
    const completed = await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data());
    assert.equal(completed?.status, "completed");
    assert.equal((await firestore.collection("users").doc("uid-ana").get()).data()?.provisioningOperationId, operationId);

    const stable = structuredClone(completed);
    await completeProfileCommit(store, reader, profileId);
    assert.deepEqual(await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data()), stable, "completed replay is immutable");

    const conflict = profileCommitRecords();
    (conflict.active as RecordValue).leaseExpiresAt = Date.now() + 60_000;
    await firestore.collection("provisioningOperations").doc(operationId).set(conflict.active);
    await firestore.collection("provisioningDispatch").doc(conflict.sourceId).set(conflict.source);
    const conflictingProfile = { ...completedProfile(), provisioningOperationId: otherOperationId };
    await firestore.collection("users").doc("uid-ana").set(conflictingProfile);
    await completeProfileCommit(store, reader, conflict.sourceId);
    assert.equal((await firestore.collection("provisioningOperations").doc(operationId).get()).data()?.status, "manual_recovery");
    assert.deepEqual((await firestore.collection("users").doc("uid-ana").get()).data(), conflictingProfile, "provenance conflict is not overwritten or deleted");

    const recovery = authCreateRecords(true);
    (recovery.active as RecordValue).leaseExpiresAt = Date.now() + 60_000;
    await firestore.collection("provisioningOperations").doc(operationId).set(recovery.active);
    await firestore.collection("provisioningDispatch").doc(recovery.sourceId).set(recovery.source);
    await createAuthUser(store, reader, recovery.sourceId);
    assert.equal((await firestore.collection("provisioningOperations").doc(operationId).get()).data()?.status, "manual_recovery", "persisted call_started reconstructs as ambiguous");
    assert.equal((await firestore.collection("provisioningDispatch").doc(recovery.sourceId).get()).data()?.workerAck, "processed");
    assert.equal((await auth.getUser("uid-ana")).email, "ana@example.com", "reconstruction never deletes the confirmed Auth identity");
  } finally {
    await deleteApp(app);
  }
});

test("P3.51 rolls back Firestore completion when the terminal audit conflicts", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-profile-completion-rollback" }, "p3-profile-completion-rollback");
  try {
    const firestore = getFirestore(app);
    const auth = getAuth(app);
    const store = new FirestoreWorkerStore(firestore);
    const reader = new FirebaseAuthReader(auth);
    const records = profileCommitRecords();
    (records.active as RecordValue).leaseExpiresAt = Date.now() + 60_000;
    const conflictingAudit = { ...profileAudit(records.sourceId, now), code: "internal" };
    await auth.createUser({ uid: "uid-ana", email: "ana@example.com" });
    await firestore.collection("provisioningOperations").doc(operationId).set(records.active);
    await firestore.collection("provisioningDispatch").doc(records.sourceId).set(records.source);
    await firestore.collection("provisioningAudit").doc(conflictingAudit.eventId as string).set(conflictingAudit);
    const before = {
      operation: await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data()),
      dispatch: await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data()),
      profile: await firestore.collection("users").doc("uid-ana").get().then((snapshot) => snapshot.data()),
      audit: await firestore.collection("provisioningAudit").doc(conflictingAudit.eventId as string).get().then((snapshot) => snapshot.data()),
    };

    await assert.rejects(() => completeProfileCommit(store, reader, records.sourceId), /audit identity mismatch/);

    assert.deepEqual(await firestore.collection("provisioningOperations").doc(operationId).get().then((snapshot) => snapshot.data()), before.operation);
    assert.deepEqual(await firestore.collection("provisioningDispatch").doc(records.sourceId).get().then((snapshot) => snapshot.data()), before.dispatch);
    assert.deepEqual(await firestore.collection("users").doc("uid-ana").get().then((snapshot) => snapshot.data()), before.profile);
    assert.deepEqual(await firestore.collection("provisioningAudit").doc(conflictingAudit.eventId as string).get().then((snapshot) => snapshot.data()), before.audit);
  } finally {
    await deleteApp(app);
  }
});
