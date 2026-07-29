# Specification: Prepare Public Portfolio Repository

## Domain: Trusted Admin User Provisioning

### Requirement: App Check Pre-Handler Enforcement

The system MUST export each provisioning callable — submission and status query — with `onCall({ enforceAppCheck: true })` so the Firebase wrapper rejects requests with missing or invalid App Check tokens before invoking handler code. Required denial evidence is platform/edge structured logging plus exported deployment metadata asserting the option. The handler SHALL NOT be required to create an audit record for requests that never enter it.

#### Scenario: Pre-handler App Check rejection evidence
- GIVEN a request with a missing or invalid App Check token targeting either callable
- WHEN the Firebase wrapper evaluates the callable gate
- THEN the wrapper rejects before handler entry
- AND platform/edge structured logs contain the denial
- AND no handler-created audit record exists for that request

#### Scenario: Deployment metadata asserts enforcement
- GIVEN the exported submission and status callables
- WHEN their deployment options/metadata are inspected structurally
- THEN `enforceAppCheck` is bound to `true` for both

### Requirement: Asynchronous Provisioning Submission

An authorized, App-Check-protected submission callable MUST validate and canonicalize the payload, accept a client-generated `operationId`, atomically persist one durable operation with its initial dispatch intent, and return `{operationId, status:'pending'}` without claiming user creation. The submission SHALL NOT execute Auth creation or profile writes. Strings SHALL be NFC-normalized and trimmed; email SHALL be lower-cased; unknown keys, non-finite numbers, and missing required values SHALL be rejected. Roles SHALL be constrained to `employee|rrhh`; the system SHALL NOT grant admin privileges through provisioning.

#### Scenario: Happy-path submission
- GIVEN an authenticated admin with valid privileges and a well-formed payload
- WHEN the submission callable processes the request
- THEN one operation is persisted with the client `operationId`
- AND the response is `{operationId, status:'pending'}`
- AND no Auth user or Firestore profile is created by the submission

#### Scenario: Malformed input rejected
- GIVEN an authenticated admin
- WHEN the request contains invalid or missing required fields, unknown keys, or a disallowed role
- THEN the backend rejects without creating any operation or dispatch

#### Scenario: Role constrained to employee or rrhh
- GIVEN an authenticated admin requesting roles
- WHEN a role outside `employee` or `rrhh` is requested
- THEN the submission is rejected
- AND the system SHALL NOT grant admin privileges or set Auth custom claims

### Requirement: Operation Identity and Idempotency

Idempotency SHALL be scoped to `(operationId, fingerprint)` where the fingerprint is a stable digest of the canonicalized payload. The same pair MUST resume or observe the same operation. The same `operationId` with a different fingerprint MUST fail with a stable conflict error without mutation. Duplicate or out-of-order dispatch MUST NOT duplicate side effects or regress state.

#### Scenario: Duplicate submission resumes
- GIVEN an existing operation with the same `operationId` and matching fingerprint
- WHEN the same submission is retried
- THEN the system returns the current operation status without duplicating resources or audit events

#### Scenario: Fingerprint conflict rejected
- GIVEN an existing operation with the same `operationId` but different fingerprint
- WHEN a submission targets that `operationId`
- THEN the system returns a stable conflict error without mutation

#### Scenario: Out-of-order dispatch is harmless
- GIVEN a dispatch referencing a stale operation generation or version
- WHEN the worker processes the dispatch
- THEN the compare-and-swap rejects and no state change or side effect occurs

### Requirement: Autonomous Backend Liveness

After an accepted submission, the backend — not the Flutter client or admin retries — MUST autonomously re-drive every nonterminal operation toward `completed`, `failed`, or `manual_recovery`, provided durable dependencies (Firestore, Auth) become available within the configured retry window. Client polling is observation only and SHALL NOT be required for progress. Each autonomous execution SHALL advance at most one external-effect boundary before yielding to the next dispatch. If durable dependencies remain permanently unavailable through the absolute infrastructure retry window, the backend SHALL emit an observable operational alert with failure evidence and route the operation to explicit operator intervention; this is the sole exception to the autonomous liveness guarantee and SHALL NOT be reported as silent success.

