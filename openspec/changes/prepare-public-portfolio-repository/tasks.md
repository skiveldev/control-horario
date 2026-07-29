# Tasks: Prepare Public Portfolio Repository

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: High

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated changed lines (WU4b) | 1,300-1,535 expected; 1,690 contingency |
| Estimated changed lines (WU4c) | 170-210 expected; 250 contingency |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR #1 (tracker, draft/no-merge) <- WU4a scaffold (already merged as `a0a79cc`) <- PR #2 WU4b <- PR #3 WU4c <- PR #4+ WU5-WU10 |
| Delivery strategy | ask-on-risk, already resolved to chained execution |
| Chain strategy | feature-branch-chain |
| Decision needed before apply | No (chained execution already authorized) |
| size:exception | WU4b: maintainer-bounded, forecast 1,500 / contingency 1,690 / reforecast-band ceiling 1,690 / scope-decision 1,850 / redesign 1,850–1,999 / absolute ceiling 2,000. WU4c: ordinary chain (<=400). |
| Selective RDD routing | WU4b gets exactly one RDD run only after emulator + TypeScript + independent phase-contract proof and candidate freeze. WU4c receives RDD only if its actual changed paths cross a critical boundary; otherwise ordinary functional/structural verification. Planning and intermediate implementation receive no RDD. |

```
Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: High
```

## Authority Reconciliation (authoritative for this phase)

This tasks revision supersedes the stale WU4b/WU4c/WU5 split recorded in the historical `apply-progress.md` (which listed WU4b = implementation only, WU4c = tests, WU5 = admin client). That file must be corrected before implementation claims further progress.

The next authorized `sdd-apply` writer MUST make the FIRST apply mutation a metadata-only merge to `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` that:
- Records the stale WU4b/WU4c/WU5 split as superseded by the corrected design.
- Records ordinals 14 and 15 as failed (no false completion carried forward).
- Does NOT claim any implementation progress.
- Stays within line accounting and rollback scope of WU4b.

This path is explicitly authorized inside the WU4b allowed metadata paths. It is a one-time reconciliation, not an ongoing write channel.

The corrected design (`design.md`) is authoritative. It requires:

- **WU4b**: the complete backend capability (callable + saga) together with **all** backend proof (unit, fault-injection, Functions/Auth/Firestore emulator via callable client, deployment-metadata assertion, TypeScript build, exact all-path line accounting, and independent phase-contract validation). No backend test may move to a proof-only work unit.
- **WU4c**: the spec-required Flutter callable migration and its focused Dart proof, depending on the accepted WU4b contract.
- **No WU5** as an independent client bucket — client work is folded into WU4c. Old WU5-WU11 renumber to WU5-WU10.

WU4a at commit `a0a79cc` (dependency scaffold) is complete. WU4, WU4b, WU4c are pending. No false completion from failed ordinals 14/15 is carried forward.

## Dependency Graph

```
WU0 (pre-commit hook) -> WU1 (tatus deletion) -> WU2 (seed credentials) -> WU3.1 (deployment disclaimers)
                                                                                        |
                                                                                        v
WU4a (scaffold, a0a79cc) ----> WU4b (backend saga + all proof) ----> WU4c (Flutter migration)
                                                                               |
                                                                               v
                                                             WU5 (Android signing) -> WU6 (de-branding)
                                                                               |
                                                                               v
                                                             WU7 (sanitization) -> WU8 (README)
                                                                               |
                                                                               v
                                                             WU9 (docs/archive + scan) -> WU10 (gates)
```

Cross-cutting:
- WU3.2 (firestore rules hardening) remains review-rejected/deferred and may only be re-applied after WU4b provides the trusted backend; it is not renumbered here and stays associated with its original deferred slot.
- WU4c depends on accepted WU4b contract/export (callable signature, error codes, operationId semantics).
- WU5-WU10 are independent of each other except WU7/WU8/WU9/WU10 which form a publication-sanitization chain.

## Line-Guard Matrix (exact, non-overlapping, non-negotiable)

| Band | Changed lines | Action |
|---|---|---|
| Ordinary progress | 0–1,500 | Continue bounded progress; track cumulative count. |
| Reforecast band | 1,501–1,690 | STOP. Remeasure all paths and reforecast before any further mutation. Continuation only if evidence still supports ≤1,690 contingency. |
| Scope-decision band | 1,691–1,849 | NO implementation continuation without a new explicit maintainer scope decision and revised plan. |
| Redesign/split band | 1,850–1,999 | Mandatory redesign/split stop. No further work until the change is split or redesigned. |
| Absolute ceiling | ≥2,000 | Absolute forbidden ceiling. Never approached as working budget. |

