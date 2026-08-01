/**
 * P1a2-i-A-1a — Immutable vocabulary + genuine bidirectional type proof.
 * Consumes P1a1 via `import type` ONLY. No constructors, CAS, transitions.
 */
import type { ProvisioningStatus, ProvisioningPhase, StatusPhasePair, TerminalStatus, AuthAttemptResult } from "./types.js";
import type { NormalizedPayload } from "./normalize.js";

// ---- 12 event types (11 state-transition + 1 ack_dispatch) --------------
export const EVENT_TYPES = Object.freeze([
  "ack_dispatch", "acquire", "takeover", "auth_intent", "auth_start",
  "auth_confirm", "auth_no_effect", "auth_ambiguous", "auth_foreign_user",
  "auth_preflight", "profile_commit", "terminalize",
] as const);

export type EventType = (typeof EVENT_TYPES)[number];

// ---- Status → phase mapping (model-owned, compile-time constrained) ------
const _MAP = {
  pending: Object.freeze(["dispatch_pending"] as const),
  active: Object.freeze(["auth_preflight", "auth_create", "profile_commit"] as const),
  completed: Object.freeze(["terminal"] as const),
  failed: Object.freeze(["terminal"] as const),
  manual_recovery: Object.freeze(["terminal"] as const),
} as const satisfies Record<ProvisioningStatus, readonly ProvisioningPhase[]>;

export const STATUS_PHASE_MAP: Record<ProvisioningStatus, readonly ProvisioningPhase[]> = Object.freeze(_MAP);

/** Literal type of the status→phase map — for implementation-coupled compile-negative testing. */
export type _StatusPhaseMap = typeof _MAP;

// ---- Genuine bidirectional type proof ------------------------------------
/**
 * Generic: flatten a status→phase map into a union of {status, phase} pairs.
 * Relaxed domain accepts maps whose keys are a subset of ProvisioningStatus,
 * so a missing-key map is an admissible type argument. Exported so
 * compile-negative fixtures consume the exact mechanism used by production
 * assertions.
 */
export type _FlatFromMap<M extends Record<string, readonly ProvisioningPhase[]>> =
  { [S in keyof M & ProvisioningStatus]: { status: S; phase: M[S][number] } }[keyof M & ProvisioningStatus];

type RequireTrue<T extends true> = T;

/**
 * Generic proof: every canonical StatusPhasePair is in the map.
 * Relaxed constraint accepts maps with missing ProvisioningStatus keys
 * so the proof body is the sole error source. Exported so compile-negative
 * fixtures instantiate it with a modified map. Anti-vacuity: if weakened
 * to unconditional `true`, the missing-pair @ts-expect-error in tests
 * becomes unused → TS2578.
 */
export type _ProofNoMissing<M extends Record<string, readonly ProvisioningPhase[]>> =
  StatusPhasePair extends _FlatFromMap<M> ? true : false;

/**
 * Generic proof: every map entry IS a canonical StatusPhasePair.
 * Tight constraint (requires all ProvisioningStatus keys) because the
 * extra-pair map always has the full key set — only phase contents differ.
 * Exported so compile-negative fixtures instantiate it with a modified map.
 * Anti-vacuity: if weakened to unconditional `true`, the extra-pair
 * @ts-expect-error in tests becomes unused → TS2578.
 */
export type _ProofNoExtra<M extends Record<ProvisioningStatus, readonly ProvisioningPhase[]>> =
  _FlatFromMap<M> extends StatusPhasePair ? true : false;

type _Assert1 = RequireTrue<_ProofNoMissing<typeof _MAP>>;
type _Assert2 = RequireTrue<_ProofNoExtra<typeof _MAP>>;

// ---- TransitionResult discriminated union ---------------------------------
export type TransitionResult =
  | { readonly type: "success"; readonly state: OperationState }
  | { readonly type: "failure"; readonly reason: string };

// ---- Auth shapes ----------------------------------------------------------
export interface AuthProof { readonly attemptId: string; readonly confirmedAt: number; readonly uidRead: string; readonly emailRead: string; }
export interface AuthAttempt { readonly attemptId: string; readonly intentAt: number; readonly callStartedAt: number | null; readonly result: AuthAttemptResult; readonly returnedUid: string | null; readonly returnedEmail: string | null; readonly proof: AuthProof | null; }

