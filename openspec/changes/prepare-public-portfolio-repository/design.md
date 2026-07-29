# Design: Recoverable Admin User-Provisioning Saga

## Outcome and Scope

WU4b delivers one Firebase Functions v2 callable and a recoverable Firestore-coordinated saga. The callable uses a server-generated UID reserved before Auth creation, profile-only non-admin roles, stable operation-scoped idempotency, CAS leases, durable audit events, and PII-safe Cloud Logging. All backend behavior, unit proof, callable/emulator integration, deployment-metadata proof, and evidence remain one work unit. Because the revised spec requires the Flutter admin panel to use the endpoint and forbids direct client creation, the client migration and its focused Dart proof form a separate WU4c.

This design removes deterministic/HMAC UIDs, key rotation, handler-owned App Check-denial audits, blanket existing-identity success, and any behavior/test work-unit split.

## Decisions

| Topic | Choice | Rejected alternative / rationale |
|---|---|---|
| Identity | The client creates a UUID-v4 `operationId` once per intentional submission and reuses it only for transport retries. The server generates a random Firebase-valid `intendedUid` before the acquisition transaction; the transaction persists the winning UID atomically with the reservation. | HMAC/deterministic UID and key rotation are unnecessary. A losing concurrent caller discards its candidate and uses the winner's persisted UID. |
| Idempotency | Identity is `(operationId, fingerprint)`. Same pair may resume or replay success. Before `authAttempted=true` commits, an unrelated email/UID/profile is an ordinary `already-exists` conflict with no identity/profile mutation. From that commit onward, identity mismatch or ambiguous ownership is `manual_recovery/internal`. | Existing email, matching UID/email, and generated-UID collision improbability are never ownership evidence. |
| Saga | `active/auth_pending`, `active/profile_pending`, `active/compensating`; immutable terminal `completed`, `failed`, and `manual_recovery`. Auth deletion additionally requires a persisted `authOwnershipProof` created only after an unambiguous `createUser` success. | Inferring ownership from `authAttempted` plus current UID/email equality could delete a foreign user after an ambiguous result. |
| Role | Accept only `employee` or `rrhh`; store `role` and `isSupervisor` in `/users/{uid}`. Never set Auth custom claims. | Provisioning must not create admin authority. |
| App Check | Export `onCall({enforceAppCheck:true}, handler)`. Firebase rejects invalid tokens before handler entry; platform/edge Functions logs are the denial evidence. | `.run()`-only proof and handler audits for pre-handler denials are impossible evidence. |

## Request, Operation, and Fingerprint Contract

`operationId` is a canonical lower-case UUID-v4 string. Unknown keys, nested values, arrays, non-plain objects, non-finite numbers, and missing required values are rejected before reservation. Strings are NFC-normalized and trimmed; email is additionally lower-cased; blank optionals become `null`; dates are UTC `YYYY-MM-DD`; `weeklyHours` defaults to `40`; booleans default to the current UI defaults; `employeeId` defaults to `""`. `displayName` is derived from normalized names and is not an input.

The fingerprint is the 64-character lower-case hexadecimal SHA-256 digest of this UTF-8 fixed-key-order JSON (JSON primitive escaping, no whitespace):

```text
{"email", "nombre", "apellido1", "apellido2", "employeeId", "weeklyHours",
 "dni", "telefono", "cargo", "departamento", "empresa", "scheduleId",
 "calendarId", "fechaInicio", "fechaFin", "role", "isSupervisor",
 "supervisorId", "isActive"}
```

The quoted order above is normative. `operationId` is excluded. The reservation stores the normalized payload and fingerprint, so retries never recompute profile data from changed defaults. Required fields are `operationId,email,nombre,apellido1`; allowed roles are exactly `employee|rrhh`.

## Persistence and CAS Contract

