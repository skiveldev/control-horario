import { strict as assert } from "node:assert";
import { createHash } from "node:crypto";
import {
  createProvisioningOutboxRuntime,
  provisioningDispatchCreated,
  provisioningOutboxRepair,
} from "../../src/index.ts";
import {
  handleCreatedDispatch,
  type DispatchAcknowledgementStore,
  type DispatchAcknowledgementTransaction,
} from "../../src/provisioning/outbox.ts";
import { createStrictEnqueueFake, type EnqueueAdapter, type EnqueueDispatch } from "../../src/provisioning/enqueue.ts";
import { isValidDispatch, isValidDispatchUpdate } from "../../src/provisioning/schemas.ts";
import type { DispatchRepairStore, RepairCursor, RepairPage } from "../../src/provisioning/outbox_repair.ts";

const dispatch = (): Record<string, unknown> => ({
  schemaVersion: 1,
  dispatchId: "d".repeat(64),
  taskId: "d".repeat(64),
  operationId: "00000000-0000-4000-a000-000000000301",
  fingerprint: "a".repeat(64),
  boundary: "acquire",
  generation: 0,
  sourceVersion: 0,
  ownerSeed: "b".repeat(64),
  enqueued: false,
  enqueuedAt: null,
  enqueueSource: null,
  enqueueEventId: null,
  workerAck: null,
  workerAckAt: null,
  createdAt: 1,
});

class MemoryAcknowledgementStore implements DispatchAcknowledgementStore {
  dispatch: Record<string, unknown>;
  failNextTransaction = false;

  constructor(initial: Record<string, unknown>) {
    this.dispatch = { ...initial };
  }

  async transaction<T>(work: (transaction: DispatchAcknowledgementTransaction) => Promise<T> | T): Promise<T> {
    if (this.failNextTransaction) {
      this.failNextTransaction = false;
      throw new Error("ack unavailable");
    }
    const transaction: DispatchAcknowledgementTransaction = {
      now: () => 42,
      readDispatch: async (dispatchId) => dispatchId === this.dispatch.dispatchId ? { ...this.dispatch } : null,
      writeDispatch: async (next) => { this.dispatch = { ...next }; },
    };
    return work(transaction);
  }
}

class RepairMemoryStore extends MemoryAcknowledgementStore implements DispatchRepairStore {
  readonly queries: { readonly cutoff: number; readonly cursor: RepairCursor | null; readonly limit: number }[] = [];
  private readonly candidates: readonly Record<string, unknown>[];

  constructor(stale: Record<string, unknown>, candidates: readonly Record<string, unknown>[]) {
    super(stale);
    this.candidates = candidates;
  }

  async queryStaleDispatches(cutoff: number, cursor: RepairCursor | null, limit: number): Promise<RepairPage> {
    this.queries.push(Object.freeze({ cutoff, cursor, limit }));
    const records = cursor === null
      ? this.candidates
        .filter((candidate) => candidate.enqueued === false && (candidate.createdAt as number) <= cutoff)
        .map((candidate) => Object.freeze({ documentId: candidate.dispatchId as string, dispatch: candidate }))
      : [];
    return Object.freeze({ records: Object.freeze(records), nextCursor: null });
  }
}

const eventIdDigest = "c".repeat(64);

async function dispatchCreated(
  store: DispatchAcknowledgementStore,
  enqueue: EnqueueAdapter,
  created = dispatch(),
): Promise<void> {
  await handleCreatedDispatch({
    dispatch: created,
    eventIdDigest,
    enqueue,
    store,
    validation: { isValidDispatch, isValidDispatchUpdate },
  });
}

{
  const store = new MemoryAcknowledgementStore(dispatch());
  const enqueue = createStrictEnqueueFake();

  await dispatchCreated(store, enqueue);

  assert.equal(enqueue.enqueueCount, 1, "a valid created dispatch is sent through the shared enqueue adapter");
  assert.equal(store.dispatch.enqueued, true, "enqueue success is acknowledged");
  assert.equal(store.dispatch.enqueuedAt, 42, "the acknowledgement uses transaction time");
  assert.equal(store.dispatch.enqueueSource, "trigger", "the trigger owns its acknowledgement provenance");
  assert.equal(store.dispatch.enqueueEventId, eventIdDigest, "the acknowledgement records the immutable event digest");

  await dispatchCreated(store, enqueue);
  assert.equal(enqueue.enqueueCount, 1, "a duplicate created event does not create a second observable enqueue");
  assert.equal(store.dispatch.enqueueEventId, eventIdDigest, "a duplicate trigger does not rewrite acknowledgement provenance");
}

