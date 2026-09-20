import assert from "node:assert/strict";
import test from "node:test";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { FirestoreStore } from "../../src/provisioning/firestore_store.ts";
import { createInitialState, type OperationState } from "../../src/provisioning/model.ts";
import { runFrozenVectors } from "./store_conformance.test.ts";
import { MemoryStore } from "../../src/provisioning/memory_store.ts";

const state = (): OperationState => createInitialState({
  operationId: "123e4567-e89b-42d3-a456-426614174000", fingerprint: "a".repeat(64), status: "pending", phase: "dispatch_pending",
  normalizedPayload: { email: "employee@example.com", nombre: "Ana", apellido1: "Lopez", apellido2: null, employeeId: "", weeklyHours: 40, dni: null, telefono: null, cargo: null, departamento: null, empresa: null, scheduleId: null, calendarId: null, fechaInicio: null, fechaFin: null, role: "employee", isSupervisor: false, supervisorId: null, isActive: true },
  intendedUid: "uid-employee", generation: 0, version: 0, ownerToken: null, leaseExpiresAt: null, currentDispatchId: null, authAttempted: false, authAttempt: null, createdAt: 0, updatedAt: 0,
});

test("Firestore and memory stores produce byte-equal frozen-vector outcomes", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST, "Firestore emulator must be running");
  const app = initializeApp({ projectId: "p1b-conformance-test" }, "p1b-conformance-test");
  try {
    const memory = await runFrozenVectors(new MemoryStore());
    const firestore = await runFrozenVectors(new FirestoreStore(getFirestore(app)));
    assert.deepEqual(firestore, memory);
  } finally {
    await deleteApp(app);
  }
});

test("FirestoreStore uses an emulator transaction for an operation round trip", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST, "Firestore emulator must be running");
  const app = initializeApp({ projectId: "p1b-store-test" }, "p1b-store-test");
  try {
    const store = new FirestoreStore(getFirestore(app));
    await store.transaction((transaction) => transaction.write("operation", state()));
    const persisted = await store.transaction((transaction) => transaction.read("operation"));
    assert.equal(persisted?.operationId, state().operationId);
    assert.equal(persisted?.version, 0);
  } finally {
    await deleteApp(app);
  }
});

test("FirestoreStore exposes the backend transaction read time as authoritative", {
  skip: !process.env.FIRESTORE_EMULATOR_HOST,
}, async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST, "Firestore emulator must be running");
  const app = initializeApp({ projectId: "p1b-authoritative-time-test" }, "p1b-authoritative-time-test");
  try {
    const store = new FirestoreStore(getFirestore(app));
    await store.transaction((transaction) => transaction.write("operation", state()));
    const observedAt = await store.transaction(async (transaction) => {
      await transaction.read("operation");
      return transaction.authoritativeNow();
    });
    assert.equal(Number.isInteger(observedAt), true);
    assert.ok(observedAt > 0);
  } finally {
    await deleteApp(app);
  }
});
