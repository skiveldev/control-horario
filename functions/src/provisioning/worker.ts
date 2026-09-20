import { createHash } from "node:crypto";
import { createApplicationLog, createAuditEvent, deduplicateAudit } from "./audit.ts";
import type { AuthCreator, AuthReader, WorkerStore, WorkerTransaction } from "./boundaries.ts";
import { matchesProfileProvenance } from "./profile.ts";
import { deriveDisplayName } from "./normalize.ts";
import { deriveAuditEventId, deriveDispatchId, deriveOwnerToken } from "./ids.ts";
import { createEvent, isValidState, reduce, type OperationState } from "./model.ts";
import { isValidDispatch, isValidDispatchUpdate, isValidOperation } from "./schemas.ts";

const OPERATION_FIELDS = [
  "schemaVersion", "operationId", "fingerprint", "normalizedPayload", "intendedUid",
  "submittedByDigest", "status", "phase", "generation", "version", "ownerToken",
  "leaseExpiresAt", "currentDispatchId", "authAttempted", "authAttempt", "createdAt", "updatedAt",
] as const;
const DISPATCH_FIELDS = [
  "schemaVersion", "dispatchId", "taskId", "operationId", "fingerprint", "boundary",
  "generation", "sourceVersion", "ownerSeed", "enqueued", "enqueuedAt", "enqueueSource",
  "enqueueEventId", "workerAck", "workerAckAt", "createdAt",
] as const;
const STATE_FIELDS = OPERATION_FIELDS.filter((field) => field !== "schemaVersion" && field !== "submittedByDigest");
const DIGEST = /^[a-f0-9]{64}$/;
const TERMINAL_STATUSES = new Set(["completed", "failed", "manual_recovery"]);

type PersistedRecord = Record<string, unknown>;
export type DeliveryClassification = "eligible" | "stale_eligible" | "duplicate" | "orphan" | "terminal" | "mismatch" | "malformed" | "corrupt";

/**
 * Adapter-owned delivery snapshots from the Firestore transaction that rereads
 * both documents. This pure carrier is not write authority on its own.
 */
export interface DeliveryClassificationRequest {
  readonly deliveryDispatchId: string;
  readonly dispatchDocumentId: string;
  readonly operationSnapshot: unknown;
  readonly dispatchSnapshot: unknown;
}

/**
 * Copies exact own data properties without invoking getters.
 * Reflection itself can trigger a Proxy trap, so exceptions are fail-closed.
 */
function readExact(value: unknown, fields: readonly string[]): PersistedRecord | null {
  try {
    if (value === null || typeof value !== "object" || Array.isArray(value) || Object.getPrototypeOf(value) !== Object.prototype) return null;
    const keys = Reflect.ownKeys(value);
    if (keys.length !== fields.length || keys.some((key) => typeof key !== "string" || !fields.includes(key))) return null;
    const descriptors = Object.getOwnPropertyDescriptors(value);
    const copy: PersistedRecord = {};
    for (const field of fields) {
      const descriptor = descriptors[field];
      if (descriptor === undefined || !("value" in descriptor)) return null;
      copy[field] = descriptor.value;
    }
    return copy;
  } catch {
    return null;
  }
}

function readRequest(value: unknown): PersistedRecord | null {
  const request = readExact(value, [
    "deliveryDispatchId", "dispatchDocumentId", "operationSnapshot", "dispatchSnapshot",
  ]);
  return request !== null
    && typeof request.deliveryDispatchId === "string" && DIGEST.test(request.deliveryDispatchId)
    && typeof request.dispatchDocumentId === "string" && DIGEST.test(request.dispatchDocumentId)
    ? request
    : null;
}

function readOperation(value: unknown): PersistedRecord | null {
  const operation = readExact(value, OPERATION_FIELDS);
  if (operation === null) return null;
  if (isValidOperation(operation)) return operation;
  if (operation.schemaVersion !== 1 || typeof operation.submittedByDigest !== "string" || !DIGEST.test(operation.submittedByDigest)) return null;
  const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]]));
  return isValidState(state) ? operation : null;
}

function readDispatch(value: unknown): PersistedRecord | null {
  const dispatch = readExact(value, DISPATCH_FIELDS);
  if (dispatch === null || typeof dispatch.taskId !== "string" || !DIGEST.test(dispatch.taskId)) return null;
  return isValidDispatch({ ...dispatch, taskId: dispatch.dispatchId }) ? dispatch : null;
}

function isInitialTuple(operation: PersistedRecord, dispatch: PersistedRecord): boolean {
  return isValidOperation(operation)
    && dispatch.boundary === "acquire"
    && dispatch.generation === 0
    && dispatch.sourceVersion === 0
    && operation.createdAt === operation.updatedAt
    && operation.createdAt === dispatch.createdAt;
}

function hasActiveLifetime(operation: PersistedRecord, dispatch: PersistedRecord): boolean {
  const createdAt = operation.createdAt as number;
  const updatedAt = operation.updatedAt as number;
  const dispatchCreatedAt = dispatch.createdAt as number;
  return createdAt <= dispatchCreatedAt && dispatchCreatedAt <= updatedAt;
}

function classifyActiveTemporalRelation(operation: PersistedRecord, dispatch: PersistedRecord): DeliveryClassification {
  if (operation.status !== "active" || operation.phase !== dispatch.boundary || !hasActiveLifetime(operation, dispatch)) return "mismatch";
  const generation = operation.generation as number;
  const version = operation.version as number;
  const dispatchGeneration = dispatch.generation as number;
  const sourceVersion = dispatch.sourceVersion as number;
  const isCurrent = operation.currentDispatchId === dispatch.dispatchId;
  const sameTuple = generation === dispatchGeneration && version === sourceVersion;
  if (sameTuple) return isCurrent ? "eligible" : "mismatch";

  const retained = (generation === dispatchGeneration && sourceVersion < version)
    || (dispatchGeneration < generation && sourceVersion < version);
  if (!retained) return "mismatch";
  return isCurrent ? "eligible" : "stale_eligible";
}

/**
 * Classifies transaction-reread persisted delivery snapshots without writes,
 * acknowledgements, Auth access, audit writes, acquisition, or external effects.
 */
export function classifyProvisioningDelivery(requestValue: unknown): DeliveryClassification {
  const request = readRequest(requestValue);
  if (request === null) return "malformed";
  if (request.dispatchSnapshot === null) return "orphan";
  const dispatch = readDispatch(request.dispatchSnapshot);
  if (dispatch === null) return "malformed";
  if (
    request.dispatchDocumentId !== dispatch.dispatchId
    || dispatch.taskId !== dispatch.dispatchId
    || deriveDispatchId(dispatch.operationId as string, dispatch.boundary as string, dispatch.generation as number, dispatch.sourceVersion as number) !== dispatch.dispatchId
  ) return "corrupt";
  if (request.operationSnapshot === null) return "orphan";
  const operation = readOperation(request.operationSnapshot);
  if (operation === null) return "malformed";
  if (
    request.deliveryDispatchId !== dispatch.dispatchId
    || operation.operationId !== dispatch.operationId
    || operation.fingerprint !== dispatch.fingerprint
  ) return "mismatch";
  if (TERMINAL_STATUSES.has(operation.status as string)) return "terminal";
  if (dispatch.workerAck !== null) return "duplicate";
  if (isInitialTuple(operation, dispatch)) return "eligible";
  return classifyActiveTemporalRelation(operation, dispatch);
}