{
  const store = new MemoryAcknowledgementStore(dispatch());
  store.failNextTransaction = true;
  const enqueue = createStrictEnqueueFake();

  await assert.rejects(() => dispatchCreated(store, enqueue), /ack unavailable/, "a crash before acknowledgement remains retryable");
  assert.equal(enqueue.enqueueCount, 1, "the first attempt reaches the queue before its acknowledgement failure");
  assert.equal(store.dispatch.enqueued, false, "a failed acknowledgement leaves the dispatch unacknowledged");

  await dispatchCreated(store, enqueue);
  assert.equal(enqueue.enqueueCount, 1, "the retry reuses the deterministic dispatch identity");
  assert.equal(store.dispatch.enqueued, true, "the retry acknowledges the previously enqueued task");
}

{
  const store = new MemoryAcknowledgementStore(dispatch());
  let enqueueCalls = 0;
  const alreadyExists: EnqueueAdapter = {
    async enqueue(_dispatch: EnqueueDispatch): Promise<void> {
      enqueueCalls += 1;
      throw Object.assign(new Error("task already exists"), { code: "ALREADY_EXISTS" });
    },
  };

  await dispatchCreated(store, alreadyExists);
  assert.equal(enqueueCalls, 1, "ALREADY_EXISTS is accepted as deterministic enqueue success");
  assert.equal(store.dispatch.enqueued, true, "ALREADY_EXISTS is followed by guarded acknowledgement");
}

{
  const store = new MemoryAcknowledgementStore(dispatch());
  const enqueue = createStrictEnqueueFake();

  await assert.rejects(
    () => dispatchCreated(store, enqueue, { ...dispatch(), taskId: "e".repeat(64) }),
    /invalid dispatch/,
    "an invalid immutable dispatch fails before queue interaction",
  );
  assert.equal(enqueue.enqueueCount, 0, "an invalid immutable dispatch cannot enqueue a task");
}

{
  const created = dispatch();
  const store = new MemoryAcknowledgementStore({ ...created, fingerprint: "e".repeat(64) });
  const enqueue = createStrictEnqueueFake();

  await assert.rejects(() => dispatchCreated(store, enqueue, created), /identity mismatch/, "acknowledgement requires the exact dispatch identity read from the event");
  assert.equal(store.dispatch.enqueued, false, "an identity mismatch cannot acknowledge a different dispatch record");
}

{
  const store = new MemoryAcknowledgementStore({
    ...dispatch(),
    enqueued: true,
    enqueuedAt: 9,
    enqueueSource: "sweeper",
    enqueueEventId: "e".repeat(64),
  });
  let enqueueCalls = 0;
  const alreadyExists: EnqueueAdapter = {
    async enqueue(_dispatch: EnqueueDispatch): Promise<void> {
      enqueueCalls += 1;
      throw Object.assign(new Error("task already exists"), { code: "ALREADY_EXISTS" });
    },
  };

  await dispatchCreated(store, alreadyExists);
  assert.equal(enqueueCalls, 1, "a trigger racing an already-enqueued sweeper task accepts deterministic task reuse");
  assert.equal(store.dispatch.enqueueSource, "sweeper", "the losing acknowledgement preserves the winning sweeper provenance");
  assert.equal(store.dispatch.enqueueEventId, "e".repeat(64), "the losing acknowledgement does not rewrite the winning event identity");
}

{
  const store = new MemoryAcknowledgementStore(dispatch());
  const enqueue = createStrictEnqueueFake();
  const runtime = createProvisioningOutboxRuntime({
    enqueue,
    store,
    validation: { isValidDispatch, isValidDispatchUpdate },
    log: () => undefined,
    now: () => 99,
  });

  await runtime.handleCreated({ dispatch: dispatch(), eventId: "created-event" });
  assert.equal(enqueue.enqueueCount, 1, "the created endpoint composes the shared enqueue seam");
  assert.equal(store.dispatch.enqueued, true, "the created endpoint composes guarded acknowledgement");
  assert.equal(store.dispatch.enqueueSource, "trigger", "the created endpoint retains trigger-only provenance");
}

