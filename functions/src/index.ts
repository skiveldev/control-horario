import { createHash, randomUUID } from "node:crypto";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { getApp, getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onTaskDispatched as onTaskDispatchedFunction } from "firebase-functions/v2/tasks";
import {
  createCloudTasksEnqueueAdapter,
  type CloudTasksCreateTaskRequest,
  type CloudTasksQueueEnvironment,
  type EnqueueAdapter,
} from "./provisioning/enqueue.ts";
import {
  handleCreatedDispatch,
  type DispatchAcknowledgementStore,
  type DispatchValidation,
} from "./provisioning/outbox.ts";
import {
  FirestoreOutboxRepairStore,
  repairStaleDispatches,
  type DispatchRepairStore,
} from "./provisioning/outbox_repair.ts";
import { isValidDispatch, isValidDispatchUpdate } from "./provisioning/schemas.ts";
import {
  FirebaseAuthReader,
  FirestoreAuthorizationPort,
  FirestoreInitialSubmissionStore,
  FirestoreWorkerStore,
  type AuthCreator,
  type AuthReader,
  type WorkerStore,
} from "./provisioning/boundaries.ts";
import { AuthorizationError, authorizeAdmin } from "./provisioning/authz.ts";
import {
  CompletedIntegrityError,
  PasswordResetLinkError,
  StatusAuthorizationError,
  StatusProjectionError,
  getAuthorizedStatusWithPasswordResetLink,
  type CompletedIntegrityPort,
  type PasswordResetLinkGenerator,
  type StatusAuthorizationPort,
} from "./provisioning/status.ts";
import { deduplicateAudit, type AuditEvent } from "./provisioning/audit.ts";
import { fingerprintPayload, normalizePayload } from "./provisioning/normalize.ts";
import { persistInitialSubmission, submitProvisioningRequest } from "./provisioning/submit.ts";
import {
  completeProfileCommit,
  createAuthUser,
  persistAuthIntent,
  preflightAuth,
  processProvisioningTask,
} from "./provisioning/worker.ts";

if (getApps().length === 0) initializeApp();

/** App Check-protected submission boundary; it persists only the pending operation and initial dispatch. */
export const submitProvisioning = onCall({ enforceAppCheck: true }, async (request) => {
  const db = getFirestore();
  try {
    return await submitProvisioningRequest(request.data, request.auth?.uid ?? null, {
      normalize: normalizePayload,
      fingerprint: fingerprintPayload,
      authorize: (callerUid, correlationId) => authorizeAdmin(
        { callerUid, correlationId },
        new FirestoreAuthorizationPort(db),
      ),
      persist: (input) => persistInitialSubmission(input, new FirestoreInitialSubmissionStore(db)),
      createIntendedUid: randomUUID,
    });
  } catch (error) {
    if (error instanceof AuthorizationError) {
      throw new HttpsError(error.code, "Provisioning submission is not authorized.");
    }
    throw error;
  }
});

class FirestoreStatusAuthorizationPort implements StatusAuthorizationPort {
  private readonly db = getFirestore();

  async readUser(uid: string): Promise<{ readonly role: string; readonly isActive: boolean } | null> {
    const snapshot = await this.db.collection("users").doc(uid).get();
    if (!snapshot.exists) return null;
    const user = snapshot.data() as Record<string, unknown>;
    return { role: typeof user.role === "string" ? user.role : "", isActive: user.isActive === true };
  }

  async readOperation(operationId: string): Promise<{ readonly fingerprint: string } | null> {
    const snapshot = await this.db.collection("provisioningOperations").doc(operationId).get();
    return snapshot.exists ? snapshot.data() as { readonly fingerprint: string } : null;
  }
}

class FirestoreCompletedIntegrityPort implements CompletedIntegrityPort, PasswordResetLinkGenerator {
  private readonly db = getFirestore();
  private readonly auth = new FirebaseAuthReader(getAuth());

  async readAuthByUid(uid: string): Promise<{ readonly uid: string; readonly email: string } | null> {
    const user = await this.auth.readByUid(uid);
    if (user === null || user.email === null) return null;
    return { uid: user.uid, email: user.email };
  }

