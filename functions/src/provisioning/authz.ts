import { createHash } from "node:crypto";
import type { AuditEvent } from "./audit.ts";

const DIGEST = /^[a-f0-9]{64}$/;

export type AuthorizationCode = "unauthenticated" | "permission-denied";

export interface AuthorizationRequest {
  readonly callerUid: string | null;
  readonly correlationId: string;
}

export interface AuthorizationProfile {
  readonly role: string;
  readonly isActive: boolean;
}

/** Persistence boundary for authorization reads and the sole denial write. */
export interface AuthorizationPort {
  readUser(uid: string): Promise<AuthorizationProfile | null>;
  writeDenialAudit(event: AuditEvent): Promise<void>;
  now(): number;
}

export class AuthorizationError extends Error {
  readonly code: AuthorizationCode;

  constructor(code: AuthorizationCode) {
    super(code);
    this.code = code;
  }
}

function actorUidDigest(uid: string | null): string | null {
  return uid === null ? null : sha256(`provision-actor:v1\0${uid}`);
}

function sha256(input: string): string {
  return createHash("sha256").update(input, "utf8").digest("hex");
}

function denialEvent(request: AuthorizationRequest, code: AuthorizationCode, createdAt: number): AuditEvent {
  return {
    schemaVersion: 1,
    eventId: sha256(`provision-audit:v1\0${request.correlationId}\0authorization\0denial\0${0}\0${0}`),
    operationId: null,
    correlationId: request.correlationId,
    category: "authorization",
    stage: "denial",
    outcome: "denied",
    code,
    actorUidDigest: actorUidDigest(request.callerUid),
    intendedUidDigest: null,
    dispatchId: null,
    generation: null,
    sourceVersion: null,
    createdAt,
  };
}

async function deny(
  code: AuthorizationCode,
  request: AuthorizationRequest,
  port: AuthorizationPort,
): Promise<never> {
  if (!DIGEST.test(request.correlationId)) throw new TypeError("invalid correlation ID");
  await port.writeDenialAudit(denialEvent(request, code, port.now()));
  throw new AuthorizationError(code);
}

/** Authorizes an active admin and records every entered denial before returning it. */
export async function authorizeAdmin(
  request: AuthorizationRequest,
  port: AuthorizationPort,
): Promise<void> {
  if (request.callerUid === null) return await deny("unauthenticated", request, port);

  const profile = await port.readUser(request.callerUid);
  if (profile?.role !== "admin" || profile.isActive !== true) {
    await deny("permission-denied", request, port);
  }
}
