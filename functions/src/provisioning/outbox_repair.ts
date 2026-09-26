import { createHash } from "node:crypto";
import { FieldPath, type Firestore } from "firebase-admin/firestore";
import { createApplicationLog, type ApplicationLog } from "./audit.ts";
import {
  enqueueAndAcknowledgeDispatch,
  type DispatchAcknowledgementStore,
  type DispatchAcknowledgementTransaction,
  type DispatchValidation,
} from "./outbox.ts";
import type { EnqueueAdapter } from "./enqueue.ts";

export const REPAIR_GRACE_MILLISECONDS = 600_000;
export const REPAIR_PAGE_SIZE = 100;
export const REPAIR_MAX_PAGES = 5;
export const REPAIR_MAX_CONCURRENCY = 10;
export const REPAIR_MAX_ENQUEUES_PER_SECOND = 25;

type DispatchRecord = Record<string, unknown>;

export interface RepairCursor {
  readonly createdAt: number;
  readonly documentId: string;
}

export interface RepairPage {
  readonly records: readonly { readonly documentId: string; readonly dispatch: unknown }[];
  readonly nextCursor: RepairCursor | null;
}

export interface DispatchRepairStore extends DispatchAcknowledgementStore {
  queryStaleDispatches(cutoff: number, cursor: RepairCursor | null, limit: number): Promise<RepairPage>;
}

export interface RepairStaleDispatchesRequest {
  readonly now: number;
  readonly runIdDigest: string;
  readonly enqueue: EnqueueAdapter;
  readonly store: DispatchRepairStore;
  readonly validation: DispatchValidation;
  readonly log: (event: ApplicationLog) => void;
  readonly delay?: (milliseconds: number) => Promise<void>;
}

const DIGEST = /^[a-f0-9]{64}$/;
const defaultDelay = (milliseconds: number): Promise<void> => new Promise((resolve) => setTimeout(resolve, milliseconds));

function digestIdentifier(domain: "provision-dispatch:v1" | "provision-audit:v1", value: unknown): string {
  const identifier = typeof value === "string" ? value : "unknown";
  return createHash("sha256").update(`${domain}\0${identifier}`, "utf8").digest("hex");
}

function logEnqueueFailure(dispatch: unknown, log: (event: ApplicationLog) => void): void {
  const record = typeof dispatch === "object" && dispatch !== null ? dispatch as DispatchRecord : {};
  log(createApplicationLog({
    eventCode: "stale-dispatch",
    resultCode: "internal",
    reasonCode: null,
    digests: [
      { domain: "provision-dispatch:v1", value: digestIdentifier("provision-dispatch:v1", record.dispatchId) },
      { domain: "provision-audit:v1", value: digestIdentifier("provision-audit:v1", record.operationId) },
    ],
  }));
}

/** SDK adapter for the repair core; document ID is the `__name__` cursor tie-breaker. */
export class FirestoreOutboxRepairStore implements DispatchRepairStore {
  private readonly firestore: Firestore;

  constructor(firestore: Firestore) {
    this.firestore = firestore;
  }

  async queryStaleDispatches(cutoff: number, cursor: RepairCursor | null, limit: number): Promise<RepairPage> {
    let query = this.firestore.collection("provisioningDispatch")
      .where("enqueued", "==", false).where("createdAt", "<=", cutoff)
      .orderBy("createdAt").orderBy(FieldPath.documentId()).limit(limit);
    if (cursor !== null) query = query.startAfter(cursor.createdAt, cursor.documentId);
    const snapshot = await query.get();
    const records = snapshot.docs.map((document) => Object.freeze({ documentId: document.id, dispatch: document.data() }));
    const last = records.at(-1);
    return Object.freeze({
      records: Object.freeze(records),
      nextCursor: records.length === limit && last !== undefined
        ? Object.freeze({ createdAt: last.dispatch.createdAt as number, documentId: last.documentId })
        : null,
    });
  }

  async transaction<T>(work: (transaction: DispatchAcknowledgementTransaction) => Promise<T> | T): Promise<T> {
    return this.firestore.runTransaction(async (transaction) => {
      let now = 0;
      const readDispatch = async (dispatchId: string): Promise<DispatchRecord | null> => {
        const snapshot = await transaction.get(this.firestore.collection("provisioningDispatch").doc(dispatchId));
        now = snapshot.readTime.toMillis();
        return snapshot.exists ? snapshot.data() as DispatchRecord : null;
      };
      return work({
        now: () => now,
        readDispatch,
        writeDispatch: (dispatch) => { transaction.set(this.firestore.collection("provisioningDispatch").doc(dispatch.dispatchId as string), dispatch); },
      });
    });
  }
}

/** Bounded, SDK-free repair core. It only delegates queueing and guarded acknowledgement. */
export async function repairStaleDispatches(request: RepairStaleDispatchesRequest): Promise<number> {
  if (!Number.isInteger(request.now) || request.now < REPAIR_GRACE_MILLISECONDS || !DIGEST.test(request.runIdDigest)) throw new Error("invalid repair request");
  const delay = request.delay ?? defaultDelay;
  const cutoff = request.now - REPAIR_GRACE_MILLISECONDS;
  let cursor: RepairCursor | null = null;
  let repaired = 0;
  let inRateWindow = 0;
  for (let page = 0; page < REPAIR_MAX_PAGES; page += 1) {
    const result = await request.store.queryStaleDispatches(cutoff, cursor, REPAIR_PAGE_SIZE);
    if (result.records.length === 0) return repaired;
    let pageFailures = 0;
    for (let start = 0; start < result.records.length;) {
      if (inRateWindow === REPAIR_MAX_ENQUEUES_PER_SECOND) {
        await delay(1_000);
        inRateWindow = 0;
      }
      const batchSize = Math.min(REPAIR_MAX_CONCURRENCY, REPAIR_MAX_ENQUEUES_PER_SECOND - inRateWindow, result.records.length - start);
      const outcomes = await Promise.all(result.records.slice(start, start + batchSize).map(async (record) => {
        try {
          await enqueueAndAcknowledgeDispatch({ dispatch: record.dispatch, eventIdDigest: request.runIdDigest, enqueue: request.enqueue, store: request.store, validation: request.validation, source: "sweeper" });
          return true;
        } catch {
          logEnqueueFailure(record.dispatch, request.log);
          return false;
        }
      }));
      start += batchSize;
      pageFailures += outcomes.filter((outcome) => !outcome).length;
      repaired += outcomes.filter(Boolean).length;
      inRateWindow += batchSize;
    }
    if (pageFailures > 0) throw new Error(`outbox repair failed after ${pageFailures} record failure`);
    if (result.nextCursor === null) return repaired;
    cursor = result.nextCursor;
  }
  return repaired;
}