Reservation path: `/provisioningOperations/{operationId}`. Required fields are `operationId,fingerprint,normalizedPayload,intendedUid,status,phase,generation,version,ownerToken,leaseExpiresAt,authAttempted,authOwned,authOwnershipProof,terminalCode,recoveryReason,createdAt,updatedAt`. `authOwnershipProof` is null initially and becomes immutable `{attemptGeneration,attemptVersion,confirmedAt}` only through CAS after `createUser` returns unambiguous success to the current owner; lookup equality cannot create it. Failure evidence contains PII-safe `{boundary,code,class}` arrays for `primary`, `persistence`, `compensation`, and `observability`; no SDK message is stored.

Let `E=(status,phase,generation,version,ownerToken,leaseExpiresAt)`. Each active mutation is one transaction requiring exact stored `fingerprint`, exact expected `E`, current owner, and `leaseExpiresAt>serverNow`; it increments `version`. Acquisition/takeover alone increments `generation`; takeover requires `leaseExpiresAt<=serverNow`, replaces owner/lease, and increments version. Terminal transitions clear owner/lease. Terminal documents and `intendedUid`, operation identity, fingerprint, normalized payload, and creation timestamps are immutable. No worker performs Auth/Profile mutation after losing CAS.

### Acquisition and Transition Matrix

`o` is a fresh cryptographic owner token and `L=serverNow+leaseDuration`. “Audit” names the event committed by that transaction; a Cloud log is also emitted for every failure.