function isClosedFirestoreTransaction(error: unknown): boolean {
  const visited = new Set<object>();
  let current: unknown = error;
  for (let depth = 0; depth < 4; depth += 1) {
    if (current === null || typeof current !== "object" || visited.has(current)) return false;
    visited.add(current);
    try {
      const { code, message, cause } = current as { readonly code?: unknown; readonly message?: unknown; readonly cause?: unknown };
      if ((code === 3 || code === "3" || code === "INVALID_ARGUMENT")
        && typeof message === "string" && /transaction(?: is)? invalid or closed/i.test(message)) return true;
      current = cause;
    } catch {
      return false;
    }
  }
  return false;
}

/**
 * Transactionally acknowledges only a transaction-reread stale delivery and
 * creates its immutable audit event. All other delivery classifications are
 * intentionally no-ops.
 */
export async function acknowledgeStaleDelivery(
  store: WorkerStore,
  deliveryDispatchId: string,
): Promise<void> {
  try {
    await acknowledgeStaleDeliveryOnce(store, deliveryDispatchId);
  } catch (error) {
    if (!isClosedFirestoreTransaction(error)) throw error;
    await acknowledgeStaleDeliveryOnce(store, deliveryDispatchId);
  }
}

async function acknowledgeStaleDeliveryOnce(
  store: WorkerStore,
  deliveryDispatchId: string,
): Promise<void> {
  await store.transaction(async (transaction) => {
    const dispatch = await transaction.readDispatch(deliveryDispatchId);
    if (dispatch === null) return;
    const operation = await transaction.readOperation(dispatch.operationId as string);
    const classification = classifyProvisioningDelivery({
      deliveryDispatchId,
      dispatchDocumentId: deliveryDispatchId,
      operationSnapshot: operation,
      dispatchSnapshot: dispatch,
    });
    if (classification !== "stale_eligible") return;

    const audit = createAuditEvent({
      schemaVersion: 1,
      eventId: deriveAuditEventId(
        operation!.operationId as string,
        "progress",
        "stale_delivery",
        dispatch.generation as number,
        dispatch.sourceVersion as number,
      ),
      operationId: operation!.operationId,
      correlationId: createHash("sha256").update(`provision-correlation:v1\0${operation!.operationId as string}`, "utf8").digest("hex"),
      category: "progress",
      stage: "stale_delivery",
      outcome: "stale",
      code: "stale-dispatch",
      actorUidDigest: null,
      intendedUidDigest: null,
      dispatchId: dispatch.dispatchId,
      generation: dispatch.generation,
      sourceVersion: dispatch.sourceVersion,
      createdAt: transaction.now,
    });
    const existing = await transaction.readAudit(audit.eventId);
    if (existing !== null) deduplicateAudit(existing, audit);

    const acknowledged = { ...dispatch, workerAck: "stale", workerAckAt: transaction.now };
    if (!isValidDispatchUpdate(dispatch, acknowledged)) throw new TypeError("invalid stale dispatch acknowledgement");
    transaction.writeDispatch(dispatch.dispatchId as string, acknowledged);
    if (existing === null) transaction.createAudit(audit.eventId, audit as unknown as PersistedRecord);
  });
}

/**
 * Acquires only the transaction-reread initial pending operation and commits
 * its next dispatch, source acknowledgement, and immutable audit together.
 */
export async function acquireInitialPending(
  store: WorkerStore,
  deliveryDispatchId: string,
): Promise<void> {
  await store.transaction(async (transaction) => {
    const source = await transaction.readDispatch(deliveryDispatchId);
    if (source === null || !isValidDispatch(source) || source.workerAck !== null) return;
    const operation = await transaction.readOperation(source.operationId as string);
    if (
      operation === null
      || !isValidOperation(operation)
      || operation.createdAt !== operation.updatedAt
      || operation.createdAt !== source.createdAt
    ) return;

    const sourceId = deriveDispatchId(operation.operationId as string, "acquire", 0, 0);
    const ownerToken = deriveOwnerToken(sourceId, 0);
    if (
      source.dispatchId !== sourceId
      || source.taskId !== sourceId
      || source.operationId !== operation.operationId
      || source.fingerprint !== operation.fingerprint
      || source.boundary !== "acquire"
      || source.generation !== 0
      || source.sourceVersion !== 0
      || source.ownerSeed !== ownerToken
    ) return;

    const audit = createAuditEvent({
      schemaVersion: 1,
      eventId: deriveAuditEventId(operation.operationId as string, "progress", "state_transition", 0, 0),
      operationId: operation.operationId,
      correlationId: createHash("sha256").update(`provision-correlation:v1\0${operation.operationId as string}`, "utf8").digest("hex"),
      category: "progress",
      stage: "state_transition",
      outcome: "started",
      code: "success",
      actorUidDigest: null,
      intendedUidDigest: null,
      dispatchId: sourceId,
      generation: 0,
      sourceVersion: 0,
      createdAt: transaction.now,
    });
    const nextId = deriveDispatchId(operation.operationId as string, "auth_preflight", 0, 1);
    const existingAudit = await transaction.readAudit(audit.eventId);
    const existingNext = await transaction.readDispatch(nextId);
    if (existingNext !== null) throw new Error("next dispatch conflict");
    if (existingAudit !== null) deduplicateAudit(existingAudit, audit);

    const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
    const result = reduce(state, {
      expected: {
        fingerprint: state.fingerprint,
        status: state.status,
        phase: state.phase,
        generation: state.generation,
        version: state.version,
        ownerToken: state.ownerToken,
        currentDispatchId: state.currentDispatchId,
        leaseExpiresAt: state.leaseExpiresAt,
      },
      observedAt: transaction.now,
      event: createEvent("acquire", { ownerToken, leaseExpiresAt: transaction.now + 60_000 }),
    });
    if (result.type !== "success") throw new Error(`acquire ${result.reason}`);

    const updatedOperation = { ...operation, ...result.state, currentDispatchId: nextId };
    const updatedState = Object.fromEntries(STATE_FIELDS.map((field) => [field, updatedOperation[field]]));
    if (!isValidState(updatedState)) throw new TypeError("invalid acquired operation");
    const processedSource = { ...source, workerAck: "processed", workerAckAt: transaction.now };
    if (!isValidDispatchUpdate(source, processedSource)) throw new TypeError("invalid processed source acknowledgement");
    const nextDispatch = {
      schemaVersion: 1,
      dispatchId: nextId,
      taskId: nextId,
      operationId: operation.operationId,
      fingerprint: operation.fingerprint,
      boundary: "auth_preflight",
      generation: 0,
      sourceVersion: 1,
      ownerSeed: deriveOwnerToken(nextId, 0),
      enqueued: false,
      enqueuedAt: null,
      enqueueSource: null,
      enqueueEventId: null,
      workerAck: null,
      workerAckAt: null,
      createdAt: transaction.now,
    };
    if (!isValidDispatch(nextDispatch)) throw new TypeError("invalid next dispatch");

    transaction.writeOperation(operation.operationId as string, updatedOperation);
    transaction.writeDispatch(sourceId, processedSource);
    if (existingAudit === null) transaction.createAudit(audit.eventId, audit as unknown as PersistedRecord);
    transaction.createDispatch(nextId, nextDispatch);
  });
}