#### Scenario: Autonomous re-drive without client
- GIVEN an accepted operation in `pending` or `active` state
- WHEN no client polls or retries
- THEN the backend autonomously advances the operation toward a terminal state

#### Scenario: Worker crash before Auth creation
- GIVEN a worker that crashes before persisting Auth-attempt evidence
- WHEN the autonomous retry fires
- THEN the system re-evaluates from persisted state and retries Auth creation safely

#### Scenario: Worker crash after Auth creation
- GIVEN a worker that crashes after Auth creation but before persisting ownership proof
- WHEN the autonomous retry fires
- THEN reconstruction from both Auth indexes determines the next safe action

#### Scenario: Permanent durable-store outage
- GIVEN a nonterminal operation whose durable dependencies remain unavailable through the absolute infrastructure retry window
- WHEN no further infrastructure attempts remain
- THEN the backend emits an observable operational alert with failure evidence
- AND the operation requires explicit operator intervention
- AND the system does NOT report silent success or claim terminal resolution

### Requirement: Protected Status Query

A separate App-Check-protected status callable MUST return one of `pending`, `active`, `completed`, `failed`, or `manual_recovery` with stable safe fields. It SHALL require admin authorization. Authorized lookup SHALL use `operationId` as the sole required key. If the caller optionally supplies a fingerprint and it does not match the stored operation, the callable SHALL return a stable conflict error without mutation. Unknown `operationId` SHALL produce a stable not-found error. Neither error path SHALL cause mutation.

#### Scenario: Authorized status read
- GIVEN an authenticated admin querying a known operation by `operationId`
- WHEN the status callable is invoked
- THEN the current status and safe fields are returned

#### Scenario: Unauthorized caller rejected
- GIVEN a non-admin or unauthenticated caller
- WHEN the status callable is invoked
- THEN the request is denied with a stable authorization error

#### Scenario: Unknown operation
- GIVEN a valid admin querying a nonexistent `operationId`
- WHEN the status callable is invoked
- THEN a stable not-found error is returned without mutation

#### Scenario: Optional fingerprint mismatch on status
- GIVEN a valid admin querying a known `operationId` with an optionally supplied fingerprint that does not match
- WHEN the status callable is invoked
- THEN a stable conflict error is returned without mutation

### Requirement: Completion Atomic Commitment

`completed` SHALL be observable only after Auth identity integrity verification plus one atomic commit of the profile document, operation completion transition, and success audit event. If the atomic commit fails, the operation SHALL remain nonterminal and retryable or transition to `manual_recovery`; the system SHALL never report success.

#### Scenario: Successful completion
- GIVEN Auth integrity verified and profile absent or operation-matching
- WHEN the atomic transaction commits profile, completion, and audit
- THEN `completed` is observable and success is returned only after commit

#### Scenario: Profile transaction failure
- GIVEN Auth integrity verified but the atomic commit fails
- WHEN the transaction does not commit
- THEN the operation remains nonterminal and is retried autonomously
- AND success is never reported

#### Scenario: Completed integrity query failure
- GIVEN an operation in `completed` state whose Auth or profile no longer verifies consistently
- WHEN the status callable is queried
- THEN the operation remains `completed` (terminal, immutable)
- AND the callable returns a stable integrity-failure error without generating a reset link
- AND no takeover, retry, or state mutation occurs on the terminal operation

### Requirement: Password Reset Link Issuance

On verified `completed` status with intact Auth integrity, the protected status callable MUST generate a fresh password reset link using Firebase Auth and return it to the authorized admin. Firebase generates the link but does NOT send it. The raw link SHALL never be stored, audited, or logged. No temporary password SHALL be created. No email delivery provider SHALL be configured or used. The admin SHALL manually deliver the link.

#### Scenario: Fresh link on completed
- GIVEN a `completed` operation with verified Auth integrity
- WHEN the authorized admin queries status
- THEN a fresh reset link is generated and returned in the response
- AND the raw link is not persisted anywhere