| State / event | Exact CAS precondition | Writes and next state | Response / retry or takeover | Audit |
|---|---|---|---|---|
| Pre-handler App Check denial | Firebase wrapper; handler not entered | None | Wrapper error; retry with valid token | Platform/edge log only |
| Handler: unauthenticated | No saga read; valid `operationId` may be parsed only for correlation | Authorization-denial event transaction; no saga/resource mutation | `unauthenticated`; if audit persistence fails, same outward denial plus Cloud failure evidence | `authorization.denied` |
| Handler: caller profile absent/inactive/not admin | Caller `/users/{callerUid}` read; no lease | Denial event transaction only | `permission-denied`; no reservation/Auth/profile mutation | `authorization.denied` |
| Authorization read/audit write fails | No lease | No saga/resource mutation | `unavailable` for dependency failure, `internal` for invariant/setup; retry | `failure.authorization` when writable, otherwise Cloud log |
| Validation fails after authorization | No reservation exists/read | None | `invalid-argument`; correct request/new operation | structured validation log |
| No reservation | Document absent | Persist candidate `intendedUid`, payload, fingerprint; `active/auth_pending,g=1,v=1,o,L,authAttempted=false,authOwned=false,authOwnershipProof=null` | Continue | none |
| Same operation, different fingerprint | Existing operation, unequal fingerprint | None | `already-exists`; never mutate | `failure.operation_conflict` create-if-absent |
| Active, live lease | Same fingerprint; lease unexpired and owner differs | None | `aborted`; retry after expiry | none |
| Active, expired lease | Exact `E`, expired lease | `g+1,v+1,o,L`; same phase | Reconstruct phase from persisted UID; never trust prior worker outcome | `recovery.takeover` |
| `completed` retry | Same fingerprint; terminal exact | No reservation mutation; run completed reconstruction | Matching resources: fresh reset link then `{userId,resetLink,idempotent:true}`; otherwise `internal` | Existing `success.completed`; integrity failure event |
| `failed` retry | Same fingerprint; terminal exact | None | Replay stored stable `terminalCode`; new intent requires new operationId | Existing failure event |
| `manual_recovery` retry | Same fingerprint; terminal exact | None | `internal`; operator investigation required | Existing `failure.manual_recovery` |
| `auth_pending`, before create | Exact owned live `E`; UID and email reconstruction says both absent | Set `authAttempted=true,v+1`, retaining phase/lease | Only after commit call `createUser({uid:intendedUid,email,displayName})` | `progress.auth_attempt` |
| Auth create returns unambiguous success | Exact owned live `E`; `authAttempted=true`; returned UID/email exactly match the request | CAS persists immutable `authOwnershipProof`, sets `authOwned=true,active/profile_pending,v+1` | Continue only after committed proof is authoritatively read; an ambiguous proof-CAS outcome is reconstructed | `progress.auth_confirmed` |
| Auth create result is ambiguous, or proof is absent after authoritative proof-CAS reconstruction | Exact owned live `E`, or exact reacquired/takeover `E`; `authAttempted=true`; no persisted proof | CAS `manual_recovery,v+1,terminalCode=internal,recoveryReason=auth-ownership-ambiguous`, clear lease; never set `authOwned` | Stable `internal` / `Provisioning requires manual recovery.`; terminal retries replay it; no further takeover | `failure.manual_recovery` in the CAS plus PII-safe Cloud record `{boundary:auth-create,code:ambiguous-result,class:ownership}` |
| Foreign identity before operation-owned create | Exact owned live `E`; `authAttempted=false`; reconstruction finds any UID/email/profile conflict | CAS `failed,v+1,terminalCode=already-exists`, clear lease; no identity/profile mutation | Stable `already-exists`; terminal retry replays; no takeover | `failure.identity_conflict` |
| Identity mismatch after partial creation is possible | Exact owned live `E`; `authAttempted=true` or phase is `profile_pending|compensating`; no positive ownership proof sufficient for the observed identity | CAS `manual_recovery,v+1,terminalCode=internal`, clear lease | Stable manual-recovery `internal`; never delete | `failure.manual_recovery` plus PII-safe mismatch log |
| Auth create definite no-side-effect failure | Exact owned live `E`; SDK classification proves no side effect and both Auth indexes confirm absence | Retryable: append evidence and CAS `authAttempted=false,v+1`; non-retryable validation/invariant: CAS `failed` | `unavailable` then retry/takeover may make a new attempt; mapped terminal error otherwise | `failure.auth_create` |
| `profile_pending`, resources reconstruct safely | Exact owned live `E`; immutable ownership proof exists; Auth matches and profile absent or operation-matching | Generate reset link; then one transaction creates profile if absent and CASes `completed,v+1`, clears lease, writes success event | Success only after transaction commit | `success.completed` in same transaction |
| Reset-link transient failure | Exact owned live `E`; immutable ownership proof exists; Auth matching | Append primary evidence, remain `profile_pending,v+1` | `unavailable`; retry/takeover regenerates | `failure.reset_link` in same transaction |
| Reset-link non-retryable/invariant or profile conflict | Exact owned live `E`; immutable ownership proof exists and Auth exactly matches | CAS `active/compensating,v+1` with primary evidence | Continue compensation; caller ultimately receives stable error | `failure.profile_or_link` |
| Final transaction ambiguous/fails | Attempted exact owned live `E` | Authoritative reread: committed `completed` is success; otherwise no assumed write and remain/reacquire `profile_pending` | `unavailable` for unresolved Firestore outcome; never delete before reconstruction | Cloud failure; durable event if transaction committed |
| Any owner loses CAS | Exact predicate fails | None | `aborted` if CAS is sole failure; `internal` if combined with primary/persistence/compensation defect | Cloud failure for compound case |
| `compensating`, Auth absent | Exact owned live `E`; exact UID absence confirmed | CAS `failed,v+1`, clear lease | Replay mapped primary error | `failure.compensated` same transaction |
| `compensating`, Auth matching | Exact owned live `E`; `authOwned=true`; immutable proof exists; re-read exact UID immediately after lease confirms normalized email | Call `deleteUser(intendedUid)` only; then confirm UID absent | On confirmed absence, terminal `failed`; otherwise remain active | progress Cloud log, then `failure.compensated` |
| Compensation delete/read fails | Exact owned live `E` if Firestore writable | Append compensation evidence, remain `compensating,v+1,o,L` | `internal`; stale takeover retries | `failure.compensation` same transaction |
| Compensation sees mismatched UID/email | Exact owned live `E` | CAS `manual_recovery,v+1`, clear lease; never delete | `internal`; no automated mutation | `failure.manual_recovery` |
| Terminal transition persistence fails | No successful CAS | No terminal state assumed | `internal`; active lease expiry enables reconstruction/takeover | Cloud log with primary+persistence evidence |

### Reconstruction Matrix