/**
 * Reads both Auth indexes before the later intent boundary. A pre-attempt
 * foreign identity terminally fails the operation without creating an Auth
 * resource, acknowledging a dispatch, or writing an audit.
 */
export async function preflightAuth(
  store: WorkerStore,
  auth: AuthReader,
  deliveryDispatchId: string,
): Promise<void> {
  const target = await store.transaction(async (transaction) => {
    const dispatch = await transaction.readDispatch(deliveryDispatchId);
    if (dispatch === null) return null;
    const operation = await transaction.readOperation(dispatch.operationId as string);
    if (operation === null || classifyProvisioningDelivery({
      deliveryDispatchId,
      dispatchDocumentId: deliveryDispatchId,
      operationSnapshot: operation,
      dispatchSnapshot: dispatch,
    }) !== "eligible") return null;

    const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
    if (!isValidState(state) || state.status !== "active" || state.phase !== "auth_preflight") return null;
    return { intendedUid: state.intendedUid, email: state.normalizedPayload.email };
  });
  if (target === null || target.intendedUid === null) return;

  const byUid = await auth.readByUid(target.intendedUid);
  const byEmail = await auth.readByEmail(target.email);
  const foreign = [byUid, byEmail].find((identity) => identity !== null
    && identity.uid !== target.intendedUid || identity !== null
    && identity.email !== null && identity.email !== target.email);
  if (foreign === undefined) return;

  await store.transaction(async (transaction) => {
    const dispatch = await transaction.readDispatch(deliveryDispatchId);
    if (dispatch === null) return;
    const operation = await transaction.readOperation(dispatch.operationId as string);
    if (operation === null || classifyProvisioningDelivery({
      deliveryDispatchId,
      dispatchDocumentId: deliveryDispatchId,
      operationSnapshot: operation,
      dispatchSnapshot: dispatch,
    }) !== "eligible") return;

    const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
    if (!isValidState(state) || state.status !== "active" || state.phase !== "auth_preflight"
      || state.intendedUid !== target.intendedUid || state.normalizedPayload.email !== target.email) return;
    const observed = foreign!;
    const result = reduce(state, {
      expected: {
        fingerprint: state.fingerprint,
        status: state.status,
        phase: state.phase,
        generation: state.generation,
        version: state.version,
        ownerToken: state.ownerToken,
        currentDispatchId: state.currentDispatchId,
        leaseExpiresAt: state.leaseExpiresAt,
      },
      observedAt: transaction.now,
      event: createEvent("auth_foreign_user", {
        uid: observed.uid,
        email: observed.email ?? target.email,
      }),
    });
    if (result.type !== "success") return;
    const updatedOperation = { ...operation, ...result.state };
    if (!isValidState(Object.fromEntries(STATE_FIELDS.map((field) => [field, updatedOperation[field]])))) {
      throw new TypeError("invalid foreign Auth failure operation");
    }
    transaction.writeOperation(operation.operationId as string, updatedOperation);
  });
}

/**
 * Takes over an expired, transaction-reread current dispatch during ordinary
 * work. It deliberately leaves that source dispatch unacknowledged: a later
 * phase transition owns acknowledgement and next-dispatch creation.
 */
const CLOSED_TRANSACTION_MAX_ATTEMPTS = 8;
type TerminalizationOutcome = "terminal" | "no-op" | "takeover-committed" | "retryable-conflict";
type ExpiredTakeoverResult = { readonly terminal: true } | { readonly takeoverCommitted: true };

/**
 * Commits takeover separately from terminalization, then rereads the committed
 * state in a fresh transaction. No transaction adapter or snapshot crosses an
 * attempt boundary; only the explicit outcome does.
 */
export async function takeoverExpiredCurrent(
  store: WorkerStore,
  deliveryDispatchId: string,
): Promise<ExpiredTakeoverResult | null> {
  for (let attempt = 0; attempt < CLOSED_TRANSACTION_MAX_ATTEMPTS; attempt += 1) {
    let outcome: TerminalizationOutcome;
    try {
      outcome = await store.transaction(async (transaction) => {
        const source = await transaction.readDispatch(deliveryDispatchId);
        if (source === null || !isValidDispatch(source)) return "no-op";
        const operation = await transaction.readOperation(source.operationId as string);
        if (isPersistedTerminalOperation(operation)) return "terminal";
        if (source.workerAck !== null || source.ownerSeed !== deriveOwnerToken(source.dispatchId as string, source.generation as number)) return "no-op";
        if (operation === null || classifyProvisioningDelivery({
          deliveryDispatchId, dispatchDocumentId: deliveryDispatchId, operationSnapshot: operation, dispatchSnapshot: source,
        }) !== "eligible") return "no-op";

        const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
        const result = reduce(state, {
          expected: {
            fingerprint: state.fingerprint, status: state.status, phase: state.phase, generation: state.generation,
            version: state.version, ownerToken: state.ownerToken, currentDispatchId: state.currentDispatchId, leaseExpiresAt: state.leaseExpiresAt,
          },
          observedAt: transaction.now,
          event: createEvent("takeover", {
            ownerToken: deriveOwnerToken(source.dispatchId as string, state.generation + 1),
            leaseExpiresAt: transaction.now + 60_000,
          }),
        });
        if (result.type !== "success") return "no-op";

        const updatedOperation = { ...operation, ...result.state };
        if (!isValidState(Object.fromEntries(STATE_FIELDS.map((field) => [field, updatedOperation[field]])))) throw new TypeError("invalid takeover operation");
        const audit = createAuditEvent({
          schemaVersion: 1,
          eventId: deriveAuditEventId(operation.operationId as string, "progress", "state_transition", state.generation, state.version),
          operationId: operation.operationId,
          correlationId: createHash("sha256").update(`provision-correlation:v1\0${operation.operationId as string}`, "utf8").digest("hex"),
          category: "progress", stage: "state_transition", outcome: "started", code: "success",
          actorUidDigest: null, intendedUidDigest: null, dispatchId: source.dispatchId,
          generation: state.generation, sourceVersion: state.version, createdAt: transaction.now,
        });
        const existingAudit = await transaction.readAudit(audit.eventId);
        if (existingAudit !== null) deduplicateAudit(existingAudit, audit);
        transaction.writeOperation(operation.operationId as string, updatedOperation);
        if (existingAudit === null) transaction.createAudit(audit.eventId, audit as unknown as PersistedRecord);
        return "takeover-committed";
      });
    } catch (error) {
      if (!isClosedFirestoreTransaction(error)) throw error;
      outcome = "retryable-conflict";
    }
    if (outcome === "retryable-conflict") {
      if (attempt + 1 === CLOSED_TRANSACTION_MAX_ATTEMPTS) throw new Error("closed Firestore transaction retry exhausted");
      continue;
    }
    if (outcome === "terminal") return { terminal: true };
    if (outcome === "no-op") return null;

    try {
      const reread = await store.transaction(async (transaction) => {
        const source = await transaction.readDispatch(deliveryDispatchId);
        const operation = source === null ? null : await transaction.readOperation(source.operationId as string);
        return source !== null && isRetainedTakeoverTerminalizationTuple(operation, source, transaction.now)
          ? "takeover-committed"
          : "no-op";
      });
      if (reread === "takeover-committed") return { takeoverCommitted: true };
      return null;
    } catch (error) {
      if (!isClosedFirestoreTransaction(error)) throw error;
      if (attempt + 1 === CLOSED_TRANSACTION_MAX_ATTEMPTS) throw new Error("closed Firestore transaction retry exhausted");
    }
  }
  throw new Error("closed Firestore transaction retry exhausted");
}

