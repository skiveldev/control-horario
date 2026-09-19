const DIGEST = /^[a-f0-9]{64}$/;
const UUID_V4 = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
const KEYS = ["schemaVersion", "eventId", "operationId", "correlationId", "category", "stage", "outcome", "code", "actorUidDigest", "intendedUidDigest", "dispatchId", "generation", "sourceVersion", "createdAt"];
const APPLICATION_LOG_KEYS = ["eventCode", "resultCode", "reasonCode", "digests"];
const APPLICATION_LOG_DIGEST_KEYS = ["domain", "value"];
const CATEGORIES = new Set(["authorization", "progress", "success", "failure"]);
const STAGES = new Set(["denial", "state_transition", "auth_intent", "auth_result", "terminal_success", "terminal_failure", "stale_delivery", "completed_integrity"]);
const OUTCOMES = new Set(["denied", "started", "completed", "failed", "stale"]);
export const CANONICAL_CODE_VALUES = Object.freeze(["unauthenticated", "permission-denied", "invalid-argument", "already-exists", "not-found", "internal", "unavailable", "integrity-failed", "manual-recovery", "stale-dispatch", "retry-exhausted", "auth-intent", "auth-confirmed", "auth-ambiguous", "definite-no-effect", "success"] as const);
export const APPLICATION_LOG_DIGEST_DOMAINS = Object.freeze(["provision-actor:v1", "provision-audit:v1", "provision-dispatch:v1"] as const);
const CODES = new Set<string>(CANONICAL_CODE_VALUES);

export interface AuditEvent { readonly schemaVersion: 1; readonly eventId: string; readonly operationId: string | null; readonly correlationId: string; readonly category: string; readonly stage: string; readonly outcome: string; readonly code: string; readonly actorUidDigest: string | null; readonly intendedUidDigest: string | null; readonly dispatchId: string | null; readonly generation: number | null; readonly sourceVersion: number | null; readonly createdAt: number; }
export interface ApplicationLogDigest { readonly domain: (typeof APPLICATION_LOG_DIGEST_DOMAINS)[number]; readonly value: string; }
export interface ApplicationLog { readonly eventCode: (typeof CANONICAL_CODE_VALUES)[number]; readonly resultCode: (typeof CANONICAL_CODE_VALUES)[number] | null; readonly reasonCode: (typeof CANONICAL_CODE_VALUES)[number] | null; readonly digests: readonly ApplicationLogDigest[]; }

function exact(value: unknown, keys: readonly string[]): Record<string, unknown> | null {
  try {
    if (value === null || typeof value !== "object" || Array.isArray(value) || Object.getPrototypeOf(value) !== Object.prototype) return null;
    const own = Reflect.ownKeys(value); const descriptors = Object.getOwnPropertyDescriptors(value);
    if (own.length !== keys.length || own.some((key) => typeof key !== "string" || !keys.includes(key))) return null;
    return keys.every((key) => key in descriptors && "value" in descriptors[key]!) ? Object.fromEntries(keys.map((key) => [key, descriptors[key]!.value])) : null;
  } catch { return null; }
}
const nullableDigest = (value: unknown): boolean => value === null || typeof value === "string" && DIGEST.test(value);
const nullableNonNegativeInteger = (value: unknown): boolean => value === null || typeof value === "number" && Number.isInteger(value) && value >= 0;

/** Accepts only the fixed, PII-free persisted audit contract. */
export function isValidAuditEvent(value: unknown): value is AuditEvent {
  const event = exact(value, KEYS);
  return event !== null && event.schemaVersion === 1 && typeof event.eventId === "string" && DIGEST.test(event.eventId)
    && (event.operationId === null || typeof event.operationId === "string" && UUID_V4.test(event.operationId))
    && typeof event.correlationId === "string" && DIGEST.test(event.correlationId)
    && CATEGORIES.has(event.category as string) && STAGES.has(event.stage as string) && OUTCOMES.has(event.outcome as string) && CODES.has(event.code as string)
    && nullableDigest(event.actorUidDigest) && nullableDigest(event.intendedUidDigest) && nullableDigest(event.dispatchId)
    && nullableNonNegativeInteger(event.generation) && nullableNonNegativeInteger(event.sourceVersion)
    && typeof event.createdAt === "number" && Number.isInteger(event.createdAt) && event.createdAt >= 0;
}

/** Creates an immutable audit value only after the full PII-safe contract passes. */
export function createAuditEvent(value: unknown): AuditEvent {
  if (!isValidAuditEvent(value)) throw new TypeError("invalid audit event");
  return Object.freeze({ ...value });
}

/** Returns the persisted event on an idempotent retry and rejects every identity drift. */
export function deduplicateAudit(existing: unknown, candidate: unknown): AuditEvent {
  if (!isValidAuditEvent(existing) || !isValidAuditEvent(candidate)) throw new TypeError("invalid audit event");
  const recorded = existing as unknown as Record<string, unknown>;
  const retry = candidate as unknown as Record<string, unknown>;
  if (KEYS.some((key) => key !== "createdAt" && recorded[key] !== retry[key])) throw new Error("audit identity mismatch");
  return existing;
}

/** Validates the bounded application-log projection without extending the audit record. */
export function isValidApplicationLog(value: unknown): value is ApplicationLog {
  const log = exact(value, APPLICATION_LOG_KEYS);
  if (!log || !CODES.has(log.eventCode as string) || !Array.isArray(log.digests) || log.digests.length === 0) return false;
  if (![log.resultCode, log.reasonCode].every((code) => code === null || CODES.has(code as string))) return false;
  return log.digests.every((digest) => {
    const entry = exact(digest, APPLICATION_LOG_DIGEST_KEYS);
    return entry !== null
      && APPLICATION_LOG_DIGEST_DOMAINS.includes(entry.domain as (typeof APPLICATION_LOG_DIGEST_DOMAINS)[number])
      && typeof entry.value === "string" && DIGEST.test(entry.value);
  });
}

/** Creates an immutable log payload with codes and tagged digests only. */
export function createApplicationLog(value: unknown): ApplicationLog {
  if (!isValidApplicationLog(value)) throw new TypeError("invalid application log");
  const log = value as ApplicationLog;
  return Object.freeze({
    eventCode: log.eventCode,
    resultCode: log.resultCode,
    reasonCode: log.reasonCode,
    digests: Object.freeze(log.digests.map((digest) => Object.freeze({ ...digest }))),
  });
}