Every takeover and continuation queries both Auth indexes and the profile. `M` means UID exists with normalized intended email and email lookup returns that UID; `X` means inconsistent/foreign/mismatched; `P` means immutable positive ownership proof exists. `PM` is a full operation-tagged profile match. Rows are evaluated top-down. Every active CAS requires exact fingerprint and live `E`; terminal checks require exact immutable operation/fingerprint. Auth read failure never implies absence.

| State and observations | CAS predicate and writes / next state | Response and retry/takeover | Delete? | Audit/log |
|---|---|---|---|---|
| `auth_pending`; `authAttempted=false`; Auth absent/absent; profile absent | Exact active `E`; CAS `authAttempted=true,v+1`; remain `auth_pending`, then create | Continue; stale takeover reconstructs | No | `progress.auth_attempt` |
| Same, profile `PM` | Exact active `E`; CAS `failed/already-exists`, clear lease | Stable conflict; terminal replay | No | `failure.identity_conflict` |
| Same, profile conflicting | Same as preceding row | Stable conflict; terminal replay | No | `failure.identity_conflict` |
| `auth_pending`; `authAttempted=false`; Auth `M` or UID absent/email foreign | Exact active `E`; CAS `failed/already-exists`, clear lease | Stable conflict; terminal replay | No | `failure.identity_conflict` |
| `auth_pending`; `authAttempted=false`; intended UID contains mismatched email or Auth indexes are otherwise `X` | Exact active `E`; CAS `failed/already-exists`, clear lease | Stable conflict; terminal replay | No | `failure.identity_conflict` + mismatch log |
| `auth_pending`; `authAttempted=true`; Auth `M`; no `P`; profile absent, `PM`, or conflicting | Exact active `E`; CAS `manual_recovery/internal`, reason `auth-ownership-ambiguous`, clear lease | Stable recovery error; terminal replay, no takeover | No | `failure.manual_recovery` + ownership log |
| `auth_pending`; `authAttempted=true`; Auth absent/absent; no `P`; any profile | Exact active `E`; CAS `manual_recovery/internal`, reason `auth-ownership-ambiguous`, clear lease | Stable recovery error; terminal replay, no takeover | No | `failure.manual_recovery` + ownership log |
| `auth_pending`; `authAttempted=true`; Auth `M`; `P`; profile absent or `PM` | Exact active `E` including proof; CAS `profile_pending,v+1` | Continue; stale takeover may resume | No | `progress.auth_confirmed` |
| `auth_pending`; `authAttempted=true`; Auth `M`; `P`; profile conflicting | Exact active `E` including proof; CAS `compensating,v+1` | Stable `internal` after compensation; takeover may resume | Only later compensation row | `failure.profile_or_link` |
| `auth_pending` after `authAttempted=true`, `profile_pending`, or `compensating`; intended UID contains mismatched email or Auth indexes are `X` | Exact active `E`; CAS `manual_recovery/internal`, clear lease | Stable recovery error; terminal replay | No | `failure.manual_recovery` + mismatch log |
| Any active phase; Auth/profile read fails | Exact active `E`; append PII-safe evidence, `v+1`, same phase | `unavailable`; retry or stale takeover | No | phase-specific failure event/log |
| `profile_pending`; Auth absent/absent; any profile | Exact active `E`; CAS `compensating,v+1`; compensation confirms absence then CAS `failed/internal` | `internal`; retry/takeover until terminal | No | `failure.auth_missing`, then `failure.compensated` |
| `profile_pending`; Auth `M`; no `P`; any profile | Exact active `E`; CAS `manual_recovery/internal`, clear lease | Stable recovery error; terminal replay | No | `failure.manual_recovery` + ownership log |
| `profile_pending`; Auth `M`; `P`; profile absent | Exact active `E`; reset link, then transaction creates tagged profile + `completed` | Success after commit; ambiguous commit reread | No | `success.completed` atomically |
| `profile_pending`; Auth `M`; `P`; profile `PM` | Exact active `E`; preserve profile, reset link, CAS `completed` | Success; retry replays | No | `success.completed` atomically |
| `profile_pending`; Auth `M`; `P`; profile conflicting | Exact active `E`; CAS `compensating,v+1` | Primary stable error after compensation; takeover may resume | Only with `P` below | `failure.profile_or_link` |
| `compensating`; Auth absent/absent; any profile | Exact active `E`; CAS `failed`, mapped primary code, clear lease | Terminal replay; no takeover | No | `failure.compensated` |
| `compensating`; Auth `M`; `P`; any profile | Exact active `E`; immediate Auth recheck, delete exact UID, confirm absent, CAS `failed` | `internal` while unresolved; stale takeover resumes | Yes, only here | progress log + `failure.compensated` |
| `compensating`; Auth `M`; no `P` | Exact active `E`; CAS `manual_recovery/internal`, clear lease | Stable recovery error; terminal replay | No | `failure.manual_recovery` |
| `completed`; Auth `M`; profile `PM` | Exact terminal identity; no write except fresh-link side effect | Success `{idempotent:true}`; retries repeat link issuance | No | Existing `success.completed` |
| `completed`; Auth missing, conflicting, mismatched, or either Auth read fails | Exact terminal identity; reservation remains immutable; create integrity event only | Stable `internal`; retry rechecks, never takeover | No | `failure.completed_integrity` + PII-safe log |
| `completed`; Auth `M`; profile missing, conflicting, or unreadable | Same terminal predicate and no resource write | Stable `internal`; retry rechecks, never takeover | No | `failure.completed_integrity` + PII-safe log |