// ---- OperationState interface ---------------------------------------------
export interface OperationState {
  readonly operationId: string; readonly fingerprint: string;
  readonly status: ProvisioningStatus; readonly phase: ProvisioningPhase;
  readonly normalizedPayload: Readonly<Record<string, unknown>>;
  readonly intendedUid: string | null; readonly generation: number; readonly version: number;
  readonly ownerToken: string | null; readonly leaseExpiresAt: number | null; readonly currentDispatchId: string | null;
  readonly authAttempted: boolean; readonly authAttempt: AuthAttempt | null;
  readonly createdAt: number; readonly updatedAt: number;
}

// ---- Derived terminal helper constants ------------------------------------
export const TERMINAL_STATUSES: readonly TerminalStatus[] = Object.freeze(["completed", "failed", "manual_recovery"]);
export const NON_TERMINAL_STATUSES: readonly ProvisioningStatus[] = Object.freeze(["pending", "active"]);

// ---- P1a2-i-A-1b: Descriptor-safe cycle-safe deep freeze ------------------
/**
 * Recursively freezes an object and all its nested children.
 *
 * Traversal is descriptor-based: uses {@link Object.getOwnPropertyDescriptors}
 * and {@link Reflect.ownKeys} to enumerate properties, which NEVER invokes
 * getter/accessor functions — including throwing getters.  Cycle-safe via
 * an internal {@link WeakSet}.
 *
 * Children are frozen BEFORE each parent via recursive postorder so that a
 * frozen parent implies all descendants are already frozen — correct even
 * for shared-reference DAGs.  If the parent is already frozen but contains
 * unfrozen descendants, those descendants are still traversed and frozen.
 */
