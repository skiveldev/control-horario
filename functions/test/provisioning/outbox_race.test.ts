import assert from "node:assert/strict";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { createStrictEnqueueFake, type EnqueueAdapter, type EnqueueDispatch } from "../../src/provisioning/enqueue.ts";
import {
  handleCreatedDispatch,
  type DispatchAcknowledgementStore,
  type DispatchAcknowledgementTransaction,
} from "../../src/provisioning/outbox.ts";
import { FirestoreOutboxRepairStore, repairStaleDispatches } from "../../src/provisioning/outbox_repair.ts";
import { isValidDispatch, isValidDispatchUpdate } from "../../src/provisioning/schemas.ts";

const EVENT_A = "a".repeat(64);
const EVENT_B = "b".repeat(64);
const RUN_ID = "c".repeat(64);
let assertions = 0;

function equal(actual: unknown, expected: unknown, message: string): void {
  assertions += 1;
  assert.equal(actual, expected, message);
}

function dispatch(index = 1): Record<string, unknown> {
  const dispatchId = index.toString(16).padStart(64, "0");
  return {
    schemaVersion: 1,
    dispatchId,
    taskId: dispatchId,
    operationId: `00000000-0000-4000-a000-${index.toString().padStart(12, "0")}`,
    fingerprint: "d".repeat(64),
    boundary: "acquire",
    generation: 0,
    sourceVersion: 0,
    ownerSeed: "e".repeat(64),
    enqueued: false,
    enqueuedAt: null,
    enqueueSource: null,
    enqueueEventId: null,
    workerAck: null,
    workerAckAt: null,
    createdAt: 0,
  };
}

class MemoryStore implements DispatchAcknowledgementStore {
  record: Record<string, unknown>;
  failAcknowledgement = false;

  constructor(record: Record<string, unknown>) {
    this.record = { ...record };
  }

  async transaction<T>(work: (transaction: DispatchAcknowledgementTransaction) => Promise<T> | T): Promise<T> {
    if (this.failAcknowledgement) {
      this.failAcknowledgement = false;
      throw new Error("simulated acknowledgement crash");
    }
    return work({
      now: () => 123,
      readDispatch: async (dispatchId) => dispatchId === this.record.dispatchId ? { ...this.record } : null,
      writeDispatch: async (next) => { this.record = { ...next }; },
    });
  }
}

async function trigger(store: DispatchAcknowledgementStore, enqueue: EnqueueAdapter, eventIdDigest = EVENT_A, record = dispatch()): Promise<void> {
  await handleCreatedDispatch({
    dispatch: record,
    eventIdDigest,
    enqueue,
    store,
    validation: { isValidDispatch, isValidDispatchUpdate },
  });
}

class FirstSuccessThenAlreadyExists implements EnqueueAdapter {
  calls = 0;

  async enqueue(_record: EnqueueDispatch): Promise<void> {
    this.calls += 1;
    if (this.calls > 1) throw Object.assign(new Error("task exists"), { code: "ALREADY_EXISTS" });
  }
}

class ConcurrentEnqueueBarrier implements EnqueueAdapter {
  calls = 0;
  private release!: () => void;
  private readonly released = new Promise<void>((resolve) => { this.release = resolve; });
  private arrivals!: () => void;
  private readonly bothArrived = new Promise<void>((resolve) => { this.arrivals = resolve; });

  async enqueue(_record: EnqueueDispatch): Promise<void> {
    this.calls += 1;
    if (this.calls === 2) this.arrivals();
    await this.bothArrived;
    await this.released;
  }

  async releaseAfterBothArrive(): Promise<void> {
    await this.bothArrived;
    this.release();
  }
}

{
  const store = new MemoryStore(dispatch());
  const enqueue = createStrictEnqueueFake();
  await trigger(store, enqueue);
  await trigger(store, enqueue);
  equal(enqueue.enqueueCount, 1, "duplicate created delivery has one deterministic queue effect");
  equal(store.record.enqueueEventId, EVENT_A, "duplicate created delivery preserves its acknowledgement identity");

  await trigger(store, enqueue, EVENT_B);
  equal(store.record.enqueueEventId, EVENT_A, "late out-of-order delivery cannot overwrite acknowledgement identity");
  equal(store.record.enqueueSource, "trigger", "late out-of-order delivery cannot overwrite acknowledgement provenance");
}

