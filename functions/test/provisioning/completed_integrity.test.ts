import assert from "node:assert/strict";
import test from "node:test";
import { deduplicateAudit, type AuditEvent } from "../../src/provisioning/audit.ts";
import { isValidState } from "../../src/provisioning/model.ts";
import { deriveDisplayName } from "../../src/provisioning/normalize.ts";
import {
  CompletedIntegrityError,
  getAuthorizedStatusWithCompletedIntegrity,
  getAuthorizedStatusWithPasswordResetLink,
  PasswordResetLinkError,
  StatusAuthorizationError,
  type CompletedIntegrityPort,
  type PasswordResetLinkGenerator,
  type StatusAuthorizationPort,
} from "../../src/provisioning/status.ts";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";

const operationId = "123e4567-e89b-42d3-a456-426614174000";
const fingerprint = "a".repeat(64);
const uid = "trusted-user";
const email = "ana@example.com";
const persistedPayload = {
  email, nombre: "Ana", apellido1: "García", apellido2: "López", employeeId: "EMP-7",
  weeklyHours: 40, dni: null, telefono: null, cargo: null, departamento: null, empresa: null,
  scheduleId: null, calendarId: null, fechaInicio: null, fechaFin: null, role: "employee",
  isSupervisor: false, supervisorId: null, isActive: true,
} as const;
const completedAt = 1_700_000_000_000;
const operation = {
  operationId, fingerprint, normalizedPayload: persistedPayload, intendedUid: uid,
  status: "completed", phase: "terminal", generation: 2, version: 5,
  ownerToken: null, leaseExpiresAt: null, currentDispatchId: null,
  authAttempted: true,
  authAttempt: {
    attemptId: "b".repeat(64), intentAt: completedAt - 800, callStartedAt: completedAt - 700,
    result: "confirmed", returnedUid: uid, returnedEmail: email,
    proof: {
      attemptId: "b".repeat(64), confirmedAt: completedAt - 600,
      uidRead: uid, emailRead: email,
    },
  },
  createdAt: completedAt - 1_000, updatedAt: completedAt,
} as const;

function profile(): Record<string, unknown> {
  return {
    ...persistedPayload,
    displayName: deriveDisplayName(
      persistedPayload.nombre,
      persistedPayload.apellido1,
      persistedPayload.apellido2,
    ),
    userId: uid, provisioningOperationId: operationId,
    provisioningFingerprint: fingerprint, provisioningSchemaVersion: 1,
    provisionedBy: "trusted-backend", provisionedAt: completedAt,
  };
}

class Port implements StatusAuthorizationPort, CompletedIntegrityPort, PasswordResetLinkGenerator {
  readonly reads: string[] = [];
  readonly audits = new Map<string, AuditEvent>();
  readonly generatedLinks: string[] = [];
  linkFailure: Error | null = null;
  linkResult: unknown = undefined;
  statusUser: { readonly role: string; readonly isActive: boolean } | null = { role: "admin", isActive: true };
  storedOperation: ({ readonly fingerprint: string } & Record<string, unknown>) | null = operation;
  uidUser: { readonly uid: string; readonly email: string } | null = { uid, email };
  emailUser: { readonly uid: string; readonly email: string } | null = { uid, email };
  storedProfile: unknown | null = profile();
  uidFailure: Error | null = null;
  emailFailure: Error | null = null;
  profileFailure: Error | null = null;

