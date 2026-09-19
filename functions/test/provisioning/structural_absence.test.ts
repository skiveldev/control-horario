import { strict as assert } from "node:assert";
import { readdir, readFile } from "node:fs/promises";
import { join, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { provisioningDeploymentMetadata } from "../../src/provisioning/deployment_metadata.ts";
import * as audit from "../../src/provisioning/audit.ts";
import * as enqueue from "../../src/provisioning/enqueue.ts";
import * as outbox from "../../src/provisioning/outbox.ts";
import * as schemas from "../../src/provisioning/schemas.ts";

const functionsRoot = fileURLToPath(new URL("../..", import.meta.url));
const sourceRoot = join(functionsRoot, "src");
const sourceFiles = {
  index: await readFile(join(sourceRoot, "index.ts"), "utf8"),
  submit: await readFile(join(sourceRoot, "provisioning", "submit.ts"), "utf8"),
  outboxRepair: await readFile(join(sourceRoot, "provisioning", "outbox_repair.ts"), "utf8"),
};
const iamMetadataTestSource = await readFile(new URL("iam_metadata.test.ts", import.meta.url), "utf8");

async function collectSourceFiles(directory: string): Promise<string[]> {
  const entries = await readdir(directory, { withFileTypes: true });
  const files = await Promise.all(entries.map(async (entry) => {
    const absolute = join(directory, entry.name);
    if (entry.isDirectory()) return collectSourceFiles(absolute);
    return entry.isFile() && /\.(?:ts|js|json)$/.test(entry.name) ? [absolute] : [];
  }));
  return files.flat();
}

const requiredFiles = [
  "src/index.ts",
  "src/provisioning/submit.ts",
  "src/provisioning/schemas.ts",
  "src/provisioning/audit.ts",
  "src/provisioning/enqueue.ts",
  "src/provisioning/outbox.ts",
  "src/provisioning/outbox_repair.ts",
  "src/provisioning/deployment_metadata.ts",
  "test/export-metadata.test.ts",
  "test/provisioning/trigger_metadata.test.ts",
  "test/provisioning/scheduler_metadata.test.ts",
  "test/provisioning/monitoring_metadata.test.ts",
  "test/provisioning/iam_metadata.test.ts",
];

for (const path of requiredFiles) {
  await readFile(join(functionsRoot, path), "utf8");
}

assert.match(sourceFiles.submit, /export function validateSubmission\b/, "submit.ts must expose submission validation");
assert.match(sourceFiles.submit, /export async function persistInitialSubmission\b/, "submit.ts must expose the atomic submission boundary");
assert.equal(typeof schemas.isValidOperation, "function", "schemas.ts must expose operation validation");
assert.equal(typeof schemas.isValidDispatch, "function", "schemas.ts must expose dispatch validation");
assert.equal(typeof schemas.isValidDispatchUpdate, "function", "schemas.ts must expose dispatch update validation");
assert.equal(typeof audit.isValidAuditEvent, "function", "audit.ts must expose audit validation");
assert.equal(typeof audit.createAuditEvent, "function", "audit.ts must expose audit primitives");
assert.equal(typeof audit.deduplicateAudit, "function", "audit.ts must expose audit deduplication");
assert.equal(typeof audit.isValidApplicationLog, "function", "audit.ts must expose PII-safe log validation");
assert.equal(typeof enqueue.createStrictEnqueueFake, "function", "enqueue.ts must expose the shared strict enqueue adapter");
assert.equal(typeof enqueue.createCloudTasksEnqueueAdapter, "function", "enqueue.ts must expose deterministic Cloud Tasks construction");
assert.equal(typeof outbox.handleCreatedDispatch, "function", "outbox.ts must expose the created-trigger handler");
assert.equal(typeof outbox.enqueueAndAcknowledgeDispatch, "function", "outbox.ts must expose the shared enqueue/ack boundary");
assert.match(sourceFiles.outboxRepair, /export async function repairStaleDispatches\b/, "outbox_repair.ts must expose the scheduled repair core");
assert.match(sourceFiles.outboxRepair, /export class FirestoreOutboxRepairStore\b/, "outbox_repair.ts must expose the Firestore repair adapter");

assert.match(sourceFiles.index, /export const submitProvisioning\s*=\s*onCall/, "index.ts must export the submission callable");
assert.match(sourceFiles.index, /onCall\(\s*\{\s*enforceAppCheck:\s*true\s*\}/, "submission callable must bind enforceAppCheck:true");
assert.match(sourceFiles.index, /export const provisioningDispatchCreated\s*=\s*onDocumentCreated/, "index.ts must export the created dispatch trigger");
assert.match(sourceFiles.index, /retry:\s*true/, "created dispatch trigger must be retry-enabled");
assert.match(sourceFiles.index, /export const provisioningOutboxRepair\s*=\s*onSchedule/, "index.ts must export the scheduled repair function");
assert.match(sourceFiles.index, /schedule:\s*"every 5 minutes"/, "repair schedule must be wired");
assert.match(sourceFiles.index, /retryCount:\s*3/, "repair retry count must be wired");
assert.equal(provisioningDeploymentMetadata.cloudTasks.enqueuerCapability, "cloud-tasks-enqueue", "deployment metadata carrier must be available directly");
assert.match(iamMetadataTestSource, /from "\.\.\/\.\.\/src\/provisioning\/deployment_metadata\.ts"/, "IAM metadata test must import the carrier directly");
assert.doesNotMatch(sourceFiles.index, /deployment_metadata/, "index.ts must not be required to re-export IAM metadata");

const backendSources = await collectSourceFiles(sourceRoot);
assert.ok(backendSources.every((file) => relative(functionsRoot, file).startsWith("src")), "structural scan is limited to Functions backend source");

for (const file of backendSources) {
  const source = await readFile(file, "utf8");
  const scopedPath = relative(functionsRoot, file);
  assert.doesNotMatch(source, /\bdeleteUser\s*\(/, `${scopedPath} must not automatically delete Auth users`);
  assert.doesNotMatch(source, /\bcreateUser\s*\(/, `${scopedPath} must not create Auth users in P2`);
  assert.doesNotMatch(source, /\bgeneratePasswordResetLink\s*\(/, `${scopedPath} must not issue reset links in P2`);
  assert.doesNotMatch(source, /onRequest\s*\(|https?\.request\s*\(|fetch\s*\([^)]*cloudtasks/i, `${scopedPath} must not use raw HTTP task/callable workarounds`);
  assert.doesNotMatch(source, /initializeApp\s*\([^)]*,\s*["'][^"']+["']\s*\)/, `${scopedPath} must not copy secondary client Firebase-app logic into Functions source`);
  assert.doesNotMatch(source, /collection\s*\(\s*["']users["']\s*\)\s*\.doc\([^)]*\)\s*\.set\s*\(/, `${scopedPath} must not directly mutate profiles outside approved primitives`);
}

console.log(`OK: backend structural boundary ${requiredFiles.length + backendSources.length + 27} assertions`);