Note: 1,690 is the upper bound of the reforecast contingency band, NOT a hard ceiling. Work above 1,500 requires evidence, not automatic continuation. The 2,000 absolute ceiling is never a working budget target.

| Field | Value |
|---|---|
| WU4b forecast | 1,500 changed lines |
| WU4b contingency | 1,690 changed lines (upper bound of reforecast band) |
| WU4c forecast | 210 changed lines |
| WU4c contingency | 250 changed lines |
| RDD invocation | any — only after candidate freeze, phase-contract proof, and emulator/TS gates green |
| Strict TDD violation | any — RED must precede source in every WU4b/WU4c cycle |

## Delivery & Runtime (unchanged)

Auth for WU0 worktree+branch. WU0 review/commit first, then escrow WU1 patch, clear only those paths, advance base to WU0 commit, reapply patch, verify identity/revalidation, WU1 commit under existing/renewed auth. WU2 blocked until WU1 parent. Every runtime-bearing WU: `gentle-ai sdd-attempt status/begin/finish` keyed by change+work unit. Native ledger sole authority; no caller counters. Direct Task reviewer; no `opencode run --agent`/skip-hooks.

## Executable Node Contract (WU4b local test harness)

Firebase deployment runtime compatibility (Node 20+ for Cloud Functions v2) is distinct from the local TypeScript test harness requirements.

**Local Node prerequisite**: Node >= 22.6.0 is required because the test harness uses `node --experimental-strip-types` to execute `.ts` test files directly without a build step. This flag is only supported from Node 22.6.0 onward.

**Fail-fast version check**: Before any test or emulator execution, the harness MUST verify `node --version` satisfies `>= 22.6.0`. If the check fails, execution MUST abort with a clear error message naming the minimum version. No test command may silently run under an unsupported Node version.

**Direct `.ts` test invocation contract**: Every direct `.ts` test invocation — including emulator commands — MUST use one of:
- `node --experimental-strip-types <test-file.ts>` directly, OR
- An npm script that internally uses `node --experimental-strip-types` (e.g., `npm test` routing to the same flag).

The emulator verification command in WU4b already satisfies this contract: `npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning.emulator.test.ts"`.

**TypeScript build is separate**: `npx tsc --noEmit` is the explicit TypeScript type-checking command. It does not use `--experimental-strip-types` and is independent of the Node version contract. It must remain green but is not a test execution mechanism.

**No package.json modification in this phase**: This contract defines the required flag and version but does not itself modify `package.json`. Any npm script additions belong to the WU4b implementation scope and must respect the same flag requirement.

## WU0 — CANDIDATE (maintainer size:exception <=800)

Complete. Final committed as `4915419`, correction commit `3e9146f`. Lineage `review-3b4a3a0f30245bc4`.

## WU1 — COMPLETE

Commit `7772e14`. Lineage `review-3447c0e8c1233521`. Only `tatus` deletion remained.

## WU2 — COMPLETE

Seed-script credential purge.

## WU3 — PARTIAL (3.1 complete; 3.2 review-rejected/deferred)

3.1 deployment disclaimers retained. 3.2 Firestore `/users` denial deferred until trusted backend exists.

## WU4a — COMPLETE

Dependency scaffold at commit `a0a79cc`: `functions/package.json`, `functions/package-lock.json`, `functions/tsconfig.json`, `functions/src/placeholder.ts`, `firebase.json` functions block. Atomic lockfile exception (max 3100).

---

## WU4 — PENDING (aggregate of WU4a complete + WU4b + WU4c pending)

WU4 is the full trusted-backend provisioning capability. WU4a is done; WU4b and WU4c are not.

### WU4b — Backend provisioning saga + all backend proof (one reviewable work unit)

**Scope** (single unit; behavior + proof bundled):

