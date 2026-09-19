import { strict as assert } from "node:assert";
import { readFile } from "node:fs/promises";
import { HttpsError } from "firebase-functions/v2/https";
import { deleteApp, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { submitProvisioning } from "../../src/index.ts";
import { FirestoreInitialSubmissionStore } from "../../src/provisioning/boundaries.ts";
import { deriveDispatchId, deriveOwnerToken } from "../../src/provisioning/ids.ts";
import { fingerprintPayload, normalizePayload } from "../../src/provisioning/normalize.ts";
import { isValidDispatch, isValidOperation } from "../../src/provisioning/schemas.ts";
import {
  persistInitialSubmission,
  submitProvisioningRequest,
  validateSubmission,
  type InitialSubmissionInput,
  type InitialSubmissionStore,
  type SubmissionComposition,
} from "../../src/provisioning/submit.ts";

const validPayload = {
  operationId: "00000000-0000-4000-a000-000000000001",
  email: " Admin@Example.com ",
  nombre: " Admin ",
  apellido1: " User ",
  role: "employee",
};

function validate(data: unknown): void {
  validateSubmission(data, normalizePayload);
}

function expectInvalidArgument(data: unknown, message: string): void {
  assert.throws(
    () => validate(data),
    (error: unknown) => error instanceof HttpsError && error.code === "invalid-argument",
    message,
  );
}

const normalized = validateSubmission(validPayload, normalizePayload);
assert.deepEqual(
  normalized,
  {
    email: "admin@example.com",
    nombre: "Admin",
    apellido1: "User",
    apellido2: null,
    employeeId: "",
    weeklyHours: 40,
    dni: null,
    telefono: null,
    cargo: null,
    departamento: null,
    empresa: null,
    scheduleId: null,
    calendarId: null,
    fechaInicio: null,
    fechaFin: null,
    role: "employee",
    isSupervisor: false,
    supervisorId: null,
    isActive: true,
    displayName: "Admin User",
  },
  "valid input must be canonicalized before later submission stages",
);

expectInvalidArgument(
  { ...validPayload, role: "admin" },
  "roles outside employee and rrhh must be rejected by the callable",
);
expectInvalidArgument(
  { ...validPayload, weeklyHours: Number.NaN },
  "non-finite schema values must be rejected by the callable",
);

for (const requiredField of ["operationId", "email", "nombre", "apellido1"]) {
  const missing = { ...validPayload } as Record<string, unknown>;
  delete missing[requiredField];
  expectInvalidArgument(
    missing,
    `missing ${requiredField} must be rejected by the callable`,
  );
}

const submission = {
  operationId: validPayload.operationId,
  fingerprint: "a".repeat(64),
  normalizedPayload: normalized,
  intendedUid: "server-generated-uid",
  submittedByDigest: "b".repeat(64),
  initialDispatchId: deriveDispatchId(validPayload.operationId, "acquire", 0, 0),
  initialOwnerSeed: deriveOwnerToken(deriveDispatchId(validPayload.operationId, "acquire", 0, 0), 0),
};

function transactionStore(failDispatch = false): {
  readonly store: InitialSubmissionStore;
  readonly writes: Array<{ readonly kind: string; readonly value: Record<string, unknown> }>;
} {
  const writes: Array<{ kind: string; value: Record<string, unknown> }> = [];
  return {
    writes,
    store: {
      async transaction(work) {
        const pending: Array<{ kind: string; value: Record<string, unknown> }> = [];
        const result = await work({
          now: () => 123,
          readOperation: async () => null,
          createOperation: (operation) => {
            pending.push({ kind: "operation", value: operation });
          },
          createDispatch: (dispatch) => {
            if (failDispatch) throw new Error("dispatch write failed");
            pending.push({ kind: "dispatch", value: dispatch });
          },
        });
        writes.push(...pending);
        return result;
      },
    },
  };
}

function testComposition(
  overrides: Partial<SubmissionComposition> = {},
): SubmissionComposition {
  return {
    normalize: normalizePayload,
    fingerprint: fingerprintPayload,
    authorize: async () => {},
    persist: async () => ({ operationId: validPayload.operationId, status: "pending" }),
    createIntendedUid: () => "server-generated-uid",
    ...overrides,
  };
}

function replayStore(): {
  readonly store: InitialSubmissionStore;
  readonly operations: Map<string, Record<string, unknown>>;
  readonly dispatches: Map<string, Record<string, unknown>>;
  readonly writes: { operation: number; dispatch: number; audit: number; auth: number; profile: number };
} {
  const operations = new Map<string, Record<string, unknown>>();
  const dispatches = new Map<string, Record<string, unknown>>();
  const writes = { operation: 0, dispatch: 0, audit: 0, auth: 0, profile: 0 };
  const store: InitialSubmissionStore = {
    async transaction(work) {
      const pendingOperations = new Map<string, Record<string, unknown>>();
      const pendingDispatches = new Map<string, Record<string, unknown>>();
      const result = await work({
        now: () => 123,
        readOperation: async (operationId: string) => operations.get(operationId) ?? null,
        createOperation: (operation) => {
          if (operations.has(operation.operationId as string)) throw new Error("duplicate operation write");
          pendingOperations.set(operation.operationId as string, operation);
        },
        createDispatch: (dispatch) => {
          if (dispatches.has(dispatch.dispatchId as string)) throw new Error("duplicate dispatch write");
          pendingDispatches.set(dispatch.dispatchId as string, dispatch);
        },
      });
      for (const [operationId, operation] of pendingOperations) {
        operations.set(operationId, operation);
        writes.operation += 1;
      }
      for (const [dispatchId, dispatch] of pendingDispatches) {
        dispatches.set(dispatchId, dispatch);
        writes.dispatch += 1;
      }
      return result;
    },
  };
  return { store, operations, dispatches, writes };
}

{
  const { store, writes } = transactionStore();
  const result = await persistInitialSubmission(submission, store);
  const operation = writes.find((write) => write.kind === "operation")?.value;
  const dispatch = writes.find((write) => write.kind === "dispatch")?.value;

  assert.deepEqual(result, { operationId: submission.operationId, status: "pending" }, "submission returns only the pending operation reference");
  assert.deepEqual(writes.map((write) => write.kind), ["operation", "dispatch"], "submission writes only the operation and initial dispatch");
  assert.equal(isValidOperation(operation), true, "submission persists one canonical pending operation");
  assert.equal(isValidDispatch(dispatch), true, "submission persists one canonical initial dispatch");
  assert.equal(dispatch?.dispatchId, submission.initialDispatchId, "initial dispatch identity is deterministic");
  assert.equal(dispatch?.ownerSeed, submission.initialOwnerSeed, "initial dispatch owns a deterministic opaque seed");
}

{
  const { store, writes } = transactionStore(true);
  await assert.rejects(
    () => persistInitialSubmission(submission, store),
    /dispatch write failed/,
    "a dispatch persistence failure must fail the submission transaction",
  );
  assert.deepEqual(writes, [], "a failed dispatch write must roll back the operation instead of leaving a partial submission");
}

{
  const { store, operations, dispatches, writes } = replayStore();
  await persistInitialSubmission(submission, store);
  const operation = operations.get(submission.operationId)!;
  operation.status = "active";
  const result = await persistInitialSubmission(submission, store);

  assert.deepEqual(result, { operationId: submission.operationId, status: "active" }, "matching identity replays the current safe operation status");
  assert.equal(operations.size, 1, "matching identity does not create a second operation");
  assert.equal(dispatches.size, 1, "matching identity does not create a second initial dispatch");
  assert.deepEqual(writes, { operation: 1, dispatch: 1, audit: 0, auth: 0, profile: 0 }, "matching identity causes no additional persistence or external effects");
}

{
  const { store, operations, dispatches, writes } = replayStore();
  await persistInitialSubmission(submission, store);
  await assert.rejects(
    () => persistInitialSubmission({
      ...submission,
      fingerprint: "c".repeat(64),
      normalizedPayload: { ...submission.normalizedPayload, nombre: "Different" },
    }, store),
    (error: unknown) => error instanceof HttpsError && error.code === "already-exists",
    "a reused operation ID with a different payload fingerprint fails closed",
  );

  assert.equal(operations.get(submission.operationId)?.fingerprint, submission.fingerprint, "fingerprint conflict preserves the stored operation identity");
  assert.equal(dispatches.size, 1, "fingerprint conflict does not create a dispatch");
  assert.deepEqual(writes, { operation: 1, dispatch: 1, audit: 0, auth: 0, profile: 0 }, "fingerprint conflict causes no additional writes or external effects");
}

{
  let authorizations = 0;
  let persistences = 0;
  await assert.rejects(
    () => submitProvisioningRequest(
      { ...validPayload, role: "admin" },
      "admin-uid",
      testComposition({
        authorize: async () => { authorizations += 1; },
        persist: async () => {
          persistences += 1;
          return { operationId: validPayload.operationId, status: "pending" };
        },
      }),
    ),
    (error: unknown) => error instanceof HttpsError && error.code === "invalid-argument",
    "invalid input fails before authorization or persistence",
  );
  assert.deepEqual({ authorizations, persistences }, { authorizations: 0, persistences: 0 });
}

{
  let persistences = 0;
  await assert.rejects(
    () => submitProvisioningRequest(
      validPayload,
      "admin-uid",
      testComposition({
        authorize: async () => { throw new HttpsError("permission-denied", "denied"); },
        persist: async () => {
          persistences += 1;
          return { operationId: validPayload.operationId, status: "pending" };
        },
      }),
    ),
    (error: unknown) => error instanceof HttpsError && error.code === "permission-denied",
    "authorization denial fails before persistence",
  );
  assert.equal(persistences, 0, "denial must not reach persistence");
}

{
  const { store, operations, writes } = replayStore();
  operations.set(validPayload.operationId, {
    fingerprint: fingerprintPayload(validPayload),
    status: "not-a-status",
  });
  await assert.rejects(
    () => submitProvisioningRequest(validPayload, "admin-uid", testComposition({
      persist: async (input) => persistInitialSubmission(input, store),
    })),
    (error: unknown) => error instanceof HttpsError && error.code === "failed-precondition",
    "malformed persisted status fails closed through submission composition",
  );
  assert.deepEqual(writes, { operation: 0, dispatch: 0, audit: 0, auth: 0, profile: 0 });
}

if (process.env.FIRESTORE_EMULATOR_HOST) {
  const app = initializeApp({ projectId: "demo-no-project" }, "submit-test");
  const db = getFirestore(app);
  const store = new FirestoreInitialSubmissionStore(db);
  const realSubmission = (operationId: string): InitialSubmissionInput => {
    const initialDispatchId = deriveDispatchId(operationId, "acquire", 0, 0);
    return {
      ...submission,
      operationId,
      initialDispatchId,
      initialOwnerSeed: deriveOwnerToken(initialDispatchId, 0),
    };
  };
  const atomic = realSubmission("00000000-0000-4000-a000-000000000011");
  const conflict = realSubmission("00000000-0000-4000-a000-000000000012");
  const concurrent = realSubmission("00000000-0000-4000-a000-000000000013");
  const operationRef = (operationId: string) => db.collection("provisioningOperations").doc(operationId);
  const dispatchRef = (dispatchId: string) => db.collection("provisioningDispatch").doc(dispatchId);

  try {
    await persistInitialSubmission(atomic, store);
    const [atomicOperation, atomicDispatch] = await Promise.all([
      operationRef(atomic.operationId).get(),
      dispatchRef(atomic.initialDispatchId).get(),
    ]);
    assert.equal(isValidOperation(atomicOperation.data()), true, "Firestore commits the pending operation");
    assert.equal(isValidDispatch(atomicDispatch.data()), true, "Firestore commits its deterministic acquire dispatch");
    assert.equal(atomicDispatch.data()?.operationId, atomic.operationId);

    await dispatchRef(conflict.initialDispatchId).create({ preserved: true });
    await assert.rejects(
      () => persistInitialSubmission(conflict, store),
      (error: unknown) => (error as { code?: unknown }).code === 6,
      "a real dispatch create conflict rejects the transaction",
    );
    assert.equal((await operationRef(conflict.operationId).get()).exists, false, "conflict rolls back the operation create");
    assert.deepEqual((await dispatchRef(conflict.initialDispatchId).get()).data(), { preserved: true });

    const results = await Promise.all(Array.from({ length: 3 }, () => persistInitialSubmission(concurrent, store)));
    assert.deepEqual(results, Array.from({ length: 3 }, () => ({ operationId: concurrent.operationId, status: "pending" })));
    const [concurrentOperation, concurrentDispatch] = await Promise.all([
      operationRef(concurrent.operationId).get(),
      dispatchRef(concurrent.initialDispatchId).get(),
    ]);
    assert.equal(isValidOperation(concurrentOperation.data()), true, "concurrent submissions converge on one valid operation");
    assert.equal(isValidDispatch(concurrentDispatch.data()), true, "concurrent submissions converge on one valid dispatch");
  } finally {
    await Promise.all([
      operationRef(atomic.operationId).delete(),
      dispatchRef(atomic.initialDispatchId).delete(),
      operationRef(conflict.operationId).delete(),
      dispatchRef(conflict.initialDispatchId).delete(),
      operationRef(concurrent.operationId).delete(),
      dispatchRef(concurrent.initialDispatchId).delete(),
    ]);
    await deleteApp(app);
  }
}

{
  const source = await readFile(new URL("../../src/index.ts", import.meta.url), "utf8");
  assert.equal(typeof submitProvisioning, "function", "submission endpoint must be exported");
  assert.equal(submitProvisioning.__endpoint.callableTrigger !== undefined, true, "submission endpoint must remain a v2 callable");
  assert.match(source, /onCall\(\{\s*enforceAppCheck:\s*true\s*\}/, "callable must enforce App Check before its handler");

  const { store, operations, dispatches, writes } = replayStore();
  const authorizations: Array<{ readonly callerUid: string | null; readonly correlationId: string }> = [];
  const dependencies = {
    normalize: normalizePayload,
    fingerprint: fingerprintPayload,
    authorize: async (callerUid: string | null, correlationId: string) => {
      authorizations.push({ callerUid, correlationId });
    },
    persist: async (input: InitialSubmissionInput) => persistInitialSubmission(input, store),
    createIntendedUid: () => "server-generated-uid",
  };

  const first = await submitProvisioningRequest(validPayload, "admin-uid", dependencies);
  assert.deepEqual(first, { operationId: validPayload.operationId, status: "pending" }, "the callable returns only the canonical pending response");
  assert.equal(authorizations.length, 1, "the callable authorizes before persistence");
  assert.equal(authorizations[0]?.callerUid, "admin-uid", "the callable forwards the authenticated caller identity only to authorization");
  assert.equal(dispatches.get(submission.initialDispatchId)?.dispatchId, submission.initialDispatchId, "composition persists the deterministic acquire dispatch");
  assert.deepEqual(writes, { operation: 1, dispatch: 1, audit: 0, auth: 0, profile: 0 }, "submission composition has no Auth, audit, profile, or worker effect");

  operations.get(validPayload.operationId)!.status = "active";
  const replay = await submitProvisioningRequest(validPayload, "admin-uid", dependencies);
  assert.deepEqual(replay, { operationId: validPayload.operationId, status: "active" }, "same identity replays only the safe persisted status");
  await assert.rejects(
    () => submitProvisioningRequest({ ...validPayload, nombre: "Different" }, "admin-uid", dependencies),
    (error: unknown) => error instanceof HttpsError && error.code === "already-exists",
    "a fingerprint conflict is stable and leaves the original operation intact",
  );
  assert.equal(operations.size, 1, "conflicts cannot create another operation");
  assert.equal(dispatches.size, 1, "conflicts cannot create another dispatch");
}

console.log("OK: submission validation, negative composition, atomic persistence, and emulator-gated Firestore conformance");
