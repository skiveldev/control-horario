/**
 * P1a1.1 — FIRST AUTHORED MUTATION: type-level validation of
 * (status, phase) vocabulary and valid-pair enforcement.
 *
 * RED: types.ts does not exist yet; import will fail.
 *
 * REMEDIATION (ordinal 25): Group 1 — Vocabulary + type-level contract.
 * Added boundary/result/category literal vocabulary, discriminated
 * StatusPhasePair union, and @ts-expect-error compile-time rejection.
 */

import {
  type ProvisioningStatus,
  type ProvisioningPhase,
  type TerminalStatus,
  type NonTerminalStatus,
  type ProvisioningBoundary,
  type AuthAttemptResult,
  type AuditCategory,
  type StatusPhasePair,
  VALID_STATUS_PHASE_PAIRS,
  isValidStatusPhasePair,
  makeStatusPhasePair,
  STATUS_VALUES,
  PHASE_VALUES,
  TERMINAL_STATUSES,
  BOUNDARY_VALUES,
  AUTH_ATTEMPT_RESULT_VALUES,
  AUDIT_CATEGORY_VALUES,
} from "../../src/provisioning/types.ts";

import { strict as assert } from "node:assert";
import { test } from "node:test";

// ---------------------------------------------------------------------------
// Vocabulary
// ---------------------------------------------------------------------------

test("ProvisioningStatus vocabulary is exactly the canonical set", () => {
  const expected: ProvisioningStatus[] = [
    "pending",
    "active",
    "completed",
    "failed",
    "manual_recovery",
  ];
  assert.deepStrictEqual([...STATUS_VALUES].sort(), [...expected].sort());
  assert.strictEqual(STATUS_VALUES.size, 5);
});

test("ProvisioningPhase vocabulary is exactly the canonical set", () => {
  const expected: ProvisioningPhase[] = [
    "dispatch_pending",
    "auth_preflight",
    "auth_create",
    "profile_commit",
    "terminal",
  ];
  assert.deepStrictEqual([...PHASE_VALUES].sort(), [...expected].sort());
  assert.strictEqual(PHASE_VALUES.size, 5);
});

test("TerminalStatus vocabulary is exactly {completed, failed, manual_recovery}", () => {
  const expected: TerminalStatus[] = ["completed", "failed", "manual_recovery"];
  assert.deepStrictEqual([...TERMINAL_STATUSES].sort(), [...expected].sort());
  assert.strictEqual(TERMINAL_STATUSES.size, 3);
});

test("NonTerminalStatus values are {pending, active}", () => {
  // imported type; validate via the valid-pair map keys
  const nonTerminal: ProvisioningStatus[] = ["pending", "active"];
  for (const s of nonTerminal) {
    assert.ok(VALID_STATUS_PHASE_PAIRS[s] !== undefined, `missing key: ${s}`);
  }
  // And the remaining keys are terminal
  const terminal: ProvisioningStatus[] = ["completed", "failed", "manual_recovery"];
  for (const s of terminal) {
    assert.ok(VALID_STATUS_PHASE_PAIRS[s] !== undefined, `missing key: ${s}`);
  }
  assert.strictEqual(Object.keys(VALID_STATUS_PHASE_PAIRS).length, 5);
});

// ---------------------------------------------------------------------------
// Valid pairs
// ---------------------------------------------------------------------------

test("pending + dispatch_pending is valid", () => {
  assert.strictEqual(isValidStatusPhasePair("pending", "dispatch_pending"), true);
});

test("active + auth_preflight is valid", () => {
  assert.strictEqual(isValidStatusPhasePair("active", "auth_preflight"), true);
});

test("active + auth_create is valid", () => {
  assert.strictEqual(isValidStatusPhasePair("active", "auth_create"), true);
});

test("active + profile_commit is valid", () => {
  assert.strictEqual(isValidStatusPhasePair("active", "profile_commit"), true);
});

test("completed + terminal is valid", () => {
  assert.strictEqual(isValidStatusPhasePair("completed", "terminal"), true);
});

test("failed + terminal is valid", () => {
  assert.strictEqual(isValidStatusPhasePair("failed", "terminal"), true);
});

test("manual_recovery + terminal is valid", () => {
  assert.strictEqual(isValidStatusPhasePair("manual_recovery", "terminal"), true);
});

// ---------------------------------------------------------------------------
// Invalid pairs — every invalid combination is rejected
// ---------------------------------------------------------------------------

const ALL_STATUSES: ProvisioningStatus[] = [
  "pending",
  "active",
  "completed",
  "failed",
  "manual_recovery",
];

const ALL_PHASES: ProvisioningPhase[] = [
  "dispatch_pending",
  "auth_preflight",
  "auth_create",
  "profile_commit",
  "terminal",
];

const VALID_PAIRS: Array<[ProvisioningStatus, ProvisioningPhase]> = [
  ["pending", "dispatch_pending"],
  ["active", "auth_preflight"],
  ["active", "auth_create"],
  ["active", "profile_commit"],
  ["completed", "terminal"],
  ["failed", "terminal"],
  ["manual_recovery", "terminal"],
];

const validSet = new Set(VALID_PAIRS.map(([s, p]) => `${s}|${p}`));

