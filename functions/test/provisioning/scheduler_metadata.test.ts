import { strict as assert } from "node:assert";
import { readFile } from "node:fs/promises";
import { provisioningOutboxRepair } from "../../src/index.ts";

const source = await readFile(new URL("../../src/index.ts", import.meta.url), "utf8");

assert.equal(typeof provisioningOutboxRepair, "function", "the outbox repair sweeper must be exported");
assert.equal(provisioningOutboxRepair.__endpoint.platform, "gcfv2", "the sweeper must expose v2 metadata");
const scheduleTrigger = provisioningOutboxRepair.__endpoint.scheduleTrigger;
assert.ok(scheduleTrigger, "the sweeper must expose scheduler metadata");
assert.equal(scheduleTrigger.schedule, "every 5 minutes", "the sweeper must run every five minutes");
assert.equal(scheduleTrigger.retryConfig?.retryCount, 3, "the sweeper must retry three times");
assert.equal(scheduleTrigger.retryConfig?.minBackoffSeconds, 30, "the sweeper must use a 30-second minimum backoff");
assert.equal(scheduleTrigger.retryConfig?.maxBackoffSeconds, 300, "the sweeper must use a 300-second maximum backoff");
assert.equal(scheduleTrigger.retryConfig?.maxDoublings, 2, "the sweeper must allow two backoff doublings");
assert.equal(provisioningOutboxRepair.__endpoint.maxInstances, 1, "the sweeper must allow one concurrent instance");
assert.equal(provisioningOutboxRepair.__endpoint.timeoutSeconds, 240, "the sweeper must time out after 240 seconds");
assert.match(
  source,
  /onSchedule\(\s*\{\s*schedule:\s*["']every 5 minutes["'],\s*retryCount:\s*3,\s*minBackoffSeconds:\s*30,\s*maxBackoffSeconds:\s*300,\s*maxDoublings:\s*2,\s*maxInstances:\s*1,\s*timeoutSeconds:\s*240\s*,?\s*\}/,
  "the sweeper must bind the required scheduler options",
);

console.log("OK: provisioning outbox repair scheduler metadata 11 assertions");
