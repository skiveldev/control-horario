# Design: Durable Trusted Admin Provisioning and Portfolio Preparation

## Outcome and Scope

The trusted provisioning root is a **transactional Firestore outbox plus Cloud Tasks durable saga**. `submitProvisioning` accepts work but performs no Auth or profile side effect; a created-only outbox trigger is the enqueue fast path; a scheduled stale-outbox sweeper repairs exhausted/missed Eventarc delivery; `onTaskDispatched` advances at most one external-effect boundary; and `getProvisioningStatus` observes immutable terminal state and issues a fresh reset link only after completed-resource integrity checks. The Flutter client observes progress but never drives it.

This planning revision replaces the stale callable-owned saga and compensation design. It retains valid decisions: canonical `(operationId,fingerprint)` identity, server-generated `intendedUid`, `employee|rrhh` roles without custom claims, full transactional CAS leases, durable PII-safe audit, atomic profile/completion/success, Riverpod-only client state, WU4a's existing Functions scaffold, and the unrelated sanitization/signing/docs boundaries. First-slice code performs **no Auth deletion**. Deployment, publication, history rewrite, and runtime execution remain out of scope.

## Architecture at a Glance

```text
Flutter admin
  -> submitProvisioning [App Check -> auth -> admin -> schema]
       -> Firestore transaction(operation + initial dispatch)
  -> poll getProvisioningStatus with bounded backoff/cancellation

provisioningDispatch/{dispatchId} created
  +-> retry-enabled onDocumentCreated fast path ---------+
  |                                                       |
  +-> scheduled stale enqueued=false repair scan --------+-> same enqueue adapter
                                                           -> Cloud Task(taskId = dispatchId)
                                                           -> guarded enqueued=true acknowledgement

Cloud Task
  -> onTaskDispatched
       -> transaction: acquire/take over lease and persist intent
       -> at most one external effect
       -> transaction: state + audit + next dispatch + current worker ack
```

`onDocumentCreated` is deliberate: enqueue acknowledgement updates cannot retrigger it. A crash after enqueue but before acknowledgement redelivers the Firestore event; deterministic task identity turns Cloud Tasks `ALREADY_EXISTS` into accepted success. If created-event retries exhaust before any task exists, the first-slice scheduled sweeper finds the durable stale dispatch and uses the same task identity and adapter. The callable never enqueues directly, so there is no state-written/task-missing gap.

## Decisions

| Topic | Decision | Rejected alternative / rationale |
|---|---|---|
| Liveness | Transactional outbox -> created-only trigger fast path plus scheduled stale-outbox repair -> Cloud Tasks worker. | Callable-only/client retry strands work; trigger-only liveness can fail when Eventarc retries exhaust before task creation. |
| Enqueue boundary | Submission atomically creates operation and initial dispatch; only the shared trigger/sweeper adapter enqueues. | Direct callable enqueue cannot be atomic with Firestore. |
| Sweeper | First-slice bounded repair of stale `enqueued=false` dispatches; it never executes saga work. Validator evidence explicitly supersedes the earlier exclusion of scheduled repair because Eventarc delivery can exhaust before task creation. | A scheduler as the primary driver adds latency; trigger-only delivery leaves a durable outbox without an independent repair path. |
| Effect protocol | One dispatch represents one boundary; worker persists intent before an external mutation and writes result, audit, next dispatch, and current ack atomically where Firestore permits. | A multi-effect invocation enlarges ambiguous crash windows. |
| Auth ambiguity | Exact create return plus mandatory UID/email reads can establish proof; timeout, ambiguous return, crash, or missing persisted proof goes `manual_recovery`. | Equality after uncertainty is not ownership and cannot justify retry or deletion. |
| Compensation | No Auth deletion in the first slice; safe failures fix forward, unsafe/post-attempt failures go `manual_recovery`. | Automatic deletion risks deleting a foreign identity. |
| Retry | `maxAttempts=12`; normal work only for `retryCount < 8`; `retryCount >= 8` is terminalization-only. | One threshold leaves no attempts to durably record terminal state. |
| Contract proof | Independent pure reducer, frozen vectors, strict in-memory reference store, and Firestore-emulator adapter conformance precede production adapters. | An implementation-authored fake can repeat the implementation's defect. |
| Reset onboarding | Status query generates and returns a fresh reset link after integrity checks; it never stores, logs, audits, or emails the link. | Temporary passwords and implied email delivery violate the approved product contract. |

Rejected alternatives remain: callable-only provisioning, direct enqueue from the callable, client-owned liveness, automatic Auth deletion, and fake-only proof. Trigger-only outbox delivery is newly rejected; the trigger remains the fast path and the scheduled sweeper is only the repair path.

## Canonical Vocabulary and Identity

Statuses are exactly `pending | active | completed | failed | manual_recovery`. Phases are `dispatch_pending | auth_preflight | auth_create | profile_commit | terminal`; only `pending/dispatch_pending`, `active/{auth_preflight,auth_create,profile_commit}`, and terminal-status/`terminal` combinations are valid.

| Identity | Canonical form |
|---|---|
| `operationId` | Client-created lower-case UUID-v4, reused only for the same intentional submission and persisted for restart. |
| `fingerprint` | Lower-case SHA-256 of UTF-8 fixed-key-order canonical JSON; `operationId` excluded. |
| `intendedUid` | Server-generated Firebase-valid random UID, immutable after submission wins. |
| `dispatchId` / `taskId` | `hexSha256("provision-dispatch:v1\0" + operationId + "\0" + boundary + "\0" + generation + "\0" + sourceVersion)`. |
| `attemptId` | Dispatch ID for the Auth intent; never reused for a second create call. |
| `auditEventId` | `hexSha256("provision-audit:v1\0" + operationIdOrCorrelation + "\0" + category + "\0" + stage + "\0" + generation + "\0" + sourceVersion)`. |
| `ownerToken` | Fencing digest derived from dispatch ID and generation; opaque outside the worker. |

