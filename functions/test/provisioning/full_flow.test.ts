import assert from "node:assert/strict";
import test from "node:test";
import { createHash, randomUUID } from "node:crypto";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { createProvisioningOutboxRuntime } from "../../src/index.ts";
import { createStrictEnqueueFake } from "../../src/provisioning/enqueue.ts";
import { FirestoreOutboxRepairStore } from "../../src/provisioning/outbox_repair.ts";
import { deriveDispatchId } from "../../src/provisioning/ids.ts";
import { isValidDispatch, isValidDispatchUpdate } from "../../src/provisioning/schemas.ts";

const emulatorReady = Boolean(
  process.env.FUNCTIONS_EMULATOR_HOST
  && process.env.FIRESTORE_EMULATOR_HOST
  && process.env.FIREBASE_AUTH_EMULATOR_HOST,
);

function functionsUrl(name: string, projectId: string): string {
  return `http://${process.env.FUNCTIONS_EMULATOR_HOST}/${projectId}/us-central1/${name}`;
}

function appCheckToken(): string {
  return [
    Buffer.from(JSON.stringify({ alg: "none" })).toString("base64url"),
    Buffer.from(JSON.stringify({ sub: "p3-45-full-flow-app" })).toString("base64url"),
    "signature",
  ].join(".");
}

async function signIn(email: string, password: string): Promise<string> {
  const response = await fetch(
    `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=emulator`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password, returnSecureToken: true }),
    },
  );
  assert.equal(response.status, 200, await response.clone().text());
  const body = await response.json() as { readonly idToken?: unknown };
  assert.equal(typeof body.idToken, "string");
  return body.idToken;
}

function taskHeaders(projectId: string, dispatchId: string): Record<string, string> {
  const queue = `projects/${projectId}/locations/us-central1/queues/provisioning-dispatch`;
  return {
    "Content-Type": "application/json",
    "X-CloudTasks-QueueName": queue,
    "X-CloudTasks-TaskName": `${queue}/tasks/${dispatchId}`,
    "X-CloudTasks-TaskRetryCount": "0",
    "X-CloudTasks-TaskExecutionCount": "1",
    "X-CloudTasks-TaskETA": "2026-01-01T00:00:00.000Z",
  };
}

async function invokeBackendTask(projectId: string, dispatchId: string): Promise<void> {
  const response = await fetch(functionsUrl("onTaskDispatched", projectId), {
    method: "POST",
    headers: taskHeaders(projectId, dispatchId),
    body: JSON.stringify({ data: { dispatchId } }),
  });
  assert.equal(response.status, 204, await response.clone().text());
}

