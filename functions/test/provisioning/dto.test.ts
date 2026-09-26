import { strict as assert } from "node:assert";
import { projectStatusDto } from "../../src/provisioning/dto.ts";

const prohibitedFields = [
  "email",
  "ownerToken",
  "leaseExpiresAt",
  "generation",
  "version",
  "failureEvidence",
  "retryEvidence",
  "auditEventId",
  "submittedByDigest",
  "resetLink",
  "normalizedPayload",
] as const;

const operation = (status: string, phase: string, overrides: Record<string, unknown> = {}) => ({
  operationId: "00000000-0000-4000-a000-000000000001",
  status,
  phase,
  intendedUid: "trusted-user-id",
  terminalCode: "unavailable",
  recoveryCode: "manual-review",
  email: "private@example.com",
  ownerToken: "owner-secret",
  leaseExpiresAt: 999,
  generation: 7,
  version: 9,
  failureEvidence: [{ code: "internal" }],
  retryEvidence: { lastRetryReasonCode: "internal" },
  auditEventId: "audit-identity",
  submittedByDigest: "actor-digest",
  resetLink: "https://reset.example/private-link",
  normalizedPayload: { email: "private@example.com" },
  ...overrides,
});

const expected = [
  ["pending", operation("pending", "dispatch_pending"), { operationId: "00000000-0000-4000-a000-000000000001", status: "pending", retryAfterSeconds: 1 }],
  ["active", operation("active", "auth_create"), { operationId: "00000000-0000-4000-a000-000000000001", status: "active", phase: "auth_create", retryAfterSeconds: 1 }],
  ["completed", operation("completed", "terminal"), { operationId: "00000000-0000-4000-a000-000000000001", status: "completed", userId: "trusted-user-id", idempotent: true }],
  ["failed", operation("failed", "terminal"), { operationId: "00000000-0000-4000-a000-000000000001", status: "failed", terminalCode: "unavailable" }],
  ["manual_recovery", operation("manual_recovery", "terminal"), { operationId: "00000000-0000-4000-a000-000000000001", status: "manual_recovery", terminalCode: "unavailable", recoveryCode: "manual-review" }],
] as const;

for (const [status, source, safe] of expected) {
  const projected = projectStatusDto(source);
  assert.deepEqual(projected, safe, `${status} projects exactly its safe DTO fields`);

  for (const field of prohibitedFields) {
    assert.equal(Object.hasOwn(projected ?? {}, field), false, `${status} never exposes ${field}`);
  }

  const serialized = JSON.stringify(projected);
  assert.equal(
    serialized.includes("private@example.com")
      || serialized.includes("owner-secret")
      || serialized.includes("private-link")
      || serialized.includes("audit-identity"),
    false,
    `${status} serializes no private source value`,
  );
}

assert.equal(projectStatusDto(operation("unknown", "terminal")), null, "unknown status fails closed");
assert.equal(projectStatusDto(operation("pending", "terminal")), null, "pending with an invalid phase fails closed");
assert.equal(projectStatusDto(operation("completed", "terminal", { intendedUid: null })), null, "completed without its canonical user ID fails closed");
assert.equal(projectStatusDto(operation("manual_recovery", "terminal", { recoveryCode: "" })), null, "manual recovery without a stable recovery code fails closed");

console.log("OK: safe status DTO projection 69 assertions");
