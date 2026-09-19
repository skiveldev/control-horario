import assert from "node:assert/strict";
import test from "node:test";
import {
  StatusAuthorizationError,
  StatusProjectionError,
  authorizeStatusRequest,
  getAuthorizedStatus,
  type StatusAuthorizationPort,
} from "../../src/provisioning/status.ts";
import { getProvisioningStatus } from "../../src/index.ts";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";

const operationId = "123e4567-e89b-42d3-a456-426614174000";
const storedFingerprint = "a".repeat(64);

class FakeStatusAuthorizationPort implements StatusAuthorizationPort {
  readonly reads: string[] = [];
  private readonly user: { readonly role: string; readonly isActive: boolean } | null;
  private readonly operation: { readonly fingerprint: string } | null;

  constructor(
    user: { readonly role: string; readonly isActive: boolean } | null,
    operation: { readonly fingerprint: string } | null,
  ) {
    this.user = user;
    this.operation = operation;
  }

  async readUser(uid: string): Promise<{ readonly role: string; readonly isActive: boolean } | null> {
    this.reads.push(`user:${uid}`);
    return this.user;
  }

  async readOperation(id: string): Promise<{ readonly fingerprint: string } | null> {
    this.reads.push(`operation:${id}`);
    return this.operation;
  }
}

async function expectCode(
  work: () => Promise<void>,
  code: "unauthenticated" | "permission-denied" | "not-found" | "already-exists",
): Promise<void> {
  await assert.rejects(work, (error: unknown) => (
    error instanceof StatusAuthorizationError && error.code === code
  ));
}

for (const [name, request, user, operation, code, expectedReads] of [
  [
    "rejects unauthenticated callers before any read",
    { callerUid: null, operationId },
    null,
    { fingerprint: storedFingerprint },
    "unauthenticated",
    [],
  ],
  [
    "rejects non-admin callers after only the user read",
    { callerUid: "employee-uid", operationId },
    { role: "employee", isActive: true },
    { fingerprint: storedFingerprint },
    "permission-denied",
    ["user:employee-uid"],
  ],
  [
    "rejects unknown operations after user then operation reads",
    { callerUid: "admin-uid", operationId },
    { role: "admin", isActive: true },
    null,
    "not-found",
    ["user:admin-uid", `operation:${operationId}`],
  ],
  [
    "rejects mismatched fingerprints after user then operation reads",
    { callerUid: "admin-uid", operationId, fingerprint: "b".repeat(64) },
    { role: "admin", isActive: true },
    { fingerprint: storedFingerprint },
    "already-exists",
    ["user:admin-uid", `operation:${operationId}`],
  ],
] as const) {
  test(name, async () => {
    const port = new FakeStatusAuthorizationPort(user, operation);
    await expectCode(
      () => authorizeStatusRequest(request, port),
      code,
    );
    assert.deepEqual(port.reads, expectedReads);
  });
}

test("allows an active admin to reach the narrow handler with absent or matching fingerprints", async () => {
  for (const fingerprint of [undefined, storedFingerprint]) {
    const port = new FakeStatusAuthorizationPort(
      { role: "admin", isActive: true },
      { fingerprint: storedFingerprint },
    );

    await authorizeStatusRequest(
      { callerUid: "admin-uid", operationId, fingerprint },
      port,
    );

    assert.deepEqual(port.reads, ["user:admin-uid", `operation:${operationId}`]);
  }
});

class FakeStatusLookupPort implements StatusAuthorizationPort {
  readonly reads: string[] = [];
  private readonly operation: { readonly fingerprint: string } | null;

  constructor(operation: { readonly fingerprint: string } | null) {
    this.operation = operation;
  }

  async readUser(uid: string): Promise<{ readonly role: string; readonly isActive: boolean } | null> {
    this.reads.push(`user:${uid}`);
    return { role: "admin", isActive: true };
  }

  async readOperation(id: string): Promise<{ readonly fingerprint: string } | null> {
    this.reads.push(`operation:${id}`);
    return this.operation;
  }
}

const hostileExtras = {
  email: "private@example.com",
  rawEmail: "private@example.com",
  payload: { email: "private@example.com", dni: "private-dni" },
  normalizedPayload: { email: "private@example.com", dni: "private-dni" },
  rawPayload: { email: "private@example.com", dni: "private-dni" },
  ownerToken: "owner-token",
  leaseExpiresAt: 123456,
  generation: 7,
  version: 9,
  retryEvidence: { retryCount: 8 },
  failureEvidence: [{ code: "internal" }],
  auditEventId: "audit-event-id",
  auditId: "audit-id",
  auditIdentity: { actorUid: "raw-uid" },
  auditActorIdentity: { uid: "raw-uid" },
  submittedByDigest: "audit-actor-digest",
} as const;

