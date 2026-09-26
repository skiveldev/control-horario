import { strict as assert } from "node:assert";
import {
  createCloudTasksEnqueueAdapter,
  createStrictEnqueueFake,
  type CloudTasksCreateTaskRequest,
  type EnqueueAdapter,
  type EnqueueDispatch,
} from "../../src/provisioning/enqueue.ts";

const dispatch: EnqueueDispatch = {
  dispatchId: "a".repeat(64),
  taskId: "a".repeat(64),
  operationId: "00000000-0000-4000-a000-000000000001",
  fingerprint: "b".repeat(64),
  boundary: "acquire",
  generation: 0,
  sourceVersion: 0,
  ownerSeed: "c".repeat(64),
};

{
  const fake = createStrictEnqueueFake();
  const adapter: EnqueueAdapter = fake;

  await adapter.enqueue(dispatch);
  await adapter.enqueue({ ...dispatch });

  assert.equal(fake.enqueueCount, 1, "matching dispatch replay produces one observable enqueue side effect");
  assert.deepEqual(fake.enqueued, [dispatch], "the fake records the canonical dispatch identity once");
  assert.notEqual(fake.enqueued[0], dispatch, "the observable enqueue record is isolated from caller mutation");
}

{
  const fake = createStrictEnqueueFake();
  await fake.enqueue(dispatch);

  await assert.rejects(
    () => fake.enqueue({ ...dispatch, fingerprint: "d".repeat(64) }),
    /incompatible dispatch identity/,
    "reusing a dispatch ID with a different canonical identity fails closed",
  );

  await fake.enqueue({
    ...dispatch,
    dispatchId: "e".repeat(64),
    taskId: "e".repeat(64),
    generation: 1,
  });
  assert.equal(fake.enqueueCount, 2, "a distinct dispatch identity produces its own observable enqueue side effect");
  assert.deepEqual(fake.enqueued[0], dispatch, "incompatible reuse does not alter the original observable enqueue");
}

{
  const requests: CloudTasksCreateTaskRequest[] = [];
  const adapter = createCloudTasksEnqueueAdapter(
    {
      projectId: "portfolio-project",
      location: "us-central1",
      queue: "provisioning-dispatch",
      targetUrl: "https://us-central1-portfolio-project.cloudfunctions.net/onTaskDispatched",
      oidcServiceAccountEmail: "provisioning-worker@portfolio-project.iam.gserviceaccount.com",
    },
    {
      async createTask(request) {
        requests.push(request);
      },
    },
  );

  await adapter.enqueue(dispatch);
  await adapter.enqueue({ ...dispatch });

  const parent = "projects/portfolio-project/locations/us-central1/queues/provisioning-dispatch";
  const expectedBody = Buffer.from(JSON.stringify({data:{dispatchId: dispatch.dispatchId}}), "utf8").toString("base64");
  const expectedRequest: CloudTasksCreateTaskRequest = {
    parent,
    task: {
      name: `${parent}/tasks/${dispatch.dispatchId}`,
      httpRequest: {
        httpMethod: "POST",
        url: "https://us-central1-portfolio-project.cloudfunctions.net/onTaskDispatched",
        headers: { "Content-Type": "application/json" },
        body: expectedBody,
        oidcToken: {
          serviceAccountEmail: "provisioning-worker@portfolio-project.iam.gserviceaccount.com",
        },
      },
    },
  };

  assert.equal(requests.length, 2, "the injectable transport receives both idempotent enqueue attempts");
  assert.deepEqual(requests[0], expectedRequest, "the adapter constructs the documented Cloud Tasks request exactly");
  assert.deepEqual(requests[0], requests[1], "the same canonical dispatch produces byte-stable request data");
  assert.equal(requests[0].task.name, `${parent}/tasks/${dispatch.dispatchId}`, "the fully qualified task ID is the dispatch ID");
  assert.deepEqual(
    JSON.parse(Buffer.from(requests[0].task.httpRequest.body, "base64").toString("utf8")),
    { data: { dispatchId: dispatch.dispatchId } },
    "the task body contains exactly the Cloud Tasks data envelope",
  );
  const serializedRequest = JSON.stringify(requests[0]);
  assert.doesNotMatch(serializedRequest, new RegExp(dispatch.operationId), "the task request omits the operation ID");
  assert.doesNotMatch(serializedRequest, new RegExp(dispatch.fingerprint), "the task request omits the payload fingerprint");
  assert.doesNotMatch(serializedRequest, new RegExp(dispatch.ownerSeed), "the task request omits opaque owner material");
  assert.doesNotMatch(serializedRequest, /resetLink/i, "the task request cannot contain a reset link");

  await adapter.enqueue({
    ...dispatch,
    dispatchId: "d".repeat(64),
    taskId: "d".repeat(64),
    generation: 1,
  });
  assert.equal(requests.length, 3, "a distinct canonical dispatch produces a third transport request");
  assert.notEqual(requests[0].task.name, requests[2].task.name, "distinct dispatch identities produce distinct task IDs");

  await assert.rejects(
    () => adapter.enqueue({ ...dispatch, taskId: "e".repeat(64) }),
    /invalid dispatch identity/,
    "a noncanonical task ID fails closed before transport",
  );
}

for (const invalidEnvironment of [
  { projectId: "", location: "us-central1", queue: "provisioning-dispatch" },
  { projectId: "portfolio-project", location: "../us-central1", queue: "provisioning-dispatch" },
  { projectId: "portfolio-project", location: "us-central1", queue: "provisioning/dispatch" },
]) {
  assert.throws(
    () => createCloudTasksEnqueueAdapter({
      ...invalidEnvironment,
      targetUrl: "https://us-central1-portfolio-project.cloudfunctions.net/onTaskDispatched",
      oidcServiceAccountEmail: "provisioning-worker@portfolio-project.iam.gserviceaccount.com",
    }, { async createTask() {} }),
    /invalid queue environment/,
    "project, location, and queue inputs fail closed",
  );
}

{
  const adapter = createCloudTasksEnqueueAdapter(
    {
      projectId: "portfolio-project",
      location: "us-central1",
      queue: "provisioning-dispatch",
      targetUrl: "https://us-central1-portfolio-project.cloudfunctions.net/onTaskDispatched",
      oidcServiceAccountEmail: "provisioning-worker@portfolio-project.iam.gserviceaccount.com",
    },
    { async createTask() { throw new Error("transport failure"); } },
  );
  await assert.rejects(() => adapter.enqueue(dispatch), /transport failure/, "the adapter exposes transport failure to the caller");
}

console.log("OK: enqueue adapter contract and production construction 22 assertions");