  async readUser(): Promise<{ readonly role: string; readonly isActive: boolean } | null> {
    return this.statusUser;
  }
  async readOperation(): Promise<({ readonly fingerprint: string } & Record<string, unknown>) | null> {
    return this.storedOperation;
  }
  async readAuthByUid(value: string): Promise<{ readonly uid: string; readonly email: string } | null> {
    this.reads.push(`uid:${value}`); if (this.uidFailure) throw this.uidFailure; return this.uidUser;
  }
  async readAuthByEmail(value: string): Promise<{ readonly uid: string; readonly email: string } | null> {
    this.reads.push(`email:${value}`); if (this.emailFailure) throw this.emailFailure; return this.emailUser;
  }
  async readProfile(value: string): Promise<unknown | null> {
    this.reads.push(`profile:${value}`); if (this.profileFailure) throw this.profileFailure; return this.storedProfile;
  }
  async recordCompletedIntegrityAudit(event: AuditEvent): Promise<void> {
    const existing = this.audits.get(event.eventId);
    if (existing) deduplicateAudit(existing, event);
    else this.audits.set(event.eventId, event);
  }
  async generatePasswordResetLink(value: string): Promise<string> {
    this.reads.push(`link:${value}`);
    if (this.linkFailure) throw this.linkFailure;
    if (this.linkResult !== undefined) return this.linkResult as string;
    const link = `https://reset.example/${this.generatedLinks.length + 1}`;
    this.generatedLinks.push(link);
    return link;
  }
}

async function expectIntegrityFailure(port: Port): Promise<void> {
  const before = structuredClone(operation);
  await assert.rejects(
    () => getAuthorizedStatusWithCompletedIntegrity({ callerUid: "admin", operationId }, port, port),
    (error: unknown) => error instanceof CompletedIntegrityError && error.code === "integrity-failed",
  );
  assert.deepEqual(operation, before, "completed operation remains immutable");
  assert.equal(port.audits.size, 1, "one immutable PII-safe integrity audit persists");
  const [event] = port.audits.values();
  assert.equal(event.createdAt, completedAt, "audit time is bound to persisted completion evidence");
}

test("accepts the canonical completed record with persisted timestamps, no root schemaVersion, and no stored displayName", async () => {
  const port = new Port();
  assert.equal(Object.hasOwn(operation, "schemaVersion"), false);
  assert.equal(Object.hasOwn(persistedPayload, "displayName"), false);
  assert.equal(isValidState(operation), true, "completed fixture is canonical OperationState");
  assert.deepEqual(
    await getAuthorizedStatusWithCompletedIntegrity({ callerUid: "admin", operationId }, port, port),
    { operationId, status: "completed", userId: uid, idempotent: true },
  );
  assert.deepEqual(port.reads, [`uid:${uid}`, `email:${email}`, `profile:${uid}`]);
  assert.equal(port.audits.size, 0);
});

for (const [name, change] of [
  ["missing UID index", (port: Port) => { port.uidUser = null; }],
  ["UID/email index disagreement", (port: Port) => { port.emailUser = { uid: "other", email }; }],
  ["wrong Auth email", (port: Port) => { port.uidUser = { uid, email: "other@example.com" }; }],
  ["absent profile", (port: Port) => { port.storedProfile = null; }],
  ["malformed profile provenance", (port: Port) => { port.storedProfile = { ...profile(), displayName: null }; }],
  ["UID read failure", (port: Port) => { port.uidFailure = new Error("unavailable"); }],
  ["email read failure", (port: Port) => { port.emailFailure = new Error("unavailable"); }],
  ["profile read failure", (port: Port) => { port.profileFailure = new Error("unavailable"); }],
] as const) {
  test(`fails closed for ${name} after attempting every integrity read`, async () => {
    const port = new Port();
    change(port);
    await expectIntegrityFailure(port);
    assert.deepEqual(port.reads, [`uid:${uid}`, `email:${email}`, `profile:${uid}`]);
  });
}

test("deduplicates deterministic audit replay and fails closed on incompatible identity reuse", async () => {
  const port = new Port();
  port.uidUser = null;
  await expectIntegrityFailure(port);
  const [first] = port.audits.values();
  await expectIntegrityFailure(port);
  const [replayed] = port.audits.values();
  assert.equal(port.audits.size, 1, "matching replay does not duplicate the audit");
  assert.equal(replayed.createdAt, first.createdAt, "matching replay preserves deterministic audit bytes");
  port.audits.set(first.eventId, { ...first, code: "internal" });
  await expectIntegrityFailure(port);
});

