import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import {
  FirestoreOutboxRepairStore,
  repairStaleDispatches,
  type DispatchRepairStore,
  type RepairCursor,
  type RepairPage,
} from "../../src/provisioning/outbox_repair.ts";
import {
  createEnqueueAcknowledgement,
  handleCreatedDispatch,
  type DispatchAcknowledgementTransaction,
} from "../../src/provisioning/outbox.ts";
import { createStrictEnqueueFake, type EnqueueAdapter, type EnqueueDispatch } from "../../src/provisioning/enqueue.ts";
import { createApplicationLog, type ApplicationLog } from "../../src/provisioning/audit.ts";
import { isValidDispatch, isValidDispatchUpdate } from "../../src/provisioning/schemas.ts";

const NOW = 1_000_000;
const RUN_ID = "c".repeat(64);
let assertions = 0;

type PersistedDispatch = EnqueueDispatch & Record<string, unknown> & {
  readonly schemaVersion: 1;
  readonly enqueued: boolean;
  readonly enqueuedAt: number | null;
  readonly enqueueSource: "trigger" | "sweeper" | null;
  readonly enqueueEventId: string | null;
  readonly workerAck: "processed" | "stale" | "terminalized" | null;
  readonly workerAckAt: number | null;
  readonly createdAt: number;
};

function equal(actual: unknown, expected: unknown, message: string): void {
  assertions += 1;
  assert.equal(actual, expected, message);
}

function failOnUnexpectedLog(_event: ApplicationLog): never {
  throw new Error("unexpected application log");
}

function dispatch(index: number, createdAt: number): PersistedDispatch {
  const dispatchId = index.toString(16).padStart(64, "0");
  return {
    schemaVersion: 1,
    dispatchId,
    taskId: dispatchId,
    operationId: `00000000-0000-4000-a000-${index.toString().padStart(12, "0")}`,
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
    createdAt,
  };
}

async function seed(firestore: Firestore, records: readonly Record<string, unknown>[]): Promise<void> {
  for (let start = 0; start < records.length; start += 500) {
    const batch = firestore.batch();
    for (const record of records.slice(start, start + 500)) {
      batch.set(firestore.collection("provisioningDispatch").doc(record.dispatchId as string), record);
    }
    await batch.commit();
  }
}

async function withFirestore(name: string, work: (firestore: Firestore) => Promise<void>): Promise<void> {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST, "Firestore emulator must be running");
  const app = initializeApp({ projectId: name }, name);
  try {
    await work(getFirestore(app));
  } finally {
    await deleteApp(app);
  }
}

class Signal {
  private resolver: (() => void) | null = null;
  readonly promise: Promise<void>;

  constructor() {
    this.promise = new Promise<void>((resolve) => { this.resolver = resolve; });
  }

  release(): void {
    if (this.resolver === null) throw new Error("signal already released");
    const resolve = this.resolver;
    this.resolver = null;
    resolve();
  }
}

function withTimeout<T>(promise: Promise<T>, label: string): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error(`timed out waiting for ${label}`)), 10_000);
    promise.then(
      (value) => { clearTimeout(timer); resolve(value); },
      (error: unknown) => { clearTimeout(timer); reject(error); },
    );
  });
}

class TwoArrivalEnqueue implements EnqueueAdapter {
  readonly arrivals: { readonly source: "trigger" | "sweeper"; readonly dispatch: EnqueueDispatch }[] = [];
  readonly alreadyExistsErrors: unknown[] = [];
  private readonly arrivalsComplete = new Signal();
  private readonly releases = [new Signal(), new Signal()] as const;
  private winner: number | null = null;
  successCount = 0;

  async enqueue(record: EnqueueDispatch): Promise<void> {
    return this.enqueueFrom(record, "trigger");
  }

  forSource(source: "trigger" | "sweeper"): EnqueueAdapter {
    return { enqueue: async (record) => this.enqueueFrom(record, source) };
  }

  private async enqueueFrom(record: EnqueueDispatch, source: "trigger" | "sweeper"): Promise<void> {
    const position = this.arrivals.length;
    if (position >= 2) throw new Error("unexpected third enqueue attempt");
    this.arrivals.push(Object.freeze({ source, dispatch: Object.freeze({ ...record }) }));
    if (position === 1) this.arrivalsComplete.release();
    await this.releases[position].promise;
    if (position !== this.winner) {
      const error = { code: "ALREADY_EXISTS" };
      this.alreadyExistsErrors.push(error);
      throw error;
    }
    this.successCount += 1;
  }

  waitForArrivals(): Promise<void> {
    return this.arrivalsComplete.promise;
  }

  release(position: number): void {
    if (position !== 0 && position !== 1) throw new Error("invalid release position");
    if (this.winner === null) this.winner = position;
    this.releases[position].release();
  }
}

