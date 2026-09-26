import { createHash } from "node:crypto";
import { HttpsError } from "firebase-functions/v2/https";
import { deriveDispatchId, deriveOwnerToken } from "./ids.ts";
import type { NormalizedPayload } from "./normalize.ts";

export interface InitialSubmissionInput {
  readonly operationId: string;
  readonly fingerprint: string;
  readonly normalizedPayload: NormalizedPayload;
  readonly intendedUid: string;
  readonly submittedByDigest: string;
  readonly initialDispatchId: string;
  readonly initialOwnerSeed: string;
}

/** Domain transaction boundary; its adapter must commit operation and dispatch together. */
export interface InitialSubmissionTransaction {
  now(): number;
  readOperation(operationId: string): Promise<Record<string, unknown> | null>;
  createOperation(operation: Record<string, unknown>): void | Promise<void>;
  createDispatch(dispatch: Record<string, unknown>): void | Promise<void>;
}

export interface InitialSubmissionStore {
  transaction<T>(work: (transaction: InitialSubmissionTransaction) => Promise<T> | T): Promise<T>;
}

export interface SubmissionComposition {
  readonly normalize: (data: Record<string, unknown>) => NormalizedPayload;
  readonly fingerprint: (data: Record<string, unknown>) => string;
  readonly authorize: (callerUid: string | null, correlationId: string) => Promise<void>;
  readonly persist: (input: InitialSubmissionInput) => Promise<{ readonly operationId: string; readonly status: SubmissionStatus }>;
  readonly createIntendedUid: () => string;
}

type SubmissionStatus = "pending" | "active" | "completed" | "failed" | "manual_recovery";

function isSubmissionStatus(value: unknown): value is SubmissionStatus {
  return value === "pending" || value === "active" || value === "completed" || value === "failed" || value === "manual_recovery";
}

/** Canonicalizes a submission payload and maps all schema failures to the callable contract. */
export function validateSubmission(
  data: unknown,
  normalize: (input: Record<string, unknown>) => NormalizedPayload,
): NormalizedPayload {
  try {
    return normalize(data as Record<string, unknown>);
  } catch {
    throw new HttpsError("invalid-argument", "Invalid provisioning submission.");
  }
}

/** Composes validation, authorization, and durable pending submission without external effects. */
export async function submitProvisioningRequest(
  data: unknown,
  callerUid: string | null,
  composition: SubmissionComposition,
): Promise<{ readonly operationId: string; readonly status: SubmissionStatus }> {
  const normalizedPayload = validateSubmission(data, composition.normalize);
  const operationId = (data as Record<string, unknown>).operationId as string;
  await composition.authorize(
    callerUid,
    createHash("sha256").update(`provision-correlation:v1\0${operationId}`, "utf8").digest("hex"),
  );
  const initialDispatchId = deriveDispatchId(operationId, "acquire", 0, 0);
  return await composition.persist({
    operationId,
    fingerprint: composition.fingerprint(data as Record<string, unknown>),
    normalizedPayload,
    intendedUid: composition.createIntendedUid(),
    submittedByDigest: createHash("sha256").update(`provision-actor:v1\0${callerUid}`, "utf8").digest("hex"),
    initialDispatchId,
    initialOwnerSeed: deriveOwnerToken(initialDispatchId, 0),
  });
}

/** Atomically reserves a pending operation and its initial acquire outbox record. */
export async function persistInitialSubmission(
  input: InitialSubmissionInput,
  store: InitialSubmissionStore,
): Promise<{ readonly operationId: string; readonly status: SubmissionStatus }> {
  return store.transaction(async (transaction) => {
    const existing = await transaction.readOperation(input.operationId);
    if (existing !== null) {
      if (existing.fingerprint !== input.fingerprint) {
        throw new HttpsError("already-exists", "Provisioning operation already exists.");
      }
      if (!isSubmissionStatus(existing.status)) {
        throw new HttpsError("failed-precondition", "Provisioning operation has an invalid status.");
      }
      return { operationId: input.operationId, status: existing.status };
    }
    const createdAt = transaction.now();
    const { displayName: _displayName, ...normalizedPayload } = input.normalizedPayload;
    await transaction.createOperation({
      schemaVersion: 1,
      operationId: input.operationId,
      fingerprint: input.fingerprint,
      normalizedPayload,
      intendedUid: input.intendedUid,
      submittedByDigest: input.submittedByDigest,
      status: "pending",
      phase: "dispatch_pending",
      generation: 0,
      version: 0,
      ownerToken: null,
      leaseExpiresAt: null,
      currentDispatchId: null,
      authAttempted: false,
      authAttempt: null,
      createdAt,
      updatedAt: createdAt,
    });
    await transaction.createDispatch({
      schemaVersion: 1,
      dispatchId: input.initialDispatchId,
      taskId: input.initialDispatchId,
      operationId: input.operationId,
      fingerprint: input.fingerprint,
      boundary: "acquire",
      generation: 0,
      sourceVersion: 0,
      ownerSeed: input.initialOwnerSeed,
      enqueued: false,
      enqueuedAt: null,
      enqueueSource: null,
      enqueueEventId: null,
      workerAck: null,
      workerAckAt: null,
      createdAt,
    });

    return { operationId: input.operationId, status: "pending" };
  });
}
