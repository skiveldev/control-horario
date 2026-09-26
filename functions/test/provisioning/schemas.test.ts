import { strict as assert } from "node:assert";
import { isValidDispatch, isValidDispatchUpdate, isValidOperation } from "../../src/provisioning/schemas.ts";

const operation = () => ({
  schemaVersion: 1,
  operationId: "00000000-0000-4000-a000-000000000101",
  fingerprint: "a".repeat(64),
  normalizedPayload: {
    email: "employee@example.com", nombre: "Employee", apellido1: "Example", apellido2: null,
    employeeId: "", weeklyHours: 40, dni: null, telefono: null, cargo: null, departamento: null,
    empresa: null, scheduleId: null, calendarId: null, fechaInicio: null, fechaFin: null,
    role: "employee", isSupervisor: false, supervisorId: null, isActive: true,
  },
  intendedUid: "uid-001",
  submittedByDigest: "b".repeat(64),
  status: "pending", phase: "dispatch_pending", generation: 0, version: 0,
  ownerToken: null, leaseExpiresAt: null, currentDispatchId: null,
  authAttempted: false, authAttempt: null, createdAt: 1, updatedAt: 1,
});

assert.equal(isValidOperation(operation()), true, "canonical operation must validate");
for (const invalid of [
  { ...operation(), schemaVersion: 2 },
  { ...operation(), operationId: "not-a-uuid" },
  { ...operation(), fingerprint: "A".repeat(64) },
  { ...operation(), submittedByDigest: "raw-user-id" },
  { ...operation(), status: "pending", phase: "terminal" },
  { ...operation(), intendedUid: null },
  { ...operation(), ownerToken: "c".repeat(64) },
  { ...operation(), normalizedPayload: { ...operation().normalizedPayload, role: "admin" } },
  { ...operation(), normalizedPayload: { ...operation().normalizedPayload, email: "Employee@Example.com" } },
  { ...operation(), createdAt: 1.5 },
  { ...operation(), extra: true },
]) assert.equal(isValidOperation(invalid), false, "invalid operation combination must reject");

assert.equal(isValidOperation({ ...operation(), normalizedPayload: { ...operation().normalizedPayload, email: " employee@example.com " } }), false, "email must already be trimmed");
for (const field of ["apellido2", "dni", "telefono", "cargo", "departamento", "empresa", "scheduleId", "calendarId", "fechaInicio", "fechaFin", "supervisorId"] as const) {
  assert.equal(isValidOperation({ ...operation(), normalizedPayload: { ...operation().normalizedPayload, [field]: " " } }), false, `${field} must reject blank optional strings`);
}
for (const date of ["2026-02-29", "2026-13-01", "2026-01-32"]) {
  assert.equal(isValidOperation({ ...operation(), normalizedPayload: { ...operation().normalizedPayload, fechaInicio: date } }), false, `${date} must reject malformed dates`);
}
assert.equal(isValidOperation(new Proxy({}, { getPrototypeOf() { throw new Error("hostile operation"); } })), false, "hostile operations must fail closed");

console.log("OK: operation schema 28 assertions");

const dispatch = () => ({
  schemaVersion: 1, dispatchId: "d".repeat(64), taskId: "d".repeat(64),
  operationId: "00000000-0000-4000-a000-000000000101", fingerprint: "a".repeat(64),
  boundary: "acquire", generation: 0, sourceVersion: 0, ownerSeed: "e".repeat(64),
  enqueued: false, enqueuedAt: null, enqueueSource: null, enqueueEventId: null,
  workerAck: null, workerAckAt: null, createdAt: 1,
});
assert.equal(isValidDispatch(dispatch()), true, "canonical initial dispatch must validate");
for (const invalid of [
  { ...dispatch(), taskId: "f".repeat(64) },
  { ...dispatch(), boundary: "terminalize" },
  { ...dispatch(), enqueued: true },
  { ...dispatch(), workerAck: "processed" },
  { ...dispatch(), sourceVersion: -1 },
]) assert.equal(isValidDispatch(invalid), false, "invalid dispatch shape must reject");
const enqueued = { ...dispatch(), enqueued: true, enqueuedAt: 2, enqueueSource: "trigger", enqueueEventId: "f".repeat(64) };
assert.equal(isValidDispatchUpdate(dispatch(), enqueued), true, "enqueue acknowledgement is the only permitted non-identity update");
assert.equal(isValidDispatchUpdate(enqueued, { ...enqueued, fingerprint: "b".repeat(64) }), false, "dispatch identity must be immutable");
assert.equal(isValidDispatchUpdate(enqueued, { ...enqueued, enqueued: false, enqueuedAt: null, enqueueSource: null, enqueueEventId: null }), false, "acknowledgement cannot regress");
assert.equal(isValidDispatch(new Proxy({}, { getPrototypeOf() { throw new Error("hostile dispatch"); } })), false, "hostile dispatches must fail closed");
assert.equal(isValidDispatchUpdate(enqueued, { ...enqueued, enqueuedAt: 3 }), false, "enqueue provenance must be immutable after acknowledgement");
const workerAcknowledged = { ...enqueued, workerAck: "processed", workerAckAt: 3 };
assert.equal(isValidDispatchUpdate(enqueued, workerAcknowledged), true, "worker acknowledgement may be recorded once");
assert.equal(isValidDispatchUpdate(workerAcknowledged, { ...workerAcknowledged, workerAckAt: 4 }), false, "worker acknowledgement timestamp must be immutable");
console.log("OK: dispatch schema 13 assertions");
