const DIGEST = /^[a-f0-9]{64}$/;
const UUID_V4 = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
const PAYLOAD_KEYS = ["email", "nombre", "apellido1", "apellido2", "employeeId", "weeklyHours", "dni", "telefono", "cargo", "departamento", "empresa", "scheduleId", "calendarId", "fechaInicio", "fechaFin", "role", "isSupervisor", "supervisorId", "isActive"];
const OPERATION_KEYS = ["schemaVersion", "operationId", "fingerprint", "normalizedPayload", "intendedUid", "submittedByDigest", "status", "phase", "generation", "version", "ownerToken", "leaseExpiresAt", "currentDispatchId", "authAttempted", "authAttempt", "createdAt", "updatedAt"];
const DISPATCH_KEYS = ["schemaVersion", "dispatchId", "taskId", "operationId", "fingerprint", "boundary", "generation", "sourceVersion", "ownerSeed", "enqueued", "enqueuedAt", "enqueueSource", "enqueueEventId", "workerAck", "workerAckAt", "createdAt"];
const DISPATCH_IDENTITY_KEYS = ["schemaVersion", "dispatchId", "taskId", "operationId", "fingerprint", "boundary", "generation", "sourceVersion", "ownerSeed", "createdAt"];

type RecordValue = Record<string, unknown>;

function readExact(value: unknown, keys: readonly string[]): RecordValue | null {
  try {
    if (value === null || typeof value !== "object" || Array.isArray(value) || Object.getPrototypeOf(value) !== Object.prototype) return null;
    const ownKeys = Reflect.ownKeys(value);
    if (ownKeys.length !== keys.length || ownKeys.some((key) => typeof key !== "string" || !keys.includes(key))) return null;
    const descriptors = Object.getOwnPropertyDescriptors(value);
    for (const key of keys) if (!(key in descriptors) || !("value" in descriptors[key]!)) return null;
    return Object.fromEntries(keys.map((key) => [key, descriptors[key]!.value]));
  } catch { return null; }
}

const nonEmpty = (value: unknown): value is string => typeof value === "string" && value.length > 0;
const canonicalString = (value: unknown, allowEmpty = false): value is string => typeof value === "string" && (allowEmpty || value.length > 0) && value === value.trim() && value === value.normalize("NFC");
const nullableCanonicalString = (value: unknown): boolean => value === null || canonicalString(value);
const timestamp = (value: unknown): boolean => typeof value === "number" && Number.isInteger(value) && value >= 0;
const canonicalDate = (value: unknown): boolean => {
  if (value === null) return true;
  if (!canonicalString(value) || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const parsed = new Date(`${value}T00:00:00.000Z`);
  return !Number.isNaN(parsed.valueOf()) && parsed.toISOString().slice(0, 10) === value;
};

function isNormalizedPayload(value: unknown): boolean {
  const payload = readExact(value, PAYLOAD_KEYS);
  if (!payload || !canonicalString(payload.email) || payload.email !== payload.email.toLowerCase() || !canonicalString(payload.nombre) || !canonicalString(payload.apellido1)) return false;
  if (payload.role !== "employee" && payload.role !== "rrhh") return false;
  if (!canonicalString(payload.employeeId, true) || !Number.isInteger(payload.weeklyHours) || (payload.weeklyHours as number) < 1 || (payload.weeklyHours as number) > 168) return false;
  if (typeof payload.isSupervisor !== "boolean" || typeof payload.isActive !== "boolean") return false;
  return ["apellido2", "dni", "telefono", "cargo", "departamento", "empresa", "scheduleId", "calendarId", "supervisorId"].every((key) => nullableCanonicalString(payload[key]))
    && canonicalDate(payload.fechaInicio) && canonicalDate(payload.fechaFin);
}

/** Validates only a canonical, newly submitted pending operation document. */
export function isValidOperation(value: unknown): boolean {
  const operation = readExact(value, OPERATION_KEYS);
  return operation !== null
    && operation.schemaVersion === 1
    && typeof operation.operationId === "string" && UUID_V4.test(operation.operationId)
    && typeof operation.fingerprint === "string" && DIGEST.test(operation.fingerprint)
    && isNormalizedPayload(operation.normalizedPayload)
    && nonEmpty(operation.intendedUid)
    && typeof operation.submittedByDigest === "string" && DIGEST.test(operation.submittedByDigest)
    && operation.status === "pending" && operation.phase === "dispatch_pending"
    && operation.generation === 0 && operation.version === 0
    && operation.ownerToken === null && operation.leaseExpiresAt === null && operation.currentDispatchId === null
    && operation.authAttempted === false && operation.authAttempt === null
    && timestamp(operation.createdAt) && timestamp(operation.updatedAt);
}

/** Validates the immutable dispatch identity and its acknowledgement state. */
export function isValidDispatch(value: unknown): boolean {
  const dispatch = readExact(value, DISPATCH_KEYS);
  if (!dispatch || dispatch.schemaVersion !== 1 || typeof dispatch.dispatchId !== "string" || !DIGEST.test(dispatch.dispatchId)
    || dispatch.taskId !== dispatch.dispatchId || typeof dispatch.operationId !== "string" || !UUID_V4.test(dispatch.operationId)
    || typeof dispatch.fingerprint !== "string" || !DIGEST.test(dispatch.fingerprint) || typeof dispatch.ownerSeed !== "string" || !DIGEST.test(dispatch.ownerSeed)
    || !["acquire", "auth_preflight", "auth_create", "profile_commit"].includes(dispatch.boundary as string)
    || !Number.isInteger(dispatch.generation) || (dispatch.generation as number) < 0 || !Number.isInteger(dispatch.sourceVersion) || (dispatch.sourceVersion as number) < 0 || !timestamp(dispatch.createdAt)) return false;
  const enqueueEmpty = dispatch.enqueued === false && dispatch.enqueuedAt === null && dispatch.enqueueSource === null && dispatch.enqueueEventId === null;
  const enqueueAck = dispatch.enqueued === true && timestamp(dispatch.enqueuedAt) && ["trigger", "sweeper"].includes(dispatch.enqueueSource as string) && typeof dispatch.enqueueEventId === "string" && DIGEST.test(dispatch.enqueueEventId);
  const workerEmpty = dispatch.workerAck === null && dispatch.workerAckAt === null;
  const workerAck = ["processed", "stale", "terminalized"].includes(dispatch.workerAck as string) && timestamp(dispatch.workerAckAt);
  return (enqueueEmpty || enqueueAck) && (workerEmpty || workerAck);
}

/** Enforces immutable dispatch identity and monotonic enqueue/worker acknowledgements. */
export function isValidDispatchUpdate(previous: unknown, next: unknown): boolean {
  const before = readExact(previous, DISPATCH_KEYS);
  const after = readExact(next, DISPATCH_KEYS);
  if (!before || !after || !isValidDispatch(before) || !isValidDispatch(after)) return false;
  if (DISPATCH_IDENTITY_KEYS.some((key) => before[key] !== after[key])) return false;
  if (before.enqueued === true && after.enqueued !== true) return false;
  if (before.enqueued === true && (before.enqueuedAt !== after.enqueuedAt || before.enqueueSource !== after.enqueueSource || before.enqueueEventId !== after.enqueueEventId)) return false;
  if (before.workerAck !== null && (after.workerAck !== before.workerAck || after.workerAckAt !== before.workerAckAt)) return false;
  return true;
}
