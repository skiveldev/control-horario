/**
 * P1a1 — Canonical provisioning types.
 *
 * Statuses are exactly `pending | active | completed | failed | manual_recovery`.
 * Phases are exactly `dispatch_pending | auth_preflight | auth_create | profile_commit | terminal`.
 * Boundaries: `acquire | auth_preflight | auth_create | profile_commit`.
 * Auth attempt results: `intent | call_started | confirmed | definite_no_effect | ambiguous`.
 * Audit categories: `authorization | progress | success | failure`.
 *
 * Only valid (status, phase) pairs are permitted at compile time via the
 * discriminated `StatusPhasePair` union and at runtime via `isValidStatusPhasePair`.
 *
 * No persistence, no Firestore, no model, no reducer in P1a1.
 */

// ---------------------------------------------------------------------------
// Vocabulary literals
// ---------------------------------------------------------------------------

export const STATUS_VALUES = new Set([
  "pending",
  "active",
  "completed",
  "failed",
  "manual_recovery",
] as const);

export const PHASE_VALUES = new Set([
  "dispatch_pending",
  "auth_preflight",
  "auth_create",
  "profile_commit",
  "terminal",
] as const);

export const TERMINAL_STATUSES = new Set([
  "completed",
  "failed",
  "manual_recovery",
] as const);

/** Canonical dispatch boundaries per the design contract. */
export const BOUNDARY_VALUES = new Set([
  "acquire",
  "auth_preflight",
  "auth_create",
  "profile_commit",
] as const);

/** Canonical Auth attempt results. */
export const AUTH_ATTEMPT_RESULT_VALUES = new Set([
  "intent",
  "call_started",
  "confirmed",
  "definite_no_effect",
  "ambiguous",
] as const);

/** Canonical audit event categories. */
export const AUDIT_CATEGORY_VALUES = new Set([
  "authorization",
  "progress",
  "success",
  "failure",
] as const);

// ---------------------------------------------------------------------------
// Canonical type aliases
// ---------------------------------------------------------------------------

export type ProvisioningStatus = "pending" | "active" | "completed" | "failed" | "manual_recovery";
export type ProvisioningPhase = "dispatch_pending" | "auth_preflight" | "auth_create" | "profile_commit" | "terminal";
export type TerminalStatus = "completed" | "failed" | "manual_recovery";
export type NonTerminalStatus = "pending" | "active";
export type ProvisioningBoundary = "acquire" | "auth_preflight" | "auth_create" | "profile_commit";
export type AuthAttemptResult = "intent" | "call_started" | "confirmed" | "definite_no_effect" | "ambiguous";
export type AuditCategory = "authorization" | "progress" | "success" | "failure";

// ---------------------------------------------------------------------------
// Discriminated union: compile-time valid-pair contract
// ---------------------------------------------------------------------------

/**
 * Only valid (status, phase) combinations compile.
 * Invalid pairs are rejected at the type level.
 *
 * - `pending`       → only `dispatch_pending`
 * - `active`        → `auth_preflight | auth_create | profile_commit`
 * - terminal status → only `terminal`
 */
export type StatusPhasePair =
  | { readonly status: "pending"; readonly phase: "dispatch_pending" }
  | { readonly status: "active"; readonly phase: "auth_preflight" | "auth_create" | "profile_commit" }
  | { readonly status: "completed"; readonly phase: "terminal" }
  | { readonly status: "failed"; readonly phase: "terminal" }
  | { readonly status: "manual_recovery"; readonly phase: "terminal" };

// ---------------------------------------------------------------------------
// Valid (status, phase) pairs — runtime
// ---------------------------------------------------------------------------

const _VALID_PAIRS = {
  pending: ["dispatch_pending"],
  active: ["auth_preflight", "auth_create", "profile_commit"],
  completed: ["terminal"],
  failed: ["terminal"],
  manual_recovery: ["terminal"],
} as const satisfies Record<ProvisioningStatus, readonly ProvisioningPhase[]>;

export const VALID_STATUS_PHASE_PAIRS: Record<ProvisioningStatus, readonly ProvisioningPhase[]> =
  Object.freeze(_VALID_PAIRS);

/** Runtime predicate for (status, phase) pair validity. */
export function isValidStatusPhasePair(
  status: ProvisioningStatus,
  phase: ProvisioningPhase,
): boolean {
  const allowed = VALID_STATUS_PHASE_PAIRS[status] as readonly string[];
  return allowed.includes(phase);
}

// ---------------------------------------------------------------------------
// Phase-for-status mapping (compile-time constraint)
// ---------------------------------------------------------------------------

/** Narrows `phase` to only the values valid for a given `status`. */
type PhaseFor<S extends ProvisioningStatus> =
  S extends "pending" ? "dispatch_pending" :
  S extends "active" ? "auth_preflight" | "auth_create" | "profile_commit" :
  "terminal"; // completed | failed | manual_recovery

// ---------------------------------------------------------------------------
// Type-safe pair constructor
// ---------------------------------------------------------------------------

/**
 * Creates a `StatusPhasePair` with both compile-time and runtime validation.
 *
 * Invalid LITERAL pairs are rejected at compile time via the `PhaseFor<S>`
 * constraint.  Broad-typed variables fall through to the runtime guard.
 */
export function makeStatusPhasePair<S extends ProvisioningStatus>(
  status: S,
  phase: PhaseFor<S>,
): StatusPhasePair {
  if (!isValidStatusPhasePair(status, phase)) {
    throw new TypeError(`invalid (status, phase) pair: (${status}, ${phase})`);
  }
  return { status, phase } as unknown as StatusPhasePair;
}