`PM` requires `provisioningOperationId`, fingerprint, UID, normalized email, and full normalized payload. It proves profile provenance, not Auth ownership. Only `authOwnershipProof` permits Auth deletion. Generated-UID collision improbability, `authAttempted`, and current UID/email equality are explicitly insufficient. `completed`, `failed`, and `manual_recovery` never recreate, overwrite, compensate, or take over.

## Sequence

```text
Client(operationId) -> v2 callable/App Check -> handler
handler -> caller profile read -> authorization audit if denied
handler -> reservation transaction(candidate intendedUid)
handler -> Auth reads(intendedUid + email)
handler -> CAS authAttempted -> Auth.createUser(exact intendedUid)
handler -> unambiguous Auth result -> CAS ownership proof + profile_pending
ambiguous Auth result or missing proof -> CAS manual_recovery -> stable internal
handler -> Auth.generatePasswordResetLink
handler -> Firestore transaction(profile + success audit + completed CAS)
handler -> client {userId, resetLink, idempotent}

non-retryable post-Auth failure -> compensating CAS/lease
  -> re-read exact UID/email -> delete exact intendedUid -> confirm absent
  -> failed CAS + failure audit -> stable HttpsError
```

## Authorization, Audit, and Logs

Order is wrapper App Check gate → authentication → Admin SDK caller `/users/{uid}` read requiring `role=admin && isActive=true` → denial audit if needed → validation → reservation/lease. No raw email, display name, request body, token, DNI, telephone, or names appear in application logs/audit.

Audit path is `/provisioningAudit/{eventId}`. `eventId=lowerHex(SHA-256("provision:v1\0"+operationKey+"\0"+actorKey+"\0"+category+"\0"+stage+"\0"+attempt))`, where `operationKey` is valid `operationId`, or `correlationId` only when operationId is absent/invalid; `actorKey` is the caller UID digest or literal `anonymous`; `attempt` is `0` for authorization, terminal success, and terminal failure, otherwise the reservation generation. Required fields: `eventId,operationId|null,category(success|failure|authorization),stage,outcome,code,correlationId,actorUidDigest|null,intendedUidDigest|null,generation|null,createdAt`. Digests use one-way SHA-256 with a fixed domain prefix, not a UID-generation secret.

Events are create-if-absent. A retry reads an existing event, verifies immutable identity fields, and performs no write; mismatch is `internal`. Authorization events commit before lease/resource mutation. Success commits in the profile/completion transaction. Transition failures commit in the transaction that records the failure/phase change. App Check denials are the sole application-audit exception. Cloud logs use the same correlation fields plus `version,status,phase` and all failure triples.

## Failure Mapping and Precedence

