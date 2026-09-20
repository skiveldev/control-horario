# ODD Feature: Prepare Public Portfolio Repository

## Objective

Complete the remaining public-portfolio repository work under Organic Driven Development (ODD), preserving the accepted OpenSpec implementation and evidence while executing only the still-valid pending units.

## Problem

The existing OpenSpec change contains substantial accepted implementation and detailed evidence, but the working tree is far ahead of `HEAD`, mixes tracked and untracked paths, and includes historical, superseded, and failed plans alongside executable tasks. P3.15/P3.16 also overlap with the later P3.53/P3.54 crash and concurrency matrix.

## Why

A reconciled ODD task authority is needed to prevent duplicate implementation, preserve accepted behavior, recover progress safely, and keep future work reviewable without rewriting project history.

## Scope

- Reconcile the current Git working tree with accepted OpenSpec task and progress evidence.
- Resolve the remaining ownership of P3.15/P3.16 before further implementation.
- Complete the remaining P3 matrices and final backend freeze.
- Complete P4 client migration and Firestore hardening using its existing requirement boundaries.
- Complete WU5-WU10 in their existing order.
- Retain OpenSpec artifacts as historical and contractual evidence.

## Non-goals

- Reimplement accepted P1, P2, or P3 behavior.
- Import retired P1a2-iii, P1a2-i-B-3, failed ordinals, evidence-only stashes, or provisional superseded P3-B plans as executable work.
- Rewrite or delete OpenSpec history.
- Commit, push, create pull requests, deploy, publish, or mutate native review authority without the applicable explicit authorization.

## Constraints

- Strict TDD remains active from `openspec/config.yaml`; use the exact runner declared by the applicable existing task or reconcile it before implementation.
- Preserve the existing `auto-chain` delivery strategy and `feature-branch-chain` topology unless explicitly changed.
- Treat approximately 400 authored changed lines as an ODD planning heuristic, not a code-golf target or acceptance gate.
- Use CodeGraph exclusively for code discovery and call-path exploration.
- Keep implementation writes single-threaded.
- Do not treat task checkboxes as acceptance evidence without corresponding implementation and verification evidence.
- Current baseline evidence: `HEAD` is `76bd104b44a46aa9c530eb7e90d4596dedaaf592`; the pre-ODD audit observed 15 tracked modifications and 46 collapsed untracked entries. After creating this ODD document, current Git status reports 15 tracked modifications, 47 collapsed untracked entries, and 70 untracked files when directories are expanded.

## Acceptance Criteria

- Every retained pending unit has one stable ODD task and no retired task is executable.
- Accepted implementation is mapped to current bytes and evidence before new source work begins.
- P3.15/P3.16 ownership is resolved without duplicating P3.53/P3.54 coverage.
- Every implementation task records focused verification, failures/skips, and its work-unit commit when commit authorization exists.
- P3 closes only after aggregate emulator, TypeScript, full-suite, and independent verification evidence.
- P4 and WU5-WU10 retain their existing product requirements and ordering.

## Tasks