class PartialFailureEnqueue implements EnqueueAdapter {
  readonly arrivals: EnqueueDispatch[] = [];
  private readonly arrivalsComplete = new Signal();
  private readonly successfulRecordRelease = new Signal();
  private readonly failingDispatchId: string;

  constructor(failingDispatchId: string) {
    this.failingDispatchId = failingDispatchId;
  }

  async enqueue(record: EnqueueDispatch): Promise<void> {
    this.arrivals.push(record);
    if (this.arrivals.length === 2) this.arrivalsComplete.release();
    if (record.dispatchId === this.failingDispatchId) throw new Error("synthetic enqueue failure");
    await this.successfulRecordRelease.promise;
  }

  waitForArrivals(): Promise<void> {
    return this.arrivalsComplete.promise;
  }

  releaseSuccessfulRecord(): void {
    this.successfulRecordRelease.release();
  }
}

class AcknowledgementOrderStore implements DispatchRepairStore {
  private readonly delegate: FirestoreOutboxRepairStore;
  private readonly completions = {
    trigger: new Signal(),
    sweeper: new Signal(),
  };
  readonly acknowledgementSources: ("trigger" | "sweeper")[] = [];
  acknowledgementTransactions = 0;

  constructor(firestore: Firestore) {
    this.delegate = new FirestoreOutboxRepairStore(firestore);
  }

  queryStaleDispatches(cutoff: number, cursor: RepairCursor | null, limit: number): Promise<RepairPage> {
    return this.delegate.queryStaleDispatches(cutoff, cursor, limit);
  }

  transaction<T>(work: (transaction: DispatchAcknowledgementTransaction) => Promise<T> | T): Promise<T> {
    this.acknowledgementTransactions += 1;
    return this.delegate.transaction(work);
  }

  forSource(source: "trigger" | "sweeper"): DispatchRepairStore {
    return {
      queryStaleDispatches: (cutoff, cursor, limit) => this.queryStaleDispatches(cutoff, cursor, limit),
      transaction: async <T>(work: (transaction: DispatchAcknowledgementTransaction) => Promise<T> | T): Promise<T> => {
        this.acknowledgementTransactions += 1;
        this.acknowledgementSources.push(source);
        const result = await this.delegate.transaction(work);
        this.completions[source].release();
        return result;
      },
    };
  }

  waitForCompletion(source: "trigger" | "sweeper"): Promise<void> {
    return this.completions[source].promise;
  }
}

await withFirestore("p2-repair-order-test", async (firestore) => {
  const cutoff = NOW - 600_000;
  const exactGrace = dispatch(2, cutoff);
  const sameTimeEarlierName = dispatch(1, cutoff);
  const older = dispatch(3, cutoff - 1);
  const tooRecent = dispatch(4, cutoff + 1);
  await seed(firestore, [exactGrace, sameTimeEarlierName, older, tooRecent]);

  const enqueue = createStrictEnqueueFake();
  const repaired = await repairStaleDispatches({
    now: NOW,
    runIdDigest: RUN_ID,
    enqueue,
    store: new FirestoreOutboxRepairStore(firestore),
    validation: { isValidDispatch, isValidDispatchUpdate },
    log: failOnUnexpectedLog,
    delay: async () => undefined,
  });

  equal(repaired, 3, "the exact ten-minute grace edge is eligible while newer records remain untouched");
  assert.deepEqual(enqueue.enqueued.map((record) => record.dispatchId), [older.dispatchId, sameTimeEarlierName.dispatchId, exactGrace.dispatchId]);
  assertions += 1;
  const recent = await firestore.collection("provisioningDispatch").doc(tooRecent.dispatchId as string).get();
  equal(recent.data()?.enqueued, false, "a record inside the grace window is not acknowledged");
  const acknowledged = await firestore.collection("provisioningDispatch").doc(exactGrace.dispatchId as string).get();
  equal(acknowledged.data()?.enqueueSource, "sweeper", "the shared guarded acknowledgement records sweeper provenance");
});

