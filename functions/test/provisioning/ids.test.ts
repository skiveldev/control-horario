/**
 * P1a1.8 RED — Deterministic ID derivation vectors.
 *
 * RED: ids.ts does not exist yet; import will fail.
 *
 * Tests for:
 *   - dispatchId / taskId (same value per design)
 *   - auditEventId
 *   - attemptId
 *   - ownerToken
 *   - fingerprint derivation
 *   - Domain separators produce distinct outputs
 *   - Deterministic: same inputs → same output
 *   - Distinct inputs produce distinct outputs
 */

import {
  deriveDispatchId,
  deriveTaskId,
  deriveAuditEventId,
  deriveAttemptId,
  deriveOwnerToken,
  deriveFingerprint,
} from "../../src/provisioning/ids.ts";

import { strict as assert } from "node:assert";
import { test } from "node:test";

// ---------------------------------------------------------------------------
// Determinism: same inputs → same output
// ---------------------------------------------------------------------------

test("dispatchId is deterministic", () => {
  const a = deriveDispatchId("op-1", "acquire", 0, 0);
  const b = deriveDispatchId("op-1", "acquire", 0, 0);
  assert.strictEqual(a, b);
  assert.strictEqual(a.length, 64);
  assert.ok(/^[0-9a-f]{64}$/.test(a));
});

test("taskId equals dispatchId", () => {
  const d = deriveDispatchId("op-1", "auth_create", 2, 0);
  const t = deriveTaskId("op-1", "auth_create", 2, 0);
  assert.strictEqual(t, d);
});

test("auditEventId is deterministic", () => {
  const a = deriveAuditEventId("op-1", "success", "completed", 1, 0);
  const b = deriveAuditEventId("op-1", "success", "completed", 1, 0);
  assert.strictEqual(a, b);
  assert.strictEqual(a.length, 64);
  assert.ok(/^[0-9a-f]{64}$/.test(a));
});

test("attemptId is deterministic", () => {
  const a = deriveAttemptId("op-1", 0, 0);
  const b = deriveAttemptId("op-1", 0, 0);
  assert.strictEqual(a, b);
});

test("ownerToken is deterministic", () => {
  const a = deriveOwnerToken("dispatch-id-hex", 1);
  const b = deriveOwnerToken("dispatch-id-hex", 1);
  assert.strictEqual(a, b);
});

test("deriveFingerprint is deterministic", () => {
  const payload = JSON.stringify({ email: "a@b.com" });
  const a = deriveFingerprint(payload);
  const b = deriveFingerprint(payload);
  assert.strictEqual(a, b);
});

// ---------------------------------------------------------------------------
// Distinct inputs produce distinct outputs
// ---------------------------------------------------------------------------

test("different operationId → different dispatchId", () => {
  const a = deriveDispatchId("op-a", "acquire", 0, 0);
  const b = deriveDispatchId("op-b", "acquire", 0, 0);
  assert.notStrictEqual(a, b);
});

test("different boundary → different dispatchId", () => {
  const a = deriveDispatchId("op-1", "acquire", 0, 0);
  const b = deriveDispatchId("op-1", "auth_preflight", 0, 0);
  assert.notStrictEqual(a, b);
});

test("different generation → different dispatchId", () => {
  const a = deriveDispatchId("op-1", "acquire", 0, 0);
  const b = deriveDispatchId("op-1", "acquire", 1, 0);
  assert.notStrictEqual(a, b);
});

test("different sourceVersion → different dispatchId", () => {
  const a = deriveDispatchId("op-1", "acquire", 0, 0);
  const b = deriveDispatchId("op-1", "acquire", 0, 1);
  assert.notStrictEqual(a, b);
});

test("different category → different auditEventId", () => {
  const a = deriveAuditEventId("op-1", "success", "completed", 1, 0);
  const b = deriveAuditEventId("op-1", "failure", "completed", 1, 0);
  assert.notStrictEqual(a, b);
});

test("different stage → different auditEventId", () => {
  const a = deriveAuditEventId("op-1", "success", "completed", 1, 0);
  const b = deriveAuditEventId("op-1", "success", "auth_create", 1, 0);
  assert.notStrictEqual(a, b);
});

test("different generation → different auditEventId", () => {
  const a = deriveAuditEventId("op-1", "success", "completed", 1, 0);
  const b = deriveAuditEventId("op-1", "success", "completed", 2, 0);
  assert.notStrictEqual(a, b);
});

test("different dispatch → different ownerToken", () => {
  const a = deriveOwnerToken("dispatch-a", 1);
  const b = deriveOwnerToken("dispatch-b", 1);
  assert.notStrictEqual(a, b);
});

test("different generation → different ownerToken", () => {
  const a = deriveOwnerToken("dispatch-id", 1);
  const b = deriveOwnerToken("dispatch-id", 2);
  assert.notStrictEqual(a, b);
});

// ---------------------------------------------------------------------------
// Domain separator uniqueness
// ---------------------------------------------------------------------------

test("domain separators produce distinct outputs for same inputs", () => {
  const opId = "same-op-id";
  const dispatch = deriveDispatchId(opId, "acquire", 0, 0);
  const audit = deriveAuditEventId(opId, "authorization", "denial", 1, 0);
  const attempt = deriveAttemptId(opId, 0, 0);
  // All three should be different because of different domain separators
  assert.notStrictEqual(dispatch, audit);
  assert.notStrictEqual(dispatch, attempt);
  assert.notStrictEqual(audit, attempt);
});

