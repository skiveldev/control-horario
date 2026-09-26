import { strict as assert } from "node:assert";
import { readFile } from "node:fs/promises";
import { provisioningDispatchCreated } from "../../src/index.ts";

const source = await readFile(new URL("../../src/index.ts", import.meta.url), "utf8");

assert.equal(typeof provisioningDispatchCreated, "function", "the outbox created trigger must be exported");
assert.equal(provisioningDispatchCreated.__endpoint.platform, "gcfv2", "the outbox created trigger must expose v2 metadata");
const eventTrigger = provisioningDispatchCreated.__endpoint.eventTrigger;
assert.ok(eventTrigger, "the outbox created trigger must expose event metadata");
assert.equal(
  eventTrigger.retry,
  true,
  "the outbox created trigger must enable retry",
);
assert.match(
  source,
  /onDocumentCreated\(\s*\{\s*document:\s*["']provisioningDispatch\/\{dispatchId\}["'],\s*retry:\s*true\s*\}/,
  "the outbox created trigger must bind the dispatch path and retry option",
);

console.log("OK: created outbox trigger metadata 5 assertions");
