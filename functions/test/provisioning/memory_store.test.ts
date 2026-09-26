import assert from "node:assert/strict";
import test from "node:test";
import { createEvent, createInitialState, reduce, type OperationState, type ReducerRequest } from "../../src/provisioning/model.ts";
import { MemoryStore } from "../../src/provisioning/memory_store.ts";

const state = (): OperationState => createInitialState({
  operationId: "123e4567-e89b-42d3-a456-426614174000",
  fingerprint: "a".repeat(64), status: "pending", phase: "dispatch_pending",
  normalizedPayload: { email: "employee@example.com", nombre: "Ana", apellido1: "Lopez", apellido2: null, employeeId: "", weeklyHours: 40, dni: null, telefono: null, cargo: null, departamento: null, empresa: null, scheduleId: null, calendarId: null, fechaInicio: null, fechaFin: null, role: "employee", isSupervisor: false, supervisorId: null, isActive: true },
  intendedUid: null, generation: 0, version: 0, ownerToken: null, leaseExpiresAt: null,
  currentDispatchId: null, authAttempted: false, authAttempt: null, createdAt: 0, updatedAt: 0,
});

const request = (current: OperationState): ReducerRequest => ({
  expected: { fingerprint: current.fingerprint, status: current.status, phase: current.phase, generation: current.generation, version: current.version, ownerToken: current.ownerToken, currentDispatchId: current.currentDispatchId, leaseExpiresAt: current.leaseExpiresAt },
  observedAt: 1,
  event: createEvent("acquire", { ownerToken: "b".repeat(64), leaseExpiresAt: 2 }),
});

test("MemoryStore atomically persists an exact-CAS transition", async () => {
  const store = new MemoryStore();
  await store.transaction((transaction) => transaction.write("operation", state()));
  const result = await store.transaction((transaction) => transaction.compareAndSwap("operation", request(state()), reduce));
  assert.equal(result.type, "success");
  const persisted = await store.transaction((transaction) => transaction.read("operation"));
  assert.deepEqual(persisted?.status, "active");
  assert.deepEqual(persisted?.version, 1);
});
