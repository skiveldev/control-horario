# Specification: Prepare Public Portfolio Repository

## Domain: Trusted Admin User Provisioning

### Requirement: Backend-Only User Creation

The system MUST expose a trusted backend endpoint as the sole authority for creating Firebase Auth users, writing initial Firestore user documents, and assigning privileged roles. The Flutter admin panel MUST initiate requests to this endpoint; direct client creation MUST NOT be possible.

#### Scenario: Admin creates a user successfully
- GIVEN an authenticated admin with valid privileges
- WHEN a well-formed account-creation request is submitted
- THEN the backend creates the Auth user, writes the Firestore document, assigns constrained roles, and returns success with an audit record

#### Scenario: Unauthorized caller rejected
- GIVEN a caller without admin authorization
- WHEN an account-creation request is submitted
- THEN the backend denies the request and logs the attempt

#### Scenario: Malformed input rejected
- GIVEN an authenticated admin
- WHEN the request contains invalid or missing fields
- THEN the backend rejects without creating any resources

#### Scenario: Duplicate/idempotent request
- GIVEN an authenticated admin targeting an already-existing identity
- WHEN the creation request is submitted
- THEN the backend returns an idempotent response without duplicating resources

#### Scenario: Partial Auth/Firestore failure compensated
- GIVEN Auth user creation succeeds but Firestore write fails
- WHEN the backend detects partial state
- THEN the backend compensates or surfaces failure with audit evidence

#### Scenario: Privileged role constrained
- GIVEN an authenticated admin requesting a role outside the allowed set
- WHEN the request is submitted
- THEN the backend rejects the request

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