{
  const stale: Record<string, unknown> = { ...dispatch(), createdAt: 42 };
  const fresh: Record<string, unknown> = { ...dispatch(), dispatchId: "e".repeat(64), taskId: "e".repeat(64), createdAt: 43 };
  const store = new RepairMemoryStore(stale, [stale, fresh]);
  const enqueue = createStrictEnqueueFake();
  const runtime = createProvisioningOutboxRuntime({
    enqueue,
    store,
    repairStore: store,
    validation: { isValidDispatch, isValidDispatchUpdate },
    log: () => undefined,
    now: () => 600_042,
  });

  const repaired = await runtime.repair("scheduler-run-42");
  const expectedRunDigest = createHash("sha256")
    .update("provision-outbox-repair:v1\0scheduler-run-42", "utf8")
    .digest("hex");

  assert.equal(repaired, 1, "the scheduled runtime reports the one selected stale dispatch as repaired");
  assert.deepEqual(store.queries, [{ cutoff: 42, cursor: null, limit: 100 }], "the runtime forwards its clock to the stale-dispatch repair seam");
  assert.deepEqual(enqueue.enqueued.map((record) => record.dispatchId), [stale.dispatchId], "the repair seam selects only the stale dispatch for the shared enqueue adapter");
  assert.equal(store.dispatch.enqueued, true, "scheduled repair commits the guarded acknowledgement");
  assert.equal(store.dispatch.enqueuedAt, 42, "scheduled repair acknowledgement uses transaction time");
  assert.equal(store.dispatch.enqueueSource, "sweeper", "scheduled repair records sweeper provenance");
  assert.equal(store.dispatch.enqueueEventId, expectedRunDigest, "scheduled repair derives its deterministic acknowledgement digest from the scheduler run identity");
}

{
  assert.equal(provisioningDispatchCreated.__endpoint.eventTrigger?.retry, true, "the exported created-dispatch endpoint retains retry-enabled delivery");
  const schedule = provisioningOutboxRepair.__endpoint.scheduleTrigger;
  assert.ok(schedule, "the exported repair endpoint retains scheduler metadata");
  assert.equal(schedule.schedule, "every 5 minutes", "the exported repair endpoint runs every five minutes");
  assert.equal(schedule.retryConfig?.retryCount, 3, "the exported repair endpoint retries three times");
  assert.equal(schedule.retryConfig?.minBackoffSeconds, 30, "the exported repair endpoint has a 30-second minimum backoff");
  assert.equal(schedule.retryConfig?.maxBackoffSeconds, 300, "the exported repair endpoint has a 300-second maximum backoff");
  assert.equal(schedule.retryConfig?.maxDoublings, 2, "the exported repair endpoint permits two backoff doublings");
  assert.equal(provisioningOutboxRepair.__endpoint.maxInstances, 1, "the exported repair endpoint permits one instance");
  assert.equal(provisioningOutboxRepair.__endpoint.timeoutSeconds, 240, "the exported repair endpoint has a 240-second timeout");
}

console.log("OK: created outbox trigger and scheduled repair composition assertions");

{
  const store = new MemoryAcknowledgementStore(dispatch());
  const enqueue = createStrictEnqueueFake();
  const beforeEnqueue = structuredClone(store.dispatch);

  assert.deepEqual(store.dispatch, beforeEnqueue, "P3.15a before enqueue preserves the durable dispatch");
  store.failNextTransaction = true;
  await assert.rejects(() => dispatchCreated(store, enqueue), /ack unavailable/);
  assert.equal(enqueue.enqueueCount, 1, "P3.15a after enqueue before acknowledgement records one deterministic task");
  assert.deepEqual(store.dispatch, beforeEnqueue, "P3.15a after enqueue before acknowledgement leaves durable acknowledgement pending");

  await dispatchCreated(store, enqueue);
  assert.equal(enqueue.enqueueCount, 1, "P3.15a enqueue replay reuses the existing task");
  assert.equal(store.dispatch.enqueued, true, "P3.15a enqueue replay commits the guarded acknowledgement");
}
