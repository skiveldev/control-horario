import assert from "node:assert/strict";
import test from "node:test";
import { createStrictEnqueueFake, type EnqueueAdapter, type EnqueueDispatch } from "../../src/provisioning/enqueue.ts";
import type {
  AuthCreateOutcome,
  AuthCreator,
  AuthIdentity,
  AuthReader,
  WorkerRecord,
  WorkerStore,
  WorkerTransaction,
} from "../../src/provisioning/boundaries.ts";
import { deriveDispatchId, deriveOwnerToken } from "../../src/provisioning/ids.ts";
import { handleCreatedDispatch, type DispatchAcknowledgementStore } from "../../src/provisioning/outbox.ts";
import { isValidDispatch, isValidDispatchUpdate } from "../../src/provisioning/schemas.ts";
import { createProvisioningWorkerRuntime } from "../../src/index.ts";

const operationId = "82ac2574-9e1c-4d72-a6de-55624774f96c";
const fingerprint = "a".repeat(64);
const uid = "uid-ana";
const email = "ana@example.com";
const now = 1_700_000_000_000;

function initialOperation(): WorkerRecord {
  return {
    schemaVersion: 1, operationId, fingerprint,
    normalizedPayload: {
      email, nombre: "Ana", apellido1: "García", apellido2: null, employeeId: "EMP-7", weeklyHours: 40,
      dni: null, telefono: null, cargo: null, departamento: null, empresa: null, scheduleId: null,
      calendarId: null, fechaInicio: null, fechaFin: null, role: "employee", isSupervisor: false, supervisorId: null, isActive: true,
    },
    intendedUid: uid, submittedByDigest: "b".repeat(64), status: "pending", phase: "dispatch_pending",
    generation: 0, version: 0, ownerToken: null, leaseExpiresAt: null, currentDispatchId: null,
    authAttempted: false, authAttempt: null, createdAt: now, updatedAt: now,
  };
}

function initialDispatch(): WorkerRecord {
  const dispatchId = deriveDispatchId(operationId, "acquire", 0, 0);
  return {
    schemaVersion: 1, dispatchId, taskId: dispatchId, operationId, fingerprint, boundary: "acquire",
    generation: 0, sourceVersion: 0, ownerSeed: deriveOwnerToken(dispatchId, 0), enqueued: false,
    enqueuedAt: null, enqueueSource: null, enqueueEventId: null, workerAck: null, workerAckAt: null, createdAt: now,
  };
}

class Store implements WorkerStore, DispatchAcknowledgementStore {
  readonly operations = new Map<string, WorkerRecord>([[operationId, initialOperation()]]);
  readonly dispatches = new Map<string, WorkerRecord>();
  readonly audits = new Map<string, WorkerRecord>();
  readonly profiles = new Map<string, WorkerRecord>();
  /** Number of successful write transactions to survive before a simulated process crash. */
  crashAfterWriteTransactions: number | null = null;
  crashAfterOutboxAcknowledgementOnce = false;

  constructor() { this.dispatches.set(initialDispatch().dispatchId as string, initialDispatch()); }

  async transaction<T>(work: (transaction: WorkerTransaction) => Promise<T>): Promise<T> {
    const operations = new Map(this.operations);
    const dispatches = new Map(this.dispatches);
    const audits = new Map(this.audits);
    const profiles = new Map(this.profiles);
    let wrote = false;
    const transaction: WorkerTransaction = {
      now,
      readOperation: async (id) => operations.get(id) ?? null,
      readDispatch: async (id) => dispatches.get(id) ?? null,
      readAudit: async (id) => audits.get(id) ?? null,
      readProfile: async (id) => profiles.get(id) ?? null,
      writeOperation: (id, value) => { wrote = true; operations.set(id, value); },
      writeDispatch: (id, value) => { wrote = true; dispatches.set(id, value); },
      createDispatch: (id, value) => { wrote = true; if (dispatches.has(id)) throw new Error("dispatch conflict"); dispatches.set(id, value); },
      createAudit: (id, value) => { wrote = true; if (audits.has(id)) throw new Error("audit conflict"); audits.set(id, value); },
      writeProfile: (id, value) => { wrote = true; profiles.set(id, value); },
    };
    const result = await work(transaction);
    this.operations.clear(); this.dispatches.clear(); this.audits.clear(); this.profiles.clear();
    for (const [id, value] of operations) this.operations.set(id, value);
    for (const [id, value] of dispatches) this.dispatches.set(id, value);
    for (const [id, value] of audits) this.audits.set(id, value);
    for (const [id, value] of profiles) this.profiles.set(id, value);
    if (wrote && this.crashAfterWriteTransactions !== null) {
      if (this.crashAfterWriteTransactions === 0) {
        this.crashAfterWriteTransactions = null;
        throw new Error("simulated crash after durable commit");
      }
      this.crashAfterWriteTransactions -= 1;
    }
    return result;
  }