Canonical payload keys, in order, are `email,nombre,apellido1,apellido2,employeeId,weeklyHours,dni,telefono,cargo,departamento,empresa,scheduleId,calendarId,fechaInicio,fechaFin,role,isSupervisor,supervisorId,isActive`. Strings are NFC-normalized and trimmed; email is lower-case; blank optionals are `null`; dates are UTC `YYYY-MM-DD`; defaults are exactly `weeklyHours=40`, `employeeId=""`, `isSupervisor=false`, `supervisorId=null`, and `isActive=true`. Unknown keys, nested/array/non-plain values, non-finite numbers, invalid ranges, and missing `operationId,email,nombre,apellido1` are rejected. `displayName` is derived. Roles are only `employee|rrhh`.

## Persistence Contracts

### `/provisioningOperations/{operationId}`

| Field | Contract |
|---|---|
| `schemaVersion` | Integer `1`; immutable. |
| `operationId`, `fingerprint`, `normalizedPayload`, `intendedUid` | Canonical values above; immutable. |
| `submittedByDigest` | Domain-separated SHA-256 caller UID digest; immutable, never a raw UID. |
| `status`, `phase` | Valid vocabulary pair; terminal pair immutable. |
| `generation`, `version` | Initially `0,0`; generation changes only on takeover, version on every operation mutation. |
| `ownerToken`, `leaseExpiresAt`, `currentDispatchId` | Current fencing owner, server-time lease, and only dispatch allowed to advance; owner/lease null in `pending` and terminal states. |
| `authAttempted` | Initially false; flips monotonically to true in the transaction that persists the first Auth intent and never resets. Pending terminalization requires false. |
| `authAttempt` | Null or `{attemptId,intentAt,callStartedAt,result,returnedUid,returnedEmail,proof}`. `result` is `intent|call_started|confirmed|definite_no_effect|ambiguous`; returned values are exact create response fields; `proof={attemptId,confirmedAt,uidRead,emailRead}` only after exact return and both reads agree. `call_started` is committed immediately before the call, so a redelivery never calls again. Confirmed proof is immutable. |
| `failureEvidence` | Append-only bounded entries `{eventId,boundary,code,class,generation,version,recordedAt}`; no SDK message or PII. Overflow rolls into counts/digests, never silent deletion. |
| `retryEvidence` | `{committedFailureCount,maxRetryCountSeen,maxExecutionCountSeen,lastRetryReasonCode}`; Firestore values are authoritative, TaskContext values advisory. |
| `terminalCode`, `recoveryCode` | Stable allowlisted codes or null; no free-text SDK detail. |
| `createdAt`, `updatedAt` | Server timestamps; `createdAt` immutable. |

### `/provisioningDispatch/{dispatchId}`

| Field | Contract |
|---|---|
| `schemaVersion`, `dispatchId`, `taskId`, `operationId`, `fingerprint` | Immutable identity; task ID equals dispatch ID. |
| `boundary`, `generation`, `sourceVersion` | Immutable expected work tuple. Boundaries: `acquire`, `auth_preflight`, `auth_create`, `profile_commit`. |
| `ownerSeed` | Opaque material used to derive the generation fencing token; immutable. |
| `enqueued`, `enqueuedAt`, `enqueueSource`, `enqueueEventId` | Initially `false,null,null,null`; guarded acknowledgement sets `true`, server time, `trigger|sweeper`, and the source event/run digest. Trigger and sweeper own these fields through the same transaction helper. |
| `workerAck`, `workerAckAt` | Initially null; only worker-owned terminal dispatch result: `processed|stale|terminalized`. |
| `createdAt` | Immutable server timestamp. |

Identity fields never change. Enqueue acknowledgement and worker acknowledgement are the only legal updates. A transition creates exactly one next dispatch with deterministic create-if-absent semantics.

### `/provisioningAudit/{eventId}`

Required immutable fields are `schemaVersion,eventId,operationId|null,correlationId,category,stage,outcome,code,actorUidDigest|null,intendedUidDigest|null,dispatchId|null,generation|null,sourceVersion|null,createdAt`. Categories are exactly `authorization | progress | success | failure`; required families are denial, state transition, Auth intent/result, terminal success, terminal failure/manual recovery, stale delivery, and completed-integrity failure. Events are create-if-absent and immutable; an existing ID must match all identity fields. App Check rejection before handler entry is the sole application-audit exception.

### `/users/{intendedUid}` provisioning provenance

The existing employee fields remain, but backend-created profiles also require immutable `userId,email,provisioningOperationId,provisioningFingerprint,provisioningSchemaVersion,provisionedBy:"trusted-backend",provisionedAt`. `email` is normalized; `userId` equals the document ID and intended UID. A profile is operation-matching only when UID, normalized email, operation ID, fingerprint, schema version, and every normalized profile field match. Provenance proves profile origin, not Auth ownership.

### Indexes

Saga phase correctness uses direct document reads. `firestore.indexes.json` adds operations `(status ASC, updatedAt ASC)`, operations `(status ASC, phase ASC, leaseExpiresAt ASC)`, dispatches `(operationId ASC, createdAt ASC)`, audit `(operationId ASC, createdAt ASC)`, and the correctness-critical sweeper query index `(enqueued ASC, createdAt ASC, __name__ ASC)`. The sweeper queries exactly `enqueued == false AND createdAt <= serverNow-10m`, ordered by `createdAt,__name__`, with cursor pagination.

## Full CAS and Lease Contract

