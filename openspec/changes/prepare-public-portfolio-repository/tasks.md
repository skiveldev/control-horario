# Tasks: Prepare Public Portfolio Repository

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: Accepted for P1–P4 via maintainer size:exception
Delivery strategy: exception-ok (P1–P4 only)
RDD routing: disabled — no automatic review activation. After cumulative backend emulator + TypeScript + independent phase-contract proof and candidate freeze at end of P3, surface explicit maintainer enable decision; no review before then.

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated aggregate changed lines (tasks-phase validated) | **3,690–5,030** |
| Aggregate ceiling | **None** — no invented aggregate ceiling; per-slice max governs |
| 400-line budget risk | Accepted for P1–P4 via maintainer size:exception |
| Delivery strategy | exception-ok (P1–P4 only) |
| Chain strategy | feature-branch-chain |
| Decision needed before apply | No (P1–P4 size/chaining resolved) |
| Slice count | 4 chained implementation slices (P1–P4) |
| Per-slice reforecast/STOP (P1–P4 only) | 1,700 |
| Per-slice absolute max (P1–P4 only) | 2,000 |
| Later independent chain | WU5–WU10 preserved (signing → de-branding → sanitization → README → archive → gates); each max 400, stop at 400; no inherited exception |

### Phase-Authority Decision

The previous `Decision needed before apply` workload/size question is resolved: maintainer has explicitly approved `size:exception` up to 2,000 lines per slice **for P1–P4 only**. **No workload decision remains for P1–P4.** WU5–WU10 retain ordinary max 400 per work unit; any future overrun in those work units requires a separate maintainer decision. Separately, **interactive phase approval + validated planning baseline** are still required before P1 may begin — that gate is about phase sequencing, not about size/chaining, and does not contradict the resolved workload decision.

### Supersession Notice

The prior 11-slice plan is **fully superseded**. The old 400-line per-slice budget is superseded by the maintainer-approved `size:exception` max 2,000 per slice **for P1–P4 only**. Old 1,500/1,690 WU4b bands and any prior aggregate ceiling are superseded. Per-slice max governs for P1–P4. WU5–WU10 operate under ordinary max 400, stop at 400.

### Tasks-Phase Forecast Refinement

The tasks-phase forecast refines the design grouping 3,050–3,880. Two rounds of refinement have been applied:

1. **First refinement (3,190–4,080)**: P4 was expanded to include the previously unallocated deferred Firestore rules hardening/proof demanded by the spec validator.
2. **Second refinement (3,690–5,030)**: Exact current-tree inspection revealed that P4's Flutter service/provider/drawer/tests footprint plus dependency/bootstrap/lockfile and Firestore rules work was omitted/understated in the first refinement. P4 expected increased from 400–550 to **900–1,500** to cover: `provisioning_service.dart` (callable transport + operationId persistence + polling/backoff/cancellation/restart), `firebase_service.dart` migration (remove EmployeeCreationService + direct Auth/profile paths), `user_management_provider.dart` + `new_employee_drawer.dart` (callable-based UX + reset-link display), `firebase_service.g.dart` regeneration, `pubspec.yaml` + `pubspec.lock` + `lib/main.dart` (App Check bootstrap), `firestore.rules` hardening, and 6 test files (`provisioning_service_test.dart`, `firebase_service_migration_test.dart`, `callable_transport_test.dart`, `app_check_activation_test.dart`, `new_employee_drawer_test.dart`, `firestore_rules.test.js`).

The tasks-phase aggregate **3,690–5,030** supersedes both the design 3,050–3,880 and the first refinement 3,190–4,080 for planning purposes; it is not a separate ceiling and no aggregate ceiling is introduced. P4 remains under approved reforecast 1,700 and max 2,000 working authority.

Per-slice breakdown (validated from design grouping + current-tree inspection):

| Slice | Focus | Expected |
|---|---|---:|
| P1 | Executable contract + persistence foundation (former S1–S3) | 950–1,180 |
| P2 | Submission + reliable dispatch (former S4–S6) | 660–890 |
| P3 | Worker + status + full backend proof (former S7–S10) | 1,180–1,460 |
| P4 | Flutter migration + Firestore rules hardening/proof + dependency/bootstrap (former S11 + deferred hardening + exact current-tree footprint) | 900–1,500 |
| **Total P1–P4** | | **3,690–5,030** |

P4 900–1,500 covers the full Flutter service/provider/drawer/tests footprint plus dependency manifests (pubspec.yaml + pubspec.lock), App Check bootstrap wiring in `lib/main.dart`, and Firestore rules hardening with emulator proof.

### Per-Slice Exception Boundaries (P1–P4 only)

| Slice | Reforecast/STOP | Absolute max |
|---|---:|---:|
| P1 | 1,700 | 2,000 |
| P2 | 1,700 | 2,000 |
| P3 | 1,700 | 2,000 |
| P4 | 1,700 | 2,000 |

WU5–WU10 do **not** inherit these boundaries. Each later work unit has max 400, stop at 400; any future overrun requires a separate maintainer decision.

### Line-Accounting Rules

- Per-slice expected range is the working budget for P1–P4.
- If measured changed lines reach 1,700 within any P1–P4 slice, **STOP** and reforecast. Continuation requires measured evidence and explicit continuation within the already-approved exception.
- If measured changed lines reach 2,000 within any P1–P4 slice, **STOP absolutely** — no further mutation in that slice.
- WU5–WU10 each have max 400; if measured changed lines reach 400 within any of them, **STOP** — continuation requires a new, separate maintainer decision (no inherited exception).
- apply-progress reconciliation lines in P1 count inside P1's range.
- Test files count toward the slice they verify (no test-only slice).

### Chain Topology (feature-branch-chain)

```
main
  └── feature/tracker (draft/no-merge) — accumulates final integration
        └── P1 branch (base: feature/tracker)
              └── P2 branch (base: P1)
                    └── P3 branch (base: P2)
                          └── P4 branch (base: P3)

Independent later chain (after P4 merges into tracker, tracker merges into main):
main ──→ WU5 (signing) ──→ WU6 (de-branding) ──→ WU7 (sanitization) ──→ WU8 (README) ──→ WU9 (archive) ──→ WU10 (gates)
```

Each child PR targets its immediate previous slice branch. Only the tracker ultimately targets `main`. No branch, commit, or PR is created in this planning phase.

## Authority Reconciliation and Historical Evidence

### Architecture Reset

The validated design replaces the callable-only saga with outbox + Cloud Tasks + scheduled-repair topology. Runtime is idle after explicit redesign reset at revision `sha256:47f0f905bafb2546b7d09ed5290d072840247ae3481520b3938b78440978d151`. Each runtime-bearing slice reads `gentle-ai sdd-attempt status`, begins exactly once only when `next_action=begin`, and finishes truthfully.

### Failed Ordinals (historical evidence only)

- **Ordinal 19**: failed; no completion carried forward.
- **Ordinal 20**: failed; no completion carried forward.
- **Stashes**: recorded as historical evidence only; never restored.

### Preserved Completion

| Work Unit | Status | Evidence |
|---|---|---|
| WU0 | Complete | Commit `4915419`, correction `3e9146f`, lineage `review-3b4a3a0f30245bc4` |
| WU1 | Complete | Commit `7772e14`, lineage `review-3447c0e8c1233521` |
| WU2 | Complete | Ordinal 6, generation 6 |
| WU3.1 | Complete | Deployment disclaimers retained |
| WU3.2 | Deferred | Review-rejected; re-apply only after trusted backend/client (now P4) |
| WU4a | Complete | Commit `a0a79cc` — dependency scaffold |

No false completion is carried forward from failed ordinals 19/20. WU4b/WU4c are fully replaced by P1–P4.

### Planning Baseline

This `tasks.md` revision, the current `spec.md`, and the current `design.md` are the validated planning baseline. No `sdd-apply` slice may begin until this baseline is intact. Planning spec/design/tasks changes require their own validated planning baseline before any apply slice.

### apply-progress Reconciliation

The FIRST apply mutation of P1 MUST be a metadata-only write to `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` that:

1. Records the architecture reset (outbox + Cloud Tasks + scheduled-repair design).
2. Records the stale WU4b/WU4c split as superseded by the 4-slice plan.
3. Records ordinals 19/20 as failed (no false implementation completion).
4. Preserves truthful WU0–WU4a completion byte-for-byte.
5. Does NOT claim any implementation progress.
6. Lines count inside P1's range.

## Executable Node Contract (strict TDD local harness)

- **Local Node prerequisite**: Node >= 22.6.0 (for `node --experimental-strip-types`).
- **Fail-fast version check**: every test/emulator invocation verifies `node --version` satisfies >= 22.6.0 and aborts otherwise.
- **Direct `.ts` invocation contract**: every direct `.ts` test invocation uses `node --experimental-strip-types` or an npm script routing to it.
- **TypeScript build separate**: `npx tsc --noEmit` is the type-checking command and is independent of the Node contract.
- **Strict TDD**: every behavior row requires RED before GREEN. No test may be retroactively labeled RED.