  async readAuthByEmail(email: string): Promise<{ readonly uid: string; readonly email: string } | null> {
    const user = await this.auth.readByEmail(email);
    if (user === null || user.email === null) return null;
    return { uid: user.uid, email: user.email };
  }

  async readProfile(uid: string): Promise<unknown | null> {
    const snapshot = await this.db.collection("users").doc(uid).get();
    return snapshot.exists ? snapshot.data() : null;
  }

  async recordCompletedIntegrityAudit(event: AuditEvent): Promise<void> {
    const reference = this.db.collection("provisioningAudit").doc(event.eventId);
    await this.db.runTransaction(async (transaction) => {
      const existing = await transaction.get(reference);
      if (existing.exists) {
        deduplicateAudit(existing.data() as AuditEvent, event);
        return;
      }
      transaction.create(reference, event);
    });
  }

  generatePasswordResetLink(email: string): Promise<string> {
    return getAuth().generatePasswordResetLink(email);
  }
}

/** App Check-protected status observation with completed integrity and immediate reset-link issuance. */
export const getProvisioningStatus = onCall({ enforceAppCheck: true }, async (request) => {
  const data = request.data as { readonly operationId?: unknown; readonly fingerprint?: unknown };
  if (typeof data?.operationId !== "string" || (data.fingerprint !== undefined && typeof data.fingerprint !== "string")) {
    throw new HttpsError("invalid-argument", "Status lookup requires a valid operation ID.");
  }
  try {
    const authorization = new FirestoreStatusAuthorizationPort();
    const integrity = new FirestoreCompletedIntegrityPort();
    return await getAuthorizedStatusWithPasswordResetLink({
      callerUid: request.auth?.uid ?? null,
      operationId: data.operationId,
      fingerprint: data.fingerprint,
    }, authorization, integrity, integrity);
  } catch (error) {
    if (error instanceof StatusAuthorizationError) {
      throw new HttpsError(error.code, "Provisioning status is not authorized.");
    }
    if (error instanceof StatusProjectionError) {
      throw new HttpsError("internal", "Provisioning status is unavailable.");
    }
    if (error instanceof CompletedIntegrityError) {
      throw new HttpsError("failed-precondition", "Provisioning completion integrity failed.");
    }
    if (error instanceof PasswordResetLinkError) {
      throw new HttpsError("unavailable", "Provisioning reset link is unavailable.");
    }
    throw error;
  }
});

export interface ProvisioningOutboxRuntimeDependencies {
  readonly enqueue: EnqueueAdapter;
  readonly store: DispatchAcknowledgementStore;
  readonly repairStore?: DispatchRepairStore;
  readonly validation: DispatchValidation;
  readonly log: (entry: unknown) => void;
  readonly now: () => number;
}

function digestEventId(domain: string, eventId: string): string {
  return createHash("sha256").update(`${domain}\0${eventId}`, "utf8").digest("hex");
}

/** Composes created-event and scheduled-repair delivery around the shared outbox seams. */
export function createProvisioningOutboxRuntime(dependencies: ProvisioningOutboxRuntimeDependencies) {
  return Object.freeze({
    async handleCreated(request: { readonly dispatch: unknown; readonly eventId: string }): Promise<void> {
      await handleCreatedDispatch({
        dispatch: request.dispatch,
        eventIdDigest: digestEventId("provision-created-event:v1", request.eventId),
        enqueue: dependencies.enqueue,
        store: dependencies.store,
        validation: dependencies.validation,
      });
    },
    async repair(runId: string): Promise<number> {
      if (dependencies.repairStore === undefined) throw new Error("repair store is not configured");
      return repairStaleDispatches({
        now: dependencies.now(),
        runIdDigest: digestEventId("provision-outbox-repair:v1", runId),
        enqueue: dependencies.enqueue,
        store: dependencies.repairStore,
        validation: dependencies.validation,
        log: dependencies.log,
      });
    },
  });
}

function queueEnvironment(): CloudTasksQueueEnvironment {
  return {
    projectId: process.env.GCLOUD_PROJECT ?? "",
    location: process.env.FUNCTION_REGION ?? "",
    queue: process.env.PROVISIONING_DISPATCH_QUEUE ?? "provisioning-dispatch",
    targetUrl: process.env.PROVISIONING_DISPATCH_TARGET_URL ?? "",
    oidcServiceAccountEmail: process.env.PROVISIONING_TASK_SERVICE_ACCOUNT ?? "",
  };
}

