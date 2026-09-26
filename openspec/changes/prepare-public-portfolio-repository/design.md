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
| `consumedDelivery` | Initially null; optional immutable `{ownerToken,generation,version,leaseExpiresAt,recordedAt}` recording an intentional competing-owner 2xx decision, not queue receipt. A worker may create it only in a transaction rereading this unacknowledged current dispatch and the exact active operation identity/full CAS tuple with a foreign live lease; the marker copies that observed fence and server time. Same-fence replay preserves it byte-for-byte; a different fence cannot overwrite it. It is evidence of the decision to return 2xx, not proof that the response reached Cloud Tasks. |
| `workerAck`, `workerAckAt` | Initially null; only worker-owned terminal dispatch result: `processed|stale|terminalized`. |
| `createdAt` | Immutable server timestamp. |

Identity fields never change. Enqueue acknowledgement, immutable consumed-delivery marker insertion, and worker acknowledgement are the only legal updates. The marker is not `workerAck` and cannot stand in for an effect/result transaction. A transition creates exactly one next dispatch with deterministic create-if-absent semantics.

### `/provisioningAudit/{eventId}`

Required immutable fields are `schemaVersion,eventId,operationId|null,correlationId,category,stage,outcome,code,actorUidDigest|null,intendedUidDigest|null,dispatchId|null,generation|null,sourceVersion|null,createdAt`. Categories are exactly `authorization | progress | success | failure`; required families are denial, state transition, Auth intent/result, terminal success, terminal failure/manual recovery, stale delivery, and completed-integrity failure. Events are create-if-absent and immutable; an existing ID must match all identity fields. App Check rejection before handler entry is the sole application-audit exception.

### `/users/{intendedUid}` provisioning provenance

The existing employee fields remain, but backend-created profiles also require immutable `userId,email,provisioningOperationId,provisioningFingerprint,provisioningSchemaVersion,provisionedBy:"trusted-backend",provisionedAt`. `email` is normalized; `userId` equals the document ID and intended UID. A profile is operation-matching only when UID, normalized email, operation ID, fingerprint, schema version, and every normalized profile field match. Provenance proves profile origin, not Auth ownership.

### Indexes

Saga phase correctness uses direct document reads. `firestore.indexes.json` adds operations `(status ASC, updatedAt ASC)`, operations `(status ASC, phase ASC, leaseExpiresAt ASC)`, dispatches `(operationId ASC, createdAt ASC)`, audit `(operationId ASC, createdAt ASC)`, and the correctness-critical sweeper query index `(enqueued ASC, createdAt ASC, __name__ ASC)`. The sweeper queries exactly `enqueued == false AND createdAt <= serverNow-10m`, ordered by `createdAt,__name__`, with cursor pagination.

## Full CAS and Lease Contract

For every active mutation, the transaction reads server time and requires equality of `fingerprint,status,phase,generation,version,ownerToken,currentDispatchId` plus `leaseExpiresAt > serverNow`. It also verifies the current dispatch's immutable `operationId,fingerprint,boundary,generation,sourceVersion` as the issuance identity; after acquisition/takeover, the operation's freshly read full tuple is the mutation CAS while `currentDispatchId` fences stale dispatches. The write increments `version` exactly once. No Auth/profile mutation starts after this predicate fails.

Initial acquisition requires `pending/dispatch_pending`, exact fingerprint, `generation=0`, `version=0`, `ownerToken=null`, `leaseExpiresAt=null`, `authAttempted=false`, and the exact unacknowledged initial `acquire` dispatch. One transaction sets `active/auth_preflight`, owner token, lease `serverNow+60s`, increments version, creates the matching `auth_preflight` dispatch, audits the transition, and acknowledges the `acquire` dispatch; that invocation yields. Same-dispatch continuation requires the full live tuple. Takeover requires the full observed tuple, same current dispatch, and `leaseExpiresAt <= serverNow`; it increments generation and version, derives a new fencing token from dispatch ID plus new generation, and sets a 60-second lease. The invocation then must reread and use that exact new full active tuple before any transition. A stale generation/version, wrong owner, wrong dispatch, terminal status, or expired lease on a non-takeover mutation produces no write or side effect. Terminalization clears owner/lease, sets phase `terminal`, and preserves immutable/failure fields.

### ACCEPTED DESIGN — initial lease-acquisition audit (maintainer confirmed)

**Status/gate.** The maintainer accepted this exact audit and acquisition contract. It authorizes normative planning and later apply, but is not implementation or deployment evidence. The accepted stale-delivery mapping remains unchanged.

| `AuditEvent` field | Exact normative value | Rationale |
|---|---|---|
| `schemaVersion` | `1` | Reuses the current schema. |
| `eventId` | `deriveAuditEventId(operation.operationId, "progress", "state_transition", sourceDispatch.generation, sourceDispatch.sourceVersion)` | Binds replay to the immutable acquisition source tuple. |
| `operationId` | Transaction-reread `operation.operationId` | This is the submitted lower-case UUID-v4 persisted by `submit.ts`. |
| `correlationId` | `hexSha256("provision-correlation:v1\0" + operation.operationId)` | Reuses the already-approved per-operation correlation derivation. |
| `category` | `"progress"` | Acquisition is nonterminal progress. |
| `stage` | `"state_transition"` | This is the existing generic transition stage, not Auth intent. |
| `outcome` | `"started"` | Existing vocabulary exactly describes entry into active work. |
| `code` | `"success"` | Accepted existing generic successful-transition code; `"auth-intent"` would describe the wrong phase. |
| `actorUidDigest` | `null` | The worker is the system actor; request attribution would be misleading. |
| `intendedUidDigest` | `null` | Acquisition needs no subject identity and remains PII-minimal. |
| `dispatchId` | Transaction-reread `sourceDispatch.dispatchId` | Records the trusted acquisition dispatch digest. |
| `generation` | `sourceDispatch.generation` (`0`) | Records immutable source generation, not resulting state. |
| `sourceVersion` | `sourceDispatch.sourceVersion` (`0`) | Records immutable source version, not resulting operation `version=1`. |
| `createdAt` | Transaction `now` on first insertion | Matching replay preserves existing time through current dedup semantics. |

**Atomic transaction and data flow.** Read the operation, source dispatch, candidate audit ID, and next-dispatch ID before writes. Require the exact submitted pending state, including definitive persisted `currentDispatchId=null`, and source `acquire/g=0/sv=0`, `workerAck=null`, deterministic dispatch identity, plus `sourceDispatch.ownerSeed===deriveOwnerToken(sourceDispatch.dispatchId,0)`. At one transaction `now`, commit source `workerAck="processed"/workerAckAt=now`; operation `active/auth_preflight,generation=0,version=1,ownerToken=deriveOwnerToken(sourceDispatch.dispatchId,0),leaseExpiresAt=now+60000,updatedAt=now,currentDispatchId=nextDispatchId`; the accepted audit; and create-if-absent `auth_preflight/g=0/sourceVersion=1` next dispatch with deterministic `dispatchId===taskId` and copied operation/fingerprint identity. The pure `acquire` reducer correctly leaves the initial null pointer unchanged; the persistence adapter assigns the next pointer in this full commit.

**Failure/concurrency boundary.** Any audit identity mismatch, existing conflicting next dispatch, failed create, or failed CAS rolls back every write. Contention permits one winner; replay verifies matching immutable records and preserves the original audit `createdAt`. This unit performs no takeover, Auth read/call, profile effect, or stale-delivery remapping.

