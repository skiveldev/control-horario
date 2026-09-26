import { createHash } from "node:crypto";
import { type AuditEvent } from "./audit.ts";
import { projectStatusDto, type SafeStatusDto } from "./dto.ts";
import { deriveAuditEventId } from "./ids.ts";
import { matchesProfileProvenance, type ProfileExpectation } from "./profile.ts";
import { canonicalPayloadKeys, deriveDisplayName, type NormalizedPayload } from "./normalize.ts";

export type StatusAuthorizationCode =
  | "unauthenticated"
  | "permission-denied"
  | "not-found"
  | "already-exists";

export type StatusProjectionCode = "invalid-projection";
export type CompletedIntegrityCode = "integrity-failed";
export type PasswordResetLinkCode = "unavailable";

interface AuthorizedStatusOperation {
  readonly fingerprint: string;
}

export interface StatusAuthorizationRequest {
  readonly callerUid: string | null;
  readonly operationId: string;
  readonly fingerprint?: string;
}

export interface StatusAuthorizationPort {
  readUser(uid: string): Promise<{ readonly role: string; readonly isActive: boolean } | null>;
  readOperation(operationId: string): Promise<{ readonly fingerprint: string } | null>;
}

export class StatusAuthorizationError extends Error {
  readonly code: StatusAuthorizationCode;

  constructor(code: StatusAuthorizationCode) {
    super(code);
    this.code = code;
  }
}

export class StatusProjectionError extends Error {
  readonly code: StatusProjectionCode;

  constructor(code: StatusProjectionCode) {
    super(code);
    this.code = code;
  }
}

export class CompletedIntegrityError extends Error {
  readonly code: CompletedIntegrityCode = "integrity-failed";

  constructor() {
    super("integrity-failed");
  }
}

/** Stable retryable failure for a transient Auth reset-link rejection. */
export class PasswordResetLinkError extends Error {
  readonly code: PasswordResetLinkCode = "unavailable";

  constructor() {
    super("unavailable");
  }
}

export interface CompletedIntegrityPort {
  readAuthByUid(uid: string): Promise<{ readonly uid: string; readonly email: string } | null>;
  readAuthByEmail(email: string): Promise<{ readonly uid: string; readonly email: string } | null>;
  readProfile(uid: string): Promise<unknown | null>;
  recordCompletedIntegrityAudit(event: AuditEvent): Promise<void>;
}

/** Auth capability deliberately limited to immediate reset-link generation. */
export interface PasswordResetLinkGenerator {
  generatePasswordResetLink(email: string): Promise<string>;
}

/**
 * Authorizes a status lookup without mutating a provisioning record or audit log.
 * The caller receives only the status DTO projection; completed-resource integrity
 * and reset-link handling remain outside this narrow status boundary.
 */
export async function authorizeStatusRequest(
  request: StatusAuthorizationRequest,
  port: StatusAuthorizationPort,
): Promise<AuthorizedStatusOperation> {
  if (request.callerUid === null) {
    throw new StatusAuthorizationError("unauthenticated");
  }

  const user = await port.readUser(request.callerUid);
  if (user?.role !== "admin" || user.isActive !== true) {
    throw new StatusAuthorizationError("permission-denied");
  }

  const operation = await port.readOperation(request.operationId);
  if (operation === null) {
    throw new StatusAuthorizationError("not-found");
  }

  if (request.fingerprint !== undefined && request.fingerprint !== operation.fingerprint) {
    throw new StatusAuthorizationError("already-exists");
  }

  return operation;
}

/** Returns only the immutable DTO that the current persisted status can safely expose. */
export async function getAuthorizedStatus(
  request: StatusAuthorizationRequest,
  port: StatusAuthorizationPort,
): Promise<SafeStatusDto> {
  const operation = await authorizeStatusRequest(request, port);
  const status = projectStatusDto(operation);
  if (status === null) throw new StatusProjectionError("invalid-projection");
  return status;
}

function data(value: unknown): Record<string, unknown> | null {
  try {
    if (value === null || typeof value !== "object" || Array.isArray(value)
      || Object.getPrototypeOf(value) !== Object.prototype) return null;
    const descriptors = Object.getOwnPropertyDescriptors(value);
    return Object.values(descriptors).every((descriptor) => "value" in descriptor) ? value as Record<string, unknown> : null;
  } catch { return null; }
}

function persistedNormalizedPayload(value: unknown): Readonly<NormalizedPayload> | null {
  const payload = data(value);
  let ownKeys: readonly PropertyKey[];
  try { ownKeys = Reflect.ownKeys(value as object); } catch { return null; }
  if (payload === null || ownKeys.length !== canonicalPayloadKeys.length
    || ownKeys.some((key) => typeof key !== "string" || !canonicalPayloadKeys.includes(key))) return null;
  if (typeof payload.email !== "string" || typeof payload.nombre !== "string"
    || typeof payload.apellido1 !== "string" || typeof payload.employeeId !== "string"
    || !Number.isFinite(payload.weeklyHours) || !["employee", "rrhh"].includes(payload.role as string)
    || typeof payload.isSupervisor !== "boolean" || typeof payload.isActive !== "boolean") return null;
  for (const field of ["apellido2", "dni", "telefono", "cargo", "departamento", "empresa", "scheduleId", "calendarId", "fechaInicio", "fechaFin", "supervisorId"]) {
    if (payload[field] !== null && typeof payload[field] !== "string") return null;
  }
  return {
    ...payload,
    displayName: deriveDisplayName(payload.nombre, payload.apellido1, payload.apellido2 as string | null),
  } as Readonly<NormalizedPayload>;
}