- Production callable and saga implementation under `functions/src/index.ts` and `functions/src/provisioning.ts`.
- Unit/fault-injection tests under `functions/test/provisioning.unit.test.ts` covering every matrix row (normalization, fingerprint, schema/role denial, every CAS predicate, every transition and reconstruction row, stable event IDs, single and compound failures including persistence/compensation/observability/logger).
- Emulator/concurrency tests under `functions/test/provisioning.emulator.test.ts` with Functions/Auth/Firestore emulators driven through the exported callable client: two actual parallel clients for one operation, stale owner takeover, shared-state reconstruction, UID absent/matching/mismatched/read-failure, profile absent/matching/conflicting, reset-link failure, compensation/delete failure, completed-state missing/conflicting resources, authorization-before-mutation, audit dedup.
- Deployment-metadata assertion under `functions/test/export-metadata.test.ts` proving the exported v2 endpoint binds `enforceAppCheck:true`; `.run()` supplements handler tests only.
- Minimal scripts/emulator wiring in `functions/package.json` and `firebase.json`.
- TypeScript build proof: `npx tsc --noEmit` green from the WU4a scaffold with WU4b source in place.
- Exact all-path line accounting against the design matrices (Acquisition+Transition and Reconstruction) with candidate freeze before RDD.
- **One** selective RDD run, gated on: emulator green + TypeScript green + independent phase-contract validation of candidate + candidate freeze. RDD is not invoked before all prior gates pass.

**Entry gates**:

- WU4a scaffold committed at `a0a79cc`.
- Clean worktree base; no leftover `functions/src/index.ts` or `functions/test/create_user.test.ts` from prior failed attempts.
- No production credentials; only emulator project ID; ports 5001/8080/9099 free.
- Local Node >= 22.6.0 confirmed via `node --version` (fail-fast per Executable Node Contract).
- Strict TDD: every matrix row must first have a RED test (compile error or failing assertion) before its production implementation. No test may be retroactively labeled RED.

**Exit gates**:

- `npm test` (unit + emulator + metadata) green.
- `npx tsc --noEmit` green.
- All Acquisition+Transition and Reconstruction matrix rows mapped to a passing test; no row is covered only by `.run()` or by sequential mocks.
- Callable client used for emulator tests (no direct Admin SDK mutation from tests pretending to be the client).
- Deployment-metadata test (4b.4) was written and run RED against the WU4a placeholder BEFORE the callable export (4b.5) was introduced; the test structurally asserts `enforceAppCheck:true` on the exported endpoint.
- RDD run (single) executed only after emulator+TS+phase-contract proof and candidate freeze; result recorded.
- No handler-owned audit expected for pre-handler App Check denials; platform/edge log is the documented denial evidence.
- Line accounting within the Line-Guard Matrix bands.
- Every direct `.ts` test invocation used `node --experimental-strip-types` or an equivalent npm script routing to it (per Executable Node Contract).

**Rollback boundary**: revert only the WU4b enumerated paths (`functions/src/index.ts`, `functions/src/provisioning.ts`, `functions/test/provisioning.unit.test.ts`, `functions/test/provisioning.emulator.test.ts`, `functions/test/export-metadata.test.ts`, the WU4b-scoped lines of `functions/package.json` and `firebase.json`, and the one-time first metadata mutation to `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`); leave WU4a scaffold intact. Never auto-mutate existing `/provisioningOperations` or `/provisioningAudit` resources.

**Forbidden actions inside WU4b**: no push, no PR, no deploy, no skip-hooks, no `opencode run --agent`, no modification outside the enumerated paths (except the one-time metadata-only apply-progress reconciliation described in Authority Reconciliation), no production credentials, no sequential-mock-labeled-as-concurrency, no `.run()`-only App Check proof, no handler-owned pre-handler denial audit, no Auth custom claims, no foreign-identity-as-success, no Auth deletion without immutable positive proof plus exact UID/email re-verification.

**Verification commands**:

- `cd functions && npm test` (full unit + emulator + metadata suite).
- `cd functions && npx tsc --noEmit`.
- `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning.emulator.test.ts"`.
- RDD command (single run, post-freeze only): `gentle-ai review start` against the candidate with lineage keying per native ledger.

**Allowed paths**:

- `functions/src/index.ts` (new, callable export + Admin SDK init).
- `functions/src/provisioning.ts` (new, saga implementation).
- `functions/test/provisioning.unit.test.ts` (new).
- `functions/test/provisioning.emulator.test.ts` (new).
- `functions/test/export-metadata.test.ts` (new).
- `functions/package.json` (minimal scripts/emulator additions).
- `firebase.json` (minimal emulator wiring for Functions emulator port if not already present in WU4a).
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata-only, one-time reconciliation as FIRST apply mutation — see Authority Reconciliation).