**Collision analysis.** The accepted ID uses acquisition source `g0/v0`, while the resulting dispatch is `g0/v1`, preventing collision with currently defined later `progress/state_transition` events sourced from monotonically later versions. `deriveAuditEventId` does not include boundary, so this is not a universal uniqueness claim for unknown future transitions; any future same-category/stage reuse at the same generation/sourceVersion must be rejected or separately designed before vocabulary expansion.

**Planning implication.** Audit construction, read/dedup, atomic conflict, replay, and one-winner coverage invalidate the operative use of the historical `289–370` acquisition estimate. A bounded planning pass must reforecast from CodeGraph-supported actual source context before apply; until then, fit under the existing line limits is unasserted. No audit-field choice remains open.

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
5. Apply the accepted B-2 terminal policy: a terminal state plus any operation-transition event returns `terminal_state`; `ack_dispatch` is excluded and remains unsupported by the pure reducer because P2/P3 own acknowledgement persistence. For a nonterminal event that can mutate in P1a2-ii, compare all eight expected fields to current state. Any inequality returns `cas_mismatch`. At the lease stage, active non-takeover mutations require non-null `state.leaseExpiresAt > observedAt`; takeover instead requires non-null `state.leaseExpiresAt <= observedAt`; a failed applicable predicate returns `lease_not_live`.
6. Dispatch supported behavior. In B-1 every boundary/terminalization event remains unsupported after a live CAS and returns `unsupported_event`; stale, malformed, terminal, and unsupported paths are all non-mutating. P1a2-ii adds only the representable matrix below behind the same gate.

Failure codes above are stable literal reasons and deeply frozen. Precedence is state -> request -> expected -> event -> terminal policy -> CAS equality -> lease liveness -> event dispatch. A failed predicate never calls a transition helper, increments counters, or changes nested data.

| Alternative | Tradeoff | Decision |
|---|---|---|
| Selected event envelope (`ReducerRequest`) | Keeps two arguments and gives adapters one atomic command value; adds one narrow carrier type and changes planned callers. | Selected. CAS metadata stays beside, never inside, business events. |
| Separate third argument | Small type, but `reduce(state,event,expected)` can split event/time/expectation assembly and requires a fourth value or hidden clock for liveness. | Rejected. |
| Expectations embedded in state | Conflates authoritative current data with caller preconditions and risks persisting transient command metadata. | Rejected. |
| Self-comparison | No independent precondition; always “proves” equality and falsely claims CAS. | Forbidden. |

B-1 RED must prove: old `reduce(state,event)` is compile-rejected; the exact request compiles; each expected field independently mismatches through `reduce()`; an exact tuple reaches `unsupported_event`; exact-but-expired and active-null leases return `lease_not_live`; malformed/missing/extra envelope and expectation fields fail closed; existing per-event missing/extra payload probes remain green; and every failure leaves the complete input state byte-identical. Explicit source+test TypeScript and source-only `npx tsc --noEmit` remain mandatory, including `@ts-expect-error` probes for the old signature and missing/extra expected fields.