Every synchronous constructor/getter/logger error and every rejected SDK read, transaction callback/commit, batch/write, Auth lookup/create/delete, reset-link, audit, and compensation promise reaches one mapper; no empty or best-effort catch exists.

| Condition | Stable `HttpsError` |
|---|---|
| Missing auth | `unauthenticated` |
| Authenticated inactive/non-admin | `permission-denied` |
| Invalid schema/email/role/date/range | `invalid-argument` |
| Foreign operation/fingerprint, or foreign UID/email/profile observed while `authAttempted=false` | `already-exists` |
| Any identity mismatch or ownership ambiguity after `authAttempted=true`, including matching UID/email without `authOwnershipProof` | `internal` after CAS to `manual_recovery` |
| Live lease or CAS loss alone | `aborted` |
| Retryable Auth/Firestore/reset-link `aborted|deadline-exceeded|resource-exhausted|too-many-requests|unavailable` | `unavailable` |
| Invariant, malformed SDK response, setup, unknown SDK code, audit/persistence/logger defect, unsafe ownership, compensation failure | `internal` |

The phase boundary is the successful CAS that sets `authAttempted=true`, immediately before `createUser`. Before it, an observed foreign identity is ordinary conflict: CAS may record the reservation failure and audit, but no Auth/profile/claim/delete mutation occurs, and `already-exists` wins. At or after it, the operation may have created a partial resource: mismatch, an ambiguous create result, or matching Auth without persisted proof MUST CAS to `manual_recovery` and return the stable `internal` recovery error; it never falls back to `already-exists` and never deletes.

Overall precedence is security decision → post-attempt ownership/integrity → compound integrity → pre-attempt conflict → retryable dependency → CAS-only loss → primary mapping. `unauthenticated`/`permission-denied` remain outwardly stable if denial-audit persistence fails, with Cloud/stderr evidence for both. For authorized work, persistence, compensation, or observability defects return `internal`. All failures remain separate triples. If the structured logger throws, emit the same PII-safe record to `process.stderr`; stderr is fallback evidence, not durable application audit.

## Files and Work-Unit Verification

| Path | Planned change |
|---|---|
| `functions/src/index.ts` | Export v2 callable with `enforceAppCheck:true`; initialize Admin SDK. |
| `functions/src/provisioning.ts` | Validation, normalization, fingerprint, state machine, CAS, reconstruction, compensation, mapping, audit/log contracts. |
| `functions/test/provisioning.unit.test.ts` | Deterministic unit/fault-injection coverage for every matrix row and compound precedence. |
| `functions/test/provisioning.emulator.test.ts` | Callable-client Auth/Firestore/Functions emulator coverage, true concurrent clients, stale takeover, shared-state reconstruction. |
| `functions/test/export-metadata.test.ts` | Structural assertion that exported v2 endpoint metadata binds `enforceAppCheck:true`; `.run()` only supplements handler tests. |
| `functions/package.json`, `firebase.json` | Minimal same-WU4b scripts/emulator wiring. |
| `lib/core/services/firebase_service.dart`, generated provider file if required | WU4c: replace secondary client Auth flow with callable client; preserve Riverpod boundary and operationId across transport retries. |
| Existing focused Dart service/provider/widget tests | WU4c proof: callable payload/result/error behavior and absence of direct client Auth creation. |

Local test-harness prerequisites: Node >=22.6.0 because direct `.ts` execution uses `--experimental-strip-types`, installed existing function dependencies, Firebase CLI already authenticated only if required locally, Java for Firestore emulator, ports 5001/8080/9099 free, a disposable emulator project ID, and no production credentials. Firebase deployment runtime compatibility remains Node 20+ for Cloud Functions v2; production does not require Node 22.6. Tests use Functions/Auth/Firestore emulators with isolated namespaces and cleanup. Callable-client tests prove protocol and shared emulator state, not production App Check cryptography.