### WU4c — Required client migration + Dart proof (separate work unit)

**Scope**:

- Replace the secondary client Auth provisioning flow in the Flutter admin panel with the trusted backend callable client.
- Preserve Riverpod boundary and `operationId` reuse across transport retries.
- Focused Dart tests for the migrated service/provider proving: callable payload, success result mapping, stable error-code mapping (including `already-exists`, `aborted`, `unavailable`, `internal`, `unauthenticated`, `permission-denied`, `invalid-argument`), operationId retry reuse, and **absence** of direct client Auth creation in the migrated path.

**Dependency**: accepts the WU4b contract/export as the callable shape (argument schema, success shape, stable error codes, operationId semantics). Do not bundle backend proof here; do not reimplement or re-prove backend behavior on the Dart side.

**Entry gates**:

- WU4b accepted (callable export stable, tests green, RDD run recorded if invoked).
- Clean base advanced past the WU4b commit.

**Exit gates**:

- `flutter analyze --no-pub --fatal-infos --fatal-warnings` green on changed paths.
- `dart format` clean.
- Dart tests for migrated service/provider green.
- No direct client Auth provisioning remains in the migrated path (structural grep + test asserting absence).
- Line accounting within forecast/contingency (210 expected / 250 stop).

**Rollback boundary**: revert the migrated `lib/core/services/firebase_service.dart`, generated provider file if touched, and the new Dart test file; leave WU4b backend intact.

**Forbidden actions inside WU4c**: no backend source change, no emulator test, no re-proof of backend behavior, no push/PR/deploy, no skip-hooks, no modification of unrelated Flutter files.

**Verification commands**:

- `flutter analyze --no-pub --fatal-infos --fatal-warnings lib/core/services/firebase_service.dart <provider-file-if-any> test/<new-test>.dart`.
- `dart format --output=none --set-exit-if-changed lib/ test/`.
- `flutter test test/<new-test>.dart`.

**Allowed paths**:

- `lib/core/services/firebase_service.dart` (modified, callable client).
- Generated provider file (modified, if required by Riverpod regeneration).
- `test/<focused-migration-test>.dart` (new).

**Selective RDD for WU4c**: only if the actual changed paths cross a critical boundary (Firebase callable client wiring into admin UI provisioning flow with authorization implications). Otherwise, ordinary functional/structural verification is sufficient. Decision deferred to apply time based on the real diff.

---

## WU5 (formerly WU6) — Android release-signing guard

- [ ] 5.1 RED: release build must fail when signing config/keystore secrets are absent.
- [ ] 5.2 GREEN: `android/app/build.gradle` signing block with fail-fast error; `.gitignore` excludes keystore and signing-secret files.
- [ ] 5.3 REFACTOR: verify no secrets committed; document in repository.

Rollback: revert `android/app/build.gradle` signing block and `.gitignore` additions. Verification: `./gradlew assembleRelease` without keystore fails with clear error.

## WU6 (formerly WU7) — Generic organization de-branding

- [ ] 6.1 Replace organization identifiers with generic placeholders in metadata; retain application name `controlhorario-rega`.
- [ ] 6.2 Verify protected paths `.atl/*` and `lib/core/theme/app_colors.dart` are untouched.

Rollback: revert branding replacements; protected paths unaffected. Verification: grep for retained app name; diff shows only placeholder substitutions.

## WU7 (formerly WU8) — Repository sanitization and protected-path checks

- [ ] 7.1 Secret/PII scan of current tree; remove hits (excluding protected paths).
- [ ] 7.2 Replace production claims with truthful portfolio-mode statements.

Rollback: revert only sanitized non-protected paths. Verification: scan clean; protected paths byte-identical to base.

## WU8 (formerly WU9) — Portfolio README rewrite

- [ ] 8.1 Rewrite `README.md` as portfolio codebase with no live-demo promise.
- [ ] 8.2 Publication gates visible and listed as pending/manual.

Rollback: revert `README.md`. Verification: grep for deployment/demo promises absent; three gates documented.

## WU9 (formerly WU10) — docs/archive removal plus secret scan

- [ ] 9.1 Remove `docs/archive/` entirely.
- [ ] 9.2 Post-removal secret scan of entire tree.

Rollback: restore `docs/archive/` from base. Verification: `docs/archive/` absent; scan clean.

## WU10 (formerly WU11) — Publication gates documentation and final no-publication boundary