For every active mutation, the transaction reads server time and requires equality of `fingerprint,status,phase,generation,version,ownerToken,currentDispatchId` plus `leaseExpiresAt > serverNow`. It also verifies the current dispatch's immutable `operationId,fingerprint,boundary,generation,sourceVersion` as the issuance identity; after acquisition/takeover, the operation's freshly read full tuple is the mutation CAS while `currentDispatchId` fences stale dispatches. The write increments `version` exactly once. No Auth/profile mutation starts after this predicate fails.

Initial acquisition requires `pending/dispatch_pending`, exact fingerprint, `generation=0`, `version=0`, `ownerToken=null`, `leaseExpiresAt=null`, `authAttempted=false`, and the exact unacknowledged initial `acquire` dispatch. One transaction sets `active/auth_preflight`, owner token, lease `serverNow+60s`, increments version, creates the matching `auth_preflight` dispatch, audits the transition, and acknowledges the `acquire` dispatch; that invocation yields. Same-dispatch continuation requires the full live tuple. Takeover requires the full observed tuple, same current dispatch, and `leaseExpiresAt <= serverNow`; it increments generation and version, derives a new fencing token from dispatch ID plus new generation, and sets a 60-second lease. The invocation then must reread and use that exact new full active tuple before any transition. A stale generation/version, wrong owner, wrong dispatch, terminal status, or expired lease on a non-takeover mutation produces no write or side effect. Terminalization clears owner/lease, sets phase `terminal`, and preserves immutable/failure fields.

### P1a2-i-B-1 amendment: explicit expected-CAS request

The prior planned `reduce(state, event)` surface cannot prove CAS: `state` contains only the current tuple, while the frozen exact `ModelEvent` payloads contain no independent expectations. B-1 therefore narrowly amends the planned reducer parameter from an event to a request envelope. `reduce()` remains the only public transition function; event vocabulary, payload schemas, `isValidEvent`, `createEvent`, state vocabulary, guards, and the four accepted A constructors are unchanged.

```ts
export interface ExpectedCAS {
  readonly fingerprint: OperationState["fingerprint"];
  readonly status: OperationState["status"];
  readonly phase: OperationState["phase"];
  readonly generation: number;
  readonly version: number;
  readonly ownerToken: string | null;
  readonly currentDispatchId: string | null;
  readonly leaseExpiresAt: number | null;
}

export interface ReducerRequest {
  readonly expected: ExpectedCAS;
  readonly observedAt: number;
  readonly event: ModelEvent;
}

export function reduce(
  state: OperationState,
  request: ReducerRequest,
): TransitionResult;
```

`expected` is owned by the transaction/dispatch caller: it is captured from the tuple that authorized the attempted write, independently of the authoritative `state` reread passed as the first argument. The adapter must not derive expectations from that same reread. `observedAt` is the caller's authoritative server-time observation; it is outside the eight-field tuple so lease equality and lease liveness remain separate predicates and the pure model never reads a clock. The carrier is readonly, is never mutated or retained by the reducer, and all returned results/states remain deeply frozen.

Validation and dispatch order is exact:

1. Validate `state` with the accepted strict state guard; failure is `invalid_state`, with no mutation.
2. Descriptor-read a plain `ReducerRequest` with exactly `expected,observedAt,event`; reject missing, extra, symbol, accessor, class, polluted-prototype, proxy/trap, fractional, negative, or non-finite values as `invalid_request` without invoking accessors.
3. Descriptor-read a plain `expected` object with exactly the eight fields above. Validate each field independently against its canonical scalar/null domain, but do not require the expectation's status/phase or lifecycle fields to form a valid state; this preserves per-field stale-CAS diagnosis. Missing/extra/malformed fields fail as `invalid_expected`.
4. Validate `event` unchanged through `isValidEvent`; malformed business payloads fail as `invalid_event`. Envelope validation MUST NOT add CAS keys to payloads or relax their exact-field guards.
5. Apply B-2/B-3 terminal policy when those slices exist. For a nonterminal event that can mutate now or in P1a2-ii/iii, compare all eight expected fields to current state. Any inequality returns `cas_mismatch`. For active state, additionally require non-null `state.leaseExpiresAt` and `state.leaseExpiresAt > observedAt`; otherwise return `lease_not_live`.
6. Dispatch supported behavior. In B-1 every boundary/terminalization event remains unsupported after a live CAS and returns `unsupported_event`; stale, malformed, terminal, and unsupported paths are all non-mutating. Later slices add behavior behind the same gate rather than bypassing it.

Failure codes above are stable literal reasons and deeply frozen. Precedence is state -> request -> expected -> event -> terminal policy -> CAS equality -> lease liveness -> event dispatch. A failed predicate never calls a transition helper, increments counters, or changes nested data.

| Alternative | Tradeoff | Decision |
|---|---|---|
| Selected event envelope (`ReducerRequest`) | Keeps two arguments and gives adapters one atomic command value; adds one narrow carrier type and changes planned callers. | Selected. CAS metadata stays beside, never inside, business events. |
| Separate third argument | Small type, but `reduce(state,event,expected)` can split event/time/expectation assembly and requires a fourth value or hidden clock for liveness. | Rejected. |
| Expectations embedded in state | Conflates authoritative current data with caller preconditions and risks persisting transient command metadata. | Rejected. |
| Self-comparison | No independent precondition; always “proves” equality and falsely claims CAS. | Forbidden. |

B-1 RED must prove: old `reduce(state,event)` is compile-rejected; the exact request compiles; each expected field independently mismatches through `reduce()`; an exact tuple reaches `unsupported_event`; exact-but-expired and active-null leases return `lease_not_live`; malformed/missing/extra envelope and expectation fields fail closed; existing per-event missing/extra payload probes remain green; and every failure leaves the complete input state byte-identical. Explicit source+test TypeScript and source-only `npx tsc --noEmit` remain mandatory, including `@ts-expect-error` probes for the old signature and missing/extra expected fields.