/**
 * Persists the first Auth-call intent before any Auth mutation. The current
 * auth_preflight dispatch is acknowledged only with the operation transition,
 * immutable audit, and deterministic auth_create dispatch in one transaction.
 */
export async function persistAuthIntent(
  store: WorkerStore,
  deliveryDispatchId: string,
): Promise<void> {
  await store.transaction(async (transaction) => {
    const source = await transaction.readDispatch(deliveryDispatchId);
    if (source === null) return;
    const operation = await transaction.readOperation(source.operationId as string);
    if (operation === null || classifyProvisioningDelivery({
      deliveryDispatchId,
      dispatchDocumentId: deliveryDispatchId,
      operationSnapshot: operation,
      dispatchSnapshot: source,
    }) !== "eligible") return;

    const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
    if (!isValidState(state) || state.status !== "active" || state.phase !== "auth_preflight"
      || source.boundary !== "auth_preflight" || source.generation !== state.generation
      || source.sourceVersion !== state.version || source.workerAck !== null) return;

    const nextId = deriveDispatchId(
      state.operationId,
      "auth_create",
      state.generation,
      state.version + 1,
    );
    const audit = createAuditEvent({
      schemaVersion: 1,
      eventId: deriveAuditEventId(state.operationId, "progress", "auth_intent", source.generation as number, source.sourceVersion as number),
      operationId: state.operationId,
      correlationId: createHash("sha256").update(`provision-correlation:v1\0${state.operationId}`, "utf8").digest("hex"),
      category: "progress",
      stage: "auth_intent",
      outcome: "started",
      code: "auth-intent",
      actorUidDigest: null,
      intendedUidDigest: null,
      dispatchId: source.dispatchId,
      generation: source.generation,
      sourceVersion: source.sourceVersion,
      createdAt: transaction.now,
    });
    const existingAudit = await transaction.readAudit(audit.eventId);
    const existingNext = await transaction.readDispatch(nextId);
    if (existingNext !== null) throw new Error("next dispatch conflict");
    if (existingAudit !== null) deduplicateAudit(existingAudit, audit);

    const result = reduce(state, {
      expected: {
        fingerprint: state.fingerprint,
        status: state.status,
        phase: state.phase,
        generation: state.generation,
        version: state.version,
        ownerToken: state.ownerToken,
        currentDispatchId: state.currentDispatchId,
        leaseExpiresAt: state.leaseExpiresAt,
      },
      observedAt: transaction.now,
      event: createEvent("auth_intent", { attemptId: nextId, intentAt: transaction.now }),
    });
    if (result.type !== "success") return;

    const updatedOperation = { ...operation, ...result.state, currentDispatchId: nextId };
    if (!isValidState(Object.fromEntries(STATE_FIELDS.map((field) => [field, updatedOperation[field]])))) {
      throw new TypeError("invalid Auth intent operation");
    }
    const processedSource = { ...source, workerAck: "processed", workerAckAt: transaction.now };
    if (!isValidDispatchUpdate(source, processedSource)) throw new TypeError("invalid Auth intent acknowledgement");
    const nextDispatch = {
      schemaVersion: 1,
      dispatchId: nextId,
      taskId: nextId,
      operationId: state.operationId,
      fingerprint: state.fingerprint,
      boundary: "auth_create",
      generation: state.generation,
      sourceVersion: state.version + 1,
      ownerSeed: deriveOwnerToken(nextId, state.generation),
      enqueued: false,
      enqueuedAt: null,
      enqueueSource: null,
      enqueueEventId: null,
      workerAck: null,
      workerAckAt: null,
      createdAt: transaction.now,
    };
    if (!isValidDispatch(nextDispatch)) throw new TypeError("invalid Auth intent dispatch");

    transaction.writeOperation(state.operationId, updatedOperation);
    transaction.writeDispatch(source.dispatchId as string, processedSource);
    if (existingAudit === null) transaction.createAudit(audit.eventId, audit as unknown as PersistedRecord);
    transaction.createDispatch(nextId, nextDispatch);
  });
}


function hasCompletePersistedAuthCorrelation(state: OperationState): boolean {
  const attempt = state.authAttempt;
  if (state.intendedUid === null || attempt === null || attempt.result !== "confirmed" || attempt.proof === null) {
    return false;
  }
  const proof = attempt.proof;
  return proof.attemptId === attempt.attemptId
    && attempt.returnedUid === state.intendedUid
    && proof.uidRead === state.intendedUid
    && attempt.returnedEmail === state.normalizedPayload.email
    && proof.emailRead === state.normalizedPayload.email;
}

function authRequest(state: OperationState, observedAt: number, event: ReturnType<typeof createEvent>) {
  return {
    expected: {
      fingerprint: state.fingerprint, status: state.status, phase: state.phase,
      generation: state.generation, version: state.version, ownerToken: state.ownerToken,
      currentDispatchId: state.currentDispatchId, leaseExpiresAt: state.leaseExpiresAt,
    },
    observedAt,
    event,
  };
}

function createWorkerDispatch(
  operation: PersistedRecord,
  boundary: "auth_preflight" | "profile_commit",
  generation: number,
  sourceVersion: number,
  now: number,
): PersistedRecord {
  const dispatchId = deriveDispatchId(operation.operationId as string, boundary, generation, sourceVersion);
  return {
    schemaVersion: 1, dispatchId, taskId: dispatchId, operationId: operation.operationId,
    fingerprint: operation.fingerprint, boundary, generation, sourceVersion,
    ownerSeed: deriveOwnerToken(dispatchId, generation), enqueued: false, enqueuedAt: null,
    enqueueSource: null, enqueueEventId: null, workerAck: null, workerAckAt: null, createdAt: now,
  };
}

function isCreatedAuthOutcome(value: unknown): value is {
  readonly kind: "created";
  readonly identity: { readonly uid: string; readonly email: string };
} {
  if (value === null || typeof value !== "object") return false;
  const outcome = value as { readonly kind?: unknown; readonly identity?: unknown };
  if (outcome.kind !== "created" || outcome.identity === null || typeof outcome.identity !== "object") return false;
  const identity = outcome.identity as { readonly uid?: unknown; readonly email?: unknown };
  return typeof identity.uid === "string" && typeof identity.email === "string";
}

function isDefiniteNoEffectOutcome(value: unknown): boolean {
  return value !== null
    && typeof value === "object"
    && (value as { readonly kind?: unknown }).kind === "definite_no_effect";
}

function authResultAudit(
  operation: PersistedRecord,
  source: PersistedRecord,
  transaction: WorkerTransaction,
  category: "progress" | "failure",
  outcome: "completed" | "failed",
  code: "auth-confirmed" | "definite-no-effect" | "auth-ambiguous",
) {
  return createAuditEvent({
    schemaVersion: 1,
    eventId: deriveAuditEventId(operation.operationId as string, category, "auth_result", source.generation as number, source.sourceVersion as number),
    operationId: operation.operationId,
    correlationId: createHash("sha256").update(`provision-correlation:v1\0${operation.operationId as string}`, "utf8").digest("hex"),
    category, stage: "auth_result", outcome, code, actorUidDigest: null, intendedUidDigest: null,
    dispatchId: source.dispatchId, generation: source.generation, sourceVersion: source.sourceVersion,
    createdAt: transaction.now,
  });
}

