import { strict as assert } from "node:assert";
import { readFile, readdir } from "node:fs/promises";
import {
  APPLICATION_LOG_DIGEST_DOMAINS,
  CANONICAL_CODE_VALUES,
  createApplicationLog,
  deduplicateAudit,
  isValidApplicationLog,
  isValidAuditEvent,
} from "../../src/provisioning/audit.ts";

const event = () => ({
  schemaVersion: 1,
  eventId: "c".repeat(64),
  operationId: "00000000-0000-4000-a000-000000000101",
  correlationId: "d".repeat(64),
  category: "authorization",
  stage: "denial",
  outcome: "denied",
  code: "permission-denied",
  actorUidDigest: "e".repeat(64),
  intendedUidDigest: null,
  dispatchId: null,
  generation: null,
  sourceVersion: null,
  createdAt: 1,
});

assert.equal(isValidAuditEvent(event()), true, "canonical audit event must validate");
for (const unsafe of [
  { ...event(), eventId: "employee@example.com" },
  { ...event(), correlationId: "Employee Example" },
  { ...event(), code: "12345678A" },
  { ...event(), code: "+34123456789" },
  { ...event(), code: "request body" },
  { ...event(), code: "token=secret" },
  { ...event(), code: "https://example.com/reset?token=secret" },
  { ...event(), code: "FirebaseError: permission denied" },
  { ...event(), actorUidDigest: "raw-uid" },
  { ...event(), extra: true },
]) assert.equal(isValidAuditEvent(unsafe), false, "raw PII or non-contract audit data must reject");

const acceptedAuditEvents = [event()];
for (const [field, value] of [
  ["email", "employee@example.com"],
  ["nombre", "Employee"],
  ["apellido", "Example"],
  ["dni", "12345678A"],
  ["telefono", "+34123456789"],
  ["body", "request body"],
  ["token", "secret"],
  ["resetLink", "https://example.com/reset?token=secret"],
  ["sdkMessage", "FirebaseError: permission denied"],
] as const) {
  const input = { ...event(), [field]: value };
  const inputBefore = structuredClone(input);
  const acceptedBefore = structuredClone(acceptedAuditEvents);
  assert.equal(isValidAuditEvent(input), false, `${field} must be rejected by the exact audit shape`);
  assert.deepEqual(input, inputBefore, `${field} rejection must not mutate its input`);
  assert.deepEqual(acceptedAuditEvents, acceptedBefore, `${field} rejection must not mutate accepted audit events`);
}

assert.equal(isValidAuditEvent(new Proxy({}, { getPrototypeOf() { throw new Error("hostile audit"); } })), false, "hostile audit events must fail closed");

console.log("OK: audit schema 39 assertions");

const existing = event();
assert.strictEqual(deduplicateAudit(existing, { ...existing }), existing, "matching event identity must be idempotent");
for (const mismatch of [
  { ...existing, operationId: null },
  { ...existing, correlationId: "a".repeat(64) },
  { ...existing, stage: "auth_intent" },
  { ...existing, dispatchId: "b".repeat(64) },
  { ...existing, generation: 1 },
]) assert.throws(() => deduplicateAudit(existing, mismatch), /audit identity mismatch/, "identity mismatch must fail without mutation");
assert.deepEqual(existing, event(), "failed deduplication must not mutate the existing audit event");
console.log("OK: audit dedup 7 assertions");

const applicationLog = {
  eventCode: "auth-intent",
  resultCode: "success",
  reasonCode: "unavailable",
  digests: [
    { domain: "provision-audit:v1", value: "a".repeat(64) },
    { domain: "provision-dispatch:v1", value: "b".repeat(64) },
  ],
};

assert.deepEqual(
  createApplicationLog(applicationLog),
  applicationLog,
  "application logs retain only allowlisted codes and explicitly tagged digests",
);
assert.equal(isValidApplicationLog(applicationLog), true, "canonical application log must validate");
assert.deepEqual(
  CANONICAL_CODE_VALUES.includes("permission-denied"),
  true,
  "application log codes must reuse the canonical audit-code vocabulary",
);
assert.deepEqual(
  APPLICATION_LOG_DIGEST_DOMAINS.includes("provision-audit:v1"),
  true,
  "application log digests must declare an approved domain separator",
);

for (const invalidCode of ["employee@example.com", "owner-secret", "FirebaseError: denied"]) {
  assert.equal(
    isValidApplicationLog({ ...applicationLog, reasonCode: invalidCode }),
    false,
    "application log reason codes must be allowlisted",
  );
}

for (const [field, value] of [
  ["email", "employee@example.com"],
  ["uid", "raw-user-id"],
  ["operationId", "00000000-0000-4000-a000-000000000101"],
  ["ownerToken", "owner-secret"],
  ["auditEventId", "a".repeat(64)],
  ["resetLink", "https://example.com/reset?token=secret"],
  ["failureEvidence", { message: "raw SDK detail" }],
  ["leaseExpiresAt", 123],
  ["normalizedPayload", { email: "employee@example.com" }],
  ["metadata", { arbitrary: true }],
] as const) {
  assert.equal(
    isValidApplicationLog({ ...applicationLog, [field]: value }),
    false,
    `${field} must not enter application logs as arbitrary metadata`,
  );
  assert.throws(
    () => createApplicationLog({ ...applicationLog, [field]: value }),
    /invalid application log/,
    `${field} must be rejected by the application-log factory`,
  );
}

for (const invalidDigest of [
  { domain: "provision-audit:v1", value: "employee@example.com" },
  { domain: "sha256", value: "a".repeat(64) },
  { domain: "provision-dispatch:v1", value: "not-a-digest" },
]) {
  assert.equal(
    isValidApplicationLog({ ...applicationLog, digests: [invalidDigest] }),
    false,
    "application log digests must be explicitly domain-separated SHA-256 values",
  );
}

async function sourceFiles(directory: URL): Promise<URL[]> {
  const files: URL[] = [];
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const file = new URL(entry.name, directory);
    if (entry.isDirectory()) files.push(...await sourceFiles(new URL(`${entry.name}/`, directory)));
    if (entry.isFile() && entry.name.endsWith(".ts")) files.push(file);
  }
  return files;
}

const applicationSources = await sourceFiles(new URL("../../src/", import.meta.url));
for (const sourceFile of applicationSources) {
  assert.doesNotMatch(
    await readFile(sourceFile, "utf8"),
    /\b(?:console\.(?:debug|error|info|log|warn)|logger\.(?:debug|error|info|log|warn)|process\.(?:stderr|stdout)\.write)\s*\(/,
    `${sourceFile.pathname} must not bypass the bounded application-log contract`,
  );
}

console.log(`OK: application log safety ${30 + applicationSources.length} assertions`);
