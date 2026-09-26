import { strict as assert } from "node:assert";
import { readFile } from "node:fs/promises";
import { provisioningDeploymentMetadata } from "../../src/provisioning/deployment_metadata.ts";

const source = await readFile(
  new URL("../../src/provisioning/deployment_metadata.ts", import.meta.url),
  "utf8",
);

assert.deepEqual(provisioningDeploymentMetadata.environment, {
  environment: "<environment-placeholder>",
  project: "<project-placeholder>",
  region: "<region-placeholder>",
  rate: "<rate-placeholder>",
  concurrency: "<concurrency-placeholder>",
});

assert.deepEqual(provisioningDeploymentMetadata.serviceAccounts, {
  submissionCallable: {
    identity: "<submission-callable-service-account-placeholder>",
    capabilities: ["firestore-read", "operation-write", "dispatch-write", "audit-write"],
  },
  taskWorker: {
    identity: "<task-worker-service-account-placeholder>",
    capabilities: ["firestore-read", "operation-write", "profile-write", "audit-write", "auth-user-administration"],
  },
  outboxTrigger: {
    identity: "<outbox-trigger-service-account-placeholder>",
    capabilities: ["dispatch-read", "dispatch-update", "cloud-tasks-enqueue"],
  },
  outboxSweeper: {
    identity: "<outbox-sweeper-service-account-placeholder>",
    capabilities: ["dispatch-query", "dispatch-read", "dispatch-update", "cloud-tasks-enqueue"],
  },
});

assert.deepEqual(provisioningDeploymentMetadata.cloudTasks, {
  queue: {
    name: "<cloud-tasks-queue-placeholder>",
    retryConfiguration: "<cloud-tasks-retry-placeholder>",
    rateLimit: "<cloud-tasks-rate-limit-placeholder>",
  },
  taskOidc: {
    identity: "<task-oidc-service-account-placeholder>",
    audience: "<private-task-function-audience-placeholder>",
  },
  enqueuerCapability: "cloud-tasks-enqueue",
});

assert.deepEqual(provisioningDeploymentMetadata.invocation, {
  schedulerInvoker: "<scheduler-invoker-placeholder>",
  eventarcTriggerIdentity: "<eventarc-trigger-identity-placeholder>",
});

assert.deepEqual(provisioningDeploymentMetadata.requiredCapabilities, {
  firestore: ["caller-profile-read", "operation-read", "operation-write", "dispatch-read", "dispatch-write", "audit-write"],
  auth: ["user-read", "user-create", "password-reset-link"],
});

assert.doesNotMatch(source, /projectId\s*:|@|AIza|BEGIN [A-Z ]*KEY|secret|principal|binding|deploy\s*\(/i);
assert.doesNotMatch(source, /(?:region|rate|concurrency)\s*:\s*(?:\d+|["'][a-z][^"']*["'])/i);

console.log("OK: provisioning IAM deployment metadata 7 assertions");