test("rejects non-string, empty, and whitespace-only reset links after integrity", async () => {
  const request = { callerUid: "admin", operationId };
  for (const malformedResult of [null, 0, "", " \t\n"] as const) {
    const port = new Port();
    port.linkResult = malformedResult;
    const operationBefore = structuredClone(operation);
    const profileBefore = structuredClone(port.storedProfile);
    await assert.rejects(
      () => getAuthorizedStatusWithPasswordResetLink(request, port, port, port),
      (error: unknown) => error instanceof PasswordResetLinkError && error.code === "unavailable"
        && error.message === "unavailable",
      `rejects malformed reset link ${String(malformedResult)}`,
    );
    assert.deepEqual(port.reads, [`uid:${uid}`, `email:${email}`, `profile:${uid}`, `link:${email}`]);
    assert.deepEqual(operation, operationBefore, "malformed link leaves completed state unchanged");
    assert.deepEqual(port.storedProfile, profileBefore, "malformed link leaves profile unchanged");
    assert.equal(port.audits.size, 0, "malformed link adds no audit");
    assert.equal(port.generatedLinks.length, 0, "malformed link is never retained");
  }
});

function statusEndpointUrl(projectId: string): string {
  const host = process.env.FUNCTIONS_EMULATOR_HOST ?? "127.0.0.1:5001";
  return `http://${host}/${projectId}/us-central1/getProvisioningStatus`;
}

function emulatorAppCheckToken(): string {
  return [
    Buffer.from(JSON.stringify({ alg: "none" })).toString("base64url"),
    Buffer.from(JSON.stringify({ sub: "p3-44e-integrity-test-app" })).toString("base64url"),
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
  return body.idToken as string;
}

test("P3.44e composes completed integrity and a fresh reset link through Firestore/Auth/Functions", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST,
}, async () => {
  const projectId = process.env.GCLOUD_PROJECT || "demo-no-project";
  const adminEmail = "completed-status-admin@example.com";
  const adminPassword = "Completed-status-password-1";
  const adminUid = "completed-status-admin-uid";
  const app = initializeApp({ projectId }, "p3-44e-completed-status-callable");
  try {
    const firestore = getFirestore(app);
    const auth = getAuth(app);
    await auth.createUser({ uid: adminUid, email: adminEmail, password: adminPassword });
    await auth.createUser({ uid, email });
    await firestore.collection("users").doc(adminUid).set({ role: "admin", isActive: true });
    await firestore.collection("users").doc(uid).set(profile());
    await firestore.collection("provisioningOperations").doc(operationId).set(operation);
    const token = await statusIdToken(adminEmail, adminPassword);
    const call = () => fetch(statusEndpointUrl(projectId), {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
        "X-Firebase-AppCheck": emulatorAppCheckToken(),
      },
      body: JSON.stringify({ data: { operationId } }),
    });

    const completed = await call();
    assert.equal(completed.status, 200, await completed.clone().text());
    const completedBody = await completed.json() as { readonly result?: unknown };
    const firstLink = (completedBody.result as { readonly passwordResetLink?: unknown }).passwordResetLink;
    assert.equal(typeof firstLink, "string");
    assert.match(firstLink as string, /^https?:\/\//);
    const completedAgain = await call();
    const completedAgainBody = await completedAgain.json() as { readonly result?: { readonly passwordResetLink?: unknown } };
    assert.equal(completedAgain.status, 200);
    assert.equal(typeof completedAgainBody.result?.passwordResetLink, "string");
    assert.notEqual(completedAgainBody.result?.passwordResetLink, firstLink, "each completed response receives a fresh link");
    assert.deepEqual(await firestore.collection("provisioningAudit").get().then((snapshot) => snapshot.docs.map((document) => document.data())), []);
    assert.equal(Object.hasOwn((await firestore.collection("provisioningOperations").doc(operationId).get()).data() ?? {}, "passwordResetLink"), false);
    assert.equal(Object.hasOwn((await firestore.collection("users").doc(uid).get()).data() ?? {}, "passwordResetLink"), false);

    await firestore.collection("users").doc(uid).set({ ...profile(), provisioningFingerprint: "b".repeat(64) });
    const firstFailure = await call();
    const secondFailure = await call();
    assert.equal(firstFailure.status, 400, await firstFailure.clone().text());
    assert.equal(secondFailure.status, 400, await secondFailure.clone().text());
    assert.equal(JSON.stringify(await firstFailure.json()).includes("passwordResetLink"), false);
    assert.equal(JSON.stringify(await secondFailure.json()).includes("passwordResetLink"), false);
    const audits = await firestore.collection("provisioningAudit").get();
    assert.equal(audits.size, 1, "integrity mismatch creates one deterministic audit");
    const audit = audits.docs[0]?.data();
    assert.deepEqual(
      {
        category: audit?.category,
        stage: audit?.stage,
        outcome: audit?.outcome,
        code: audit?.code,
        actorUidDigest: audit?.actorUidDigest,
        intendedUidDigest: audit?.intendedUidDigest,
      },
      { category: "failure", stage: "completed_integrity", outcome: "failed", code: "integrity-failed", actorUidDigest: null, intendedUidDigest: null },
    );
  } finally {
    await deleteApp(app);
  }
});