test("P3.45 backend-only happy path reaches completed status with an immediate fresh reset link", {
  skip: !emulatorReady,
}, async () => {
  const projectId = process.env.GCLOUD_PROJECT || "demo-no-project";
  const suffix = randomUUID();
  const operationId = randomUUID();
  const adminUid = `full-flow-admin-${suffix}`;
  const adminEmail = `full-flow-admin-${suffix}@example.com`;
  const adminPassword = "Full-flow-admin-password-1";
  const app = initializeApp({ projectId }, `p3-45-full-flow-${suffix}`);
  const firestore = getFirestore(app);
  const auth = getAuth(app);
  const enqueue = createStrictEnqueueFake();
    const outbox = createProvisioningOutboxRuntime({
      enqueue,
      store: new FirestoreOutboxRepairStore(firestore),
      validation: { isValidDispatch, isValidDispatchUpdate },
      log: () => undefined,
      now: Date.now,
    });
    let intendedUid: string | null = null;

    async function enqueueBeforeWorker(dispatchId: string, boundary: string): Promise<void> {
      const reference = firestore.collection("provisioningDispatch").doc(dispatchId);
      const persisted = (await reference.get()).data();
      const eventId = `p3-45-${operationId}-${boundary}`;
      const eventDigest = createHash("sha256")
        .update(`provision-created-event:v1\0${eventId}`, "utf8")
        .digest("hex");

      assert.equal(persisted?.enqueued, false, `${boundary} worker delivery is forbidden before durable acknowledgement`);
      assert.equal(persisted?.workerAck, null, `${boundary} dispatch is unacknowledged by the worker before delivery`);
      await outbox.handleCreated({ dispatch: persisted, eventId });
      assert.equal(enqueue.enqueued.at(-1)?.dispatchId, dispatchId, `${boundary} created path enqueues the persisted dispatch`);

      const acknowledged = (await reference.get()).data();
      assert.equal(acknowledged?.enqueued, true, `${boundary} worker delivery follows guarded acknowledgement only`);
      assert.equal(typeof acknowledged?.enqueuedAt, "number", `${boundary} acknowledgement persists transaction time`);
      assert.equal(Number.isFinite(acknowledged?.enqueuedAt), true, `${boundary} acknowledgement time is valid`);
      assert.equal(acknowledged?.enqueueSource, "trigger", `${boundary} acknowledgement retains trigger provenance`);
      assert.equal(acknowledged?.enqueueEventId, eventDigest, `${boundary} acknowledgement persists the deterministic created-event digest`);
      await invokeBackendTask(projectId, dispatchId);
    }

  try {
    await auth.createUser({ uid: adminUid, email: adminEmail, password: adminPassword });
    await firestore.collection("users").doc(adminUid).set({ role: "admin", isActive: true });
    const idToken = await signIn(adminEmail, adminPassword);
    const payload = {
      operationId,
      email: `full-flow-user-${suffix}@example.com`,
      nombre: "Full",
      apellido1: "Flow",
      role: "employee",
    };

    // This is the only client-originated mutation. No status polling or resubmission
    // occurs until backend task deliveries have completed every persisted boundary.
    const submitted = await fetch(functionsUrl("submitProvisioning", projectId), {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${idToken}`,
        "X-Firebase-AppCheck": appCheckToken(),
      },
      body: JSON.stringify({ data: payload }),
    });
    assert.equal(submitted.status, 200, await submitted.clone().text());
    assert.deepEqual(
      await submitted.json(),
      { result: { operationId, status: "pending" } },
      "App Check/admin submission returns only the pending operation",
    );

    const initialDispatchId = deriveDispatchId(operationId, "acquire", 0, 0);
    const initialDispatch = await firestore.collection("provisioningDispatch").doc(initialDispatchId).get();
    assert.equal(initialDispatch.data()?.enqueued, false, "submission persists the initial durable outbox record before backend work");
    assert.equal(initialDispatch.data()?.workerAck, null);

    await enqueueBeforeWorker(initialDispatchId, "acquire");
    let operation = (await firestore.collection("provisioningOperations").doc(operationId).get()).data();
    assert.equal(operation?.phase, "auth_preflight", "acquisition creates the preflight task boundary");

    const preflightDispatchId = operation?.currentDispatchId as string;
    await enqueueBeforeWorker(preflightDispatchId, "auth_preflight");
    operation = (await firestore.collection("provisioningOperations").doc(operationId).get()).data();
    assert.equal(operation?.phase, "auth_create", "preflight and persisted intent advance without a client re-drive");

    const authCreateDispatchId = operation?.currentDispatchId as string;
    await enqueueBeforeWorker(authCreateDispatchId, "auth_create");
    operation = (await firestore.collection("provisioningOperations").doc(operationId).get()).data();
    assert.equal(operation?.phase, "profile_commit", "Auth create and dual reads advance through the backend task");

    const profileDispatchId = operation?.currentDispatchId as string;
    await enqueueBeforeWorker(profileDispatchId, "profile_commit");
    operation = (await firestore.collection("provisioningOperations").doc(operationId).get()).data();
    intendedUid = operation?.intendedUid as string;
    assert.equal(operation?.status, "completed", "profile commit atomically reaches terminal completion");
    assert.equal(operation?.phase, "terminal");
    assert.equal(typeof intendedUid, "string");
    assert.equal((await firestore.collection("users").doc(intendedUid).get()).data()?.provisionedBy, "trusted-backend");

    const status = await fetch(functionsUrl("getProvisioningStatus", projectId), {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${idToken}`,
        "X-Firebase-AppCheck": appCheckToken(),
      },
      body: JSON.stringify({ data: { operationId } }),
    });
    assert.equal(status.status, 200, await status.clone().text());
    const response = await status.json() as {
      readonly result?: { readonly status?: unknown; readonly passwordResetLink?: unknown };
    };
    assert.equal(response.result?.status, "completed");
    assert.equal(typeof response.result?.passwordResetLink, "string", "the authorized completed response returns an immediate fresh reset link");
    assert.match(response.result?.passwordResetLink as string, /^https?:\/\//);
    assert.equal(Object.hasOwn(operation ?? {}, "passwordResetLink"), false, "the link is response-only, not persisted on the operation");
    assert.equal(Object.hasOwn((await firestore.collection("users").doc(intendedUid).get()).data() ?? {}, "passwordResetLink"), false, "the link is not persisted on the profile");
  } finally {
    if (intendedUid !== null) {
      await auth.deleteUser(intendedUid).catch(() => undefined);
      await firestore.collection("users").doc(intendedUid).delete();
    }
    await auth.deleteUser(adminUid).catch(() => undefined);
    await firestore.collection("users").doc(adminUid).delete();
    await firestore.collection("provisioningOperations").doc(operationId).delete();
    await Promise.all((await firestore.collection("provisioningDispatch").where("operationId", "==", operationId).get()).docs.map((document) => document.ref.delete()));
    await Promise.all((await firestore.collection("provisioningAudit").where("operationId", "==", operationId).get()).docs.map((document) => document.ref.delete()));
    await deleteApp(app);
  }
});