| Proof layer | Required cases |
|---|---|
| Unit | Exact normalization/fingerprint; schema/role denial; all CAS predicates; every transition/reconstruction row; stable event IDs; all single and primary+persistence+compensation+logger failures. |
| Concurrency | Two actual parallel callable clients for one operation choose one persisted UID; loser uses winner UID; same-op mismatch conflicts; live lease aborts; stale owner takeover; lost CAS cannot mutate. Sequential mock calls are insufficient. |
| Emulator integration | Success; retry; foreign email/UID; ambiguous create reconstruction; UID absent/matching/mismatched/read failure; profile absent/matching/conflicting; reset failure; compensation/delete failure; completed missing/conflicting resources; audit dedup and authorization-before-mutation. |
| Boundary | Export metadata has `enforceAppCheck:true`; platform/edge logs are documented production denial evidence; no handler audit is expected pre-handler. `.run()` is not App Check proof. |
| Client | Admin flow calls backend, reuses operationId for retry, maps stable errors, never directly creates Auth/profile. |

## Rollback, Gates, and Forecast

Rollback disables/removes the callable export and restores only paths enumerated by the applicable WU4b backend or WU4c client unit; it never mutates existing reservations/resources automatically. Before rollback, active operations are allowed to expire and are assessed through the same reconstruction matrix. No deployment occurs in this phase.

WU4 remains incomplete after green unit tests. WU4b completion requires backend behavior plus every unit, emulator/concurrency, export-metadata, build, and evidence obligation in the matrices; none may move to a proof-only work unit. WU4c is required separately because the revised spec mandates the Flutter endpoint migration, and it carries its focused Dart proof. Only after both are complete may the candidate proceed to the later validation policy. RDD remains disabled in this design correction; no review runs here.

Recalculated combined forecast (changed lines): backend/state machine **520–600**; function unit tests **390–460**; emulator/concurrency/metadata proof **360–430**; wiring **30–45**; Flutter callable migration and proof **170–210**. Combined expected total is **1,470–1,745** and credible contingency is **1,920**. Reforecast remains **1,500**, stop remains **1,850**, and **2,000** remains the absolute ceiling. Because the contingency exceeds the stop, a combined WU4b is blocked.

Required internal split: **WU4b** is the complete backend capability plus all unit, emulator/concurrency, export-metadata, wiring/build, and evidence proof (**1,300–1,535 expected; 1,690 contingency**). **WU4c** is the spec-required Flutter callable migration plus its focused service/provider/widget proof (**170–210 expected; 250 contingency**). Each behavior stays with its proof; no backend test-only slice is permitted.

### Deferred Tasks Reconciliation

The current WU4b/WU4c/WU5 continuation metadata is stale relative to this authoritative design. The subsequent `sdd-tasks` phase MUST reconcile `tasks.md`, apply-progress continuation metadata, work-unit labels, dependencies, forecasts, and completion gates to the WU4b backend-proof / WU4c client-proof split above, without moving any backend unit/emulator/metadata proof out of WU4b. This design phase intentionally does not edit those files.

Threat matrix: N/A — no routing, shell, subprocess, VCS/PR automation, executable-file classification, or process-integration boundary is introduced.

## Explicitly Invalid Implementations

Non-CAS terminal writes; swallowed/best-effort failures; sequential mocks labeled concurrency; `.run()`-only App Check proof; handler audit for pre-handler rejection; foreign identity as idempotent success; deriving Auth ownership from `authAttempted`, UID/email equality, or collision improbability; Auth deletion without immutable positive proof, current compensation lease, and exact UID/email re-verification; Auth admin claims; and declaring WU4 complete from green unit tests alone are rejected.

## Requirements Traceability

| Normative requirement | Design evidence |
|---|---|
| App Check pre-handler enforcement | Decision, transition first row, boundary test, platform-log exception |
| Recoverable idempotent saga | Request identity, CAS contract, both exhaustive matrices, sequence |
| Foreign identity conflict/no mutation | Identity decision and reconstruction conflict rows |
| Constrained profile roles/no claims | Role decision and validation contract |
| Authorization/audit/PII safety | Authorization order and mechanical audit schema |
| Compound failure observability | Failure mapping, precedence, fault matrix |
| Backend proof kept in WU4b; required client migration in WU4c | Files, test matrix, completion gates |