---

## P1 — Executable Contract + Persistence Foundation

**Objective**: author the independent pure reducer/reference model, frozen invariant vectors, normalization/fingerprint/IDs, strict in-memory reference store, Firestore emulator adapter with identical conformance/divergence vectors, canonical operation/dispatch/audit/profile schemas, full CAS/lease primitives, and pending+active terminalization primitives. Behavior and proof live in the same slice. No Firebase production adapter behavior beyond the Firestore conformance foundation.

**Spec traceability**: Requirement: Operation Invariants; Requirement: Auth Ambiguity and Reconstruction; Requirement: Bounded Retry and Terminal Failure Finalization; Requirement: Completion Atomic Commitment; Requirement: First-Slice Compensation Policy; Requirement: Operation Identity and Idempotency; Requirement: Application Audit and Observability Contract.

**Design traceability**: "Executable Contract Before Production Code"; persistence contracts; canonical vocabulary; full CAS and lease contract; deterministic IDs; retry and exhaustion semantics.

**Depends on**: — (first slice; base = `feature/tracker`).

**Base / branch**: `slice/p1-contract-persistence` branched from `feature/tracker`.

**Allowed paths** (exact):

- `functions/src/provisioning/model.ts` (new — pure reducer/types)
- `functions/src/provisioning/types.ts` (new — canonical vocabulary/types)
- `functions/src/provisioning/ids.ts` (new — deterministic ID derivation)
- `functions/src/provisioning/normalize.ts` (new — payload normalization + fingerprint)
- `functions/src/provisioning/store.ts` (new — domain port/interface)
- `functions/src/provisioning/memory_store.ts` (new — strict in-memory reference implementation)
- `functions/src/provisioning/firestore_store.ts` (new — Firestore emulator transaction adapter)
- `functions/src/provisioning/schemas.ts` (new — operation/dispatch/audit schema validators)
- `functions/src/provisioning/cas.ts` (new — full CAS predicates, lease helpers, terminalization helpers)
- `functions/src/provisioning/audit.ts` (new — audit event creation + dedup)
- `functions/src/provisioning/profile.ts` (new — provenance-tagged profile shape)
- `functions/test/provisioning/model.test.ts` (new — invariant + transition vectors)
- `functions/test/provisioning/ids.test.ts` (new — deterministic ID vectors)
- `functions/test/provisioning/normalize.test.ts` (new — normalization/fingerprint vectors)
- `functions/test/provisioning/fixtures.ts` (new — frozen vector fixtures)
- `functions/test/provisioning/store_conformance.test.ts` (new — shared conformance harness)
- `functions/test/provisioning/memory_store.test.ts` (new — in-memory-specific tests)
- `functions/test/provisioning/firestore_store.test.ts` (new — Firestore emulator conformance)
- `functions/test/provisioning/schemas.test.ts` (new — schema validation vectors)
- `functions/test/provisioning/cas.test.ts` (new — CAS predicate + lease + terminalization vectors against both stores)
- `functions/test/provisioning/audit.test.ts` (new — audit dedup + PII-safety vectors)
- `functions/test/provisioning/profile.test.ts` (new — provenance match/missing/mismatch vectors)
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata-only, one-time reconciliation — FIRST apply mutation of P1)

**Native `sdd-attempt` contract**:
- Work unit: P1
- Evidence goal: pure model + invariant vectors + reference store + Firestore adapter conformance + schemas + CAS primitives all green
- max = 2,000
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

### Strict TDD order (RED → GREEN)

- [ ] P1.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 before every test or emulator invocation.
- [ ] P1.1 METADATA (FIRST APPLY MUTATION): reconcile `apply-progress.md` recording architecture reset, superseded WU4b/WU4c/11-slice plan, failed ordinals 19/20, preserved WU0–WU4a, no false implementation completion.
- [ ] P1.2 RED: model types + reducer skeleton — every invariant test fails (compile error or assertion).
- [ ] P1.3 GREEN: implement pure reducer covering every valid `(state, event) -> state` row; status vocabulary exactly `pending | active | completed | failed | manual_recovery`; phase vocabulary exactly `dispatch_pending | auth_preflight | auth_create | profile_commit | terminal`; only valid `(status, phase)` pairs allowed.
- [ ] P1.4 RED: invariant vectors — terminal immutability, fingerprint stability, CAS monotonicity, dispatch ordering, no phantom Auth, no orphan dispatch, idempotent enqueue.
- [ ] P1.5 GREEN: every invariant vector passes; every command against each terminal status rejected without mutation.
- [ ] P1.6 RED: per-field CAS mutation suite — independently alter fingerprint, status, phase, generation, version, ownerToken, currentDispatchId, lease liveness; each stale mutation fails; exact live tuple succeeds.
- [ ] P1.7 GREEN: per-field CAS mutation suite passes.
- [ ] P1.8 RED: pending terminalization guard — independently mutate fingerprint, status, phase, generation, version, ownerToken, lease, authAttempted, authAttempt, current dispatch ID, dispatch identity/source tuple, worker ack; every mismatch blocks `failed/unavailable`.
- [ ] P1.9 GREEN: pending terminalization guard passes; exact initial state commits failure + audit + ack once.
- [ ] P1.10 RED: active terminalization classifier — exact initial pending state; pending predicate mismatch; active with exact current owner + live lease; active with another owner's unexpired lease (no steal); active with expired lease (takeover); terminal operation idempotent.
- [ ] P1.11 GREEN: active terminalization classifier passes.
- [ ] P1.12 RED: retry threshold vectors — `retryCount` 0–7 may work; 8–11 terminalize only; no fictional exhaustion callback; pre-handler 5xx semantics.
- [ ] P1.13 GREEN: retry threshold vectors pass.
- [ ] P1.14 RED: Auth create result matrix — exact live intent CAS to `call_started`; exact returned UID + email with both reads agreeing; malformed/ambiguous/timeout/crash -> `manual_recovery`; definite no-effect with both indexes proving absence; foreign UID/email before intent -> `failed/already-exists`.
- [ ] P1.15 GREEN: Auth create result matrix passes; no repeated ambiguous create; no automatic deletion.
- [ ] P1.16 RED: crash-point vectors around every external effect — before/after Auth intent, Auth call, Auth return, dual reads, proof commit, profile/completion commit.
- [ ] P1.17 GREEN: crash-point vectors pass.
- [ ] P1.18 RED: completion atomicity vector — profile + completed + success audit + ack appear together or not at all.
- [ ] P1.19 GREEN: completion atomicity passes.
- [ ] P1.20 RED: data immutability vector — operation identity/payload/UID, audit identity, dispatch identity, provenance, Auth proof cannot change.
- [ ] P1.21 GREEN: data immutability passes.
- [ ] P1.22 RED: deterministic ID vectors — `dispatchId`, `taskId`, `auditEventId`, `attemptId`, `ownerToken`, `fingerprint` derivation from canonical inputs.
- [ ] P1.23 GREEN: deterministic ID vectors pass.
- [ ] P1.24 RED: normalization/fingerprint vectors — canonical key order, NFC, trimmed, email lower-cased, blank optionals null, dates UTC YYYY-MM-DD, defaults exactly `weeklyHours=40`, `employeeId=""`, `isSupervisor=false`, `supervisorId=null`, `isActive=true`; roles exactly `employee | rrhh`; unknown keys rejected; `displayName` derived.
- [ ] P1.25 GREEN: normalization/fingerprint vectors pass.
- [ ] P1.26 RED: domain port (`Store`) — type-level compile failure until interface defined.
- [ ] P1.27 GREEN: define `Store` port with transactional semantics (read, write, CAS, transaction wrapper); no Firebase import in the port.
- [ ] P1.28 RED: in-memory reference store — every conformance vector fails.
- [ ] P1.29 GREEN: implement in-memory store; pass every frozen conformance vector from the model.
- [ ] P1.30 RED: Firestore emulator adapter — every conformance vector fails against real emulator.
- [ ] P1.31 GREEN: implement Firestore adapter using real `firebase-admin` transactions against the Firestore emulator; pass every frozen vector.
- [ ] P1.32 RED: divergence test — run identical conformance vectors against both stores and assert byte-equal outcomes.
- [ ] P1.33 GREEN: divergence test passes; any reference-vs-emulator difference fails the build.
- [ ] P1.34 RED: crash-point schedule around every transaction boundary — abort simulation, retry, idempotent re-entry.
- [ ] P1.35 GREEN: crash-point schedule passes for both stores identically.
- [ ] P1.36 RED: operation schema validator — every invalid field combination fails.
- [ ] P1.37 GREEN: operation schema validator; valid combinations pass; invalid rejected.
- [ ] P1.38 RED: dispatch schema validator — immutable identity + enqueue/ack updates only.
- [ ] P1.39 GREEN: dispatch schema passes.
- [ ] P1.40 RED: audit schema + PII-safety — no raw email, names, DNI, telephone, body, token, reset link, SDK message in any audit field.
- [ ] P1.41 GREEN: audit schema passes; PII-safety scan passes.
- [ ] P1.42 RED: CAS primitives — full tuple predicate, lease check (server time), terminalization helper, generation fence.
- [ ] P1.43 GREEN: CAS primitives pass against both stores.
- [ ] P1.44 RED: audit dedup — same `auditEventId` with matching identity fields is idempotent; mismatched identity fails.
- [ ] P1.45 GREEN: audit dedup passes.
- [ ] P1.46 RED: profile provenance match — UID + email + operationId + fingerprint + schema version + every normalized field must all match.
- [ ] P1.47 GREEN: profile provenance passes.
- [ ] P1.48 REFACTOR: freeze model + invariants + stores + schemas + CAS primitives.

