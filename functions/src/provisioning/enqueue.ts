/** Canonical immutable identity supplied by the outbox trigger or repair handler. */
export interface EnqueueDispatch {
  readonly dispatchId: string;
  readonly taskId: string;
  readonly operationId: string;
  readonly fingerprint: string;
  readonly boundary: string;
  readonly generation: number;
  readonly sourceVersion: number;
  readonly ownerSeed: string;
}

/** Injectable queue boundary. Production SDK adapters belong to a later slice. */
export interface EnqueueAdapter {
  enqueue(dispatch: EnqueueDispatch): Promise<void>;
}

export interface StrictEnqueueFake extends EnqueueAdapter {
  readonly enqueueCount: number;
  readonly enqueued: readonly EnqueueDispatch[];
}

/** Immutable deployment inputs supplied by the Functions composition root. */
export interface CloudTasksQueueEnvironment {
  readonly projectId: string;
  readonly location: string;
  readonly queue: string;
  readonly targetUrl: string;
  readonly oidcServiceAccountEmail: string;
}

/** Minimal Cloud Tasks create request used at the external transport boundary. */
export interface CloudTasksCreateTaskRequest {
  readonly parent: string;
  readonly task: {
    readonly name: string;
    readonly httpRequest: {
      readonly httpMethod: "POST";
      readonly url: string;
      readonly headers: Readonly<Record<"Content-Type", "application/json">>;
      readonly body: string;
      readonly oidcToken: {
        readonly serviceAccountEmail: string;
      };
    };
  };
}

/** Injectable Cloud Tasks SDK boundary; construction lives outside the domain port. */
export interface CloudTasksTransport {
  createTask(request: CloudTasksCreateTaskRequest): Promise<void>;
}

const PROJECT_ID = /^[a-z][a-z0-9-]{4,61}[a-z0-9]$/;
const LOCATION = /^[a-z]+(?:-[a-z0-9]+)*\d$/;
const QUEUE = /^[a-z](?:[-a-z0-9]{0,61}[a-z0-9])?$/;
const DISPATCH_ID = /^[a-f0-9]{64}$/;
const SERVICE_ACCOUNT = /^[^\s@]+@[^\s@]+\.iam\.gserviceaccount\.com$/;

function isValidTargetUrl(value: string): boolean {
  try {
    const target = new URL(value);
    return target.protocol === "https:" && target.username === "" && target.password === "";
  } catch {
    return false;
  }
}

function isValidEnvironment(environment: CloudTasksQueueEnvironment): boolean {
  return PROJECT_ID.test(environment.projectId)
    && LOCATION.test(environment.location)
    && QUEUE.test(environment.queue)
    && isValidTargetUrl(environment.targetUrl)
    && SERVICE_ACCOUNT.test(environment.oidcServiceAccountEmail);
}

function createTaskRequest(
  environment: CloudTasksQueueEnvironment,
  dispatch: EnqueueDispatch,
): CloudTasksCreateTaskRequest {
  if (!DISPATCH_ID.test(dispatch.dispatchId) || dispatch.taskId !== dispatch.dispatchId) {
    throw new Error("invalid dispatch identity");
  }

  const parent = `projects/${environment.projectId}/locations/${environment.location}/queues/${environment.queue}`;
  return {
    parent,
    task: {
      name: `${parent}/tasks/${dispatch.dispatchId}`,
      httpRequest: {
        httpMethod: "POST",
        url: environment.targetUrl,
        headers: { "Content-Type": "application/json" },
        body: Buffer.from(JSON.stringify({ data: { dispatchId: dispatch.dispatchId } }), "utf8").toString("base64"),
        oidcToken: { serviceAccountEmail: environment.oidcServiceAccountEmail },
      },
    },
  };
}

/**
 * Creates the production queue adapter using a caller-injected Cloud Tasks transport.
 * It derives every task identity from the canonical dispatch and never reads globals.
 */
export function createCloudTasksEnqueueAdapter(
  environment: CloudTasksQueueEnvironment,
  transport: CloudTasksTransport,
): EnqueueAdapter {
  if (!isValidEnvironment(environment)) throw new Error("invalid queue environment");
  const fixedEnvironment = Object.freeze({ ...environment });

  return {
    async enqueue(dispatch: EnqueueDispatch): Promise<void> {
      await transport.createTask(createTaskRequest(fixedEnvironment, dispatch));
    },
  };
}

function snapshot(dispatch: EnqueueDispatch): EnqueueDispatch {
  return Object.freeze({ ...dispatch });
}

function matches(left: EnqueueDispatch, right: EnqueueDispatch): boolean {
  return left.dispatchId === right.dispatchId
    && left.taskId === right.taskId
    && left.operationId === right.operationId
    && left.fingerprint === right.fingerprint
    && left.boundary === right.boundary
    && left.generation === right.generation
    && left.sourceVersion === right.sourceVersion
    && left.ownerSeed === right.ownerSeed;
}

class StrictFake implements StrictEnqueueFake {
  readonly #byDispatchId = new Map<string, EnqueueDispatch>();
  #enqueued: readonly EnqueueDispatch[] = Object.freeze([]);

  get enqueueCount(): number {
    return this.#enqueued.length;
  }

  get enqueued(): readonly EnqueueDispatch[] {
    return this.#enqueued;
  }

  async enqueue(dispatch: EnqueueDispatch): Promise<void> {
    const existing = this.#byDispatchId.get(dispatch.dispatchId);
    if (existing !== undefined) {
      if (!matches(existing, dispatch)) throw new Error("incompatible dispatch identity");
      return;
    }

    const recorded = snapshot(dispatch);
    this.#byDispatchId.set(recorded.dispatchId, recorded);
    this.#enqueued = Object.freeze([...this.#enqueued, recorded]);
  }
}

/** Creates a strict in-memory adapter for deterministic outbox contract tests. */
export function createStrictEnqueueFake(): StrictEnqueueFake {
  return new StrictFake();
}