This changes no downstream semantics: B-2/B-3 add terminal, monotonic, data, and acknowledgement behavior behind this request gate; P1a2-ii supplies expectations from dispatch/transaction issuance snapshots; P1a2-iii reuses the same carrier for reserved terminalization. The four implementation/planning paths remain `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, `tasks.md`, and `apply-progress.md`. This design amendment changes only `design.md`; the next `sdd-tasks` amendment must rewrite B-1's signature, RED cases, forecast, and handoff without changing apply progress.

## Boundary and Crash Protocol

### Submission transaction

After App Check, authentication, admin lookup, and schema normalization, one Firestore transaction creates the operation in `pending/dispatch_pending` and initial `acquire` dispatch. Same `(operationId,fingerprint)` returns its current safe status; a different fingerprint returns `already-exists` without mutation. Firestore can make these two documents atomic. Submission cannot be atomic with Auth or Cloud Tasks and intentionally calls neither.

### Outbox enqueue

The retry-enabled `onDocumentCreated` handler validates immutable dispatch shape and calls `enqueueDispatch(dispatch)`. Enqueue and Firestore acknowledgement cannot share a transaction. Crash before enqueue causes event retry; crash after enqueue causes `ALREADY_EXISTS`, which is accepted. Success or `ALREADY_EXISTS` is followed by one guarded transaction requiring exact dispatch identity and `enqueued=false`; it sets `enqueued=true`, `enqueuedAt=serverNow`, source/event digest, and nothing else. If a race already committed the same acknowledgement, the handler succeeds; identity mismatch fails closed. Other errors emit only PII-safe operation/dispatch digests and throw.

### Scheduled outbox repair

`repairProvisioningOutbox` is a first-slice `onSchedule` function running every 5 minutes with scheduler retries `retryCount=3`, `minBackoffSeconds=30`, `maxBackoffSeconds=300`, and `maxDoublings=2`. Each run computes `cutoff=serverNow-10m` and scans only `enqueued=false AND createdAt<=cutoff`, ordered by `createdAt,__name__`, in pages of 100, at most five pages/500 dispatches per run. It uses at most 10 concurrent enqueue calls and a 25-enqueues/second limiter; `maxInstances=1` and `timeoutSeconds=240` bound overlap and cost.

For every record it validates immutable identity and calls the **same** `enqueueDispatch` adapter with the **same** deterministic task ID as the trigger. Enqueue success or `ALREADY_EXISTS` uses the same guarded acknowledgement transaction. Trigger+sweeper races are harmless: one enqueue wins, the other observes `ALREADY_EXISTS`, and either acknowledgement wins while the other verifies `enqueued=true`. Per-record failures log PII-safe operation/dispatch digests; the run processes its bounded page, then throws if any failed so Scheduler retry and the next regular schedule repair them.

The sweeper does not execute or classify saga phases, mutate Auth/profile/operation state, acknowledge worker completion, create dispatches, or invent alternate task identities. Trigger delivery remains the fast path; scheduled scanning is only repair. If Eventarc, Scheduler, and Cloud Tasks are simultaneously unavailable beyond their retry windows, autonomy is not claimed: Monitoring alerts and the operator runbook restore dependencies, query the same stale index, and re-run the same repair handler/adapter. Operators never call a saga phase directly.

### Worker acquisition and intent

Each delivery reads dispatch and operation, then uses the CAS rules to acquire, continue, or take over. Duplicate/out-of-order/terminal deliveries atomically mark only their dispatch stale where legal and return 2xx; they never advance operation state. Before Auth create, the worker performs mandatory UID and email reads. If both are absent, one transaction flips `authAttempted=true`, persists `authAttempt.result=intent`, Auth-attempt audit, version, a deterministic `auth_create` dispatch, and current dispatch acknowledgement. The current invocation yields; the next dispatch owns the external create boundary.

### Auth create result matrix

The `auth_create` dispatch first CASes the full live tuple from `intent` to `call_started`, records `callStartedAt`, and increments version. Only that successful invocation may call Auth, once. Any delivery observing `call_started` without proof reconstructs and terminalizes; it never calls create again for that `attemptId`.

| Observation | Required action |
|---|---|
| Exact live intent; CAS to `call_started` succeeds in this execution | Call `createUser({uid:intendedUid,email,displayName})` once. |
| Exact returned UID and email, then mandatory UID lookup and email lookup both resolve to that pair | Transactionally persist exact return, immutable proof, `active/profile_commit`, result audit, next dispatch, and current ack. |
| Returned UID/email differs, either read differs/fails, return is malformed/ambiguous, timeout occurs, or execution crashes after `call_started` and before proof commits | On retry/reconstruction, run both reads; without independently persisted proof, atomically set `manual_recovery`, failure evidence/audit, and current ack. This includes a crash after `call_started` but before the SDK call: safety deliberately favors manual review. Never retry or delete Auth. |
| SDK reports a definite no-effect error and both post-error indexes independently prove absence | Transactionally record `definite_no_effect`, evidence/audit, return to `auth_preflight`, create a new dispatch/attempt identity, and ack current dispatch. Retry policy decides whether normal work remains. |
| Foreign UID/email exists before any intent | Atomically set `failed/terminal` with `already-exists`, audit, and ack; mutate no identity/profile/claim. |

Current UID/email equality after timeout is not proof: another actor may own that identity. The design claims neither exactly-once nor at-most-once Auth behavior after uncertainty.

### Profile and completion

The `profile_commit` dispatch first requires persisted Auth proof and mandatory matching UID/email reads. One Firestore transaction then creates or verifies the operation-matching profile and atomically writes `completed/terminal`, the `success.completed` audit event, and current dispatch acknowledgement. This success transaction is all-or-nothing: success audit cannot fail independently. A conflicting profile, missing/mismatched Auth, absent proof, or unsafe post-attempt condition terminalizes as `manual_recovery`; no deletion occurs. A transient transaction failure leaves the operation nonterminal and throws for retry.

### Failed/manual terminalization and outbox acknowledgement

All safe terminal transitions atomically write operation terminal state, stable evidence, terminal audit, and current worker ack. When a transition creates more work, operation state, transition audit, next dispatch, and current worker ack are one transaction. Enqueue acknowledgement remains a separate shared trigger/sweeper update because Cloud Tasks cannot participate in Firestore transactions.

## Retry and Exhaustion Semantics

`onTaskDispatched` uses `retryConfig.maxAttempts=12`, `minBackoffSeconds=5`, `maxBackoffSeconds=300`, and `maxDoublings=5`; queue rate limits are repository configuration reviewed before deployment. Official TaskContext semantics are normative: initial `retryCount=0`; `retryCount` includes retry-causing 5xx attempts that may never reach handler execution; `executionCount` is separately available.

Normal boundary work is allowed only when `retryCount < 8` (values 0-7). At `retryCount >= 8`, values 8-11 are four reserved terminalization opportunities. They perform no external Auth/profile effect and follow this exact classifier:

| Stored state at reserved attempt | Mechanically executable action |
|---|---|
| Exact initial pending state | One transaction requires operation fingerprint, `status=pending`, `phase=dispatch_pending`, `generation=0`, `version=0`, `ownerToken=null`, `leaseExpiresAt=null`, `authAttempted=false`, `authAttempt=null`, and `currentDispatchId` equal to the task's initial dispatch. It also requires that dispatch's exact `operationId,fingerprint,boundary=acquire,generation=0,sourceVersion=0,workerAck=null`. It writes `failed/terminal`, `version=1`, `terminalCode=unavailable`, retry evidence, `failure.retry_exhausted_before_entry`, its deterministic failure audit, and current dispatch `workerAck=terminalized/workerAckAt=serverNow` atomically; no next dispatch. |
| Pending predicate mismatch | Do not infer safety or write. Reread operation+dispatch and reclassify as exact pending, active, or terminal; a second mismatch/CAS loss returns success with no mutation because another worker changed ownership/progress. |
| Active with exact current owner and live lease | Require the complete active CAS tuple and current dispatch identity. If durable evidence proves no Auth intent/effect (`authAttempted=false`, `authAttempt=null`, safe phase), atomically write `failed/unavailable`; otherwise atomically write `manual_recovery/internal`. In either case evidence, failure audit, owner/lease clear, and current ack commit together. |
| Active with another owner's unexpired lease | Do not steal or mutate. CAS loss/ownership classification returns success because that owner is responsible for progress. |
| Active with expired lease | First transaction requires the exact full observed expired tuple/current dispatch, increments generation+version, installs the deterministic new owner token and live lease. The same invocation (or its retry after authoritative reread) then applies the complete active terminalization guard above using the exact new tuple. If takeover or terminalization persistence is uncertain, reread; throw only when the guarded terminalization still belongs to this owner and did not commit. |
| Terminal operation | Return success without operation mutation or new audit. Existing dispatch acknowledgement is idempotent; no terminal state changes. |

The pending path is safe `failed/unavailable`, not `manual_recovery`, because every predicate proves no Auth intent/effect exists. Any missing/mismatched pending field destroys that proof. Active terminalization never steals an unexpired lease and never relies on TaskContext as ownership evidence.

Any terminalization CAS loss is success with no mutation: authoritative reread classifies it as another worker owning progress or an already-terminal operation. Dependency/commit failure is distinct from CAS loss and throws only while this task still satisfies the exact guarded owner/current-dispatch predicate.

On every entered execution, advisory TaskContext maxima and any failure evidence are committed with the guarded state mutation. Firestore state, not headers, decides whether an effect intent/proof exists. Because pre-handler 5xx can increment `retryCount` without execution, a task's first handler entry can already have `retryCount>=8`; it immediately uses the pending classifier rather than attempting acquisition. Reserved values 8, 9, 10, and 11 repeat only these guarded terminalization paths. A failed terminalization transaction throws so the next reserved attempt retries it; a committed terminal state returns success.

If Firestore is permanently unavailable, no handler can guarantee terminalization. There is no fictional post-exhaustion callback: Cloud Tasks/Functions failed-execution and queue-attempt-exhaustion metrics must alert, correlated with the PII-safe operation/dispatch digest emitted by any entered invocation. The runbook inspects and explicitly recovers the nonterminal operation. Exhaustion itself does not write `manual_recovery`; terminalization remains best effort under permanent durable-store outage.

## Callable Contracts and Security

Both callables export `onCall({enforceAppCheck:true})`. Handler order is: wrapper App Check -> authentication -> `/users/{callerUid}` admin and `isActive=true` authorization -> denial audit when handler was entered -> schema/normalization -> operation access. App Check denial has platform/edge evidence only. An entered unauthenticated or unauthorized request writes one PII-safe denial event before any reservation/resource mutation; if that write is unavailable, outward denial remains stable and a PII-safe platform error is emitted.

`submitProvisioning` returns only `{operationId,status}` where status is `pending` for a new operation or the current canonical status for an idempotent replay. `getProvisioningStatus` requires `operationId`, accepts optional fingerprint, returns `not-found` for unknown ID and `already-exists` for mismatch, and never mutates the operation on either path.

Safe status DTOs are discriminated:

| Status | Safe fields |
|---|---|
| `pending` | `operationId,status,retryAfterSeconds` |
| `active` | `operationId,status,phase,retryAfterSeconds` |
| `completed` | `operationId,status,userId,resetLink,idempotent:true` |
| `failed` | `operationId,status,terminalCode` |
| `manual_recovery` | `operationId,status,terminalCode,recoveryCode` |

Internal payload, owner, lease, generation/version, raw evidence, audit identity, and email are never returned. For `completed`, the callable re-reads both Auth indexes and the full provenance-tagged profile. Failure or inconsistency returns a stable integrity error without changing the terminal operation or generating a link; a separate deduplicated integrity audit may be created. Only after integrity passes does Auth generate a fresh reset link. The link is returned to the admin for manual delivery; it is never stored, logged, audited, or emailed. Transient link failure returns a stable retryable error and leaves `completed` unchanged.

Dedicated service accounts enforce least privilege: callables read caller/profile/operation data; submission writes operation/dispatch/audit; worker reads/writes saga/profile/audit and uses only required Auth user administration; outbox trigger has one-dispatch read/update plus Cloud Tasks enqueuer; sweeper has query/read/update on dispatch only plus the same Cloud Tasks enqueuer; Scheduler may invoke only the sweeper; the queue's OIDC identity may invoke only the private task function. The sweeper has no Auth permission and no operation/profile write permission. Application logs contain only allowlisted codes and domain-separated digests—never raw email, names, display name, DNI, telephone, request body, token, reset link, or SDK message.

Cloud Monitoring defines: (1) `outbox_stale_age_seconds`, emitted from the oldest matching repair query and alerting above 900 seconds for two consecutive 5-minute periods; (2) Eventarc outbox-trigger error/delivery-failure alerts; (3) sweeper execution-error alert and a missing-successful-execution alert after 10 minutes; and (4) Cloud Tasks enqueue/attempt-exhaustion alerts. Trigger and sweeper failure logs carry only dispatch/operation digests. The runbook first restores Eventarc/Scheduler/Tasks, then invokes the same repair handler or waits for schedule, verifies deterministic enqueue acknowledgement, and finally inventories any still-stale dispatches—never mutating Auth/profile/operation directly.

## Flutter Product Flow

The Riverpod service replaces secondary `FirebaseApp`, direct client Auth/profile writes, temporary passwords, and client compensation. It creates and durably stores one operation ID before submission, submits once, and polls status with delays `1s,2s,4s,8s`, then capped `15s` with jitter. Polling cancels on drawer disposal/logout, pauses offline/backgrounded, and resumes from the persisted operation ID after restart by querying status—never by resubmitting. `retryAfterSeconds` may lengthen but not shorten local backoff. Completed UI presents a copyable reset link and states that the admin must deliver it; failed/manual recovery UI shows stable actionable copy and preserves the operation ID for support.

## Executable Contract Before Production Code

Slice 1 authors and independently reviews a pure TypeScript reducer/reference model, invariant table, and conformance vectors before any production Firebase adapter. Commands/events describe domain observations and intended transitions only; they cannot call, import, encode, or assume Firebase adapters. The model is frozen for adapter conformance review.

| Invariant | Required proof |
|---|---|
| Terminal immutability | Every command against each terminal status is rejected without mutation. |
| Full CAS | Per-field mutation tests independently alter fingerprint, status, phase, generation, version, ownerToken, currentDispatchId, and lease liveness; each stale mutation fails, while the exact live tuple succeeds. |
| Monotonic state | Version increments on every mutation; generation only on expired-lease takeover. |
| Intent before effect | No create command is emitted without a committed unique intent. |
| Ambiguity safety | Crash/timeout/malformed return/missing proof never emits create retry or delete. |
| Dispatch safety | Duplicate, stale, and out-of-order vectors cause no effect or regression. |
| Completion atomicity | Profile + completed + success audit + ack appear together or not at all. |
| Data immutability | Operation identity/payload/UID, audit identity, dispatch identity, provenance, and Auth proof cannot change. |
| Retry thresholds | 0-7 may work; 8-11 terminalize only; exhaustion never fabricates a terminal write. |
| Pending terminalization | Independently mutate fingerprint, status, phase, generation, version, ownerToken, lease, authAttempted, authAttempt, current dispatch ID, dispatch identity/source tuple, and worker ack; every mismatch blocks `failed/unavailable`. Exact initial state commits failure+audit+ack once. |

Crash-point vectors surround every external effect: before/after enqueue, Auth intent, Auth call, Auth return, each dual read, proof commit, profile/completion commit, completed integrity reads, and reset-link generation. The same vectors run against (1) a strict independently reviewed in-memory reference store and (2) the Firestore emulator transaction adapter. Divergence fails the build. A production-implementation-authored fake alone is inadmissible.

## Emulator and Verification Strategy

| Layer | Required proof |
|---|---|
| Pure unit/property | Normalization/fingerprint, reducer transitions, invariant/per-field guard mutations, deterministic IDs, retry threshold, failure precedence, safe DTO projection. |
| Strict reference conformance | Frozen vectors and crash schedules against independent store, then identical vectors against Firestore emulator adapter. |
| Auth + Firestore emulators | Foreign pre-attempt identity; exact create result; both UID/email reads; ambiguity; provenance conflict; all-or-nothing completion; completed integrity. |
| Functions emulator | Both callable HTTP/callable protocols, metadata `enforceAppCheck:true`, task queue function exercised as its HTTP endpoint, stable errors, PII-safe logs. |
| Outbox integration | Firestore created event -> injectable enqueue adapter; duplicate event, enqueue success/crash-before-ack, `ALREADY_EXISTS`, invalid dispatch, guarded ack, and trigger+sweeper race. Production adapter receives a contract test against verified task construction. |
| Scheduled repair | Invoke the pure sweeper handler directly with Firestore-emulator records and shared enqueue adapter: 10-minute grace edge, `(enqueued,createdAt,__name__)` ordering/cursors, 100x5 bounds, rate/concurrency limits, partial failure/throw, already-enqueued race, and forbidden operation/Auth/profile writes. This proves handler behavior, not a fake scheduler or Scheduler delivery. Export/config metadata proves the real schedule/retry limits. |
| Concurrency/faults | True parallel emulator clients/workers, lease expiry/takeover, duplicate/out-of-order delivery, crash injection around every effect, first entry after pre-handler retries, retryCount 7/8/9/10/11, exact pending guard per-field mutations, pending mismatch reclassification, active live owner, foreign live owner, expired takeover, terminal idempotency, and failed reserved terminalization. Sequential mocks do not qualify. |
| Client | Fake callable transport only for Dart boundary tests; polling/backoff/jitter/cancel/restart persistence, DTO/error mapping, reset-link UX, and structural absence of direct provisioning. |

There is no supported `emulators.tasks` or Scheduler emulator assumption. Local task-worker proof sends authenticated test HTTP requests to the Functions emulator's task endpoint with controlled TaskContext headers. The enqueue boundary is injectable: a strict fake proves outbox idempotency, while a production adapter contract verifies deterministic queue/task construction. The scheduled handler is invoked directly; tests never claim that a fake timer proves Cloud Scheduler delivery. Auth, Firestore, and Functions emulators remain the integration substrate; metadata tests prove App Check and schedule/retry options because emulator tokens/timers do not prove production platform metadata.

## Repository Files and Deployment Metadata

| Path | Planned action |
|---|---|
| `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, vector fixtures | Add independent pure model/invariants first. |
| `functions/src/provisioning/store.ts`, `functions/src/provisioning/firestore_store.ts` | Add domain port and transactional Firestore adapter. |
| `functions/src/provisioning/submit.ts`, `outbox.ts`, `outbox_repair.ts`, `worker.ts`, `status.ts` | Add separated callable, shared enqueue/ack adapter, created-trigger fast path, bounded scheduled repair, task worker, and status handlers. |
| `functions/src/index.ts` | Export both App-Check callables, created-only trigger with retry, 5-minute scheduled repair with bounded retry, and private task function with retry/rate/service-account metadata. |
| `functions/test/provisioning/**` | Add unit, conformance, adapter, emulator, concurrency, crash, threshold, and export-metadata proof. |
| `functions/package.json`, lockfile, `firebase.json` | Extend WU4a scaffold minimally for scripts and Functions wiring; do not add a tasks emulator block. |
| `firestore.indexes.json`, `firestore.rules`, `test/firestore/**` | Add reporting indexes and, after trusted client migration, deny direct `/users` creation/privileged writes with Admin SDK emulator proof. |
| `lib/core/services/firebase_service.dart`, provider/UI state and focused tests | Replace direct provisioning with callable submission, persisted observation, polling, and reset-link result while retaining Riverpod. |
| Existing signing/sanitization/README/docs paths | Continue only in their later already-defined work units; no architectural change here. |