#### Scenario: Reset-link generation failure
- GIVEN a `completed` operation but link generation fails transiently
- WHEN the status callable is invoked
- THEN a stable error is returned
- AND the admin may retry to obtain a fresh link

### Requirement: Auth Ambiguity and Reconstruction

External Auth has no shared transaction with the operation store. The system MUST persist intent before Auth mutation. On timeout or crash, the system MUST reconstruct BOTH the intended UID index and the email index. Missing independent ownership proof, identity mismatch, or read uncertainty after Auth attempt SHALL produce `manual_recovery`. The system SHALL never repeat an ambiguous Auth create. The system SHALL never reinterpret post-attempt ambiguity as ordinary `already-exists`.

#### Scenario: Auth read uncertainty after crash
- GIVEN Auth was attempted but no ownership proof was persisted before a crash
- WHEN reconstruction queries both UID and email Auth indexes
- THEN the operation transitions to `manual_recovery` with a stable recovery reason
- AND no Auth deletion is attempted

#### Scenario: Foreign identity before Auth attempt
- GIVEN the target email or UID is owned by a different identity before any Auth attempt
- WHEN the worker evaluates the operation
- THEN the operation transitions to `failed` with `already-exists`
- AND no identity, profile, or claim mutation occurs

#### Scenario: Identity mismatch after Auth attempt
- GIVEN Auth was attempted and the observed identity does not match the intended operation
- WHEN reconstruction evaluates the mismatch
- THEN the operation transitions to `manual_recovery`
- AND no Auth deletion occurs
- AND the mismatch is not reinterpreted as ordinary `already-exists`

### Requirement: First-Slice Compensation Policy

The system SHALL NOT perform automatic Auth deletion in the first slice. Where safe, the system SHALL fix-forward by retry. Where fix-forward is not safe, the operation SHALL transition to `manual_recovery`. An existing or foreign identity observed before any Auth attempt MAY produce `failed` with `already-exists` without mutation.

#### Scenario: No automatic Auth deletion after post-Auth failure
- GIVEN a failure after Auth creation that could theoretically be compensated by deletion
- WHEN the system evaluates compensation
- THEN no Auth deletion is attempted
- AND the operation transitions to `manual_recovery`

#### Scenario: Foreign identity before attempt fails without mutation
- GIVEN an email already owned by another UID before any Auth attempt
- WHEN the operation evaluates pre-conditions
- THEN the operation fails with `already-exists` without any identity mutation

### Requirement: Bounded Retry and Terminal Failure Finalization

Transient failures SHALL autonomously retry with bounded backoff. The system SHALL define two thresholds: an **application terminalization threshold** strictly before the infrastructure queue's absolute maximum attempt count, and one or more **reserved infrastructure attempts** beyond the application threshold dedicated solely to terminalization. When the application threshold is reached, the worker MUST atomically persist failure evidence, an audit event, and `manual_recovery` (or a defined terminal failure state when side effect is proven absent). Terminalization success SHALL acknowledge the task. If the terminalization transaction itself fails, the execution SHALL throw so that a reserved infrastructure attempt retries the terminalization. If the durable store remains unavailable through the absolute infrastructure window and no reserved attempt succeeds, the backend SHALL emit an observable operational alert with failure evidence and require explicit operator recovery; this is the sole liveness exception and SHALL NOT be reported as silent success. Task exhaustion SHALL NOT silently strand an active operation.

#### Scenario: Bounded retry succeeds within application threshold
- GIVEN a transient failure during worker execution
- WHEN autonomous retries occur within the application terminalization threshold
- THEN the operation eventually advances to the next phase or terminal state

#### Scenario: Application threshold triggers terminalization
- GIVEN the worker reaches the application terminalization threshold
- WHEN normal work retries are exhausted but reserved attempts remain
- THEN failure evidence, audit event, and `manual_recovery` are atomically persisted
- AND the task acknowledges only after that terminalization commit succeeds

#### Scenario: Reserved attempt retries failed terminalization
- GIVEN the terminalization transaction failed during the application-threshold attempt
- WHEN a reserved infrastructure attempt fires
- THEN the system retries the terminalization atomically
- AND acknowledges only after the commit succeeds

