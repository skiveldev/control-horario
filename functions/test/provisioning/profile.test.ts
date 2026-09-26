import assert from "node:assert/strict";
import test from "node:test";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import type { NormalizedPayload } from "../../src/provisioning/normalize.ts";
import {
  matchesProfileProvenance,
  storedProfileMatchesOperation,
  type ProfileExpectation,
  type ProfileReader,
} from "../../src/provisioning/profile.ts";

const payload: NormalizedPayload = {
  email: "ana@example.com",
  nombre: "Ana",
  apellido1: "García",
  apellido2: "López",
  employeeId: "EMP-7",
  weeklyHours: 40,
  dni: "12345678Z",
  telefono: "+34123456789",
  cargo: "Engineer",
  departamento: "Platform",
  empresa: "Control Horario",
  scheduleId: "schedule-a",
  calendarId: "calendar-a",
  fechaInicio: "2026-01-02",
  fechaFin: null,
  role: "employee",
  isSupervisor: true,
  supervisorId: "supervisor-a",
  isActive: true,
  displayName: "Ana García López",
};

const expectation: ProfileExpectation = {
  intendedUid: "uid-ana",
  operationId: "82ac2574-9e1c-4d72-a6de-55624774f96c",
  fingerprint: "a".repeat(64),
  schemaVersion: 1,
  normalizedPayload: payload,
};

function matchingProfile(): Record<string, unknown> {
  return {
    ...payload,
    userId: expectation.intendedUid,
    provisioningOperationId: expectation.operationId,
    provisioningFingerprint: expectation.fingerprint,
    provisioningSchemaVersion: expectation.schemaVersion,
    provisionedBy: "trusted-backend",
    provisionedAt: 1_800_000_000_000,
  };
}

function different(value: unknown): unknown {
  if (typeof value === "boolean") return !value;
  if (typeof value === "number") return value + 1;
  if (value === null) return "unexpected";
  return `${String(value)}-different`;
}

function mismatchVectors(): Array<[string, Record<string, unknown>]> {
  const base = matchingProfile();
  const vectors: Array<[string, Record<string, unknown>]> = [
    ["userId", { ...base, userId: "uid-other" }],
    ["operationId", { ...base, provisioningOperationId: "operation-other" }],
    ["fingerprint", { ...base, provisioningFingerprint: "b".repeat(64) }],
    ["schemaVersion", { ...base, provisioningSchemaVersion: 2 }],
    ["provisionedBy", { ...base, provisionedBy: "untrusted-client" }],
  ];
  for (const [field, value] of Object.entries(payload)) {
    vectors.push([field, { ...base, [field]: different(value) }]);
  }
  return vectors;
}

function assertPureVectors(): void {
  assert.equal(matchesProfileProvenance(matchingProfile(), expectation), true, "matching profile");
  assert.equal(matchesProfileProvenance(null, expectation), false, "missing profile");
  for (const [field, profile] of mismatchVectors()) {
    assert.equal(matchesProfileProvenance(profile, expectation), false, `${field} mismatch`);
  }
  const { provisionedAt: _missing, ...withoutProvisionedAt } = matchingProfile();
  assert.equal(matchesProfileProvenance(withoutProvisionedAt, expectation), false, "missing provisionedAt");
}

test("pure profile provenance requires the complete operation and normalized profile match", () => {
  assertPureVectors();
});

test("profile read failures propagate instead of becoming absence", async () => {
  const readFailure = new Error("profile read unavailable");
  const reader: ProfileReader = {
    async readProfile(userId: string): Promise<unknown | null> {
      assert.equal(userId, expectation.intendedUid);
      throw readFailure;
    },
  };

  await assert.rejects(
    storedProfileMatchesOperation(reader, expectation),
    (error: unknown) => error === readFailure,
  );
});

class FirestoreProfileReader implements ProfileReader {
  private readonly firestore: Firestore;

  constructor(firestore: Firestore) {
    this.firestore = firestore;
  }

  async readProfile(userId: string): Promise<unknown | null> {
    const snapshot = await this.firestore.collection("users").doc(userId).get();
    return snapshot.exists ? snapshot.data() ?? null : null;
  }
}

test("Firestore profile provenance has byte-equivalent match, missing, and mismatch outcomes", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  const app = initializeApp({ projectId: "p3-profile-provenance" }, "p3-profile-provenance");
  try {
    const firestore = getFirestore(app);
    const reader = new FirestoreProfileReader(firestore);
    const reference = firestore.collection("users").doc(expectation.intendedUid);

    assert.equal(await storedProfileMatchesOperation(reader, expectation), false, "missing profile");
    await reference.set(matchingProfile());
    assert.equal(await storedProfileMatchesOperation(reader, expectation), true, "matching profile");

    for (const [field, profile] of mismatchVectors()) {
      await reference.set(profile);
      assert.equal(await storedProfileMatchesOperation(reader, expectation), false, `${field} mismatch`);
    }
    const { provisionedAt: _missing, ...withoutProvisionedAt } = matchingProfile();
    await reference.set(withoutProvisionedAt);
    assert.equal(await storedProfileMatchesOperation(reader, expectation), false, "missing provisionedAt");
  } finally {
    await deleteApp(app);
  }
});