for (const status of ALL_STATUSES) {
  for (const phase of ALL_PHASES) {
    const pair = `${status}|${phase}`;
    if (validSet.has(pair)) continue; // skip valid pairs

    test(`INVALID pair: ${status} + ${phase} is rejected`, () => {
      assert.strictEqual(
        isValidStatusPhasePair(status, phase),
        false,
        `expected false for (${status}, ${phase})`,
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Edge: the pair map is immutable
// ---------------------------------------------------------------------------

test("VALID_STATUS_PHASE_PAIRS is a readonly record (frozen snapshot)", () => {
  assert.throws(() => {
    (VALID_STATUS_PHASE_PAIRS as Record<string, unknown>).newKey = [];
  });
});

// ---------------------------------------------------------------------------
// Group 1: Boundary / Result / Category vocabulary
// ---------------------------------------------------------------------------

test("ProvisioningBoundary vocabulary is exactly the canonical set", () => {
  const expected: ProvisioningBoundary[] = [
    "acquire",
    "auth_preflight",
    "auth_create",
    "profile_commit",
  ];
  assert.deepStrictEqual([...BOUNDARY_VALUES].sort(), [...expected].sort());
  assert.strictEqual(BOUNDARY_VALUES.size, 4);
});

test("AuthAttemptResult vocabulary is exactly the canonical set", () => {
  const expected: AuthAttemptResult[] = [
    "intent",
    "call_started",
    "confirmed",
    "definite_no_effect",
    "ambiguous",
  ];
  assert.deepStrictEqual([...AUTH_ATTEMPT_RESULT_VALUES].sort(), [...expected].sort());
  assert.strictEqual(AUTH_ATTEMPT_RESULT_VALUES.size, 5);
});

test("AuditCategory vocabulary is exactly the canonical set", () => {
  const expected: AuditCategory[] = [
    "authorization",
    "progress",
    "success",
    "failure",
  ];
  assert.deepStrictEqual([...AUDIT_CATEGORY_VALUES].sort(), [...expected].sort());
  assert.strictEqual(AUDIT_CATEGORY_VALUES.size, 4);
});

// ---------------------------------------------------------------------------
// Group 1: makeStatusPhasePair runtime validation
// ---------------------------------------------------------------------------

test("makeStatusPhasePair: valid pair succeeds", () => {
  const pair = makeStatusPhasePair("pending", "dispatch_pending");
  assert.strictEqual(pair.status, "pending");
  assert.strictEqual(pair.phase, "dispatch_pending");
});

test("makeStatusPhasePair: all 7 valid pairs succeed", () => {
  const pairs: Array<[ProvisioningStatus, ProvisioningPhase]> = [
    ["pending", "dispatch_pending"],
    ["active", "auth_preflight"],
    ["active", "auth_create"],
    ["active", "profile_commit"],
    ["completed", "terminal"],
    ["failed", "terminal"],
    ["manual_recovery", "terminal"],
  ];
  for (const [s, p] of pairs) {
    const pair = makeStatusPhasePair(s, p);
    assert.strictEqual(pair.status, s);
    assert.strictEqual(pair.phase, p);
  }
});

test("makeStatusPhasePair: runtime guard catches invalid pair", () => {
  // Use broad-typed variables so the compile-time constraint passes;
  // the runtime guard must still throw.
  const sPend = "pending" as ProvisioningStatus;
  const sAct = "active" as ProvisioningStatus;
  const sComp = "completed" as ProvisioningStatus;
  const pPre = "auth_preflight" as ProvisioningPhase;
  const pDisp = "dispatch_pending" as ProvisioningPhase;
  const pCre = "auth_create" as ProvisioningPhase;
  assert.throws(() => makeStatusPhasePair(sPend, pPre));
  assert.throws(() => makeStatusPhasePair(sAct, pDisp));
  assert.throws(() => makeStatusPhasePair(sComp, pCre));
});

// ---------------------------------------------------------------------------
// Group 1: Type-level @ts-expect-error — invalid pairs fail at compile time
// These MUST produce TS errors. npx tsc verifies them; node strips them.
// ---------------------------------------------------------------------------

// @ts-expect-error: pending + auth_preflight is not a valid StatusPhasePair
export const _invalidTypePair1: StatusPhasePair = { status: "pending", phase: "auth_preflight" };

// @ts-expect-error: active + dispatch_pending is not a valid StatusPhasePair
export const _invalidTypePair2: StatusPhasePair = { status: "active", phase: "dispatch_pending" };

// @ts-expect-error: completed + dispatch_pending is not a valid StatusPhasePair
export const _invalidTypePair3: StatusPhasePair = { status: "completed", phase: "dispatch_pending" };

// @ts-expect-error: failed + auth_preflight is not a valid StatusPhasePair
export const _invalidTypePair4: StatusPhasePair = { status: "failed", phase: "auth_preflight" };

// @ts-expect-error: manual_recovery + auth_create is not a valid StatusPhasePair
export const _invalidTypePair5: StatusPhasePair = { status: "manual_recovery", phase: "auth_create" };

// Valid pair MUST compile (no @ts-expect-error — proves the type accepts it)
export const _validTypePair: StatusPhasePair = { status: "pending", phase: "dispatch_pending" };

// ---------------------------------------------------------------------------
// Group 1 remediation: compile-time-safe pair constructor
// ts-expect-error tests against makeStatusPhasePair itself.
// These MUST error at compile time after the constructor is constrained.
// Before the constraint, the directives are UNUSED \u2192 tsc fails \u2192 genuine RED.
// Wrapped in a dead function so runtime execution never reaches them.
// ---------------------------------------------------------------------------

function _compileTimeCtorCheck(): void {
  // @ts-expect-error: makeStatusPhasePair("pending", "auth_preflight") invalid literal pair
  makeStatusPhasePair("pending", "auth_preflight");

  // @ts-expect-error: makeStatusPhasePair("active", "dispatch_pending") invalid literal pair
  makeStatusPhasePair("active", "dispatch_pending");

  // @ts-expect-error: makeStatusPhasePair("completed", "auth_create") invalid literal pair
  makeStatusPhasePair("completed", "auth_create");
}
void _compileTimeCtorCheck; // suppress unused warning
