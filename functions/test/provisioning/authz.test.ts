import { strict as assert } from "node:assert";
import { createHash } from "node:crypto";
import {
  AuthorizationError,
  authorizeAdmin,
  type AuthorizationPort,
} from "../../src/provisioning/authz.ts";

const correlationId = "c".repeat(64);
const auditEventId = createHash("sha256")
  .update(`provision-audit:v1\0${correlationId}\0authorization\0denial\0${0}\0${0}`, "utf8")
  .digest("hex");

function port(
  profile: { role: string; isActive: boolean } | null,
  order: string[],
  audits: unknown[],
): AuthorizationPort {
  return {
    async readUser(uid) {
      order.push(`read:${uid}`);
      return profile;
    },
    async writeDenialAudit(event) {
      order.push("audit");
      audits.push(event);
    },
    now: () => 123,
  };
}

async function expectDenial(
  request: { callerUid: string | null; correlationId: string },
  dependency: AuthorizationPort,
  code: "unauthenticated" | "permission-denied",
  order: string[],
): Promise<void> {
  await assert.rejects(
    async () => {
      try {
        await authorizeAdmin(request, dependency);
      } catch (error) {
        order.push("denial");
        throw error;
      }
    },
    (error: unknown) => error instanceof AuthorizationError && error.code === code,
    `${code} must be returned only after its denial audit persists`,
  );
}

{
  const order: string[] = [];
  const audits: unknown[] = [];
  await expectDenial(
    { callerUid: null, correlationId },
    port(null, order, audits),
    "unauthenticated",
    order,
  );

  assert.deepEqual(order, ["audit", "denial"], "unauthenticated denial must audit before it is surfaced without reading a profile");
  const audit = audits[0] as Record<string, unknown>;
  assert.equal(audits.length, 1, "unauthenticated denial must create exactly one audit record");
  assert.equal(audit.eventId, auditEventId, "denial audit identity must use the canonical deterministic format");
  assert.deepEqual(
    { ...audit, eventId: undefined },
    {
      schemaVersion: 1, eventId: undefined, operationId: null, correlationId,
      category: "authorization", stage: "denial", outcome: "denied", code: "unauthenticated",
      actorUidDigest: null, intendedUidDigest: null, dispatchId: null, generation: null,
      sourceVersion: null, createdAt: 123,
    },
    "unauthenticated denial must persist the PII-safe authorization audit contract",
  );
}

{
  const order: string[] = [];
  const audits: unknown[] = [];
  await expectDenial(
    { callerUid: "employee-1", correlationId },
    port({ role: "employee", isActive: true }, order, audits),
    "permission-denied",
    order,
  );

  assert.deepEqual(order, ["read:employee-1", "audit", "denial"], "non-admin denial must persist its audit before any later mutation can run");
  assert.equal((audits[0] as { code: string }).code, "permission-denied", "non-admin audit must record the stable denial code");
  assert.match((audits[0] as { actorUidDigest: string }).actorUidDigest, /^[a-f0-9]{64}$/, "non-admin audit must store only a caller digest");
}

{
  const order: string[] = [];
  const audits: unknown[] = [];
  await assert.rejects(
    () => authorizeAdmin(
      { callerUid: null, correlationId: "employee@example.com" },
      port(null, order, audits),
    ),
    /invalid correlation ID/,
    "raw correlation values must be rejected before they can enter an audit",
  );

  assert.deepEqual(order, [], "a raw correlation value must not trigger an audit write");
  assert.deepEqual(audits, [], "a raw correlation value must never persist PII in an audit event");
}

{
  const order: string[] = [];
  const audits: unknown[] = [];
  await authorizeAdmin(
    { callerUid: "admin-1", correlationId },
    port({ role: "admin", isActive: true }, order, audits),
  );

  assert.deepEqual(order, ["read:admin-1"], "active admins must pass authorization without a denial audit");
  assert.deepEqual(audits, [], "authorized requests must not create denial audits");
}

console.log("OK: authorization 14 assertions");