### Verification commands

- `cd functions && node --experimental-strip-types test/provisioning/model.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/ids.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/normalize.test.ts`
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/firestore_store.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/store_conformance.test.ts"`
- `cd functions && node --experimental-strip-types test/provisioning/memory_store.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/schemas.test.ts`
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/cas.test.ts"`
- `cd functions && node --experimental-strip-types test/provisioning/audit.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/profile.test.ts`
- `cd functions && npx tsc --noEmit`

### Rollback boundary

Revert all `functions/src/provisioning/*` source files listed above, delete all `functions/test/provisioning/*` test files listed above, revert `apply-progress.md` to pre-P1 state. Pure model + emulator-only code — fully removable without unrelated rollback.

### Forbidden actions

No submission callable. No outbox trigger. No scheduled sweeper. No task worker. No status callable. No Auth.createUser call. No push/PR/deploy. No modification of `spec.md` or `design.md`. No modification of `D:\control_horario`.

### Handoff contract to P2

Frozen pure model + invariant table + frozen conformance vectors + frozen ID/normalization modules + frozen stores + frozen schemas + frozen CAS/audit primitives. P2 builds the submission callable and dispatch machinery using these.

---

## P2 — Submission + Reliable Dispatch

**Objective**: implement the `submitProvisioning` App Check-enforced callable, authorization/denial audit, safe status DTO projection, atomic operation+initial outbox transaction, shared Cloud Tasks enqueue adapter, created-only retry-enabled trigger, scheduled stale-outbox sweeper, deterministic task IDs, `ALREADY_EXISTS` acceptance, guarded acknowledgement, trigger/sweeper race safety, and the repository-preparation metadata for indexes, IAM, schedule, trigger, and monitoring/alerting/runbook.

**Spec traceability**: Requirement: App Check Pre-Handler Enforcement; Requirement: Asynchronous Provisioning Submission; Requirement: Operation Identity and Idempotency; Requirement: Autonomous Backend Liveness; Requirement: Protected Status Query; Requirement: Application Audit and Observability Contract; Requirement: Explicit Non-Goals and Compatibility.

**Design traceability**: Callable contracts and security; submission transaction; outbox enqueue; scheduled outbox repair; repository files and deployment metadata; risks and operational controls.

**Depends on**: P1 (frozen foundation).

**Base / branch**: `slice/p2-submission-dispatch` branched from `slice/p1-contract-persistence`.

**Allowed paths** (exact):

- `functions/src/provisioning/submit.ts` (new — submission handler)
- `functions/src/provisioning/dto.ts` (new — safe status DTO projection)
- `functions/src/provisioning/authz.ts` (new — admin authorization + denial audit)
- `functions/src/provisioning/enqueue.ts` (new — shared adapter + contract + fake)
- `functions/src/provisioning/outbox.ts` (new — created-trigger fast path)
- `functions/src/provisioning/outbox_repair.ts` (new — scheduled handler)
- `functions/src/index.ts` (new — callable exports with `enforceAppCheck:true`, Admin SDK init, created-trigger export, scheduled export)
- `functions/package.json` (minimal scripts/emulator additions if not in WU4a)
- `firebase.json` (Functions emulator port wiring if not in WU4a)
- `firestore.indexes.json` (add operation/dispatch/audit indexes + sweeper query index `(enqueued, createdAt, __name__)`)
- `functions/test/provisioning/submit.test.ts` (new — submission behavior)
- `functions/test/provisioning/authz.test.ts` (new — authorization/denial)
- `functions/test/provisioning/dto.test.ts` (new — DTO projection)
- `functions/test/export-metadata.test.ts` (new — `enforceAppCheck:true` structural proof)
- `functions/test/provisioning/enqueue.test.ts` (new — adapter contract + production adapter contract)
- `functions/test/provisioning/outbox.test.ts` (new — trigger behavior + race vectors)
- `functions/test/provisioning/outbox_repair.test.ts` (new — sweeper handler behavior)
- `functions/test/provisioning/trigger_metadata.test.ts` (new — created-trigger retry/options structural proof)
- `functions/test/provisioning/scheduler_metadata.test.ts` (new — schedule/cadence/retry/timeout structural proof: `retryCount=3`, `minBackoffSeconds=30`, `maxBackoffSeconds=300`, `maxDoublings=2`, `maxInstances=1`, `timeoutSeconds=240`, every-5-minute cadence)
- `functions/test/provisioning/monitoring_metadata.test.ts` (new — `outbox_stale_age_seconds` threshold 900s, Eventarc trigger error alert, sweeper error + missing-execution alert, Cloud Tasks enqueue/attempt-exhaustion alert; structural proof only, no production deployment)
- `functions/test/provisioning/iam_metadata.test.ts` (new — least-privilege service accounts; task queue name; task retry/rate limits; task OIDC identity; Scheduler invoker; Eventarc trigger metadata; Cloud Tasks enqueuer role; required Firestore/Auth permissions; environment/project placeholders)
- `functions/test/provisioning/structural_absence.test.ts` (new — BACKEND-only structural boundary proof: scans ONLY Functions/`functions/` scope; required P2 Functions production files/exports/metadata exist and are wired; forbidden backend-only patterns absent (no raw HTTP task/callable workaround, no automatic Auth deletion, no client Firebase secondary-app logic copied into Functions, no unsafe direct profile mutation outside approved transaction primitives, no missing `enforceAppCheck:true` metadata on exported callables); MUST NOT require Flutter/client pattern removal; genuine RED before P2 Functions files exist; client structural absence is owned by P4 via Dart migration tests)
- `docs/operations/outbox-recovery-runbook.md` (new — PII-safe operator runbook: restore Eventarc/Scheduler/Tasks first, invoke same repair handler or wait for schedule, verify deterministic enqueue acknowledgement, inventory still-stale dispatches, never mutate Auth/profile/operation directly)

**Native `sdd-attempt` contract**:
- Work unit: P2
- Evidence goal: submission callable + dispatch machinery + metadata proof all green
- max = 2,000
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

### Strict TDD order (RED → GREEN)