export function deepFreeze<T>(obj: T): Readonly<T> {
  if (obj !== null && (typeof obj === "function" || typeof obj !== "object")) {
    return obj as unknown as Readonly<T>;
  }

  // Stack entries carry a shared seen-set so descendants of the same root
  // share cycle-tracking; each root starts a fresh WeakSet.
  const seen = new WeakSet<object>();
  const stack: object[] = [obj as object];
  const roots: object[] = [];

  // Phase 1: descriptor-based traversal — collect every reachable object
  while (stack.length > 0) {
    const current = stack.pop()!;
    if (current === null) continue;

    // Cycle guard
    if (seen.has(current as object)) continue;
    seen.add(current as object);
    roots.push(current as object);

    // Descriptor-based enumeration — NEVER invokes getters
    const descs = Object.getOwnPropertyDescriptors(current);
    for (const key of Reflect.ownKeys(current)) {
      const desc = descs[key as string];
      if (!desc) continue;

      // Accessor descriptor → skip (do NOT invoke the getter)
      if ("get" in desc || "set" in desc) continue;

      const val = (desc as PropertyDescriptor & { value?: unknown }).value;
      if (val !== null && typeof val === "object") {
        stack.push(val);
      }
    }
  }

  // Phase 2: recursive postorder freeze (children before each parent, DAG-safe)
  const frozen = new WeakSet<object>();
  function freezeNode(node: object): void {
    if (frozen.has(node)) return;
    frozen.add(node);
    const descs = Object.getOwnPropertyDescriptors(node);
    for (const key of Reflect.ownKeys(node)) {
      const desc = descs[key as string];
      if (!desc || "get" in desc || "set" in desc) continue;
      const val = (desc as PropertyDescriptor & { value?: unknown }).value;
      if (val !== null && typeof val === "object") freezeNode(val);
    }
    if (!Object.isFrozen(node)) Object.freeze(node);
  }
  for (let i = roots.length - 1; i >= 0; i--) freezeNode(roots[i]);

  return obj as unknown as Readonly<T>;
}
// ---- P1a2-i-A-1c: strict state guard -------------------------------------
const STATE_KEYS = Object.freeze([
  "operationId", "fingerprint", "status", "phase", "normalizedPayload",
  "intendedUid", "generation", "version", "ownerToken", "leaseExpiresAt",
  "currentDispatchId", "authAttempted", "authAttempt", "createdAt", "updatedAt",
] as const);
const PAYLOAD_KEYS = Object.freeze(["email","nombre","apellido1","apellido2","employeeId","weeklyHours","dni","telefono","cargo","departamento","empresa","scheduleId","calendarId","fechaInicio","fechaFin","role","isSupervisor","supervisorId","isActive","displayName"] as const);
const AUTH_ATTEMPT_KEYS = Object.freeze([
  "attemptId", "intentAt", "callStartedAt", "result", "returnedUid", "returnedEmail", "proof",
] as const);
const AUTH_PROOF_KEYS = Object.freeze(["attemptId", "confirmedAt", "uidRead", "emailRead"] as const);
const AUTH_ATTEMPT_RESULTS = Object.freeze(["intent", "call_started", "confirmed", "definite_no_effect", "ambiguous"] as const);
const UUID_V4_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
const SHA256_RE = /^[0-9a-f]{64}$/;
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;
function isPlainRecord(value: unknown): value is Record<PropertyKey, unknown> {
  if (value === null || typeof value !== "object" || Array.isArray(value)) return false;
  return Object.getPrototypeOf(value) === Object.prototype;
}
function hasExactFields(value: Record<PropertyKey, unknown>, fields: readonly string[]): boolean {
  const keys = Reflect.ownKeys(value);
  return keys.length === fields.length && keys.every((key) => typeof key === "string") && fields.every((field) => Object.hasOwn(value, field));
}
function isCanonicalText(value: unknown, empty = false): value is string {
  return typeof value === "string" && (empty || value.length > 0) && value === value.trim() && value === value.normalize("NFC");
}
function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.length > 0;
}
function isFirebaseUid(value: unknown): value is string {
  return typeof value === "string" && value.length > 0 && value.length <= 128;
}
function isNullableText(value: unknown): value is string | null {
  return value === null || isCanonicalText(value);
}
function isTimestamp(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value) && Number.isInteger(value) && value >= 0;
}
function isCounter(value: unknown): value is number {
  return isTimestamp(value) && Number.isInteger(value);
}
function isSha256(value: unknown): value is string {
  return typeof value === "string" && SHA256_RE.test(value);
}
function isDateOrNull(value: unknown): value is string | null {
  if (value === null) return true;
  if (!isCanonicalText(value) || !DATE_RE.test(value)) return false;
  const date = new Date(`${value}T00:00:00.000Z`);
  return !Number.isNaN(date.valueOf()) && date.toISOString().slice(0, 10) === value;
}
function isNormalizedPayload(value: unknown): value is NormalizedPayload {
  if (!isPlainRecord(value) || !hasExactFields(value, PAYLOAD_KEYS)) return false;
  const payload = value;
  if (!isCanonicalText(payload.email) || payload.email !== payload.email.toLowerCase() || !isCanonicalText(payload.nombre) || !isCanonicalText(payload.apellido1) || !isNullableText(payload.apellido2) || !isCanonicalText(payload.employeeId, true)) return false;
  if (typeof payload.weeklyHours !== "number" || !Number.isFinite(payload.weeklyHours) || payload.weeklyHours < 1 || payload.weeklyHours > 168 || !isNullableText(payload.dni) || !isNullableText(payload.telefono) || !isNullableText(payload.cargo) || !isNullableText(payload.departamento) || !isNullableText(payload.empresa) || !isNullableText(payload.scheduleId) || !isNullableText(payload.calendarId) || !isDateOrNull(payload.fechaInicio) || !isDateOrNull(payload.fechaFin)) return false;
  if ((payload.role !== "employee" && payload.role !== "rrhh") || typeof payload.isSupervisor !== "boolean" || !isNullableText(payload.supervisorId) || typeof payload.isActive !== "boolean" || !isCanonicalText(payload.displayName)) return false;
  return payload.displayName === [payload.nombre, payload.apellido1, payload.apellido2].filter((part): part is string => part !== null).join(" ");
}
function isAuthProof(value: unknown): value is AuthProof {
  if (!isPlainRecord(value) || !hasExactFields(value, AUTH_PROOF_KEYS)) return false;
  return isSha256(value.attemptId) && isTimestamp(value.confirmedAt) && isFirebaseUid(value.uidRead) && isNonEmptyString(value.emailRead);
}
function isAuthAttempt(value: unknown): value is AuthAttempt | null {
  if (value === null) return true;
  if (!isPlainRecord(value) || !hasExactFields(value, AUTH_ATTEMPT_KEYS)) return false;
  const proof = value.proof === null || isAuthProof(value.proof) ? value.proof : undefined;
  return isSha256(value.attemptId) && isTimestamp(value.intentAt)
    && (value.callStartedAt === null || isTimestamp(value.callStartedAt))
    && AUTH_ATTEMPT_RESULTS.includes(value.result as AuthAttemptResult)
    && (value.returnedUid === null || isFirebaseUid(value.returnedUid)) && (value.returnedEmail === null || isNonEmptyString(value.returnedEmail))
    && proof !== undefined && (proof === null || proof.attemptId === value.attemptId);
}
/** Returns whether value is one of the frozen accepted provisioning statuses. */
export function isStatus(value: unknown): value is ProvisioningStatus {
  return typeof value === "string" && Object.hasOwn(STATUS_PHASE_MAP, value);
}
/** Returns whether value is one of the frozen accepted provisioning phases. */
export function isPhase(value: unknown): value is ProvisioningPhase {
  return typeof value === "string"
    && Object.values(STATUS_PHASE_MAP).some((phases) => phases.includes(value as ProvisioningPhase));
}

