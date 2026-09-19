/**
 * Declarative repository-preparation metadata; it has no deployment behavior.
 */
export const provisioningDeploymentMetadata = {
  environment: {
    environment: "<environment-placeholder>",
    project: "<project-placeholder>",
    region: "<region-placeholder>",
    rate: "<rate-placeholder>",
    concurrency: "<concurrency-placeholder>",
  },
  serviceAccounts: {
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
  },
  cloudTasks: {
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
  },
  invocation: {
    schedulerInvoker: "<scheduler-invoker-placeholder>",
    eventarcTriggerIdentity: "<eventarc-trigger-identity-placeholder>",
  },
  requiredCapabilities: {
    firestore: ["caller-profile-read", "operation-read", "operation-write", "dispatch-read", "dispatch-write", "audit-write"],
    auth: ["user-read", "user-create", "password-reset-link"],
  },
} as const;