interface CompletedIntegrityExpectation extends ProfileExpectation {
  readonly generation: number;
  readonly version: number;
  readonly completedAt: number;
}

function completedExpectation(operation: unknown): CompletedIntegrityExpectation | null {
  const value = data(operation);
  const payload = persistedNormalizedPayload(value?.normalizedPayload);
  const generation = value?.generation;
  const version = value?.version;
  const createdAt = value?.createdAt;
  const updatedAt = value?.updatedAt;
  if (value === null || payload === null || typeof value.operationId !== "string" || typeof value.fingerprint !== "string"
    || typeof value.intendedUid !== "string" || value.intendedUid.length === 0 || value.status !== "completed"
    || value.phase !== "terminal" || typeof generation !== "number" || !Number.isInteger(generation)
    || typeof version !== "number" || !Number.isInteger(version) || typeof createdAt !== "number"
    || !Number.isInteger(createdAt) || typeof updatedAt !== "number" || !Number.isInteger(updatedAt)
    || generation < 0 || version < 0 || createdAt < 0 || updatedAt < createdAt) return null;
  return { intendedUid: value.intendedUid, operationId: value.operationId, fingerprint: value.fingerprint,
    schemaVersion: 1, normalizedPayload: payload, generation, version, completedAt: updatedAt };
}

function integrityAudit(expected: CompletedIntegrityExpectation): AuditEvent {
  const correlationId = createHash("sha256").update(`provision-correlation:v1\0${expected.operationId}`, "utf8").digest("hex");
  return { schemaVersion: 1, eventId: deriveAuditEventId(expected.operationId, "failure", "completed_integrity", expected.generation, expected.version), operationId: expected.operationId, correlationId, category: "failure", stage: "completed_integrity", outcome: "failed", code: "integrity-failed", actorUidDigest: null, intendedUidDigest: null, dispatchId: null, generation: expected.generation, sourceVersion: expected.version, createdAt: expected.completedAt };
}

/** Rechecks immutable completed resources before later reset-link issuance. */
async function resolveStatusWithCompletedIntegrity(
  request: StatusAuthorizationRequest,
  authorization: StatusAuthorizationPort,
  integrity: CompletedIntegrityPort,
): Promise<{ readonly status: SafeStatusDto; readonly resetEmail: string | null }> {
  const operation = await authorizeStatusRequest(request, authorization);
  const status = projectStatusDto(operation);
  if (status === null) throw new StatusProjectionError("invalid-projection");
  if (status.status !== "completed") return { status, resetEmail: null };

  const expected = completedExpectation(operation);
  try {
    if (expected === null) throw new Error("invalid completed operation");
    const [uidRead, emailRead, profileRead] = await Promise.allSettled([
      integrity.readAuthByUid(expected.intendedUid),
      integrity.readAuthByEmail(expected.normalizedPayload.email),
      integrity.readProfile(expected.intendedUid),
    ]);

    if (uidRead.status !== "fulfilled" || emailRead.status !== "fulfilled" || profileRead.status !== "fulfilled"
          || uidRead.value === null || emailRead.value === null || uidRead.value.uid !== expected.intendedUid
      || emailRead.value.uid !== expected.intendedUid || uidRead.value.email !== expected.normalizedPayload.email
      || emailRead.value.email !== expected.normalizedPayload.email
          || !matchesProfileProvenance(profileRead.value, expected)) {
      throw new Error("completed integrity mismatch");
    }
    return { status, resetEmail: expected.normalizedPayload.email };
  } catch {
    if (expected !== null) {
      try { await integrity.recordCompletedIntegrityAudit(integrityAudit(expected)); } catch { /* fail closed */ }
    }
    throw new CompletedIntegrityError();
  }
}

export async function getAuthorizedStatusWithCompletedIntegrity(
  request: StatusAuthorizationRequest,
  authorization: StatusAuthorizationPort,
  integrity: CompletedIntegrityPort,
): Promise<SafeStatusDto> {
  return (await resolveStatusWithCompletedIntegrity(request, authorization, integrity)).status;
}

/** Returns a generated link only after the completed integrity boundary succeeds. */
export async function getAuthorizedStatusWithPasswordResetLink(
  request: StatusAuthorizationRequest,
  authorization: StatusAuthorizationPort,
  integrity: CompletedIntegrityPort,
  generator: PasswordResetLinkGenerator,
): Promise<SafeStatusDto | Readonly<{ passwordResetLink: string } & Extract<SafeStatusDto, { status: "completed" }>>> {
  const { status, resetEmail } = await resolveStatusWithCompletedIntegrity(request, authorization, integrity);
  if (resetEmail === null) return status;
  try {
    const passwordResetLink = await generator.generatePasswordResetLink(resetEmail);
    if (typeof passwordResetLink !== "string" || passwordResetLink.trim().length === 0) {
      throw new PasswordResetLinkError();
    }
    return Object.freeze({ ...status, passwordResetLink });
  } catch {
    throw new PasswordResetLinkError();
  }
}