await withFirestore("p2-repair-bounds-test", async (firestore) => {
  await seed(firestore, Array.from({ length: 501 }, (_, index) => dispatch(index + 10, 0)));
  let active = 0;
  let maximumActive = 0;
  let enqueueCount = 0;
  const delays: number[] = [];
  const enqueue: EnqueueAdapter = {
    async enqueue(_record: EnqueueDispatch): Promise<void> {
      active += 1;
      maximumActive = Math.max(maximumActive, active);
      await Promise.resolve();
      enqueueCount += 1;
      active -= 1;
    },
  };

  const repaired = await repairStaleDispatches({
    now: NOW,
    runIdDigest: RUN_ID,
    enqueue,
    store: new FirestoreOutboxRepairStore(firestore),
    validation: { isValidDispatch, isValidDispatchUpdate },
    log: failOnUnexpectedLog,
    delay: async (milliseconds) => { delays.push(milliseconds); },
  });

  equal(repaired, 500, "the sweeper stops after five pages of one hundred records");
  equal(enqueueCount, 500, "only the bounded records are sent through the shared enqueue adapter");
  equal(maximumActive, 10, "enqueue work never exceeds ten concurrent calls");
  equal(delays.length, 19, "the rate limiter separates twenty twenty-five-enqueue windows");
  assert.ok(delays.every((milliseconds) => milliseconds === 1_000), "each rate-limit wait is one second");
  assertions += 1;
  const remaining = await firestore.collection("provisioningDispatch").where("enqueued", "==", false).get();
  equal(remaining.size, 1, "cursor pagination leaves the sixth page for a future bounded run");
});

await withFirestore("p2-repair-forbidden-operations-test", async (firestore) => {
  const staleDispatch: PersistedDispatch = {
    ...dispatch(600, 0),
    workerAck: "processed",
    workerAckAt: NOW - 1,
  };
  const operation = { status: "active", phase: "auth_create", version: 7 };
  const profile = { userId: "protected-user", provisioningOperationId: staleDispatch.operationId };
  await seed(firestore, [staleDispatch]);
  await firestore.collection("provisioningOperations").doc(staleDispatch.operationId as string).set(operation);
  await firestore.collection("users").doc("protected-user").set(profile);

  const projected = createEnqueueAcknowledgement(staleDispatch, NOW, "sweeper", RUN_ID);
  equal(projected.dispatchId, staleDispatch.dispatchId, "an acknowledgement retains the canonical dispatch identity");
  equal(projected.taskId, staleDispatch.taskId, "an acknowledgement retains the canonical task identity");
  equal(projected.workerAck, "processed", "an enqueue acknowledgement cannot replace a worker acknowledgement");
  equal(projected.workerAckAt, NOW - 1, "an enqueue acknowledgement retains the worker acknowledgement timestamp");

  const enqueue = createStrictEnqueueFake();
  const repaired = await repairStaleDispatches({
    now: NOW,
    runIdDigest: RUN_ID,
    enqueue,
    store: new FirestoreOutboxRepairStore(firestore),
    validation: { isValidDispatch, isValidDispatchUpdate },
    log: failOnUnexpectedLog,
    delay: async () => undefined,
  });

  equal(repaired, 1, "the sweeper repairs the existing stale dispatch without creating follow-up work");
  equal(enqueue.enqueued.length, 1, "the sweeper delegates one enqueue through the shared adapter");
  equal(enqueue.enqueued[0]?.dispatchId, staleDispatch.dispatchId, "the shared adapter receives the persisted dispatch identity");
  equal(enqueue.enqueued[0]?.taskId, staleDispatch.taskId, "the shared adapter receives the persisted task identity");
  const persistedDispatches = await firestore.collection("provisioningDispatch").get();
  equal(persistedDispatches.size, 1, "the sweeper does not create another dispatch record");
  const persisted = persistedDispatches.docs[0]?.data();
  equal(persisted?.workerAck, "processed", "the sweeper does not acknowledge worker completion");
  equal(persisted?.workerAckAt, NOW - 1, "the sweeper preserves the worker acknowledgement timestamp");
  assert.deepEqual((await firestore.collection("provisioningOperations").doc(staleDispatch.operationId as string).get()).data(), operation, "the sweeper does not mutate operation state");
  assertions += 1;
  assert.deepEqual((await firestore.collection("users").doc("protected-user").get()).data(), profile, "the sweeper does not mutate profile state");
  assertions += 1;
});

