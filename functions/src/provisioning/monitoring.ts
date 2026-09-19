/**
 * Declarative monitoring contract only; deployment configuration is intentionally out of scope.
 */
export const provisioningMonitoringMetadata = {
  outboxStaleAge: {
    metric: "outbox_stale_age_seconds",
    thresholdSeconds: 900,
    consecutivePeriods: 2,
    periodMinutes: 5,
  },
  eventarcOutboxTriggerAlerts: ["error", "delivery-failure"],
  sweeperAlerts: ["execution-error", "missing-successful-execution"],
  sweeperMissingSuccessfulExecutionAfterMinutes: 10,
  cloudTasksAlerts: ["enqueue", "attempt-exhaustion"],
  safeLogIdentifiers: ["operation-digest", "dispatch-digest", "coded-identifier"],
} as const;