The accepted B-2 slice remains the terminal-rejection boundary. P1a2-ii supplies expectations from transaction issuance snapshots for representable transitions only. Reserved terminalization no longer has a pure-model slice. The four implementation/planning paths remain `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, `tasks.md`, and `apply-progress.md`; this amendment changes only `design.md`, and the next `sdd-tasks` phase must replan ii/iii without changing apply progress in this phase.

### P1a2 post-B-2 amendment: exact pure lifecycle contract

The maintainer selected **Conservar modelo puro**, then authorized **Corregir contrato**. The accepted `OperationState`, `ModelEvent`, `ReducerRequest`, `TransitionResult`, and public API remain frozen. This amendment makes the eight existing success branches exact; it adds no product behavior, field, event, result, failure reason, persistence claim, or external observation.

#### Common gate and output rules

Precedence remains `state -> request -> expected -> event -> terminal policy -> CAS -> lease -> dispatch`. Existing failures remain `invalid_state`, `invalid_request`, `invalid_expected`, `invalid_event`, `terminal_state`, `cas_mismatch`, and `lease_not_live`. The pre-ii guard-refinement slice below rejects incoherent persisted Auth lifecycle combinations as `invalid_state`; after that state gate, a canonical state whose requested transition does not meet the event-specific predicate below returns existing `unsupported_event`. Every failure is deeply frozen and leaves state/request/event byte- and reference-identical. No new reason is authorized.

CAS compares all eight accepted fields for every success. Lease applicability is event-specific at the existing lease stage: `acquire` requires no prior lease but requires payload `leaseExpiresAt > observedAt`; `takeover` requires prior `leaseExpiresAt <= observedAt` and payload `leaseExpiresAt > observedAt`; the other six require a non-null live lease `> observedAt`. Every success sets `updatedAt=observedAt`, increments `version` exactly once, preserves `operationId`, `fingerprint`, `normalizedPayload`, `intendedUid`, `createdAt`, and `currentDispatchId`, and preserves `generation` except takeover. Fields not explicitly changed below are immutable. Terminal results clear `ownerToken` and `leaseExpiresAt`; they do not acknowledge a dispatch.

#### P1a2-i-C — AuthAttempt Lifecycle Guard Refinement (maintainer-authorized pre-ii slice)

This bounded slice branches from accepted B-2 and must be independently accepted before P1a2-ii. It adds no field, type, event, result, reason, product behavior, persistence read/write, effect, lease/CAS/dispatch behavior, or P2/P3 ownership. Future apply may modify only `functions/src/provisioning/model.ts` (`isAuthAttempt`/`isValidState`), `functions/test/provisioning/model.test.ts` (guard/regression vectors), `tasks.md`, and `apply-progress.md`.

Shape aliases use only existing fields: `Ø = authAttempted:false/authAttempt:null`; every non-null attempt requires `authAttempted:true` and non-null `intendedUid`. `I=intent` requires null `callStartedAt`, returned fields, and proof. `C=call_started`, `D=definite_no_effect`, and `A=ambiguous` require non-null `callStartedAt` and null returned fields/proof. `K=confirmed` requires non-null `callStartedAt`, returned fields, and proof, with `proof.attemptId=attemptId`, `returnedUid=proof.uidRead=intendedUid`, and `returnedEmail=proof.emailRead=normalizedPayload.email`. Existing scalar, exact-field, timestamp, UID, email, and proof guards still apply; no new timestamp ordering is inferred.

| Canonical status/phase | Complete admitted Auth lifecycle set | Normative use |
|---|---|---|
| `pending/dispatch_pending` | `Ø` | Initial and exact pending terminalization input. |
| `active/auth_preflight` | `Ø`, `D` | Before intent, or retained proven-no-effect result awaiting retry/takeover. |
| `active/auth_create` | `I`, `C` | Persisted intent or call-started boundary. |
| `active/profile_commit` | `K` | Confirmed Auth ownership before profile commit. |
| `completed/terminal` | `K` | Confirmed completion; completed integrity failure never rewrites it. |
| `failed/terminal` | `Ø`, `D` | Foreign/pre-attempt failure or terminal failure with effect definitely absent. |
| `manual_recovery/terminal` | `I`, `C`, `D`, `K`, `A` | Post-attempt uncertainty, exhaustion, conflict, or explicit ambiguity; no false/null pre-attempt form. |

This is the complete finite canonical matrix. In particular, active takeover retention is exactly five rows: `auth_preflight×{Ø,D}`, `auth_create×{I,C}`, and `profile_commit×{K}`. `A` is terminal-only. P1a2-ii must depend on independently accepted P1a2-i-C and enumerate takeover only over those five active rows, not a phase/result Cartesian product. P3 may consume the terminal rows for definite-no-effect terminal failure, ambiguity/manual recovery, foreign-user failure, confirmed-profile conflict/manual recovery, and confirmed completion; it may not invent another lifecycle combination.

Invalid-state families are exhaustive: (1) any noncanonical status/phase pair; (2) `authAttempted=false` with a non-null attempt or `true` with null; (3) any attempt while `intendedUid=null`; (4) any variant with a required-null field non-null or required-non-null field null; (5) a confirmed proof/return/attempt/UID/email correlation break; (6) any phase-incompatible variant, including active ambiguity; and (7) any terminal-incompatible variant, including pending attempts, completed non-confirmed states, failed intent/call-started/confirmed/ambiguous states, or manual-recovery `Ø`. Certification examples `pending+false+confirmed`, `attempted=true+null`, and `confirmed+null proof` are rejected at state validation with existing `invalid_state`, before request, event, terminal policy, CAS, lease, dispatch, or any effect.

Strict TDD is RED→GREEN→REFACTOR. RED independently declares the seven-row positive matrix and generates the finite complement across all seven status/phase rows, `Ø/I/C/D/K/A`, boolean/null contradictions, every per-variant nullability bit, and each confirmed correlation edge; expected validity is a test-owned literal table, never derived from production. GREEN makes the narrow guard correlation change. REFACTOR reruns all inherited source+test TypeScript and Node model harnesses. Every rejection proves complete state/request/event snapshot and reference retention, no mutation, no result graph retention, and `invalid_state` precedence; every admitted row proves exact retention. Accepted states that remain valid include pending `Ø`, active preflight `Ø`, and failed/terminal `Ø`. The accepted guard probes intentionally reclassified as incoherent are exactly the pending `false+confirmed` “valid nested Auth boundary” control and its returned-UID-128, returned-UID-null, and proof-UID-128 positives. Replace the confirmed positives with `active/profile_commit+K` fixtures whose intended, returned, proof UID, attempt ID, and email correlations remain valid while the tested scalar boundary varies; replace the nullable-return positive with `active/auth_preflight+D`, whose returned fields and proof are canonically required null. These are fixture-construction corrections, not production-behavior changes.

Complete B-2 regression remains mandatory. Its helper-derived `completed/terminal+Ø` and `manual_recovery/terminal+Ø` vectors are also intentionally reclassified as incoherent and must reach `invalid_state` before terminal policy; the 14 `failed/terminal+Ø` vectors remain canonical and unchanged. Reconstruct the status-specific helper with `completed/terminal+K` using valid confirmed proof/attempt/UID/email correlations, `failed/terminal+Ø`, and `manual_recovery/terminal+A`. `A` is the exact manual-recovery alias because it represents post-call uncertainty, requires no returned identity/proof, and has no state-to-event/payload correlation in the accepted reducer gate, so it does not couple any B-2 event-independence control to lifecycle validation. The count remains truthfully 42: 33 non-ack terminal-policy controls plus three stale-expected terminal-policy controls, the three inherited malformed request/expected/event precedence controls, and three terminal `ack_dispatch` controls. Reprove their exact accepted outcomes (`terminal_state`, `invalid_request`/`invalid_expected`/`invalid_event`, or `unsupported_event`, respectively), precedence, complete no-mutation and graph-detachment guarantees, event/payload independence, and terminal-policy coverage over canonical valid terminal states. No accepted B-2 terminal rejection semantic or production behavior is lost; only invalid test states stop masquerading as terminal-policy inputs.

Forecast: 220–340 changed lines; early warning 300, STOP/reforecast 350, absolute max 400, no size exception or borrowing. Rollback removes only P1a2-i-C guard/tests/bookkeeping and restores accepted B-2 exactly. The next tasks phase must insert this dependency and reforecast P1a2-ii/transitive totals; this design phase does not edit task records.

#### Exact eight-event matrix

| Event | Exact admitted input and correlations | Exact pure output |
|---|---|---|
| `acquire` | `pending/dispatch_pending`; `generation=0`, `version=0`, `ownerToken=null`, `leaseExpiresAt=null`, `authAttempted=false`, `authAttempt=null`; exact CAS; payload owner is a valid token and payload lease is live. | `active/auth_preflight`; install payload owner/lease; preserve `generation=0`; `version=1`; Auth fields remain false/null. |
| `takeover` | Any of the five canonical active P1a2-i-C rows, preserved verbatim; exact CAS; expired prior lease; payload owner differs from prior owner and payload lease is live. | Preserve status, phase, and AuthAttempt; replace owner/lease; `generation+1`, `version+1`. |
| `auth_intent` | Exactly `active/auth_preflight`; live lease; `authAttempted=false`, `authAttempt=null`; `intendedUid` is non-null; payload supplies the new attempt identity/time. | Exactly `active/auth_create`; `authAttempted=true`; `authAttempt={attemptId, intentAt, callStartedAt:null, result:"intent", returnedUid:null, returnedEmail:null, proof:null}` from payload; `version+1`. |
| `auth_start` | Exactly `active/auth_create`; live lease; `authAttempted=true`; exact intent-shaped attempt above; payload `attemptId===authAttempt.attemptId`. | Remain `active/auth_create`; preserve attemptId/intentAt; set payload `callStartedAt`, `result="call_started"`; returned fields/proof remain null; `version+1`. |
| `auth_confirm` | Exactly `active/auth_create`; live lease; `authAttempted=true`; matching call-started attempt with non-null `callStartedAt`, null returned fields/proof, and payload `attemptId===authAttempt.attemptId===payload.proof.attemptId`; require `payload.returnedUid===payload.proof.uidRead===state.intendedUid` and `payload.returnedEmail===payload.proof.emailRead===state.normalizedPayload.email`. Direct intent confirmation is forbidden. | Exactly `active/profile_commit`; preserve attemptId/intentAt/callStartedAt; set `result="confirmed"`, returned fields, and proof exactly from payload; `version+1`. |
| `auth_ambiguous` | Exactly `active/auth_create`; live lease; `authAttempted=true`; the sole admitted unproven in-flight shape is matching `call_started` with non-null callStartedAt and null returned fields/proof; payload attemptId must match. Confirmed/proven, intent, definite-no-effect, already-ambiguous, or mismatched attempts are rejected. Payload code is selected upstream and is not persisted by this vocabulary. | Exactly `manual_recovery/terminal`; preserve attempt identity/times; set only `result="ambiguous"`; returned fields/proof remain null; clear owner/lease; `version+1`. |
| `auth_foreign_user` | Exactly `active/auth_preflight`; live lease; `authAttempted=false`, `authAttempt=null`; non-null intended UID; require `payload.uid!==state.intendedUid || payload.email!==state.normalizedPayload.email`. A payload matching both intended UID and normalized target email is not foreign and is rejected. | Exactly `failed/terminal`; Auth fields remain false/null; clear owner/lease; `version+1`. No payload identity is copied into state. |
| `profile_commit` | Exactly `active/profile_commit`; live lease; `authAttempted=true`; matching confirmed attempt with non-null callStartedAt/returned fields/proof; require `payload.userId===returnedUid===proof.uidRead===state.intendedUid`, `returnedEmail===proof.emailRead===state.normalizedPayload.email`, and `proof.attemptId===authAttempt.attemptId`. | Exactly `completed/terminal`; confirmed attempt/proof remains byte-identical; clear owner/lease; `version+1`. This is only a candidate state. |

All six named Auth/profile output pairs are canonical: `auth_intent` and `auth_start` -> `active/auth_create`; `auth_confirm` -> `active/profile_commit`; `auth_ambiguous` -> `manual_recovery/terminal`; `auth_foreign_user` -> `failed/terminal`; `profile_commit` -> `completed/terminal`. `auth_preflight`, `auth_no_effect`, `ack_dispatch`, and `terminalize` remain `unsupported_event` with no success path or version change. Explicit crash/read events do not exist and MUST NOT be simulated.

#### Mandatory honest-RED negative families for the next tasks amendment

Tasks must add independently authored vectors for: every event from each wrong status/phase; CAS and applicable live/expired/null lease edges; acquire non-initial fields and takeover live lease/same owner; Auth flag/null/result-shape contradictions; every matching/mismatched attemptId edge; direct-intent confirmation; each UID equality link and each email equality link broken independently; confirmation with absent/proven-before-call/malformed proof; ambiguity from intent, confirmed, definite-no-effect, ambiguous, any proof/returned identity, and mismatched ID; foreign-user after any attempt and the exact both-identities-match non-foreign payload (plus one-inequality positive controls); profile completion with absent proof, wrong result, each userId/returned/proof/intended UID link broken independently, and each returned/proof/normalized-email link broken independently. Add output vectors for all canonical pairs, exact AuthAttempt shapes, terminal owner/lease clearing, version `+1`, takeover-only generation `+1`, immutable common fields, confirmed-proof preservation, and all four unsupported events. Every negative vector must assert the stable inherited reason by precedence and complete no-mutation/no-retention; lifecycle/correlation misses specifically expect `unsupported_event`.

P1a2-iii remains retired/reassigned in full. P2 retains schemas, audit/full-dispatch identity, enqueue/worker-ack foundations, and create-if-absent semantics. P3 owns external reads, crash reconstruction, delivery classification, retry/terminalization, codes/evidence, and persisted no-regression. Completion Atomic Commitment remains P3's atomic profile/provenance + operation completion + success audit + worker-ack write; a pure `profile_commit` success never proves persistence. The next phase replans tasks so P1a2-i-C sits between accepted B-2 and P1a2-ii; rollback of ii returns to independently accepted P1a2-i-C, while rollback of P1a2-i-C returns to accepted B-2 without touching P2/P3.

## P3-B.2a amendment: trusted persisted delivery classifier

**Decision.** `classifyProvisioningDelivery` is the single authoritative classifier vocabulary: `eligible | stale_eligible | orphan | duplicate | terminal | mismatch | malformed | corrupt`. No second stale predicate is permitted. `malformed` means the exact plain-data envelope or a record fails structural/schema validation (including extra/symbol/accessor/class/polluted-prototype fields or any reflective/Proxy exception). `corrupt` is the narrower valid-field-domain case whose persisted dispatch self-identity is impossible (`document ID != dispatchId`, `taskId != dispatchId`, or deterministic ID != the immutable operation/boundary/generation/sourceVersion tuple). This deliberately reclassifies task-ID self-conflict from the current `isValidDispatch`-driven `malformed` result; other malformed inputs do not become corrupt. `mismatch` means individually valid snapshots do not describe the same delivery/operation or fail the temporal table below.

A pure call has no authority. `eligible` and `stale_eligible` are candidates only. Authority requires the exact `/provisioningDispatch/{deliveryDispatchId}` snapshot reread inside the same Firestore transaction as its `/provisioningOperations/{dispatch.operationId}` snapshot, from collections clients cannot write. The transaction reruns this same classifier before any write. The delivery ID, Firestore document ID, embedded `dispatchId`, `taskId`, and deterministic ID must all agree; operation ID and immutable fingerprint must agree. Only a successful authoritative snapshot reporting nonexistence is `orphan`; retrieval/transaction errors propagate and authorize nothing. A deterministic ID or arbitrary caller-built object alone never proves issuance. No extra transition or audit provenance is required.

Existing evidence establishes only part of this premise: `persistInitialSubmission` specifies atomic create-if-absent operation/initial-dispatch writes (`functions/src/provisioning/submit.ts`), `FirestoreWorkerTransaction.createDispatch` uses Firestore transaction `create` (`functions/src/provisioning/boundaries.ts`), and the catch-all Firestore rule denies client access to the otherwise-unmatched provisioning collections (`firestore.rules`). Production `submitProvisioning` and dispatch runtime composition still throw `unimplemented`/fail closed (`functions/src/index.ts`), and repository IAM bindings are declarative placeholders. Therefore P3-B.2a MUST NOT claim trusted creation is production-proven; downstream persistence remains blocked until tests prove every reachable creation path uses those backend create-if-absent transactions and clients cannot create/update/delete either collection.

Precedence is exact: malformed request; missing dispatch=`orphan`; malformed dispatch; corrupt dispatch self-identity; missing operation=`orphan`; malformed operation; delivery/operation identity `mismatch`; matching terminal operation=`terminal`; non-null `workerAck`=`duplicate`; then the temporal table. Every result is pure and no-write; only a transaction-authoritative `stale_eligible` may later permit the separate stale-ack/audit unit.

| Canonical operation and trusted unacknowledged dispatch relation | Result |
|---|---|
| Pending exact initial tuple: `pending/dispatch_pending`, operation `g=0,v=0`, null owner/lease/current ID and no Auth attempt; dispatch `acquire,g=0,sv=0`; equal creation/update time | `eligible` |
| Pending with any other boundary/generation/sourceVersion or timestamp relation | `mismatch` (impossible/future/unknown; no legal pending stale relation) |
| Active; dispatch ID is current, boundary equals phase, timestamps are within the operation lifetime, and relation is exact `dg=og,sv=ov`, same-generation retained `dg=og,sv<ov`, or takeover-retained `dg<og,sv<ov` | `eligible` |
| Active; dispatch is not current and `dg=og,sv<ov` or `dg<og,sv<ov`, with `operation.createdAt <= dispatch.createdAt <= operation.updatedAt` | `stale_eligible` |
| Active; `dg>og`, `sv>ov`, mixed `dg<og && sv>=ov`, or dispatch timestamp outside the operation lifetime | `mismatch` (future/impossible/unknown) |
| Active; `dg=og,sv=ov` but wrong current ID, or any candidate with wrong boundary/phase | `mismatch` (same-version fork or boundary fork is impossible) |
| Matching terminal operation, including an old dispatch; or matching nonterminal dispatch already acknowledged | `terminal` or `duplicate` by precedence; never stale-write eligible |

Here `dg/og` are dispatch/operation generation and `sv/ov` are sourceVersion/operation version. Arithmetic only establishes temporal coherence after trusted persisted issuance; it never establishes issuance itself. Immutable operation fingerprint/ID and dispatch identity stay exact across all rows. No legal relation inferred by this state machine is classified stale merely because “something differs”; an unlisted relation is `mismatch` and no-write.

Implementation/testing implication: the current pure classifier and six-test fixture do not encode document-reference trust, timestamp coherence, or all generation/version quadrants. P3-B.2a must add an adapter-owned trusted-snapshot envelope (without exposing a new unauthenticated caller API), descriptor-safe exception vectors, every table boundary, purity/reference retention, and a structural proof that no competing stale predicate exists. The historical 195–337 estimate is preserved but not reverified; apply must reforecast this expanded contract before code and use the already-approved feature-branch-chain strategy if it threatens 400 lines.

### ACCEPTED DESIGN — stale-delivery audit derivation (maintainer confirmed)

**Status/gate.** The maintainer accepted this exact completion of the previously unresolved field semantics. A transaction-authoritative `stale_eligible` result creates exactly this immutable `progress/stale_delivery` event while acknowledging only that dispatch; this decision authorizes planning and later apply, not an implementation or deployment claim.

| `AuditEvent` field | Normative derivation | Rationale |
|---|---|---|
| `schemaVersion` | `1` | Existing audit schema version. |
| `eventId` | `deriveAuditEventId(operation.operationId, "progress", "stale_delivery", dispatch.generation, dispatch.sourceVersion)` | Existing exact `provision-audit:v1` identity; immutable dispatch tuple makes replay stable and later operation generations/versions irrelevant. |
| `operationId` | Trusted transaction-reread `operation.operationId` | Links the event without exposing payload data. |
| `correlationId` | `hexSha256("provision-correlation:v1\0" + operation.operationId)` | Deterministic per operation and explicitly namespaced; it is not an application-log digest-domain tag, so no log-domain allowlist expansion is proposed. |
| `category` | `"progress"` | Existing category for nonterminal delivery handling. |
| `stage` | `"stale_delivery"` | Existing audit stage. |
| `outcome` | `"stale"` | Existing outcome vocabulary. |
| `code` | `"stale-dispatch"` | Existing stable code. |
| `actorUidDigest` | `null` | The worker is the actor; copying `submittedByDigest` would misattribute the submitting admin. |
| `intendedUidDigest` | `null` | Stale acknowledgement does not need subject identity; minimize linkable PII. |
| `dispatchId` | Trusted immutable `dispatch.dispatchId` | Identifies the acknowledged delivery and is already a digest. |
| `generation` | Trusted immutable `dispatch.generation` | Records issuance identity, not the newer operation value. |
| `sourceVersion` | Trusted immutable `dispatch.sourceVersion` | Records issuance identity, not the newer operation value. |
| `createdAt` | Transaction clock on the first successful insert | Timestamp is write evidence, not logical identity; replay preserves the existing event and its original time. |

**Hash/port evidence.** `ids.ts` already hashes UTF-8 strings with NUL-separated `provision-audit:v1` and exports the exact event-ID helper above; `authz.ts` proves actor digests use `hexSha256("provision-actor:v1\0" + uid)` while correlation arrives as an external 64-hex digest. `submit.ts` persists `submittedByDigest` and raw server-generated `intendedUid`, but neither is needed for this system event. `audit.ts` currently validates digest/null shape only, and `deduplicateAudit` compares every field except `createdAt`. `WorkerTransaction` exposes transaction time plus `readAudit`/`createAudit`, supporting create-if-absent without audit rewrite.

**Real alternative considered.** Reusing `operationId` directly is invalid because `correlationId` requires a 64-hex digest; using `submittedByDigest` would conflate request attribution with operation correlation. A random per-delivery correlation would also break deterministic replay. The accepted namespace is therefore local derivation semantics, not a new domain allowlist or raw identifier.

**PII boundary.** No raw UID, email, name, DNI, telephone, request body, reset link, SDK message, `submittedByDigest`, or `intendedUid` is copied into this event. Same-dispatch replay must compare all fields except `createdAt`, preserve an existing matching event byte-for-byte, and fail closed on any mismatch; no audit document is rewritten.

**Maintainer decision.** Confirmed exactly: `correlationId=hexSha256("provision-correlation:v1\0" + operationId)`, both actor/subject digests are null, dispatch generation/sourceVersion drive immutable event identity, and transaction `now` supplies only a first-insert candidate `createdAt`; matching replay preserves the existing event unchanged.

**Approved coverage replacement.** The real Firestore conflict vector stages `writeDispatch(workerAck:"stale")` then `createAudit` against an already-existing audit without first reading that audit, and asserts Firestore `ALREADY_EXISTS` (code 6) rejects the commit with dispatch and audit bytes unchanged. It replaces the deadlocking externally coordinated post-read interleaving; this proves adapter commit atomicity, while the retained `Promise.all` worker test separately proves worker-level replay convergence.

## Boundary and Crash Protocol

### Submission transaction

After App Check, authentication, admin lookup, and schema normalization, one Firestore transaction creates the operation in `pending/dispatch_pending` and initial `acquire` dispatch. Same `(operationId,fingerprint)` returns its current safe status; a different fingerprint returns `already-exists` without mutation. Firestore can make these two documents atomic. Submission cannot be atomic with Auth or Cloud Tasks and intentionally calls neither.

### Outbox enqueue

The retry-enabled `onDocumentCreated` handler validates immutable dispatch shape and calls `enqueueDispatch(dispatch)`. Enqueue and Firestore acknowledgement cannot share a transaction. Crash before enqueue causes event retry; crash after enqueue causes `ALREADY_EXISTS`, which is accepted. Success or `ALREADY_EXISTS` is followed by one guarded transaction requiring exact dispatch identity and `enqueued=false`; it sets `enqueued=true`, `enqueuedAt=serverNow`, source/event digest, and nothing else. If a race already committed the same acknowledgement, the handler succeeds; identity mismatch fails closed. Other errors emit only PII-safe operation/dispatch digests and throw.

### Scheduled outbox repair

`repairProvisioningOutbox` is a first-slice `onSchedule` function running every 5 minutes with scheduler retries `retryCount=3`, `minBackoffSeconds=30`, `maxBackoffSeconds=300`, and `maxDoublings=2`. Each run computes `cutoff=serverNow-10m` and scans only `enqueued=false AND createdAt<=cutoff`, ordered by `createdAt,__name__`, in pages of 100, at most five pages/500 dispatches per run. It uses at most 10 concurrent enqueue calls and a 25-enqueues/second limiter; `maxInstances=1` and `timeoutSeconds=240` bound overlap and cost.

For every record it validates immutable identity and calls the **same** `enqueueDispatch` adapter with the **same** deterministic task ID as the trigger. Enqueue success or `ALREADY_EXISTS` uses the same guarded acknowledgement transaction. Trigger+sweeper races are harmless: one enqueue wins, the other observes `ALREADY_EXISTS`, and either acknowledgement wins while the other verifies `enqueued=true`. Per-record failures log PII-safe operation/dispatch digests; the run processes its bounded page, then throws if any failed so Scheduler retry and the next regular schedule repair them.

The sweeper does not execute or classify saga phases, mutate Auth/profile/operation state, acknowledge worker completion, create dispatches, or invent alternate task identities. Trigger delivery remains the fast path; scheduled scanning repairs **enqueue only**. P3 separately owns recovery of consumed worker tasks for `enqueued=true` current dispatches; the P2 sweeper cannot recover them. If Eventarc, Scheduler, and Cloud Tasks are simultaneously unavailable beyond their retry windows, autonomy is not claimed: Monitoring alerts and the operator runbook restore dependencies, query the same stale index, and re-run the same repair handler/adapter. Operators never call a saga phase directly.

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
| Exact initial pending state | One transaction requires operation fingerprint, `status=pending`, `phase=dispatch_pending`, `generation=0`, `version=0`, `ownerToken=null`, `leaseExpiresAt=null`, `authAttempted=false`, `authAttempt=null`, and definitive persisted `currentDispatchId=null`, while the task separately identifies the exact initial dispatch. It also requires that dispatch's exact `operationId,fingerprint,boundary=acquire,generation=0,sourceVersion=0,workerAck=null`. It writes `failed/terminal`, `version=1`, `terminalCode=unavailable`, retry evidence, `failure.retry_exhausted_before_entry`, its deterministic failure audit, and current dispatch `workerAck=terminalized/workerAckAt=serverNow` atomically; no next dispatch. |
| Pending predicate mismatch | Do not infer safety or write. Reread operation+dispatch and reclassify as exact pending, active, or terminal; a second mismatch/CAS loss returns success with no mutation because another worker changed ownership/progress. |
| Active with exact current owner and live lease | Require the complete active CAS tuple and current dispatch identity. If durable evidence proves no Auth intent/effect (`authAttempted=false`, `authAttempt=null`, safe phase), atomically write `failed/unavailable`; otherwise atomically write `manual_recovery/internal`. In either case evidence, failure audit, owner/lease clear, and current ack commit together. |
| Active with another owner's unexpired lease | Do not steal or mutate. CAS loss/ownership classification returns success; durable P3 worker-recovery scanning must revisit this nonterminal current dispatch after the lease expires if its task was consumed. |
| Active with expired lease | First transaction requires the exact full observed expired tuple/current dispatch, increments generation+version, installs the deterministic new owner token and live lease. The same invocation (or its retry after authoritative reread) then applies the complete active terminalization guard above using the exact new tuple. If takeover or terminalization persistence is uncertain, reread; throw only when the guarded terminalization still belongs to this owner and did not commit. |
| Terminal operation | Return success without operation mutation or new audit. Existing dispatch acknowledgement is idempotent; no terminal state changes. |

The pending path is safe `failed/unavailable`, not `manual_recovery`, because every predicate proves no Auth intent/effect exists. Any missing/mismatched pending field destroys that proof. Active terminalization never steals an unexpired lease and never relies on TaskContext as ownership evidence.

Any terminalization CAS loss is success with no mutation: authoritative reread classifies it as another worker owning progress or an already-terminal operation. Returning success on a foreign live lease does not prove eventual progress: the independent P3 recovery path below must remain armed. Dependency/commit failure is distinct from CAS loss and throws only while this task still satisfies the exact guarded owner/current-dispatch predicate.

On every entered execution, advisory TaskContext maxima and any failure evidence are committed with the guarded state mutation. Firestore state, not headers, decides whether an effect intent/proof exists. Because pre-handler 5xx can increment `retryCount` without execution, a task's first handler entry can already have `retryCount>=8`; it immediately uses the pending classifier rather than attempting acquisition. Reserved values 8, 9, 10, and 11 repeat only these guarded terminalization paths. A failed terminalization transaction throws so the next reserved attempt retries it; a committed terminal state returns success.

**P3 consumed-delivery recovery (separate from ordinary takeover and P2 enqueue repair).** A scheduled, bounded P3 reconciler queries nonterminal operations with overdue leases or stalled current dispatches in stable indexed pages, capped page count/concurrency and a server-time watermark; it rereads both documents transactionally. On a foreign live owner, a worker returning 2xx must first insert the dispatch `consumedDelivery` marker under the exact current identity and full observed active CAS/live-lease fence. A failed marker commit forbids intentional 2xx. A crash before insertion leaves no marker and ordinary retry/takeover remains available; a crash after insertion but before the response leaves an idempotent marker even if Cloud Tasks retries, so this proves intent to consume, not observed queue consumption. A same-fence retry preserves the marker; a different live fence cannot rewrite it. Recovery may consider only a marker on the still-current dispatch after its recorded lease expires. Its saved fence identifies the earlier authorized decision, not the recovery write predicate: a legitimate owner may subsequently advance operation version on that same dispatch (for example `auth_create` intent `I` -> call-started `C`) without invalidating the marker. Transactionally reread the current operation and dispatch; require exact immutable identity, unchanged current pointer, marker provenance for that dispatch and a historically valid generation/version fence, monotonic same-dispatch version advancement, nonterminal status, and expired current lease. Reject a changed pointer, terminal state, impossible/untrusted temporal relation or newer live owner; a marker never substitutes for the fresh full observed CAS. Without a marker (including uncertain pre-handler 2xx), never claim proven consumption: use ordinary retry/takeover when available and alert on prolonged no-progress/exhaustion for operator intervention.

The recovery claim is a **takeover variant**, not a reducer phase transition: transactionally reread exact immutable dispatch identity, fingerprint, pointer, phase and full observed operation tuple, require expired lease and matching historical marker provenance against the freshly observed same-dispatch tuple, and increment generation and version exactly once, deriving a new fencing owner/60-second lease. Audit identity and source acknowledgement derive from the immutable *current source dispatch* tuple, not the older marker's saved operation version; create-if-absent audit conflicts abort the transaction. Only safe active phase/lifecycle pairs issue a replacement: `auth_preflight` with `Ø` or `D` -> `auth_preflight`; `auth_create` with `I` -> `auth_create` (the existing intent/attempt ID remains immutable; no new Auth intent is created); `profile_commit` with `K` -> `profile_commit`. The new immutable tuple is `boundary=phase`, `generation=old generation+1`, `sourceVersion=resulting operation version=old version+1`, `dispatchId=taskId=deriveDispatchId(operationId,boundary,generation,sourceVersion)`, `ownerSeed=deriveOwnerToken(dispatchId,generation)`, and the original operationId/fingerprint; enqueue fields start false/null and `workerAck/workerAckAt/consumedDelivery` start null. Its worker must prove this exact persisted current identity and live owner/lease before any boundary action. The claim transaction atomically advances the operation pointer, installs owner/lease, acknowledges the old current dispatch `processed` with server time as part of that real takeover-and-redispatch transition, and creates the new dispatch and immutable audit create-if-absent; any mismatch rolls back everything. The old marker remains evidence, never a worker result. No new dispatch is acknowledged before its own legal result transaction; each later transition acknowledges only its current source. Replay after pointer advance creates nothing and an old delivery cannot act.

`auth_create` with `C`, including an `I` marker followed by a same-dispatch `I` -> `C` version advance and crash, must never receive another `auth_create` task: after lease expiry the reconciler uses the fresh observed full CAS/current-dispatch identity to apply the guarded active terminalization classifier directly, preserving call-started evidence and atomically writing `manual_recovery/internal`, failure audit and old current `workerAck=terminalized`. This operation mutation increments version once, preserves generation (no takeover), creates no dispatch, and never calls Auth again; the marker remains unchanged. A pointer change or CAS loser writes nothing. If no canonical safe phase/lifecycle row matches, fail closed and alert rather than mint a boundary. Reserved-attempt exhaustion likewise terminalizes under the exact pending/active no-effect versus uncertainty classifier when its guard is available; no attempt budget is reset by replay. The P2 created-trigger/sweeper adapter enqueues a newly issued dispatch and repairs claim-before-enqueue crashes; enqueue-before-ack converges through deterministic `ALREADY_EXISTS`. Ordinary expired-current takeover without an applicable marker retains its current dispatch unchanged. CAS losers and foreign live owners make no recovery write/effect. Durable store/queue/reconciler outage emits a PII-safe stalled-operation/attempt-exhaustion alert requiring intervention, never a fictional guarantee of eventual 2xx or success.

If Firestore is permanently unavailable, no handler can guarantee terminalization. There is no fictional post-exhaustion callback: Cloud Tasks/Functions failed-execution and queue-attempt-exhaustion metrics must alert, correlated with the PII-safe operation/dispatch digest emitted by any entered invocation. The runbook inspects and explicitly recovers the nonterminal operation. Exhaustion itself does not write `manual_recovery`; terminalization remains best effort under permanent durable-store outage.

### Current Bounded Unit — Ordinary Expired-Lease Takeover (implementation blocked)

**Approved normal takeover behavior.** Ordinary takeover is normal work only (`retryCount < 8`) for an expired *current* active dispatch. One transaction rereads the source dispatch and the operation, requires the accepted source identity and full eight-field observed CAS with `currentDispatchId===source.dispatchId`, `status=active`, and `leaseExpiresAt<=transaction.now`, then derives `nextGeneration=observedOperation.generation+1` and `ownerToken=deriveOwnerToken(source.dispatchId,nextGeneration)`. It preserves status, phase, AuthAttempt, and the source pointer; increments generation and version; and installs the deterministic live 60-second lease. A retained current source may have an older immutable generation; each later expiry increments the latest observed operation generation. The transaction leaves the source dispatch byte-identical with `workerAck:null` and creates no next dispatch. It must reread the exact resulting tuple before any later ordinary phase transition.

The takeover atomically creates or deduplicates the accepted `schemaVersion:1` `progress/state_transition/started/success` audit: `eventId=deriveAuditEventId(operationId,"progress","state_transition",observedOperation.generation,observedOperation.version)`, trusted operation ID and correlation, null actor/intended-UID digests, source dispatch ID, and pre-takeover observed operation generation/version. `createdAt=transaction.now` applies only to first insertion; matching replay preserves the original timestamp, while any other-field mismatch rolls back all writes. A later ordinary phase transition remains responsible for acknowledging the source `processed` and atomically creating/pointing to its deterministic next dispatch. Accepted audit and source-dispatch semantics are unchanged.

**Current unit boundary.** One cohesive ordinary-takeover unit contains this approved behavior, strict-fake proof, and minimal REAL Firestore proof for one winner, replay/timestamp preservation, and rollback/atomicity. The REAL proof is part of this unit, not a preventive standalone unit. It may be split only after a measured pre-edit forecast of additions, deletions, tests, documentation, and review margin shows the cohesive unit cannot remain below STOP 380 and hard maximum 399; no exception, borrowing, or coverage reduction is allowed.

**Separate reserved-attempt ownership.** Reserved-attempt takeover plus terminalization remains exclusively owned by existing P3.29/P3.30. It is not part of the current unit, receives no implementation or completion authority here, and may reuse the accepted takeover primitive later without coupling the two units. The existing retry/exhaustion semantics and terminalization audit/source-dispatch behavior remain unchanged.

**Implementation gate.** The current unit is blocked until its measured pre-edit additions+deletions+tests+docs+margin forecast is recorded and fits the limits. No forecast, implementation, native authority, or P3.29/P3.30 completion is granted by this planning correction.

**Accepted evidence, unchanged.** Full CAS requires the eight fields plus a live lease for active mutation (`Full CAS and Lease Contract`); takeover alone requires the same observed current dispatch and an expired lease, then increments generation/version and rereads before a transition (same section). The reducer admits takeover only from a canonical active row, requires expired prior lease/live replacement lease, and preserves phase/AuthAttempt (`P1a2 post-B-2 amendment: Exact eight-event matrix`). `worker.ts` currently classifies trusted source tuples, derives owner tokens from dispatch+generation, and implements only initial acquisition/stale acknowledgement; `audit.ts` validates 14 immutable fields and deduplicates every field except `createdAt`.

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

Slice 1 authors and independently reviews a pure TypeScript reducer/reference model, invariant table, and representable transition vectors before any production Firebase adapter. Commands/events consume only fields present in the accepted payload/state vocabulary; they cannot call, import, encode, or claim observations from Firebase adapters. The model is frozen for adapter conformance review.

| Invariant | Required proof |
|---|---|
| Terminal immutability | Every command against each terminal status is rejected without mutation. |
| Full CAS | Per-field mutation tests independently alter fingerprint, status, phase, generation, version, ownerToken, currentDispatchId, and lease liveness; each stale mutation fails, while the exact live tuple succeeds. |
| Monotonic state | Version increments on every `OperationState` mutation; generation only on expired-lease takeover. Dispatch-only enqueue or duplicate/terminal acknowledgements do not mutate or version-bump `OperationState`. |
| Intent before effect | P1a2-ii represents the Auth intent state; P3 proves it committed before the external effect. |
| Ambiguity safety | P1a2-ii consumes only existing attempt/proof/ambiguity facts; P3 proves crash, timeout, reads, no retry, and no deletion. |
| Dispatch safety | Pure CAS fences `currentDispatchId`; P2/P3 prove incoming delivery identity, duplicate/order/orphan handling, and no regression. |
| Completion atomicity | P1a2-ii proves the candidate state transition; P3 atomically commits profile + completed + success audit + ack. |
| Data immutability | P1a2-ii preserves operation identity/payload/intended UID and confirmed Auth proof across real transitions; P2 proves audit/dispatch identity, and P3 proves profile provenance and terminal no-regression persistence. |
| Retry thresholds | P3 proves 0-7 work, 8-11 terminalize only, and exhaustion never fabricates a terminal write. |
| Pending terminalization | P3 independently mutates operation plus P2 dispatch/source/ack fields; exact initial persistence commits failure+audit+ack once. |

P1a2-ii has no fictional crash/read vectors. P3 crash-point vectors surround every external effect: before/after enqueue, Auth intent, Auth call, Auth return, each dual read, proof commit, profile/completion commit, completed integrity reads, and reset-link generation. Persistence vectors run against (1) a strict independently reviewed reference store and (2) the Firestore emulator transaction adapter. Divergence fails the build. A production-implementation-authored fake alone is inadmissible.

## Emulator and Verification Strategy

| Layer | Required proof |
|---|---|
| Pure unit/property | Normalization/fingerprint, representable reducer transitions, invariant/per-field guard mutations, deterministic IDs, and failure precedence. |
| Strict reference conformance | Frozen vectors and crash schedules against independent store, then identical vectors against Firestore emulator adapter. |
| Auth + Firestore emulators | Foreign pre-attempt identity; exact create result; both UID/email reads; ambiguity; provenance conflict; all-or-nothing completion; completed integrity. |
| Functions emulator | Both callable HTTP/callable protocols, metadata `enforceAppCheck:true`, task queue function exercised as its HTTP endpoint, stable errors, PII-safe logs. |
| Outbox integration | Firestore created event -> injectable enqueue adapter; duplicate event, enqueue success/crash-before-ack, `ALREADY_EXISTS`, invalid dispatch, guarded ack, and trigger+sweeper race. Production adapter receives a contract test against verified task construction. |
| Scheduled repair | Invoke the pure sweeper handler directly with Firestore-emulator records and shared enqueue adapter: 10-minute grace edge, `(enqueued,createdAt,__name__)` ordering/cursors, 100x5 bounds, rate/concurrency limits, partial failure/throw, already-enqueued race, and forbidden operation/Auth/profile writes. This proves handler behavior, not a fake scheduler or Scheduler delivery. Export/config metadata proves the real schedule/retry limits. |
| Concurrency/faults | True parallel emulator clients/workers, lease expiry/takeover, duplicate/out-of-order delivery, crash injection around every effect, first entry after pre-handler retries, retryCount 7/8/9/10/11, exact pending guard per-field mutations, pending mismatch reclassification, active live owner, foreign live owner, expired takeover, terminal idempotency, and failed reserved terminalization. Sequential mocks do not qualify. |
| Client | Fake callable transport only for Dart boundary tests; polling/backoff/jitter/cancel/restart persistence, DTO/error mapping, reset-link UX, and structural absence of direct provisioning. |

There is no supported `emulators.tasks` or Scheduler emulator assumption. Local task-worker proof sends authenticated test HTTP requests to the Functions emulator's task endpoint with controlled TaskContext headers. The enqueue boundary is injectable: a strict fake proves outbox idempotency, while a production adapter contract verifies deterministic queue/task construction. The scheduled handler is invoked directly; tests never claim that a fake timer proves Cloud Scheduler delivery. Auth, Firestore, and Functions emulators remain the integration substrate; metadata tests prove App Check and schedule/retry options because emulator tokens/timers do not prove production platform metadata.

## Repository Files and Deployment Metadata

### Decision: Declarative P2 IAM/deployment metadata carrier

**Choice.** P2 is authorized to add `functions/src/provisioning/deployment_metadata.ts`, exporting `provisioningDeploymentMetadata`. This carrier is declarative repository-preparation evidence only: importing it creates no production resource and has no runtime deployment effect. It records placeholders and capability intent for environment/project selection; logical per-function service accounts; Cloud Tasks queue, retry, and rate-limit configuration; task OIDC identity; Scheduler invoker; Eventarc trigger identity; Cloud Tasks enqueuer capability; and the required Firestore and Auth capabilities. Values remain placeholders where deployment review is required, including project, environment, region, rate, and concurrency. It contains no real project ID, secret, principal binding, or instruction that creates a queue, job, alert, deployment, or other production resource.

P2 structural proof imports `provisioningDeploymentMetadata` directly from this carrier. For P2.45, the carrier plus that direct structural proof constitutes wiring; `functions/src/index.ts` need not re-export it. P3 retains ownership of the final reviewed runtime binding and the task-function export, so P2 records intended capabilities without binding principals or changing the P2/P3 execution boundary.

| Rejected carrier | Reason |
|---|---|
| `functions/src/index.ts` | Conflates structural evidence with runtime exports and prematurely implies P3 binding. |
| `functions/src/provisioning/monitoring.ts` | Mixes IAM/deployment capability intent with the existing PII-safe alert contract. |
| `firebase.json` | Suggests deployable configuration and cannot express the logical least-privilege contract without environment-specific guesses. |
| Test-only literals | Can make the proof self-fulfilling without an authorized production-side repository contract. |

**Consequence.** P2 gains one narrow, reviewable evidence source while deployment remains inert; P3 must review and bind the final environment-specific values rather than treating P2 placeholders as deployment authorization.

| Path | Planned action |
|---|---|
| `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, vector fixtures | Add independent pure model/invariants first. |
| `functions/src/provisioning/store.ts`, `functions/src/provisioning/firestore_store.ts` | Add domain port and transactional Firestore adapter. |
| `functions/src/provisioning/submit.ts`, `outbox.ts`, `outbox_repair.ts`, `worker.ts`, `status.ts` | Add separated callable, shared enqueue/ack adapter, created-trigger fast path, bounded scheduled repair, task worker, and status handlers. |
| `functions/src/provisioning/deployment_metadata.ts` | Add the P2 declarative IAM/deployment evidence carrier described above. |
| `functions/src/index.ts` | Export the P2 App-Check callable, created-only trigger with retry, and 5-minute scheduled repair with bounded retry; P3 later adds the private task-function export and reviewed runtime metadata bindings. |
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
| S1 | Independent pure model, representable invariant table/vectors, model review/freeze | 330-400 |
| S2 | Strict reference store + Firestore adapter conformance | 300-380 |
| S3 | Canonical schemas, IDs, CAS/lease store primitives | 320-400 |
| S4 | Submission, authorization/denial audit, safe DTO contracts | 260-340 |
| S5 | Shared enqueue adapter + created-trigger fast path | 200-270 |
| S6 | Scheduled stale-outbox repair, index, limits, alerts/runbook proof | 200-280 |
| S7 | Task worker Auth/profile boundaries and crash matrix | 340-400 |
| S8 | P3 pending/active persisted terminalization guards and threshold proof | 240-320 |
| S9 | Status/reset link, exports, IAM/deployment metadata | 260-340 |
| S10 | Full emulator, true concurrency, outbox race/retry conformance | 340-400 |
| S11 | Flutter migration, persistence/polling UX, Dart proof | 260-350 |
| **Total** | Feature-branch chain; every slice remains at or below 400 forecast lines | **3,050-3,880** |