#### Scenario: Absolute durable-store outage after all attempts
- GIVEN the durable store remains unavailable through the absolute infrastructure retry window including all reserved attempts
- WHEN no further infrastructure attempts remain
- THEN the backend emits an observable operational alert with preserved failure evidence
- AND the operation requires explicit operator recovery
- AND the system does NOT report silent success or claim terminal resolution

### Requirement: Operation Invariants

Terminal states (`completed`, `failed`, `manual_recovery`) SHALL be immutable — no transition may change a terminal state. Version SHALL be strictly monotonically increasing on every mutation. Generation SHALL increase only on lease takeover. Active mutation SHALL require exact live owner, unexpired lease, and compare-and-swap on the full state tuple. The persisted intended UID and fingerprint SHALL be immutable after creation. Failure evidence SHALL be preserved. A read failure SHALL NOT be interpreted as absence.

#### Scenario: Terminal immutability
- GIVEN an operation in any terminal state
- WHEN any transition is attempted
- THEN the compare-and-swap rejects and no state change occurs

#### Scenario: Stale owner, mismatched tuple, or expired lease rejected
- GIVEN an active operation
- WHEN a worker attempts mutation with a non-matching owner token, a stale full-state tuple, or an expired lease
- THEN the compare-and-swap rejects without mutation
- AND a legitimate owner holding an unexpired lease with a matching tuple is NOT rejected

#### Scenario: Read failure is not absence
- GIVEN an Auth or profile read that fails transiently
- WHEN the system evaluates the operation
- THEN the failure is treated as retryable uncertainty, not as proof of absence

### Requirement: Application Audit and Observability Contract

Authorization failures that reach a handler MUST produce a PII-safe structured application audit entry before any reservation or Auth/Firestore mutation. The system SHALL define required audit event categories (success, failure, authorization denial) with observable guarantees. Events SHALL use stable operation/event identity so retries do not duplicate the same logical event. Platform App Check denials are the explicit exception, handled solely by platform/edge logs. No raw email, display name, DNI, telephone, request body, or token SHALL appear in application logs or audit records.

#### Scenario: Authorization denial audited before mutation
- GIVEN a caller that passes App Check but lacks admin authorization
- WHEN either handler evaluates authorization
- THEN a PII-safe structured audit entry is recorded as the sole application write
- AND no operation, reservation, profile, Auth, or claim mutation occurs

#### Scenario: Worker transition audited atomically
- GIVEN an autonomous worker committing a state transition
- WHEN the transition transaction succeeds
- THEN the audit event is committed atomically with the state transition

#### Scenario: Success and failure events are deduplicated
- GIVEN a provisioning operation with stable event identity
- WHEN retries occur for the same logical event
- THEN the audit log does not duplicate the same event identity

### Requirement: Client Provisioning Migration

The Flutter admin panel MUST remove the secondary Firebase App instance, direct client Auth creation, direct client profile writes, client-side compensation logic, and temporary password generation. It SHALL submit provisioning once via the trusted backend callable, observe status through bounded polling with backoff and cancellation support, and present the completed reset link or an actionable `failed` or `manual_recovery` result. Client restart SHALL be able to resume status observation using a persisted `operationId`.

#### Scenario: Client submits and polls to terminal
- GIVEN the migrated Flutter admin panel
- WHEN an admin initiates provisioning
- THEN the client submits once via the callable, persists the `operationId`, and polls status with bounded backoff until terminal

#### Scenario: Client restart resumes observation
- GIVEN a client restart with a persisted `operationId` from a prior submission
- WHEN the application resumes
- THEN the client queries status for the existing operation without re-submitting

#### Scenario: Terminal result presented to admin
- GIVEN the status callable returns `completed`, `failed`, or `manual_recovery`
- WHEN the client receives the terminal response
- THEN the admin sees the reset link on `completed` or an actionable error on `failed` or `manual_recovery`

#### Scenario: Direct client provisioning absent
- GIVEN the migrated Flutter codebase
- WHEN inspected for Auth creation or profile write paths
- THEN no direct client Auth creation, secondary Firebase App, or client-side compensation remains in the provisioning flow