/**
 * Advances exactly one Auth-create attempt. The `call_started` CAS commits before
 * the Auth boundary; every thrown boundary error is intentionally ambiguous.
 */
export async function createAuthUser(
  store: WorkerStore,
  auth: AuthCreator & AuthReader,
  deliveryDispatchId: string,
): Promise<void> {
  const start = await store.transaction(async (transaction) => {
    const source = await transaction.readDispatch(deliveryDispatchId);
    if (source === null) return null;
    const operation = await transaction.readOperation(source.operationId as string);
    if (operation === null || classifyProvisioningDelivery({
      deliveryDispatchId, dispatchDocumentId: deliveryDispatchId, operationSnapshot: operation, dispatchSnapshot: source,
    }) !== "eligible") return null;
    const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
    if (!isValidState(state) || state.status !== "active" || state.phase !== "auth_create"
      || source.boundary !== "auth_create" || source.workerAck !== null || state.intendedUid === null || state.authAttempt === null) return null;
    if (state.authAttempt.result === "call_started") {
      return { intendedUid: state.intendedUid, email: state.normalizedPayload.email, attemptId: state.authAttempt.attemptId, recovery: true };
    }
    if (state.authAttempt.result !== "intent") return null;
    const result = reduce(state, authRequest(state, transaction.now, createEvent("auth_start", {
      attemptId: state.authAttempt.attemptId, callStartedAt: transaction.now,
    })));
    if (result.type !== "success") return null;
    const updated = { ...operation, ...result.state };
    if (!isValidState(Object.fromEntries(STATE_FIELDS.map((field) => [field, updated[field]])))) throw new TypeError("invalid Auth call-start operation");
    transaction.writeOperation(state.operationId, updated);
    return { intendedUid: state.intendedUid, email: state.normalizedPayload.email, attemptId: state.authAttempt.attemptId, recovery: false };
  });
  if (start === null) return;
  if (start.recovery) {
    await Promise.allSettled([
      auth.readByUid(start.intendedUid),
      auth.readByEmail(start.email),
    ]);
    await finishAuthCreate(store, deliveryDispatchId, start.attemptId, "ambiguous");
    return;
  }

  let outcome: unknown;
  try {
    outcome = await auth.createUser(start.intendedUid, start.email);
  } catch {
    await finishAuthCreate(store, deliveryDispatchId, start.attemptId, "ambiguous");
    return;
  }
  if (isDefiniteNoEffectOutcome(outcome)) {
    await finishAuthCreate(store, deliveryDispatchId, start.attemptId, "definite_no_effect");
    return;
  }
  if (!isCreatedAuthOutcome(outcome)) {
    await finishAuthCreate(store, deliveryDispatchId, start.attemptId, "ambiguous");
    return;
  }

  const [uidRead, emailRead] = await Promise.allSettled([
    auth.readByUid(start.intendedUid),
    auth.readByEmail(start.email),
  ]);
  const exact = outcome.identity.uid === start.intendedUid && outcome.identity.email === start.email
    && uidRead.status === "fulfilled" && uidRead.value?.uid === start.intendedUid && uidRead.value.email === start.email
    && emailRead.status === "fulfilled" && emailRead.value?.uid === start.intendedUid && emailRead.value.email === start.email;
  await finishAuthCreate(store, deliveryDispatchId, start.attemptId, exact ? "confirmed" : "ambiguous");
}

async function finishAuthCreate(
  store: WorkerStore,
  deliveryDispatchId: string,
  attemptId: string,
  resultKind: "confirmed" | "definite_no_effect" | "ambiguous",
): Promise<void> {
  await store.transaction(async (transaction) => {
    const source = await transaction.readDispatch(deliveryDispatchId);
    if (source === null) return;
    const operation = await transaction.readOperation(source.operationId as string);
    if (operation === null || classifyProvisioningDelivery({
      deliveryDispatchId, dispatchDocumentId: deliveryDispatchId, operationSnapshot: operation, dispatchSnapshot: source,
    }) !== "eligible") return;
    const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
    if (!isValidState(state) || state.status !== "active" || state.phase !== "auth_create" || source.boundary !== "auth_create"
      || source.workerAck !== null || state.authAttempt?.result !== "call_started" || state.authAttempt.attemptId !== attemptId) return;

    const nextBoundary = resultKind === "confirmed" ? "profile_commit" : resultKind === "definite_no_effect" ? "auth_preflight" : null;
    const category = resultKind === "ambiguous" ? "failure" : "progress";
    const outcome = resultKind === "ambiguous" ? "failed" : "completed";
    const code = resultKind === "confirmed" ? "auth-confirmed" : resultKind === "definite_no_effect" ? "definite-no-effect" : "auth-ambiguous";
    const audit = authResultAudit(operation, source, transaction, category, outcome, code);
    const existingAudit = await transaction.readAudit(audit.eventId);
    if (existingAudit !== null) deduplicateAudit(existingAudit, audit);

    let transition;
    let nextDispatch: PersistedRecord | null = null;
    if (resultKind === "confirmed") {
      transition = reduce(state, authRequest(state, transaction.now, createEvent("auth_confirm", {
        attemptId, returnedUid: state.intendedUid, returnedEmail: state.normalizedPayload.email,
        proof: { attemptId, confirmedAt: transaction.now, uidRead: state.intendedUid, emailRead: state.normalizedPayload.email },
      })));
    } else if (resultKind === "ambiguous") {
      transition = reduce(state, authRequest(state, transaction.now, createEvent("auth_ambiguous", { attemptId, code })));
    } else {
      transition = { type: "success" as const, state: {
        ...state, phase: "auth_preflight" as const, authAttempt: { ...state.authAttempt, result: "definite_no_effect" as const },
        version: state.version + 1, updatedAt: transaction.now,
      } };
    }
    if (transition.type !== "success") throw new Error(`Auth result ${transition.reason}`);
    if (nextBoundary !== null) {
      nextDispatch = createWorkerDispatch(operation, nextBoundary, transition.state.generation, transition.state.version, transaction.now);
      const existingNext = await transaction.readDispatch(nextDispatch.dispatchId as string);
      if (existingNext !== null) throw new Error("next dispatch conflict");
    }
    const updated = { ...operation, ...transition.state, currentDispatchId: nextDispatch?.dispatchId ?? null };
    if (!isValidState(Object.fromEntries(STATE_FIELDS.map((field) => [field, updated[field]])))) throw new TypeError("invalid Auth result operation");
    const processed = { ...source, workerAck: "processed", workerAckAt: transaction.now };
    if (!isValidDispatchUpdate(source, processed)) throw new TypeError("invalid Auth result acknowledgement");
    transaction.writeOperation(state.operationId, updated);
    transaction.writeDispatch(source.dispatchId as string, processed);
    if (existingAudit === null) transaction.createAudit(audit.eventId, audit as unknown as PersistedRecord);
    if (nextDispatch !== null) transaction.createDispatch(nextDispatch.dispatchId as string, nextDispatch);
  });
}

/**
 * Commits a verified profile exactly with completed state, success audit, and
 * current source acknowledgement. A profile conflict intentionally remains a
 * no-op for P3.14's separately owned manual-recovery behavior.
 */
