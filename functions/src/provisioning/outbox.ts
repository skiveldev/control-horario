import type { EnqueueAdapter, EnqueueDispatch } from "./enqueue.ts";

const DIGEST = /^[a-f0-9]{64}$/;
const IDENTITY_FIELDS = [
  "schemaVersion",
  "dispatchId",
  "taskId",
  "operationId",
  "fingerprint",
  "boundary",
  "generation",
  "sourceVersion",
  "ownerSeed",
  "createdAt",
] as const;

type DispatchRecord = Record<string, unknown>;
export type EnqueueSource = "trigger" | "sweeper";

export interface DispatchAcknowledgementTransaction {
  now(): number;
  readDispatch(dispatchId: string): Promise<DispatchRecord | null>;
  writeDispatch(dispatch: DispatchRecord): void | Promise<void>;
}

/** Injectable persistence boundary for the guarded outbox acknowledgement transaction. */
export interface DispatchAcknowledgementStore {
  transaction<T>(work: (transaction: DispatchAcknowledgementTransaction) => Promise<T> | T): Promise<T>;
}

/** Immutable dispatch guards supplied by the schema composition boundary. */
export interface DispatchValidation {
  isValidDispatch(value: unknown): boolean;
  isValidDispatchUpdate(previous: unknown, next: unknown): boolean;
}

export interface CreatedDispatchRequest {
  readonly dispatch: unknown;
  readonly eventIdDigest: string;
  readonly enqueue: EnqueueAdapter;
  readonly store: DispatchAcknowledgementStore;
  readonly validation: DispatchValidation;
}

/** Shared enqueue and guarded-acknowledgement boundary used by trigger and repair paths. */
export interface EnqueueDispatchRequest extends CreatedDispatchRequest {
  readonly source: EnqueueSource;
}

function toEnqueueDispatch(dispatch: DispatchRecord): EnqueueDispatch {
  return {
    dispatchId: dispatch.dispatchId as string,
    taskId: dispatch.taskId as string,
    operationId: dispatch.operationId as string,
    fingerprint: dispatch.fingerprint as string,
    boundary: dispatch.boundary as string,
    generation: dispatch.generation as number,
    sourceVersion: dispatch.sourceVersion as number,
    ownerSeed: dispatch.ownerSeed as string,
  };
}

function hasExactIdentity(current: DispatchRecord, expected: DispatchRecord): boolean {
  return IDENTITY_FIELDS.every((field) => current[field] === expected[field]);
}

function isAlreadyExists(error: unknown): boolean {
  try {
    const code = typeof error === "object" && error !== null ? (error as { code?: unknown }).code : undefined;
    return code === "ALREADY_EXISTS" || code === 6;
  } catch {
    return false;
  }
}

/** Builds the sole dispatch mutation that enqueue repair is permitted to make. */
export function createEnqueueAcknowledgement(
  dispatch: DispatchRecord,
  enqueuedAt: number,
  source: EnqueueSource,
  eventIdDigest: string,
): DispatchRecord {
  return {
    ...dispatch,
    enqueued: true,
    enqueuedAt,
    enqueueSource: source,
    enqueueEventId: eventIdDigest,
  };
}

async function acknowledgeEnqueuedDispatch(
  dispatch: DispatchRecord,
  eventIdDigest: string,
  source: EnqueueSource,
  store: DispatchAcknowledgementStore,
  validation: DispatchValidation,
): Promise<void> {
  await store.transaction(async (transaction) => {
    const current = await transaction.readDispatch(dispatch.dispatchId as string);
    if (current === null || !validation.isValidDispatch(current)) throw new Error("invalid persisted dispatch");
    if (!hasExactIdentity(current, dispatch)) throw new Error("dispatch identity mismatch");
    if (current.enqueued === true) return;

    const acknowledged = createEnqueueAcknowledgement(current, transaction.now(), source, eventIdDigest);
    if (!validation.isValidDispatchUpdate(current, acknowledged)) throw new Error("invalid enqueue acknowledgement");
    await transaction.writeDispatch(acknowledged);
  });
}

/**
 * Handles a created outbox record through an injectable queue and transaction boundary.
 * Queue success and deterministic task reuse both require a guarded acknowledgement.
 */
export async function enqueueAndAcknowledgeDispatch(request: EnqueueDispatchRequest): Promise<void> {
  if (!request.validation.isValidDispatch(request.dispatch)) throw new Error("invalid dispatch");
  if (!DIGEST.test(request.eventIdDigest)) throw new Error("invalid event identity");

  const dispatch = request.dispatch as DispatchRecord;
  try {
    await request.enqueue.enqueue(toEnqueueDispatch(dispatch));
  } catch (error) {
    if (!isAlreadyExists(error)) throw error;
  }
  await acknowledgeEnqueuedDispatch(dispatch, request.eventIdDigest, request.source, request.store, request.validation);
}

/** Created-event fast path; repair uses the same shared boundary with sweeper provenance. */
export async function handleCreatedDispatch(request: CreatedDispatchRequest): Promise<void> {
  await enqueueAndAcknowledgeDispatch({ ...request, source: "trigger" });
}