Repository preparation records region, queue name, task retry/rate limits, Scheduler cadence/retry/timeouts, runtime and per-function service accounts, task OIDC identity, Scheduler invoker, Eventarc trigger metadata, Cloud Tasks enqueuer role, required Firestore/Auth permissions, stale-outbox index, environment/project placeholders, alert names/thresholds, and PII-safe outbox/manual-recovery runbooks. The deployer needs documented Cloud Functions/Eventarc/Cloud Tasks/Cloud Scheduler/IAM permissions, but no production project ID, secret, role binding, queue, scheduler job, alert, or deployment is created in this change phase.

## Rollback and Recovery

Deployment rollback, if later authorized, first stops new submissions (feature flag/export), keeps outbox trigger, scheduled repair, worker, and status available while accepted operations drain, then inventories every nonterminal/`manual_recovery` operation and every `enqueued=false` dispatch by digest. Never delete Auth automatically. Revert slices only through their enumerated files and keep schema readers backward-compatible until no stored operation needs them. Client rollback precedes callable removal; rules allowing no direct creation must not be relaxed merely to restore the legacy unsafe flow. Scheduler/trigger/queue removal occurs last, after stale-outbox age is zero and operations drain or explicit operator ownership is recorded. Planning rollback is simply reverting this design file; it does not touch WU4a, the updated spec, runtime, or stashes.