- [x] **ODD-001 — Reconcile the current implementation baseline.** Classify every current tracked modification and untracked path as accepted implementation, pending work, generated output, or unrelated state; compare current bytes with OpenSpec acceptance evidence; record discrepancies before any new source edit. Completed with work-unit commit `bc781d246ac566f3adea95cc9ed3d8d3cdba7e44`.
- [x] **ODD-002 — Resolve P3.15/P3.16 crash-reconstruction ownership.** P3.15a and later accepted work cover the implemented boundaries at their accepted scopes; no separate duplicate implementation remains. Residual proof stays with ODD-003 (outbox race/crash/`ALREADY_EXISTS`), ODD-005 (Auth emulator matrix), and ODD-006 (end-to-end crash injection around every retained runtime effect, including terminalization). Completed with work-unit commit `cdaf4f908428d595243d25c49a0f87317ceba6d0`.
- [x] **ODD-003 — Complete P3.47/P3.48 outbox race coverage.** The test-only candidate proves trigger+sweeper convergence, duplicate/out-of-order identity preservation, crash recovery before and after enqueue acknowledgement, accepted same-task `ALREADY_EXISTS`, and incompatible identity rejection. Completed with work-unit commit `7cf7f077f57932b46a0b33811194a49ff07fc202`.
- [x] **ODD-004 — Complete P3.49/P3.50 retry conformance.** The test-only candidate proves retryCount 0-7 normal eligibility, 8-11 terminalization-only behavior, retryable persistence failure, terminal idempotency, fail-closed malformed metadata, durable outage propagation, and absence of a fictional exhaustion callback. Completed with work-unit commit `e3c1bf30048d90b417b27861607a8b159b750739`.
- [x] **ODD-005 — Complete P3.51/P3.52 Auth emulator matrix.** Emulator-backed evidence proves foreign UID/email identity preservation, exact create result, dual-index reads, ambiguity reconstruction without repeated creation, provenance conflict, transactional completion rollback, completed-integrity callable execution, and no automatic production deletion. Completed within accepted-baseline checkpoint `7b5c687a48a38cb7b7c3d1d8fca4532a43d6ddf1`.
- [x] **ODD-006 — Complete P3.53/P3.54 concurrency integration.** Execute two ordered coherent subunits after bounded implementation forecast rejected one mixed candidate. **ODD-006a is complete with work-unit commit `3cbca8a1659d1573c4cd75460aecb71ed262aac4`:** `worker_crash.test.ts` proves in-memory integrated crash/reconstruction around retained effect boundaries without claiming real emulator persistence. **ODD-006b is complete with work-unit commit `bf42482c9a5e5ce56c974e22468bf44fe223eb6c`:** the caller-level state machine uses fresh bounded decision transactions, terminalizes an exact live owner without preliminary takeover, preserves separate committed takeover plus authoritative reread, and propagates exhausted/nonclassified errors. `concurrency.test.ts` repeats four real-emulator scenarios four times each. Reuse ODD-003/004/005 as regressions without duplicating their matrices.
- [x] **ODD-007 — Finalize and freeze P3.** Callable exports and aggregate gates are finalized. The frozen P3 candidate passed configured TypeScript, build, direct tests, aggregate emulator tests, repeated concurrency, and independent verification. Completed with work-unit commit `348aafb24069b4bf478fd98b72e58a0c35c6c4fa`.
- [x] **ODD-008 — Complete P4 client transport and dependency migration.** P4.0-P4.10 completed in two work units: **P4-T1** dependency, App Check bootstrap, and trusted callable transport foundation at `276ad35dd3b297fee0a67d5c5c82467bc1137f10`; **P4-T2** submit/status payload, result, and exact eight-code mapping at `f7b1e1a813a4480e7cefab1c87d284b3c5e3a7c1`. Polling, UX, direct-creation retirement, rules, and P4 final gates remain in ODD-009.
- [ ] **ODD-009 — Complete P4 polling, UX, and Firestore hardening.** Finish the remaining P4.0-P4.21 client-state, user-experience, rules, and emulator proof while preserving backend ownership.
- [ ] **ODD-010 — Complete WU5 signing readiness.** Preserve its existing acceptance criteria and independent rollback boundary.
- [ ] **ODD-011 — Complete WU6 de-branding.** Preserve its existing acceptance criteria and ordering after WU5.
- [ ] **ODD-012 — Complete WU7 sanitization.** Preserve its existing acceptance criteria and ordering after WU6.
- [ ] **ODD-013 — Complete WU8 README and WU9 archive work.** Keep documentation and archive behavior reviewable and preserve their existing order.
- [ ] **ODD-014 — Complete WU10 final gates.** Run the existing publication/readiness gates and report every failed, skipped, unavailable, or pending check.

## Task Routing

| Task | Initial route | Trigger evidence |
|---|---|---|
| ODD-001 | Delegated exploration | More than four files and a large dirty/untracked baseline |
| ODD-002 | Delegated exploration, then bounded writer if needed | Cross-artifact ownership reconciliation |
| ODD-003–ODD-009 | One bounded writer per task plus risk-directed verification | Multi-file implementation and emulator verification |
| ODD-010–ODD-014 | Decide after focused exploration | Deferred work with existing independent boundaries |

## Delivery Plan

