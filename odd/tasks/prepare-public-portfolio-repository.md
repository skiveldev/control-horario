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
- [ ] **ODD-003 — Complete P3.47/P3.48 outbox race coverage.** Technical implementation and independent verification are complete; the task awaits its work-unit commit. The test-only candidate proves trigger+sweeper convergence, duplicate/out-of-order identity preservation, crash recovery before and after enqueue acknowledgement, accepted same-task `ALREADY_EXISTS`, and incompatible identity rejection.
- [ ] **ODD-004 — Complete P3.49/P3.50 retry conformance.** Prove retryCount boundaries, reserved terminalization attempts, fail-closed malformed input, poison behavior, and absence of a fictional exhaustion callback.
- [ ] **ODD-005 — Complete P3.51/P3.52 Auth emulator matrix.** Prove foreign identity, exact create result, dual-index reads, ambiguity, provenance conflict, atomic completion, completed integrity, and no automatic deletion.
- [ ] **ODD-006 — Complete P3.53/P3.54 concurrency integration.** Prove lease takeover, duplicate/out-of-order delivery, crash injection around retained effects, pending/active predicates, terminal idempotency, and reserved terminalization behavior without duplicating ODD-002.
- [ ] **ODD-007 — Finalize and freeze P3.** Finalize callable exports; run configured TypeScript, full tests, aggregate emulator checks, and independent verification; record the frozen backend candidate and remaining warnings.
- [ ] **ODD-008 — Complete P4 client transport and dependency migration.** Apply the existing P4.0-P4.21 requirements for Firebase/App Check setup and trusted callable transport in reviewable behavior units.
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
- ODD-003 added only `functions/test/provisioning/outbox_race.test.ts` (183 additions); existing production already satisfied the characterized contract, so no false production RED or production edit is claimed. Independent verification passed with only low non-blocking coverage notes.

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

## Next Step

Obtain explicit authorization for the ODD-003 work-unit commit containing only `functions/test/provisioning/outbox_race.test.ts` and this ODD document. After recording that boundary, begin ODD-004.