for (const race of [
  { name: "trigger acknowledgement first", firstSource: "trigger" },
  { name: "sweeper acknowledgement first", firstSource: "sweeper" },
] as const) {
  await withFirestore(`p2-repair-race-${race.firstSource}`, async (firestore) => {
    const staleDispatch = dispatch(700 + (race.firstSource === "trigger" ? 0 : 1), 0);
    await seed(firestore, [staleDispatch]);
    const enqueue = new TwoArrivalEnqueue();
    const store = new AcknowledgementOrderStore(firestore);

    const trigger = handleCreatedDispatch({
      dispatch: staleDispatch,
      eventIdDigest: "e".repeat(64),
      enqueue: enqueue.forSource("trigger"),
      store: store.forSource("trigger"),
      validation: { isValidDispatch, isValidDispatchUpdate },
    });
    const sweeper = repairStaleDispatches({
      now: NOW,
      runIdDigest: RUN_ID,
      enqueue: enqueue.forSource("sweeper"),
      store: store.forSource("sweeper"),
      validation: { isValidDispatch, isValidDispatchUpdate },
      log: failOnUnexpectedLog,
      delay: async () => undefined,
    });

    await withTimeout(enqueue.waitForArrivals(), `${race.name} enqueue arrivals`);
    equal(enqueue.arrivals.length, 2, `${race.name} starts both enqueue attempts before awaiting either`);
    equal(enqueue.arrivals[0]?.dispatch.dispatchId, staleDispatch.dispatchId, `${race.name} preserves the first canonical dispatch identity`);
    equal(enqueue.arrivals[1]?.dispatch.dispatchId, staleDispatch.dispatchId, `${race.name} preserves the second canonical dispatch identity`);
    equal(enqueue.arrivals[0]?.dispatch.taskId, enqueue.arrivals[1]?.dispatch.taskId, `${race.name} uses identical deterministic task identities`);

    const winnerPosition = enqueue.arrivals.findIndex((arrival) => arrival.source === race.firstSource);
    assert.notEqual(winnerPosition, -1, `${race.name} has a controlled enqueue arrival`);
    assertions += 1;
    enqueue.release(winnerPosition);
    await withTimeout(store.waitForCompletion(race.firstSource), `${race.name} first acknowledgement`);
    enqueue.release(1 - winnerPosition);
    await withTimeout(Promise.all([trigger, sweeper]), `${race.name} completion`);

    equal(enqueue.successCount, 1, `${race.name} performs one enqueue side effect`);
    equal(enqueue.alreadyExistsErrors.length, 1, `${race.name} observes one ALREADY_EXISTS enqueue result`);
    equal((enqueue.alreadyExistsErrors[0] as { code?: unknown }).code, "ALREADY_EXISTS", `${race.name} preserves the accepted enqueue error code`);
    equal(store.acknowledgementTransactions, 2, `${race.name} reaches both guarded acknowledgement paths`);
    equal(store.acknowledgementSources[0], race.firstSource, `${race.name} controls the first guarded acknowledgement`);
    const persisted = await firestore.collection("provisioningDispatch").doc(staleDispatch.dispatchId).get();
    equal(persisted.data()?.enqueued, true, `${race.name} converges the shared dispatch to enqueued`);
    equal(persisted.data()?.enqueueSource, race.firstSource, `${race.name} keeps the controlled first acknowledgement provenance`);
    equal(persisted.data()?.taskId, staleDispatch.taskId, `${race.name} retains the deterministic task identity after acknowledgement`);
  });
}

await withFirestore("p2-repair-partial-failure-test", async (firestore) => {
  const failedDispatch = dispatch(802, 0);
  const successfulDispatch = dispatch(803, 0);
  await seed(firestore, [failedDispatch, successfulDispatch]);
  const enqueue = new PartialFailureEnqueue(failedDispatch.dispatchId);
  const logs: ApplicationLog[] = [];
  const repair = repairStaleDispatches({
    now: NOW,
    runIdDigest: RUN_ID,
    enqueue,
    store: new FirestoreOutboxRepairStore(firestore),
    validation: { isValidDispatch, isValidDispatchUpdate },
    log: (event) => { logs.push(event); },
    delay: async () => undefined,
  });
  let settled = false;
  void repair.then(() => { settled = true; }, () => { settled = true; });
  await withTimeout(enqueue.waitForArrivals(), "partial-failure enqueue arrivals");
  await new Promise<void>((resolve) => setTimeout(resolve, 25));
  equal(settled, false, "a failed record does not end the repair run before its bounded peer finishes");

  enqueue.releaseSuccessfulRecord();
  await assert.rejects(repair, /outbox repair failed after 1 record failure/);
  assertions += 1;

  equal((await firestore.collection("provisioningDispatch").doc(successfulDispatch.dispatchId).get()).data()?.enqueued, true, "a successful peer is acknowledged before the run reports its failure");
  equal((await firestore.collection("provisioningDispatch").doc(failedDispatch.dispatchId).get()).data()?.enqueued, false, "a failed record remains eligible for a future repair run");
  equal(logs.length, 1, "each failed record emits one required safe application log");
  const expectedLog = createApplicationLog({
    eventCode: "stale-dispatch",
    resultCode: "internal",
    reasonCode: null,
    digests: [
      { domain: "provision-dispatch:v1", value: createHash("sha256").update(`provision-dispatch:v1\0${failedDispatch.dispatchId}`, "utf8").digest("hex") },
      { domain: "provision-audit:v1", value: createHash("sha256").update(`provision-audit:v1\0${failedDispatch.operationId}`, "utf8").digest("hex") },
    ],
  });
  assert.deepEqual(logs[0], expectedLog, "the failure log uses the exact bounded application-log shape");
  assertions += 1;
  assert.ok(!JSON.stringify(logs).includes(failedDispatch.operationId));
  assertions += 1;
});

console.log(`OK: scheduled outbox repair ${assertions} assertions`);