- Strategy: `auto-chain`.
- Chain strategy: `feature-branch-chain`.
- Existing OpenSpec child boundaries remain evidence, not automatic ODD completion.
- Running authored-line totals and commit/PR slice boundaries will be recorded when work-unit commits are authorized and created.

## Progress

- Migration audit completed read-only.
- P3.45/P3.46 corrected backend happy path is accepted by the existing evidence.
- No new source implementation has begun under ODD.
- ODD-001 is complete. Work-unit commit: `bc781d246ac566f3adea95cc9ed3d8d3cdba7e44` (`docs(odd): establish portfolio migration baseline`).
- Evidence-backed accepted paths include the accumulated provisioning source/tests and OpenSpec artifacts; `functions/lib/**` is generated output and is excluded from authored acceptance accounting.
- `functions/tsconfig.json` is preserved as a documented baseline exception: overriding `rewriteRelativeImportExtensions` off causes 25 TS5097 failures in current source, while the configured source-only typecheck passes.
- `.pi/gentle-ai/sdd-preflight.json` and `.atl/skill-registry.md` are local/generated harness metadata; they are excluded from authored implementation acceptance. `.gitignore` contains the matching local `.atl/` exclusion.
- `docs/operations/outbox-recovery-runbook.md` is retained as operational evidence, but its `ALREADY_EXISTS` instructions do not establish P3.47/P3.48 implementation acceptance.
- No observed path by itself proves P3.47+ implementation.
- ODD-002 ownership analysis found no independent implementation gap. P3.15/P3.16 residual acceptance is preserved without duplication across ODD-003, ODD-005, and ODD-006. Work-unit commit: `cdaf4f908428d595243d25c49a0f87317ceba6d0` (`docs(odd): assign residual crash coverage`).
- ODD-003 added only `functions/test/provisioning/outbox_race.test.ts` (183 additions); existing production already satisfied the characterized contract, so no false production RED or production edit is claimed. Independent verification passed with only low non-blocking coverage notes. Work-unit commit: `7cf7f077f57932b46a0b33811194a49ff07fc202` (`test(provisioning): cover durable outbox races`).
- ODD-004 added only `functions/test/provisioning/retry.test.ts` (136 additions); existing production satisfied the honest characterization, so no production edit or invented RED is claimed. Independent verification passed with two low non-blocking gaps: the focused test remains in-memory under emulator invocation, and the existing endpoint retry case is skipped because the child process lacks `FUNCTIONS_EMULATOR_HOST`. Work-unit commit: `e3c1bf30048d90b417b27861607a8b159b750739` (`test(provisioning): cover retry conformance`).
- ODD-005 changed only `functions/test/provisioning/worker_auth.test.ts` and `functions/test/provisioning/completed_integrity.test.ts`; production already satisfied the characterization. Initial independent verification rejected skipped completed-integrity integration and missing real rollback/UID-collision proof. One bounded correction closed all three findings, and final independent verification passed.
- The two edited tests were still untracked accepted-baseline files, so the first attempted ODD-005 commit incorrectly captured 3,515 whole-file lines. Maintainer authorized recovery preserving all bytes, followed by an exceptional 58-file, 14,027-changed-line accepted-baseline checkpoint. Checkpoint commit: `7b5c687a48a38cb7b7c3d1d8fca4532a43d6ddf1` (`chore(odd): checkpoint accepted provisioning baseline`). Generated `functions/lib`, `.pi`, `.atl`, and the ODD document were excluded.
- ODD-006 bounded forecast made no edits and found that combined crash plus concurrency integration would exceed one honest reviewable task. The parent split it once into ODD-006a crash/reconstruction and ODD-006b concurrency/terminalization, preserving all P3.53/P3.54 acceptance requirements.
- ODD-006a added only `functions/test/provisioning/worker_crash.test.ts` (238 additions). Initial independent verification rejected weak enqueue and terminal replay assertions; one bounded correction proved shared deterministic enqueue identity/one effective enqueue, Auth create remains one after proof replay, terminalized acknowledgement, retry evidence, and complete terminal snapshot stability. Final independent verification passed. Persistence remains intentionally in-memory even under emulator wrapping. Work-unit commit: `3cbca8a1659d1573c4cd75460aecb71ed262aac4` (`test(provisioning): cover crash reconstruction`).
- ODD-006b first candidate and generic retry correction were rejected as nondeterministic. Read-only diagnosis proved transaction adapters were fresh and identified the multi-transaction choreography as the contention problem; an independent challenge rejected combining takeover and terminalization because P3.29/P3.30 require observable takeover and post-commit reread. The approved definitive correction routes exact-live-owner terminalization in one fresh decision transaction, keeps expired takeover separate with authoritative reread, and bounds only confirmed closed-transaction re-entry. Final independent verification and the mandatory parent emulator spot check both pass 4/4. Candidate size is 251 changed production lines plus 204 new test lines; 455 exceeds the advisory 400-line heuristic but remains one indivisible state-machine behavior and was not code-golfed.
- ODD-008 is in progress through delegated implementation. Read-only mapping assigns P4.0-P4.10 to this task and defers P4.11-P4.21 to ODD-009. P4-T1 is forecast at approximately 250–360 authored lines across Flutter dependencies, awaited App Check bootstrap, an injectable official `HttpsCallable` transport, and focused tests. P4-T2 will separately map submit/status payloads, success results, and the eight stable error codes. Existing backend callable behavior remains frozen and out of scope; local `.atl/`, `.pi/`, and `functions/lib/` state is excluded. P4-T1 is complete with work-unit commit `276ad35dd3b297fee0a67d5c5c82467bc1137f10` (`feat(provisioning): add trusted callable transport`). P4-T2 is in progress as a client-only contract unit: exact `submitProvisioning` and `getProvisioningStatus` callable names, submit/status request maps, five status response variants, completed reset-link field decoding without UX consumption, and the exact client vocabulary `unauthenticated`, `permission-denied`, `invalid-argument`, `not-found`, `already-exists`, `aborted`, `unavailable`, `internal` plus unknown/malformed-response boundaries. Authoritative backend replay behavior permits all five submission statuses, so submission decoding must retain that union; the independent contrary finding is rejected. The current candidate must replace the incorrectly mapped `failed-precondition` with `aborted` and add focused malformed-submit, status-call error, and operationId retry-reuse proof. Those focused tests and the exact production correction are now GREEN. P4-T2 maps `aborted` and intentionally treats `failed-precondition` as unknown while retaining all five backend replay statuses. Independent verification and the parent spot check pass 12/12, fatal analysis, format, protected/generated path isolation, and diff-check. The cohesive submit/status/error boundary is 619 changed lines, above the advisory 400-line heuristic; no honest split exists without duplicating or temporarily omitting shared failure/decoder behavior, so no code-golf or test reduction was applied. P4-T2 is complete with work-unit commit `f7b1e1a813a4480e7cefab1c87d284b3c5e3a7c1` (`feat(provisioning): map callable contracts`). ODD-008 is closed across P4-T1 and P4-T2. Transport remains payload/domain neutral; polling and UI stay deferred. The WSL blocker was resolved with explicit user authorization by installing Flutter 3.47.5 stable and Dart 3.13.4 linux_x64 at `/home/skivel/.local/share/flutter`; the Windows-mounted CRLF SDK remains untouched. The candidate adds resolver-compatible `cloud_functions 6.5.0` and `firebase_app_check 0.4.8`, an injectable official callable transport, and an awaited Firebase→App Check bootstrap with debug/production providers and fail-closed web key handling. Strict TDD recorded missing-API RED, then 5/5 GREEN. Scoped fatal analysis, format, diff-check, independent semantic verification, repository-wide path isolation, and a parent 5/5 spot check pass. Incidental `analysis_options.yaml` and unsupported desktop registrant migrations were explicitly restored; only the six authorized P4-T1 paths remain.
- ODD-007 resumed in a new user-authorized work cycle after preserving the failed prior candidate. Independent diagnosis established an optimal three-unit correction: wrap only the P3.33 outage alert with bounded application logging; repair invalid CAS fixtures without relaxing the model; and reconcile structural reset-link plus transaction-retry regressions without changing accepted production behavior. A separate assumption challenge confirmed that the live-owner CAS-loss failure is an obsolete fake that records attempted transaction writes as committed, not a production atomicity defect. The user explicitly authorized the narrow update to frozen `structural_absence.test.ts`; its global prohibition must remain and admit only the accepted P3.44e composition in `src/index.ts`. The writer's exact-replacement editor blocked the prior work cycle: the initial attempt and sole retry applied no semantic correction and left one accidental whitespace-only line at `worker.ts:982`. Independent verification confirmed the preserved focused RED at 71 passed, 5 failed, and 25 skipped, with `git diff --check` failing only on that trailing whitespace. The user explicitly authorized a new bounded work cycle using an alternative surgical editing method. Its primary correction passes focused checks, leaving three independently classified stale-test failures: one structural rule still rejects the accepted P3.44b Cloud Tasks transport in `src/index.ts`, and two FirestoreStore cases reuse a fixture containing the same unauthorized `displayName`/`submittedByDigest` fields already removed from CAS tests. The user explicitly authorized expanding the sole corrective retry to `functions/test/provisioning/firestore_store.test.ts` only for those fixture fields; that suite now passes 7/7 and production, FirestoreStore, and the strict model remain unchanged. The retry still did not close ODD-007. Independent verification proves the structural scanner conflates the accepted `PasswordResetLinkGenerator` interface/injected-port invocation in `status.ts` with concrete Firebase generation in `index.ts`. More critically, the dedicated concurrency emulator reproduces the expired-takeover failure 3/4 with `3 INVALID_ARGUMENT: Transaction is invalid or closed.`; current closed-transaction classification matches `transaction invalid or closed` but misses the emulator's intervening `is`. The candidate was preserved at that boundary. The user has now explicitly authorized a new minimal two-file cycle: narrow the structural scanner so accepted reset-link port/orchestration remains allowed while concrete Firebase issuance stays confined to `index.ts`, and classify both `Transaction invalid or closed` and `Transaction is invalid or closed` in `worker.ts`. Existing tests provide RED and regression evidence. The authorized two-file correction now passes its focused, direct, TypeScript, build, diff-check, and repeated concurrency gates. Final aggregate verification exposed one independent `outbox_race.test.ts` flake: trigger and sweeper run concurrently without a barrier, so a legitimate acknowledgement ordering can produce one fake arrival instead of two. The user explicitly authorized the sole corrective retry to add a deterministic test-only concurrency barrier in that file; the barrier is now independently validated and passes four isolated runs with 20 assertions each. No production or Cloud Tasks environment change was made. Final independent verification passes direct tests, TypeScript, build, aggregate emulators, diff-check, and three of four repeated concurrency runs, but one dedicated P3.54 repetition still fails with `3 INVALID_ARGUMENT: Transaction is invalid or closed.` despite the narrow classifier update. That cycle ended with the candidate preserved. A subsequent read-only trace proved every takeover commit and authoritative reread already sits inside bounded catch/re-entry logic; the remaining escape is an error-shape mismatch in `isClosedFirestoreTransaction`, most likely at the contested takeover commit. The rendered message matches, but Firebase/GAX may expose code `3`, string `"3"`, symbolic `"INVALID_ARGUMENT"`, or a matching nested `cause`. The user explicitly authorized a new two-file correction: require matching code and closed-transaction message on the same bounded cause-chain node in `worker.ts`, and add deterministic wrapper-shape regressions in `worker_auth.test.ts`. The eight-attempt bound and state-machine choreography remain unchanged. Final tracing identified the remaining uncovered boundary: `terminalizeInitialPendingOnce` propagated recognized closed-transaction failures without using the existing bounded classifier/re-entry loop. The final narrow correction now wraps only that pending-terminalization call with the existing classifier and eight-attempt bound. Deterministic tests prove one recognized retry, unchanged propagation for nonmatching errors, and exhaustion at exactly eight attempts. Independent verification passes worker/Auth 75/98 with 23 skips, four consecutive concurrency runs at 4/4 each, direct 237/273 with 36 skips, aggregate emulator 268/273 with 5 skips, configured TypeScript, build, and scoped diff-check. P3 is frozen at work-unit commit `348aafb24069b4bf478fd98b72e58a0c35c6c4fa` (`fix(provisioning): freeze resilient P3 backend`). Delivery remains separately unauthorized.