### Requirement: Explicit Non-Goals and Compatibility

This change SHALL NOT include production deployment, automatic Auth deletion, email delivery provider integration, exactly-once Auth mutation claims after timeout, or client-owned liveness. These are explicit exclusions for the first slice. The system makes no exactly-once guarantee for Auth creation after a timeout or crash; reconstruction handles ambiguity instead.

#### Scenario: Non-goals verifiable
- GIVEN the system boundary for this change
- WHEN assessed against the non-goals list
- THEN automatic Auth deletion, email delivery, exactly-once Auth after timeout, client-owned liveness, and production deployment are all absent

## Domain: Firestore Authorization Hardening

### Requirement: Client-Side Write Denial

Firestore rules MUST deny direct client `/users` document creation, privileged authorization-field mutation, and self-escalation. Only the trusted backend via Admin SDK SHALL bypass these restrictions.

#### Scenario: Direct client /users creation denied
- GIVEN an authenticated non-admin client
- WHEN it attempts to create a `/users` document directly
- THEN the write is denied

#### Scenario: Privileged field mutation denied
- GIVEN an authenticated user modifying their own document
- WHEN role or authorization fields are targeted
- THEN the write is denied

#### Scenario: Admin SDK write permitted
- GIVEN the trusted backend using Admin SDK
- WHEN it writes a user document with privileged fields
- THEN the write succeeds

## Domain: Publication Sanitization

### Requirement: Current-Tree Credential and PII Removal

The system MUST remove all credentials, PII, production claims, and hardcoded secrets from the current tree before any publication gate assessment.

#### Scenario: Clean scan passes
- GIVEN the remediated tree
- WHEN a secret/PII scan executes
- THEN no credentials, PII, or production claims remain

#### Scenario: Production claims replaced
- GIVEN documentation with live-deployment claims
- WHEN sanitization runs
- THEN claims are replaced with truthful portfolio-mode statements

### Requirement: Generic Organization Data

Organization branding MUST use generic data while retaining the application name `controlhorario-rega`.

#### Scenario: Generic branding verified
- GIVEN the sanitized tree
- WHEN organization metadata is inspected
- THEN it contains generic placeholders, not real identifiers

## Domain: Secure Android Signing and Secret Hygiene

### Requirement: Release Signing Enforcement

Release builds MUST fail when signing configuration or keystore secrets are absent. Signing inputs MUST be protected by ignore rules.

#### Scenario: Missing signing config fails build
- GIVEN a release build without signing secrets
- WHEN the build runs
- THEN it fails with a clear error

#### Scenario: Secret files ignored
- GIVEN the repository `.gitignore`
- WHEN evaluated
- THEN keystore and signing-secret files are excluded

### Requirement: Protected Path Immutability

`.atl/skill-registry.md`, `.atl/.skill-registry.cache.json`, and `lib/core/theme/app_colors.dart` MUST NOT be mutated by automated remediation.

#### Scenario: Protected paths untouched
- GIVEN automated remediation runs
- WHEN protected paths exist
- THEN their content remains unchanged

## Domain: Portfolio Metadata and Docs Boundary

### Requirement: Repository-Only Portfolio Presentation

The repository MUST present as a portfolio codebase with no live-demo promise. `docs/archive/` MUST be removed.

#### Scenario: No live demo claim
- GIVEN sanitized README and metadata
- WHEN inspected for deployment/demo promises
- THEN none are present

#### Scenario: Archive directory removed
- GIVEN the remediated tree
- WHEN `docs/archive/` is checked
- THEN it does not exist

### Requirement: Publication Gate Visibility

License selection, reachable-history cleanup, and Firebase Console verification MUST be documented as manual publication-blocking gates. These gates prevent ready-to-publish status but MUST NOT block local code verification.

#### Scenario: Gates documented as pending
- GIVEN repository documentation
- WHEN publication readiness is assessed
- THEN all three gates are listed as pending/manual

#### Scenario: Local verification proceeds despite gates
- GIVEN pending publication gates
- WHEN local build, test, or scan commands run
- THEN they execute and report results regardless of gate status