  async outboxTransaction<T>(work: (transaction: { now(): number; readDispatch(id: string): Promise<WorkerRecord | null>; writeDispatch(value: WorkerRecord): void }) => Promise<T> | T): Promise<T> {
    const result = await work({ now: () => now, readDispatch: async (id) => this.dispatches.get(id) ?? null, writeDispatch: (value) => this.dispatches.set(value.dispatchId as string, value) });
    if (this.crashAfterOutboxAcknowledgementOnce) {
      this.crashAfterOutboxAcknowledgementOnce = false;
      throw new Error("simulated crash after outbox acknowledgement");
    }
    return result;
  }
}

class RecordingEnqueue implements EnqueueAdapter {
  readonly delegate = createStrictEnqueueFake();
  readonly calls: EnqueueDispatch[] = [];

  async enqueue(dispatch: EnqueueDispatch): Promise<void> {
    this.calls.push({ ...dispatch });
    await this.delegate.enqueue(dispatch);
  }
}

class Auth implements AuthCreator, AuthReader {
  readonly users = new Map<string, AuthIdentity>();
  creates = 0;
  uidReads = 0;
  emailReads = 0;
  async createUser(requestedUid: string, requestedEmail: string): Promise<AuthCreateOutcome> {
    this.creates += 1;
    const identity = { uid: requestedUid, email: requestedEmail };
    this.users.set(requestedUid, identity);
    return { kind: "created", identity };
  }
  async readByUid(requestedUid: string): Promise<AuthIdentity | null> { this.uidReads += 1; return this.users.get(requestedUid) ?? null; }
  async readByEmail(requestedEmail: string): Promise<AuthIdentity | null> {
    this.emailReads += 1;
    return [...this.users.values()].find((identity) => identity.email === requestedEmail) ?? null;
  }
}

function dispatchId(store: Store, boundary: string): string {
  const dispatch = [...store.dispatches.values()].find((value) => value.boundary === boundary && value.workerAck === null);
  assert.ok(dispatch, `expected unacknowledged ${boundary} dispatch`);
  return dispatch.dispatchId as string;
}

async function enqueueInitial(store: Store, enqueue = new RecordingEnqueue()): Promise<RecordingEnqueue> {
  const source = initialDispatch();
  const outbox: DispatchAcknowledgementStore = { transaction: (work) => store.outboxTransaction(work) };
  await handleCreatedDispatch({ dispatch: source, eventIdDigest: "c".repeat(64), enqueue, store: outbox, validation: { isValidDispatch, isValidDispatchUpdate } });
  assert.equal(store.dispatches.get(source.dispatchId as string)?.enqueued, true);
  return enqueue;
}

test("replays enqueue, Auth intent, and returned Auth proof after durable-commit crashes", async () => {
  const store = new Store();
  const auth = new Auth();
  const runtime = createProvisioningWorkerRuntime({ store, auth });
  const acquire = initialDispatch().dispatchId as string;

  const enqueue = new RecordingEnqueue();
  store.crashAfterOutboxAcknowledgementOnce = true;
  await assert.rejects(() => enqueueInitial(store, enqueue), /simulated crash after outbox acknowledgement/);
  assert.equal(store.dispatches.get(acquire)?.enqueued, true, "enqueue acknowledgement survived its crash");
  await enqueueInitial(store, enqueue);
  assert.equal(enqueue.delegate.enqueueCount, 1, "crash replay has one effective deterministic enqueue");
  assert.equal(enqueue.calls.length, 2, "the trigger was delivered twice around the crash");
  assert.deepEqual(enqueue.calls.map((call) => [call.dispatchId, call.taskId]), [[acquire, acquire], [acquire, acquire]], "both deliveries use the same deterministic task identity");
  await runtime.handleTask({ dispatchId: acquire, retryCount: 0 });
  const preflight = dispatchId(store, "auth_preflight");

  store.crashAfterWriteTransactions = 0;
  await assert.rejects(() => runtime.handleTask({ dispatchId: preflight, retryCount: 0 }), /simulated crash/);
  assert.equal(store.operations.get(operationId)?.phase, "auth_create", "Auth intent survived its crash");
  await runtime.handleTask({ dispatchId: preflight, retryCount: 0 });

  const authCreate = dispatchId(store, "auth_create");
  // The first write commits call_started; the second commits the returned-identity proof.
  store.crashAfterWriteTransactions = 1;
  await assert.rejects(() => runtime.handleTask({ dispatchId: authCreate, retryCount: 0 }), /simulated crash/);
  assert.equal(auth.creates, 1, "the Auth call returned exactly once before proof commit crashed");
  assert.ok(auth.uidReads >= 1 && auth.emailReads >= 1, "both Auth indexes were read before proof commit");
  await runtime.handleTask({ dispatchId: authCreate, retryCount: 0 });
  assert.equal(auth.creates, 1, "proof replay never repeats the Auth create");
  assert.equal(store.operations.get(operationId)?.status, "active", "the committed proof remains usable after restart");
  assert.equal(store.operations.get(operationId)?.phase, "profile_commit");
});

