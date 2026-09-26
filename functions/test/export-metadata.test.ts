import { strict as assert } from "node:assert";
import { readFile } from "node:fs/promises";
import { submitProvisioning } from "../src/index.ts";

const source = await readFile(new URL("../src/index.ts", import.meta.url), "utf8");

assert.equal(typeof submitProvisioning, "function", "submission must be exported as a callable function");
assert.equal(submitProvisioning.__endpoint.platform, "gcfv2", "submission must expose v2 deployment metadata");
assert.deepEqual(submitProvisioning.__endpoint.callableTrigger, {}, "submission must expose callable deployment metadata");
assert.match(
  source,
  /onCall\(\s*\{\s*enforceAppCheck:\s*true\s*\}/,
  "submission must bind enforceAppCheck to true in its callable options",
);

console.log("OK: submission App Check metadata 4 assertions");