// ---------------------------------------------------------------------------
// Group 4: Precomputed literal vectors — guards against domain separator drift
// Expected values computed independently, not by production helpers.
// If domain separators change, these exact values WILL break.
// ---------------------------------------------------------------------------

const OP = "00000000-0000-4000-a000-000000000001";
const DISPATCH_ACQUIRE = "d8c2bea7bd64e52bc0bd069d10127d36a9fc4b3df7b77c1b875d368bf3f4419f";

test("dispatchId: precomputed literal (acquire, gen=0, sv=0)", () => {
  assert.strictEqual(deriveDispatchId(OP, "acquire", 0, 0), DISPATCH_ACQUIRE);
});

test("dispatchId: precomputed literal (auth_preflight, gen=0, sv=0)", () => {
  assert.strictEqual(
    deriveDispatchId(OP, "auth_preflight", 0, 0),
    "e1e709bdb479aa298ed2c7d7b9cb05ae9cc08f8c60c1728ad675f760242dcfd2",
  );
});

test("dispatchId: precomputed literal (auth_create, gen=0, sv=0)", () => {
  assert.strictEqual(
    deriveDispatchId(OP, "auth_create", 0, 0),
    "356d6a5176f3c467edf3cc62c5dc6e53f09ec473c9543b40879e83a29d926bc1",
  );
});

test("dispatchId: precomputed literal (profile_commit, gen=0, sv=0)", () => {
  assert.strictEqual(
    deriveDispatchId(OP, "profile_commit", 0, 0),
    "c0e79bdf923f6bcc438e6c36a8f7cfd456c3a6440528cadbc33fe009f37a77c8",
  );
});

test("dispatchId: precomputed literal (acquire, gen=1, sv=0)", () => {
  assert.strictEqual(
    deriveDispatchId(OP, "acquire", 1, 0),
    "b28c34804fb2c1f20c43ffabf534389496a5cfe562cd641c43970738cb5136ec",
  );
});

test("dispatchId: precomputed literal (acquire, gen=0, sv=1)", () => {
  assert.strictEqual(
    deriveDispatchId(OP, "acquire", 0, 1),
    "31d98233dd690b4d3212d2f12e7adbc02010d1b1f90d7c7aea3107e5c14f2a48",
  );
});

test("taskId: precomputed literal equals dispatchId (acquire, gen=0, sv=0)", () => {
  assert.strictEqual(deriveTaskId(OP, "acquire", 0, 0), DISPATCH_ACQUIRE);
});

const AUDIT_AUTHZ_DENIAL = "cb11ae62d9838d2101d7568d53eebd97749fb25af85b59df889ee1a241d9730a";

test("auditEventId: precomputed literal (authorization, denial, gen=0, sv=0)", () => {
  assert.strictEqual(
    deriveAuditEventId(OP, "authorization", "denial", 0, 0),
    AUDIT_AUTHZ_DENIAL,
  );
});

test("auditEventId: precomputed literal (success, completed, gen=1, sv=0)", () => {
  assert.strictEqual(
    deriveAuditEventId(OP, "success", "completed", 1, 0),
    "68c7056ee802fca6bca39005c93240f79bd4e9154b8d0c23af3486431538c1d8",
  );
});

test("auditEventId: precomputed literal (failure, terminal, gen=1, sv=0)", () => {
  assert.strictEqual(
    deriveAuditEventId(OP, "failure", "terminal", 1, 0),
    "9d1b64ce589d1b77efdcddca2c5774c2bea1e49920b7776cbb2e0dcaa53a840b",
  );
});

test("auditEventId: precomputed literal (progress, dispatch_pending, gen=0, sv=0)", () => {
  assert.strictEqual(
    deriveAuditEventId(OP, "progress", "dispatch_pending", 0, 0),
    "571776ea0fd4ca07ffdec664e33cb5373b16d9161f626b7a9f7d110ba7affc18",
  );
});

test("attemptId: precomputed literal (gen=0, sv=0) matches auth_create dispatch", () => {
  assert.strictEqual(
    deriveAttemptId(OP, 0, 0),
    "356d6a5176f3c467edf3cc62c5dc6e53f09ec473c9543b40879e83a29d926bc1",
  );
});

test("attemptId: precomputed literal (gen=1, sv=0)", () => {
  assert.strictEqual(
    deriveAttemptId(OP, 1, 0),
    "0a438a08abc141953ff08aa8d7044375bf3a894355d2f34017b713ff0e72d940",
  );
});

test("ownerToken: precomputed literal (dispatchId, gen=0)", () => {
  assert.strictEqual(
    deriveOwnerToken(DISPATCH_ACQUIRE, 0),
    "f7d1a9d3123a9f917a277f1e02f32131e88367d9d55d99b7e9800ece083ba07e",
  );
});

test("ownerToken: precomputed literal (dispatchId, gen=1)", () => {
  assert.strictEqual(
    deriveOwnerToken(DISPATCH_ACQUIRE, 1),
    "28c6f1b3959339042c60a9a3c1e76dc9145260e5073bba313ee2ed530aa62d7b",
  );
});

test("ownerToken: precomputed literal (dispatchId, gen=2)", () => {
  assert.strictEqual(
    deriveOwnerToken(DISPATCH_ACQUIRE, 2),
    "aa3741e2236e899cf5af4638752b21ba415498161fe5ac7b76c5dc5346af5763",
  );
});

// Fingerprint literal already covered in normalize tests