export async function completeProfileCommit(
  store: WorkerStore,
  auth: AuthReader,
  deliveryDispatchId: string,
): Promise<void> {
  const target = await store.transaction(async (transaction) => {
    const source = await transaction.readDispatch(deliveryDispatchId);
    if (source === null) return null;
    const operation = await transaction.readOperation(source.operationId as string);
    if (operation === null || classifyProvisioningDelivery({
      deliveryDispatchId, dispatchDocumentId: deliveryDispatchId, operationSnapshot: operation, dispatchSnapshot: source,
    }) !== "eligible") return null;
    const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
    if (!isValidState(state) || state.status !== "active" || state.phase !== "profile_commit"
      || source.boundary !== "profile_commit" || source.workerAck !== null || state.intendedUid === null
      || !hasCompletePersistedAuthCorrelation(state)) return null;
    return { intendedUid: state.intendedUid, email: state.normalizedPayload.email };
  });
  if (target === null) return;

  const [byUid, byEmail] = await Promise.all([
    auth.readByUid(target.intendedUid),
    auth.readByEmail(target.email),
  ]);
  if (byUid?.uid !== target.intendedUid || byUid.email !== target.email
    || byEmail?.uid !== target.intendedUid || byEmail.email !== target.email) return;

  await store.transaction(async (transaction) => {
    const source = await transaction.readDispatch(deliveryDispatchId);
    if (source === null) return;
    const operation = await transaction.readOperation(source.operationId as string);
    if (operation === null || classifyProvisioningDelivery({
      deliveryDispatchId, dispatchDocumentId: deliveryDispatchId, operationSnapshot: operation, dispatchSnapshot: source,
    }) !== "eligible") return;
    const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
    if (!isValidState(state) || state.status !== "active" || state.phase !== "profile_commit"
      || source.boundary !== "profile_commit" || source.workerAck !== null || state.intendedUid !== target.intendedUid
      || state.normalizedPayload.email !== target.email || !hasCompletePersistedAuthCorrelation(state)) return;

    const normalizedPayload = {
      ...state.normalizedPayload,
              displayName: deriveDisplayName(
            state.normalizedPayload.nombre,
            state.normalizedPayload.apellido1,
            state.normalizedPayload.apellido2,
          ),
    };
    const expectedProfile = {
      intendedUid: state.intendedUid,
      operationId: state.operationId,
      fingerprint: state.fingerprint,
      schemaVersion: 1,
      normalizedPayload,
    };
    const existingProfile = await transaction.readProfile(state.intendedUid);
    if (existingProfile !== null && !matchesProfileProvenance(existingProfile, expectedProfile)) {
          const audit = createAuditEvent({
            schemaVersion: 1,
            eventId: deriveAuditEventId(state.operationId, "failure", "terminal_failure", source.generation as number, source.sourceVersion as number),
            operationId: state.operationId,
            correlationId: createHash("sha256").update(`provision-correlation:v1\0${state.operationId}`, "utf8").digest("hex"),
            category: "failure",
            stage: "terminal_failure",
            outcome: "failed",
            code: "manual-recovery",
            actorUidDigest: null,
            intendedUidDigest: null,
            dispatchId: source.dispatchId,
            generation: source.generation,
            sourceVersion: source.sourceVersion,
            createdAt: transaction.now,
          });
          const existingAudit = await transaction.readAudit(audit.eventId);
          if (existingAudit !== null) deduplicateAudit(existingAudit, audit);
          const recovered: PersistedRecord = {
            ...operation,
            status: "manual_recovery",
            phase: "terminal",
            version: state.version + 1,
            ownerToken: null,
            leaseExpiresAt: null,
            updatedAt: transaction.now,
          };
          if (!isValidState(Object.fromEntries(STATE_FIELDS.map((field) => [field, recovered[field]])))) {
            throw new TypeError("invalid profile conflict recovery operation");
          }
          const processed = { ...source, workerAck: "processed", workerAckAt: transaction.now };
          if (!isValidDispatchUpdate(source, processed)) throw new TypeError("invalid profile conflict acknowledgement");
          transaction.writeOperation(state.operationId, recovered);
          transaction.writeDispatch(source.dispatchId as string, processed);
          if (existingAudit === null) transaction.createAudit(audit.eventId, audit as unknown as PersistedRecord);
          return;
        }

    const audit = createAuditEvent({
      schemaVersion: 1,
      eventId: deriveAuditEventId(state.operationId, "success", "terminal_success", source.generation as number, source.sourceVersion as number),
      operationId: state.operationId,
      correlationId: createHash("sha256").update(`provision-correlation:v1\0${state.operationId}`, "utf8").digest("hex"),
      category: "success",
      stage: "terminal_success",
      outcome: "completed",
      code: "success",
      actorUidDigest: null,
      intendedUidDigest: null,
      dispatchId: source.dispatchId,
      generation: source.generation,
      sourceVersion: source.sourceVersion,
      createdAt: transaction.now,
    });
    const existingAudit = await transaction.readAudit(audit.eventId);
    if (existingAudit !== null) deduplicateAudit(existingAudit, audit);
    const result = reduce(state, authRequest(state, transaction.now, createEvent("profile_commit", { userId: state.intendedUid })));
    if (result.type !== "success") throw new Error(`profile commit ${result.reason}`);

    const completed = { ...operation, ...result.state };
    if (!isValidState(Object.fromEntries(STATE_FIELDS.map((field) => [field, completed[field]])))) {
      throw new TypeError("invalid profile completion operation");
    }
    const processed = { ...source, workerAck: "processed", workerAckAt: transaction.now };
    if (!isValidDispatchUpdate(source, processed)) throw new TypeError("invalid profile completion acknowledgement");
    if (existingProfile === null) {
      transaction.writeProfile(state.intendedUid, {
        ...normalizedPayload,
        userId: state.intendedUid,
        provisioningOperationId: state.operationId,
        provisioningFingerprint: state.fingerprint,
        provisioningSchemaVersion: 1,
        provisionedBy: "trusted-backend",
        provisionedAt: transaction.now,
      });
    }
    transaction.writeOperation(state.operationId, completed);
    transaction.writeDispatch(source.dispatchId as string, processed);
    if (existingAudit === null) transaction.createAudit(audit.eventId, audit as unknown as PersistedRecord);
  });
}


export interface PendingTerminalizationEvidence {
  readonly retryCount: number;
  readonly executionCount: number;
}

class RetryableTaskError extends Error {
  readonly code = "unavailable";

  constructor(message: string) {
    super(message);
    this.name = "RetryableTaskError";
  }
}

function isValidTaskRetryCount(value: unknown): value is number {
  return typeof value === "number" && Number.isInteger(value) && value >= 0 && value <= 11;
}

/**
 * Routes Cloud Tasks retries without treating out-of-range metadata as work.
 * The final reserved attempt emits an observable, PII-safe outage event and
 * still throws so the platform never observes a silent acknowledgement.
 */