test("issues one fresh link only after completed integrity succeeds and retries safely", async () => {
  const port = new Port();
  const request = { callerUid: "admin", operationId };
  const operationBefore = structuredClone(operation);
  const profileBefore = structuredClone(port.storedProfile);

  const first = await getAuthorizedStatusWithPasswordResetLink(request, port, port, port);
  const second = await getAuthorizedStatusWithPasswordResetLink(request, port, port, port);
  assert.deepEqual(first, { operationId, status: "completed", userId: uid, idempotent: true, passwordResetLink: "https://reset.example/1" });
  assert.equal((second as { readonly passwordResetLink: string }).passwordResetLink, "https://reset.example/2");
  assert.deepEqual(port.reads, [
    `uid:${uid}`, `email:${email}`, `profile:${uid}`, `link:${email}`,
    `uid:${uid}`, `email:${email}`, `profile:${uid}`, `link:${email}`,
  ]);
  assert.deepEqual(operation, operationBefore, "link issuance never changes completed state");
  assert.deepEqual(port.storedProfile, profileBefore, "link issuance never changes profile");
  assert.equal(port.audits.size, 0, "link issuance never writes an audit");

  const failed = new Port();
  failed.linkFailure = new Error("transient");
  await assert.rejects(
    () => getAuthorizedStatusWithPasswordResetLink(request, failed, failed, failed),
    (error: unknown) => error instanceof PasswordResetLinkError && error.code === "unavailable",
  );
  assert.equal(failed.generatedLinks.length, 0);
  assert.equal(failed.audits.size, 0, "transient generation failure adds no audit");
  failed.linkFailure = null;
  assert.equal(
    (await getAuthorizedStatusWithPasswordResetLink(request, failed, failed, failed) as { readonly passwordResetLink: string }).passwordResetLink,
    "https://reset.example/1",
    "a later invocation receives a fresh generated link",
  );

  const integrityFailed = new Port();
  integrityFailed.uidUser = null;
  await assert.rejects(() => getAuthorizedStatusWithPasswordResetLink(request, integrityFailed, integrityFailed, integrityFailed), CompletedIntegrityError);
  assert.equal(integrityFailed.generatedLinks.length, 0, "integrity failure never invokes generation");

  const denied = new Port();
  denied.statusUser = { role: "employee", isActive: true };
  await assert.rejects(
    () => getAuthorizedStatusWithPasswordResetLink(request, denied, denied, denied),
    (error: unknown) => error instanceof StatusAuthorizationError && error.code === "permission-denied",
  );
  assert.equal(denied.generatedLinks.length, 0, "denial never invokes generation");

  const active = new Port();
  active.storedOperation = { operationId, fingerprint, status: "active", phase: "auth_create" };
  assert.deepEqual(
    await getAuthorizedStatusWithPasswordResetLink(request, active, active, active),
    { operationId, status: "active", phase: "auth_create", retryAfterSeconds: 1 },
  );
  assert.equal(active.generatedLinks.length, 0, "non-completed status never invokes generation");
});