## Verification Evidence

- Read: `openspec/changes/prepare-public-portfolio-repository/tasks.md`.
- Read: `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`.
- Read: `functions/test/provisioning/full_flow.test.ts`.
- Git identity observed: branch `slice/p1a2-i-b-2-terminal-monotonic`, `HEAD` `76bd104b44a46aa9c530eb7e90d4596dedaaf592`, clean index.
- Current Git state after ODD document creation: 15 tracked modifications, 47 collapsed untracked entries, and 70 expanded untracked files.
- `functions/tsconfig.json` adds `rewriteRelativeImportExtensions`; although forbidden by the earlier slice plan, read-only verification proves the current `.ts` import convention depends on it for source-only TypeScript validation.
- `functions/package.json` adds `main: lib/index.js` and changes the deployment engine from `>=20` to exact `20`; the lockfile mirrors the engine change. Local verification ran on Node `v24.20.0`, separately satisfying the direct-TypeScript-test prerequisite of Node >=22.6.0.
- `firebase.json` adds a Functions predeploy build and stops ignoring `lib`; `main`, predeploy, emitted `lib/index.js`, and the deployment ignore list are structurally consistent.
- `firestore.indexes.json` adds provisioning indexes; `openspec/config.yaml` records OpenSpec as the canonical artifact store.
- Compatibility checks passed: configured `npx tsc --noEmit` and scoped `git diff --check`.
- Baseline simulation failed as expected: `npx tsc --noEmit --rewriteRelativeImportExtensions false` produced 25 TS5097 errors.
- Current non-generated, non-harness, pre-ODD candidate manifest contains 58 files with aggregate SHA-256 `d42ba1759ea15b3017c62f1060b213947c76aa68f5d91b707acd237b73758c92` over sorted `git hash-object` path entries.
- No behavioral suite was rerun during migration planning; the latest P3.45/P3.46 independent verification evidence remains the current happy-path proof.
- ODD-003 direct test: 16 assertions pass, with the Firestore race skipped outside the emulator.
- ODD-003 Firestore/Functions emulator test: 20 assertions pass, including the persisted trigger+sweeper race.
- Existing outbox direct test, outbox/repair emulator regressions (56 repair assertions), configured TypeScript, and scoped `git diff --check` pass.
- Independent verifier result: PASS with no blocking defects. Parent spot check repeated the direct race test successfully.
- ODD-004 direct and emulator-wrapped retry tests pass 5/5; worker/Auth regressions pass 72 direct with 21 environment skips and 90 emulator-backed with 3 endpoint-environment skips.
- ODD-004 configured TypeScript and scoped `git diff --check` pass. Independent verifier found no blocking defect; parent spot check repeated the 5/5 retry test successfully.

- ODD-005 Auth emulator matrix passes 92/95 with 3 unrelated endpoint-environment skips; completed-integrity emulator passes 13/13 with zero skips; configured TypeScript and scoped `git diff --check` pass.
- Final independent verifier result: PASS with all prior findings closed. Parent spot check repeated the direct worker/Auth suite: 72 passed, 23 emulator-dependent skips, 0 failed.
- ODD-006a direct and emulator-wrapped crash suites pass 4/4; outbox-race and retry regressions pass; configured TypeScript and scoped `git diff --check` pass. Scoped status proves only `worker_crash.test.ts` changed and `concurrency.test.ts` remains absent. Parent spot check repeated 4/4 successfully.
- ODD-006b final emulator concurrency suite passes 4/4 with four repetitions per scenario; crash 4/4, outbox-race 16 assertions, retry 5/5, configured TypeScript, and scoped diff-check pass. Independent verification is PASS. Parent spot check repeated the full emulator suite successfully. `functions/firestore-debug.log` has no Git status entry.

## Next Step

Begin ODD-009 with P4.11-P4.14 polling, backoff, cancellation, and persisted operationId recovery. Keep UX, rules, and legacy retirement in later ODD-009 subunits.