- [ ] 10.1 Document license selection, reachable-history cleanup, and Firebase Console verification as manual publication-blocking gates.
- [ ] 10.2 Affirm no publication-safety claim is made while any gate remains.

Rollback: revert gate-documentation edits. Verification: all three gates listed as pending/manual.

---

## Tasks (checklist form)

### WU4a — Dependency scaffold

- [x] 4a.1 Create `functions/package.json` (firebase-admin, firebase-functions).
- [x] 4a.2 Create `functions/tsconfig.json` (NodeNext, ES2022, strict).
- [x] 4a.3 Create `functions/src/placeholder.ts` (minimal build-safe).
- [x] 4a.4 Modify `firebase.json` with functions source/config and emulator port block.
- [x] 4a.5 Generate `functions/package-lock.json` (lockfile exception max 3100).
- [x] 4a.6 Verify `npm ci --ignore-scripts` reproducible; `npx tsc --noEmit` green.

### WU4b — Backend provisioning saga + all backend proof

- [x] 4b.0 ENTRY/FAIL-FAST: verify `node --version` is >= 22.6.0 before every test or emulator invocation because direct `.ts` commands use `--experimental-strip-types`; abort without mutation when the local Node version is unsupported.
- [x] 4b.1 RED: unit test file skeleton with failing tests for normalization, fingerprint, schema/role denial, every CAS predicate, every transition/reconstruction row, stable event IDs, and compound failures (primary + persistence + compensation + logger).
- [x] 4b.2 GREEN: `functions/src/provisioning.ts` implementing validation, normalization, fingerprint, state machine, CAS, reconstruction, compensation, failure mapping, audit/log contracts per design.
- [x] 4b.3 RED: emulator test file skeleton with failing callable-client tests for success, retry, foreign email/UID, ambiguous-create reconstruction, UID absent/matching/mismatched/read-failure, profile absent/matching/conflicting, reset-link failure, compensation/delete failure, completed missing/conflicting, audit dedup, authorization-before-mutation.
- [x] 4b.4 RED: `functions/test/export-metadata.test.ts` asserting exported v2 endpoint binds `enforceAppCheck:true`. This test MUST be written and run RED against the WU4a placeholder (which has no such export) BEFORE any callable export is introduced. No test may be retroactively labeled RED.
- [x] 4b.5 GREEN: `functions/src/index.ts` exporting v2 callable with `enforceAppCheck:true`; Admin SDK init; wiring to provisioning. This makes 4b.4 GREEN.
- [ ] 4b.6 GREEN: finalize; `npm test` green for unit + emulator + metadata suite. (Unit+metadata GREEN; emulator RED pending)
- [x] 4b.7 TypeScript build: `npx tsc --noEmit` green.
- [ ] 4b.8 Exact all-path line accounting against Acquisition+Transition and Reconstruction matrices; candidate freeze. (STOPPED at reforecast band: 1,686/1,690)
- [ ] 4b.9 Independent phase-contract validation of candidate (read-only, fresh-context) against proposal/spec/design.
- [ ] 4b.10 One selective RDD run (only after 4b.7-4b.9 pass). Record lineage and result.

### WU4c — Flutter callable migration + Dart proof

- [ ] 4c.1 RED: new Dart test for callable migration: payload construction, success mapping, every stable error code, operationId retry reuse, and absence of direct client Auth creation.
- [ ] 4c.2 GREEN: modify `lib/core/services/firebase_service.dart` (and generated provider file if required) to replace secondary client Auth flow with callable client.
- [ ] 4c.3 REFACTOR: `flutter analyze --no-pub --fatal-infos --fatal-warnings` and `dart format` clean on changed paths.

### WU5 — Android release-signing guard

- [ ] 5.1-5.3 as above.

### WU6 — Generic organization de-branding

- [ ] 6.1-6.2 as above.

### WU7 — Repository sanitization

- [ ] 7.1-7.2 as above.

### WU8 — Portfolio README rewrite

- [ ] 8.1-8.2 as above.

### WU9 — docs/archive removal and secret scan

- [ ] 9.1-9.2 as above.

### WU10 — Publication gates documentation

- [ ] 10.1-10.2 as above.

**Forbidden (all WUs)**: no push, no PR, no deploy, no visibility or account action, no history rewrite, no skip-hooks, no `opencode run --agent`, no modification of `D:\control_horario`.