The scheduled repair is not a general reconciler, phase executor, archival sweep, or substitute queue. It does not change the non-goals: no production deployment, automatic Auth deletion, email provider, exactly-once/at-most-once Auth claim after uncertainty, or client-owned liveness. Autonomous progress is expected while at least one configured enqueue path and durable dependencies recover within their retry windows; permanent simultaneous Eventarc, Scheduler, Cloud Tasks, or Firestore outage is the spec-defined alert-and-operator exception, not silent success.

## Eleven Review Slices and Forecast

The former 1,500-line WU4b allowance is not sufficient. The next `sdd-tasks` phase must replace stale WU4b budgets/checkmarks before any apply work.

| Slice | Reviewable outcome | Forecast |
|---|---|---:|
| S1 | Independent pure model, invariant table, vectors, model review/freeze | 330-400 |
| S2 | Strict reference store + Firestore adapter conformance | 300-380 |
| S3 | Canonical schemas, IDs, CAS/lease store primitives | 320-400 |
| S4 | Submission, authorization/denial audit, safe DTO contracts | 260-340 |
| S5 | Shared enqueue adapter + created-trigger fast path | 200-270 |
| S6 | Scheduled stale-outbox repair, index, limits, alerts/runbook proof | 200-280 |
| S7 | Task worker Auth/profile boundaries and crash matrix | 340-400 |
| S8 | Pending/active reserved terminalization guards and threshold proof | 240-320 |
| S9 | Status/reset link, exports, IAM/deployment metadata | 260-340 |
| S10 | Full emulator, true concurrency, outbox race/retry conformance | 340-400 |
| S11 | Flutter migration, persistence/polling UX, Dart proof | 260-350 |
| **Total** | Feature-branch chain; every slice remains at or below 400 forecast lines | **3,050-3,880** |