Each slice carries its own RED/GREEN proof and rollback boundary. S1 is explicitly a model-authoring/review slice; production adapter work cannot begin before its representable vectors are accepted. The table is a topology-level forecast only: the next `sdd-tasks` replan must remove pure P1a2-iii, reforecast narrowed ii and enlarged P3 ownership, and preserve auto-chain review limits. WU4a remains complete; failed implementation checkmarks are not evidence, and no old aggregate guard authorizes the revised slices.

## Threat Matrix

N/A — this design introduces no routing, shell, subprocess, VCS/PR automation, executable-file classification, or general process-integration boundary. Firebase event/task integration is covered by the distributed-systems threat and crash matrices above.

## Requirement and Scenario Traceability

| Updated spec requirement | Design component | Scenario-family proof level |
|---|---|---|
| App Check Pre-Handler Enforcement | Callable exports; security order; metadata | Structural export metadata + Functions emulator protocol; platform denial evidence documented. |
| Asynchronous Provisioning Submission | Submission transaction; canonical payload | Unit schema/fingerprint + Firestore/Functions emulator; assert no Auth/profile side effect. |
| Operation Identity and Idempotency | Deterministic IDs; full CAS; stale delivery | Pure CAS vectors + P2/P3 emulator duplicate submission/fingerprint conflict/out-of-order delivery. |
| Autonomous Backend Liveness | Trigger fast path + scheduled stale-outbox repair + Cloud Tasks boundary protocol | No-client emulator drive, created-event exhaustion repair, trigger+sweeper race, schedule metadata, Monitoring/runbook outage exception. |
| Protected Status Query | Safe DTOs; authorization; optional fingerprint | Unit projection + callable emulator authorization/not-found/conflict. |
| Completion Atomic Commitment | Pure candidate transition + profile completion transaction | P1a2-ii state invariant + P3 emulator transaction fault injection/completed-integrity query; persisted success tuple all-or-nothing. |
| Password Reset Link Issuance | Completed-only status behavior | Auth/Functions emulator: fresh returned link, failure retry, no storage/log/email. |
| Auth Ambiguity and Reconstruction | Auth create matrix; dual reads; proof | Pure representable attempt/proof transitions + P3 Auth emulator crash/ambiguity/foreign/mismatch cases. |
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
| Complexity and reviewer fatigue | Independent pure model first; auto-chained tasks reforecast after ii/iii ownership correction; reconciliation gate before apply. |
| IAM or queue metadata drift | Structural export/config tests, least-privilege service accounts, no production action in repository preparation. |

## Open Questions

None block task planning. Queue rate limits and exact region names are deployment-environment values to be recorded as reviewed metadata, not guessed or provisioned during repository preparation.