/** Validates the complete persisted operation-state shape without coercion. */
export function isValidState(value: unknown): value is OperationState {
  if (!isPlainRecord(value) || !hasExactFields(value, STATE_KEYS)) return false;
  if (!isStatus(value.status) || !isPhase(value.phase) || !STATUS_PHASE_MAP[value.status].includes(value.phase)) return false;

  return typeof value.operationId === "string" && UUID_V4_RE.test(value.operationId)
    && isSha256(value.fingerprint) && isNormalizedPayload(value.normalizedPayload)
    && (value.intendedUid === null || isFirebaseUid(value.intendedUid)) && isCounter(value.generation) && isCounter(value.version)
    && (value.status === "active" ? isSha256(value.ownerToken) : value.ownerToken === null)
    && (value.leaseExpiresAt === null || isTimestamp(value.leaseExpiresAt))
    && (value.currentDispatchId === null || isSha256(value.currentDispatchId)) && typeof value.authAttempted === "boolean"
    && isAuthAttempt(value.authAttempt) && isTimestamp(value.createdAt) && isTimestamp(value.updatedAt);
}

// ---- P1a2-i-A-1d: strict event guard -------------------------------------
const EVENT_KEYS = Object.freeze(["eventId", "type", "payload"] as const);
const EVENT_PAYLOAD_FIELDS = Object.freeze({
  ack_dispatch: ["dispatchId"], acquire: ["ownerToken", "leaseExpiresAt"], takeover: ["ownerToken", "leaseExpiresAt"],
  auth_intent: ["attemptId", "intentAt"], auth_start: ["attemptId", "callStartedAt"],
  auth_confirm: ["attemptId", "returnedUid", "returnedEmail", "proof"], auth_no_effect: ["attemptId", "code"],
  auth_ambiguous: ["attemptId", "code"], auth_foreign_user: ["uid", "email"], auth_preflight: ["intendedUid", "email"],
  profile_commit: ["userId"], terminalize: ["terminalCode", "recoveryCode"],
} as const satisfies Record<EventType, readonly string[]>);

/** Returns whether value belongs to the frozen canonical event vocabulary. */
export function isEventType(value: unknown): value is EventType {
  return typeof value === "string" && EVENT_TYPES.includes(value as EventType);
}

/** Reads an exact plain-object field set without invoking accessors or leaking proxy traps. */
function readPlainOwnDataFields(value: unknown, fields: readonly string[]): Record<string, unknown> | null {
  try {
    if (value === null || typeof value !== "object" || Array.isArray(value) || Object.getPrototypeOf(value) !== Object.prototype) return null;
    const keys = Reflect.ownKeys(value);
    if (keys.length !== fields.length || keys.some((key) => typeof key !== "string" || !fields.includes(key))) return null;
    const result: Record<string, unknown> = {};
    for (const field of fields) {
      const descriptor = Object.getOwnPropertyDescriptor(value, field);
      if (descriptor === undefined || !("value" in descriptor)) return null;
      result[field] = descriptor.value;
    }
    return result;
  } catch { return null; }
}