- [ ] P2.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [ ] P2.1 RED: admin authorization — unauthenticated -> `unauthenticated`; non-admin -> `permission-denied`; denial audit written before any mutation.
- [ ] P2.2 GREEN: authorization + denial audit pass.
- [ ] P2.3 RED: App Check metadata — `enforceAppCheck:true` structural assertion on exported callable. This test MUST be run RED against the WU4a placeholder BEFORE the callable export is introduced.
- [ ] P2.4 GREEN: export callable with `enforceAppCheck:true`; metadata test passes.
- [ ] P2.5 RED: submission handler — invalid schema -> `invalid-argument`; role not in `employee|rrhh` -> `invalid-argument`; missing `operationId/email/nombre/apellido1` -> `invalid-argument`.
- [ ] P2.6 GREEN: schema validation passes.
- [ ] P2.7 RED: submission transaction — atomic operation + initial dispatch creation; no Auth call; no profile write; return `{operationId, status:'pending'}`.
- [ ] P2.8 GREEN: submission transaction passes.
- [ ] P2.9 RED: idempotent replay — same `(operationId, fingerprint)` returns current safe status; different fingerprint returns `already-exists` without mutation.
- [ ] P2.10 GREEN: idempotent replay passes.
- [ ] P2.11 RED: safe DTO projection — each status projects only its safe fields; no raw email, owner, lease, generation/version, evidence, audit identity, reset link leaked.
- [ ] P2.12 GREEN: DTO projection passes.
- [ ] P2.13 RED: PII-safe log/audit structural check — application logs contain only allowlisted codes and domain-separated digests.
- [ ] P2.14 GREEN: PII-safety passes.
- [ ] P2.15 RED: enqueue adapter contract — injectable interface; strict fake proves outbox idempotency.
- [ ] P2.16 GREEN: adapter contract + strict fake pass.
- [ ] P2.17 RED: production adapter contract — deterministic queue/task construction from dispatch identity; same task ID for same dispatch.
- [ ] P2.18 GREEN: production adapter contract passes.
- [ ] P2.19 RED: created-trigger handler — validates immutable dispatch shape; calls shared adapter; success or `ALREADY_EXISTS` followed by guarded ack transaction (exact dispatch identity + `enqueued=false` -> `enqueued=true`).
- [ ] P2.20 GREEN: trigger behavior passes; duplicate event, enqueue success, crash-before-ack, `ALREADY_EXISTS`, invalid dispatch, guarded ack, trigger+sweeper race vectors pass.
- [ ] P2.21 RED: sweeper handler — invoke directly with Firestore-emulator records + shared enqueue adapter; 10-minute grace edge; `(enqueued, createdAt, __name__)` ordering/cursors; 100x5 bounds; rate/concurrency limits.
- [ ] P2.22 GREEN: sweeper handler behavior passes.
- [ ] P2.23 RED: sweeper forbidden operations — must NOT execute saga phases, mutate Auth/profile/operation state, acknowledge worker completion, create dispatches, or invent task identities.
- [ ] P2.24 GREEN: forbidden operations test passes.
- [ ] P2.25 RED: trigger+sweeper race — one enqueue wins, the other observes `ALREADY_EXISTS`; either acknowledgement wins while the other verifies `enqueued=true`.
- [ ] P2.26 GREEN: race passes.
- [ ] P2.27 RED: partial failure/throw — per-record failure logs PII-safe digests; run processes its bounded page, then throws so Scheduler retry + next regular schedule repair.
- [ ] P2.28 GREEN: partial failure/throw passes.
- [ ] P2.29 RED: trigger metadata structural proof — retry-enabled `onDocumentCreated`, `retry:true`.
- [ ] P2.30 GREEN: trigger metadata passes.
- [ ] P2.31 RED: scheduler metadata structural proof — `retryCount=3`, `minBackoffSeconds=30`, `maxBackoffSeconds=300`, `maxDoublings=2`, `maxInstances=1`, `timeoutSeconds=240`, every-5-minute cadence.
- [ ] P2.32 GREEN: scheduler metadata passes.
- [ ] P2.33 RED: monitoring metadata structural proof — alert names/thresholds documented (no production alert created).
- [ ] P2.34 GREEN: monitoring metadata passes.
- [ ] P2.35 RED: IAM metadata structural proof — least-privilege service accounts; queue; OIDC; Scheduler invoker; Eventarc trigger; enqueuer role; required Firestore/Auth permissions; environment/project placeholders.
- [ ] P2.36 GREEN: IAM metadata passes; no production project ID/secret/role binding/queue/scheduler job/alert/deployment created.
- [ ] P2.37 RED: structural boundary (BACKEND-only) — BEFORE P2 Functions production files exist, test requires BOTH: (a) required P2 Functions production files/exports/metadata exist and are wired (`submit.ts` submission handler, `enqueue.ts` shared adapter, `outbox.ts` created trigger, `outbox_repair.ts` scheduled sweeper, `index.ts` callable exports with `enforceAppCheck:true`, metadata tests for trigger/scheduler/monitoring/IAM paths); these are absent before P2, guaranteeing genuine RED; (b) forbidden BACKEND-only patterns remain absent in `functions/` scope (no raw HTTP task/callable workaround, no automatic Auth deletion, no client Firebase secondary-app logic copied into Functions, no unsafe direct profile mutation outside approved transaction primitives, no missing `enforceAppCheck:true` metadata on exported callables). Test scans ONLY Functions/`functions/` backend scope and MUST NOT require Flutter/client pattern removal. Test fails RED because required Functions files/exports are missing.
- [ ] P2.38 GREEN: structural boundary (BACKEND-only) passes AFTER P2 implementation — all required P2 Functions production files exist and are wired in Functions scope; forbidden backend-only patterns remain absent in Functions scope. Client structural absence (secondary Firebase app, direct client Auth creation, direct profile write, client compensation, temp passwords) is P4's responsibility via `firebase_service_migration_test.dart` and related client/UI path tests.
- [ ] P2.39 REFACTOR: write `docs/operations/outbox-recovery-runbook.md`; add all index additions to `firestore.indexes.json`; `npx tsc --noEmit` green.

### Verification commands

- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/submit.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/authz.test.ts"`
- `cd functions && node --experimental-strip-types test/provisioning/dto.test.ts`
- `cd functions && node --experimental-strip-types test/export-metadata.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/enqueue.test.ts`
- `cd functions && npx firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox_repair.test.ts"`
- `cd functions && node --experimental-strip-types test/provisioning/trigger_metadata.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/scheduler_metadata.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/monitoring_metadata.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/iam_metadata.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/structural_absence.test.ts` (must fail RED before P2 Functions production files exist; must pass GREEN after P2 Functions implementation; BACKEND-only structural boundary; does not require Flutter/client pattern removal)
- `cd functions && npx tsc --noEmit`

### Rollback boundary

Revert `submit.ts`, `dto.ts`, `authz.ts`, `enqueue.ts`, `outbox.ts`, `outbox_repair.ts`, `index.ts`; revert `functions/package.json` and `firebase.json` additions; revert `firestore.indexes.json` additions; delete all `functions/test/provisioning/{submit,authz,dto,enqueue,outbox,outbox_repair,trigger_metadata,scheduler_metadata,monitoring_metadata,iam_metadata,structural_absence}.test.ts` and `functions/test/export-metadata.test.ts`; delete `docs/operations/outbox-recovery-runbook.md`. P1 foundation intact.

### Forbidden actions

No task worker. No status callable. No Auth.createUser call. No reset link generation. No push/PR/deploy. No production Scheduler job/Cloud Tasks queue/Eventarc trigger/alert created. No modification of P1 frozen artifacts. No modification of `spec.md` or `design.md`. No modification of `D:\control_horario`.

### Handoff contract to P3

Frozen submission callable + callable export with `enforceAppCheck:true` metadata + frozen shared enqueue adapter + frozen created-trigger + frozen sweeper + frozen indexes + frozen runbook. P3 builds the task worker + status callable + full backend integration proof.

---

## P3 — Worker + Status + Full Backend Proof

**Objective**: implement the one-effect-boundary `onTaskDispatched` worker, Auth preflight/intent/create/dual-index reconstruction/manual recovery/no-deletion, profile+completed+success audit+ack atomicity, 12/8 pending+active terminalization, `getProvisioningStatus` callable with completed-integrity checks and fresh reset link generation, final exports and IAM metadata, and the full test suite (unit, crash, threshold, task HTTP, true concurrency, outbox race, full emulator integration). Because behavior and full proof share P3, same-slice backend corrections are allowed until final proof/freeze; no frozen-backend contradiction within this slice. After the last source mutation: aggregate emulator, TypeScript, independent phase-contract validation, candidate freeze. RDD remains disabled; surface explicit maintainer enable decision only after all gates.

**Spec traceability**: all provisioning-domain requirements.

**Design traceability**: Worker acquisition and intent; Auth create result matrix; profile and completion; retry and exhaustion semantics; callable contracts and security; emulator and verification strategy.

**Depends on**: P2 (frozen dispatch).

**Base / branch**: `slice/p3-worker-proof` branched from `slice/p2-submission-dispatch`.

**Allowed paths** (exact):

- `functions/src/provisioning/worker.ts` (new — task worker entry)
- `functions/src/provisioning/boundaries.ts` (new — one-boundary-per-dispatch handlers: acquire, auth_preflight, auth_create, profile_commit)
- `functions/src/provisioning/terminalization.ts` (new — reserved-attempt classifier)
- `functions/src/provisioning/status.ts` (new — status handler)
- `functions/src/index.ts` (add task function export + status callable export)
- `functions/test/provisioning/worker_auth.test.ts` (new — Auth matrix vectors)
- `functions/test/provisioning/worker_profile.test.ts` (new — profile completion vectors)
- `functions/test/provisioning/worker_crash.test.ts` (new — crash injection around every effect)
- `functions/test/provisioning/terminalization_pending.test.ts` (new)
- `functions/test/provisioning/terminalization_active.test.ts` (new)
- `functions/test/provisioning/threshold.test.ts` (new — 12/8 protocol, pre-handler 5xx, no fictional callback)
- `functions/test/provisioning/status.test.ts` (new)
- `functions/test/provisioning/completed_integrity.test.ts` (new)
- `functions/test/provisioning/integration.test.ts` (new — full emulator flow)
- `functions/test/provisioning/concurrency.test.ts` (new — true parallel clients/workers)
- `functions/test/provisioning/outbox_race.test.ts` (new — trigger+sweeper race, duplicate/out-of-order, crash before/after enqueue, task already exists)
- `functions/test/provisioning/retry.test.ts` (new — retry threshold, poison, reserved attempts, pre-handler 5xx)