{
  const store = new MemoryStore(dispatch(2));
  const enqueue: EnqueueAdapter = { enqueue: async () => { throw new Error("simulated queue crash"); } };
  await assert.rejects(() => trigger(store, enqueue, EVENT_A, store.record), /simulated queue crash/, "crash before enqueue acknowledgement is surfaced");
  assertions += 1;
  equal(store.record.enqueued, false, "crash before enqueue leaves durable recovery eligibility");
}

{
  const store = new MemoryStore(dispatch(3));
  const enqueue = createStrictEnqueueFake();
  store.failAcknowledgement = true;
  await assert.rejects(() => trigger(store, enqueue, EVENT_A, store.record), /simulated acknowledgement crash/, "crash after queue success is surfaced for retry");
  assertions += 1;
  equal(store.record.enqueued, false, "crash after queue success leaves the acknowledgement pending");
  await trigger(store, enqueue, EVENT_A, store.record);
  equal(enqueue.enqueueCount, 1, "retry after acknowledgement crash reuses the deterministic task identity");
  equal(store.record.enqueued, true, "retry after acknowledgement crash converges the durable acknowledgement");
}

{
  const store = new MemoryStore(dispatch(4));
  const enqueue = new FirstSuccessThenAlreadyExists();
  await trigger(store, enqueue, EVENT_A, store.record);
  store.record = { ...dispatch(4), enqueued: false, enqueuedAt: null, enqueueSource: null, enqueueEventId: null };
  await trigger(store, enqueue, EVENT_B, store.record);
  equal(enqueue.calls, 2, "ALREADY_EXISTS is observed for the same deterministic task identity");
  equal(store.record.enqueued, true, "ALREADY_EXISTS is accepted as successful enqueue and acknowledged");
  equal(store.record.enqueueEventId, EVENT_B, "accepted ALREADY_EXISTS commits the guarded acknowledgement identity");
}

{
  const store = new MemoryStore(dispatch(5));
  const enqueue = createStrictEnqueueFake();
  await assert.rejects(
    () => trigger(store, enqueue, EVENT_A, { ...store.record, fingerprint: "f".repeat(64) }),
    /identity mismatch/,
    "incompatible persisted identity reuse fails closed",
  );
  assertions += 1;
  equal(enqueue.enqueueCount, 1, "incompatible identity is rejected after no alternative task is accepted");
  equal(store.record.enqueued, false, "incompatible identity reuse cannot corrupt durable acknowledgement");
}

async function withFirestore(name: string, work: (firestore: Firestore) => Promise<void>): Promise<void> {
  const app = initializeApp({ projectId: name }, name);
  try {
    await work(getFirestore(app));
  } finally {
    await deleteApp(app);
  }
}

if (process.env.FIRESTORE_EMULATOR_HOST !== undefined) {
  await withFirestore("p3-outbox-race", async (firestore) => {
    const stale = dispatch(6);
    await firestore.collection("provisioningDispatch").doc(stale.dispatchId as string).set(stale);
    const enqueue = new ConcurrentEnqueueBarrier();
    const store = new FirestoreOutboxRepairStore(firestore);

    const race = Promise.all([
      trigger(store, enqueue, EVENT_A, stale),
      repairStaleDispatches({
        now: 600_000,
        runIdDigest: RUN_ID,
        enqueue,
        store,
        validation: { isValidDispatch, isValidDispatchUpdate },
        log: () => undefined,
        delay: async () => undefined,
      }),
    ]);
    await enqueue.releaseAfterBothArrive();
    await race;

    const persisted = (await firestore.collection("provisioningDispatch").doc(stale.dispatchId as string).get()).data();
    equal(enqueue.calls, 2, "trigger and sweeper both reach the deterministic queue identity during the persisted race");
    equal(persisted?.enqueued, true, "trigger and sweeper converge through a persisted guarded acknowledgement");
    assert.ok(persisted?.enqueueSource === "trigger" || persisted?.enqueueSource === "sweeper", "the guarded winner records one valid provenance");
    assertions += 1;
    assert.ok(persisted?.enqueueEventId === EVENT_A || persisted?.enqueueEventId === RUN_ID, "the guarded winner records one immutable acknowledgement identity");
    assertions += 1;
  });
} else {
  console.log("SKIP: Firestore race requires FIRESTORE_EMULATOR_HOST");
}

console.log(`OK: outbox race ${assertions} assertions`);