Each slice carries its own RED/GREEN proof and rollback boundary. S1 is explicitly a model-authoring/review slice; production adapter work cannot begin before its vectors are accepted. The prior nine-slice forecast is superseded because adding durable scheduled repair and exact pending/active terminalization proof would make its infrastructure/worker slices unreviewable. Tasks must reconcile current completed-work metadata honestly: WU4a remains complete, failed implementation checkmarks are not evidence for this replacement design, and no old 1,500/1,690/2,000 guard is forwarded as sufficient authorization.

## Threat Matrix

N/A — this design introduces no routing, shell, subprocess, VCS/PR automation, executable-file classification, or general process-integration boundary. Firebase event/task integration is covered by the distributed-systems threat and crash matrices above.

## Requirement and Scenario Traceability

| Updated spec requirement | Design component | Scenario-family proof level |
|---|---|---|
| App Check Pre-Handler Enforcement | Callable exports; security order; metadata | Structural export metadata + Functions emulator protocol; platform denial evidence documented. |
| Asynchronous Provisioning Submission | Submission transaction; canonical payload | Unit schema/fingerprint + Firestore/Functions emulator; assert no Auth/profile side effect. |
| Operation Identity and Idempotency | Deterministic IDs; full CAS; stale delivery | Model vectors + emulator duplicate submission/fingerprint conflict/out-of-order dispatch. |
| Autonomous Backend Liveness | Trigger fast path + scheduled stale-outbox repair + Cloud Tasks boundary protocol | No-client emulator drive, created-event exhaustion repair, trigger+sweeper race, schedule metadata, Monitoring/runbook outage exception. |
| Protected Status Query | Safe DTOs; authorization; optional fingerprint | Unit projection + callable emulator authorization/not-found/conflict. |
| Completion Atomic Commitment | Profile completion transaction | Emulator transaction fault injection and completed-integrity query; success tuple all-or-nothing. |
| Password Reset Link Issuance | Completed-only status behavior | Auth/Functions emulator: fresh returned link, failure retry, no storage/log/email. |
| Auth Ambiguity and Reconstruction | Auth create matrix; dual reads; proof | Pure crash vectors + Auth emulator ambiguity/foreign/mismatch cases. |
| First-Slice Compensation Policy | No-delete decision and terminal matrix | Structural no-delete assertion + all post-Auth failure vectors -> `manual_recovery`. |
| Bounded Retry and Terminal Failure Finalization | 12/8 protocol; exact pending/active classifier; alerts/runbook | First entry at >=8 after pre-handler retries; every pending guard field/mismatch; live owner; expired takeover; terminal idempotency; 8-11 failed/committed terminalization. |
| Operation Invariants | Full tuple CAS and invariant table | Per-field mutation/property tests + true concurrency/takeover emulator. |
| Application Audit and Observability Contract | Audit schema; atomic transition writes; PII policy | Dedup/atomicity emulator + denial-before-mutation + log/audit forbidden-field scans. |
| Client Provisioning Migration | Riverpod polling/persistence flow | Dart unit/widget restart/cancel/backoff/terminal UX + structural direct-flow absence. |
| Explicit Non-Goals and Compatibility | Scope, sweeper limits, rollback/outage boundary | Structural review: sweeper only repairs enqueue; no deploy/delete/email/exactly-once/client-liveness or permanent-multi-service-autonomy claim. |
| Client-Side Write Denial | Rules after backend/client slices | Firestore rules emulator: client create/privileged mutation denied, Admin SDK succeeds. |
| Current-Tree Credential and PII Removal | Existing later sanitization units | Repository secret/PII/claim scan. |
| Generic Organization Data | Existing de-branding unit | Structural metadata scan retaining `controlhorario-rega`. |
| Release Signing Enforcement | Existing signing unit | Release fail-fast test + ignore-rule inspection. |
| Protected Path Immutability | Existing path guards | Before/after byte hashes for all three protected paths. |
| Repository-Only Portfolio Presentation | Existing README/archive unit | Claim scan + `docs/archive/` absence. |
| Publication Gate Visibility | Existing final docs unit | Structural documentation proof for all three gates; local test commands remain independent. |