**P2 frozen test consumption**: P3 may RUN the pre-existing `functions/test/provisioning/structural_absence.test.ts` as cumulative regression verification during `npm test` and full-suite invocations. P3 MUST treat this test as pre-existing/read-only — never modify, migrate, or delete it. P2 handoff marks it frozen; P3 consumes it unchanged.

**Native `sdd-attempt` contract**:
- Work unit: P3
- Evidence goal: task worker + status callable + full backend proof green; candidate freeze
- max = 2,000
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

### Strict TDD order (RED → GREEN)

- [ ] P3.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [ ] P3.1 RED: worker acquisition — acquire/take over lease; duplicate/out-of-order/terminal deliveries atomically mark dispatch stale and return 2xx; never advance operation state.
- [ ] P3.2 GREEN: acquisition passes.
- [ ] P3.3 RED: Auth preflight — mandatory UID + email reads before any create; foreign UID/email before intent -> `failed/already-exists`; no Auth mutation.
- [ ] P3.4 GREEN: preflight passes.
- [ ] P3.5 RED: Auth intent — one transaction flips `authAttempted=true`, persists `authAttempt.result=intent`, audit, version, deterministic `auth_create` dispatch, current ack.
- [ ] P3.6 GREEN: intent commit passes.
- [ ] P3.7 RED: Auth create boundary — CAS to `call_started`; call create once; exact return + UID/email reads + proof commit -> `profile_commit`; malformed/ambiguous/timeout/crash -> `manual_recovery` (no delete); definite no-effect -> back to `auth_preflight`.
- [ ] P3.8 GREEN: Auth create boundary passes; no repeated ambiguous create; no automatic deletion.
- [ ] P3.9 RED: profile_commit boundary — requires persisted Auth proof + mandatory matching UID/email reads; one transaction creates/verifies operation-matching profile + `completed/terminal` + `success.completed` audit + current ack; all-or-nothing.
- [ ] P3.10 GREEN: profile_commit passes; conflicting profile -> `manual_recovery`; no deletion.
- [ ] P3.11 RED: crash injection around every external effect — before/after enqueue, Auth intent, Auth call, Auth return, each dual read, proof commit, profile/completion commit.
- [ ] P3.12 GREEN: crash injection passes.
- [ ] P3.13 RED: true parallel emulator clients/workers — at least two actual parallel clients for one operation proving lease + CAS semantics (sequential mocks do not qualify).
- [ ] P3.14 GREEN: true parallel test passes.
- [ ] P3.15 RED: Functions emulator task endpoint — task worker exercised via authenticated HTTP POST to Functions emulator task endpoint with controlled TaskContext headers (no `emulators.tasks` config).
- [ ] P3.16 GREEN: Functions emulator task endpoint test passes.
- [ ] P3.17 RED: pending classifier — exact initial pending state predicate; writes `failed/terminal` + `version=1` + `terminalCode=unavailable` + retry evidence + failure audit + current dispatch `workerAck=terminalized` atomically.
- [ ] P3.18 GREEN: pending classifier passes.
- [ ] P3.19 RED: pending predicate mismatch — do not infer safety; reread + reclassify as exact pending/active/terminal; second mismatch/CAS loss returns success with no mutation.
- [ ] P3.20 GREEN: pending mismatch passes.
- [ ] P3.21 RED: active with exact current owner + live lease — require complete active CAS tuple; safe phase -> `failed/unavailable`; otherwise -> `manual_recovery/internal`; evidence + audit + owner/lease clear + current ack commit together.
- [ ] P3.22 GREEN: active exact-owner passes.
- [ ] P3.23 RED: active with another owner's unexpired lease — no steal, no mutation; CAS loss returns success.
- [ ] P3.24 GREEN: active foreign-owner passes.
- [ ] P3.25 RED: active with expired lease — first transaction requires full observed expired tuple, increments generation + version, installs new owner token + live lease; same invocation applies complete active terminalization guard using the exact new tuple.
- [ ] P3.26 GREEN: expired-lease takeover passes.
- [ ] P3.27 RED: terminal operation — return success without operation mutation or new audit; existing dispatch acknowledgement idempotent.
- [ ] P3.28 GREEN: terminal idempotency passes.
- [ ] P3.29 RED: 12/8 protocol — `retryCount` 0–7 may work; 8–11 terminalize only; pre-handler 5xx semantics; no fictional post-exhaustion callback; permanent durable-store outage -> alert + runbook, not silent success.
- [ ] P3.30 GREEN: 12/8 protocol passes.
- [ ] P3.31 RED: reserved attempts 8, 9, 10, 11 repeat only guarded terminalization paths; failed terminalization transaction throws so next reserved attempt retries; committed terminal returns success.
- [ ] P3.32 GREEN: reserved-attempt idempotency passes.
- [ ] P3.33 RED: status authorization — unauthenticated -> `unauthenticated`; non-admin -> `permission-denied`; unknown operationId -> `not-found`; optional fingerprint mismatch -> `already-exists`; no mutation on either path.
- [ ] P3.34 GREEN: status authorization passes.
- [ ] P3.35 RED: status DTO projection — each status returns only its safe fields; no raw email/owner/lease/generation/version/evidence/audit identity.
- [ ] P3.36 GREEN: DTO projection passes.
- [ ] P3.37 RED: completed integrity — re-read both Auth indexes + full provenance-tagged profile; failure or inconsistency returns stable integrity error without changing terminal operation or generating a link; deduplicated integrity audit.
- [ ] P3.38 GREEN: completed integrity passes.
- [ ] P3.39 RED: fresh reset link — Auth `generatePasswordResetLink` called only after integrity passes; link returned; link never stored, logged, audited, or emailed; transient link failure returns stable retryable error leaving `completed` unchanged.
- [ ] P3.40 GREEN: reset link passes.
- [ ] P3.41 RED: full emulator flow — happy-path submission through to completed status with fresh reset link; no client-driven re-drive.
- [ ] P3.42 GREEN: full emulator flow passes.
- [ ] P3.43 RED: outbox race — trigger+sweeper race; duplicate event; out-of-order delivery; crash before enqueue; crash after enqueue; task already exists (`ALREADY_EXISTS` accepted).
- [ ] P3.44 GREEN: outbox race passes.
- [ ] P3.45 RED: retry threshold conformance — `retryCount` 7/8/9/10/11; pre-handler 5xx first entry at >=8; reserved attempts terminalize only; poison behavior; no fictional exhaustion callback.
- [ ] P3.46 GREEN: retry conformance passes.
- [ ] P3.47 RED: Auth emulator matrix — foreign pre-attempt identity; exact create result; both UID/email reads; ambiguity; provenance conflict; all-or-nothing completion; completed integrity; no automatic deletion.
- [ ] P3.48 GREEN: Auth matrix passes.
- [ ] P3.49 RED: emulator/concurrency end-to-end — lease expiry/takeover; duplicate/out-of-order delivery; crash injection around every effect; first entry after pre-handler retries; exact pending guard per-field mutations; pending mismatch reclassification; active live owner; foreign live owner; expired takeover; terminal idempotency; failed reserved terminalization.
- [ ] P3.50 GREEN: end-to-end passes.
- [ ] P3.51 REFACTOR: finalize all callable exports; `npx tsc --noEmit` green; full `npm test` green.
- [ ] P3.52 FREEZE: aggregate emulator + TypeScript + independent phase-contract validation + candidate freeze. RDD remains disabled; surface explicit maintainer enable decision at this point.

### Verification commands

- `cd functions && npm test` (full suite: unit + emulator + metadata)
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/worker_auth.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/worker_profile.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/worker_crash.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/terminalization_pending.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/terminalization_active.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/threshold.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/status.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/completed_integrity.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/integration.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/concurrency.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/outbox_race.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/retry.test.ts"`
- `cd functions && npx tsc --noEmit`

### Rollback boundary

Revert `worker.ts`, `boundaries.ts`, `terminalization.ts`, `status.ts`; revert `index.ts` additions; delete all P3 test files. P2 intact, including the frozen `functions/test/provisioning/structural_absence.test.ts` which P3 consumed as read-only cumulative regression verification and must NOT modify or delete.

### Forbidden actions