test("reconstructs a call_started crash by reading both Auth indexes without repeating create", async () => {
  const store = new Store();
  const auth = new Auth();
  const runtime = createProvisioningWorkerRuntime({ store, auth });
  await enqueueInitial(store);
  await runtime.handleTask({ dispatchId: initialDispatch().dispatchId as string, retryCount: 0 });
  const preflight = dispatchId(store, "auth_preflight");
  await runtime.handleTask({ dispatchId: preflight, retryCount: 0 });
  const authCreate = dispatchId(store, "auth_create");
  auth.uidReads = 0;
  auth.emailReads = 0;

  store.crashAfterWriteTransactions = 0;
  await assert.rejects(() => runtime.handleTask({ dispatchId: authCreate, retryCount: 0 }), /simulated crash/);
  assert.equal(auth.creates, 0, "call_started commits before the Auth boundary");
  await runtime.handleTask({ dispatchId: authCreate, retryCount: 0 });
  assert.equal(auth.creates, 0, "recovery never guesses by repeating create");
  assert.equal(auth.uidReads, 1, "recovery reads the UID index once");
  assert.equal(auth.emailReads, 1, "recovery reads the email index once");
  assert.equal(store.operations.get(operationId)?.phase, "terminal");
});

test("replays a verified Auth proof and profile completion without duplicating Auth", async () => {
  const store = new Store();
  const auth = new Auth();
  const runtime = createProvisioningWorkerRuntime({ store, auth });
  const acquire = initialDispatch().dispatchId as string;
  await enqueueInitial(store);
  await runtime.handleTask({ dispatchId: acquire, retryCount: 0 });
  const preflight = dispatchId(store, "auth_preflight");
  await runtime.handleTask({ dispatchId: preflight, retryCount: 0 });
  const authCreate = dispatchId(store, "auth_create");
  await runtime.handleTask({ dispatchId: authCreate, retryCount: 0 });
  const profile = dispatchId(store, "profile_commit");

  store.crashAfterWriteTransactions = 0;
  await assert.rejects(() => runtime.handleTask({ dispatchId: profile, retryCount: 0 }), /simulated crash/);
  assert.equal(store.operations.get(operationId)?.status, "completed", "profile/completion commit survived crash");
  await runtime.handleTask({ dispatchId: profile, retryCount: 0 });
  assert.equal(auth.creates, 1, "completion replay never repeats Auth create");
  assert.equal(store.profiles.get(uid)?.provisioningOperationId, operationId);
  assert.equal(store.dispatches.get(profile)?.workerAck, "processed");
});

test("replays reserved retry terminalization after its durable commit crashes", async () => {
  const store = new Store();
  const auth = new Auth();
  const runtime = createProvisioningWorkerRuntime({ store, auth });
  const acquire = initialDispatch().dispatchId as string;
  store.crashAfterWriteTransactions = 0;
  await assert.rejects(() => runtime.handleTask({ dispatchId: acquire, retryCount: 8 }), /simulated crash/);
  const terminal = store.operations.get(operationId)!;
  assert.equal(terminal.status, "failed");
  assert.equal(terminal.phase, "terminal");
  assert.equal((terminal.retryEvidence as { maxRetryCountSeen: number }).maxRetryCountSeen, 8);
  assert.equal(store.dispatches.get(acquire)?.workerAck, "terminalized");
  const stable = structuredClone({ operations: [...store.operations], dispatches: [...store.dispatches], audits: [...store.audits], profiles: [...store.profiles] });
  await runtime.handleTask({ dispatchId: acquire, retryCount: 11 });
  assert.deepEqual({ operations: [...store.operations], dispatches: [...store.dispatches], audits: [...store.audits], profiles: [...store.profiles] }, stable, "terminal replay is completely idempotent");
  assert.equal(auth.creates, 0);
});