## Risks and Operational Controls

| Risk | Control |
|---|---|
| Auth returned success but proof commit is lost | Dual reads inform diagnosis only; missing durable proof terminalizes `manual_recovery`, never create retry/delete. |
| Firestore unavailable through all task attempts | Reserved attempts retry terminalization; platform metrics alert; runbook owns nonterminal recovery. |
| Eventarc exhausts before task creation | Five-minute bounded repair scans `enqueued=false` after 10-minute grace; stale-age/trigger/sweeper alerts and operator runbook cover multi-service outage. |
| Trigger/sweeper/task duplicate or reordering | Shared deterministic task ID, guarded acknowledgement, `ALREADY_EXISTS` acceptance, current-dispatch/full-CAS fencing. |
| Lease overlap or clock skew | Firestore server time only, 60-second leases, generation fencing, true concurrency tests. |
| Reset link exposure | Generate after integrity, return only over protected callable, never persist/log/audit/email. |
| Complexity and reviewer fatigue | Independent model first, eleven <=400-line chained slices, 3,050-3,880 honest forecast, tasks reconciliation gate. |
| IAM or queue metadata drift | Structural export/config tests, least-privilege service accounts, no production action in repository preparation. |

## Open Questions

None block task planning. Queue rate limits and exact region names are deployment-environment values to be recorded as reviewed metadata, not guessed or provisioned during repository preparation.