No Flutter client change yet (P4). No production deploy. No modification of P1/P2 frozen artifacts (except where P3's own same-slice backend corrections require it before the final freeze). No modification of `spec.md` or `design.md`. No modification of `D:\control_horario`. No automatic Auth deletion. No fictional post-exhaustion callback. No sequential-mock-labeled-as-concurrency.

### Handoff contract to P4

Frozen full backend capability + complete integration proof. P4 migrates the Flutter client and hardens Firestore rules.

---

## P4 — Flutter Migration + Firestore Rules Hardening

**Objective**: replace `EmployeeCreationService` direct provisioning with callable submission + status polling + reset link UX; persist operationId across restarts; remove secondary Firebase app, direct client Auth creation, direct profile write, client compensation, and temp password path; harden `firestore.rules` to deny client `/users` creation and privileged mutation while Admin SDK path is emulator-proven; wire `cloud_functions` + `firebase_app_check` dependencies and App Check activation in the bootstrap path before any protected callable call; focused Dart tests + Firestore rules emulator tests in the same slice. Dependency manifests, lock file, bootstrap lines, and full Flutter service/provider/drawer/tests footprint count within P4's 900–1,500 expected band.

**Spec traceability**: Requirement: Client Provisioning Migration; Requirement: Client-Side Write Denial.

**Design traceability**: Flutter product flow.

**Depends on**: P3 (frozen backend + full proof).

**Base / branch**: `slice/p4-flutter-rules` branched from `slice/p3-worker-proof`.

**Allowed paths** (exact):

- `pubspec.yaml` (modified — add compatible `cloud_functions` + `firebase_app_check` dependencies)
- `pubspec.lock` (regenerated by `flutter pub get`; dependency resolution manifest)
- `lib/main.dart` (modified — activate Firebase App Check via `firebase_app_check` plugin before any protected callable call; emulator/debug behavior explicit)
- `lib/core/services/firebase_service.dart` (modified — remove `EmployeeCreationService` class and direct Auth/profile paths; retain `firestore`, `firebaseAuth`, `scheduleService`, `calendarService` providers)
- `lib/core/services/provisioning_service.dart` (new — Riverpod service wrapping `submitProvisioning` + `getProvisioningStatus` callables + operationId persistence + polling/backoff/cancellation/restart)
- `lib/core/services/firebase_service.g.dart` (regenerated by Riverpod generator)
- `lib/features/admin/providers/user_management_provider.dart` (modified — replace `EmployeeCreationService` call with `ProvisioningService` call; accept operationId-based result instead of `{userId,temporaryPassword,employeeId}`)
- `lib/features/admin/presentation/widgets/new_employee_drawer.dart` (modified — replace temp-password display with reset-link display + copyable link + admin-must-deliver copy; preserve operationId for support on failed/manual_recovery)
- `test/features/admin/presentation/widgets/new_employee_drawer_test.dart` (modified — replace `_SpyEmployeeCreationService` with callable transport fake; test reset-link UX, operationId persistence, polling/backoff/cancel, terminal result presentation)
- `test/core/services/provisioning_service_test.dart` (new — callable payload construction, success mapping, every stable error code, operationId retry reuse, backoff/jitter, cancel, restart from persisted operationId; callable transport uses official `cloud_functions` plugin)
- `test/core/services/firebase_service_migration_test.dart` (new — structural absence: secondary Firebase app, direct client Auth creation, direct profile write, client compensation, temp passwords all absent)
- `test/core/services/callable_transport_test.dart` (new — prove provisioning callable transport uses official `cloud_functions` plugin; no manual raw HTTP workaround; App Check activation wired before protected calls)
- `test/main/app_check_activation_test.dart` (new — App Check plugin activated before any protected callable invocation in bootstrap path; emulator/debug behavior explicit; no missing activation)
- `firestore.rules` (modified — deny client `/users` creation; deny privileged field mutation; deny self-escalation; allow Admin SDK; emulator-proven)
- `test/firestore/firestore_rules.test.js` (modified — deny client create for employee/rrhh/admin roles; deny privileged mutation; allow Admin SDK)

**Stable error vocabulary** (exactly):

- `unauthenticated`
- `permission-denied`
- `invalid-argument`
- `not-found`
- `already-exists`
- `aborted`
- `unavailable`
- `internal`

Stable error vocabulary is exactly the list above; no other codes.

**Native `sdd-attempt` contract**:
- Work unit: P4
- Evidence goal: Flutter migration + Firestore rules hardening green
- max = 2,000
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

### Strict TDD order (RED → GREEN)

- [ ] P4.0 ENTRY/FAIL-FAST: verify Flutter/Dart toolchain present.
- [ ] P4.1 RED: `pubspec.yaml` — add compatible `cloud_functions` + `firebase_app_check` dependency declarations; `flutter pub get` fails because packages are not yet resolvable until versions align (initial RED).
- [ ] P4.2 GREEN: version-compatible `cloud_functions` + `firebase_app_check` entries resolve; `flutter pub get` succeeds; `pubspec.lock` generated with deterministic resolution; `flutter pub get` is idempotent.
- [ ] P4.3 RED: callable transport — provisioning service calls must use official `cloud_functions` `HttpsCallable`; any raw HTTP workaround (manual `http.Client`, `fetch`, non-Firebase transport) fails the transport contract test.
- [ ] P4.4 GREEN: callable transport uses official `cloud_functions` plugin; no manual raw HTTP workaround for `submitProvisioning` or `getProvisioningStatus`.
- [ ] P4.5 RED: App Check activation strict awaited order — bootstrap path (`lib/main.dart`) must execute in strict awaited order: (1) `await Firebase.initializeApp(...)` completes, (2) `await FirebaseAppCheck.instance.activate(...)` completes with explicit debug/emulator providers (debug secret or platform-appropriate debug provider in `kDebugMode`, production provider in release mode), (3) provisioning service/callable transport can be constructed/invoked. Test fails if callable is available before activation completes or if activation order is violated. No raw HTTP workaround; official plugins only.
- [ ] P4.6 GREEN: App Check activated in bootstrap before protected callables; emulator/debug provider behavior explicit (debug secret or platform-appropriate debug provider in `kDebugMode`); production provider in release mode.
- [ ] P4.7 RED: dependency/bootstrap integration — provisioning callable transport depends on App Check having been activated; transport test fails if App Check activation is absent from bootstrap.
- [ ] P4.8 GREEN: dependency/bootstrap integration passes; `flutter pub get` + `flutter analyze` + Dart tests all green.
- [ ] P4.9 RED: Dart unit tests — callable payload construction, success result mapping, every stable error code (`already-exists`, `aborted`, `unavailable`, `internal`, `unauthenticated`, `permission-denied`, `invalid-argument`, `not-found`), operationId retry reuse.
- [ ] P4.10 GREEN: Dart unit tests pass using fake callable transport only.
- [ ] P4.11 RED: polling/backoff/jitter — delays `1s,2s,4s,8s`, then capped `15s` with jitter; polling cancels on drawer disposal/logout; pauses offline/backgrounded; resumes from persisted operationId after restart by querying status, never by resubmitting; `retryAfterSeconds` may lengthen but not shorten local backoff.
- [ ] P4.12 GREEN: polling tests pass.
- [ ] P4.13 RED: persistence — operationId created and durably stored before submission; restart observes persisted operationId.
- [ ] P4.14 GREEN: persistence tests pass.
- [ ] P4.15 RED: UX — completed UI presents copyable reset link with admin-must-deliver copy; failed/manual_recovery UI shows stable actionable copy and preserves operationId for support.
- [ ] P4.16 GREEN: UX tests pass.
- [ ] P4.17 RED: structural absence — secondary Firebase app, direct client Auth creation, direct profile write, client compensation, temp passwords all absent from the migrated path.
- [ ] P4.18 GREEN: structural absence passes.
- [ ] P4.19 RED: Firestore rules deny with exact error code — safe self-creation denied; admin creating employee via direct client denied; admin creating rrhh via direct client denied; rrhh creating employee via direct client denied; privileged field mutation denied; self-escalation denied. Each denial MUST assert Firebase error code exactly `permission-denied` (not generic rejection or `assertFails` only).
- [ ] P4.20 GREEN: Firestore rules deny with exact `permission-denied` error code passes; Admin SDK write still permitted (emulator-proven) — Admin SDK bypass success remains separately proven.
- [ ] P4.21 REFACTOR: `flutter analyze --no-pub --fatal-infos --fatal-warnings` clean; `dart format` clean; regenerate `firebase_service.g.dart`.

### Verification commands

- `flutter pub get` (bounded setup — dependency resolution manifest consistency; not a production action)
- `flutter analyze --no-pub --fatal-infos --fatal-warnings lib/main.dart lib/core/services/provisioning_service.dart lib/core/services/firebase_service.dart lib/features/admin/providers/user_management_provider.dart lib/features/admin/presentation/widgets/new_employee_drawer.dart test/core/services/ test/features/admin/presentation/widgets/new_employee_drawer_test.dart test/main/`
- `dart format --output=none --set-exit-if-changed lib/ test/`
- `flutter test test/core/services/provisioning_service_test.dart test/core/services/firebase_service_migration_test.dart test/core/services/callable_transport_test.dart test/features/admin/presentation/widgets/new_employee_drawer_test.dart test/main/app_check_activation_test.dart`
- `npx firebase emulators:exec --only firestore "node --test test/firestore/firestore_rules.test.js"`
- No production App Check registration or deploy as part of P4 verification.

### Rollback boundary

Revert `pubspec.yaml` (remove `cloud_functions` + `firebase_app_check` additions); revert `pubspec.lock` (remove generated resolution entries); revert `lib/main.dart` (remove App Check activation); revert `lib/core/services/firebase_service.dart`, `lib/core/services/firebase_service.g.dart`, `lib/features/admin/providers/user_management_provider.dart`, `lib/features/admin/presentation/widgets/new_employee_drawer.dart`, `firestore.rules`; delete `lib/core/services/provisioning_service.dart`, `test/core/services/provisioning_service_test.dart`, `test/core/services/firebase_service_migration_test.dart`, `test/core/services/callable_transport_test.dart`, `test/main/app_check_activation_test.dart`; revert `test/features/admin/presentation/widgets/new_employee_drawer_test.dart` and `test/firestore/firestore_rules.test.js` to pre-P4 state. P3 backend intact.

### Forbidden actions

No backend source change. No emulator test for backend behavior (already proven in P3). No re-proof of backend behavior. No push/PR/deploy. No skip-hooks. No modification of unrelated Flutter files. No modification of `spec.md` or `design.md`. No modification of `D:\control_horario`.

### Handoff contract to WU5 (later independent chain)

P4 completes the trusted provisioning chain and Firestore rules hardening. After P4 merges into `feature/tracker` and `feature/tracker` merges into `main`, the independent WU5–WU10 chain may proceed.

---

## WU5 — Android Release-Signing Guard

**Objective**: enforce Android release-build failure when signing config/keystore secrets are absent, ensuring no release build is ever producible without explicit signing setup.

**Spec traceability**: Requirement: Release Signing Enforcement; Requirement: Protected Path Immutability.

**Depends on**: P4 (trusted provisioning chain complete).

**Entry gates**:

- P4 accepted (Flutter migration merged into tracker → main).
- Clean base advanced past P4 commit.
- `android/app/build.gradle.kts` exists (current Kotlin DSL file); `.gitignore` exists; release signing config/keystore are absent or incomplete in `build.gradle.kts` (RED baseline); `.gitignore` patterns for `*.jks`, `*.keystore`, `key.properties`, `release-signing.properties` are absent or incomplete (RED baseline — WU5 adds them).

**Strict TDD order**:

- [ ] 5.1 RED: prove release build/config validation in `android/app/build.gradle.kts` fails clearly without signing inputs; prove required `.gitignore` patterns (`*.jks`, `*.keystore`, `key.properties`, `release-signing.properties`) are currently absent or incomplete.
- [ ] 5.2 GREEN: `android/app/build.gradle.kts` Kotlin DSL signing block with fail-fast error when signing config/keystore absent; `.gitignore` excludes keystore and signing-secret files (`*.jks`, `*.keystore`, `key.properties`, `release-signing.properties`).
- [ ] 5.3 REFACTOR: verify no secrets committed; document in repository.

**Entry/exit evidence**:

- Focused test command: `cd android && ./gradlew assembleRelease` (expected: fails with clear error message about missing signing config when keystore absent).
- Runtime harness: plain `./gradlew assembleRelease` in CI/dev without keystore files — must fail loudly.
- Rollback boundary: revert `android/app/build.gradle.kts` Kotlin DSL signing block and `.gitignore` additions.
- Allowed paths: `android/app/build.gradle.kts`, `.gitignore`.
- max = 400; stop at 400. No inherited exception — any overrun requires a new maintainer decision.

**Native `sdd-attempt` contract**:
- Work unit: WU5
- Evidence goal: release build fails without signing; no secrets committed
- max = 400; stop at 400 (no inherited exception; future overrun requires new maintainer decision)
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

**Exit gates**:

- `./gradlew assembleRelease` without keystore fails with clear error.
- `.gitignore` contains keystore/signing patterns.
- Protected paths `.atl/*` and `lib/core/theme/app_colors.dart` byte-identical to base.
- No secrets in git history at added lines.

---

## WU6 — Generic Organization De-Branding

**Objective**: replace organization identifiers with generic placeholders in metadata while retaining application name `controlhorario-rega`; verify protected paths untouched.

**Spec traceability**: Requirement: Generic Organization Data.

**Depends on**: WU5.

**Entry gates**:

- WU5 accepted.
- Clean base advanced past WU5 commit.

**Strict TDD order**:

- [ ] 6.1 Replace organization identifiers with generic placeholders in metadata; retain application name `controlhorario-rega`.
- [ ] 6.2 Verify protected paths `.atl/*` and `lib/core/theme/app_colors.dart` are untouched.

**Entry/exit evidence**:

- Focused test command: grep for retained app name; byte-hash comparison of protected paths.
- Runtime harness: N/A (metadata replacement only).
- Rollback boundary: revert branding replacements; protected paths unaffected.
- Allowed paths: `pubspec.yaml`, `android/app/build.gradle.kts` (organization identifier/applicationId only — Kotlin DSL), `ios/Runner.xcodeproj/project.pbxproj` (organization identifier only), other metadata files that carry organization identifiers. Not `lib/core/theme/app_colors.dart`, not `.atl/*`, not application name.
- max = 400; stop at 400. No inherited exception — any overrun requires a new maintainer decision.

**Native `sdd-attempt` contract**:
- Work unit: WU6
- Evidence goal: organization identifiers generic; protected paths byte-identical
- max = 400; stop at 400 (no inherited exception; future overrun requires new maintainer decision)
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

**Exit gates**:

- Grep for retained app name `controlhorario-rega` succeeds.
- Organization identifier values replaced with generic placeholders.
- Protected paths `.atl/*` / `lib/core/theme/app_colors.dart` byte-identical to base.

---

## WU7 — Repository Sanitization and Protected-Path Checks

**Objective**: secret/PII scan of current tree (excluding protected paths); replace production claims with truthful portfolio-mode statements.

**Spec traceability**: Requirement: Current-Tree Credential and PII Removal.

**Depends on**: WU6.

**Entry gates**:

- WU6 accepted.
- Clean base advanced past WU6 commit.

**Strict TDD order**:

- [ ] 7.1 Secret/PII scan of current tree; remove hits (excluding protected paths).
- [ ] 7.2 Replace production claims with truthful portfolio-mode statements.

**Entry/exit evidence**:

- Focused test command: N/A (scan + textual replacement).
- Runtime harness: secret-scan tooling (custom regex scan or existing tool) over current tree.
- Rollback boundary: revert only sanitized non-protected paths.
- Allowed paths: any non-protected path identified by scan. Not `.atl/*`, not `lib/core/theme/app_colors.dart`.
- max = 400; stop at 400. No inherited exception — any overrun requires a new maintainer decision.

**Native `sdd-attempt` contract**:
- Work unit: WU7
- Evidence goal: secret/PII scan clean; production claims replaced
- max = 400; stop at 400 (no inherited exception; future overrun requires new maintainer decision)
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

**Exit gates**:

- Scan clean; protected paths byte-identical to base.
- Production claims replaced with truthful portfolio-mode statements.
- No new secrets introduced at added lines.

---

## WU8 — Portfolio README Rewrite

**Objective**: rewrite `README.md` as portfolio codebase with no live-demo promise; ensure publication gates visible and listed as pending/manual.

**Spec traceability**: Requirement: Repository-Only Portfolio Presentation; Requirement: Publication Gate Visibility.

**Depends on**: WU7.

**Entry gates**:

- WU7 accepted.
- Clean base advanced past WU7 commit.

**Strict TDD order**:

- [ ] 8.1 Rewrite `README.md` as portfolio codebase with no live-demo promise.
- [ ] 8.2 Publication gates visible and listed as pending/manual.

**Entry/exit evidence**:

- Focused test command: N/A (documentation rewrite).
- Runtime harness: structural grep for deployment/demo promises absent; three gates documented.
- Rollback boundary: revert `README.md`.
- Allowed paths: `README.md`.
- max = 400; stop at 400. No inherited exception — any overrun requires a new maintainer decision.

**Native `sdd-attempt` contract**:
- Work unit: WU8
- Evidence goal: README portfolio-appropriate; three gates documented
- max = 400; stop at 400 (no inherited exception; future overrun requires new maintainer decision)
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

**Exit gates**:

- Grep for deployment/demo promises absent.
- Three publication gates (license selection, reachable-history cleanup, Firebase Console verification) documented as pending/manual.

---

## WU9 — docs/archive Removal Plus Secret Scan

**Objective**: remove `docs/archive/` entirely; post-removal secret scan of entire tree.

**Spec traceability**: Requirement: Repository-Only Portfolio Presentation.

**Depends on**: WU8.

**Entry gates**:

- WU8 accepted.
- Clean base advanced past WU8 commit.
- `docs/archive/` exists in current tree.

**Strict TDD order**:

- [ ] 9.1 Remove `docs/archive/` entirely.
- [ ] 9.2 Post-removal secret scan of entire tree.

**Entry/exit evidence**:

- Focused test command: `ls docs/archive/` expected to fail (directory absent).
- Runtime harness: secret scan over current tree after archive removal.
- Rollback boundary: restore `docs/archive/` from base.
- Allowed paths: `docs/archive/**` (deletion only).
- max = 400; stop at 400. No inherited exception — any overrun requires a new maintainer decision.

**Native `sdd-attempt` contract**:
- Work unit: WU9
- Evidence goal: archive directory absent; scan clean
- max = 400; stop at 400 (no inherited exception; future overrun requires new maintainer decision)
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

**Exit gates**:

- `docs/archive/` absent.
- Secret scan clean over entire tree.
- Protected paths byte-identical to base.

---

## WU10 — Publication Gates Documentation and Final No-Publication Boundary

**Objective**: document license selection, reachable-history cleanup, and Firebase Console verification as manual publication-blocking gates; affirm no publication-safety claim is made while any gate remains.

**Spec traceability**: Requirement: Publication Gate Visibility.

**Depends on**: WU9.

**Entry gates**:

- WU9 accepted.
- Clean base advanced past WU9 commit.

**Strict TDD order**:

- [ ] 10.1 Document license selection, reachable-history cleanup, and Firebase Console verification as manual publication-blocking gates.
- [ ] 10.2 Affirm no publication-safety claim is made while any gate remains.

**Entry/exit evidence**:

- Focused test command: N/A (documentation).
- Runtime harness: structural grep — three gates listed as pending/manual.
- Rollback boundary: revert gate-documentation edits.
- Allowed paths: documentation files (e.g., `README.md`, `docs/` non-archive paths). Not code.
- max = 400; stop at 400. No inherited exception — any overrun requires a new maintainer decision.

**Native `sdd-attempt` contract**:
- Work unit: WU10
- Evidence goal: three gates documented as publication blockers
- max = 400; stop at 400 (no inherited exception; future overrun requires new maintainer decision)
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

**Exit gates**:

- All three gates listed as pending/manual.
- No publication-safety claim in tree while any gate remains.
- Local test commands remain independent of publication.

---

## Global Forbidden Actions (all slices)

- No push, no PR, no deploy, no visibility or account action, no history rewrite.
- No skip-hooks, no `opencode run --agent`.
- No modification of `D:\control_horario`.
- No production credentials, no production project ID, no production deploy of any kind.
- No modification of `spec.md` or `design.md` in this phase.
- No sequential-mock-labeled-as-concurrency.
- No implementation-authored fake passing as conformance.
- No automatic Auth deletion.
- No fictional post-exhaustion callback.
- No `emulators.tasks` config block.
- No secondary Firebase app in backend after P3.
- No direct client Auth/profile/compensation/temp-password path after P4.

## Global Verification Contract (per slice)

Every slice MUST deliver:

- Focused test command and exact result.
- Runtime harness command/scenario and exact result, or explicit `N/A` with reason.
- Rollback boundary stated independently of commit creation.
- Native `sdd-attempt` begin/finish evidence with `next_action=begin` respected.

**Exception scope**:

- P1–P4: max 2,000 changed lines per slice; reforecast/stop at 1,700; absolute stop at 2,000. Maintainer-approved `size:exception`.
- WU5–WU10: max 400 changed lines per work unit; stop at 400. **No inherited exception** — any overrun requires a new, separate maintainer decision.

## SDD Result Contract

| Field | Value |
|---|---|
| status | success |
| executive_summary | Replaced the 11-slice plan with 4 chained implementation slices (P1–P4) under maintainer-approved `size:exception` max 2,000 per slice (P1–P4 only), reforecast/stop at 1,700. Tasks-phase aggregate forecast refined to **3,690–5,030** (second refinement: P4 increased from 400–550 to 900–1,500 based on exact current-tree inspection of Flutter service/provider/drawer/tests + dependency/bootstrap/lockfile + Firestore rules footprint omitted/understated earlier; supersedes prior aggregates 3,050–3,880 and 3,190–4,080). delivery_strategy = `exception-ok` (P1–P4 only); chain_strategy = `feature-branch-chain`. WU5–WU10 retain ordinary max 400 each with no inherited exception; any overrun requires a new maintainer decision. WU0–WU4a preserved truthfully. Failed ordinals 19/20 recorded as historical evidence only. Architecture reset `sha256:47f0f905` acknowledged. RDD disabled; maintainer gate required after P3 cumulative proof/freeze. |
| artifacts | `openspec/changes/prepare-public-portfolio-repository/tasks.md` (corrective rewrite); Engram topic `sdd/prepare-public-portfolio-repository/tasks` (capture_prompt:false) |
| corrected_forecast_math | P1 950–1,180 + P2 660–890 + P3 1,180–1,460 + P4 900–1,500 = **3,690–5,030**. Second refinement: P4 increased from 400–550 to 900–1,500 based on exact current-tree inspection (Flutter service/provider/drawer/tests + dependency/bootstrap/lockfile + Firestore rules footprint omitted/understated earlier). Prior aggregates 3,050–3,880 / 3,190–4,080 are superseded. |
| narrow_blocker_corrections | (1) P4 forecast corrected from 400–550 to 900–1,500 based on exact current-tree inspection; aggregate refined to 3,690–5,030. (2) P2 structural boundary test redefined to require BOTH required P2 production files/exports exist AND forbidden patterns absent; genuine RED guaranteed before P2 implementation. (3) P4 App Check activation enforces strict awaited order: `Firebase.initializeApp` → `FirebaseAppCheck.instance.activate` (with explicit debug/emulator providers) → callable transport available; test fails if callable available before activation. (4) P4 Firestore rules deny test asserts exact `permission-denied` error code for client denials; Admin SDK bypass success separately proven. (5) P2 structural boundary test redefined as BACKEND-only: scans ONLY Functions/`functions/` scope for forbidden patterns (no raw HTTP task/callable workaround, no automatic Auth deletion, no client Firebase secondary-app logic copied into Functions, no unsafe direct profile mutation outside approved transaction primitives, no missing App Check callable metadata); MUST NOT require Flutter/client pattern removal; client structural absence owned by P4 via Dart migration tests. (6) P3 no longer owns/migrates/deletes `functions/test/provisioning/structural_absence.test.ts`; P3 may RUN the frozen P2 test as cumulative regression verification read-only; P3 rollback explicitly preserves P2 frozen test. (7) WU5 file path corrected from `android/app/build.gradle` to `android/app/build.gradle.kts` (verified Kotlin DSL); entry gate no longer requires signing ignore patterns already present (WU5 adds them); RED baseline proves signing config absent + `.gitignore` patterns missing; GREEN adds Kotlin DSL signing guard + `.gitignore` patterns. (8) WU6 Gradle path corrected from `android/app/build.gradle` to `android/app/build.gradle.kts` (organization identifier/applicationId in Kotlin DSL; de-branding legitimately changes Android metadata). (9) Test-file count text corrected from "5 test files" to "6 test files" to match the six files listed (`provisioning_service_test.dart`, `firebase_service_migration_test.dart`, `callable_transport_test.dart`, `app_check_activation_test.dart`, `new_employee_drawer_test.dart`, `firestore_rules.test.js`). |
| exception_scope | `size:exception` max 2,000 and reforecast/stop at 1,700 apply **only to P1–P4**. WU5–WU10 each have max 400, stop at 400, no inherited exception; future overrun requires a separate maintainer decision. |
| task_structure | 4 chained slices P1–P4 + preserved WU5–WU10 with full self-contained checklists (entry/exit/paths/rollback preserved) |
| delivery_plan | feature-branch-chain; each child PR targets immediate previous slice branch; only tracker targets main |
| preserved_completion | WU0 (`4915419`/`3e9146f`), WU1 (`7772e14`), WU2 (ordinal 6), WU3.1, WU4a (`a0a79cc`) — all truthful |
| risks | Implementation complexity (3,690–5,030 lines across P1–P4); per-slice reforecast boundary discipline (P1–P4 only); WU5–WU10 each bounded at 400 with independent overrun gate; Flutter polling UX latency; Cloud Tasks queue configuration; Eventarc/Scheduler/Cloud Tasks simultaneous outage (alert + runbook, not silent success); P4 App Check bootstrap ordering discipline; Firestore rules exact `permission-denied` code assertion |
| next_recommended | `sdd-apply` — but requires **interactive phase approval + validated planning-baseline validation first**. No slice may begin until `sdd-attempt status` reports `next_action=begin` for that slice. |
| skill_resolution | `sdd-tasks` + `work-unit-commits` + `chained-pr` + `cognitive-doc-design` |
