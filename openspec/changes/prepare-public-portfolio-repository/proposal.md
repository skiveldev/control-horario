# Proposal: Prepare Public Portfolio Repository

## Intent

Remediate the current repository tree for security-first portfolio review while preserving audited portions of the interrupted remediation. This change improves the code and documentation but MUST NOT claim publication readiness until legal, history, Firebase Console, and other manual gates are complete.

## Scope

### In Scope
- Keep the admin-panel creation UX, replacing direct client provisioning with an authenticated trusted backend using Firebase Admin SDK, constrained roles, audit records, and compensating rollback.
- Harden Firestore authorization; sanitize current-tree secrets, PII, claims, generic domain data, and metadata while retaining `controlhorario-rega`.
- Enforce release-signing/secret hygiene; remove `docs/archive/`; audit and partition the interrupted diff into <=400-authored-line work units.

### Out of Scope
- License selection; public live demo; deploy, stage, commit, push, visibility/account changes.
- Reachable-history cleanup: a separate authorized change requiring an external mirror backup.
- Automated mutation, restoration, or attribution of `.atl/skill-registry.md`, `.atl/.skill-registry.cache.json`, or `lib/core/theme/app_colors.dart` following the incident.

## Capabilities

### New Capabilities
- `trusted-admin-user-provisioning`: Admin UI calls a backend that verifies administrators, validates inputs/roles, creates Auth + Firestore identity, and audits partial failure/rollback.
- `publication-sanitization`: Current-tree secret/PII/claim removal and generic organization data.
- `secure-android-signing-secret-hygiene`: Protected signing inputs and release fail-fast behavior.
- `portfolio-metadata-docs-boundary`: Repository-only presentation, truthful metadata, and removal of archived/internal material.

### Modified Capabilities
- `firestore-authorization-hardening`: Deny direct client `/users` creation, privileged assignment, self-escalation, and unsafe profile updates.

## Approach

Audit the existing diff rather than blanket-revert it. Deliver autonomous chained work units within the 400-line budget, keeping behavior, tests, docs, verification, and path-specific rollback together. Complete backend provisioning before treating hardened rules and admin integration as functional.

## Affected Areas

| Area | Impact | Description |
|---|---|---|
| `firestore.rules`, `test/firestore/**` | Modified | Authorization contract/tests |
| admin UI/services, trusted backend | Modified/New | Provisioning boundary |
| `android/**`, `.gitignore`, scripts/docs/metadata | Modified/Removed | Signing and sanitization |

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Historic credentials remain reachable | High | Block publication; authorize separate backed-up rewrite |
| Interrupted diff mixes ownership | High | Path audit; protected-path exclusion |
| Partial identity creation | Medium | Idempotency, audit trail, compensating cleanup |

## Rollback Plan

Revert only the failing work unit's enumerated paths/behavior. Never blanket-restore the tree or touch protected paths. Disable backend exposure before reverting client integration or rules.

## Dependencies

- Owner license decision, authorized history-cleanup change, and manual Firebase Console hardening/verification remain publication gates.

## Success Criteria

- [ ] Rules tests and backend authorization/role/failure tests pass; client admin flow uses the backend and direct provisioning is absent.
- [ ] Current-tree secret/PII scan is clean; no credentials or production claims remain.
- [ ] Release signing guard passes; `docs/archive/` is absent; protected paths are unchanged.
- [ ] License, reachable-history, and Firebase Console gates are visible; no publication-safety claim is made while any gate remains.