export async function processProvisioningTask(
  store: WorkerStore,
  deliveryDispatchId: string,
  retryCount: unknown,
): Promise<void> {
  if (!isValidTaskRetryCount(retryCount)) {
    throw new RetryableTaskError("invalid provisioning task retry count");
  }
  if (retryCount < 8) {
    await acquireInitialPending(store, deliveryDispatchId);
    return;
  }

  const evidence = { retryCount: retryCount, executionCount: retryCount + 1 };
  try {
    const pendingTerminal = await terminalizeInitialPending(store, deliveryDispatchId, evidence);
    if (!pendingTerminal) await terminalizeActiveCurrent(store, deliveryDispatchId, evidence);
  } catch (error) {
    if (retryCount < 11) throw error;
    console.error(createApplicationLog({
      eventCode: "retry-exhausted",
      resultCode: null,
      reasonCode: "unavailable",
      digests: [{
        domain: "provision-dispatch:v1",
        value: createHash("sha256").update(`provision-dispatch:v1\0${deliveryDispatchId}`, "utf8").digest("hex"),
      }],
    }));
    throw new RetryableTaskError(
      "provisioning durable-store outage requires operator recovery; see docs/operations/outbox-recovery-runbook.md",
    );
  }
}

type PendingTerminalizationClassification = "pending" | "active" | "terminal" | "mismatch";

function isPendingTerminalizationEvidence(value: PendingTerminalizationEvidence): boolean {
  return Number.isInteger(value.retryCount)
    && value.retryCount >= 0
    && Number.isInteger(value.executionCount)
    && value.executionCount >= 0;
}

function isPersistedTerminalOperation(value: unknown): boolean {
  try {
    if (value === null || typeof value !== "object" || Array.isArray(value) || Object.getPrototypeOf(value) !== Object.prototype) {
      return false;
    }
    const descriptors = Object.getOwnPropertyDescriptors(value);
    const status = descriptors.status;
    const phase = descriptors.phase;
    return status !== undefined
      && phase !== undefined
      && "value" in status
      && "value" in phase
      && TERMINAL_STATUSES.has(status.value as string)
      && phase.value === "terminal";
  } catch {
    return false;
  }
}

function classifyPendingTerminalization(
  operation: PersistedRecord | null,
  source: PersistedRecord | null,
): PendingTerminalizationClassification {
  if (operation === null || source === null || !isValidDispatch(source)) return "mismatch";
  const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]]));
  if (!isValidState(state)) return "mismatch";
  if (TERMINAL_STATUSES.has(state.status as string)) return "terminal";
  if (state.status === "active") return "active";

  const sourceId = deriveDispatchId(operation.operationId as string, "acquire", 0, 0);
  return isValidOperation(operation)
    && operation.createdAt === operation.updatedAt
    && operation.createdAt === source.createdAt
    && source.workerAck === null
    && source.dispatchId === sourceId
    && source.taskId === sourceId
    && source.operationId === operation.operationId
    && source.fingerprint === operation.fingerprint
    && source.boundary === "acquire"
    && source.generation === 0
    && source.sourceVersion === 0
    && source.ownerSeed === deriveOwnerToken(sourceId, 0)
    ? "pending"
    : "mismatch";
}

async function rereadPendingTerminalization(
  store: WorkerStore,
  deliveryDispatchId: string,
): Promise<PendingTerminalizationClassification> {
  return store.transaction(async (transaction) => {
    const source = await transaction.readDispatch(deliveryDispatchId);
    const operation = source === null ? null : await transaction.readOperation(source.operationId as string);
    return classifyPendingTerminalization(operation, source);
  });
}

function isExactActiveTerminalizationTuple(
  operation: PersistedRecord | null,
  source: PersistedRecord | null,
  observedAt: number,
): operation is PersistedRecord {
  if (operation === null || source === null || !isValidDispatch(source)) return false;
  const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
  if (!isValidState(state) || state.status !== "active" || state.leaseExpiresAt === null || state.leaseExpiresAt <= observedAt) return false;
  const expectedDispatchId = deriveDispatchId(state.operationId, state.phase, state.generation, state.version);
  const expectedOwnerToken = deriveOwnerToken(expectedDispatchId, state.generation);
  return source.workerAck === null
    && source.dispatchId === expectedDispatchId
    && source.taskId === expectedDispatchId
    && source.operationId === state.operationId
    && source.fingerprint === state.fingerprint
    && source.boundary === state.phase
    && source.generation === state.generation
    && source.sourceVersion === state.version
    && source.ownerSeed === expectedOwnerToken
    && state.currentDispatchId === expectedDispatchId
    && state.ownerToken === expectedOwnerToken;
}

function isExpiredExactCurrentTerminalizationTuple(
  operation: PersistedRecord | null,
  source: PersistedRecord | null,
  observedAt: number,
): boolean {
  return operation !== null
    && typeof operation.leaseExpiresAt === "number"
    && operation.leaseExpiresAt <= observedAt
    && isExactActiveTerminalizationTuple({ ...operation, leaseExpiresAt: observedAt + 1 }, source, observedAt);
}

function isExpiredRetainedTakeoverTerminalizationTuple(
  operation: PersistedRecord | null,
  source: PersistedRecord | null,
  observedAt: number,
): boolean {
  return operation !== null
    && typeof operation.leaseExpiresAt === "number"
    && operation.leaseExpiresAt <= observedAt
    && isRetainedTakeoverTerminalizationTuple({ ...operation, leaseExpiresAt: observedAt + 1 }, source, observedAt);
}

function isRetainedTakeoverTerminalizationTuple(
  operation: PersistedRecord | null,
  source: PersistedRecord | null,
  observedAt: number,
): operation is PersistedRecord {
  if (operation === null || source === null || !isValidDispatch(source)) return false;
  const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, operation[field]])) as unknown as OperationState;
  return isValidState(state)
    && state.status === "active"
    && state.leaseExpiresAt !== null
    && state.leaseExpiresAt > observedAt
    && source.workerAck === null
    && source.taskId === source.dispatchId
    && source.operationId === state.operationId
    && source.fingerprint === state.fingerprint
    && source.boundary === state.phase
    && source.ownerSeed === deriveOwnerToken(source.dispatchId as string, source.generation as number)
    && (source.generation as number) < state.generation
    && (source.sourceVersion as number) < state.version
    && state.currentDispatchId === source.dispatchId
    && state.ownerToken === deriveOwnerToken(source.dispatchId as string, state.generation);
}

/**
 * Atomically finalizes only a live, exact current active tuple. Preflight is
 * safe because no Auth call is in flight; every other active phase preserves
 * uncertainty as manual recovery. A stale or incomplete tuple is a no-op.
 */