function cloudTasksTransport() {
  return {
    async createTask(request: CloudTasksCreateTaskRequest): Promise<void> {
      const credential = getApp().options.credential;
      if (credential === undefined) throw new Error("Cloud Tasks credential is unavailable");
      const token = await credential.getAccessToken();
      const response = await fetch(`https://cloudtasks.googleapis.com/v2/${request.parent}/tasks`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token.access_token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ task: request.task }),
      });
      if (response.ok) return;
      const error = Object.assign(new Error(`Cloud Tasks enqueue failed: ${response.status}`), {
        code: response.status === 409 ? "ALREADY_EXISTS" : response.status,
      });
      throw error;
    },
  };
}

function deployedOutboxRuntime() {
  const store = new FirestoreOutboxRepairStore(getFirestore());
  return createProvisioningOutboxRuntime({
    enqueue: createCloudTasksEnqueueAdapter(queueEnvironment(), cloudTasksTransport()),
    store,
    repairStore: store,
    validation: { isValidDispatch, isValidDispatchUpdate },
    log: (entry) => console.error(entry),
    now: Date.now,
  });
}

/** Retry-enabled deployment metadata for the durable provisioning-dispatch fast path. */
export const provisioningDispatchCreated = onDocumentCreated(
  { document: "provisioningDispatch/{dispatchId}", retry: true },
  async (event) => {
    await deployedOutboxRuntime().handleCreated({ dispatch: event.data?.data(), eventId: event.id });
  },
);

/** Bounded scheduled repair metadata for durable unacknowledged outbox records. */
export const provisioningOutboxRepair = onSchedule(
  {
    schedule: "every 5 minutes",
    retryCount: 3,
    minBackoffSeconds: 30,
    maxBackoffSeconds: 300,
    maxDoublings: 2,
    maxInstances: 1,
    timeoutSeconds: 240,
  },
  async (event) => {
    await deployedOutboxRuntime().repair(event.scheduleTime);
  },
);

export interface ProvisioningWorkerRuntimeDependencies {
  readonly store: WorkerStore;
  readonly auth: AuthCreator & AuthReader;
}

/** Routes a canonical task ID only through accepted worker phase handlers. */
export function createProvisioningWorkerRuntime(dependencies: ProvisioningWorkerRuntimeDependencies) {
  return Object.freeze({
    async handleTask(request: { readonly dispatchId: string; readonly retryCount: unknown }): Promise<void> {
      const dispatch = await dependencies.store.transaction((transaction) => transaction.readDispatch(request.dispatchId));
      await processProvisioningTask(dependencies.store, request.dispatchId, request.retryCount);
      if (
        dispatch === null
        || dispatch.dispatchId !== request.dispatchId
        || typeof request.retryCount !== "number"
        || !Number.isInteger(request.retryCount)
        || request.retryCount < 0
        || request.retryCount >= 8
      ) return;
      if (dispatch.boundary === "auth_preflight") {
        await preflightAuth(dependencies.store, dependencies.auth, request.dispatchId);
        await persistAuthIntent(dependencies.store, request.dispatchId);
      } else if (dispatch.boundary === "auth_create") {
        await createAuthUser(dependencies.store, dependencies.auth, request.dispatchId);
      } else if (dispatch.boundary === "profile_commit") {
        await completeProfileCommit(dependencies.store, dependencies.auth, request.dispatchId);
      }
    },
  });
}

function deployedWorkerRuntime() {
  return createProvisioningWorkerRuntime({
    store: new FirestoreWorkerStore(getFirestore()),
    auth: new FirebaseAuthReader(getAuth()),
  });
}

/** Cloud Tasks worker entry point; the transaction owns initial-delivery admission. */
export const onTaskDispatched = onTaskDispatchedFunction<{ dispatchId: string }>(async (request) => {
  await deployedWorkerRuntime().handleTask({
    dispatchId: request.data.dispatchId,
    retryCount: (request as unknown as { readonly retryCount?: unknown }).retryCount,
  });
});
