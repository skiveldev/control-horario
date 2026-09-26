/**
 * P1a1 — Deterministic ID derivation.
 *
 * All IDs use domain-separated SHA-256 with exact prefixes per the design contract:
 *   - dispatchId / taskId: `"provision-dispatch:v1\0" + operationId + "\0" + boundary + "\0" + generation + "\0" + sourceVersion`
 *   - auditEventId:         `"provision-audit:v1\0" + operationIdOrCorrelation + "\0" + category + "\0" + stage + "\0" + generation + "\0" + sourceVersion`
 *   - attemptId:            Dispatch ID used as the Auth attempt identity.
 *   - ownerToken:           Fencing digest from dispatch ID and generation.
 *   - fingerprint:          Generic SHA-256 lower-case hex of canonical input.
 *
 * All outputs are 64-character lower-case hex strings.
 */

import { createHash } from "node:crypto";

// ---------------------------------------------------------------------------
// Domain separators
// ---------------------------------------------------------------------------

const DISPATCH_PREFIX = "provision-dispatch:v1";
const AUDIT_PREFIX = "provision-audit:v1";

// ---------------------------------------------------------------------------
// Generic hash helper
// ---------------------------------------------------------------------------

function sha256hex(input: string): string {
  return createHash("sha256").update(input, "utf8").digest("hex");
}

// ---------------------------------------------------------------------------
// Dispatch / Task ID
// ---------------------------------------------------------------------------

/**
 * Dispatch ID (and task ID — they are equal per design).
 *
 * Format: `hexSha256("provision-dispatch:v1\0" + operationId + "\0" + boundary + "\0" + generation + "\0" + sourceVersion)`
 */
export function deriveDispatchId(
  operationId: string,
  boundary: string,
  generation: number,
  sourceVersion: number,
): string {
  const input = `${DISPATCH_PREFIX}\0${operationId}\0${boundary}\0${generation}\0${sourceVersion}`;
  return sha256hex(input);
}

/** Task ID equals dispatch ID (same derivation). */
export const deriveTaskId = deriveDispatchId;

// ---------------------------------------------------------------------------
// Audit Event ID
// ---------------------------------------------------------------------------

/**
 * Audit event ID.
 *
 * Format: `hexSha256("provision-audit:v1\0" + operationIdOrCorrelation + "\0" + category + "\0" + stage + "\0" + generation + "\0" + sourceVersion)`
 */
export function deriveAuditEventId(
  operationIdOrCorrelation: string,
  category: string,
  stage: string,
  generation: number,
  sourceVersion: number,
): string {
  const input = `${AUDIT_PREFIX}\0${operationIdOrCorrelation}\0${category}\0${stage}\0${generation}\0${sourceVersion}`;
  return sha256hex(input);
}

// ---------------------------------------------------------------------------
// Attempt ID
// ---------------------------------------------------------------------------

/**
 * Auth attempt ID. Reuses the dispatch ID as the attempt identity.
 * Never reused for a second create call.
 */
export function deriveAttemptId(
  operationId: string,
  generation: number,
  sourceVersion: number,
): string {
  return deriveDispatchId(operationId, "auth_create", generation, sourceVersion);
}

// ---------------------------------------------------------------------------
// Owner Token
// ---------------------------------------------------------------------------

/**
 * Owner token — fencing digest derived from dispatch ID and generation.
 * Opaque outside the worker.
 */
export function deriveOwnerToken(dispatchId: string, generation: number): string {
  const input = `${dispatchId}\0${generation}`;
  return sha256hex(input);
}

// ---------------------------------------------------------------------------
// Generic fingerprint
// ---------------------------------------------------------------------------

/**
 * Generic SHA-256 fingerprint of a canonical input string.
 * Returns lower-case hex.
 */
export function deriveFingerprint(input: string): string {
  return sha256hex(input);
}