export async function terminalizeActiveCurrent(
  store: WorkerStore,
  deliveryDispatchId: string,
  evidence: PendingTerminalizationEvidence,
): Promise<void> {
  if (!isPendingTerminalizationEvidence(evidence)) return;
  let terminalizeCommittedTakeover = false;
  for (let attempt = 0; attempt < CLOSED_TRANSACTION_MAX_ATTEMPTS; attempt += 1) {
    try {
      const decision = await store.transaction(async (transaction) => {
    const source = await transaction.readDispatch(deliveryDispatchId);
    if (source === null) return "no-op" as const;
    const operation = await transaction.readOperation(source.operationId as string);
    if (isPersistedTerminalOperation(operation)) return "terminal" as const;
    if (!terminalizeCommittedTakeover && (isExpiredExactCurrentTerminalizationTuple(operation, source, transaction.now)
      || isExpiredRetainedTakeoverTerminalizationTuple(operation, source, transaction.now))) return "expired" as const;
    const matchesTerminalizationTuple = terminalizeCommittedTakeover
      ? isRetainedTakeoverTerminalizationTuple(operation, source, transaction.now)
      : isExactActiveTerminalizationTuple(operation, source, transaction.now);
    if (!matchesTerminalizationTuple) return "no-op" as const;

    // The fresh decision read is the terminalization authority. Takeover has
    // already completed its separately committed authoritative reread.
    const rereadSource = source;
    const rereadOperation = operation;

    const state = Object.fromEntries(STATE_FIELDS.map((field) => [field, rereadOperation![field]])) as unknown as OperationState;
    const isSafePreflight = state.phase === "auth_preflight";
    const code = isSafePreflight ? "unavailable" : "internal";
    const audit = createAuditEvent({
      schemaVersion: 1,
      eventId: deriveAuditEventId(state.operationId, "failure", "terminal_failure", state.generation, state.version),
      operationId: state.operationId,
      correlationId: createHash("sha256").update(`provision-correlation:v1\0${state.operationId}`, "utf8").digest("hex"),
      category: "failure",
      stage: "terminal_failure",
      outcome: "failed",
      code,
      actorUidDigest: null,
      intendedUidDigest: null,
      dispatchId: rereadSource.dispatchId,
      generation: state.generation,
      sourceVersion: state.version,
      createdAt: transaction.now,
    });
    const existingAudit = await transaction.readAudit(audit.eventId);
    if (existingAudit !== null) deduplicateAudit(existingAudit, audit);

    const terminalOperation: PersistedRecord = {
      ...rereadOperation,
      status: isSafePreflight ? "failed" : "manual_recovery",
      phase: "terminal",
      version: state.version + 1,
      ownerToken: null,
      leaseExpiresAt: null,
      ...(isSafePreflight ? { terminalCode: "unavailable" } : { recoveryCode: "internal" }),
      failureEvidence: [{
        eventId: audit.eventId,
        boundary: rereadSource.boundary,
        code,
        class: isSafePreflight ? "infrastructure" : "recovery",
        generation: state.generation,
        version: state.version,
        recordedAt: transaction.now,
      }],
      retryEvidence: {
        committedFailureCount: 1,
        maxRetryCountSeen: evidence.retryCount,
        maxExecutionCountSeen: evidence.executionCount,
        lastRetryReasonCode: code,
      },
      updatedAt: transaction.now,
    };
    const terminalizedSource = { ...rereadSource, workerAck: "terminalized", workerAckAt: transaction.now };
    if (!isValidDispatchUpdate(rereadSource, terminalizedSource)) {
      throw new TypeError("invalid terminalized active source acknowledgement");
    }

      transaction.writeOperation(state.operationId, terminalOperation);
      transaction.writeDispatch(rereadSource.dispatchId as string, terminalizedSource);
    if (existingAudit === null) transaction.createAudit(audit.eventId, audit as unknown as PersistedRecord);
    return "terminal" as const;
      });
      if (decision === "terminal" || decision === "no-op") return;
      const takeover = await takeoverExpiredCurrent(store, deliveryDispatchId);
      if (takeover === null || "terminal" in takeover) return;
      terminalizeCommittedTakeover = true;
    } catch (error) {
      if (!isClosedFirestoreTransaction(error)) throw error;
      if (attempt + 1 === CLOSED_TRANSACTION_MAX_ATTEMPTS) throw new Error("closed Firestore transaction retry exhausted");
    }
  }
}

/**
 * Atomically finalizes only the original unacknowledged pending delivery when
 * the worker has proven that no Auth side effect was attempted. The terminal
 * record deliberately carries its failure and retry evidence; initial-only
 * schema guards are not reused to validate this terminal state.
 */
export async function terminalizeInitialPending(
  store: WorkerStore,
  deliveryDispatchId: string,
  evidence: PendingTerminalizationEvidence,
): Promise<boolean> {
  if (!isPendingTerminalizationEvidence(evidence)) return false;

  if (await terminalizeInitialPendingWithClosedTransactionRetry(store, deliveryDispatchId, evidence)) return true;
  const classification = await rereadPendingTerminalization(store, deliveryDispatchId);
  if (classification !== "pending") return classification === "terminal";

  // A second predicate loss is a successful no-op: no stale observation may
  // infer authority to write terminal state or acknowledge the dispatch.
  return terminalizeInitialPendingWithClosedTransactionRetry(store, deliveryDispatchId, evidence);
}

async function terminalizeInitialPendingWithClosedTransactionRetry(
    store: WorkerStore,
    deliveryDispatchId: string,
    evidence: PendingTerminalizationEvidence,
  ): Promise<boolean> {
    for (let attempt = 0; attempt < CLOSED_TRANSACTION_MAX_ATTEMPTS; attempt += 1) {
      try {
        return await terminalizeInitialPendingOnce(store, deliveryDispatchId, evidence);
      } catch (error) {
        if (!isClosedFirestoreTransaction(error)) throw error;
        if (attempt + 1 === CLOSED_TRANSACTION_MAX_ATTEMPTS) {
          throw new Error("closed Firestore transaction retry exhausted");
        }
      }
    }
    throw new Error("closed Firestore transaction retry exhausted");
  }

  async function terminalizeInitialPendingOnce(
  store: WorkerStore,
  deliveryDispatchId: string,
  evidence: PendingTerminalizationEvidence,
): Promise<boolean> {
  return store.transaction(async (transaction) => {
    const source = await transaction.readDispatch(deliveryDispatchId);
    if (source === null) return false;
    const operation = await transaction.readOperation(source.operationId as string);
    if (operation === null || classifyPendingTerminalization(operation, source) !== "pending") return false;

    const sourceId = deriveDispatchId(operation.operationId as string, "acquire", 0, 0);
    const audit = createAuditEvent({
      schemaVersion: 1,
      eventId: deriveAuditEventId(operation.operationId as string, "failure", "terminal_failure", 0, 0),
      operationId: operation.operationId,
      correlationId: createHash("sha256").update(`provision-correlation:v1\0${operation.operationId as string}`, "utf8").digest("hex"),
      category: "failure",
      stage: "terminal_failure",
      outcome: "failed",
      code: "unavailable",
      actorUidDigest: null,
      intendedUidDigest: null,
      dispatchId: sourceId,
      generation: 0,
      sourceVersion: 0,
      createdAt: transaction.now,
    });
    const existingAudit = await transaction.readAudit(audit.eventId);
    if (existingAudit !== null) deduplicateAudit(existingAudit, audit);

    const failedOperation: PersistedRecord = {
      ...operation,
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
        recordedAt: transaction.now,
      }],
      retryEvidence: {
        committedFailureCount: 1,
        maxRetryCountSeen: evidence.retryCount,
        maxExecutionCountSeen: evidence.executionCount,
        lastRetryReasonCode: "unavailable",
      },
      updatedAt: transaction.now,
    };
    const terminalizedSource = { ...source, workerAck: "terminalized", workerAckAt: transaction.now };
    if (!isValidDispatchUpdate(source, terminalizedSource)) {
      throw new TypeError("invalid terminalized source acknowledgement");
    }

    transaction.writeOperation(operation.operationId as string, failedOperation);
    transaction.writeDispatch(sourceId, terminalizedSource);
    if (existingAudit === null) transaction.createAudit(audit.eventId, audit as unknown as PersistedRecord);
    return true;
  });
}