function isValidEventPayload(type: EventType, value: unknown): boolean {
  const payload = readPlainOwnDataFields(value, EVENT_PAYLOAD_FIELDS[type]);
  if (payload === null) return false;
  switch (type) {
    case "ack_dispatch": return isSha256(payload.dispatchId);
    case "acquire": case "takeover": return isSha256(payload.ownerToken) && isTimestamp(payload.leaseExpiresAt);
    case "auth_intent": return isSha256(payload.attemptId) && isTimestamp(payload.intentAt);
    case "auth_start": return isSha256(payload.attemptId) && isTimestamp(payload.callStartedAt);
    case "auth_confirm": {
      const proof = readPlainOwnDataFields(payload.proof, AUTH_PROOF_KEYS);
      return proof !== null && isSha256(payload.attemptId) && isFirebaseUid(payload.returnedUid) && isNonEmptyString(payload.returnedEmail)
        && isSha256(proof.attemptId) && isTimestamp(proof.confirmedAt) && isFirebaseUid(proof.uidRead)
        && isNonEmptyString(proof.emailRead) && proof.attemptId === payload.attemptId;
    }
    case "auth_no_effect": case "auth_ambiguous": return isSha256(payload.attemptId) && isNonEmptyString(payload.code);
    case "auth_foreign_user": return isFirebaseUid(payload.uid) && isNonEmptyString(payload.email);
    case "auth_preflight": return isFirebaseUid(payload.intendedUid) && isNonEmptyString(payload.email);
    case "profile_commit": return isFirebaseUid(payload.userId);
    case "terminalize": return isNonEmptyString(payload.terminalCode) && isNonEmptyString(payload.recoveryCode);
  }
}

/** Validates the exact root and type-specific payload shape of a model event. */
export function isValidEvent(value: unknown): boolean {
  const event = readPlainOwnDataFields(value, EVENT_KEYS);
  return event !== null && isSha256(event.eventId)
    && isEventType(event.type) && isValidEventPayload(event.type, event.payload);
}

// ---- P1a2-i-A-2: validated non-transition constructors --------------------
export interface ModelEvent {
  readonly eventId: string;
  readonly type: EventType;
  readonly payload: Readonly<Record<string, unknown>>;
}

const CONSTRUCTOR_EVENT_ID = "0".repeat(64);

function canonicalizeInitialCreatedAt(params: unknown): unknown {
  if (!isPlainRecord(params) || !hasExactFields(params, STATE_KEYS) || !(params.createdAt instanceof Date)) {
    return params;
  }

  const createdAt = params.createdAt.valueOf();
  return isTimestamp(createdAt) ? { ...params, createdAt } : params;
}

/** Validates and deeply freezes an initial operation-state value. */
export function createInitialState(params: unknown): OperationState {
  const state = canonicalizeInitialCreatedAt(params);
  if (!isValidState(state)) throw new TypeError("Invalid initial operation state");
  return deepFreeze(state) as OperationState;
}

/** Validates and deeply freezes one canonical model event without transition behavior. */
export function createEvent(type: unknown, payload: unknown): ModelEvent {
  const event = { eventId: CONSTRUCTOR_EVENT_ID, type, payload };
  if (!isValidEvent(event)) throw new TypeError("Invalid model event");
  return deepFreeze(event) as ModelEvent;
}

/** Validates a complete state before returning a deeply frozen success result. */
export function createSuccessResult(state: unknown): TransitionResult {
  if (!isValidState(state)) throw new TypeError("Invalid success state");
  return deepFreeze({ type: "success" as const, state });
}

/** Creates a deeply frozen failure result for an existing non-empty reason string. */
export function createFailureResult(reason: unknown): TransitionResult {
  if (!isNonEmptyString(reason)) throw new TypeError("Failure reason must be a non-empty string");
  return deepFreeze({ type: "failure" as const, reason });
}
