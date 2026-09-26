import { strict as assert } from "node:assert";
import { readFile } from "node:fs/promises";
import { provisioningMonitoringMetadata } from "../../src/provisioning/monitoring.ts";

const source = await readFile(new URL("../../src/provisioning/monitoring.ts", import.meta.url), "utf8");

assert.equal(provisioningMonitoringMetadata.outboxStaleAge.metric, "outbox_stale_age_seconds");
assert.equal(provisioningMonitoringMetadata.outboxStaleAge.thresholdSeconds, 900);
assert.equal(provisioningMonitoringMetadata.outboxStaleAge.consecutivePeriods, 2);
assert.equal(provisioningMonitoringMetadata.outboxStaleAge.periodMinutes, 5);
assert.deepEqual(provisioningMonitoringMetadata.eventarcOutboxTriggerAlerts, ["error", "delivery-failure"]);
assert.deepEqual(provisioningMonitoringMetadata.sweeperAlerts, ["execution-error", "missing-successful-execution"]);
assert.equal(provisioningMonitoringMetadata.sweeperMissingSuccessfulExecutionAfterMinutes, 10);
assert.deepEqual(provisioningMonitoringMetadata.cloudTasksAlerts, ["enqueue", "attempt-exhaustion"]);
assert.deepEqual(provisioningMonitoringMetadata.safeLogIdentifiers, ["operation-digest", "dispatch-digest", "coded-identifier"]);
assert.doesNotMatch(source, /email|name|dni|phone|body|token|reset link|sdk message/i);

console.log("OK: provisioning monitoring metadata 10 assertions");
