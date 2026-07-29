# Specification: Prepare Public Portfolio Repository

## Domain: Trusted Admin User Provisioning

### Requirement: App Check Pre-Handler Enforcement

The system MUST export the callable with `onCall({ enforceAppCheck: true })` so the Firebase wrapper rejects requests with missing or invalid App Check tokens before invoking handler code. Required evidence is platform/edge Functions structured logging plus exported deployment metadata asserting the option. The handler SHALL NOT be required to create an audit record for requests that never enter it.

#### Scenario: Pre-handler App Check rejection evidence
- GIVEN a request with a missing or invalid App Check token
- WHEN the Firebase wrapper evaluates the callable gate
- THEN the wrapper rejects before handler entry
- AND platform/edge structured logs contain the denial
- AND no handler-created audit record exists for that request

#### Scenario: Deployment metadata asserts enforcement
- GIVEN the exported callable function
- WHEN its deployment options/metadata are inspected structurally
- THEN `enforceAppCheck` is bound to `true`

### Requirement: Recoverable Idempotent Provisioning Saga

The system MUST expose a trusted backend endpoint as the sole authority for provisioning Firebase Auth users with Firestore profile documents. Cross-service Auth + Firestore work SHALL be a recoverable idempotent saga, not atomic exactly-once. Transient recoverable internal state is permitted. The system MUST NOT report success until Auth creation, profile write, reset-link issuance, reservation completion, and required audit commitments are all established.

The system MUST persist a server-side reservation recording the intended UID before Auth creation. The reserved UID MAY be a generated identifier stored transactionally; the spec SHALL NOT require HMAC-derived deterministic UIDs or secret-key rotation.

Idempotency is scoped to the same provisioning operation on the same intended UID with a matching normalized fingerprint. An email or identity already owned by another UID or unrelated operation SHALL return a stable `already-exists`/conflict response without mutation; it SHALL NOT be reported as idempotent success.

The Flutter admin panel MUST initiate requests to this endpoint; direct client creation MUST NOT be possible.

#### Scenario: Successful provisioning
- GIVEN an authenticated admin with valid privileges and a well-formed request
- WHEN the saga completes Auth creation, profile write, reset-link, reservation completion, and audit
- THEN the system returns success with the provisioned identity

#### Scenario: Same-operation retry is idempotent
- GIVEN a prior successful provisioning for the same operation and intended UID with matching fingerprint
- WHEN the same request is retried
- THEN the system returns the same success outcome without duplicating resources or audit events

#### Scenario: Foreign existing identity is conflict
- GIVEN an email already owned by a different UID or unrelated operation
- WHEN a provisioning request targets that email
- THEN the system returns a stable `already-exists`/conflict without mutation
- AND no profile, claim, or deletion is attempted on the foreign identity

#### Scenario: Malformed input rejected
- GIVEN an authenticated admin
- WHEN the request contains invalid or missing fields
- THEN the backend rejects without creating any resources or reservation

#### Scenario: Role constrained to allowed profile set
- GIVEN an authenticated admin requesting roles
- WHEN a role outside the existing allowed profile set is requested
- THEN the backend rejects the request
- AND the system SHALL NOT grant admin privileges through provisioning
- AND roles SHALL be stored in the Firestore profile, not as Auth custom claims

#### Scenario: Recoverable partial state
- GIVEN Auth creation succeeds but a subsequent phase fails
- WHEN the system detects partial state
- THEN the saga compensates or retries without silent loss
- AND never reports success until all required commitments are established

#### Scenario: Compound failure never silently swallowed
- GIVEN a primary failure followed by a compensation or persistence error
- WHEN the system attempts recovery
- THEN the caller receives a stable error response
- AND structured logs retain both primary and recovery failure evidence without PII

### Requirement: Application Audit and Observability Contract

Authorization failures that reach the handler MUST produce a PII-safe structured application audit/log entry before any reservation or Auth/Firestore mutation. The system SHALL define required audit event categories (success, failure, authorization denial) with observable guarantees without over-specifying implementation schema. Events SHALL use stable operation/event identity so retries do not duplicate the same logical event. Platform App Check denials are the explicit exception, handled solely by platform/edge logs.

#### Scenario: Authorization denial audited before mutation
- GIVEN a caller that passes App Check but lacks admin authorization
- WHEN the handler evaluates authorization
- THEN a PII-safe structured audit entry is recorded
- AND no reservation, Auth, or Firestore mutation occurs

#### Scenario: Success and failure events are deduplicated
- GIVEN a provisioning operation with stable operation identity
- WHEN retries occur for the same logical event
- THEN the audit log does not duplicate the same event identity

#### Scenario: Unauthorized caller rejected with audit
- GIVEN a caller without valid authentication
- WHEN a provisioning request is submitted
- THEN the backend denies the request and records a PII-safe denial entry

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