const safeStatusCases = [
  [
    "pending",
    { operationId, fingerprint: storedFingerprint, status: "pending", phase: "dispatch_pending", ...hostileExtras },
    { operationId, status: "pending", retryAfterSeconds: 1 },
  ],
  [
    "active",
    { operationId, fingerprint: storedFingerprint, status: "active", phase: "auth_create", ...hostileExtras },
    { operationId, status: "active", phase: "auth_create", retryAfterSeconds: 1 },
  ],
  [
    "completed",
    { operationId, fingerprint: storedFingerprint, status: "completed", phase: "terminal", intendedUid: "trusted-user-id", ...hostileExtras },
    { operationId, status: "completed", userId: "trusted-user-id", idempotent: true },
  ],
  [
    "failed",
    { operationId, fingerprint: storedFingerprint, status: "failed", phase: "terminal", terminalCode: "unavailable", ...hostileExtras },
    { operationId, status: "failed", terminalCode: "unavailable" },
  ],
  [
    "manual recovery",
    { operationId, fingerprint: storedFingerprint, status: "manual_recovery", phase: "terminal", terminalCode: "internal", recoveryCode: "manual-review", ...hostileExtras },
    { operationId, status: "manual_recovery", terminalCode: "internal", recoveryCode: "manual-review" },
  ],
] as const;

test("projects authorized status operations to exact immutable safe DTOs", async () => {
  for (const [name, operation, expected] of safeStatusCases) {
    const port = new FakeStatusLookupPort(operation);
    const result = await getAuthorizedStatus({ callerUid: "admin-uid", operationId }, port);

    assert.deepEqual(result, expected, `${name} projects its safe values`);
    assert.deepEqual(Reflect.ownKeys(result), Reflect.ownKeys(expected), `${name} has exactly its safe own keys`);
    assert.equal(Object.isFrozen(result), true, `${name} result is immutable`);
    assert.throws(() => Object.assign(result, { status: "leaked" }), TypeError, `${name} result rejects mutation`);
    assert.equal(JSON.stringify(result).includes("private@example.com"), false, `${name} serializes no raw email`);

    for (const key of Reflect.ownKeys(hostileExtras)) {
      assert.equal(Object.hasOwn(result, key), false, `${name} omits hostile ${String(key)}`);
    }

    assert.deepEqual(port.reads, ["user:admin-uid", `operation:${operationId}`], `${name} preserves authorization lookup order`);
  }
});

test("fails closed when an authorized operation cannot be projected safely", async () => {
  const port = new FakeStatusLookupPort({
    operationId,
    fingerprint: storedFingerprint,
    status: "active",
    phase: "terminal",
    ...hostileExtras,
  });

  await assert.rejects(
    () => getAuthorizedStatus({ callerUid: "admin-uid", operationId }, port),
    (error: unknown) => error instanceof StatusProjectionError && error.code === "invalid-projection",
  );
  assert.deepEqual(port.reads, ["user:admin-uid", `operation:${operationId}`]);
});

function statusEndpointUrl(projectId: string): string {
  return `http://${process.env.FUNCTIONS_EMULATOR_HOST}/${projectId}/us-central1/getProvisioningStatus`;
}

function emulatorAppCheckToken(): string {
  return [
    Buffer.from(JSON.stringify({ alg: "none" })).toString("base64url"),
    Buffer.from(JSON.stringify({ sub: "p3-44d-status-test-app" })).toString("base64url"),
    "signature",
  ].join(".");
}

async function statusIdToken(email: string, password: string): Promise<string> {
  const response = await fetch(
    `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=emulator`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password, returnSecureToken: true }),
    },
  );
  assert.equal(response.status, 200);
  const body = await response.json() as { readonly idToken?: unknown };
  assert.equal(typeof body.idToken, "string");
  return body.idToken;
}

test("P3.44d composes the basic status callable with Firestore authorization and a safe DTO", {
  skip: !process.env.FUNCTIONS_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST,
}, async () => {
  const projectId = process.env.GCLOUD_PROJECT || "demo-no-project";
  const email = "status-admin@example.com";
  const password = "Status-password-1";
  const uid = "status-admin-uid";
  const app = initializeApp({ projectId }, "p3-44d-status-callable");
  try {
    const firestore = getFirestore(app);
    await getAuth(app).createUser({ uid, email, password });
    await firestore.collection("users").doc(uid).set({ role: "admin", isActive: true });
    await firestore.collection("provisioningOperations").doc(operationId).set({
      operationId,
      fingerprint: storedFingerprint,
      status: "active",
      phase: "auth_create",
      email: "private@example.com",
      ownerToken: "private-owner-token",
    });
    const token = await statusIdToken(email, password);
    const call = () => fetch(statusEndpointUrl(projectId), {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
        "X-Firebase-AppCheck": emulatorAppCheckToken(),
      },
      body: JSON.stringify({ data: { operationId } }),
    });

    const success = await call();
    assert.equal(success.status, 200, await success.clone().text());
    const successBody = await success.json() as { readonly result?: unknown };
    assert.deepEqual(successBody.result, {
      operationId,
      status: "active",
      phase: "auth_create",
      retryAfterSeconds: 1,
    });

    await firestore.collection("users").doc(uid).set({ role: "employee", isActive: true });
    const denied = await call();
    assert.equal(denied.status, 403);
  } finally {
    await deleteApp(app);
  }
});
