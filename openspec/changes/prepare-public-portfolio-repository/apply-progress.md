# Apply Progress: Prepare Public Portfolio Repository

## P3.45–P3.46 — Full Backend Emulator Happy Path

**Status:** corrected and complete under Strict TDD. The prior green candidate is verification-rejected because it delivered worker tasks directly while persisted dispatches remained `enqueued:false`. The corrected test uses the real Firestore acknowledgement store, validation, and deterministic strict enqueue adapter through `createProvisioningOutboxRuntime` before every worker delivery; no production source changed.

### Correction TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | Independent verification rejected the prior candidate for bypassing the canonical durable-outbox → guarded acknowledgement → worker topology; that preserved finding is the correction RED. |
| GREEN | The test-only composition now reads each persisted unacknowledged dispatch, runs the created path, verifies strict enqueue plus `enqueued:true`, numeric transaction-time `enqueuedAt`, `enqueueSource:"trigger"`, and the exact domain-separated created-event digest before posting to the worker endpoint. |
| TRIANGULATE | The required Firestore/Auth/Functions emulator command passes 1/1 in 6.2 seconds after four guarded acknowledgements for `acquire`, `auth_preflight`, `auth_create`, and `profile_commit`; it retains one submission and one final status call only. |
| REFACTOR | No production/config/dependency/domain/client/delivery changes and no P3.47/P3.48 matrix were added; expected local background-trigger `invalid queue environment` logs remain non-evidence. |

- Corrected task truth: P3.45/P3.46 remain visibly checked only because this corrected evidence passed; the prior direct-worker candidate is recorded as rejected, not accepted.
- Correction accounting: test is now 199 additions versus the prior 165-line candidate (+34); this 15-line progress delta and two task-record lines yield **243 cumulative changed lines** against the claimed 192 baseline, below warning 320, STOP 380, and hard maximum 399.
- Corrected rollback: restore `functions/test/provisioning/full_flow.test.ts` to its pre-P3.45 absence, restore the P3.45/P3.46 task state and this correction record; production remains untouched.

**Prior candidate status:** superseded by the verification-rejected correction above. Historical details below are not acceptance evidence for the direct worker deliveries.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | The first authored full-flow emulator run failed in `signIn` with `TypeError: Body is unusable` because the test consumed the Auth REST response to construct an assertion message before parsing its JSON. This was a genuine harness failure, not a production composition claim; no production code was edited. |
| GREEN | The test-only assertions now use `response.clone().text()`. The exact 180-second-bounded Firestore/Auth/Functions command passed 1/1 in about six seconds, with no integration skip. |
| TRIANGULATE | The flow observed submission `pending`; durable `acquire` dispatch; acquisition -> `auth_preflight`; preflight/intent -> `auth_create`; Auth create plus dual reads -> `profile_commit`; profile/provenance completion -> `completed`; then one authorized App Check status response with an HTTPS reset link. |
| REFACTOR | Retained the durable `enqueued:false` initial outbox assertion and actual task-endpoint eligibility headers. No client polling, resubmission, client re-drive, P3.47 duplicate/race/ALREADY_EXISTS vectors, P3.48 crash/ambiguity vectors, configuration, or dependencies were added. |

- Persisted task updates: P3.45 and P3.46 are visibly checked. The next unchecked line is `- [ ] P3.47 RED: outbox race — trigger+sweeper race; duplicate event; out-of-order delivery; crash before enqueue; crash after enqueue; task already exists (`ALREADY_EXISTS` accepted).`
- Reconciliation: the inherited candidate had uncommitted `index.ts`, `tasks.md`, and `apply-progress.md` changes; P3.45/P3.46 added only the new `functions/test/provisioning/full_flow.test.ts` and these two bookkeeping updates. `index.ts` remains byte-identical during this slice.
- Verification: Node `v24.20.0`; `npm run build`; the exact `timeout 180s` emulator command (1 pass, 0 skip, completed before timeout); direct submit/outbox/worker-auth/completed-integrity regressions; configured `npx tsc --noEmit`; and scoped `git diff --check` all exit 0.
- Emulator note: created-dispatch background delivery logs `invalid queue environment` because this no-config test environment lacks deployment queue inputs. The test neither treats that as success nor alters the durable `enqueued` gate; its approved deterministic task endpoint deliveries exercise the already-composed backend handlers against their persisted eligibility checks.
- No-client-redrive proof: the test has one `submitProvisioning` HTTP call, four `onTaskDispatched` deliveries from persisted `currentDispatchId` values, and one final `getProvisioningStatus` call. It makes no preterminal status call, client resubmission, or direct domain-handler invocation.
- Accounting against the exact pre-slice absence of the new test: `full_flow.test.ts` 165 additions, task checkbox replacements 2 additions + 2 deletions, and this 23-line progress record = **190 additions + 2 deletions = 192 changed lines**, below warning 320, STOP/reforecast 380, and hard maximum 399.
- Workload / PR boundary: P3.45/P3.46 feature-branch-chain child only; no commit, PR, push, delivery, or review action.
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState:"ready"`, `nextRecommended:"apply"`, canonical repo-local workspace and sole allowed root. `actionContext` has no warnings.
- Rollback boundary: delete `functions/test/provisioning/full_flow.test.ts`; restore only the two P3.45/P3.46 checkboxes and this section. P3.44a–e and all P3.47+ work remain intact/unstarted.

## P3.44e — Completed Integrity + Immediate Fresh Reset-Link Composition

**Status:** complete under Strict TDD. `getProvisioningStatus` retains App Check and admin authorization, then composes the accepted completed-integrity/reset-link pipeline with real Firebase Auth and Firestore adapters. `status.ts` and all domain behavior remain byte-identical.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | Authored the callable/emulator evidence in `completed_integrity.test.ts` before `index.ts` wiring. The Firestore/Auth/Functions emulator command genuinely failed 12 pass/1 fail because the completed response had `passwordResetLink: undefined`. |
| GREEN | `index.ts` now reads Auth by intended UID and normalized email through `FirebaseAuthReader`, reads the provenance-tagged profile, transactionally deduplicates the existing PII-safe integrity audit, and calls `getAuth().generatePasswordResetLink` only after the accepted pipeline succeeds. |
| TRIANGULATE | The real emulator executed 13/13 tests with valid App Check and auth; it returned two distinct fresh links, preserved no link in operation/profile/audit persistence, and recorded one deterministic integrity-failure audit for two mismatched-profile calls. |
| REFACTOR | Retained the accepted `status.ts`, DTO/authz/domain/worker/outbox behavior and added no P3.47/P3.48 matrices, logging, email delivery, client work, configuration, or dependencies. |

- Persisted task updates: P3.44e.1–P3.44e.4 are visibly checked. P3.44e has no remaining unchecked task; next pending line is `- [ ] P3.45 RED: full emulator flow — happy-path submission through to completed status with fresh reset link; no client-driven re-drive.`
- Files changed: `functions/src/index.ts`, `functions/test/provisioning/completed_integrity.test.ts`, this task record, and this cumulative record.
- Commands: Node v24.20.0; focused completed-integrity direct runner (12 pass/1 emulator skip); explicit source+test TypeScript and configured `npx tsc --noEmit`; `npm run build`; direct status/authz/DTO regressions (7 pass/1 emulator skip, 14 assertions, 69 assertions); and the Firestore/Auth/Functions emulator focused runner (13 pass/0 skip).
- Accounting: exact `/tmp/p3-44e-pre-slice` recount is 55+4 (`index.ts`) + 100+2 (test) + 4+4 (tasks) + 22+0 (progress) = **191 additions plus deletions**, below warning 320, STOP/reforecast 380, and hard maximum 399; no exception or borrowing.
- Workload / PR boundary: P3.44e feature-branch-chain child only; no commit, PR, push, delivery, review, or later-slice work.
- Deviation from design: none. Completion stays immutable on mismatch and reset links remain immediate-response-only.
- Structured status consumed: `gentle-ai.sdd-status` v2 with `applyState:"ready"`, `nextRecommended:"apply"`, canonical repo-local workspace, and allowed root. `actionContext` has no warnings.
- Rollback boundary: revert only P3.44e `index.ts`, completed-integrity emulator evidence, P3.44e checkboxes, and this section to `/tmp/p3-44e-pre-slice`; P3.44a–d remain accepted.

## P3.44d — Status Callable + Safe DTO Composition

**Status:** complete under Strict TDD. The callable remains App Check-protected and now reaches the accepted authorization and safe DTO projection through Firestore-backed profile and operation reads; it does not invoke completed-integrity or reset-link behavior.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | `status.test.ts` first imported the missing `getProvisioningStatus`; the focused Node runner exited 1 with the absent named export. The initial endpoint smoke then genuinely returned 401 `UNAUTHENTICATED`. |
| GREEN | Bounded read-only inspection of `firebase-functions` showed that emulator `skipTokenVerification` decodes a syntactically valid JWT from `X-Firebase-AppCheck`. The test-only harness now sends a base64url three-segment token with a `sub`; no production App Check setting changed. |
| TRIANGULATE | The exact Firestore/Auth/Functions emulator command executed under `demo-no-project`, reported `app:"VALID",auth:"VALID"` for both calls, and passed all 8 status tests. The active-admin safe DTO and non-admin 403 paths both reached the callable. |
| REFACTOR | Kept one test-only token helper; `status.ts`, DTO, authz, integrity/reset-link, worker, outbox, persistence, configuration, and dependencies remain unchanged. |

- Bounded-search evidence: `functions/node_modules/firebase-functions/lib/common/providers/https.js` requires `X-Firebase-AppCheck` and, in emulator debug verification, decodes a JWT-like token; `lib/common/debug.js` defines the local debug feature contract. No path outside the user-authorized scopes was searched.
- Files changed: `functions/src/index.ts`, `functions/test/provisioning/status.test.ts`, this task record, and this cumulative record. Persisted P3.44d.1–.4 checkboxes are visibly checked.
- Commands: focused status 7 pass/1 environment skip; authz 14 assertions pass; DTO 69 assertions pass; `npm run build`, emulator smoke (8 pass/0 skip), configured `npx tsc --noEmit`, and scoped `git diff --check` all exit 0.
- Accounting: captured pre-slice bytes are `/tmp/p3-44d-pre-slice`; final four-path accounting is 45 + 80 + 8 + 22 = 155 additions plus deletions, below warning 320, STOP 380, and hard max 399.
- Workload / PR boundary: P3.44d feature-branch-chain child only; no P3.44e, P3.47/P3.48, client, delivery, review, commit, or push work began.
- Structured status consumed: supplied `gentle-ai.sdd-status` v2, `applyState:"ready"`, `nextRecommended:"apply"`, canonical repo-local workspace, and allowed root; `actionContext` has no warnings.
- Rollback boundary: revert only P3.44d changes in `functions/src/index.ts`, `functions/test/provisioning/status.test.ts`, this task record, and this record to `/tmp/p3-44d-pre-slice`; accepted P3.44a–c remain intact.


## P3.44c — Endpoint Reachability Acceptance Completion

**Status:** complete under Strict TDD. The test harness now deterministically resolves the Functions emulator project as `GCLOUD_PROJECT` or Firebase CLI's no-project default `demo-no-project`, builds the task endpoint URL once, and cleans the preflight smoke's shared documents so the existing acquisition endpoint case remains isolated.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | Preserved continuation RED: the exact Firestore/Auth/Functions command loaded `onTaskDispatched` at `http://127.0.0.1:5001/demo-no-project/us-central1/onTaskDispatched` but returned 404 for all three endpoint cases (90 pass, 3 fail, 0 skip). |
| GREEN | Test-only project/URL resolution replaced endpoint-local fallback project IDs; the three endpoint cases reached the loaded function with expected 204, 204, and 500/204 statuses. |
| TRIANGULATE | The exact emulator command exits 0 with 93 pass, 0 fail, 0 skip; `P3.44c`, P3.19, and P3.34 endpoint cases all execute. |
| REFACTOR | Retained one URL helper and narrowly deleted the preflight test documents; no production, handler, config, package, or dependency byte changed. |

- Files changed: `functions/test/provisioning/worker_auth.test.ts`, `tasks.md`, and this cumulative record only; `functions/src/index.ts` is byte-identical during this continuation.
- Endpoint evidence: the emulator advertised the demo project URL, and all three task endpoint cases used it through the same deterministic helper.
- Commands: Node v24.20.0; `npm run build` and configured TypeScript exit 0; direct worker harness is 72 pass, 21 environment skips; emulator harness is 93 pass, 0 fail, 0 skip.
- Persisted checkbox updates: P3.44c.3 and P3.44c.4 are visibly checked after the emulator proof.
- Accounting against `/tmp/p3-44c-pre-slice`: current test delta is 72 additions + 6 deletions = 78; the correction adds 21 changed test lines to the preserved 143-line P3.44c candidate. This record adds 24 lines and the two checkbox replacements add 4, so correction total is 49 and cumulative P3.44c accounting is 192, below warning 320, STOP 380, and hard maximum 399.
- Workload / PR boundary: P3.44c feature-branch-chain child only; no P3.44d/e, P3.47/P3.48, delivery, review, commit, or push work began.
- Deviation from design: none; emulator outbox warnings from intentionally unset queue environment are unrelated to worker endpoint status assertions.
- Remaining P3.44c tasks: none. P3.44d/e and all later P3 work remain unchecked and outside this continuation.
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState:"ready"`, `nextRecommended:"apply"`, canonical workspace, and `actionContext.mode:"repo-local"` with the supplied root; no action-context warnings.
- Rollback boundary: revert only the test URL/isolation correction, P3.44c.3/.4 checkboxes, and this completion record to the preserved partial P3.44c state; production and all later P3 slices remain untouched.

## P3.44c — Worker Runtime Phase Routing + Firebase Auth Composition

**Status:** partial under Strict TDD: P3.44c.1–P3.44c.2 are complete. The sole corrective rerun built `functions/lib/index.js` and loaded the Functions definitions, but the child test process still lacks `FUNCTIONS_EMULATOR_HOST`, so P3.44c.3–P3.44c.4 remain unchecked.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | `worker_auth.test.ts` first imported the missing `createProvisioningWorkerRuntime`; the focused Node runner exited 1 with the missing export before production composition. |
| GREEN | `createProvisioningWorkerRuntime` reads the canonical dispatch ID, preserves `processProvisioningTask` retry ownership, and routes only `auth_preflight`, `auth_create`, and `profile_commit` to the accepted handlers with injected `FirebaseAuthReader(getAuth())`. The focused runner passes 72/72 with 21 environment skips; the new strict-store preflight/intent smoke passes. |
| TRIANGULATE | The sole corrective `npm run build` exits 0 and the emulator loads `onTaskDispatched`; its focused command exits 0 with 90 passes and 3 skips. The new HTTP endpoint smoke still skips because the child process lacks `FUNCTIONS_EMULATOR_HOST`, so this is not accepted endpoint evidence. Configured source TypeScript exits 0. |
| REFACTOR | No handler, retry, crash, Auth-matrix, or concurrency behavior was changed; final scoped whitespace check passed after this evidence write. |

- Files changed: `functions/src/index.ts`, `functions/test/provisioning/worker_auth.test.ts`, and these OpenSpec records. `worker.ts` and `boundaries.ts` remain byte-identical.
- Commands: `cd functions && npm run build` exited 0; `node --version` returned `v24.20.0`; direct worker harness passed 72/72 with 21 environment skips; configured `npx tsc --noEmit` passed; the explicit source+test TypeScript command failed on pre-existing worker-test errors outside this child; the Firestore/Auth/Functions emulator command passed 90 tests with 3 skips after loading all Functions definitions, but the new endpoint smoke skipped because `FUNCTIONS_EMULATOR_HOST` was absent; scoped `git diff --check` passed.
- Persisted checkbox updates: P3.44c.1 and P3.44c.2 are checked. Remaining exact unchecked lines: `- [ ] P3.44c.3 TRIANGULATE: run focused worker endpoint tests through Firestore/Auth/Functions emulators, explicit/source-only TypeScript, and already accepted worker regressions only.` and `- [ ] P3.44c.4 REFACTOR: retain backend-owned liveness, persisted intent-before-effect, and no-deletion boundaries while removing only composition duplication.`
- Workload / PR boundary: P3.44c feature-branch-chain child only. Fresh pre-slice baseline is `/tmp/p3-44c-pre-slice`; before bookkeeping, the source/test delta was 117 additions+deletions, below warning 320 and STOP 380. No size exception or borrowing is used.
- Deviation from design: none. The existing phase handlers retain their own persisted intent, external-effect, and terminalization contracts.
- Structured status consumed: `gentle-ai.sdd-status` v2 with `applyState:"ready"`, `nextRecommended:"apply"`, canonical workspace, and the sole allowed edit root; `actionContext` has no warnings.
- Rollback boundary: revert only P3.44c changes in `functions/src/index.ts`, `functions/test/provisioning/worker_auth.test.ts`, and these OpenSpec records to accepted P3.44b; P3.44d/e and P3.47+ remain untouched.


## P3.44b Acceptance-Evidence Correction — Scheduled Runtime and Export Coverage

**Status:** complete under Strict TDD characterization; the test-first evidence passed existing production, so no production code changed.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | The focused runtime/export test was authored before any possible production change; it passed against existing composition, so no false RED is claimed. |
| GREEN | No production change was necessary; controlled dependencies prove `runtime.repair("scheduler-run-42")` forwards `now`, selects only the stale record, uses the shared enqueue adapter, and commits its guarded sweeper acknowledgement with the independently derived run digest. |
| TRIANGULATE | Direct enqueue/outbox tests, explicit NodeNext TypeScript, Firestore/Functions emulator `outbox.test.ts && outbox_repair.test.ts`, and configured TypeScript all pass. |
| REFACTOR | Nine-path blob-based `git diff --check` is clean; P3.47/P3.48 race, duplicate, crash, and `ALREADY_EXISTS` matrices were not extended. |

- Export evidence asserts trigger `retry:true` and exact repair metadata: every 5 minutes; retry count 3; min/max backoff 30/300; max doublings 2; max instances 1; timeout 240.
- Files changed: `functions/test/provisioning/outbox.test.ts` and this bounded record only. The seven supplied production/regression baseline blobs remain byte-identical; no design deviation occurred.
- Persisted P3.44b checkbox reconciliation: P3.44b.1–P3.44b.4 were re-read and remain visibly checked after all requested checks passed; `tasks.md` required no byte change.
- Workload / PR boundary: P3.44b feature-branch-chain child only. Blob correction is 69 additions + 2 deletions in the test and 20 additions in this record = 91; cumulative `165 + 91 = 256`, below warning 320 and STOP 380.
- Remaining scope: `- [ ] P3.44c.1 RED: extend \`worker_auth.test.ts\` before composition only for task endpoint dispatch to the already implemented phase handlers, Firebase Auth adapter construction, and the minimum preflight/intent routing smoke path; accepted worker/domain tests remain regressions. Do not re-author P3.15/P3.16 crash vectors or P3.49+ retry/Auth/concurrency matrices.` P3.44c–e and P3.47/P3.48 remain untouched.
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState:"ready"`, `nextRecommended:"apply"`, canonical repo-local workspace, and allowed root; `actionContext` has no warnings.

## P3.44b Corrective Resume — Command Contract Reconciled

**Status:** complete under Strict TDD; P3.44b.1–P3.44b.4 are visibly checked.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | Preserved `outbox.test.ts` missing-export RED: Node v24.20.0 exited 1 because `createProvisioningOutboxRuntime` was not exported. |
| GREEN | The minimal factory now composes created events through `handleCreatedDispatch`, and endpoint wrappers use the existing Cloud Tasks request adapter plus guarded Firestore acknowledgement. The focused created-outbox test exits 0 (29 assertions). |
| TRIANGULATE | Explicit NodeNext TypeScript and configured `npx tsc --noEmit` exit 0. Firestore/Functions emulator test exits 0: created outbox 29 assertions and scheduled repair 56 assertions. |
| REFACTOR | Scoped `git diff --check` exits 0; no race, duplicate/out-of-order, crash-matrix, worker, Auth, status, or client behavior was added. |

- Harness separation: the corrected direct command runs enqueue and created-outbox tests only; `outbox_repair.test.ts` remains mandatory in the Firestore/Functions emulator command because it requires `FIRESTORE_EMULATOR_HOST`. No source or test bytes changed for this correction.
- Files changed: `functions/src/index.ts` and the preserved RED in `functions/test/provisioning/outbox.test.ts`; `enqueue.ts`, `outbox.ts`, `outbox_repair.ts`, and their two existing tests remain immutable.
- Workload / PR boundary: P3.44b feature-branch-chain child. Complete original-baseline accounting is 152 additions + 13 deletions = 165 changed lines: index 108+7, preserved outbox RED 19+1, tasks 5+5, and progress 20+0. No size exception is used.
- P3.44c–P3.44e and P3.47/P3.48 remain unchecked and semantically untouched; no race, duplicate/out-of-order, crash-matrix, or `ALREADY_EXISTS` work was added.
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState:"ready"`, `nextRecommended:"apply"`, canonical repo-local workspace, and allowed root. `actionContext` has no warnings.


## P3.44a Correction — Real Firestore Acceptance Evidence

**Status:** complete; P3.44a.1–P3.44a.4 remain visibly checked after corrected acceptance.

- Changed only `functions/test/provisioning/submit.test.ts`; all three production files are byte-identical to their supplied correction baselines, and P3.44b+ was untouched.
- Characterization: the new invalid-input, authorization-denial, and malformed-persisted-status composition tests passed without production changes; no RED was invented.
- Emulator proof uses `FirestoreInitialSubmissionStore` with an explicit emulator-only Admin app: operation plus deterministic dispatch commit together, an `ALREADY_EXISTS` dispatch create rolls back the operation, and three concurrent submissions converge on one valid operation/dispatch pair.
- Commands passed: Node v24.20.0; Java 21.0.12; focused Node harness; explicit source+test TypeScript; Firestore/Auth/Functions emulator harness; configured `npx tsc --noEmit`.
- The first emulator execution exposed only missing test project identity; the test harness now supplies the emulator project ID and the one permitted retry passed. The Functions emulator still reports the pre-existing missing `functions/lib/index.js` entrypoint while the requested harness passes.
- TDD evidence: tests preceded any potential production change; focused unit success is characterization, and no deterministic production defect was exposed by the real adapter.
- No design deviation or production change occurred. Workload boundary remains the single feature-chain child `P3.44a`; supplied-blob accounting is 213 baseline + 135 test correction lines before this record, below the hard cap.
- Remaining tasks (untouched): `- [ ] P3.44b.1 RED: add only the minimum created-dispatch happy-path vectors for shared enqueue, guarded enqueued acknowledgement, stale-record selection, and trigger/scheduler endpoint wiring before composition. Do not add race, duplicate, crash, or ALREADY_EXISTS matrix vectors here.`
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState:"ready"`, `nextRecommended:"apply"`, repo-local canonical workspace and allowed root, with no action-context warnings.

## P3.44a — Submission Callable + Firestore Persistence Composition

**Status:** complete under Strict TDD. Parent-provided immutable accepted-baseline evidence supplies the exact pre-existing untracked-path blobs; the current 2.9.2 grant-only runtime exposes no new attempt/begin snapshot and no prior authority was reused or mutated. Final cumulative slice accounting is 195 additions + 18 deletions = 213 changed lines, below the 185–250 forecast and 399 hard maximum.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | Extended `functions/test/provisioning/submit.test.ts` before production composition; `cd functions && node --experimental-strip-types test/provisioning/submit.test.ts` exited 1 because `submitProvisioningRequest` was not exported. |
| GREEN | Composed the App Check callable with validation, authorization, normalized fingerprinting, deterministic initial-dispatch derivation, and `persistInitialSubmission`; the focused test exits 0 with 36 assertions. |
| TRIANGULATE | Explicit source+test TypeScript exits 0; Firestore/Auth/Functions emulator wrapper exits 0 for the focused harness. The Functions emulator reports pre-existing `functions/lib/index.js` absence, but Firestore/Auth started and the requested Node harness passed. |
| REFACTOR | Configured `cd functions && npx tsc --noEmit` exits 0; no refactor widened the callable beyond pending-operation and initial-dispatch persistence. |

### Evidence and Boundary

- Files changed: `functions/src/index.ts`, `functions/src/provisioning/submit.ts`, `functions/src/provisioning/boundaries.ts`, and `functions/test/provisioning/submit.test.ts`; this cumulative progress record is the only bookkeeping update. No Auth, Cloud Tasks, profile, worker, status, or client re-drive effect was added.
- Verification: Node v24.20.0 (>=22.6.0); Java 21.0.12; focused submit harness 36 assertions; explicit source+test TypeScript and configured source-only TypeScript both exit 0; emulator wrapper exits 0 with the noted missing compiled Functions entrypoint warning.
- The callable remains `onCall({ enforceAppCheck: true })`; authorization uses the existing denial-audit port, then one Firestore transaction creates the canonical pending operation and deterministic `acquire/g0/v0` dispatch. Matching identity replays the persisted safe status; fingerprint conflict remains `already-exists` with no write.
- Workload / PR boundary: feature-branch-chain child `P3.44a` only. Rechecked accepted baselines: source/test = 164 additions + 10 deletions; leading progress section = 23 additions; four checkbox replacements = 4 additions + 4 deletions; four progress wording replacements = 4 additions + 4 deletions; final arithmetic = 195 additions + 18 deletions = 213, below forecast and all limits.
- Structured status consumed: `gentle-ai.sdd-status` v2, `changeName:"prepare-public-portfolio-repository"`, `artifactStore:"openspec"`, `applyState:"ready"`, `nextRecommended:"apply"`, canonical workspace and sole allowed edit root. `actionContext` has no warnings. No retired native status/acquire/settle operation or ordinal-61 authority was used.
- Persisted closure: P3.44a.1–P3.44a.4 are visibly checked after the accepted-baseline recount and completed evidence; P3.44b+ remains untouched.


## P3.43–P3.44 — Runtime Validation Correction for Generated Reset Links

**Status:** retained P3.43/P3.44 correction complete under Strict TDD. The reset-link adapter now runtime-validates the external generator result before returning it: only non-empty, non-whitespace strings are returned. Non-string, empty, and whitespace-only results throw the existing `PasswordResetLinkError` with `code` and message `unavailable`.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | Added malformed generator-result cases to `functions/test/provisioning/completed_integrity.test.ts` before production code; `cd functions && node --experimental-strip-types test/provisioning/completed_integrity.test.ts` failed 11/12 because `null` was returned rather than rejected. |
| GREEN | Added the narrow runtime type/nonblank guard in `functions/src/provisioning/status.ts`; the focused command passed 12/12. |
| TRIANGULATE | The focused test covers `null` and `0` non-strings plus `""` and `" \t\n"`; it verifies integrity reads precede the generator call, stable `unavailable` code/message, no completed-operation/profile mutation, no audit, and no retained generated link. Existing vectors retain valid fresh-link, retry, authorization, non-completed, integrity-failure, and immutability behavior. |
| REFACTOR | No refactor was required beyond the smallest guard; `cd functions && npx tsc --noEmit` exited 0 and scoped `git diff --check` exited 0. |

### Verification and Scope

- Retained completed task checkboxes were re-read and confirmed visibly checked: `- [x] P3.43 RED: fresh reset link — Auth \`generatePasswordResetLink\` called only after integrity passes; link returned; link never stored, logged, audited, or emailed; transient link failure returns stable retryable error leaving \`completed\` unchanged.` and `- [x] P3.44 GREEN: reset link passes.` No checkbox text required mutation because both were already truthful after correction verification.
- Files changed in this corrective unit: `functions/src/provisioning/status.ts`, `functions/test/provisioning/completed_integrity.test.ts`, and this cumulative `apply-progress.md`. `tasks.md` was read and retained unchanged; P3.45+ were not modified.
- Test commands: `cd functions && node --experimental-strip-types test/provisioning/completed_integrity.test.ts` RED 11/12 (expected failure), then GREEN/triangulation 12/12; `cd functions && npx tsc --noEmit` exit 0; scoped `git diff --check` exit 0. Node v24.20.0 satisfies the required Node >=22.6.0 gate.
- Deviation from design: none. The guard preserves generator call ordering, fresh retries, immediate-response-only link handling, authorization, integrity checking, and terminal completion immutability.
- Workload / PR boundary: retained feature-branch-chain P3.43/P3.44 correction only. The production guard is five added/replaced lines plus focused test cases; no source/test/docs were compressed to meet the existing 399-line cap. Ambient source/test paths are untracked, so ordinary tracked `git diff --numstat` cannot establish slice-only accounting.
- Structured status consumed: native `gentle-ai.sdd-status` v2 for `prepare-public-portfolio-repository`, `artifactStore:"openspec"`, `applyState:"ready"`, `nextRecommended:"apply"`, canonical repo-local workspace, and its sole allowed edit root. `actionContext` had no warnings; no native attempt, settlement, delivery, review, or other lifecycle mutation ran.
- Remaining retained boundary: `- [ ] P3.45 RED: full emulator flow — happy-path submission through to completed status with fresh reset link; no client-driven re-drive.` and all later P3.46+ tasks remain intentionally unchecked and outside this correction.

## P3.43–P3.44 — Fresh Completed Reset Link

**Status:** completed under Strict TDD for P3.43/P3.44 only. `getAuthorizedStatusWithPasswordResetLink` first completes authorization, safe projection, and completed-integrity verification, then invokes the injected generator-only port exactly once with the verified normalized email. It returns the raw link only in the immediate completed response; it stores, logs, audits, emails, and otherwise retains no link.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|
| P3.43 | Extended `functions/test/provisioning/completed_integrity.test.ts` before production code; the focused Node command failed because `PasswordResetLinkError` was not exported. | N/A — RED task. | The test proves authorization denial, non-completed projection, and integrity failure never invoke the generator. |
| P3.44 | Retained the genuine missing-export RED. | Added only the generator port, stable retryable `unavailable` error, and completed-response adapter; focused harness passes 11/11. | Two completed calls produce distinct links; transient failure leaves operation/profile/audits unchanged and a later call generates a link. |

### Verification and Accounting

- Completed persisted checkbox updates: P3.43 and P3.44 are visibly `- [x]` in `tasks.md`.
- Exact plan commands passed: `cd functions && node --experimental-strip-types test/provisioning/status.test.ts` (7/7); `cd functions && node --experimental-strip-types test/provisioning/dto.test.ts` (69 assertions); `cd functions && node --experimental-strip-types test/provisioning/authz.test.ts` (14 assertions); `cd functions && node --experimental-strip-types test/provisioning/completed_integrity.test.ts` (11/11). Node v24.20.0 satisfies the prerequisite.
- Non-retention/immutability evidence: success and transient rejection leave the completed operation/profile unchanged and add no audit; denied, active, and integrity-failed paths record zero generation calls. The source introduces no logging, audit, persistence, email, operation, or profile write boundary for the raw link.
- Files changed: `functions/src/provisioning/status.ts`, `functions/test/provisioning/completed_integrity.test.ts`, `tasks.md`, and this file. P3.45+ and `functions/src/index.ts` are untouched.
- Workload / PR boundary: feature-branch-chain corrective P3.43/P3.44 only. Parent-acquired native attempt accounting remains within the required 399-line cap; local `/dev/null` totals are not slice accounting because these source/test files were already untracked before this corrective unit.
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState:"ready"`, repo-local canonical workspace, and the sole allowed edit root. No action-context warnings. Parent owns token settlement; no `sdd-attempt` query, acquire, settle, reset, delivery, or review mutation ran.
- Remaining implementation tasks are intentionally untouched, starting with `- [ ] P3.45 RED: full emulator flow — happy-path submission through to completed status with fresh reset link; no client-driven re-drive.`

## P3.39–P3.40 — Safe Status DTO Projection

**Status:** completed under Strict TDD for P3.39/P3.40 only. `getAuthorizedStatus` reuses the frozen `projectStatusDto` after the existing authorized operation lookup and returns only `SafeStatusDto`; an unprojectable stored record throws the stable fail-closed `invalid-projection` error. No completed-integrity or reset-link behavior was added.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|
| P3.39 | Extended `functions/test/provisioning/status.test.ts` before `status.ts`; the focused Node runner failed because `StatusProjectionError` was not exported. | N/A — RED task. | The test declares exact own-key sets, frozen output, hostile-field exclusion, authorization read order, and invalid-projection rejection for all five statuses. |
| P3.40 | The P3.39 missing-export failure is the genuine RED evidence. | Added the narrow authorized projection handler; focused status runner passes 7/7. | Re-ran authorization 14 assertions, configured TypeScript, and scoped diff check. |

### Verification and Accounting

- Completed persisted checkbox updates: P3.39 and P3.40 are visibly `- [x]` in `tasks.md`.
- Files changed: `functions/src/provisioning/status.ts`, `functions/test/provisioning/status.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this progress file.
- Commands: `cd functions && node --experimental-strip-types test/provisioning/status.test.ts` (7 pass); `cd functions && node --experimental-strip-types test/provisioning/authz.test.ts` (14 assertions); `cd functions && npx tsc --noEmit` (exit 0); scoped `git diff --check` (exit 0). Node v24.20.0 satisfies the prerequisite.
- Deviation: the first RED test used an unsupported strip-types parameter property and was corrected in the test before rerunning; the genuine RED was the missing production exports. No production code preceded that RED.
- Native status consumed: `gentle-ai.sdd-status` v2, `applyState: ready`, repo-local canonical workspace and allowed edit root; continuing token `sha256:fa8ba7b70e9fdf2ff15b3685953c9f2d83e7e9d0bed84174f17cf10914b66999` acquired with `state: proceed`. No action-context warnings.
- Workload / PR boundary: feature-branch-chain, P3.39/P3.40 only. The active native attempt has a 399-line cap; final native-begin accounting is intentionally unfinalized because this slice must not settle the attempt. No source outside the two authorized provisioning paths was edited.
- `dto.ts`, `index.ts`, and all P3.41+ implementation/checkboxes are untouched.
- Remaining scoped persisted lines: `- [ ] P3.41 RED: completed integrity — re-read both Auth indexes + full provenance-tagged profile; failure or inconsistency returns stable integrity error without changing terminal operation or generating a link; deduplicated integrity audit.` and `- [ ] P3.42 GREEN: completed integrity passes.`

## P3.41–P3.42 — Completed Integrity

**Status:** completed under Strict TDD for P3.41/P3.42 only. `getAuthorizedStatusWithCompletedIntegrity` leaves the existing P3.37–P3.40 status handler unchanged, re-reads Auth by intended UID and normalized email, and requires both exact Auth identities plus full `matchesProfileProvenance` before returning the existing safe completed DTO. Every integrity failure returns only `integrity-failed`; it never mutates the terminal operation or has any reset-link boundary.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|
| P3.41 | Authored `functions/test/provisioning/completed_integrity.test.ts` before `status.ts`; direct Node execution failed because `CompletedIntegrityError` was not exported. | N/A — RED task. | Tests independently cover both Auth indexes, exact UID/email agreement, full provenance including canonical `displayName`, absence, malformed profile, read failure, operation immutability, and the PII-safe audit identity. |
| P3.42 | The missing-export result above is the genuine RED. | Added the injected integrity boundary and completed-only verifier; the focused harness passed 8/8. | Matching replay retains one audit; incompatible same event identity fails closed. |

### Verification and Accounting

- Persisted task checkboxes: P3.41 and P3.42 are `- [x]` in `tasks.md`.
- Files changed: `functions/src/provisioning/status.ts`, `functions/test/provisioning/completed_integrity.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this file.
- Six commands: direct status 7/7; DTO 69 assertions; authorization 14 assertions; completed-integrity 8/8; `npx tsc --noEmit` exit 0; Auth/Firestore/Functions emulator wrapper with completed-integrity 8/8. Node v24.20.0 satisfied the gate. The emulator reported pre-existing missing `functions/lib/index.js` while the requested Node harness still passed and all emulators shut down.
- `git diff --check` passed for every allowed path. Only the two P3.41/P3.42 source/test paths and required OpenSpec records were edited; `dto.ts`, `index.ts`, P3.43+ test paths, reset-link behavior, and frozen P3.37–P3.40 behavior remain untouched.
- Native status consumed: `gentle-ai.sdd-status` v2, repo-local canonical root and allowed edit root. Continuing token `sha256:4e9f976e64691d64ea81998e7715a67de2230b2da21ac2b2a89b0fd7838c826c` was acquired with `state: proceed`; native status still shows its active attempt and no settle/reset was run as instructed.
- Workload / PR boundary: feature-branch-chain, P3.41/P3.42 only. Conservative all-path accounting is <=316 lines: whole current untracked `status.ts` 177 + new test 106 + task checkbox replacement 4 + this bounded record <=29; this is below the user-required 399 cap. No source was compressed or expanded for budget fit.
- Remaining scoped persisted lines: `- [ ] P3.43 RED: fresh reset link — Auth generatePasswordResetLink called only after integrity passes; link returned; link never stored, logged, audited, or emailed; transient link failure returns stable retryable error leaving completed unchanged.` and `- [ ] P3.44 GREEN: reset link passes.`


## P3.25–P3.26 — Active Exact-Owner Terminalization

**Status:** completed under Strict TDD for the assigned P3.25/P3.26 slice only. `terminalizeActiveCurrent` accepts only a transaction-reread, unacknowledged current dispatch whose complete active tuple matches the operation, derived owner token, and live lease. It atomically writes immutable failure evidence/audit, clears owner and lease, and acknowledges the current dispatch. `auth_preflight` becomes `failed/terminal` with `terminalCode: unavailable`; other active phases become `manual_recovery/terminal` with `recoveryCode: internal`.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|
| P3.25 | `node --experimental-strip-types test/provisioning/worker_auth.test.ts` exited 1 before production code because `terminalizeActiveCurrent` was not exported. | Exact safe and unsafe terminalization, audit conflict rollback, and all eight active-CAS-field no-write probes pass. | Direct worker harness: 62 pass, 15 skipped, 0 fail. |
| P3.26 | The P3.25 export-missing failure is the genuine focused RED for the same atomic behavior. | Direct worker harness exits 0. | Firestore + Auth emulator harness: 77 pass, 1 skipped, 0 fail; includes real active terminalization atomic-commit proof. |

### Verification and Accounting

- Node v24.20.0 and Java 21.0.12 passed the prerequisite gates.
- `cd functions && ./node_modules/.bin/tsc --noEmit` exited 0.
- `git diff --check -- <allowed paths>` exited 0. The two source paths are untracked in the ambient worktree, so ordinary tracked `git diff --numstat` cannot provide a truthful slice-only count; no inferred count is recorded.
- Files changed: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this progress file.
- Persisted task updates: P3.25 and P3.26 are checked; P3.27+ remain unchecked.
- Workload / PR boundary: feature-branch-chain, P3.25–P3.26 only; no commit, PR, or delivery mutation.
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState: ready`, repo-local workspace with the canonical root as the allowed edit root. An active native attempt token remains held for parent settlement; no settlement was performed here.


## P2-enqueue-contract — P2.23–P2.24

**Status**: implemented under Strict TDD. The domain-facing enqueue port contains no Firebase or external queue SDK dependency; the strict fake records one immutable observable enqueue per compatible canonical dispatch identity and rejects incompatible reuse.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.23 | `functions/test/provisioning/enqueue.test.ts` | Unit | N/A (new files) | `node --experimental-strip-types test/provisioning/enqueue.test.ts` → `ERR_MODULE_NOT_FOUND` for absent `enqueue.ts` | N/A — RED task | Matching replay and incompatible same-ID reuse declared before implementation | None needed |
| P2.24 | `functions/test/provisioning/enqueue.test.ts` | Unit | RED retained | Same genuine RED retained | Same command → exit 0, 6 assertions | Matching replay yields one effect; incompatible reuse rejects without mutation; distinct identity yields a second effect | None needed |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/enqueue.test.ts` → exit 0, 6 assertions. |
| Runtime harness command/scenario and exact result | N/A: this is an injectable domain-port/strict-fake contract; the focused Node harness executes its observable in-memory behavior. Production queue construction belongs to P2.25. |
| Regression | Schemas 41 assertions; audit 46; submission 25; DTO 69; authorization 14; export metadata 4; MemoryStore 1 test; store conformance 4 tests — all passed. |
| TypeScript | Explicit enqueue source+test TypeScript and configured `npx tsc --noEmit` both exit 0. |
| Rollback boundary | Delete `functions/src/provisioning/enqueue.ts` and `functions/test/provisioning/enqueue.test.ts`; revert only P2.23–P2.24 checkboxes and this record. |

- **Implementation evidence revision**: `sha256:c05bf6a72b6017bd80669062d74a3781207a2565f03082c36047268909e7dbd9`, calculated from a UTF-8 newline-terminated manifest of the SHA-256 hashes for `functions/src/provisioning/enqueue.ts` and `functions/test/provisioning/enqueue.test.ts`.
- **Scope**: no production queue adapter, Firebase queue SDK, trigger, sweeper, emulator, or P2.25+ implementation was added.

## P2-schemas-audit — P2.0–P2.8

**Status**: independently accepted. Scope is limited to pure operation/dispatch/audit schemas and audit deduplication; no callable, outbox, worker, Firebase, or P3 behavior was added.

### Historical TDD Cycle Evidence

The assertion totals in this table are preserved implementation history, not current acceptance totals.

| Task | Layer | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|---|
| P2.0 | Harness | Node v24.11.1 gate passed | N/A | N/A |
| P2.1 | Unit | `schemas.test.ts` → `ERR_MODULE_NOT_FOUND` for `schemas.ts` | P2.2 | 11 invalid combinations plus canonical operation |
| P2.2 | Unit | P2.1 retained | `schemas.test.ts` → 12 operation assertions pass | Exact-key, UUID/digest, lifecycle, payload and timestamp paths |
| P2.3 | Unit | missing `isValidDispatch` export | P2.4 | Five invalid shapes plus identity, acknowledgement and no-regression paths |
| P2.4 | Unit | P2.3 retained | `schemas.test.ts` → 21 total assertions pass | Immutable identity and monotonic acknowledgement contract |
| P2.5 | Unit | `audit.test.ts` → `ERR_MODULE_NOT_FOUND` for `audit.ts` | P2.6 | Ten PII/non-contract rejections plus canonical audit event |
| P2.6 | Unit | P2.5 retained | `audit.test.ts` → 11 audit-schema assertions pass | Fixed allowlists and digest-only identity fields prevent raw PII/SDK detail |
| P2.7 | Unit | missing `deduplicateAudit` export | P2.8 | Five independent identity mismatches plus matching replay |
| P2.8 | Unit | P2.7 retained | `audit.test.ts` → 18 total assertions pass | Mismatch throws without changing the existing event; no refactor beyond the minimal TypeScript indexing correction |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Historical focused test commands | `cd functions && node --experimental-strip-types test/provisioning/schemas.test.ts` → 21 assertions pass; `cd functions && node --experimental-strip-types test/provisioning/audit.test.ts` → 18 assertions pass. |
| Runtime harness | N/A: both contracts are deterministic pure TypeScript; Firebase/callable/outbox behavior belongs to later P2 tasks. |
| TypeScript | Explicit source+test and explicit two-source `npx tsc --noEmit` commands exit 0. |
| Rollback boundary | Delete `functions/src/provisioning/{schemas,audit}.ts` and `functions/test/provisioning/{schemas,audit}.test.ts`; revert only P2.0–P2.8 checkboxes and this record. |

### Current Acceptance Record

- **Accepted evidence**: correction `sha256:93b5138397a6fc507f6aa54be82196fe09a4f16e262747cc6e93c1fb5ddd89fd`; fresh independent acceptance `sha256:92d5e1f8a42edb9259172157367d05bea1ecec8fc317ccf4dd1801e8566388c7`; prior failed evidence `sha256:4d632a9cbb929dbcd3d014e9618f7e54546c669fb4d1be8193e8f874e6730a3d` was remediated.
- **Current matrix**: schemas 41/41, audit 46/46, durable total 87/87, and supplemental 9/9. Configured TypeScript and `git diff --check` passed.
- **Scope and integrity**: cumulative P2 source/test scope 271/800; correction-only scope 47/200; independent verification made zero mutations.
- **Artifact authority migration**: OpenSpec is canonical. Engram chunk observations #3433, #3457–#3459, #1725, and #3460 are immutable historical snapshots and MUST NOT be current parity gates or be updated. Engram may retain only small path/hash/evidence summaries, never full artifact bytes.
- **Pending work**: P2.11+ remains unchecked and pending.

## P2-authorization — P2.9–P2.10

**Status**: implemented under Strict TDD. The isolated authorization port performs only the PII-safe denial audit write before surfacing a stable denial; submission and resource mutation remain future tasks.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.9–P2.10 | `functions/test/provisioning/authz.test.ts` | Unit | N/A (new authorization files) | `node --experimental-strip-types test/provisioning/authz.test.ts` → `ERR_MODULE_NOT_FOUND` for absent `authz.ts`; raw correlation probe then failed with `AuthorizationError: unauthenticated` | Same command → exit 0, 14 assertions | Unauthenticated, active employee, raw-correlation rejection, and active admin branches prove both denial paths, PII-safe audit admission, and authorization | Replaced a self-referential audit-ID expectation with an independently computed SHA-256 oracle; focused test remained green |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/authz.test.ts` → exit 0, 14 assertions. |
| Runtime harness command/scenario and exact result | Same Node harness injects a read/audit port and proves denial-audit completion precedes the surfaced denial; exit 0, 14 assertions. No Firebase emulator is needed because P2.9 introduces no callable or Firebase adapter. |
| Regression | `schemas.test.ts` → 41 assertions; `audit.test.ts` → 46 assertions, both exit 0. |
| TypeScript | Explicit `authz.ts` + test TypeScript check and configured `npx tsc --noEmit` both exit 0. |
| Rollback boundary | Delete `functions/src/provisioning/authz.ts` and `functions/test/provisioning/authz.test.ts`; revert only P2.9–P2.10 checkboxes and this record. |

- **Implementation evidence revision**: `sha256:70bb7928d7590b79327d2d878e51aa466b447285ebc4c406f3d70890dafe2adc`, calculated from the SHA-256 manifest of the new authorization source and test files.
- **Line accounting**: 234 changed lines including 203 source/test lines and SDD bookkeeping; the completed work unit remains below the 400-line attempt maximum.

## P2-callable-metadata — P2.11–P2.12

**Status**: implemented under Strict TDD. The submission export is an App Check-protected v2 callable and remains fail-closed until P2.13 owns request handling.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.11–P2.12 | `functions/test/export-metadata.test.ts` | Unit / structural | N/A (new callable export and test) | `node --experimental-strip-types test/export-metadata.test.ts` → `ERR_MODULE_NOT_FOUND` for absent `src/index.ts` | Same command → exit 0, 4 assertions | Skipped: one required immutable callable option; assertions cover exported v2 callable metadata and the exact bound option | None needed |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/export-metadata.test.ts` → exit 0, 4 assertions. |
| Runtime harness command/scenario and exact result | Same Node harness loads the actual Firebase v2 callable wrapper and inspects its exported deployment metadata plus the bound `enforceAppCheck:true` option → exit 0, 4 assertions. Firebase emulator is not required for this metadata-only slice. |
| Regression | `schemas.test.ts` → 41 assertions; `audit.test.ts` → 46 assertions; `authz.test.ts` → 14 assertions, all exit 0. |
| TypeScript | Explicit `index.ts` + export-metadata test TypeScript check and configured `npx tsc --noEmit` both exit 0. |
| Rollback boundary | Delete `functions/src/index.ts` and `functions/test/export-metadata.test.ts`; revert only P2.11–P2.12 checkboxes and this record. |

- **Implementation evidence revision**: `sha256:0b39e6d50a3e53c8f026e0e91133f5713940cf6bdd74108db6a27c5f97b09280`, calculated from a UTF-8 newline-terminated manifest of the SHA-256 hashes for `functions/src/index.ts` and `functions/test/export-metadata.test.ts`.
- **Line accounting**: 48 changed lines including source, test, and SDD bookkeeping; below the 400-line maximum.

## P2-submission-schema — P2.13–P2.14

**Status**: implemented under Strict TDD. The callable now validates and canonicalizes input before its deliberately pending P2.15 persistence boundary; invalid input returns only `invalid-argument`.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.13–P2.14 | `functions/test/provisioning/submit.test.ts` | Unit | `export-metadata.test.ts` → 4 assertions pass | `submit.test.ts` → `ERR_MODULE_NOT_FOUND` for absent `submit.ts` | Same command → exit 0, 7 assertions | Valid canonicalization; disallowed role; non-finite value; each required field absent | None needed |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/submit.test.ts` → exit 0, 7 assertions. |
| Runtime harness command/scenario and exact result | The same Node harness executes the production validation adapter with the existing canonical normalizer; Firebase emulator is N/A because atomic persistence is owned by P2.15–P2.16. |
| Regression | Export metadata 4 assertions; schemas 41 assertions; audit 46 assertions; authorization 14 assertions — all exit 0. |
| TypeScript | Explicit source+test TypeScript command and configured `npx tsc --noEmit` both exit 0. |
| Rollback boundary | Revert the P2.13 changes in `functions/src/index.ts`; delete `functions/src/provisioning/submit.ts` and `functions/test/provisioning/submit.test.ts`; revert only P2.13–P2.14 checkboxes and this record. |

- **Implementation evidence revision**: `sha256:3030c239a3a96e10660072a8e009ed3f78f9b05991394f1c3d2031ec314c8f97`, calculated from a UTF-8 newline-terminated manifest of SHA-256 hashes for `functions/src/index.ts`, `functions/src/provisioning/submit.ts`, and `functions/test/provisioning/submit.test.ts`.
- **Line accounting**: 124 conservative changed lines including source, test, and SDD bookkeeping; below the 400-line maximum.

## P1a2-ii — Pure OperationState Transitions + Invariants

**Status**: independently accepted at native ordinal 105; evidence revision `sha256:8fa48fbbd0e387f0025c95afc8bbcab0ef967093010d926f308d9fed7b1c9dd6` records 601/601 assertions and zero validation mutation.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| ii.0–ii.20 | `functions/test/provisioning/model.test.ts` | Unit | Existing model harness exit 0 | Node harness exit 1: `ii ACQ succeeds` while all eight events remained unsupported | Node harness exit 0 after the eight private reducer branches | Five exact C-admitted takeover rows, two takeover generations, both foreign inequality controls, and event-specific lifecycle/correlation negatives | Independent ordinal-105 acceptance: focused model, explicit source+test TypeScript, source-only TypeScript, P1a1 controls, fixture integrity, and diff check pass |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` → exit 0; inherited A/B-2/C controls plus the eight-event matrix pass. |
| Runtime harness command/scenario and exact result | The same Node strip-types pure in-memory reducer harness → exit 0; no runtime boundary exists in this pure slice, so Firebase/Auth/Firestore/Cloud Tasks are N/A. |
| Rollback boundary | Revert only the P1a2-ii additions in `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, and this slice's two SDD records to accepted P1a2-i-C. |

### Verification

- Node v24.11.1 satisfies the Node >= 22.6.0 gate.
- Explicit source+test TypeScript and source-only TypeScript exit 0.
- P1a1 controls: types 36/36, normalization 36/36, IDs 32/32, and fixture integrity/recursive immutability all pass.
- The pure reducer has exactly eight success branches; `auth_preflight`, `auth_no_effect`, `ack_dispatch`, and `terminalize` remain unsupported after inherited gates.
- No persistence, external effect, acknowledgement, retry, audit, terminal evidence, or P2/P3 behavior was added.

## Work Unit 1 - COMPLETED

114 authored lines. Reviewed (lineage `review-544ad22fd4046a93`), post-apply allowed, UNSTAGED/UNCOMMITTED.

### WU1 Immutable State

Source HEAD: `05685e0`, branch `master`, 62 dirty. Portfolio HEAD: `05685e0`, branch `feat/prepare-public-portfolio`, staged `A .codegraph/.gitignore` + `D tatus`, diff SHA-256 `F44C75D54283DCCFDEE48C1274D61EDCD8D355118CDD29DDB74AC0CA0FE0C050`.

---

## Work Unit 0 - ATTEMPT 2 - CANDIDATE (pending native finish)

659 authored changed lines (537 additions + 122 deletions). Maintainer-approved size:exception <800.

### Helper (`tool/check_staged_dart_format.dart`, 193 lines)

- Discovers repo root via `git rev-parse --show-toplevel`
- Reads staged ACMR `.dart` paths (NUL-safe, `-z`); ignores deletions; renames use destination path
- Empty index -> exit 0 (no-op)
- Staged Dart with unstaged content -> fail closed (exit 1, actionable message)
- Runs `dart format --output=none --set-exit-if-changed` via argument list (never shell interpolation)
- `DART_FORMAT_BIN` env var override with secure default `'dart'`; ProcessException caught with actionable error
- Never writes, stages, resolves, or installs

### Hooks

Both `.githooks/pre-commit` and `.githooks/pre-commit.bat`: invoke helper -> check exit code -> `flutter analyze --no-pub --fatal-infos --fatal-warnings`. Removed whole-tree `dart format lib/` mutation.

---

## Work Unit 0.1 - ATTEMPT 3 - post-review bounded correction (windows-batch-call)

**Lineage**: `sha256:bc15e0761adb6f79edc2bfda8c8b4c7f4b3cc364a9407461e0e363d5f540dc67`
**Generation**: 3
**Ordinal**: 3
**Max budget**: 120 authored changed lines
**Actual**: 103 authored changed lines (1 production + 102 test/harness)

### Defect

Committed `.githooks/pre-commit.bat` invoked `dart run ...` without `call`. On this machine `dart` resolves to `C:\flutter\bin\dart.bat`; batch-to-batch invocation without `call` transfers control and never returns. Actual commit output stopped after `Formatted 2 files (0 changed)` and never reached `Running static analysis...`.

### Production Fix

`.githooks/pre-commit.bat` line 15: add `call` prefix -> `call dart run tool\check_staged_dart_format.dart`. Single-token change (1 insertion, 1 deletion).

### TDD Cycle Evidence (Strict TDD)

| Task | Test File | Layer | Safety Net | RED | GREEN | TRIANGULATE | REFACTOR |
|------|-----------|-------|------------|-----|-------|-------------|----------|
| 0.1 | `test/tool/pre_commit_batch_call_test.dart` | Integration | N/A (new) | 2/5 assertions failed: analyzer not reached after formatting OK; analyzer failure masked by early exit | All 5/5 assertions pass after adding `call` | 3 cases: happy-path (formatting OK->analyzer reached, exit 0), dart-failure (analyzer NOT reached, fail closed), flutter-failure (fail closed) | Formatted, existing 15-suite re-green |

### RED Evidence (before fix)

```
Cases: 3
Assertions passed: 3
Assertions failed: 2
FAILED: 2 assertion(s) failed
  FAIL: analyzer must be reached after formatting passes, got exit 0
  FAIL: must fail non-zero, got 0
```

### GREEN Evidence (after fix - `call` added)

```
=== pre-commit.bat batch call semantics ===
  formatting OK -> analyzer reached (exit 0) ... (164ms)
  formatting fails -> analyzer NOT reached, fail closed ... (117ms)
  formatting OK, analyzer fails -> fail closed ... (145ms)
=== RESULTS ===
Cases: 3  Passed: 5  Failed: 0
```

### Existing Suite Re-green

```
=== Integration suite: check_staged_dart_format (attempt 2) ===
Cases: 15
Assertions passed: 20
Assertions failed: 0
All 15 cases passed (20 assertions).
```

### Work Unit Evidence (WU0.1)

| Evidence | Required value |
|---|---|
| Focused test command and exact result | `dart run test/tool/pre_commit_batch_call_test.dart` -> 3 cases, 5 assertions, 0 failures |
| Runtime harness | Mock `dart.bat`/`flutter.bat` shims prepended to PATH; marker-file proof that `call` enables analyzer step reachability; exit-code proof of fail-closed for both dart and flutter failures |
| Rollback boundary | Revert single word `call ` from `.githooks/pre-commit.bat` line 15; delete `test/tool/pre_commit_batch_call_test.dart` |

### Files Changed

| File | Action | Lines |
|------|--------|-------|
| `.githooks/pre-commit.bat` | Modified (1 word) | 1 insertion, 1 deletion |
| `test/tool/pre_commit_batch_call_test.dart` | Created | 102 lines |

### Worktree State

Branch `fix/pre-commit-staged-check`, HEAD `491541958865cb37fa128c6632ef70823d00fa6e`. Worktree clean before this correction. After: `pre-commit.bat` modified (unstaged), `pre_commit_batch_call_test.dart` untracked. Index untouched. Source repo `D:\control_horario` untouched.

---

## Cumulative Status

| Work Unit | Tasks | Lines | State |
|-----------|-------|-------|-------|
| WU0 (attempt 2) | 0.1-0.3 | 659 (size:exception) | Candidate - pending native finish |
| WU0.1 (attempt 3) | windows-batch-call | 103 | Correction complete - pending native finish |
| WU1 | 1.1-1.6 | 114 | Complete, reviewed, unstaged |
| WU2-11 | - | - | Pending |

## Migration / Final-State Note

The preceding sections preserve the extracted apply-progress snapshot. They include stale candidate and uncommitted states that were superseded after extraction. The authoritative final state at migration is:

| Work Unit | Final state | Evidence |
|---|---|---|
| WU0 | Complete and committed locally | Commit `4915419`, correction commit `3e9146f`; final approved lineage `review-3b4a3a0f30245bc4`; clean worktree at HEAD `3e9146f`, tree `448709be0613f746acfe168e0880e252d393dc10`; formatting and `flutter analyze` passed with no issues |
| WU0.1 | Complete | Native attempt max 120, finished at 116 lines |
| WU0.2 | Complete | Native attempt max 10, finished at 10 lines |
| WU1 | Complete and committed locally | Base advanced compatibly to `3e9146f`; `.codegraph/.gitignore` entered the WU0 base; final delta only deleted `tatus`; commit `7772e14`; final approved lineage `review-3447c0e8c1233521`; tree `b57799d0b19124e4d27c1c9d0370f0c18781e9d0` |
| WU2 | Complete | Ordinal 5 failed because native measured 485 > max 400; maintainer approved `size:exception` max 500; ordinal 6 passed with native incremental `changed_lines` 32 |
| WU3 | 3.1 complete; 3.2 review-rejected/deferred | Deployment disclaimers retained. Direct-client `/users` denial is deferred until the trusted backend/client replacement slice (WU4-WU5); current provisioning behavior remains unchanged. |
| WU4 | SPLIT — WU4a dependency scaffold complete; WU4b/WU4c pending | Original attempt 8 over-budget at 3520 lines (lockfile 2978 + authored 393 + SDD delta + node_modules leakage). Maintainer approved split: WU4a (dependency scaffold, lockfile exception max 3100), WU4b (semantic implementation, max 1000), WU4c (tests, max 1000). WU4a is atomic lockfile + package/tsconfig + firebase.json functions block only. |
| WU5-WU11 | Pending | No later work unit is complete |

No push or PR occurred. The original checkout remained untouched.

---

## Work Unit 2 — COMPLETE (ordinal 6, generation 6)

Ordinal 5 failed because native measured 485 > max 400. The maintainer approved `size:exception` max 500. Ordinal 6 passed at native revision `sha256:84be2f2284f3e1e34c37b630591fd85a4eebfabb4cfb133fb8e27cd313369462` with evidence revision `sha256:17f222913d42f0b657e19c6461560da35fc5e1158f83fd0de47666153f4b47c6` and native incremental `changed_lines` 32.

### TDD Cycle Evidence (Strict TDD)

| Task | Test File | Layer | Safety Net | RED | GREEN | TRIANGULATE | REFACTOR |
|------|-----------|-------|------------|-----|-------|-------------|----------|
| 2.1-2.2 | `test/scripts/seed_users_credentials_test.dart` | Unit | N/A (new) | ✅ 13 compile errors: imports + symbols not found | ✅ 26/26 assertions pass | ✅ 3 cases: special chars, valid roles, multi-entry env | ✅ Format clean; compressed test from 45→26 assertions |

### RED Evidence

```
dart run test/scripts/seed_users_credentials_test.dart → 13 compile errors
(seed_user_definitions.dart, seed_credentials.dart not found;
 getSeedUserDefinitions, resolveSeedPassword, SeedCredentialError undefined)
```

### GREEN Evidence

```
=== WU2 seed credential purge ===
-- 2.1: Data definitions --
-- 2.2: Password resolution --
=== RESULTS: 26 passed, 0 failed ===
```

### Production Code

| File | Action | Lines | Purpose |
|------|--------|-------|---------|
| `scripts/shared/seed_user_definitions.dart` | Created | 44 | Demo user records: no passwords, @example.com, DEV- ids, demo names |
| `scripts/shared/seed_credentials.dart` | Created | 31 | `resolveSeedPassword()`: env-var resolution with fail-closed missing/empty |
| `scripts/seed_users.dart` | Modified | 75 (was 147) | Uses shared modules; env-var passwords; fail-fast credential check; no passwords in output |
| `scripts/seed_users_simple.dart` | Modified | 14 (was 103) | Uses shared definitions; prints env var names, never passwords |

### Work Unit Evidence

| Evidence | Required value |
|---|---|
| Focused test command and exact result | `dart run test/scripts/seed_users_credentials_test.dart` → 26/26 pass |
| Runtime harness command/scenario | `dart run scripts/seed_users_simple.dart` → clean output, no passwords printed; `seed_users.dart` fail-closed path proven by test (26/26 pass); standalone `dart run` blocked by `dart:ui` (Firebase plugins require Flutter context — pre-existing, not a WU2 regression) |
| Rollback boundary | Delete `scripts/shared/seed_user_definitions.dart`, `scripts/shared/seed_credentials.dart`, `test/scripts/seed_users_credentials_test.dart`; revert `scripts/seed_users.dart` and `scripts/seed_users_simple.dart` to HEAD `5f7eb3a` |

### Quality Checks (revalidated ordinal 6)

- `dart format --output=none --set-exit-if-changed` on 5 files → 0 changed (clean)
- `flutter analyze --no-pub --fatal-infos --fatal-warnings test/scripts/ scripts/shared/` → No issues found
- `dart run scripts/seed_users_simple.dart` → clean output, env var names only, no passwords
- Protected paths `.atl/*` / `lib/core/theme/app_colors.dart` unchanged → confirmed
- No-secret/PII scan (passwords, real emails, real names) → 0 hits

### WU2 Result Contract

| Field | Result |
|---|---|
| status | success |
| executive_summary | Removed embedded seed credentials and introduced fail-closed environment-based password resolution. |
| artifacts | WU2 production changes, focused tests, quality-check evidence, and native finish evidence recorded above. |
| next_recommended | Native review of WU2 before staging, commit, or WU3. |
| risks | Full `seed_users.dart` cannot run under plain `dart run` due to the pre-existing `dart:ui` Flutter dependency. |
| skill_resolution | paths-injected |

### Worktree State

Branch `feat/prepare-public-portfolio`, HEAD `5f7eb3a`. All changes unstaged/uncommitted. 4 modified + 3 new untracked files. Source repo `D:\control_horario` untouched.

---

## Work Unit 3 — REVIEW-REJECTED ATTEMPT (3.1 retained; 3.2 deferred to WU4-WU5)

Revision: `sha256:6119da4cb1a2399e12d9e0a5a0ad61bea7d1ded515860555123a55c3e32529b1`. Delivery: `exception-ok` (maintainer-approved WU3 `size:exception` max 800). Actual: 193 total changed lines (183 insertions + 10 deletions).

### TDD Cycle Evidence (Strict TDD)

| Task | Test File | Layer | Safety Net | RED | GREEN | TRIANGULATE | REFACTOR |
|------|-----------|-------|------------|-----|-------|-------------|----------|
| 3.1 | N/A (docs) | N/A | N/A | N/A (docs — structural readback + claim scan) | N/A | N/A | N/A |
| 3.2 | `test/firestore/firestore_rules.test.js` | Integration (@firebase/rules-unit-testing) | ✅ 43/43 baseline | ✅ 4 genuine RED: safe self-creation, admin→employee, admin→rrhh, rrhh→employee — all currently allowed | REJECTED: 51/51 candidate pass (unconditional client-create denial); review `review-7644de9233c3cbd0` rejected for breaking provisioning before WU4/WU5 | REJECTED: rules and tests restored to HEAD by review correction | DEFERRED: unconditional denial not applied; pending WU4-WU5 trusted backend delivery |

### RED Evidence (3.2 — REJECTED CANDIDATE; not in current tree)

51/51 candidate test run (BEFORE review correction; restored to HEAD after rejection):

```
51 tests: 47 pass, 4 fail
✖ denies safe self-creation (normative: only Admin SDK may create /users documents)
✖ denies admin from creating an employee-role user via direct client
✖ denies admin from creating an rrhh-role user via direct client
✖ denies rrhh from creating an employee-role user via direct client
All 4 failures: expected request to fail, but it succeeded.
```

This was the RED evidence for the candidate that native review `review-7644de9233c3cbd0` subsequently rejected. Rules and tests were later restored to HEAD.

### GREEN Evidence (3.2 — REJECTED CANDIDATE; not in current tree)

Candidate run that passed after unconditional rule hardening (BEFORE review correction; restored to HEAD after rejection):

```
npx firebase emulators:exec --only firestore "node --test test/firestore/firestore_rules.test.js"
ℹ tests 51
ℹ pass 51
ℹ fail 0
```

Native review `review-7644de9233c3cbd0` rejected this candidate: unconditional client-create denial breaks provisioning before WU4/WU5. The review correction restored `firestore.rules` and `test/firestore/firestore_rules.test.js` to HEAD. No runtime test rerun after restoration — native runtime objective is complete.

### Production Code (3.2 — REJECTED; restored to HEAD)

Native review `review-7644de9233c3cbd0` rejected the unconditional `/users` denial because it breaks provisioning before WU4/WU5 provides the trusted backend and client integration. The review correction restored `firestore.rules` and `test/firestore/firestore_rules.test.js` to HEAD (content-identical to `05685e0`). No code changes remain applied.

| File | Action | Lines | Purpose |
|------|--------|-------|---------|
| `firestore.rules` | Reverted to HEAD | — | Unconditional `allow create: if false` rejected; HEAD content restored |
| `test/firestore/firestore_rules.test.js` | Reverted to HEAD | — | WU3 hardening tests removed; HEAD content restored |

### Production Code (3.1)

| File | Action | Lines | Purpose |
|------|--------|-------|---------|
| `docs/deployment/DEPLOYMENT_SUCCESS.md` | Modified | 5A | Truthful portfolio disclaimer banner |
| `docs/deployment/DEPLOYMENT_QUICKSTART.md` | Modified | 4A | Truthful portfolio disclaimer banner |
| `docs/deployment/DEPLOYMENT_MI_CONTROL_HORARIO.md` | Modified | 4A | Truthful portfolio disclaimer banner |

### Documentation Readback (3.1)

- Deployment docs: Truthful disclaimer banners warn readers that no deployment has occurred and publication gates are pending. Original historical content preserved behind disclaimers.
- README.md, package.json, docs/README.md: Reverted to HEAD (out of WU3 scope — belong to WU7/WU9-WU11).
- Protected paths (`.atl/*`, `lib/core/theme/app_colors.dart`): Confirmed unchanged.

### Work Unit Evidence (3.2 candidate — REJECTED; 3.1 retained)

| Evidence | Required value |
|---|---|
| Focused test command and exact result (3.2 REJECTED CANDIDATE) | `npx firebase emulators:exec --only firestore "node --test test/firestore/firestore_rules.test.js"` → 51/51 pass, 0 fail — **was the rejected candidate result; not current after HEAD restoration** |
| Focused test (3.1 docs — structural) | N/A (documentation claim scan; no executable tests) |
| Runtime harness command/scenario (3.2 REJECTED CANDIDATE) | Firebase Firestore emulator; `withSecurityRulesDisabled` context proves Admin SDK bypass semantics — **rejected candidate evidence preserved for audit** |
| Rollback boundary (3.1 only) | Revert deployment doc disclaimer banners from three docs |

### Quality Checks (post-correction state)

- Protected paths `.atl/*` / `lib/core/theme/app_colors.dart` unchanged ✅
- Documentation claim scan: deployment docs carry truthful disclaimers ✅
- No secrets/credentials introduced ✅
- No transitional-allowance claims in evidence ✅
- Firestore rules tests: not rerun after HEAD restoration (native runtime objective complete; no runtime test required post-restoration)

### WU3 Result Contract (post-correction)

| Field | Result |
|---|---|
| status | partial: 3.1 complete; 3.2 review-rejected/deferred |
| executive_summary | Task 3.1 deployment disclaimers applied to three deployment docs and retained. Task 3.2 unconditional client-create denial was implemented, passed 51/51 tests, but native review `review-7644de9233c3cbd0` rejected it for breaking provisioning before WU4/WU5 provides the trusted backend/client integration. Rules and tests restored to HEAD. |
| artifacts | WU3 deployment doc disclaimers (3.1, retained). Rules/tests candidate evidence preserved above for audit. No rules change remains applied in current tree. |
| next_recommended | Defer task 3.2 rule hardening until WU4-WU5 deliver trusted backend and client integration. Native review lineage `review-7644de9233c3cbd0` is escalated and must be recovered only after this candidate change. |
| risks | WU4-WU5 backend must use Admin SDK for user creation before 3.2 unconditional denial can be applied. |

### Worktree State

Branch `feat/prepare-public-portfolio`, HEAD `b5eec2f`. All changes unstaged/uncommitted. 7 modified files. Source repo `D:\control_horario` untouched.

---

## Work Unit 4 — SPLIT: WU4a (dependency scaffold), WU4b (implementation), WU4c (tests)

### WU4a — Dependency Scaffold (ordinal 9, generation 9)

**Status**: Candidate — pending native finish.

Original WU4 attempt 8 (ordinal 8, generation 8) failed at 3520 total candidate lines: lockfile (2978) + authored source (393: 147 index.ts + 204 test + 20 package.json + 14 tsconfig.json + 8 firebase.json) + SDD delta + node_modules leakage. Exceeded the 400 authored-line budget.

Maintainer authorized a WU4a lockfile exception with HARD maximum 3100 changed lines. WU4b and WU4c remain pending under 1000 lines each.

### WU4a Scope

**KEPT** (dependency scaffold only):
| File | Action | Lines | Purpose |
|------|--------|-------|---------|
| `functions/package.json` | Created | 20 | Cloud Functions v2 dependencies (firebase-admin, firebase-functions) |
| `functions/package-lock.json` | Created | 2978 | Reproducible lockfile for `npm ci` |
| `functions/tsconfig.json` | Created | 14 | TypeScript config (NodeNext, ES2022, strict) |
| `functions/src/placeholder.ts` | Created | 2 | Minimal build-safe placeholder (satisfies `include: ["src"]`) |
| `firebase.json` | Modified | +8 | Functions source/config and functions emulator port block |

**REMOVED** (deferred to WU4b/WU4c):
- `functions/src/index.ts` (147 lines — semantic implementation)
- `functions/test/create_user.test.ts` (204 lines — tests)

### WU4a Work Unit Evidence

| Evidence | Required value |
|---|---|
| Focused test command and exact result | `npm ci --ignore-scripts` → added 253 packages, audited 254 packages in 21s; lockfile reproduces cleanly from `package.json` |
| Runtime harness | `npx tsc --noEmit` → no errors (TypeScript config valid; placeholder compiles) |
| Rollback boundary | Delete `functions/` directory entirely; revert `firebase.json` to HEAD `ea22d22`. No other files touched. |

### Lockfile Reproducibility Validation

```
npm ci --ignore-scripts
→ added 253 packages, audited 254 packages in 21s
→ npm ci summary: 8 moderate; npm audit --json: 9 moderate, 0 high, 0 critical (introduced by WU4a firebase-admin@13.10.0 + firebase-functions@6.6.0; HEAD has no functions/package.json)
```

### TypeScript Build Validation

```
npx tsc --noEmit
→ exit 0, no output — config valid, placeholder compiles cleanly
```

### Candidate Line Count

| Component | Lines |
|---|---|
| `functions/package.json` | 20 |
| `functions/package-lock.json` | 2978 |
| `functions/tsconfig.json` | 14 |
| `functions/src/placeholder.ts` | 2 |
| `firebase.json` diff | 8 (+8/-0) |
| `apply-progress.md` delta | 78 (+77/-1) |
| **Total** | **3100** |
| Node modules | Excluded (git-ignored) |

### WU4b/WU4c — Pending

- **WU4b**: Semantic implementation of `functions/src/index.ts` (authorizeRequest, validateInput, computeFingerprint, provisionUser, onCall wrapper) — max 1000 authored lines.
- **WU4c**: Test suite `functions/test/create_user.test.ts` (16 behavior-first tests) — max 1000 authored lines.

### Worktree State

Branch `feat/prepare-public-portfolio`, HEAD `ea22d22`. Changes unstaged/uncommitted:
- `M firebase.json` (modified)
- `?? functions/` (new, untracked — lockfile + package.json + tsconfig.json + placeholder.ts; src/index.ts and test/create_user.test.ts removed)
Source repo `D:\control_horario` untouched.

---

## Architecture Reset and Superseded Plans

### Design Redesign

The validated design at revision `sha256:6e04cd501986d26986f3caf6cd728c8520009b70b58d3533580ecde5378b6458` replaces the callable-only saga with an **outbox + Cloud Tasks + scheduled-repair** topology. The prior callable-owned saga and compensation design are superseded.

### Superseded Plans (no false completion carried forward)

| Plan | Status |
|---|---|
| Original combined-P1 (executable contract + persistence in one slice) | Superseded — failed ordinal 21 (2,273 lines before any tests) |
| Single-P1a (types + normalization + IDs + reducer + invariants in one slice) | Superseded — failed ordinal 22 (2,679 all-path lines; unauthorized `functions/tsconfig.json`) |
| Current 6-slice plan (P1a1, P1a2, P1b, P2, P3, P4) | Active — this is the authoritative plan |
| Stale WU4b/WU4c | Superseded — replaced by P1a1–P4 decomposition |

### Failed Ordinals (historical evidence only)

| Ordinal | Scope | Lines | Stash | Verdict |
|---|---|---|---|---|
| 19 | Unknown | Unknown | — | Failed; no completion carried forward |
| 20 | Unknown | Unknown | — | Failed; no completion carried forward |
| 21 | Combined P1 | 2,273 before tests | `66424881e1b7b064a61d6bd884daa13f7793fa12` | Failed; over-budget; implementation before tests |
| 22 | Single P1a | 2,679 all-path (Git numstat) | `3ab7b419f344077b3c3b4667391b155700cfe9fe` | Failed; unauthorized `functions/tsconfig.json`; over STOP+max |

**Both stashes are evidence-only. Never restored, copied, or cherry-picked. No checkbox/completion claims carried forward from them.**

### Preserved Completion (WU0–WU4a)

| Work Unit | Status | Evidence |
|---|---|---|
| WU0 | Complete | Commit `4915419`, correction `3e9146f`, lineage `review-3b4a3a0f30245bc4` |
| WU1 | Complete | Commit `7772e14`, lineage `review-3447c0e8c1233521` |
| WU2 | Complete | Ordinal 6, generation 6 |
| WU3.1 | Complete | Deployment disclaimers retained |
| WU3.2 | Deferred | Review-rejected; re-apply after trusted backend/client (P4) |
| WU4a | Complete | Commit `a0a79cc` — dependency scaffold |

No false implementation completion from failed ordinals 19/20/21/22. P1a was never complete.

### Current Slice: P1a1 — Types + Normalization + IDs + Canonical Fixtures

**Ordinal 23** (first attempt): failed. STOP violation at 1,700 reforecast threshold; independent measured full candidate was 1,851 lines. Not accepted; no completion carried forward.

**Ordinal 24**: mechanically passed unchanged revalidation (same candidate bytes) but fresh phase-contract validation FAILED against the six CRITICAL groups.

**Ordinal 25** (bounded remediation — FAILED): native measured 1,675 correction lines; independent comparison measured 1,729; both exceed max 1,000. Full candidate independently measured 1,780. Ordinal 25 is NOT accepted; no completion carried forward.

**Ordinal 26** (residual contract remediation — ACCEPTED): native ordinal 26 passed at revision `sha256:2d693675feac2b8a87400a4f019a7b4e9f50f601fb65119d2dfc74d004875af4`. Final candidate `sha256:cbc789d9a27f5fd0df86747a72683ca94fabb2bca171d82adebe1f3fdc3c7aa2`, tree `d4860f7206707c0a91e13fdb79038efbc6bf4134`; full candidate 1,909/2,000 changed lines, ordinal-26 residual 361/400. Fresh independent validation: all five groups PASS. Proof: types 36/36, normalize 36/36, ids 32/32, fixture integrity + recursive immutability pass, explicit source+test tsc pass, source-only tsc pass, and `git diff --check` clean. P1a2 and downstream remain pending.

---

## P1a2-i-A-1a — Immutable Vocabulary + Genuine Bidirectional Type Proof

### Ordinal 35 — FAILED VALIDATION

Candidate `sha256:9cdd40fa...`, tree `8d1e0d9e`, 258 changed lines. Three findings:
1. Nested `STATUS_PHASE_MAP` phase arrays mutable — only outer `Object.freeze(_MAP)` applied.
2. Compile-negative fixtures used detached local maps, not implementation-coupled types.
3. Premature `VERIFIED`/independent-acceptance claims.

### Ordinal 36 — FAILED (120-line STOP breach)

Bounded corrective execution: nested-array freeze fix (5 lines model.ts + 6 lines model.test.ts) + compile-negative implementation-coupling via `_StatusPhaseMap` export. Correction delta 124 lines (65A+59D), exceeding mandatory 120-line STOP. Full candidate 264/400. Ordinal 36 is NOT accepted.

### Ordinal 37 — FAILED (anti-vacuity/bookkeeping)

Attempted anti-vacuity correction. Compile-negative fixtures used `_StatusPhaseMap`-derived types but did NOT consume the production's generic proof-direction mechanism (`_ProofNoMissing`/`_ProofNoExtra` extends pattern). Weakening production proof to unconditional `true` left compile-negative tests falsely green. Bookkeeping incomplete. Ordinal 37 is NOT accepted.

### Ordinal 38 — INTERRUPTED

Zero changes before actor/harness launch. No mutation occurred.

### Ordinal 39 — FAILED (direction anti-vacuity/stale records)

Ordinal 39 attempted anti-vacuity via `_FlatFromMap`-based compile-negative fixtures. Independent evidence proved `_ProofNoMissing = true` alone and `_ProofNoExtra = true` alone both leave compilation green — tests protected `_FlatFromMap`, not each direction individually. 506 full-candidate lines (325A+181D) exceeded 400 absolute max. Ordinal 39 is NOT accepted.

### Ordinal 40 — FAILED (unchanged)

No mutation occurred. Same candidate bytes as ordinal 39.

### Ordinal 41 — INTERRUPTED (zero-change/empty result)

Zero changes before actor/harness launch. No mutation occurred.

### Ordinal 42 — PENDING INDEPENDENT VALIDATION

**Objective**: direction-specific generic anti-vacuity proof. Both `_ProofNoMissing<M>` and `_ProofNoExtra<M>` are now parameterized generics exported from `model.ts`. Each compile-negative fixture imports and instantiates its exact production generic with a modified map type. Weakening either generic alone to unconditional `true` makes only its corresponding `@ts-expect-error` directive unused → TS2578.

**Production changes** (`functions/src/provisioning/model.ts`, 86 lines):
- `_ProofNoMissing<M>` — generic; `StatusPhasePair extends _FlatFromMap<M>` parameterized by map M
- `_ProofNoExtra<M>` — generic; `_FlatFromMap<M> extends StatusPhasePair` parameterized by map M
- Production assertions: `_Assert1 = RequireTrue<_ProofNoMissing<typeof _MAP>>`, `_Assert2 = RequireTrue<_ProofNoExtra<typeof _MAP>>`
- Removed intermediate `_Flat` type alias (no longer needed)

**Test changes** (`functions/test/provisioning/model.test.ts`, 84 lines):
- Compile-time proof: `_V1 = RequireTrue<_ProofNoMissing<_StatusPhaseMap>>`, `_V2 = RequireTrue<_ProofNoExtra<_StatusPhaseMap>>`
- Missing fixture: `_MissDetect = RequireTrue<_ProofNoMissing<_MissMap>>` — `@ts-expect-error` validated (pending omitted)
- Extra fixture: `_ExtDetect = RequireTrue<_ProofNoExtra<_ExtMap>>` — `@ts-expect-error` validated (extra auth_preflight in completed)

**Anti-vacuity**: If `_ProofNoMissing<M>` is weakened to always return `true`, only the missing-pair `@ts-expect-error` (line 56) becomes unused → TS2578. If `_ProofNoExtra<M>` is weakened to always return `true`, only the extra-pair `@ts-expect-error` (line 65) becomes unused → TS2578. Each direction is independently protected.

### Verification Results (ordinal 42)

| Command | Exit | Evidence |
|---------|------|----------|
| `node --version` | — | v24.11.1 |
| Full tsc 9 files (P1a1 + model) | 0 | 0 errors; @ts-expect-error validated |
| `node --experimental-strip-types test/provisioning/model.test.ts` | 0 | ALL PASSED |
| `npx tsc --noEmit` | 0 | source-only compat |
| P1a1 types | 0 | 36/36 |
| P1a1 normalize | 0 | 36/36 |
| P1a1 ids | 0 | 32/32 |
| P1a1 fixtures | 0 | integrity + immutability OK |
| `git diff --check` | 0 | clean |

### Ordinal-42 Correction Delta (FAILED — vacuous generic constraint)

**Defect**: `_ProofNoMissing<M extends Record<ProvisioningStatus,...>>` is vacuous. `_MissMap = Omit<_StatusPhaseMap, "pending">` does not satisfy the generic constraint, so the constraint itself consumes the `@ts-expect-error` directive. Weakening `_ProofNoMissing` to unconditional `true` produces NO TS2578.

**Native authority measured**: 164 changed lines above max 120. Independent textual comparison: 182 changed lines. Full candidate: 289 lines (86 model.ts + 84 model.test.ts + 92 apply-progress.md + 27 tasks.md). Maintainer selected preserved-candidate size exception.

### Ordinal 43 — Constraint Domain Correction (PENDING independent validation)

**Objective**: Relax the generic constraint on `_ProofNoMissing` and `_FlatFromMap` so a missing-key map is admissible as a type argument, making the proof body the sole error source.

**Production changes** (`functions/src/provisioning/model.ts`, 90 lines; +4 from ordinal 42):
- `_FlatFromMap<M extends Record<string, readonly ProvisioningPhase[]>>` — relaxed domain accepts maps with subset of ProvisioningStatus keys
- `_ProofNoMissing<M extends Record<string, readonly ProvisioningPhase[]>>` — relaxed so `_MissMap` is an admissible type argument
- `_ProofNoExtra<M extends Record<ProvisioningStatus, readonly ProvisioningPhase[]>>` — tight constraint preserved (extra-map always has full key set)
- JSDoc comments updated with accurate domain descriptions

**Test file** (`functions/test/provisioning/model.test.ts`): unchanged (84 lines). Fixtures already correct; only the production domain needed adjustment.

### Verification Results (ordinal 43)

| Command | Exit | Evidence |
|---------|------|----------|
| `node --version` | — | v24.11.1 |
| Full tsc 9 files (P1a1 + model) | 0 | 0 errors; @ts-expect-error validated |
| Source-only `npx tsc --noEmit` | 0 | source-only compat |
| `node --experimental-strip-types test/provisioning/model.test.ts` | 0 | ALL PASSED |
| P1a1 types | 0 | 36/36 |
| P1a1 normalize | 0 | 36/36 |
| P1a1 ids | 0 | 32/32 |
| P1a1 fixtures | 0 | integrity + immutability OK |
| `git diff --check` | 0 | clean |

### Anti-Vacuity Evidence (ordinal 43 — direction-specific weakening)

| Weakened | Expected | Result |
|----------|----------|--------|
| `_ProofNoMissing` → `true` | TS2578 at model.test.ts:56 (missing fixture only) | ✅ `error TS2578: Unused '@ts-expect-error' directive` at line 56 only |
| `_ProofNoExtra` → `true` | TS2578 at model.test.ts:65 (extra fixture only) | ✅ `error TS2578: Unused '@ts-expect-error' directive` at line 65 only |

Each weakening produces TS2578 ONLY on its corresponding `@ts-expect-error` directive. The other direction remains valid.

### Ordinal-43 Correction Delta (from begin tree a7017ff)

| Path | Lines changed |
|------|--------------|
| `functions/src/provisioning/model.ts` | +4 (87 → 91) |
| `functions/test/provisioning/model.test.ts` | 0 (unchanged) |
| `openspec/.../tasks.md` | bookkeeping (this section) |
| `openspec/.../apply-progress.md` | ordinal-43 entry (this section) |
| **Total correction (ordinal 43)** | **96** |

### Cumulative Status Update

| Work Unit | Status |
|-----------|--------|
| WU0–WU4a | Complete (prior evidence preserved) |
| P1a1 (ordinal 26) | Complete |
| P1a2-i-A-1a (ordinal 35) | FAILED — 3 findings |
| P1a2-i-A-1a (ordinal 36) | FAILED — 120-line STOP breach |
| P1a2-i-A-1a (ordinal 37) | FAILED — anti-vacuity/bookkeeping |
| P1a2-i-A-1a (ordinal 38) | INTERRUPTED — zero changes |
| P1a2-i-A-1a (ordinal 39) | FAILED — native 177, direction anti-vacuity/stale records |
| P1a2-i-A-1a (ordinal 40) | FAILED — unchanged for direction anti-vacuity/stale records |
| P1a2-i-A-1a (ordinal 41) | INTERRUPTED — zero-change/empty result |
| P1a2-i-A-1a (ordinal 42) | FAILED — vacuous generic constraint; 289-line candidate preserved |
| P1a2-i-A-1a (ordinal 43) | FAILED — native 96, crossed STOP80 but below max100, full candidate 335 |
| P1a2-i-A-1a (ordinal 44) | CANCELLED — maintainer requested P1a2-i segmentation, P1a2-i-A-1a accepted |
| P1a2-i-A-1a (ordinal 45) | ACCEPTED — P1a2-i-A-1a baseline frozen (tree `a7017ff`) |
| P1a2-i-A-1b (ordinal 46) | COMPLETE — deepFreeze implementation, strict TDD, 222 authored lines |
| P1a2-i-A-1c through WU10 | Pending |

---

## P1a2-i-A-1b — Descriptor-Safe Cycle-Safe Deep Freeze (ordinal 46)

**Status**: COMPLETE. Strict TDD. 222 authored lines (62 model.ts + 160 model.test.ts). Within 200-270 forecast; below 300 warning.

### TDD Cycle Evidence (Strict TDD)

| Task | Test File | Layer | Safety Net | RED | GREEN | TRIANGULATE | REFACTOR |
|------|-----------|-------|------------|-----|-------|-------------|----------|
| A-1b.0 | `model.test.ts` | Unit | N/A (new extension) | ✅ ENTRY: `grep deepFreeze` → 0 matches; confirmed absent | — | — | — |
| A-1b.1 | `model.test.ts` | Unit | ✅ A-1a 73 assertions pass baseline | ✅ TS2305: no exported member `deepFreeze` | — | N/A (9 probes cover all spec requirements) | — |
| A-1b.2 | — | — | — | ✅ recount: 222-line forecast; within 200-270 | — | — | — |
| A-1b.3 | `model.ts` + `model.test.ts` | Unit | A-1a green | — | ✅ All 9 probe groups pass + all A-1a assertions preserved | ✅ 9 probe groups: basic data, array ops, deep nesting, pre-frozen parent, symbol keys, non-enumerable, throwing getter, cycle, children-before-parent | — |
| A-1b.4 | `model.ts` | Unit | All green | — | — | — | ✅ `Object.getOwnPropertyDescriptors()` (plural); single WeakSet; removed eslint-disable comments; no `every()` redundancy |

### RED Evidence (A-1b.1)

```
npx tsc --noEmit → TS2305: Module '"../../src/provisioning/model.ts"' has no exported member 'deepFreeze'
```
`grep deepFreeze functions/` → 0 matches (confirmed absent before GREEN).

### GREEN Evidence (A-1b.3)

```
=== P1a2-i-A-1a vocabulary + type proof ===
ALL PASSED
=== P1a2-i-A-1b deepFreeze probes ===
ALL PASSED
```

### Adversarial Freeze Probes Implemented

| # | Probe | Evidence |
|---|-------|----------|
| 1 | String-keyed own data property freeze | Same ref, top + nested frozen, mutation rejected, delete rejected |
| 2 | Array push/index-assign/delete rejected | Array frozen, push throws, index-set throws or preserved, delete blocked |
| 3 | Deep nesting — every level frozen | l1→l4 all `Object.isFrozen`; `findUnfrozen` returns null |
| 4 | Pre-frozen parent with unfrozen children | Parent pre-frozen confirmed; after deepFreeze, child NOW frozen, mutation rejected |
| 5 | Symbol-keyed properties | Symbol keys enumerated and frozen; symbol-keyed mutation rejected |
| 6 | Non-enumerable own data properties | `Object.defineProperty` hidden property; post-freeze descriptor shows `writable:false, configurable:false` |
| 7 | Throwing getter does NOT abort traversal | `getterInvoked === false`; `safe` property frozen; `boom` accessor preserved |
| 8 | Circular reference (cycle-safe) | Same ref returned; self-ref intact; `Object.isFrozen` true |
| 9 | Children frozen before parent | Parent + child both frozen confirms traversal order |

### Verification Results (ordinal 46)

| Command | Exit | Evidence |
|---------|------|----------|
| `node --version` | — | v24.11.1 |
| Explicit A-1a+A-1b tsc (types.ts + model.ts + model.test.ts) | 0 | 0 errors |
| Source-only `npx tsc --noEmit` | 0 | clean |
| `node --experimental-strip-types test/provisioning/model.test.ts` | 0 | ALL PASSED (A-1a + A-1b) |
| P1a1 types `test/provisioning/types.test.ts` | 0 | 36/36 pass |
| P1a1 normalize `test/provisioning/normalize.test.ts` | 0 | 36/36 pass |
| P1a1 ids `test/provisioning/ids.test.ts` | 0 | 32/32 pass |
| `git diff --check` | 0 | clean (only pre-existing CRLF warning on tasks.md) |
| Protected paths diff (`.atl/*`, `app_colors.dart`) | 0 | no changes |

### Production Code

| File | Action | Lines | Purpose |
|------|--------|-------|---------|
| `functions/src/provisioning/model.ts` | Extended | +62 (90→152) | `deepFreeze<T>`: descriptor-based traversal via `Object.getOwnPropertyDescriptors()` + `Reflect.ownKeys()`; cycle-safe via `WeakSet`; children frozen before parent; pre-frozen parent traversal preserved |
| `functions/test/provisioning/model.test.ts` | Extended | +160 (84→244) | 9 adversarial freeze probes: array ops, deep nesting, pre-frozen parent, symbols, non-enumerable, throwing getter, cycles, children-before-parent, basic data |

### Work Unit Evidence

| Evidence | Required value |
|---|---|
| Focused test command and exact result | `node --experimental-strip-types test/provisioning/model.test.ts` → ALL PASSED (A-1a 73 assertions + A-1b 9 probe groups) |
| Runtime harness | `npx tsc --noEmit --module NodeNext ...` → 0 errors; `npx tsc --noEmit` → 0 errors |
| Rollback boundary | Revert `functions/src/provisioning/model.ts` to 90-line A-1a state (remove lines 91–152); revert `functions/test/provisioning/model.test.ts` to 84-line A-1a state (remove lines 85–244); revert tasks.md and apply-progress.md to pre-A-1b state |

### Line Count

| Component | Lines | Budget |
|---|---|---:|
| `model.ts` deepFreeze | 62 | 60–80 |
| `model.test.ts` probes | 160 | 120–160 |
| `tasks.md` + `apply-progress.md` | ~30 (this entry) | 20–30 |
| **Total** | **~222 + doc** | **200–270** |

### Cumulative Status Update

| Work Unit | Status |
|-----------|--------|
| WU0–WU4a | Complete (prior evidence preserved) |
| P1a1 (ordinal 26) | Complete |
| P1a2-i-A-1a (ordinal 45) | ACCEPTED — baseline frozen (tree `a7017ff`) |
| P1a2-i-A-1b (ordinal 46) | COMPLETE — deepFreeze, 222 authored lines, strict TDD |
| P1a2-i-A-1c through WU10 | Pending |

## Ordinal 50 reconciliation
- Ordinal 46 FAILED at 333 native lines: reverse discovery failed shared-DAG postorder.
- Ordinal 47 INTERRUPTED after 40 lines with no trustworthy returned tests; current code/test appears to fix the DAG but is unaccepted pending fresh validation.
- Ordinals 48 and 49 INTERRUPTED at 0 lines (executor cancellation and provider quota).
- Pre-reconciliation combined A-1b: 355/400; after this 18-line correction, Git-native recomputation is 353/400.
- DAG edges are child-before-parent; cycles are cycle-safe because strict order for every cyclic edge is impossible.
- A-1b is not GREEN, COMPLETE, accepted, or tested; prior completion/test claims are superseded. No tests ran for ordinal 50.

## Native Ordinal 51 — A-1b Final Acceptance
- Native ordinal 51 PASS; unchanged candidate tree `ef9cc3b651f987694d61ae893655165427bb64e5`; evidence revision `sha256:f92338f36186d4446837dcbc3439eedd1189deb72040bab77d2f32dd2155fb2b`.
- Scope: 353/400 before acceptance-record adjustment; zero validation changes.
- Checks: focused/full TypeScript PASS; model ALL PASSED; P1a1 36/36 + 36/36 + 32/32; fixtures/integrity PASS; descriptor/getter/cycle/shared-DAG semantics PASS.
- A-1b accepted; A-1c remains pending and MUST NOT start.

---

## P1a2-i-A-1c — Strict State Guard (native ordinal 53)

**Status**: implementation complete under Strict TDD; pending fresh independent A-1c phase-contract validation. The independent acceptance checklist remains unchecked.

### Scope

- Added `isStatus`, `isPhase`, and `isValidState` only in `model.ts`.
- State validation requires a plain root and plain normalized payload, the exact root field set, finite numeric fields, non-null `operationId`/`fingerprint`, valid frozen status/phase vocabulary and pair, and no symbol-keyed extras.
- No constructor, event guard, transition, CAS, A-1d work, staging, commit, push, PR, deploy, or protected-path mutation occurred.

### TDD Cycle Evidence (Strict TDD)

| Task | Test File | Layer | Safety Net | RED | GREEN | TRIANGULATE | REFACTOR |
|------|-----------|-------|------------|-----|-------|-------------|----------|
| A-1c.0 | `model.test.ts` | Unit | `node --experimental-strip-types test/provisioning/model.test.ts` → exit 0, A-1a/A-1b preserved | ENTRY complete | — | — | — |
| A-1c.1 | `model.test.ts` | Unit | A-1a/A-1b runtime green | Exact explicit TypeScript command → TS2305 for missing `isPhase`, `isStatus`, `isValidState` | — | 10 state-guard cases written | — |
| A-1c.2 | — | — | — | Baseline-to-worktree blob-aware recount: 42 lines after RED | — | — | — |
| A-1c.3 | `model.ts`, `model.test.ts` | Unit | A-1a/A-1b green | — | Explicit TypeScript command, source-only TypeScript, and model runtime all exit 0 | Valid state plus null identifiers, NaN, pair, class/prototype/payload, missing/string/symbol-extra cases | — |
| A-1c.4 | `model.ts` | Unit | All green | — | Type-level GREEN exit 0 | — | No further refactor needed; helpers keep validation descriptor-free and side-effect-free |
| A-1c-R.1-.2 | `model.test.ts`, `model.ts` | Unit | model harness baseline passed | RED: 9/20 boundary mismatches | GREEN: 20/20 | owner/nullability + UID 128/129 | whitespace-only compaction |

### RED Evidence

```
TS2305: no exported member 'isPhase'
TS2305: no exported member 'isStatus'
TS2305: no exported member 'isValidState'
```

### Work Unit Evidence

| Evidence | Required value |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` → exit 0; A-1a/A-1b runtime output preserved and every A-1c assertion completed without throwing. |
| Runtime harness command/scenario and exact result | Same Node strip-types harness exercises exported guards with valid and adversarial in-memory states → exit 0. |
| Rollback boundary | Revert only `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, and the two SDD records to baseline tree `ba061e5438d59c7494fc198ccb530eed7f15b0c5`; A-1a/A-1b behavior remains intact. |

**Candidate count**: 167 authored changed lines (161 additions + 6 deletions) by baseline-tree blob comparison; below the 300-line warning and 350-line STOP.

---

## A-1c bounded remediation — ordinal 53 FAIL / ordinal 54 candidate

- Ordinal 53 FAILED fresh independent validation: 22/135 adversarial assertions failed; evidence `sha256:fd128f77c161abc45a01ecd4de4b72e586fa2d6efeddfe47c532163aac4c01a8`.
- Ordinal 54 starts at tree `629a3fd11a5a538c38480ea0d68e9986a11100fb`; correction max 183 and final A-1c total remains below 350. No acceptance is claimed.
- Blob-aware recount after record updates: correction 148/183; final A-1c 261/350.

| TDD | Evidence |
|---|---|
| RED | New focused matrix failed against prior production: 22/22 invalid states accepted. |
| GREEN | Model harness and explicit/source-only TypeScript pass after strict recursive validation. |
| Scope | Only model, model test, tasks, and this progress record; no A-1d or forbidden action. |

```json
{"schema":"gentle-ai.remediation-result/v1","ordinal":54,"lineage_id":"sha256:66d1ad55af20282bfcd3a1213b0ae9ec46d1e6b6de141f1234bb1ee00c95723e","generation":53,"fix_batch":"P1a2-i-A-1c-bounded-contract-remediation","failed_evidence_revision":"sha256:fd128f77c161abc45a01ecd4de4b72e586fa2d6efeddfe47c532163aac4c01a8","state":"implemented-awaiting-independent-validation"}
```
```json
{"schema":"gentle-ai.remediation-evidence/v1","red":"node strip-types: 22/22 accepted invalid states","green":"model harness + explicit/source-only tsc exit 0","begin_tree":"629a3fd11a5a538c38480ea0d68e9986a11100fb","scope":"four authorized paths only"}
```

## Native Ordinal 55 — A-1c-R recovery
- Ordinal 53 failed; ordinal 54 failed (true correction `192/183`); pre-recovery final was `333/350` after planning.
- RED: 9/20 owner-token/UID boundaries mismatched; GREEN: 20/20 after canonical SHA-256 reuse, UID bounds, and lifecycle guard; final `334/350`, correction `<=67`.
- Independent acceptance remains unchecked; no 379-matrix claim.

---

## Ordinals 60–61 — Fractional Timestamp Integer Correction
- Ordinal 60 FAILED: `isTimestamp()` accepted `0.5` in all six timestamp fields; evidence `sha256:021a5ea4c83ac511b90e87d6547657af3a8c8ac19f8ce7edabb12ba1d178f815`.
- Strict TDD: safety model harness passed; RED exit 1 reported `6/6` accepted fields; GREEN added shared `Number.isInteger` enforcement and the same harness exited 0 (all six rejected); no refactor.
- Work-unit evidence: focused/runtime boundary is the Node strip-types model harness; rollback is the shared predicate, six-case test, and these records; no independent A-1c acceptance.
- Measured after records: ordinal-61 correction `+17/-1` (18); endpoint `+341/-9` (350/350).

## Native Ordinal 65 — A-1c Formal Acceptance
- Accepted candidate tree `8bbf37438a41379a6214482a9571051d55a050a6`; evidence `sha256:0113ec2afd80162e4ef0b6524ae16843626b053cf870a0ce4addcea0aa53f738`.
- Ordinal 64 PASS: fresh semantic matrix 405/405; all six fractional timestamp checks passed; exact four-path endpoint 350/350.
- Validation made zero repository changes; the ephemeral external harness was deleted; A-1d remains pending and untouched.

---

## Native Ordinal 66 — P1a2-i-A-1d Strict Event Guard

**Status**: implementation complete under Strict TDD; independent acceptance checklist remains unchecked.

### TDD Cycle Evidence (Strict TDD)

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| A-1d.0–.4 | `functions/test/provisioning/model.test.ts` | Unit | Existing model harness exit 0 | Missing `isEventType` export: Node ESM `SyntaxError`; exit 1 | Focused model harness exit 0 | 12 independent literal event shapes; missing/extra payload fields for each; finite/non-plain/symbol adversaries | No further refactor needed; explicit/source-only TypeScript exit 0 |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused/runtime harness | `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` → exit 0 |
| Type checks | Explicit P1a1+model `npx tsc --noEmit ...` → exit 0; source-only `npx tsc --noEmit` → exit 0 |
| Inherited proof | P1a1 types 36/36, normalize 36/36, IDs 32/32; fixtures integrity and recursive immutability → exit 0 |
| Rollback boundary | Revert only `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, and these two SDD records to begin tree `0de44ff33b943bc81e3037546b3c144249a34c7c`. |

### Scope

- Added only `isEventType` and `isValidEvent` with exact root/payload guards; no constructors, state-guard changes, transitions, or CAS.
- A-1d.0 through A-1d.4 are locally evidenced complete. Lines 717–728 remain unchecked for independent validation.

---

## Native Ordinal 69 — A-1d Descriptor/Proxy Fail-Closed Correction

**Status**: implemented under strict TDD; independent A-1d acceptance remains unchecked.

| TDD | Evidence |
|---|---|
| Safety net | Existing model harness exited 0 before the RED mutation. |
| RED | `node --experimental-strip-types test/provisioning/model.test.ts` exited 1: `15/15` root/payload/proof accessor and proxy cases failed. |
| GREEN | The same harness exited 0: `15/15` descriptor/proxy cases fail closed; explicit and source-only TypeScript also exited 0. |
| Refactor | Event-only `readPlainOwnDataFields` safely performs prototype, key, and own-descriptor reflection; accessor descriptors and reflection exceptions return `false`. |

- `isValidEvent` now reads exact root/payload/proof own data descriptors without executing accessors. Reflection/proxy exceptions are contained and reject the event; existing state-guard behavior is untouched.
- The structural contract is deliberate: `acquire`/`takeover` and `auth_no_effect`/`auth_ambiguous` payloads have no internal provenance and remain valid by matching schema. No discriminant was added.
- Scope remains only the four authorized paths; no constructor, transition, reducer/CAS, P1a1, A-2, delivery, staging, branch, commit, or protected-path change occurred. This is local correction evidence, not independent acceptance.

## Ordinal 74 — A-1d Acceptance Record
- Validator ordinal 73 accepted tree `28498fb2de16a46b685e92dbe0c56aa84d019dc6`, identity `sha256:1713fb9e87d8fbe89f84a4144ba1290ddd5265b28cff29909d73b6b049d3b52a`, evidence `sha256:8977042fc24ad675d122cfac43de4d86d535cc7a47c655068489d25b7414976b`.
- Oracle 148/148; event types 12/12; descriptor/proxy 15/15; P1a1 36/36 + 36/36 + 32/32; TypeScript, model harness, fixtures/recursive immutability, diff/isolation passed. Accepted scope 189/350: model 60, model.test 75 (+74/-1), tasks 11 (+6/-5), apply-progress 43.

---

## P1a2-i-A-2 — Validated Constructors + TypeScript Compatibility

**Status**: Strict-TDD implementation complete; independent acceptance remains pending.

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| A-2.0–A-2.7 | `functions/test/provisioning/model.test.ts` | Unit | Model harness and explicit TypeScript passed before RED | Native strip-types exited 1: one ESM import failure, `createEvent` not exported; all four constructor probes were authored first | Native strip-types, explicit noEmit, and source-only noEmit exit 0 | 60 constructor assertions: initial 11, event 41, success 4, failure 4 | No further refactor needed; GREEN re-run passed |

The RED probes cover valid frozen outputs and malformed initial-state fields, all 12 event payload shapes plus unknown/missing/extra/proxy/nested-proof invalid inputs, invalid success states, and empty/non-string failure reasons. `createFailureResult(" ")` is explicitly expected to succeed because the existing non-empty-string predicate accepts any string with length greater than zero.

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused/runtime harness | `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` → exit 0; 60 constructor assertions passed alongside inherited model probes. |
| Type compatibility | Explicit P1a1+A-1+A-2 `npx tsc --noEmit ...` and source-only `tsc --noEmit -p functions/tsconfig.json` → exit 0. |
| Rollback boundary | Revert only `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, and these two SDD records to tree `32496a55943fe0f12f06e6ff01130d42876af1cd`; A-1d remains intact. |
## Native Ordinal 76 — A-2 Acceptance Record
- Accepted unchanged candidate tree `127f8413d6273c297b09f5758fa377a3c66488ed`; evidence revision `sha256:14856ce37f3cac0542a30ed7868f579d0faefef6d291a7aea7ed6b07e22ce2a0`.
- Constructors: 60/60 (11 initial, 41 event, 4 success, 4 failure); inherited controls: 36/36 + 36/36 + 32/32.
- Explicit/full TypeScript, fixtures, model harness, and diff checks passed; exact four-path scope: 127/250.
- Validation changed zero repository lines, preserved HEAD/index/path blobs/modes, and removed the ephemeral harness; P1a2-i-B remains unstarted.

---

## P1a2-i-B-1 — Blocked Before RED

**Local status**: entry and inherited model-harness safety net passed; no B-1 test or production mutation was made. **Independent acceptance remains unchecked.**

### Evidence

| Item | Result |
|---|---|
| Entry | `node --version` → `v24.11.1` (meets Node >=22.6.0) |
| Safety net | `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` → exit 0; frozen A baseline passed |
| RED | Not authored: the frozen `reduce(state, event)` input contract cannot carry an expected full CAS tuple. |
| GREEN / refactor | Not run; no fake or partial CAS implementation was added. |

### Blocking diagnosis

`OperationState` supplies only one state and `ModelEvent` is constrained by the frozen A-1d exact event guard to `{eventId,type,payload}` with type-specific payloads. None of those payloads contains the required expected `fingerprint,status,phase,generation,version,ownerToken,currentDispatchId,leaseExpiresAt` tuple. Therefore `reduce(state,event)` has no independent live tuple against which to compare a stale tuple. Adding such fields changes frozen vocabulary/guards/constructors; adding another public input/helper violates B-1. A fabricated comparison would not prove full CAS.

### Required planning decision

Define an allowed, guardable expected-CAS carrier while preserving the intended public reducer surface, or explicitly revise the frozen A contract. Until then, B-1.1–B-1.5 remain unchecked and no boundary/terminalization behavior is implemented.

---

## P1a2-i-B-1a — Local TDD Attempt (blocked)

- RED: the new request-surface tests failed before source because `reduce` was not exported (Node strip-types exit 1).
- Runtime GREEN: descriptor-safe request/ExpectedCAS validation and the reducer surface pass the model harness (exit 0); no CAS, lease, dispatch, terminal, or transition behavior was added.
- Required explicit source+test and source-only `npx tsc --noEmit` both exit 1 because this clean worktree has no TypeScript compiler installed. No install or fallback was used.
- At this blocked attempt, B-1a checkboxes and independent acceptance remained unchecked; the source/test delta before this record was 102 changed lines.
## Native Ordinal 82 — B-1a Acceptance Record
- Independently accepted unchanged B-1a: candidate/evidence diff `sha256:986fa44d1e30b7725699544e0447c797347a049090c03902b6a62e039ee9557e`; 105/105 adversarial assertions; explicit/source-only TypeScript, model harness, inherited 36/36 + 36/36 + 32/32, fixtures, and diff checks PASS; exact scope 111 lines across `model.ts`, `model.test.ts`, and `apply-progress.md`; zero validation mutation, temporary harness deleted, source/test bytes and modes preserved, B-1b/later behavior absent.

## P1a2-i-B-1b — Blocked at Entry
- Node v24.11.1 and the inherited B-1a/A model harness passed before mutation.
- The required explicit TypeScript command cannot run: `npm ls typescript --depth=0` reports an empty dependency tree, `npx tsc` reports no compiler installed, and no global `tsc` exists.
- No B-1b RED test or production mutation was made; B-1b.1–.5 and all independent acceptance items remain unchecked.

## P1a2-i-B-1b — Strict-TDD Continuation
- Maintainer-authorized dependency recovery supplied Functions-local TypeScript 5.9.3 without tracked changes.
- RED: test-only vectors failed with `cas_mismatch` and `unsupported_event` missing from the B-1a reducer.
- GREEN: module-private eight-field CAS comparison, active-lease liveness, and `unsupported_event` dispatch passed; no transition or terminal policy was added.

| Task | RED | GREEN | REFACTOR |
|---|---|---|---|
| B-1b.1–.5 | 8 CAS, 2 lease, 14 dispatch vectors failed before production | Model/runtime, explicit TypeScript, source-only TypeScript, inherited fixtures all passed | No further refactor needed |

| Evidence | Result |
|---|---|
| Focused/runtime harness | `node --experimental-strip-types test/provisioning/model.test.ts` → exit 0; 70 B-1b assertions exercised. |
| Type checks | Explicit source+test `npx tsc --noEmit ...` and source-only `npx tsc --noEmit` → exit 0. |
| Rollback boundary | Revert B-1b changes in `model.ts`, `model.test.ts`, and these two SDD records only. |

- B-1b.0–.5 are locally proved. Independent acceptance remains unchecked. Native authority was not called.
- Bounded evidence revision: `sha256:6538f7c4b269de9ee9ffb0c6558349e5698a3c1ec0ed42e6289e7d4b75e34a7c`.

## Native Ordinal 88 — B-1b Acceptance Record
- PASS; evidence `sha256:817fb6dac5ebaa9e3d05e9d24974a01c097f50bb30b64a37f59bb462e9d9ddb3`; independent oracle 74/74.
- All eight CAS fields, including owner fencing, precede lease liveness and dispatch; exact live/inactive tuples return `unsupported_event`; stale/dead-lease precedence and fail-closed ordering pass. No B-2/B-3 behavior exists.
- Explicit/source-only TypeScript, model, inherited 36/36 + 36/36 + 32/32, fixtures, and diff check PASS; pre-acceptance candidate is 67 additions + 9 deletions = 76 lines (<120/<170/<200).
- Validation made zero repository mutation; temporary files/processes were removed; source/test blobs and modes were preserved.

## P1a2-i-B-2 — Terminal Rejection + Non-Mutation

**Status**: Formal independent acceptance recorded; B-1b acceptance retained; B-3 is retired/superseded historical-only (never implemented or accepted).
- TDD RED: `node --experimental-strip-types test/provisioning/model.test.ts` exited 1 with 36/36 genuine failures: 33 `unsupported_event`, 3 stale ExpectedCAS `cas_mismatch`; GREEN: the same harness exited 0 after terminal policy insertion; no refactor was needed.
- Inherited controls remained green: malformed request/ExpectedCAS/event returned `invalid_request`/`invalid_expected`/`invalid_event`; 3 exact terminal acknowledgements returned pre-B-3 `unsupported_event`.
- All 42 controls prove canonical snapshots, direct/deep state/request/event references, unchanged version/generation, and no returned graph retention; terminal policy follows event validation and precedes CAS/lease, excluding `ack_dispatch`.
- Verification passed: model harness, explicit source+test TypeScript, source-only TypeScript, types 36/36, normalize 36/36, IDs 32/32, and fixture integrity/recursive immutability. `npm ci --ignore-scripts` restored existing local dependencies without tracked changes (audit: 9 moderate vulnerabilities).
- Work unit evidence: focused/runtime harness is the pure Node strip-types command; rollback reverts only B-2 policy/test additions and these two SDD records. No B-3 acknowledgement/data semantics, P1a2-ii transitions, success result, version increment, generation change, native authority action, staging, commit, PR, or deployment occurred.

## Native B-2 Acceptance Record
- PASS / READY_TO_RECORD; evidence `sha256:850a08c45c85d37db0c2b86ecfc5fe73ef13ad166ea6b4630d99a886d3111213`; bookkeeping-only evidence `sha256:262c296bd4a87046e04619c29c685b1d2c1b15eb8c99fd94d628319fa1bb59f8` remediated by native settlement (complete). B-2 accepted; B-3 is retired/superseded historical-only and has no aggregate gate. 42/42: 33 terminal + 3 mixed-invalid + 3 stale-CAS + 3 terminal-ack; TypeScript and inherited types/normalize/IDs/fixtures passed; validation caused zero mutation; candidate scope 173/200 (warning 155 exceeded; STOP 180 and max 200 respected).

---

## P1a2-i-C — AuthAttempt Lifecycle Guard Refinement

**Status**: P1a2-i-C is independently accepted; P1a2-ii was subsequently independently accepted at ordinal 105.

### TDD Cycle Evidence (Strict TDD)

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| C.0–C.6 | `functions/test/provisioning/model.test.ts` | Unit | Node model harness passed before test mutation | Focused Node harness exited 1: first literal finite-complement row expected `invalid_state` and reached a later gate | Focused Node harness, explicit source+test TypeScript, and source-only TypeScript exited 0 | Literal 7-row oracle × `Ø/I/C/D/K/A` (42 rows), nullability/flag/correlation families, and B-2 fixture reconstruction | No further refactor needed; inherited harnesses re-green |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command | `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` → exit 0; inherited model probes, 42 B-2 controls, and C literal lifecycle oracle pass. |
| Runtime harness | Same Node strip-types pure reducer path; invalid lifecycle states return `invalid_state` before request/event/terminal/CAS/lease/dispatch and retain snapshots, references, version, and generation. |
| Rollback boundary | Revert only C changes in `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, and these C task/progress records; accepted B-2 remains intact. |

- GREEN changes are confined to `isAuthAttempt` and `isValidState`. No field, type, event, result, reason, persistence/effect behavior, CAS/lease/dispatch behavior, or P1a2-ii transition was added.
- B-2 fixtures were canonicalized: completed/terminal uses `K`, failed/terminal retains `Ø`, and manual_recovery/terminal uses `A`; all 42 accepted outcomes remain unchanged.

## Native Ordinal 99 — C Acceptance Record
- PASS; evidence `sha256:0cdf8a3521ce79395b2b622c367eb6948a0a3567c013edd0107afeaa288d990f`; accepted tree `2cd10c154ecd4ccc8a404ffb088fc8bc66aecaac`; four admitted files, 180 additions + 16 deletions = 196 total churn; oracle 122/122 (7 valid lifecycle, 28 invalid-complement, 5 active takeover, 33 malformed/hostile/lifecycle-negative, 42 B-2 controls); focused model harness, explicit source+test/source-only TypeScript, inherited P1a1 36/36 + 36/36 + 32/32, fixture integrity/recursive immutability, and `git diff --check` passed; task/progress mirrors are byte-equal, verification made zero repository mutation, and P1a2-ii was subsequently independently accepted at ordinal 105.

---

## P1b — Persistence Ports + Conformance

**Status**: independently accepted; native objective complete. Fresh independent evidence `sha256:7b0340540a81cf6034bdea8d5e30cc536ad55432932016a7b4db26e1d89e41b5` remediates the prior failed evidence; P1b acceptance is recorded and later slices remain pending.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P1b.0–P1b.10 | `store_conformance.test.ts`, `memory_store.test.ts`, `firestore_store.test.ts`, `cas.test.ts` | Unit + Firestore emulator | Accepted candidate: store conformance 2/2, memory 1/1, emulator 4/4, source-only TypeScript, and diff check passed | Accepted in the prior candidate | Accepted in the prior candidate | Frozen P1a matrix runs against memory and Firestore with byte-equal outcomes | Preserved without rebuilding accepted files |
| P1b.11–P1b.12 | `functions/test/provisioning/cas.test.ts` | Firestore emulator integration | Existing CAS unit probe 1/1 and Firestore store harness 4/4 passed before mutation | Emulator command exited 1 because `applyCASMutation` was not exported | Emulator command exited 0: 2/2 tests; all eight stale tuple fields, expired lease, invalid takeover generation, and exact live mutation have byte-equal memory/Firestore outcomes | Eight independent tuple mutations plus lease, generation, and exact-live branches | Added the smallest guarded mutation primitive; it owns no terminalization, dispatch, or retry policy |
| P1b.13–P1b.14 | `functions/test/provisioning/cas.test.ts` | Firestore emulator integration | P1b.11–P1b.12 2/2 green | Emulator command exited 1 because the store port had no explicit abort boundary | Emulator command exited 0: 3/3 tests; abort leaves no write, retry applies once, and stale re-entry returns `cas_mismatch` in both stores | Abort, retry, and re-entry compare byte-equal outcome vectors across both stores | Added `StoreTransaction.abort()` and aligned both adapters; no application retry policy was introduced |
| P1b.15 | all P1b files | Source type check + focused runtime | P1b focused suites green | N/A — refactor-only freeze after green behavior | `npx tsc --noEmit` exit 0; focused store and memory suites re-green | N/A — behavior was already triangulated above | Added the abort implementation to the typed conformance fake and re-ran focused checks |

### RED Evidence

1. `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/cas.test.ts"` with process-scoped `JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.12.8-hotspot` exited 1 before P1b.12: `cas.ts` did not provide `applyCASMutation`.
2. The same emulator command exited 1 before P1b.14: `store.ts` did not provide the explicit transaction-abort contract used by the crash-point schedule.

### GREEN and Final Verification

- Node v24.11.1 was checked before every focused test/emulator invocation; Temurin 21.0.12 was used only through process-scoped `JAVA_HOME` for emulator commands.
- `cd functions && node --experimental-strip-types test/provisioning/store_conformance.test.ts` → exit 0, 2/2 tests.
- `cd functions && node --experimental-strip-types test/provisioning/memory_store.test.ts` → exit 0, 1/1 test.
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/firestore_store.test.ts"` → exit 0, 4/4 tests.
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/cas.test.ts"` → exit 0, 3/3 tests.
- `cd functions && npx tsc --noEmit` → exit 0.
- `git diff --check` → exit 0.

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | The four commands above passed with 2/2, 1/1, 4/4, and 3/3 tests respectively. |
| Runtime harness command/scenario and exact result | The two Firestore emulator commands used real `firebase-admin` transactions with Temurin 21; frozen-vector parity, real stale/live CAS mutation, abort rollback, retry, and stale re-entry passed. |
| Rollback boundary | Revert only `functions/src/provisioning/{store,memory_store,firestore_store,cas}.ts`, delete the four corresponding P1b test files, and revert these P1b task/progress records. No P1a behavior, emulator configuration, callable, dispatch, worker, audit, profile, or terminalization behavior is included. |

### Scope and Accounting

- Eight authorized P1b source/test files contain 459 authored additions and zero deletions. The accepted starting candidate was 297 lines; this continuation adds 162 lines. The P1b total is 459/2,000, leaving 1,541 lines and remaining below the 1,700 STOP threshold and 2,000 hard maximum.
- No files outside the P1b allowlist were changed by this continuation except the required `tasks.md` checkboxes and this cumulative `apply-progress.md` record. `.atl/.skill-registry.cache.json` was preserved untouched.
- No commit, staging, push, PR, install, delivery, native attempt settlement, or final acceptance was performed.

### Fresh Evidence Revision

- `sha256:34c94204716c0d9e18f0b3b889a9f10a81b7eb592a1f747534e53a1a2889bf0f`, computed from the ordered `path SHA-256` manifest of all eight authorized P1b source/test files after the final green commands. It is fresh evidence intended to remediate failed evidence `sha256:efca20e15fef518323aa724d72b96c63f96228485fb5d692798f0c9205f5055f`.

## Native P1b Acceptance Record

- Fresh independent PASS: `sha256:7b0340540a81cf6034bdea8d5e30cc536ad55432932016a7b4db26e1d89e41b5`; remediation evidence: `sha256:b7cbed7aef8db580233bbc394d89026cd80329d0020591690f9c7b2865fffa62`; original failed evidence: `sha256:701e1e83f97c2a9580bf03bd2c546bc9cb49b2154c65868cfb24aa54c2f24ac8`.
- 12/12 native controls passed: Store 4/4, memory 1/1, Firestore 7/7, CAS 4/4, and TypeScript 2/2; all five evaluator inputs passed.
- OpenSpec/Engram parity reconstructed exactly; cleanup and zero-mutation checks passed; scope was 742/800; native objective is complete. P2 and later slices remain pending.

## P2-atomic-submission — P2.15–P2.16

**Status**: implemented under Strict TDD. The submission persistence boundary atomically creates only a canonical pending operation and its deterministic initial `acquire` dispatch; it performs no Auth or profile operation.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.15–P2.16 | `functions/test/provisioning/submit.test.ts` | Unit | Existing schema validation → 7 assertions pass | Test-first import failed with `SyntaxError`: missing `persistInitialSubmission` export | Same command → exit 0, 16 assertions | Success proves canonical operation/dispatch identity and response; dispatch-write failure proves no partial operation survives | Fixed the test transaction callback's `void` return typing; focused test and TypeScript re-green |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/submit.test.ts` → exit 0, 16 assertions. |
| Runtime harness command/scenario and exact result | Commit-on-success in-memory transaction port: operation then dispatch commits together; injected dispatch failure exits rejected with zero committed writes. Firebase emulator is N/A because this bounded domain-port contract has no Firebase adapter in this slice. |
| Regression | Schemas 41 assertions, audit 46 assertions, authorization 14 assertions, export metadata 4 assertions, MemoryStore 1/1, Store conformance 4/4, and focused CAS 2/2 all pass. |
| TypeScript | Explicit `submit.ts` + `submit.test.ts` check and configured `cd functions && npx tsc --noEmit` exit 0. |
| Rollback boundary | Revert only `functions/src/provisioning/submit.ts`, `functions/test/provisioning/submit.test.ts`, these two checkboxes, and this record. |

- `git diff --check` passed. P2.17+ remains unchecked and pending.
- **Implementation evidence revision**: `sha256:ffacad0875759616cf0532ffeb79f69593781718b9e3540da6b81a3c54f80062`, from the UTF-8 newline-terminated ordered `path SHA-256` manifest of `submit.ts` and `submit.test.ts` after GREEN.

## P2-idempotent-submission-replay — P2.17–P2.18

**Status**: implemented under Strict TDD. Submission reuses the existing operation lookup inside the same transaction: a matching `(operationId, fingerprint)` returns only its current status, while a mismatched fingerprint fails with `already-exists` before any write.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.17–P2.18 | `functions/test/provisioning/submit.test.ts` | Unit / transaction port | Existing submission harness → 16 assertions pass | Same replay harness → exit 1, `duplicate operation write` on the second matching submission | Same harness → exit 0, 25 assertions | Matching replay returns `active`; changed payload/fingerprint returns `already-exists`; both prove one operation/dispatch and zero audit/Auth/profile effects | None needed; the minimal transaction lookup is clear |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/submit.test.ts` → exit 0, 25 assertions. |
| Runtime harness command/scenario and exact result | Same transaction-port harness replays an existing operation and a mismatched payload/fingerprint; duplicate operation/dispatch writes throw in the fake, while write counters prove no audit/Auth/profile effects. Exit 0, 25 assertions. Firebase emulator is N/A: replay is fully proven at the accepted transaction-port boundary. |
| Regression | Schemas 41 assertions, audit 46 assertions, authorization 14 assertions, export metadata 4 assertions, MemoryStore 1/1, and Store conformance 4/4 all pass. Focused in-memory CAS rows pass 2/2; a full CAS invocation has two emulator-required failures because `FIRESTORE_EMULATOR_HOST` is absent, so those adapter rows are outside this port-level replay slice. |
| TypeScript | Explicit `submit.ts` + test TypeScript check and configured `cd functions && npx tsc --noEmit` exit 0. |
| Rollback boundary | Revert P2.17–P2.18 changes in `functions/src/provisioning/submit.ts` and `functions/test/provisioning/submit.test.ts`, their two checkboxes, and this record. |

- `git diff --check` passed; P2.19+ remains unchecked and pending.
- **Implementation evidence revision**: `sha256:3481f43ce5625cc48a53f902e2fc6160b275fd03da0950d29f09c103d289f620`, from the UTF-8 newline-terminated ordered `path SHA-256` manifest of `submit.ts` and `submit.test.ts` after GREEN.

## P2-safe-status-dto — P2.19–P2.20

**Status**: implemented under Strict TDD. `projectStatusDto` uses explicit status branches and returns `null` for unknown or invalid status/phase shapes; it never serializes persisted sensitive fields or a stored reset link.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.19–P2.20 | `functions/test/provisioning/dto.test.ts` | Unit | N/A (new DTO files) | `node --experimental-strip-types test/provisioning/dto.test.ts` → exit 1, `ERR_MODULE_NOT_FOUND` for absent `dto.ts` | Same command → exit 0, 69 assertions | Five canonical statuses each have an exact DTO and prohibited-field non-leak proof; four unknown/invalid shapes fail closed | None needed; explicit branches are minimal |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/dto.test.ts` → exit 0, 69 assertions. |
| Runtime harness command/scenario and exact result | Same Node harness invokes the production projection over persisted-operation-shaped records; no Firebase/emulator boundary exists for this pure projection. |
| Regression | Submission 25 assertions; schemas 41; audit 46; authorization 14; export metadata 4; MemoryStore 1/1; Store conformance 4/4 — all exit 0. |
| Rollback boundary | Delete `functions/src/provisioning/dto.ts` and `functions/test/provisioning/dto.test.ts`; revert only P2.19–P2.20 checkboxes and this record. |

- Explicit source+test TypeScript, configured `npx tsc --noEmit`, and `git diff --check` passed.
- **Implementation evidence revision**: `sha256:6e59d6d0f92b7cfe13eab082fe29a128bb14a9d593a27d42e6bbde6df9e3723e`, from the UTF-8 newline-terminated ordered `path SHA-256` manifest of `dto.ts` and `dto.test.ts` after GREEN.
- P2.21+ remains unchecked and pending.

## P2-log-audit-safety — P2.21–P2.22

**Status**: implemented under Strict TDD. Application-log construction is a bounded projection beside the existing audit contract, not a second audit model.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.21–P2.22 | `functions/test/provisioning/audit.test.ts` | Unit / structural | Existing audit harness → 46 assertions pass | Test-first import → exit 1: missing `APPLICATION_LOG_DIGEST_DOMAINS` export | Same command → exit 0, 91 assertions | Valid tagged-digest projection; three invalid codes; ten prohibited raw/metadata fields; three invalid digest forms; 15 production sources scanned for direct logging bypasses | Generalized the existing canonical code vocabulary as the single allowlist; no further refactor needed |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/audit.test.ts` → exit 0, 91 assertions (39 audit schema + 7 audit dedup + 45 application-log safety). |
| Runtime harness command/scenario and exact result | Same Node harness constructs the production log projection and scans all 15 `functions/src/**/*.ts` files; no Firebase/emulator boundary exists for this pure structural contract. |
| Security proof | Exact log shape permits only event/result/reason codes from the canonical audit allowlist and nonempty `{domain,value}` SHA-256 pairs tagged `provision-actor:v1`, `provision-audit:v1`, or `provision-dispatch:v1`; raw email, UID, operation ID, owner, audit identity, reset link, evidence, lease, payload, and arbitrary metadata are rejected. Direct `console`, `logger`, and stdout/stderr writes are structurally absent from application source. |
| Regression | Submission 25 assertions; DTO 69; schemas 41; authorization 14; export metadata 4; store conformance 4/4; MemoryStore 1/1 — all exit 0. |
| TypeScript | Explicit `audit.ts` + `audit.test.ts` TypeScript check and configured `npx tsc --noEmit` exit 0. |
| Rollback boundary | Revert only the P2.21–P2.22 additions in `functions/src/provisioning/audit.ts` and `functions/test/provisioning/audit.test.ts`, these two checkboxes, and this record. |

- `git diff --check` passed; P2.23+ remains unchecked and pending.
- **Implementation evidence revision**: `sha256:89ebf405f6f2d7d522a1baaf347195a1651023ba9a3faf2f1b49ea43b9e289ff`, from the UTF-8 newline-terminated ordered `path SHA-256` manifest of `audit.ts` and `audit.test.ts` after GREEN.

## P2-production-enqueue-adapter — P2.25–P2.26

**Status**: GREEN validation confirms deterministic Cloud Tasks request construction: a canonical dispatch produces its qualified task name and a body containing only `dispatchId`; noncanonical task IDs and invalid queue environments fail closed.

### TDD Cycle Evidence

| Task | RED | GREEN | REFACTOR |
|---|---|---|---|
| P2.25–P2.26 | Maintainer-authorized exception: recovery preserved production adapter source/tests whose bytes differ from the P2.24 begin tree, but no genuine RED chronology survived. | Focused harness passes 22 assertions; explicit source+test and configured TypeScript checks pass. | None. |

### Work Unit Evidence

- Checks: Node `v24.11.1`; `cd functions && node --experimental-strip-types test/provisioning/enqueue.test.ts` → exit 0, 22 assertions; explicit enqueue source+test TypeScript and `cd functions && npx tsc --noEmit` → exit 0; `git diff --check` → exit 0.
- Runtime harness: injected Cloud Tasks transport received byte-stable deterministic requests and propagated transport failure; a real Cloud Tasks emulator is not supported by the design.
- Scope: the RED-evidence exception is only for P2.25–P2.26. P2.27+ remains pending.
- Accounting and preservation: this records operation adds `21` changed lines against active begin tree `2a0c1c85c58c66e139760550ac7d196c187f413a`; staged inventory is empty; all P2.0–P2.24 and unrelated changes were preserved; no commit, staging, push, PR, install, or native delivery action occurred.

## P2-created-trigger-emulator-remediation — P2.27–P2.28

**Status**: accepted after one bounded remediation launch. The prior genuine RED and focused GREEN remain historical; this entry adds distinct emulator evidence without changing the candidate implementation.

### TDD Cycle Evidence

| Task | RED | GREEN | REFACTOR |
|---|---|---|---|
| P2.27–P2.28 | Historical: `node --experimental-strip-types test/provisioning/outbox.test.ts` failed with `ERR_MODULE_NOT_FOUND` before `outbox.ts` existed. | Historical focused harness: exit 0, `OK: created outbox trigger 20 assertions`. Remediation emulator harness: exit 0 with the same 20 assertions. | No product refactor; remediation corrected the process-local Java resolution only. |

### Work Unit Evidence

- Required emulator command: `cd functions && JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.12.8-hotspot` with that JDK's `bin` first in `PATH`, then `npx firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox.test.ts"` → exit 0; Firestore started and the test reported `OK: created outbox trigger 20 assertions`.
- Diagnosis and linkage: the failed evidence revision `sha256:eee5d450d42fca16d63a78790b693a4973bbc0cadec3e0647e570c54159b2ece` ran with an invalid `JAVA_HOME` (`jdk-21.0.10.7-hotspot` absent) and PATH-resolved Oracle Java 8. The passing launch used existing Temurin 21.0.12 only in its process environment.
- Supporting integrity checks: direct focused Node harness exit 0, explicit `outbox.ts`/`enqueue.ts`/`schemas.ts` plus `outbox.test.ts` TypeScript check exit 0, and `git diff --check` for the two candidate paths exit 0.
- Functions-emulator limitation: Firebase CLI 14.26.0 reported that the Functions definition did not load because package engine `>=20` is unsupported by that CLI parser; the command and test still exited 0. This is not endpoint/trigger-export proof, which remains owned by P2.37–P2.38.
- Exact candidate paths: `functions/src/provisioning/outbox.ts` and `functions/test/provisioning/outbox.test.ts` (265 pre-existing source/test lines, preserved unchanged). This remediation changed only the two task checkboxes and this progress record; no repository configuration was persisted.
- Budget and cleanup: candidate implementation is 265 lines; remediation bookkeeping remains below the 400-line limit. The emulator shut down normally; ports 4000, 5001, 8080, 9099, and 9150 had no listeners and no Firebase/Firestore emulator process remained.
- Rollback boundary: revert only these P2.27–P2.28 task checkboxes and this record; the preserved source/test candidate remains independently removable at its existing two paths.
- Pending: P2.29+ remains unchecked.

- **Remediation evidence revision**: `sha256:a93f405cf73fbda3b87675637643682d36b4a18bce508e942ca1eb7f74e8c48a`, a UTF-8 newline-terminated manifest of the two candidate hashes plus the exact passing emulator command, runtime versions, outcome, and Functions-emulator load limitation. It is distinct from the failed revision above.

## P2-scheduled-outbox-repair — P2.29–P2.30

**Status**: completed under Strict TDD remediation. The authoritative genuine RED remains preserved; this retry repaired source-runtime module resolution without changing sweeper behavior.

### TDD Cycle Evidence

| Task | Test file | Layer | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|
| P2.29–P2.30 | `functions/test/provisioning/outbox_repair.test.ts` | Firestore emulator | Authoritative genuine RED preserved from the initial candidate | Emulator command exited 0, 10 assertions | Grace/order and five-page/rate/concurrency scenarios | None; import/runtime compatibility only |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && JAVA_HOME=<Temurin-21-child-env> npx firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox_repair.test.ts"` → exit 0, 10 assertions. |
| Runtime harness command/scenario and exact result | Firestore emulator directly exercised the real repair store, exact grace edge, deterministic ordering/cursors, five-page bound, and rate/concurrency limits → exit 0. |
| Rollback boundary | Revert only this retry's provisioning `.ts` import extensions, `rewriteRelativeImportExtensions`, these two checkboxes, and this progress record; the preserved sweeper candidate remains otherwise unchanged. |

### Verification

- Source policy: every relative import under `functions/src/provisioning/` now uses an explicit `.ts` extension; package imports remain unchanged.
- Direct Node v24.11.1 strip-types source preflight loaded `outbox_repair.ts` successfully.
- `npx tsc --noEmit`, emitted ESM import of `lib/provisioning/outbox_repair.js`, and focused source+test TypeScript checking exited 0; emitted relative imports use `.js`.
- The emulator used Temurin 21.0.12 only in its child environment and shut down normally. Firebase CLI warned that its Functions definition parser rejects the package engine range, but the focused Firestore harness executed and passed.

### Retry Scope

- This retry changed 65 authored lines: 31 source/config lines and 34 OpenSpec bookkeeping lines; generated `functions/lib/**` output is excluded.
- Staging is empty; no commit, delivery, push, PR, package change, or dependency installation occurred.

## P2-sweeper-forbidden-operations — P2.31–P2.32

**Status**: completed under Strict TDD. The focused emulator proof confirms that repair preserves the existing dispatch/task identity and worker acknowledgement while leaving operation and profile documents unchanged.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.31 | `functions/test/provisioning/outbox_repair.test.ts` | Firestore emulator | P2.29–P2.30 baseline → 10 assertions pass | Genuine RED: named export `createEnqueueAcknowledgement` was absent | N/A — RED task | Existing unacknowledged repair plus retained `processed` worker-ack sentinel | N/A |
| P2.32 | `functions/test/provisioning/outbox_repair.test.ts` | Firestore emulator | RED retained | Focused emulator → exit 0, 23 assertions | Normal stale repair and worker-ack-preservation edge cover distinct dispatch states | Minimal test-only type correction; no production behavior change |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && JAVA_HOME=<Temurin-21-child-env> npx firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox_repair.test.ts"` → exit 0, 23 assertions. |
| Runtime harness command/scenario and exact result | Firestore emulator seeded a stale dispatch with a retained worker acknowledgement plus protected operation/profile documents; repair acknowledged only enqueue fields, preserved canonical IDs and worker acknowledgement, created no dispatch, and left operation/profile state unchanged. |
| TypeScript | Explicit `enqueue.ts` + `outbox.ts` + `outbox_repair.ts` + `schemas.ts` + focused test check and configured `npx tsc --noEmit` both exit 0. |
| Rollback boundary | Revert `createEnqueueAcknowledgement` in `functions/src/provisioning/outbox.ts`, the P2.31–P2.32 test additions, these two checkboxes, and this record. |

- **Remediation**: the preserved prior check reported seven TS2339 errors because object spread over `Record<string, unknown>` hid retained fields. The first resumed check then proved the annotation also needs its `Record<string, unknown>` index signature; the test now uses `PersistedDispatch = EnqueueDispatch & Record<string, unknown> & {...}` and the single corrective rerun passed without casts or production broadening.
- **Accounting and cleanup**: remediation delta is 45 changed lines (17 test correction, 4 task-checkbox lines, 24 progress lines), below 400. `firestore-debug.log` was removed; emulator shutdown completed; no emulator listeners/processes remained; staging is empty.

## P2-trigger-sweeper-race-definitive — P2.33–P2.34

**Status**: completed under the maintainer-authorized RED exception. Production behavior from P2.27–P2.32 was already present, so this test-only characterization does not fabricate a RED failure or claim genuine RED evidence.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.33 | `functions/test/provisioning/outbox_repair.test.ts` | Firestore emulator | Baseline focused emulator: exit 0, 23 assertions | Maintainer-authorized exception: existing behavior was already GREEN; earlier harness failures were invalid and are not RED evidence | N/A — exception task | Trigger-first and sweeper-first guarded acknowledgement orders | Test harness only; no production change |
| P2.34 | `functions/test/provisioning/outbox_repair.test.ts` | Firestore emulator | P2.33 baseline retained | RED exception retained | Focused emulator: exit 0, 49 assertions | Both controlled acknowledgement orders assert one side effect, one `{ code: "ALREADY_EXISTS" }`, identical task identity, and `enqueued === true` convergence | Strip-types-compatible explicit fields; timeout prevents unsettled top-level await |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && JAVA_HOME=<Temurin-21-child-env> npx firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox_repair.test.ts"` → exit 0, 49 assertions. |
| Runtime harness command/scenario and exact result | The Firestore emulator executed `handleCreatedDispatch` and `repairStaleDispatches` against the same persisted dispatch/store. An explicit two-arrival enqueue barrier started both promises before either was awaited; controlled trigger-first and sweeper-first releases proved one queue side effect, one `{ code: "ALREADY_EXISTS" }`, deterministic task identity, and guarded acknowledgement convergence. |
| TypeScript | Explicit outbox source+test `npx tsc --noEmit`, configured `npx tsc --noEmit`, and configured `npm run build` all exit 0. |
| Rollback boundary | Remove only the P2.33–P2.34 race characterization from `functions/test/provisioning/outbox_repair.test.ts`; revert these two checkboxes and this record. No production behavior is removed. |

- **Verification environment**: Node v24.11.1; Temurin 21.0.12.8 was injected only into the emulator child process. Firebase CLI still warned that its Functions definition parser rejects the package engine range `>=20`, but the Firestore harness executed and passed.
- **Cleanup and process evidence**: `firestore-debug.log` and build output `functions/lib/` were removed; ports 4000, 5001, 8080, 9099, and 9150 had no listeners after shutdown; no emulator process, staging, install, configuration change, commit, push, or PR remained.
- **Native settlement and accounting**: the completed implementation attempt settled `passed` at 197/400 changed lines; its remediated evidence revision is `sha256:ec8d80628c0530fd6ad940f9c003b88220d746d370fe5cafd5f851a9a66bee5d`.
- **Scope**: this P2.33–P2.34 work unit changed only `functions/test/provisioning/outbox_repair.test.ts` and active OpenSpec evidence. Pre-existing dirty and untracked production files from earlier authorized P2 slices were preserved and are outside this work unit. The test avoids parameter properties, enums, namespaces, decorators, and transform-dependent syntax.
- **Implementation evidence revision**: `sha256:219c2298c26c407260c0275f3d7551bd21d4bebcfe39362fa7748bb0251af32d`, derived from the post-correction test hash and the distinct focused-emulator, explicit/configured TypeScript, configured-build, and cleanup evidence; it remediates failed evidence `sha256:ec8d80628c0530fd6ad940f9c003b88220d746d370fe5cafd5f851a9a66bee5d`.

## P2-partial-enqueue-failure — P2.35–P2.36

**Status**: completed under Strict TDD. A repair run now completes its bounded page after individual enqueue failures, emits only domain-separated operation and dispatch digests for each failed record, and then throws so Scheduler retry and the next scheduled run can re-drive unresolved records.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.35 | `functions/test/provisioning/outbox_repair.test.ts` | Firestore emulator | Focused emulator baseline → exit 0, 49 assertions | Focused emulator → exit 1: `a failed record does not end the repair run before its bounded peer finishes`; existing `Promise.all` rejected early | N/A — RED task | Existing all-success repair plus controlled partial-failure peer exercise distinct outcomes | The PII assertion was corrected to inspect the failed record actually represented in the log; focused emulator remained green |
| P2.36 | `functions/test/provisioning/outbox_repair.test.ts` | Firestore emulator | RED retained | Focused emulator → exit 0, 59 assertions | Successful peer is acknowledged, failed peer remains eligible, one digest-only log is emitted, then the repair throws after the page | None needed |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && JAVA_HOME=<Temurin-21-child-env> npx firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox_repair.test.ts"` → RED exit 1 at the early-settlement assertion; GREEN exit 0, 59 assertions. |
| Runtime harness command/scenario and exact result | Firestore emulator seeds one failing and one held-success stale dispatch. The harness proves the run waits for the successful peer, persists only its enqueue acknowledgement, logs two 64-hex digests without the failed raw operation ID, and rejects after the bounded page. |
| TypeScript | Explicit `enqueue.ts`, `outbox.ts`, `outbox_repair.ts`, `schemas.ts`, and focused test TypeScript check plus configured `npx tsc --noEmit` both exit 0. |
| Rollback boundary | Revert the per-record outcome aggregation and digest-only log in `functions/src/provisioning/outbox_repair.ts`, remove the partial-failure test extension in `functions/test/provisioning/outbox_repair.test.ts`, and revert only P2.35–P2.36 plus this record. |

- **Native settlement and accounting**: the completed implementation attempt settled `passed` at `127/400` changed lines; its implementation evidence revision is `sha256:97a7f9a95d4f75ecec15a053e27ca07218d01cb21740743b6c560438b8fd11f5`. No transient attempt token is persisted.
- **Cleanup and scope attribution**: Temurin 21.0.12.8 was injected only into emulator child processes; emulator shutdown completed, generated logs were removed, and process/listener cleanup was verified. This P2.35–P2.36 slice owns only its `outbox_repair.ts` production change, `outbox_repair.test.ts` test extension, task checkboxes, and this evidence record; pre-existing dirty and untracked workspace paths were preserved and are not owned by this slice.

## P2-trigger-metadata-structural-proof — P2.37–P2.38

**Status**: accepted for unmanaged OpenSpec task continuation after Strict TDD GREEN verification; this is not native settlement. The Functions composition root now exports a v2 Firestore created-document trigger for `provisioningDispatch/{dispatchId}` with retry explicitly enabled. Its current handler fails closed until the later runtime-composition slice supplies the Firestore and Cloud Tasks adapters; it does not silently acknowledge or discard an outbox dispatch. Native settlement remains blocked by the provider/untracked-inventory defect. Receipt-driven development (RDD) is currently off, and the maintainer/user explicitly selected unmanaged continuation on 2026-09-04.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.37 | `functions/test/provisioning/trigger_metadata.test.ts` | Unit / structural | `node --experimental-strip-types test/export-metadata.test.ts` → exit 0, 4 assertions | `node --experimental-strip-types test/provisioning/trigger_metadata.test.ts` → exit 1, `SyntaxError`: `index.ts` did not export `provisioningDispatchCreated` | N/A — RED task | Export presence, v2 endpoint platform, event metadata presence, retry flag, and source-bound path/options cover distinct structural facts | None needed |
| P2.38 | `functions/test/provisioning/trigger_metadata.test.ts` | Unit / structural | RED retained | Same command → exit 0, 5 assertions | Trigger export plus metadata/source assertions exercise independent deployment-contract fields | TypeScript narrowed the event metadata before reading `retry`; focused test remained green |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/trigger_metadata.test.ts` → RED exit 1 for the absent export; GREEN exit 0, 5 assertions. |
| Runtime harness command/scenario and exact result | N/A: this slice proves exported deployment metadata only. The handler intentionally fails closed rather than performing a partial enqueue without the later composition adapters; no Firebase emulator boundary is introduced by P2.37–P2.38. |
| Structural/export check | `cd functions && node --experimental-strip-types test/export-metadata.test.ts` → exit 0, 4 assertions for the existing callable App Check export. |
| TypeScript and build | Explicit `index.ts` + trigger-metadata test TypeScript, configured `npx tsc --noEmit`, and configured `npm run build` all exit 0. `git diff --check` exits 0; it reports only preserved CRLF conversion warnings on pre-existing paths. |
| Rollback boundary | Remove `provisioningDispatchCreated` and its Firestore import from `functions/src/index.ts`; delete `functions/test/provisioning/trigger_metadata.test.ts`; revert only P2.37–P2.38 checkboxes and this record. |

- **Implementation evidence revision**: `sha256:7d6b648dab55ed549a86df03543f2bbea119ffc09b0a44c2764168ca17d1ff55`, calculated from a UTF-8 newline-terminated manifest of SHA-256 hashes for `functions/src/index.ts` and `functions/test/provisioning/trigger_metadata.test.ts`.
- **Native settlement and accounting**: exactly one `passed` settlement request was made with request ID `p237-p238-trigger-metadata-20260902-01`; native rejected it with `untracked inventory changed; rerun gentle-ai review status --cwd <repo> --contract gentle-ai.review-integration/v2 --agent <runtime> --next-transition before selecting paths`. Native settlement remains blocked by that provider/untracked-inventory defect; no native changed-line count or accepted outcome exists. RDD is currently off, and the maintainer/user explicitly selected unmanaged continuation on 2026-09-04. P2.37–P2.38 are therefore checked only as unmanaged OpenSpec task acceptance, not as native acceptance. No retry, remediation flag, or second settlement was attempted.
- **Cleanup and scope attribution**: generated `functions/lib/` output was removed after the configured build. Ports 4000, 5001, 8080, 9099, and 9150 had zero listeners; no emulator or child process remained. This slice owns the `index.ts` trigger-metadata addition, `trigger_metadata.test.ts`, the two pending task entries, and this candidate record. All pre-existing dirty and untracked production paths were preserved separately.

## P2.39–P2.40 — Unmanaged OpenSpec Continuation

**Status**: completed under Strict TDD as an unmanaged OpenSpec continuation; this is not native settlement or acceptance.

- **RED**: `cd functions && node --experimental-strip-types test/provisioning/scheduler_metadata.test.ts` failed before the production change because `index.ts` did not export `provisioningOutboxRepair`.
- **GREEN**: the same command passed with 11 assertions after adding the fail-closed Firebase v2 `onSchedule` export.
- **Contract**: every 5 minutes; `retryCount=3`, `minBackoffSeconds=30`, `maxBackoffSeconds=300`, `maxDoublings=2`, `maxInstances=1`, and `timeoutSeconds=240`.
- **Checks**: configured `npx tsc --noEmit` and explicit `index.ts` plus scheduler-test TypeScript checks passed; no deployment IDs, project IDs, secrets, or runtime composition were added.

## P2.41–P2.42 — Unmanaged OpenSpec Continuation

**Status**: completed under Strict TDD as an unmanaged OpenSpec continuation; this is not native settlement or acceptance.

- **RED**: `cd functions && node --experimental-strip-types test/provisioning/monitoring_metadata.test.ts` exited 1 because `src/provisioning/monitoring.ts` was absent.
- **GREEN**: the same command passed with 10 assertions after adding declarative, typed monitoring metadata only.
- **Contract**: stale-outbox age `outbox_stale_age_seconds` alerts above 900 seconds for two consecutive 5-minute periods; Eventarc trigger error/delivery-failure, sweeper execution-error/missing-successful-execution after 10 minutes, and Cloud Tasks enqueue/attempt-exhaustion alerts are named. Log identifiers are limited to operation/dispatch digests or coded identifiers.
- **Checks**: configured `npx tsc --noEmit` and explicit monitoring source/test TypeScript checks passed. No production alert, deployment, external configuration, project ID, or secret was created.

## P2-scheduler-metadata-structural-proof — Native Reconciliation

**Status**: passed native reconciliation for the already implemented P2.39–P2.40 candidate. The preceding unmanaged RED/GREEN chronology remains the historical implementation record; this work unit added no production or test bytes and did not fabricate a new RED cycle.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.39–P2.40 reconciliation | `functions/test/provisioning/scheduler_metadata.test.ts` | Unit / structural | Existing candidate; no files modified | Historical unmanaged RED retained above: absent `provisioningOutboxRepair` export | Fresh `node --experimental-strip-types test/provisioning/scheduler_metadata.test.ts` → exit 0, 11 assertions | Existing structural assertions independently cover cadence, retry configuration, instance bound, timeout, and source-bound options | None; no source or test change |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Node prerequisite | `node --version` → `v24.11.1`, satisfying Node >= 22.6.0. |
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/scheduler_metadata.test.ts` → exit 0, `OK: provisioning outbox repair scheduler metadata 11 assertions`. |
| Runtime harness command/scenario and exact result | The focused Node harness imports the actual Firebase v2 scheduled export and inspects its deployment metadata. Emulator N/A: this is an exported structural metadata boundary with no scheduler deployment or runtime composition. |
| TypeScript checks | Explicit `index.ts` plus scheduler-test TypeScript check → exit 0; configured `cd functions && npx tsc --noEmit` → exit 0. |
| Rollback boundary | Revert only this reconciliation record; no production or test behavior was modified. |

- **Implementation evidence revision**: `sha256:5c8d9c1c3476d70e50bfc16c3e5774bbdbb0e4f7c0bfa0cd90c9b650e5bde84b`, calculated from a UTF-8 newline-terminated manifest of SHA-256 hashes for `functions/src/index.ts` and `functions/test/provisioning/scheduler_metadata.test.ts`.
- **Native settlement and accounting**: passed exactly once with request ID `settle-p2-scheduler-metadata-20260904-b`; the native response reported `state: complete`. Validation changed 0/400 candidate lines; this OpenSpec reconciliation record is the only repository-byte mutation in this continuation.
- **Cleanup and scope attribution**: no verification-generated output, emulator, listener, or child process was created; no cleanup was required. The exact acquired 31-path untracked selection and digest `sha256:99def73d8ad0a5d330a8181ef200629e4902679bf3ddf3aae88668f804fe2c47` were preserved in settlement.

## P2-monitoring-metadata-structural-proof — Native Reconciliation Candidate

**Status**: freshly validated candidate for the already implemented P2.41–P2.42 monitoring metadata. The historical unmanaged RED/GREEN chronology above remains the implementation record; this reconciliation adds no production or test bytes and does not claim a new RED cycle. Native settlement is pending the parent orchestrator.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.41–P2.42 reconciliation | `functions/test/provisioning/monitoring_metadata.test.ts` | Unit / structural | Existing candidate; no files modified | Historical unmanaged RED retained above: absent `monitoring.ts` | Fresh `node --experimental-strip-types test/provisioning/monitoring_metadata.test.ts` → exit 0, 10 assertions | Existing assertions independently cover threshold/cadence, all four alert families, PII-safe identifiers, and forbidden raw-PII tokens | None; no source or test change |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Node prerequisite | `node --version` → `v24.11.1`, satisfying Node >= 22.6.0. |
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/monitoring_metadata.test.ts` → exit 0, `OK: provisioning monitoring metadata 10 assertions`. |
| Runtime harness command/scenario and exact result | The focused Node harness imports the actual declarative metadata and reads its source to enforce the PII-safe token boundary. Emulator N/A: P2.41–P2.42 define structural metadata only and create no alert, deployment, scheduler, or external runtime boundary. |
| TypeScript checks | Explicit monitoring source plus test TypeScript check → exit 0; configured `cd functions && npx tsc --noEmit` equivalent via local `node_modules/.bin/tsc.cmd --noEmit` → exit 0. |
| Rollback boundary | Revert only this reconciliation record; no production or test behavior was modified. |

- **Candidate evidence revision**: `sha256:bcea7ff30130e5a36a34a125cc8bf4720718b3158f2bbb3995e78aa4acc69e78`, calculated from a UTF-8 newline-terminated manifest of SHA-256 hashes for `functions/src/provisioning/monitoring.ts` and `functions/test/provisioning/monitoring_metadata.test.ts`.
- **Native attempt handling**: reused the maintainer-supplied token `sha256:dd01490c47dcb304ac8b7531fa4c0ca3f4393d6bcb783fa5260a6be0f25ce251`; this executor did not acquire, reset, or settle an attempt. Parent settlement remains required.
- **Line accounting and scope attribution**: 0 source/test behavior lines changed against the existing candidate, within the 400-line budget. This append-only OpenSpec reconciliation record is the sole current-continuation repository mutation; all pre-existing dirty and untracked paths remain outside the rollback boundary.

## P2-IAM-deployment-metadata — P2.43–P2.44

**Status**: completed under Strict TDD. The direct-import carrier is inert declarative repository-preparation evidence; it defines only placeholders and intended capabilities, with no runtime export or deployment effect.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.43 | `functions/test/provisioning/iam_metadata.test.ts` | Unit / structural | N/A (new files) | `cd functions && node --experimental-strip-types test/provisioning/iam_metadata.test.ts` → exit 1, `ERR_MODULE_NOT_FOUND` for absent `src/provisioning/deployment_metadata.ts` | N/A — RED task | Environment placeholders, per-function logical identities/capabilities, queue/OIDC/enqueuer intent, invocation identities, and Firestore/Auth capability sets cover distinct structural facts | None needed |
| P2.44 | `functions/test/provisioning/iam_metadata.test.ts` | Unit / structural | RED retained | Same genuine RED retained | `cd functions && node --experimental-strip-types test/provisioning/iam_metadata.test.ts` → exit 0, `OK: provisioning IAM deployment metadata 7 assertions` | Source checks reject concrete project/credential/binding/deployment markers and guessed region/rate/concurrency values | None needed |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Node prerequisite | `node --version` → `v24.11.1`, satisfying Node >= 22.6.0. |
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/iam_metadata.test.ts` → RED exit 1 with `ERR_MODULE_NOT_FOUND` for the absent carrier; GREEN exit 0, `OK: provisioning IAM deployment metadata 7 assertions`. |
| Runtime harness command/scenario and exact result | N/A: the focused Node harness imports the real inert carrier and inspects its source. This structural work unit creates no Firebase, Cloud Tasks, Scheduler, Eventarc, IAM, or deployment runtime boundary. |
| TypeScript checks | `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/deployment_metadata.ts test/provisioning/iam_metadata.test.ts` → exit 0; configured `cd functions && npx tsc --noEmit` → exit 0. |
| Diff check | `git diff --check` → exit 0; preserved CRLF conversion warnings were emitted for pre-existing modified paths only. |
| Rollback boundary | Delete `functions/src/provisioning/deployment_metadata.ts` and `functions/test/provisioning/iam_metadata.test.ts`; revert only P2.43–P2.44 checkboxes and this appended record. |

- **Candidate evidence revision**: `sha256:2eb8562d4106b1f9e3a79b30a738b4b2a74a2f479d893038893a1b69142807b0`, calculated from a UTF-8 newline-terminated manifest of SHA-256 hashes for `functions/src/provisioning/deployment_metadata.ts` and `functions/test/provisioning/iam_metadata.test.ts`.
- **Native attempt handling**: reused the maintainer-supplied token `sha256:cf0469a8f5fb5574687dc9a7917b0ff88db67c870a7a781a2101acd8c947ca9f`; this executor did not acquire, reset, or settle an attempt. Parent settlement remains required.
- **Cleanup and process evidence**: focused Node and TypeScript commands were synchronous and produced no generated output; no emulator, deployment, install, resource-creation, background process, listener, staging, commit, push, or PR was started. No cleanup was required, and all pre-existing dirty/untracked paths were preserved.
- **Scope and ownership**: this unit changed only the carrier, its direct structural test, P2.43–P2.44 checkboxes, and this append-only record. The carrier is not exported from `index.ts`; P3 retains the final task-function export and reviewed runtime IAM bindings.
- **Post-check process snapshot**: `Get-Process -Name node` listed PIDs `1920, 8148, 10212, 12952, 16008, 16072, 16780, 18356`; none was stopped or modified. The work-unit commands ran synchronously and launched no background process.


## P2-backend-structural-boundary — P2.45–P2.46

**Status**: partially implemented but not completed. The backend-only structural characterization test was added and passed GREEN, but the configured TypeScript command did not pass in this environment, so P2.45–P2.46 checkboxes remain unchecked.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P2.45–P2.46 | `functions/test/provisioning/structural_absence.test.ts` | Unit / structural | N/A (new file) | Characterization exception authorized by maintainer: historical “before P2” RED is unreproducible because P2 production already exists after migration; no production rollback or fake RED was performed. | `cd functions && node --experimental-strip-types test/provisioning/structural_absence.test.ts` → exit 0, `OK: backend structural boundary 60 assertions`. | Required file presence, source/export wiring, direct IAM carrier import, no index re-export requirement, and forbidden backend-source patterns are independently checked. | None performed; configured TypeScript failed before completion. |

### Work Unit Evidence

| Evidence | Result |
|---|---|
| Node prerequisite | `node --version` → `v24.20.0`, satisfying Node >= 22.6.0. |
| Focused test command and exact result | `cd functions && node --experimental-strip-types test/provisioning/structural_absence.test.ts` → exit 0, `OK: backend structural boundary 60 assertions`. |
| Runtime harness command/scenario and exact result | N/A: the focused Node harness performs deterministic structural source/import checks in Functions backend scope only. It does not scan Flutter/client paths and does not create Firebase, Cloud Tasks, Scheduler, Eventarc, IAM, or deployment resources. |
| TypeScript check | `cd functions && npx tsc --noEmit` → exit 1. `npx` could not find local `typescript`/`tsc` and attempted the deprecated `tsc@2.0.4` shim, which prints “This is not the tsc command you are looking for.” No dependencies were intentionally installed. |
| Diff check | `git diff --check -- functions/test/provisioning/structural_absence.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md` → exit 0. |
| Rollback boundary | Delete `functions/test/provisioning/structural_absence.test.ts`; remove this appended record. P2.45–P2.46 checkboxes remain unchecked because all required evidence is not green. |

- **Scope**: current executor modified only `functions/test/provisioning/structural_absence.test.ts` and this append-only record. It did not edit production files, config, other tests, unrelated OpenSpec sections, `.atl/.skill-registry.cache.json`, or any selected candidate source/test path outside the allowed test file.
- **Line accounting**: authored test file is 91 new lines, under the 400-line budget. Existing dirty `tasks.md`/`apply-progress.md` line counts predate this bounded work unit and were preserved.
- **Native attempt handling**: parent supplied proceed authority; this executor did not acquire, settle, reset, or persist any token.
- **Remaining task lines**: `- [ ] P2.45 RED: structural boundary (BACKEND-only) — BEFORE P2 Functions production files exist, test requires BOTH: ...`; `- [ ] P2.46 GREEN: structural boundary (BACKEND-only) passes AFTER P2 implementation — all required P2 Functions production files exist and are wired in Functions scope, ...`.


### Corrective Continuation — dependency restoration and final P2.45–P2.46 completion

- **Dependency restoration**: user-authorized `cd functions && npm ci` completed successfully from the existing lockfile: 253 packages added, audit completed, with npm-reported moderate vulnerabilities and install-script approval warnings. `package.json` and `package-lock.json` were not intentionally edited; `node_modules/` is generated/ignored.
- **Focused GREEN**: `cd functions && node --version && node --experimental-strip-types test/provisioning/structural_absence.test.ts` → `v24.20.0`, exit 0, `OK: backend structural boundary 60 assertions`.
- **Configured TypeScript**: `cd functions && npx tsc --noEmit` → exit 0.
- **Scoped diff check**: `git diff --check -- functions/test/provisioning/structural_absence.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md` → exit 0.
- **Task checkbox persistence**: P2.45 and P2.46 are now marked complete in `tasks.md`; P2.47 remains unchecked.
- **Native attempt handling**: parent retained continuation token; this executor did not acquire, settle, reset, or persist any token.

## P2.47 — Outbox Recovery Runbook and Firestore Indexes

**Status**: completed as a documentation/index REFACTOR slice. Strict TDD is active for implementation work, but this task added no production behavior and no fabricated RED was created.

### Evidence

| Check | Result |
|---|---|
| Node prerequisite | `node --version` → `v24.20.0`, satisfying Node >= 22.6.0. |
| Firestore index syntax | `python3 -m json.tool firestore.indexes.json` → exit 0. |
| Functions TypeScript | `cd functions && npx tsc --noEmit` → exit 0. |
| Scoped whitespace check | `git diff --check -- docs/operations/outbox-recovery-runbook.md firestore.indexes.json openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md` → exit 0 before bookkeeping append. |

### Scope and rollback

- Added `docs/operations/outbox-recovery-runbook.md` with PII-safe recovery steps, alert context, deterministic task identity verification, guarded `enqueued=true` acknowledgement checks, stale-dispatch inventory criteria, and explicit forbidden direct mutations.
- Added exactly five design-mandated composite indexes to `firestore.indexes.json` while preserving existing indexes: two `provisioningOperations`, two operation/audit lookup indexes, and the `provisioningDispatch` sweeper index over `enqueued`, `createdAt`, and `__name__`.
- Updated only the P2.47 checkbox in `tasks.md`.
- Rollback is limited to deleting the runbook, removing the five added Firestore composite indexes, reverting the P2.47 checkbox, and removing this appended evidence block.

### Process notes

- No token acquisition, settlement, reset, or persistence was performed.
- No package manifests, deployment configuration, PR, commit, staging area, `.atl` file, or skill-registry cache was modified.
- Pre-existing dirty and untracked paths were preserved; only the allowed P2.47 edit surfaces were touched.

### Remaining tasks

- No implementation-owned P2.47 work remains.

### Final reconciliation

- Final scoped whitespace check was re-run after the P2.47 checkbox and this evidence were appended: `git diff --check -- docs/operations/outbox-recovery-runbook.md firestore.indexes.json openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md` → exit 0.
- Final `python3 -m json.tool firestore.indexes.json` and `cd functions && npx tsc --noEmit` were re-run after bookkeeping → both exit 0.

## P3-A — Profile Provenance (P3.0–P3.4)

**Status**: completed under Strict TDD using the preserved candidate. `profile.ts` remained read-only; the only behavior addition was deterministic rejecting-reader reliability coverage.

### TDD Cycle Evidence

| Tasks | Test file | Layer | RED | GREEN / TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|
| P3.1–P3.2 | `functions/test/provisioning/profile.test.ts` | Pure unit | Recovered genuine pre-source `ERR_MODULE_NOT_FOUND` for absent `profile.ts`; not re-fabricated | Direct harness: 2 pass, 1 emulator-only skip; complete provenance mismatch vectors pass | None needed; production was reusable as-is |
| P3.3–P3.4 | `functions/test/provisioning/profile.test.ts` | Firestore emulator | The pre-source missing-module RED covered the already-authored emulator vectors | Emulator harness: 3/3 pass; match, missing, and every mismatch execute against Firestore | Added rejecting `ProfileReader` assertion proving the exact read error propagates instead of becoming absence |

### Verification and Scope Evidence

- Node gate: `cd functions && node --version` → `v24.20.0`, satisfying Node >= 22.6.0.
- Pure GREEN: `node --experimental-strip-types test/provisioning/profile.test.ts` → 2 pass, 0 fail, 1 emulator-only skip.
- Emulator GREEN: `npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/profile.test.ts"` → 3 pass, 0 fail; emulator shut down cleanly.
- TypeScript: `npx tsc --noEmit` → exit 0.
- Whitespace: no-index checks covered both untracked profile files and tracked checks covered `tasks.md` plus `apply-progress.md`; all clean.
- Line accounting: profile source/test candidate is 217 lines (74 + 143); five checkbox flips are 10 diff lines and this 25-line evidence block makes 252 total P3-A authored diff lines, below 400.
- Package integrity: `package.json` remained `53747c031e48188b2393e5de82dbb823b12567f928283d5169431e3dfd5264b3`; `package-lock.json` remained `330cd7ece0e1b7c37fdab4a223642834348377d4574d3ba1e307991daf46cbfc`.
- Cleanup/process: Firebase reported orderly Firestore emulator, hub, and logging shutdown; no emulator/background process remained and no generated debug path was added to Git status.
- Rollback: remove `profile.ts` and `profile.test.ts`, revert only P3.0–P3.4 checkboxes, and remove this appended block; P2 and unrelated dirty/untracked files remain intact.
- Native authority: parent supplied proceed continuation and retained its token; this executor did not acquire, settle, reset, or persist tokens.
- Structured status consumed: `prepare-public-portfolio-repository`, OpenSpec, apply ready, repo-local allowed root `<workspace-root>`; no action-context warning.
- Remaining P3 implementation starts at exact unchecked task `- [ ] P3.5 RED: worker acquisition and delivery classification — validate the full persisted dispatch source tuple, acquire/take over lease, and classify duplicate/out-of-order/orphan/terminal deliveries; stale deliveries mark only the dispatch where legal and return 2xx without advancing operation state.`

## P3-B Planning Amendment — Documentation Only, Blocked

This append-only note records the superseding P3-B plan. No test, emulator, TypeScript invocation, code/config/native-state mutation, authority operation, token storage, install, or Git operation occurred. P3.5–P3.10 checkbox lines remain byte-for-byte unchanged and unchecked.

- The corrected full candidate forecast is **505–650**; the separate B1 incremental correction forecast is **346–439** (`worker.ts 125–155`, `boundaries.ts 28–40`, test `175–220`, tasks `4`, progress `14–20`). Its endpoint against the historical native observation is **578–671**. These are forecasts, not completed work.
- Historical native accounting was **232 charged / 168 remaining under 400**; it is not caller-owned budget. B1 is not claimed to fit 400 or 168. B1 and B2 are feature-branch-chain slices with no size exception and no fresh budget.
- The skeleton is reusable, but tests are insufficient rather than useless. The failed candidate is not GREEN evidence. Missing contracts retained for future RED include strip-types-incompatible parameter properties, deterministic incoming ID/full source tuple, legal stale ack and P2 audit validation/dedup, takeover reread/fences, foreign `failed/already-exists`, read spies, and atomicity vectors. The genuine historical missing-module RED is retained; no GREEN is claimed from it, and TypeScript passing alone is insufficient.
- B1 remains blocked at P3.5–P3.6; B2 depends on accepted B1 and covers P3.7–P3.10 only. Future proof must use direct `node --experimental-strip-types`, explicit test-file TypeScript, and Firestore/Auth/Functions emulator coverage. Package manifests remain frozen. No tests or emulators were run here.
- Zero-drift rescope means unchanged since settlement, not zero accumulated lines; narrowing carries budgets. No widening/reset is authorized by this amendment, and docs must not be manipulated to enable one. This amendment may change candidate identity/post-settlement drift, so fresh native eligibility is required before execution.

### Candidate and task preservation evidence

Independent structural validation confirmed that all three candidate SHA-256 hashes match the pre-amendment failed-candidate evidence:

| File | Preserved SHA-256 |
|---|---|
| `worker.ts` | `bd29cd7fae2975c0da6a37602ca3581aa92eb78d917c9364e6d48504e0fa79d4` |
| `boundaries.ts` | `f231546639c4be47e428d910047934bc46278a4efb37fe8895f6e8ad33191fcd` |
| `worker_auth.test.ts` | `3cf3a6f047af58b2b1304198831d94b5ca7a49158322b9a64013c9916f6c00c9` |

P3.5–P3.10 remain unchecked and match the pre-amendment worktree text captured in the parent session. P3.5/P3.9 already differed from Git HEAD before this amendment; HEAD is not the amendment baseline. No full-artifact pre-amendment checkbox hash is claimed. Scoped documentation whitespace validation passed.

- Native authority: no acquire, settle, reset, or rescope operation was attempted; no token is stored.
- Rollback: remove only this appended note and the superseding planning section in `tasks.md`; preserve all unrelated dirty/untracked state.

## P3-B Successor Narrowing Pass — Documentation Only

- The prior P3-B reset-block wording is superseded by the supplied latest native remediation relation: last-observed state `sha256:01a82d5f9eb50f0f2cbb4ad310876fcaa598f22b9a1b92993c30b9e18b63062b`, `objective=null`, current `0`, attempts `0`, lines `0`, lifetime `5/794`, and `next_action=begin`. This is not a fresh admission or semantic settlement. No acquire, implementation, native mutation, test, emulator, install, or Git write occurred in this pass.
- The failed evidence `sha256:1770af2293aa772bdfe644120e875fcdd18a2f73ea2e693c163c736615d30a54` remains retained. Read evidence is 101 lines (`worker.ts`), 58 (`boundaries.ts`), and 73 (`worker_auth.test.ts`), 232 total; no 310-ish source-length assumption is used. The three historical candidate hashes remain preservation evidence only; no before/after Bash hash was run because this tool session has no shell/command tool, and the three code files were not modified.
- The sound first successor is the worker delivery identity gate described in `tasks.md`: classification only, with acquisition/Auth behavior explicitly removed or isolated rather than left reachable as accepted behavior. The rewritten worker and test import no symbol from `boundaries.ts`; its preserved hash remains historical. The descriptor-safe active/pending envelope validator and its adversarial tests are included in the corrected forecast: additions `162–206`, total changed lines `273–351`, below the 400-line hard limit. The historical B1 346–439 estimate is not reused or relabeled.
- The unit owns no stale acknowledgement, audit, lease/takeover, Auth, preflight, intent, or P3.5–P3.10 acceptance. Those remain downstream and unchecked. No claim is made that P3-B or P3 is corrected.
- Rollback: remove this appended planning note and the successor section in `tasks.md`; preserve all prior historical evidence, checkboxes, IDs, code, config, native state, and unrelated worktree changes.

## P3-B.1 Delivery Identity Gate — Classifier Only

### P3-B.1 Completion Evidence — Historical Append

- Native-complete scope was the pure delivery classifier only; no P3.5–P3.10 acceptance carried forward.
- Latest verification evidence: `sha256:b13bd17f37d317b79e45ef33d0b8520ebe3f8f65b28875eff96f81808be2f161`.
- Source hashes: worker `9a0d6b441c23cff5d0a5e19502410d6fc525377427317ec9e41d8c282972fe65`; test `50819817e72c51222ad83ceecc510b7075b1070c23d5e7e1cacd19dae7c1d469`.
- Preserved boundary hash: `f231546639c4be47e428d910047934bc46278a4efb37fe8895f6e8ad33191fcd`.
- The classifier ended at 368 incremental changed lines; no code, test, emulator, install, native, staging, commit, or PR operation occurred in this planning pass.

### P3-B.2 Planning Record — Superseded by Corrective Split

- Independent review blocked the prior 213–317 forecast: actual persistence scope is 340–470 because it omitted `boundaries.ts` parameter-property compatibility, `WorkerTransaction.readAudit` propagation, the legal stale matrix, rollback/concurrency, and seeded Firestore convergence.
- That prior record remains historical evidence only; no implementation or acceptance is carried forward.

### P3-B.2a Planning Record — Safe Stale Eligibility Predicate

- Chosen first subunit: pure `corrupt` versus `stale_eligible` classification in `worker.ts` and `worker_auth.test.ts`; persistence, audit writes, boundary plumbing, memory rollback, and Firestore convergence remain downstream.
- Corrupt deterministic IDs, foreign operation/fingerprint, malformed envelopes, wrong request IDs, accessors, and reflection failures are explicit no-write outcomes; only valid stale operation/current-tuple divergence is `stale_eligible`.
- RED/GREEN use the direct worker test and explicit TypeScript commands in `tasks.md`; P2 `schemas.test.ts`, `audit.test.ts`, and `outbox.test.ts` are direct pure regressions. Emulator-bound `outbox_repair.test.ts` is intentionally skipped for this pure slice and requires Java 21 plus `FIRESTORE_EMULATOR_HOST` downstream.
- Forecast is 195–337 changed lines with warning 300, STOP 360, hard maximum 399; no exception, borrowing, implementation, runtime, emulator, install, or native operation occurred. P3.5–P3.10 remain unchecked.

### Retained superseded P3-B.2 evidence

- Next ordered slice is persistence-only: transaction-reread the full operation/dispatch identity, create/deduplicate the P2-validated stale audit, and atomically set only `workerAck=stale`; acquisition/takeover/Auth remain downstream.
- Exact planned paths are `worker.ts`, `boundaries.ts`, `worker_auth.test.ts`, `tasks.md`, and this record. Existing outbox/Firestore emulator harnesses are reused; no new path or install is planned.
- Planned proof includes wrong-ID/source-tuple/accessor/proxy rejection, audit mismatch rollback, replay deduplication, unchanged operation/version, injected transaction failure, and two parallel Firestore transactions converging to one acknowledgement/audit.
- Node 24.x and Java 21 are required. RED/GREEN commands and the 213–317 changed-line forecast are recorded in `tasks.md`; warning 320, STOP 380, hard maximum 399, no exception or borrowing.
- No tests, emulator, install, code/config, staging, commit, PR, or native operation occurred during this planning pass; P3.5–P3.10 remain unchecked.

- Status consumed: OpenSpec `prepare-public-portfolio-repository`, apply ready, repo-local target allowed; no action-context warnings.
- Scope: pure deterministic classifier before external effects; no acquisition, acknowledgement, audit, Auth, or persistence behavior remains reachable.
- Files changed: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, and this cumulative progress record.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | New classifier tests failed: missing `classifyProvisioningDelivery` export in strip-types and TS. |
| GREEN | Six direct Node classifier tests and explicit source+test TypeScript check passed. |
| TRIANGULATE | Per-field dispatch tuple, pending/active controls, duplicate, orphan, terminal, malformed, accessor, and Proxy-failure vectors pass. |
| REFACTOR | Removed the coupled worker/Auth surface; scoped diff check and boundaries-reference check are clean. |

- RED command: `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` exited 1 before source correction.
- GREEN command: the same command exited 0 with 6/6 tests passing; explicit TypeScript and configured `npx tsc --noEmit` exited 0.
- Verification: no emulator, install, configuration, Auth, or Firestore operation was run; those contracts remain deferred.
- Task state: P3.5–P3.10 remain visibly unchecked; this narrow classifier does not complete P3.5 or P3.6.
- Workload: manual start-candidate comparison is +194/-151, 345 code lines; this 23-line record makes 368 incremental lines, below STOP 380 and hard 399.
- Deviations and risks: active envelope validation uses the frozen model state guard while initial pending uses `isValidOperation`; persistence-backed stale acknowledgement, audit, acquisition, takeover, and Auth proof remain downstream.
- Cleanup: no staging, commit, reset, rescope, settlement, or token persistence occurred; unrelated dirty and untracked files were preserved.

### P3-B.2a Authorized Provenance Clarification

- The user selected `trusted_persisted_dispatch`: the exact dispatch document from authorized backend create-if-absent paths, transaction-reread with its operation and temporal coherence, is sufficient issuance provenance; deterministic IDs and arbitrary caller objects are insufficient. No additional transition/audit provenance is required.
- Evidence inspected: `submit.ts` atomically specifies initial operation+dispatch creation; `boundaries.ts` uses transactional `create` for later dispatches; unmatched provisioning collections are client-denied by `firestore.rules`. Production creation exclusivity is not yet proven because `index.ts` submission/dispatch composition remains unimplemented and IAM metadata remains declarative.
- Design/spec/tasks now require one `classifyProvisioningDelivery` vocabulary and exact pending/active generation-version-timestamp table. Terminal, duplicate, orphan, malformed, corrupt, mismatch, future, impossible, and unknown rows are no-write; a pure result never authorizes persistence.
- Documentation-only clarification: no code, test, config, generated file, runtime, emulator, acquire/reset/review/delivery operation ran. Historical failed/superseded estimates remain evidence, are not newly verified, and P3.5–P3.10 remain unchecked. The prior ask-on-risk wording is superseded by the already-approved feature-branch-chain strategy; this pass does not authorize implementation.

## P3-B.2a Forecast Supersession — Documentation Only

- This corrective append supersedes only the prior routing wording and interim-boundary ambiguity; historical forecasts and implementation status remain unchanged.

- Recalculated against the actual current `functions/src/provisioning/worker.ts` classifier and `functions/test/provisioning/worker_auth.test.ts` fixture after the trusted-persisted-dispatch clarification; no implementation result is claimed.
- The full clarified carrier, identity, precedence, temporal-quadrant, timestamp, purity, and structural-proof contract forecasts **450–700 changed lines**, above hard maximum 399; the prior 195–337 forecast is superseded as forecast only, not historical evidence.
- One safe boundary is P3-B.2a-1: adapter-owned document-reference envelope plus valid/corrupt identity and precedence classification, forecast **240–355** including tests, records, and review margin. P3-B.2a-2 owns retained current temporal relations, all temporal stale quadrants, and timestamp failures after acceptance.
- Required vectors remain explicit in `tasks.md`: valid/corrupt document-reference identity; pending versus active; current retained and forks; all legal stale, future, mixed, unknown, boundary, same-version, and timestamp-failure rows; reflection/accessor failures; no competing predicate export; purity and no-write proof.
- Warning is 320, STOP is 380, and hard maximum is 399. The already-approved feature-branch-chain strategy is active; no chain-choice or ask-on-risk decision is pending. This documentation pass does not authorize implementation; parent routing may select P3-B.2a-1.
- Allowed future writer paths remain only `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `tasks.md`, and `apply-progress.md`; `boundaries.ts` stays unchanged and unimported. No store/Auth/audit writes, emulator, install, native operation, or delivery action ran.

## P3-B.2a-1 — Incomplete Verification Record

- Writer-provider usage limit interrupted verification; recovered evidence: genuine RED `runtime1/7 pass, 6 fail`, intermediate `6/7`, then GREEN `7/7`, with explicit and configured TypeScript both passing.
- Independent focused result: `7/7` pass; schemas `41/41` and outbox `20/20` pass.
- Mandatory audit regression failed after 46 assertions on the pre-existing `console.error` at `functions/src/provisioning/outbox_repair.ts:52`.
- Begin/current `outbox_repair.ts` blob `a6a63f6e49556d5368b0ad3d6c24fea594cd9d8e` and audit-test blob `cd94a252a5b645deead620e90bdf5d444b53297b` are identical.
- Source was untouched. The pre-note incremental count was 199 against native begin tree `45aa462823258a45a4173cd09c9d3f4363ca31d2` versus in-memory files; it is not a final/native charge.
- Selected tasks B.2a-1 and B.2a-2 are checked; B.2a-3 and B.2a-4 are pending. P3.5–P3.10 remain unchecked.
- No completion or all-green claim: temporal B.2a-2 is deferred. No emulator, install, delivery, token, native-settlement, or native-operation claim is made.

## P2 Outbox Repair Audit Telemetry Correction — BLOCKED

- **Authorized scope:** The user authorized only the preexisting audit-telemetry correction in `functions/src/provisioning/outbox_repair.ts` and `functions/test/provisioning/outbox_repair.test.ts`; this record and the matching concise tasks amendment preserve P2's frozen history, unrelated checks, and audit scanner without a design-wide override.
- **RED:** After replacing the console mock with a collecting required sink and an exact `createApplicationLog` expectation, `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/outbox_repair.test.ts"` exited 1 at `each failed record emits one required safe application log` (`0 !== 1`), while the preexisting `console.error` emitted two raw digest fields. This is a genuine behavioral RED through the Firestore emulator.
- **GREEN blocker:** The narrow production attempt used `createApplicationLog` with the required `{ eventCode: "stale-dispatch", resultCode: "failed", reasonCode: "unavailable" }` shape and injected sink, but the current frozen factory rejects it: `cd functions && node --experimental-strip-types --input-type=module -e '…createApplicationLog(…resultCode: "failed"…)…'` exited 1 with `invalid application log`. `CANONICAL_CODE_VALUES` admits neither `failed` nor another equivalent result literal. The attempted emulator GREEN therefore rejected before the held successful peer completed; source was restored to its captured pre-correction hash rather than leaving an invalid partial implementation.
- **Verification to date:** explicit NodeNext TypeScript for `audit.ts`, `outbox_repair.ts`, and both tests exited 0 while the temporary source contract existed; direct regressions passed: audit 39 + 7 + 53 assertions, schemas 28 + 13 assertions, outbox 20 assertions, and delivery identity 7/7. The mandatory audit regression remains red on the original `console.error`; it was not weakened or edited.
- **Required decision:** expand the allowed correction surface to the frozen `functions/src/provisioning/audit.ts` / `audit.test.ts` contract with an approved PII-safe representation for required `resultCode: "failed"`, or amend the required log shape. No P3-B.2a-1.3/.4 checkbox was checked; P3.5–P3.10 remain unchecked.
- **Cleanup and scope:** local Firestore emulator stopped after both runs; the session-created ignored `functions/firestore-debug.log` was removed, and no emulator listener remained. No install, config change, scanner weakening, staging, commit, delivery, reset, or settlement occurred.

## P2 Outbox Repair Audit Telemetry Correction — Complete

- **Runtime scope:** only `outbox_repair.ts` and `outbox_repair.test.ts` changed, plus the required task/progress records. The repair request now requires a typed `ApplicationLog` sink; each failed candidate emits exactly one `createApplicationLog` payload with `eventCode: "stale-dispatch"`, `resultCode: "internal"`, `reasonCode: null`, and SHA-256 digests tagged `provision-dispatch:v1` and `provision-audit:v1`.
- **Supersession:** the preceding blocked record and its `failed`/`unavailable` candidate remain historical evidence. That payload is superseded as noncanonical; no `audit.ts` or `audit.test.ts` change, scanner relaxation, raw error, raw identifier, or PII logging was introduced.
- **Behavior:** failed candidates remain eligible, peers finish, and the aggregate repair error is thrown after the bounded batch completes.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|
| P3-B.2a-1.3/.4 scoped telemetry correction | Firestore emulator exited 1 at the injected sink assertion (`0 !== 1`). | Same emulator command exited 0: 56 assertions. | Delivery identity 7/7; schemas 41; audit 99; outbox 20 all passed. | Explicit NodeNext and configured TypeScript passed; sole classifier export and unchecked P3.5–P3.10 were confirmed. |

### Verification and Completion

- `node --version` reported v24.20.0 and `java -version` reported Java 21.0.12 before both emulator runs.
- `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/outbox_repair.test.ts"` passed after GREEN; the emulator shut down normally.
- Completed persisted checkboxes: P3-B.2a-1.3 and P3-B.2a-1.4. P3-B.2a-2 retains temporal ownership; P3.5–P3.10 remain unchecked.
- **Workload / PR boundary:** P3-B.2a-1 correction only; no commit or PR was created. The baseline-relative scope is remeasured below the 320 warning and 380 STOP thresholds.
- Additional checks: `node --experimental-strip-types test/provisioning/worker_auth.test.ts`, `schemas.test.ts`, `audit.test.ts`, and `outbox.test.ts`; the explicit NodeNext check covered `audit.ts`, `outbox_repair.ts`, and both tests; configured `npx tsc --noEmit` also passed.
- **Line accounting:** baseline `f44a25ad4ac5808cf1ab43635c86dceac6d104d7` versus in-memory files: source 23, test 4, tasks 4, progress 29; total 60 changed lines (below warning 320).
- **Status consumed:** parent status named `prepare-public-portfolio-repository` as apply-ready in the explicit target worktree; action context was repo-local with that worktree as the sole allowed edit root and no warnings.
- **Remaining downstream unchecked tasks:**
  - [ ] P3.5 RED: worker acquisition and delivery classification — validate the full persisted dispatch source tuple, acquire/take over lease, and classify duplicate/out-of-order/orphan/terminal deliveries; stale deliveries mark only the dispatch where legal and return 2xx without advancing operation state.
  - [ ] P3.6 GREEN: acquisition passes.
  - [ ] P3.7 RED: Auth preflight — mandatory UID + email reads before any create; foreign UID/email before intent -> `failed/already-exists`; no Auth mutation.
  - [ ] P3.8 GREEN: preflight passes.
  - [ ] P3.9 RED: Auth intent — one transaction flips `authAttempted=true`, persists `authAttempt.result=intent`, audit, version, deterministic `auth_create` dispatch, and worker acknowledgement using P2 schemas; the full source tuple and current-dispatch fence are verified.
  - [ ] P3.10 GREEN: intent commit passes.

## P3-B.2a-2 — Temporal Classifier Planning Record

- **Status:** bounded planning only; no source/test/native/emulator/install/delivery change was made. P3-B.2a-1 identity and telemetry correction remain historical completed prerequisites; prior correction evidence is referenced only by `sha256:51175ef4c5c61652f552e5a21cf8de7ea86fd988008b90b3c5abbac3412b29c9`.
- **Owned paths:** `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `tasks.md`, and this record. `boundaries.ts` remains unchanged and unimported.
- **Temporal authority:** exact pending initial is `eligible`; exact active current and retained current `dg=og,sv<ov` or `dg<og,sv<ov` are `eligible`; noncurrent legal earlier quadrants are `stale_eligible`; pending stale, future/impossible/mixed/unlisted quadrants, forks, wrong phase/boundary, and out-of-lifetime timestamps are `mismatch`. Existing terminal-before-duplicate precedence remains unchanged.
- **Forecast:** worker `70–102`, worker test `146–200`, tasks `12–18`, this record `10–15`, reserved refactor/review margin `12–18`; total **250–353** changed lines. Warning `320`, STOP/reforecast `380`, hard maximum `399`; approved strategy is feature-branch-chain with no size exception.
- **Required commands after apply:** `cd functions && node --version`; `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`; `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/worker.ts test/provisioning/worker_auth.test.ts`; `cd functions && npx tsc --noEmit`; and the exact direct regressions `cd functions && node --experimental-strip-types test/provisioning/schemas.test.ts`, `cd functions && node --experimental-strip-types test/provisioning/audit.test.ts`, and `cd functions && node --experimental-strip-types test/provisioning/outbox.test.ts`.
- **Verification boundary:** pure temporal logic only; no Firestore emulator, Java, persistence, acknowledgement, stale audit, lease, Auth, or P3.5–P3.10 completion. Rollback is limited to this temporal worker/test extension and these two planning records.

## P3-B.2a-2 — Temporal Classifier Applied

| Task | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|
| P3-B.2a-2.1–.4 | Recovered: direct worker harness 6/8 pass, 2 fail before temporal implementation. | Direct Node 24 worker harness 8/8 pass after source change. | Added pending boundary/generation/sourceVersion and active 3×3 generation/version current/noncurrent vectors; 8/8 remained green. | One classifier export; no `boundaries` import; tracked/untracked diff checks pass. |

- Commands passed (Node v24.20.0): `node --experimental-strip-types test/provisioning/worker_auth.test.ts` (8/8); `npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/worker.ts test/provisioning/worker_auth.test.ts`; `npx tsc --noEmit`; and direct `schemas.test.ts` (41), `audit.test.ts` (99), `outbox.test.ts` (20).
- Completed persisted checkboxes: P3-B.2a-2.1–.4. Pure classifier only: no Firestore, acknowledgement, audit, lease, Auth, SDK, emulator, or P3.5–P3.10 work.
- Baseline `4cac4d2664d1fcfdc638bd86e048d54594418e21`; rollback reverts only temporal worker/test changes and these two artifacts. No process was started, so no cleanup was needed.

## P3-B.2b-pre — Audit Read Port Prerequisite Applied

**Status:** implemented under Strict TDD. `readAudit(eventId)` reads only `provisioningAudit/{eventId}` through the worker transaction; it returns the stored record or `null`, propagates transaction-read errors, and has no write path. No stale acknowledgement, audit creation, worker change, acquisition, Auth, or runtime-composition claim was added.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| P3-B.2b-pre.1 | `functions/test/provisioning/worker_auth.test.ts` | Unit / emulator adapter | Existing worker harness: 8/8 passed | Explicit NodeNext check failed with `TS2339: Property 'readAudit' does not exist on type 'WorkerTransaction'`; direct runtime was separately blocked by existing parameter-property syntax, not counted as behavioral RED. | N/A — RED task | Fake record/absence and rejecting-`get` vectors were authored before source changes. | N/A |
| P3-B.2b-pre.2–.4 | `functions/test/provisioning/worker_auth.test.ts` | Unit + Firestore emulator | Same 8/8 baseline | Retained explicit missing-port RED | Direct harness: 10 pass, 1 emulator-only skip; explicit and configured TypeScript passed. | Firestore emulator: 11/11 pass, including existing/absence; injected audit `get` failure propagated with zero writes. | Scoped diff check passed; no refactor beyond the required syntax conversion. |

### Work Unit Evidence

- **Completed persisted checkboxes:** P3-B.2b-pre.1, P3-B.2b-pre.2, P3-B.2b-pre.3, and P3-B.2b-pre.4 are marked `[x]` in `tasks.md`; P3.5–P3.10 remain unchecked.
- **Commands passed:** Node `v24.20.0`; Java `21.0.12`; direct worker harness (10 pass, 1 skip); `./node_modules/.bin/firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` (11/11); explicit NodeNext source/test check; configured `./node_modules/.bin/tsc --noEmit`; direct `schemas.test.ts` (28 operation + 13 dispatch assertions), `audit.test.ts` (39 schema + 7 dedup + 53 log-safety assertions), and Firestore-only `outbox.test.ts` (20 assertions). The local Firebase CLI was used; no Functions emulator or install was needed.
- **Failure proof:** the injected transaction rejects only the audit read after the clock read; its test asserted both read paths and zero `set`/`create` calls. The emulator test separately asserted the persisted existing record, a missing record as `null`, and unchanged existing audit data.
- **Files changed:** `functions/src/provisioning/boundaries.ts`, `functions/test/provisioning/worker_auth.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this append-only record. `worker.ts` was not changed.
- **Workload / PR boundary:** feature-branch-chain child prerequisite only; no commit or PR was created. Independent in-memory comparison against native begin tree `6a76159b1dd412ebaccd8bada6029c3284d9c27f` yields 19 source changes (16 additions, 3 deletions) and 109 test additions; with 8 task changes and 21 progress additions, the baseline-relative total is 157 changed lines. This supersedes the writer's non-reproducible 163-line count and is 22 above the 95–135 forecast but below warning 320, STOP 380, and hard maximum 399; the excess is necessary for independent fake, injected-failure, and real-emulator assertions, not code-golf candidate material.
- **Progress integrity:** pre-append `apply-progress.md` was 159,071 bytes with SHA-256 `90eda4516614d922ab4bb246be3eae5b7c9bba5bd68b413c94ce9ca6f0536b6c`; this record was appended only. Rollback removes only the port/adapter conversion, its test vectors, these four checkbox updates, and this appended section.
- **Status consumed:** parent-authoritative `prepare-public-portfolio-repository` apply-ready status for `<workspace-root>`; `actionContext.mode=repo-local`, sole allowed root was that worktree, and no action-context warning was present.

## P3-B.2b-2 — Interrupted Apply Evidence (blocked)

- **Status:** blocked before task completion. The persisted P3-B.2b-2.1–.4 checkboxes remain unchecked; no task completion is claimed.
- **Status consumed:** parent-authoritative `prepare-public-portfolio-repository` apply-ready status for this worktree; `actionContext.mode=repo-local`, sole allowed root was this worktree, with no warnings.
- **TDD:** safety-net direct worker harness passed 10/10 with one pre-existing emulator-only skip. RED was genuine: importing `acknowledgeStaleDelivery` failed because `worker.ts` exported no such member. GREEN: direct harness passed 13/13 with three emulator-only skips and explicit NodeNext TypeScript passed.
- **Partial candidate:** trusted transaction rereads dispatch then operation, classifies, reads audit before writes, derives the accepted 14-field event, and writes only stale acknowledgement plus create-if-absent audit. Fake vectors cover the exact audit, no-write classifications, conflicting audit, injected create failure rollback, and replay.
- **Blocking evidence:** the Firestore emulator passed 15/16 tests, including real concurrent duplicate convergence, but the required deliberate conflicting-audit creation after trusted reads failed twice with `3 INVALID_ARGUMENT: Transaction is invalid or closed`. The Firebase transaction API/emulator rejects the attempted externally coordinated write while the transaction callback is held; no fake commit hook was substituted.
- **Stop rule:** one corrective retry for that same real-emulator coordination failure was exhausted. Do not mark GREEN/TRIANGULATE/REFACTOR complete or weaken the real-race requirement without a maintainer-approved alternative coordination mechanism.
- **Cleanup:** both Firestore emulator invocations shut down; the session-created ignored `functions/firestore-debug.log` was removed. No install, config, staging, commit, native acquisition/reset/settlement, Auth, lease, profile, deployment, or operation/version mutation occurred.
- **Workload / PR boundary:** partial P3-B.2b-2 feature-branch-chain slice; current source/test delta is 342 lines by retained in-memory baseline (worker +76, worker test +266), before this append and with no task-record delta. It is below STOP 380 and hard maximum 399, but incomplete.
- **Remaining unchecked implementation tasks:**
  - [ ] P3-B.2b-2.1 RED: author fake and REAL Firestore vectors before source changes for trusted rereads, classifier rerun, legal `null→stale`, all 14 audit fields/IDs, all-reads-before-writes, every no-write classification, conflicting audit, injected failures, atomic rollback, replay, and coordinated concurrency. <!-- sdd-owner: implementation -->
  - [ ] P3-B.2b-2.2 GREEN: implement only the transaction stale-ack path in `worker.ts`/`boundaries.ts`; use the existing store/transaction ports and transaction `now`, derive every field from trusted rereads, and add no competing classifier, caller override, acquisition, or Auth. <!-- sdd-owner: implementation -->
  - [ ] P3-B.2b-2.3 TRIANGULATE: in this same unit, run the fake and REAL Firestore harness for all acceptance vectors; coordinate competing audit creation after reads, prove the loser sees the audit-create conflict, retries, and commits no partial stale ack, and prove one acknowledgement/one audit, unchanged operation/version, no external effects, and idempotent replay. No fake commit hook substitutes for emulator proof. <!-- sdd-owner: implementation -->
  - [ ] P3-B.2b-2.4 REFACTOR: gate Node 24 and Java 21, run the exact typecheck, emulator, three direct regressions, and full-path scoped diff check below; preserve broader P3.5–P3.10 and historical checkboxes as unchecked. <!-- sdd-owner: implementation -->

## P3-B.2b-2 — Coverage Repair Complete

### TDD Cycle Evidence

| Task | RED | GREEN / TRIANGULATE / REFACTOR |
|---|---|---|
| P3-B.2b-2.1–.4 | Historical emulator RED (`Transaction is invalid or closed`) is immutable and was not rerun. | New real precondition assertion passed first on unchanged production; direct harness 13 pass/3 emulator skips and Firestore emulator 16/16, then both TypeScript checks, schemas 41, audit 99, outbox 20, and diff check passed. |

- **Completed persisted tasks:** P3-B.2b-2.1–.4 are `[x]`; P3.5–P3.10 remain unchecked.
- **Coverage:** real adapter `writeDispatch` then `createAudit` without `readAudit` receives Firestore code 6 `ALREADY_EXISTS` and preserves dispatch, operation, and audit bytes; retained `Promise.all` proves worker replay convergence.
- **Scope / workload:** test plus targeted design/spec/tasks records only; no production change, no install, config, deploy, or native action; feature-chain child remains below the 399-line hard limit.
- **Progress integrity:** pre-append bytes `166869`, SHA-256 `cfe30316811d042f96f62e64a042230e2fab19c778bdcf7abc2d452ba5c4d054`; original prefix verified unchanged before this append.
- **Status:** parent supplied apply-ready `prepare-public-portfolio-repository`; repo-local target root had no action-context warnings.
## P3-B.2c-pre — StrictWorkerStore Create Prerequisite Applied
| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
| P3-B.2c-pre.1–.4 | `functions/test/provisioning/worker_auth.test.ts` | Unit, strict fake | 13 pass/3 emulator skips | 3 new vectors failed against `not expected` | 16 pass/3 skips | success, duplicate preservation, and later-failure rollback | focused harness plus both TypeScript checks pass |
- **Completed checkboxes/status:** P3-B.2c-pre.1–.4 are `[x]`; parent status was apply-ready, `repo-local` at the sole allowed root, with no action-context warnings.
- **Verification:** Node `v24.20.0`, Java `21.0.12`, direct worker harness (16 pass, 3 existing emulator skips), explicit NodeNext, and configured `tsc --noEmit` passed; no emulator ran.
- **Files/scope:** only the strict fake and focused vectors in `worker_auth.test.ts`, these four task checkboxes, and this append changed; stale-audit regressions stay green, and no production, acquisition, takeover, Auth, or runtime claim changed.
- **Workload / PR boundary:** feature-branch-chain child `p3b2c-pre-strict-dispatch-create`; native-begin comparison is 69 additions/1 deletion in the test, 4/4 in tasks, and this 8-line evidence append (86 changed lines), above forecast 42–72 but below 399 without code-golf.
- **Integrity/evidence:** native begin `0486c968933bd25a535529c0170b7e8cbfbca423` prefix was byte-identical before append; test evidence SHA-256 is `f52a4243d75dd19007e490b5f53941c89d0018208adffc96a3065fc72cf8beb6`; no process was started, so cleanup was unnecessary.

## P3-B.2c-pre-payload-contract — Persisted-19 Reducer Repair
- **Completed checkboxes:** P3-B.2c-pre-payload-contract.1–.4 are `[x]`; acquisition and broader P3 tasks remain unchecked.
- **TDD:** RED was genuine: model test failed `P3-B.2c persisted 19-field pending state accepted`; GREEN passed after model-only persisted typing/validation.
- **TRIANGULATE:** persisted pending→active→auth intent retains the 19-field payload and fingerprint; transient `displayName` is rejected; worker active fixture is persisted-19.
- **REFACTOR / scope:** one `PERSISTED_PAYLOAD_KEYS` ownership marker remains; no coverage or behavior outside `model.ts` changed; no emulator, install, acquisition/takeover, Auth, profile assembly, normalization, hashing, submission, or profile code changed.
- **Verification:** Node v24.20.0, Java 21.0.12, focused model/worker/schemas/profile tests, explicit NodeNext, and configured TypeScript checks passed; emulator-only tests were skipped by absent emulator host.
- **Workload / PR boundary:** feature-branch-chain child `p3b2c-pre-persisted-payload`; no commit, native settlement, or process cleanup was required.

## P3-B.2c-A — Unit A Strict-Fake Candidate (partial)
| Task | Test file | Layer | RED | GREEN | TRIANGULATE | REFACTOR |
| P3-B.2c-A.1–.4 | `worker_auth.test.ts` | strict fake | missing export exit 1 | 21 pass / 3 skip | fences, replay, rollback | focused TypeScript clean |
- **Status:** no Unit A checkbox is marked complete because a required inherited regression failed.
- **Focused evidence:** Node v24.20.0 and Java 21.0.12 gates passed; direct worker harness passed 21 tests with 3 expected emulator skips.
- **TypeScript:** explicit NodeNext worker-plus-test command passed after the Green correction.
- **Regression blocker:** schemas, audit, and outbox passed; `store_conformance.test.ts` failed 3 inherited `Invalid initial operation state` cases, so `memory_store.test.ts` and configured TypeScript remain unrun.
- **Scope/workload:** only Unit A `worker.ts`, strict-fake vectors, and this append changed; native-begin delta is 248 additions/5 deletions before this 9-line append, below the 320 review warning.

## P3-B.2c-A — Bounded Fake-Coverage Correction (partial)
| Task | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|
| Unit A constructor repair + absent-read/create conflict | `store_conformance` 1/4 and `memory_store` 0/1 failed `Invalid initial operation state`; new strict-fake assertion genuinely failed `Missing expected rejection`. | Persisted-19 constructors and the test-only post-absent-read create-conflict wrapper yield store 4/4, memory 1/1, and worker 22 pass/3 emulator-only skips. | Normal create-if-absent and injected post-read create conflict independently preserve rollback; schemas, audit, outbox, model, explicit NodeNext, and configured TypeScript pass. |
- **Scope:** user-authorized only `store_conformance.test.ts` and `memory_store.test.ts` constructor repairs plus `worker_auth.test.ts` fake coverage; `worker.ts` and all production files remained unchanged.
- **Accounting:** native-begin `3e389c2237054c5d4aefd710579b92c563476f06` comparison before this 9-line append was +296/-9 = 305 across all six allowed paths; progress prefix SHA-256 was `0df85f43434eb31cdfcf8b6ceb6a89923384d3cf0d618e8c6522864f8625f388`.
- **Cleanup:** no install, emulator, staging, commit, reset, native settlement, or long-lived process occurred; Unit B remains pending.
- **TDD decision:** current constructor and wrapper REDs are genuine, but the historical acquisition missing-export RED is recorded only and cannot be independently re-observed; no P3-B.2c-A checkbox is marked complete.

## P3-B.2c-A — Accepted A-Only Disposition
- Maintainer accepted the historical missing-export compilation RED deviation; no behavioral RED is claimed or fabricated.
- Independent verification passed 7 regressions, 2 TypeScript checks, worker 22 pass/3 skip, store 4/4, and memory 1/1.
- Candidate accounting was 314 pre-disposition lines; no budget exception applies.
- Unit B remains pending and must execute all REAL rollback, concurrency, and replay proof.

## P3-B.2c-B — Blocked Before Apply
- **Status consumed:** native `applyState: blocked`, authoritative OpenSpec, repo-local exact root, no action-context warning.
- **Integrity:** pre-append 173943-byte prefix SHA-256 was `8cea91f6237b493d3c3f6defc0b1a9f305add2b01e1dfffce21b9b15c755d8a0`.
- **Blocker:** four completed Unit A task rows have non-terminal `sdd-owner` markers containing `; historical RED deviation accepted`.
- **No Unit B execution:** no tests, emulator, source/test/spec/design/task edits, installs, staging, commits, or production changes occurred.
- **Task state:** all four Unit B implementation checkboxes remain visibly unchecked; malformed A markers were left unchanged.
- **Next action:** correct the four ownership markers to terminal `<!-- sdd-owner: implementation -->`, rerun native status, then authorize Unit B.

## P3-B.2c-B — REAL Firestore Acquisition Acceptance
- **Completed checkboxes:** P3-B.2c-B.1–.4 are `[x]`; full acquisition is technically B-verified only, with broader P3 still unchecked and no native settlement.
- **TDD honesty:** four emulator-gated acceptance vectors were authored before any remediation; unchanged Unit A passed first execution, so this is characterization GREEN, not a fabricated behavioral RED.
- **Safety net:** corrected focused Node command passed 22/25 with 3 expected emulator skips; an initial wrong-root invocation failed only with `MODULE_NOT_FOUND` and made no change.
- **REAL evidence:** local demo-project Firestore emulator passed 29/29, including concurrent pre-start-barrier `Promise.all` convergence, matching-audit timestamp preservation, processed replay stability, and code-6 atomic rollback.
- **Regression / types:** explicit NodeNext and configured TypeScript checks passed; schemas 41, audit 46, outbox 20, store conformance 4/4, and memory store 1/1 passed.
- **Scope / integrity:** only `worker_auth.test.ts`, four B checkboxes, and append-only evidence changed; all six production provisioning files hash-match native begin.
- **Workload / boundary:** feature-branch-chain child `p3b2c-b-real-acquisition-proof` remains below 320 warning and 399 hard limit; no production, rules, mode, config, install, commit, deploy, or native action.
- **Cleanup:** `emulators:exec` shut down Firestore/hub/logging processes; preexisting-or-unproven `functions/firestore-debug.log` was hashed and deliberately preserved.

## P3 Ordinary Takeover Unit — Applied

**Status:** Strict-TDD ordinary normal-work takeover only. The implementation is deliberately not a completion claim for P3.5/P3.6, and it does not alter the separate P3.29/P3.30 reserved-attempt terminalization boundary.

### TDD Cycle Evidence

| Task | Test file | Layer | Safety net | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|---|---|---|
| Ordinary expired-current takeover | `functions/test/provisioning/worker_auth.test.ts` | Strict fake + Firestore emulator | Direct worker harness: 22 pass, 7 emulator skips | Direct harness exited 1: missing `takeoverExpiredCurrent` export; new strict-fake and REAL takeover vectors were authored before source. | Direct harness exited 0: 26 pass, 8 emulator skips. | Emulator exited 0: 35/35, including one winner, matching audit timestamp, replay, and conflict rollback. | Configured TypeScript and scoped diff check passed; no scope widening. |

### Evidence and Boundary

- The transaction rereads the trusted current source and operation, feeds the full eight-field observed tuple to the pure `takeover` reducer, writes only the operation plus first-insert audit, then internally rereads and returns the verified operation/source tuple.
- The source dispatch remains byte-identical and unacknowledged; no next dispatch, Auth/profile action, terminalization, or later phase transition is created.
- Repeated expiry of the retained source derives generation, owner token, and audit identity from the latest operation tuple; a matching audit preserves its first-insert timestamp and an audit conflict rolls back atomically.
- Workload / PR boundary: approved feature-branch-chain ordinary-takeover child only. P3.5/P3.6 and P3.29/P3.30 remain visibly unchecked.
- Status consumed: authoritative OpenSpec `applyState=ready`; `actionContext.mode=repo-local`; allowed root was this worktree; no action-context warning. Parent retained attempt settlement and delivery.

### Verification and Accounting

- `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`: exit 0; 26 pass, 9 emulator-only skips.
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"`: exit 0; 35/35 pass.
- `cd functions && npx tsc --noEmit`: exit 0.
- `git diff --check -- functions/src/provisioning/worker.ts functions/test/provisioning/worker_auth.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md`: exit 0.
- Captured pre-edit scoped line baseline to current bytes: `worker.ts +82/-0`, `worker_auth.test.ts +155/-0`, `tasks.md +6/-0`, `apply-progress.md +27/-0`; total **+270/-0 = 270**. This is below warning 320, STOP 380, and hard 399. The untracked code paths have no Git tree blob, so parent-owned attempt settlement must reconcile this captured baseline with its provider-issued native tree.
- Remaining unchecked implementation lines include `- [ ] P3.5 RED: worker acquisition and delivery classification — validate the full persisted dispatch source tuple, acquire/take over lease, and classify duplicate/out-of-order/orphan/terminal deliveries; stale deliveries mark only the dispatch where legal and return 2xx without advancing operation state.`, `- [ ] P3.6 GREEN: acquisition passes.`, `- [ ] P3.29 RED: active with expired lease — first transaction requires full observed expired tuple, increments generation + version, installs new owner token + live lease; same invocation applies complete active terminalization guard using the exact new tuple.`, and `- [ ] P3.30 GREEN: expired-lease takeover passes.`


## P3.5–P3.6 — Full Dispatch Tuple and Lease Gate (blocked verification)

**Status:** Strict-TDD RED and focused GREEN evidence were captured, but final acceptance is blocked because the required configured `flutter test` runner cannot start from this Linux environment. P3.5 and P3.6 remain unchecked.

### TDD Cycle Evidence

| Cycle | Command | Result |
|---|---|---|
| RED | `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` | Exit 1: new `TK-FENCE` owner-seed-drift vector observed an unauthorized takeover. |
| GREEN | `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` | Exit 0: 26 pass, 9 emulator-only skips after the trusted owner-seed fence. |
| TRIANGULATE | `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` | Exit 0: 35/35 pass, including acquisition, stale-delivery, and takeover Firestore vectors; the emulator shut down cleanly. |
| REFACTOR | `cd functions && npx tsc --noEmit --project tsconfig.json` | Exit 0. Scoped `git diff --check` passed. |

- Required configured runner: `flutter test` exited 127 before test discovery: `/mnt/c/flutter/bin/flutter` has CRLF script line endings and `/usr/bin/env` rejected `bash\\r`. This is an environment/toolchain blocker, not a source assertion failure.
- Files changed: `functions/src/provisioning/worker.ts` adds an expired-takeover owner-seed derivation fence; `functions/test/provisioning/worker_auth.test.ts` derives canonical active owner seeds and proves seed drift causes no write. No task checkbox was changed.
- Status consumed: `gentle-ai.sdd-status` v2, `prepare-public-portfolio-repository`, apply ready, repo-local allowed root `<workspace-root>`; no action-context warning.
- Workload / PR boundary: P3.5–P3.6 only; no commit, stage, push, review, or deployment. The runtime attempt binding was supplied by the parent; no acquire, reset, rescope, supersede, or settlement was run.
- Remaining implementation tasks: `- [ ] P3.5 RED: worker acquisition and delivery classification — validate the full persisted dispatch source tuple, acquire/take over lease, and classify duplicate/out-of-order/orphan/terminal deliveries; stale deliveries mark only the dispatch where legal and return 2xx without advancing operation state.` and `- [ ] P3.6 GREEN: acquisition passes.`
- Settlement-ready diagnosis: focused Functions evidence is green, but final required Flutter verification is blocked by the CRLF Flutter launcher. Cleanup/process evidence: `emulators:exec` exited 0 and stopped Firestore, hub, and logging processes; no native settlement was performed.


## P3.5–P3.6 — Corrective Gatekeeper Acceptance

**Status:** accepted for this Functions-only slice. This correction explicitly remediates the prior blocked evidence revision `sha256:a4e0af0d33afb8ac60263fdc25876d0df15bcf48bd5dc56f658a569dfa2052cd`; P3.5 and P3.6 are persisted as complete. No P3.7+ task changed.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | The prior genuine `TK-FENCE` owner-seed-drift RED remains preserved: direct worker harness exited 1 before the source fence. |
| GREEN | `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` exited 0: 26 pass, 9 emulator-only skips. |
| TRIANGULATE | `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` exited 0: 35/35 pass, including stale acknowledgement, acquisition one-winner/replay/rollback, and expired-takeover vectors. |
| REFACTOR | `cd functions && npx tsc --noEmit --project tsconfig.json` and the exact scoped `git diff --check` both exited 0. |

- Acceptance coverage: trusted persisted dispatch/document/operation identity, duplicate/out-of-order/orphan/terminal precedence, legal stale dispatch-only acknowledgement with unchanged operation, atomic initial acquisition, and expired-current takeover fencing are green in direct and real Firestore adapter runs.
- Required `flutter test` was re-run and exited 127 before test discovery with the known environmental failure `/usr/bin/env: ‘bash\\r’: No such file or directory` from `/mnt/c/flutter/bin/flutter`. The independently diagnosed CRLF launcher/WSL cwd incompatibility is not a project Flutter test or Functions source failure and is excluded from this Functions-only acceptance decision.
- Persisted task update: P3.5 and P3.6 are `[x]`; exact remaining downstream boundary begins `- [ ] P3.7 RED: Auth preflight — mandatory UID + email reads before any create; foreign UID/email before intent -> `failed/already-exists`; no Auth mutation.`
- Files changed in the accepted candidate remain `functions/src/provisioning/worker.ts` and `functions/test/provisioning/worker_auth.test.ts`; this correction changed only P3.5/P3.6 task checkboxes and this append. No source/test modification was required by the rerun.
- Workload / PR boundary: P3.5–P3.6 Functions-only feature-chain slice; no stage, commit, push, review, deployment, or P3.7+ mutation.
- Runtime/process cleanup: `emulators:exec` exited 0 and stopped Firestore, hub, and logging processes. Native authority was parent-bound; this executor performed no acquire, reset, rescope, supersede, or settlement.
- Settlement-ready diagnosis: acceptance checks passed; the only non-green command is the known pre-discovery Flutter launcher environment failure, not a candidate defect. Parent retains the opaque attempt token and must supply any native evidence-revision value for settlement.

## P3.7–P3.8 — Auth Preflight

**Status:** completed under Strict TDD. `preflightAuth` reads the intended UID and normalized email indexes before any future Auth-create boundary. Either foreign identity transitions the operation to `failed/terminal` through the pure reducer; no Auth creation, dispatch acknowledgement, audit, or profile mutation occurs.

### TDD Cycle Evidence

| Cycle | Command | Result |
|---|---|---|
| RED | `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` | Exit 1: `worker.ts` did not export `preflightAuth`. |
| GREEN | Same direct Node command | Exit 0: 29 pass, 9 emulator-only skips; new absent, UID-foreign, email-foreign, and read-error vectors pass. |
| TRIANGULATE | `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` | Exit 0: 38/38 pass. |
| REFACTOR | `cd functions && npx tsc --noEmit --project tsconfig.json` | Exit 0. |

- **Persisted task updates:** P3.7 and P3.8 are `[x]`; P3.9 and later implementation rows remain unchecked.
- **Files changed:** `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `tasks.md`, and this append-only record.
- **Configured runner:** `flutter test` exited 127 before discovery with `/usr/bin/env: ‘bash\\r’: No such file or directory` from `/mnt/c/flutter/bin/flutter`; this is the independently established CRLF/WSL launcher failure, not a Flutter or Functions test failure.
- **Workload / PR boundary:** P3.7–P3.8 Functions-only feature-chain slice; no stage, commit, push, review, deploy, install, or P3.9+ mutation.
- **Status/action context:** consumed parent native `gentle-ai.sdd-status` v2 (`applyState: ready`), repo-local root `<workspace-root>`, no action-context warning; continuing active attempt token `sha256:bb1f4733c7ff5985897eece3e4b5b6865fcf157ee417c3311fb0757323e927c1` acquired as `proceed`.
- **Settlement-ready diagnosis:** focused Node, Firestore emulator, and configured TypeScript checks passed. The only non-green command is the known Flutter launcher pre-discovery failure. **Cleanup/process evidence:** `emulators:exec` exited 0 and stopped Firestore, hub, and logging processes. Do not settle from this executor.

## P3.9–P3.10 — Atomic Auth Intent

**Status:** implemented under Strict TDD. `persistAuthIntent` performs the one `auth_preflight` source transaction that writes the reducer-produced intent state, P2-valid deterministic `auth_create` dispatch, `progress/auth_intent` audit, and `processed` acknowledgement together. It performs no Auth mutation.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|
| P3.9 RED | Added `persistAuthIntent` import plus atomic fake-vector tests before production implementation; `node --experimental-strip-types test/provisioning/worker_auth.test.ts` exited 1 because `worker.ts` did not export `persistAuthIntent`. | N/A | Source/current-dispatch fence, audit conflict, next-dispatch conflict, matching-audit timestamp retention, and processed replay vectors pass. | Focused Node, Firestore emulator, configured TypeScript, and scoped whitespace checks recorded below. |
| P3.10 GREEN | The P3.9 missing-export failure remains the authentic RED. | The focused Node harness exits 0: 32 pass, 10 emulator-gated skips. | Firestore emulator exits 0: 42/42 pass, including `REAL-INTENT`. | The first emulator attempt exposed an expired historical fixture lease rather than production behavior; the REAL test now seeds a 60-second live lease and the single corrective rerun passes. |

### Verification

- `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` → exit 0; 32 passed, 10 Firestore-gated tests skipped.
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` → exit 0; 42/42 passed, including the real Auth-intent transaction.
- `cd functions && npx tsc --noEmit --project tsconfig.json` → exit 0.
- `flutter test` → exit 127 before test discovery: external `/mnt/c/flutter/bin/flutter` has a CRLF `bash\r` launcher and cannot run from this WSL UNC worktree. This is an environmental Flutter launcher failure, not a Functions test failure, and is non-blocking for this Functions-only slice.

### Scope and delivery

- Changed paths: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `openspec/changes/prepare-public-portfolio-repository/{tasks.md,apply-progress.md}`.
- No deviation from the accepted Auth-intent design; the REAL-test fixture uses a live lease because the emulator transaction clock is current while historical fixture timestamps are not.
- PR boundary: one Functions-only atomic Auth-intent work unit; no Flutter, Auth create, profile, retry, deployment, or P3.11+ behavior was changed.
- Status consumed: `gentle-ai.sdd-status` v2, `applyState: ready`, `nextRecommended: apply`, repo-local action context with workspace root `<workspace-root>` and the supplied allowed root. No action-context warning occurred.
- Remaining implementation begins with exact unchecked line: `- [ ] P3.11 RED: Auth create boundary — CAS to \`call_started\`; call create once; exact return + UID/email reads + proof commit -> \`profile_commit\`; malformed/ambiguous/timeout/crash -> \`manual_recovery\` (no delete); definite no-effect -> back to \`auth_preflight\`.`
- Settlement-ready (not settled): passed diagnosis is that focused and Firestore-emulator evidence prove the atomic intent transaction; cleanup evidence is that the Firebase emulator reported orderly Firestore/hub/logging shutdown; process evidence is the completed `firebase emulators:exec` exit-0 run. No acquire, settle, reset, commit, staging, push, or deployment was performed by this slice.


## P3.11–P3.12 — Auth Create Boundary

**Status:** completed under Strict TDD. `createAuthUser` first CAS-transitions an `intent` to persisted `call_started`, then invokes the narrow Auth create boundary once. A matching exact create return plus mandatory UID and email index reads commits immutable proof and a deterministic `profile_commit` dispatch. Persisted call-start, malformed return, read mismatch, and thrown timeout route to `manual_recovery`; no delete boundary exists or is invoked. The explicit `definite_no_effect` outcome returns to `auth_preflight` with a new deterministic dispatch.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|
| P3.11–P3.12 | `node --experimental-strip-types test/provisioning/worker_auth.test.ts` exited 1 because `worker.ts` did not export `createAuthUser`; this was after replacing a test-only strip-types-incompatible parameter-property fixture. | Same command exited 0 with 36 pass / 10 emulator skips after the boundary, source-ack, audit, and dispatch implementation. | Added a thrown-timeout vector: one create call only, then `manual_recovery`; malformed return, read mismatch, persisted call-start crash recovery, and definite-no-effect vectors also pass. | Final direct run: 37 pass / 10 emulator skips; configured TypeScript and scoped whitespace checks pass. |

### Verification and Scope

- `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` → exit 0; 37 pass, 10 Firestore-gated skips.
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` → exit 0; 47/47 pass. One earlier invocation hit the pre-existing stale-delivery concurrency flake (`Transaction is invalid or closed`); the single permitted retry passed and shut down Firestore, hub, and logging processes cleanly.
- `cd functions && npx tsc --noEmit --project tsconfig.json` → exit 0.
- `flutter test` → exit 127 before discovery because `/mnt/c/flutter/bin/flutter` has a CRLF `bash\r` launcher; this is the known environment failure, not a project-test failure.
- Scoped `git diff --check` over the five authorized paths → exit 0.
- Persisted task updates: P3.11 and P3.12 are visibly `[x]`; P3.13+ remains untouched.
- Files changed: `functions/src/provisioning/boundaries.ts`, `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this append-only record.
- Workload / PR boundary: one Functions-only feature-chain P3.11–P3.12 child. Baseline-relative line accounting is unavailable from `git diff --numstat` because all three provisioning code paths are pre-existing untracked candidate files; no size exception is claimed. No commit, stage, push, review, deployment, install, or Flutter edit occurred.
- Status/action context: consumed native `gentle-ai.sdd-status` v2, apply ready, repo-local root `<workspace-root>`, with that root as the allowed edit surface and no warning. Continuing acquire token `sha256:99396aacab8cfd21c9b0ad5739897c6c9369c1fc4016ff4cee6b3bf27e01e0ea` returned `proceed`; no settlement was performed.
- Remaining implementation begins with exact unchecked lines: `- [ ] P3.13 RED: profile_commit boundary — requires persisted Auth proof + mandatory matching UID/email reads; one transaction creates/verifies operation-matching profile + \`completed/terminal\` + \`success.completed\` audit + current ack; all-or-nothing.` and `- [ ] P3.14 GREEN: profile_commit passes; conflicting profile -> \`manual_recovery\`; no deletion.`
- Settlement-ready diagnosis: focused direct, emulator, and TypeScript evidence pass; Flutter did not reach discovery because of the known CRLF launcher. Cleanup/process evidence: the successful `emulators:exec` invocation stopped Firestore, hub, and logging processes. Do not settle from this executor.

## P3.11 Auth Create Boundary — Failed-Evidence Remediation

**Status:** completed under Strict TDD as a bounded correction of failed evidence `sha256:fc0b45d567d8c3bbb856c76967db665236fc971f46e4e4a7286c03c9e300b7b6`. P3.11 and P3.12 were already visibly persisted as `[x]`; P3.13+ remains untouched.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | The retained Firestore concurrent stale-delivery failure was `INVALID_ARGUMENT: transaction invalid or closed`; a deterministic code-3 closed-transaction replay vector failed before the retry boundary. A newly authored null `AuthCreator.createUser` runtime-output vector failed with `TypeError` outside classification. |
| GREEN | `acknowledgeStaleDelivery` retries exactly one code-3 closed transaction; `createAuthUser` structurally validates runtime output and routes malformed output to `manual_recovery`. Direct worker harness: 39 pass, 10 emulator-gated skips. |
| TRIANGULATE | Null, null identity, and unknown-kind output vectors each route to `manual_recovery` with one create call. Firestore emulator: 49/49, including concurrent stale replay and atomic create-precondition rollback. |
| REFACTOR | Explicit source+test and configured TypeScript checks, schemas (41), audit (99), outbox (20), and scoped diff check all passed. |

### Verification and Scope

- Commands passed: `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`; `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"`; explicit NodeNext TypeScript for worker, boundaries, and worker test; and configured `npx tsc --noEmit --project tsconfig.json`.
- Firestore process evidence: `emulators:exec` exited 0 and stopped Firestore, hub, and logging processes.
- Regression commands passed: direct `schemas.test.ts` (41 assertions), `audit.test.ts` (99 assertions), and `outbox.test.ts` (20 assertions).
- Files changed: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, and this append-only record. No task checkbox changed because P3.11/P3.12 were already `[x]`; no P3.13+ row changed.
- Workload / PR boundary: `p3-11-auth-create-boundary` remediation only. No commit, stage, push, PR, deployment, reset, rescope, or supersession occurred. Git cannot measure the existing untracked provisioning files against a tree blob; this correction is limited to the two behavioral fixes and evidence.
- Status consumed: native `gentle-ai.sdd-status` v2, apply ready, repo-local root `<workspace-root>`, with that root as the sole allowed edit root and no action-context warning.
- Remaining implementation starts with `P3.13 RED: profile_commit boundary`; no P3.13+ source or task row changed.

### Native Settlement Result

- Submitted a passing settlement using fresh evidence `sha256:185b103e93b0324d0f6eceb370987e9e4e7b84a508a56000cdd7658ad76a24f1` and `--remediates-evidence-revision sha256:fc0b45d567d8c3bbb856c76967db665236fc971f46e4e4a7286c03c9e300b7b6`.
- Native status recorded ordinal 28 as passed but returned `state: blocked` / `maintainer_decision`: the native ledger charged 113 changed lines to this remediation, making its cumulative objective 475 changed lines against the 399 limit. Native status now requires a maintainer reset and reports `next_action: reset`.
- No reset, rescope, supersession, staging, commit, push, PR, or further source mutation was performed. The corrected candidate and fresh verification evidence remain preserved for maintainer disposition.

## P3.11–P3.12 — Evidence-Only Revalidation

**Status:** revalidated the preserved corrected candidate only; P3.11/P3.12 remain `[x]`, and P3.13+ task bytes remain untouched. This run introduced no new RED because it re-executed an already-corrected candidate.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | Not rerun or fabricated; the preserved remediation RED remains the historical evidence. |
| GREEN / TRIANGULATE | Direct worker harness passed 39 with 10 emulator-only skips; Firestore emulator passed 49/49. |
| REFACTOR | Explicit NodeNext and configured TypeScript, three direct regressions, and scoped whitespace validation passed. |

- `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` → exit 0; 39 pass, 10 skipped.
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` → exit 0; 49/49 pass; Firestore, hub, and logging shut down orderly.
- Explicit NodeNext check for `src/provisioning/worker.ts`, `src/provisioning/boundaries.ts`, and `test/provisioning/worker_auth.test.ts` → exit 0; `cd functions && npx tsc --noEmit --project tsconfig.json` → exit 0.
- Direct regressions passed: `schemas.test.ts` 41 assertions, `audit.test.ts` 99 assertions, `outbox.test.ts` 20 assertions. Required `flutter test` exited 127 before discovery with `/usr/bin/env: ‘bash\r’: No such file or directory`; this known CRLF launcher environment failure was neither hidden nor repaired.
- No-source-mutation proof before this append and after all commands: `boundaries.ts` `71a9e232d8f34cb734d7f165a2d514cac21fdf594c3e39dde8c475b019f3d1e6`, `worker.ts` `1f8be19134372f98c1d4e25ac507ede92d010b05666921e5165a5acfb31cee4f`, `worker_auth.test.ts` `7340e341687bb7f2e1463b36f2bce95fc018d06ea72001a25d313894ce1b93af`, and `tasks.md` `448725626fc2d3337a5120f3e1318e1ce4421cfe13617b8ef61df21fe11de34c` were identical; P3.13/P3.14 remain unchecked. Scoped `git diff --check` covers those paths, `tasks.md`, and this append.
- Status consumed: parent-authoritative apply-ready v2 status, repo-local sole allowed root, no action-context warning. The parent retains settlement and the active attempt token; this executor did not settle, reset, rescope, or alter task checkboxes.

### Native Evidence-Only Settlement

- Parent settlement returned `state: complete` and remediated `sha256:185b103e93b0324d0f6eceb370987e9e4e7b84a508a56000cdd7658ad76a24f1` with fresh verification evidence `sha256:e774c4bb8fa963239144fadb9746915968f52e285d0bd1cbe3bacdd6d5350f91`.
- Final native revision: `sha256:697111da10c7b1b4950997e84dfb0169d3629514441ef4078ff0f452cd9cb672`; generation 23 is complete, `decision_required: false`, and `next_action: complete`.
- Native accounting: 1 attempt and 19 changed lines for this objective; lifetime totals are 29 attempts and 3921 changed lines.
- This post-settlement record changes no source, test, configuration, or task checkbox. P3.13+ remains pending.

## P3.13 — Profile Commit RED

**Status:** Strict-TDD RED completed; P3.14 GREEN remains unchecked and is the sole owner of production implementation.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|
| P3.13 | `node --experimental-strip-types test/provisioning/worker_profile.test.ts` exited 1 because `worker.ts` does not export `completeProfileCommit` or `ProfileCommitReader`; explicit NodeNext TypeScript exited 2 with matching TS2305 errors. | Not run; production code is prohibited in this RED-only slice. | Not run; owned by P3.14. | Not run; owned by P3.14. |

- Added `functions/test/provisioning/worker_profile.test.ts` before any production change. Its vectors specify atomic provenance-profile/completed-terminal/success-audit/source-ack persistence, mandatory matching Auth UID/email reads, and rollback after an injected post-profile transaction failure.
- Persisted task update: P3.13 is visibly `- [x]`; P3.14 and all later P3 rows remain unchecked.
- Files changed: `functions/test/provisioning/worker_profile.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this cumulative progress record. No production source, configuration, P3.14, or protected path changed.
- Workload boundary: `p3-13-profile-commit-success`, RED-only; warning 320, STOP 380, hard maximum 399. The parent supplied the same-attempt `proceed` authority; this executor neither acquired nor settled an attempt.
- Status consumed: authoritative `gentle-ai.sdd-status` v2 apply state `ready`, repo-local workspace root with the repository as the sole allowed edit root; no action-context warning.

## P3.13 — Corrected Profile Commit Completion

**Supersedes:** The preceding RED-only record was rejected because it used an unauthorized new test file and incorrectly claimed task completion. Its historical RED command remains factual; this corrected record is the authoritative P3.13 outcome.

### TDD Cycle Evidence

| Stage | Evidence |
|---|---|
| RED | `worker_auth.test.ts` was extended before production code; direct Node exited 1 because `completeProfileCommit` was absent. |
| GREEN | The focused direct harness passed **41**, failed **0**, skipped **11**; profile commit covers atomic provenance/profile/completed/audit/source-ack persistence. |
| TRIANGULATE | The Auth+Firestore emulator harness passed **52**, failed **0**, skipped **0**, including `REAL-PROFILE-COMMIT`. Matching existing profiles and terminal replay preserve bytes; an audit-create conflict rolls back the strict fake. |
| REFACTOR | Explicit NodeNext and configured TypeScript passed; scoped whitespace validation passed; no coverage was removed. |

- Corrected scope: removed the unauthorized `functions/test/provisioning/worker_profile.test.ts`; its relevant RED vectors now live in the authorized `functions/test/provisioning/worker_auth.test.ts`.
- Implemented `completeProfileCommit` in `worker.ts` and only the required `readProfile`/`writeProfile` transaction ports plus Firestore `users` adapter in `boundaries.ts`. `profile.ts` and every other excluded dependency remain unchanged.
- Regression results: profile direct 2 pass/0 fail/1 skip; schemas 41 assertions; audit 99 assertions; outbox 20 assertions. `flutter test` remains a known pre-discovery environment failure (exit 127: `bash\\r` shebang) and was neither hidden nor changed.
- Persisted task update: P3.13 is visibly `- [x]`; P3.14 and every later P3 task remain unchecked.
- Workload: provider-begin-tree measurement over exactly `worker.ts`, `boundaries.ts`, `worker_auth.test.ts`, `tasks.md`, and this record is retained in the final result; no new-file test remains. Warning 320, STOP 380, hard maximum 399.
- Attempt: same parent-authorized token was used without acquire or settlement; parent retains settlement.

## P3.13 — Bounded Failed-Evidence Correction

**Status:** corrected under the active parent-bound remediation attempt; P3.13 remains checked and P3.14+ remain unchanged.

| TDD stage | Evidence |
|---|---|
| RED | Added behavior vectors for every incomplete persisted-proof correlation and an implementation conformance assertion; direct worker harness exited 1 (41 pass, 1 fail) because profile commit did not delegate display-name derivation. |
| GREEN | `completeProfileCommit` now delegates to `deriveDisplayName` and explicitly requires confirmed attempt/proof UID/email/attempt correlations before either Auth reads or atomic success work; direct harness passed 42/0 (11 emulator-only skips). |
| TRIANGULATE | Firestore+Auth emulator command passed 53/0, including `REAL-PROFILE-COMMIT`. |
| REFACTOR | Explicit NodeNext and configured TypeScript plus direct profile, schemas, audit, and outbox regressions passed. |

- Files changed: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, and this append-only record.
- Scope/deviation: no transaction port, audit, profile, task checkbox, or P3.14+ behavior changed; the existing state validator already rejected malformed correlations, and this correction makes the worker's required persisted-proof predicate explicit.
- Remaining implementation task: `- [ ] P3.14 GREEN: profile_commit passes; conflicting profile -> manual_recovery; no deletion.`
- Workload/attempt: `p3-13-profile-commit-remediation`, bounded to the parent-issued 180-line maximum; the executor used the active token without acquire, settlement, reset, rescope, or token persistence.
- Status consumed: authoritative apply-ready `gentle-ai.sdd-status` v2, repo-local root and sole allowed edit root; no action-context warning.

## P3.14 — Profile Conflict Manual Recovery

**Status:** implemented under strict TDD using the parent-provided second/final `proceed` authority; no acquire, settlement, reset, rescope, or token persistence was performed.

### TDD Cycle Evidence

| Stage | Evidence |
|---|---|
| RED | Added the conflicting-profile fake and Firestore acceptance vectors before source changes; direct worker harness exited 1 because the existing path left the operation active. |
| GREEN | The profile-conflict transaction atomically records `manual_recovery/terminal`, clears owner and lease, acknowledges the source as processed, preserves the conflicting profile, and creates the exact immutable 14-field failure audit. |
| TRIANGULATE | Fake matrix proves the exact audit, matching-audit timestamp retention, replay stability, and rollback on audit identity drift; Firestore emulator passed 56/56, including `REAL-PROFILE-CONFLICT-RED`. |
| REFACTOR | Focused Node and explicit/configured TypeScript checks passed; schema, audit, outbox, and profile regressions passed, and scoped `git diff --check` was clean. |

- Persisted task update: P3.14 is visibly `- [x]`; P3.15 and every later P3 row remain unchecked.
- Files changed: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `tasks.md`, and this append-only record. No profile is overwritten or deleted on the conflict path.
- Verification: direct worker harness 44 pass/0 fail/12 emulator skips; Firestore harness 56 pass/0 fail/0 skips; explicit NodeNext and configured TypeScript pass; schema 41, audit 99, outbox 20, and profile 2 pass/1 emulator skip.
- Flutter check: `flutter analyze --no-pub --fatal-infos --fatal-warnings` could not start because the configured `/mnt/c/flutter/bin/flutter` has a CRLF `bash\\r` shebang; one bounded bash retry failed on the same line endings, and no toolchain or source file was changed.
- Provider-begin-tree accounting: native `sdd-attempt status` could not report a measurement because it rejected the pre-existing runtime record with `unmanaged_remediation_finish_bind` at revision `sha256:697111da10c7b1b4950997e84dfb0169d3629514441ef4078ff0f452cd9cb672`; no reset or other native mutation was attempted.
- Workload boundary: `p3-14-profile-conflict-manual-recovery`, warning 320, STOP 380, hard maximum 399; measured provider-begin-tree lines remain unavailable until the parent/maintainer repairs the native runtime record.
- Status consumed: authoritative `gentle-ai.sdd-status` v2 apply-ready, repo-local workspace root and sole allowed edit root; no action-context warning.

## P3.14 — Independent Acceptance Correction

**Status:** failed acceptance; candidate preserved and P3.15+ remains out of scope.

- The writer's 56/56 emulator result above remains historical writer evidence, but it is not sufficient independent acceptance evidence.
- The independent verifier and the single authorized corrective retry each produced 55/56. Both failed `REAL-TK-ONE-WINNER preserves a matching replay timestamp and source bytes` with `3 INVALID_ARGUMENT: Transaction is invalid or closed`.
- P3.14 semantic inspection passed: the profile-conflict transition is atomic, preserves conflicting profile bytes, clears owner and lease, acknowledges the exact source, writes or deduplicates the immutable failure audit, and preserves matching replay timestamp/source bytes.
- No second retry is authorized. No attributable Firebase emulator, Java emulator, or worker test process remained after shutdown.
- P3.14 is implemented but not natively accepted; this correction supersedes any interpretation of the preceding 56/56 writer result as final acceptance.

## P3.14 — Closed-Transaction Remediation

**Status:** corrected only the failed P3.14 acceptance path under the parent-held native attempt. P3.15+ remains out of scope.

### TDD Cycle Evidence

| Stage | Evidence |
|---|---|
| RED | Preserved independently reproduced `REAL-TK-ONE-WINNER preserves a matching replay timestamp and source bytes` failure: 55/56 with Firestore code 3, `Transaction is invalid or closed`; no historical RED was fabricated. |
| GREEN | `takeoverExpiredCurrent` now retries exactly once only when a Firestore transaction reports that exact closed-transaction signature, separately around its write transaction and mandatory post-commit reread. |
| TRIANGULATE | `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` exited 0: 56/56, including `REAL-TK-ONE-WINNER` and profile-conflict preservation. |
| REFACTOR | Direct worker harness passed 44/44 with 12 emulator-only skips; explicit NodeNext and configured TypeScript passed; schemas 41, audit 99, outbox 20, profile 2 pass/1 skip, and scoped `git diff --check` passed. |

- **Structural diagnosis:** ordinary takeover previously had no bounded recovery for Firestore's transient closed transaction, while stale-delivery acknowledgement already guarded the identical code-3 condition. Retrying only the failed transaction preserves the already-committed takeover state for the required reread instead of rerunning side effects.
- **Files changed:** `functions/src/provisioning/worker.ts` and this append-only record. `worker_auth.test.ts` was not weakened, serialized, skipped, or changed; profile conflict semantics and P3.15+ were untouched.
- **Persisted tasks:** P3.14 was already visibly `[x]`; no task checkbox changed. P3.15 remains visibly unchecked.
- **Runtime cleanup:** `firebase emulators:exec` exited 0 and reported orderly Firestore, hub, and logging shutdown. No acquire, settle, reset, rescope, staging, commit, push, PR, or deployment was performed.
- **Workload / PR boundary:** bounded P3.14 remediation in the existing feature-chain work unit. Native begin-tree measurement remains parent-owned because the scoped provisioning source is pre-existing untracked candidate content; no size exception is claimed.
- **Status consumed:** `gentle-ai.sdd-status` v2 for `prepare-public-portfolio-repository`, `applyState: ready`, repo-local workspace root `<workspace-root>`, and that sole allowed edit root; no action-context warning.

## P3.15a — Current-Effect Crash/Reconstruction Subslice

**Status:** completed only for the maintainer-approved P3.15a scope. Parent P3.15/P3.16 remain visibly unchecked; terminalization and P3.17+ were not implemented or tested.

### TDD Cycle Evidence

| Stage | Evidence |
|---|---|
| RED | New `AUTH-CRASH-RED` and `AUTH-PROOF-COMMIT-RED` vectors failed because persisted `call_started` replay performed no UID/email reconstruction reads. |
| GREEN | `createAuthUser` now uses `Promise.allSettled` to reread both Auth indexes before committing `manual_recovery`; it still never repeats `createUser`. |
| TRIANGULATE | Either missing reconstruction index is ambiguous; the existing outbox crash-before-ack replay and profile completion rollback/retry paths remain green. |
| REFACTOR | Focused worker/outbox harnesses and explicit/configured TypeScript checks passed with no model event, terminalization, or concurrency-coverage change. |

- **Files changed:** `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `tasks.md`, and this cumulative record. `outbox.test.ts` was read/run as the retained enqueue replay safety net and was not changed.
- **Focused verification:** `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` → 48 pass, 12 emulator-gated skips; `node --experimental-strip-types test/provisioning/outbox.test.ts` → 20 assertions; explicit worker/test NodeNext `tsc` and configured `tsc --noEmit` → exit 0.
- **Deviation:** a real reconstruction defect required a four-line `worker.ts` repair; no other production behavior changed.
- **Workload / PR boundary:** approved P3.15a current-effect child only; native-begin raw-byte accounting remains below the 300 warning, 350 reforecast stop, and 399 hard maximum. No commit, PR, staging, deployment, or native attempt action occurred.
- **Status consumed:** `gentle-ai.sdd-status` v2 reported `prepare-public-portfolio-repository` apply-ready with repo-local root `<workspace-root>`; allowed root was honored. The supplied corrective-relaunch instruction prohibited acquire/settle/reset/rescope.
- **Remaining implementation tasks:** `- [ ] P3.15 RED: crash/read reconstruction around every runtime effect — before/after enqueue delivery, Auth intent, Auth call, Auth return, each UID/email read, proof commit, profile/completion commit, and terminalization; no explicit crash/read event is added to the pure model.`; `- [ ] P3.16 GREEN: crash injection passes.`

### P3.15a Gatekeeper Command-Evidence Correction

- **Auth + Firestore worker emulator:** `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` → exit 0, 60 pass, 0 fail, 0 skips; Auth, Firestore, and Functions emulators shut down normally.
- **Firestore outbox emulator:** `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox.test.ts"` → exit 0, 20 assertions; emulators shut down normally.
- **Schemas:** `cd functions && node --experimental-strip-types test/provisioning/schemas.test.ts` → exit 0, 28 operation plus 13 dispatch assertions.
- **Audit:** `cd functions && node --experimental-strip-types test/provisioning/audit.test.ts` → exit 0, 39 schema plus 7 dedup plus 53 log-safety assertions.
- **Outbox repair:** `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox_repair.test.ts"` → exit 0, 56 assertions; emulators shut down normally.
- **Scoped diff:** `git diff --check -- functions/src/provisioning/worker.ts functions/test/provisioning/worker_auth.test.ts functions/test/provisioning/outbox.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md` → exit 0.
- **Runtime note:** each Functions-emulator launch warned that the existing `package.json` engine range was not loadable by that emulator, but the requested scripts executed and passed; no package/config change was made.
- **Cleanup:** post-command process inspection found only its own inspection shell and no attributable emulator process. An ignored `functions/firestore-debug.log` exists from emulator execution; it is outside this work unit's authorized source surfaces and was left untouched.
- **Native raw-byte accounting:** begin tree `42b2da90e7db3935781f212cd3bde39733fe8a8d` compared blob-to-filesystem with per-path `git diff --no-index`: worker `4/0`, worker test `86/1`, outbox test `0/0`, tasks `9/0`, and this progress record `32/0`; total `131 additions + 1 deletion = 132` changed lines, below warning 300, stop 350, and hard max 399.

### P3.15a Independent Boundary-Vector Correction

- **Scope:** added independently named crash/restart/replay assertions without changing `worker.ts`; persisted `call_started` matching identities remain `manual_recovery`, never reconstructed proof or a second Auth create.
- **Boundary vectors:** before enqueue; after enqueue before acknowledgement; before intent commit rollback; after committed intent replay; after persisted `call_started` before Auth call; after call/return before reads/proof; UID and email read failures with the peer read observed; proof-commit failure/replay; before completion rollback; and after committed completion replay.
- **TDD honesty:** this is an acceptance-coverage correction over already-correct production behavior, so the added vectors were characterization-green and no fabricated RED or production seam was introduced. The original genuine reconstruction RED remains preserved above.
- **Worker emulator:** `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` → exit 0, 66 pass, 0 fail, 0 skips.
- **Outbox emulator:** `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox.test.ts"` → exit 0, 26 assertions.
- **Outbox repair emulator:** `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox_repair.test.ts"` → exit 0, 56 assertions.
- **Direct regressions:** schemas exit 0 (28 operation, 13 dispatch); audit exit 0 (39 schema, 7 dedup, 53 log-safety); explicit worker/test NodeNext and configured TypeScript checks exit 0.
- **Runtime note:** every emulator command shut down normally. The existing Functions engine-range warning persisted, but requested scripts passed and no package/config change was made.
- **Non-goals:** P3.15/P3.16 remain unchecked; no terminalization, P3.17+, pure-model event, sleep, skipped coverage, concurrency weakening, or profile-conflict/closed-transaction behavior change occurred.
- **Final accounting/cleanup:** native blob-to-filesystem comparison against `42b2da90e7db3935781f212cd3bde39733fe8a8d` totals 269 changed lines (`worker +4/-0`, worker test `+192/-1`, outbox test `+17/-1`, tasks `+9/-0`, progress `+45/-0`); only the inspection shell remained after emulator shutdown.

## P3.17–P3.18 — Two-App REAL Firestore Concurrency Correction (pending runtime authority)

- **Change:** the retained test-only vector uses two separately initialized named Admin apps and Firestore stores, a shared pre-start barrier, and `Promise.all`; it now narrows persisted record fields before asserting the durable g0/v1 operation, owner/lease, processed source, deterministic next dispatch, one audit, and byte-stable replay.
- **TDD evidence:** this is characterization-GREEN only: the user reported the retained REAL two-client behavior passed 67/67, while the direct NodeNext compiler correction passed after the field-access narrowing; no RED was fabricated.
- **Static verification:** Node v24.20.0; explicit `./node_modules/.bin/tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/worker.ts test/provisioning/worker_auth.test.ts` and configured `./node_modules/.bin/tsc --noEmit` both exit 0.
- **Runtime gate:** no direct worker or Firestore-emulator command was launched because authoritative status requires `sdd-attempt acquire` before runtime-bearing work and the maintainer instruction prohibits acquire. P3.17/P3.18 remain unchecked pending that reconciled authority.
- **Scope/accounting:** test and progress only; no production/Auth/Functions/terminalization/P3.19+ change, staging, commit, push, PR, or deployment. Before this append, blob-to-filesystem accounting against begin tree `7b3cb0c6d715f29ac68967be0a27d2cfb6f70b7d` measured worker test `+59/-0`; recount is required after this append before any completion claim.

## P3.17–P3.18 — Independent Two-Client Acceptance

- **TDD honesty:** the maintainer explicitly accepted test-only characterization. Existing production behavior passed the first REAL run, so no RED is claimed or fabricated.
- **Independent runtime:** two separately initialized Firebase Admin apps and Firestore clients targeted the same emulator project and operation; the shared pre-start barrier plus `Promise.all` converged to one durable active g0/v1 operation, exact owner/lease, processed source acknowledgement, deterministic next dispatch, one acquisition audit, and byte-stable replay.
- **Verification:** direct worker harness passed 54 with 13 expected emulator skips; Firestore emulator passed 67/67; explicit NodeNext and configured TypeScript passed; scoped `git diff --check` passed.
- **Scope:** P3.17 and P3.18 are complete. P3.19+ remains unchecked. No production, Auth, Functions, terminalization, staging, commit, push, PR, or deployment change occurred.
- **Cleanup:** independent process inspection found no attributable Firebase, Firestore, Java, or worker-test process after emulator shutdown.

## P3.19–P3.20 — Pre-edit delivery gate

- **Status:** blocked before RED tests or source mutation.
- **Reason:** `tasks.md` declares `Chained PRs recommended: Yes`, while this session selected `ask-on-risk` and did not provide an explicit delivery path (`auto-chain` or a chosen feature-branch-chain mode).
- **Scope:** P3.19/P3.20 remain unchecked; no acquire/settle/reset/rescope, emulator, Flutter, terminalization, staging, or delivery action occurred.

## P3.19–P3.20 — Strict-TDD endpoint attempt (blocked)

| Task | RED | GREEN / verification |
|---|---|---|
| P3.19 | `node --experimental-strip-types test/provisioning/worker_auth.test.ts` failed because `index.ts` lacked `onTaskDispatched`. | Direct worker harness passed 54 with 14 emulator skips after the export was added; the required Functions emulator could not load Functions because the existing `functions/package.json` engine range is `>=20`, which this CLI rejects. |
| P3.20 | `node --experimental-strip-types test/provisioning/enqueue.test.ts` failed because the task body omitted the `data` envelope. | The focused enqueue contract passed 22 assertions after the exact envelope change; explicit source/test NodeNext and configured TypeScript checks passed. |

- **Attempted emulator evidence:** `firebase emulators:exec --project p3-task-endpoint --only firestore,functions ...worker_auth.test.ts` ran Firestore proof (67 pass, 1 skip), but Functions failed before loading the export due to the pre-existing engine-range rejection; the P3.19 HTTP test was skipped, so no endpoint/body/context/persistence evidence exists. Emulator evidence would prove endpoint/body/context wiring only, never IAM or OIDC enforcement.
- **Accounting gate:** Git-native comparison against begin tree `de7358471e7bc0bcdca64426194c973cade02e88` measures 2,378 changed lines across the allowed paths, exceeding the 399 hard cap before this slice can be accepted. No further source or test mutation occurred after this measurement; this mandatory evidence append accounts for the final increase.
- **Remaining tasks:** `- [ ] P3.19 RED: Functions emulator task endpoint — task worker exercised via authenticated HTTP POST to Functions emulator task endpoint with controlled TaskContext headers (no emulators.tasks config).`; `- [ ] P3.20 GREEN: Functions emulator task endpoint test passes.`
- **Scope/status:** structured native apply status was `ready` in repo-local action context; the maintainer selected `feature-branch-chain`; no acquire/settle/reset/rescope, task checkbox, Flutter, terminalization, staging, commit, push, PR, or deployment action occurred.
- **Workload boundary:** this is the P3.19/P3.20 feature-branch-chain slice; it is blocked by the measured hard-cap and Functions-emulator loader gates.

## P3.19–P3.20 — Engine-correction authorization blocked by accounting

- **Maintainer scope:** `functions/package.json` and `functions/package-lock.json` were authorized only for `engines.node: >=20 → 20`, without install or resolution changes.
- **Stop condition:** before changing either file, the required eight-path begin-tree comparison measured 2,378 changed lines, already above the non-exception 399 hard cap.
- **Disposition:** preserved the endpoint/envelope candidate and made no engine, dependency, task-checkbox, or runtime mutation; P3.19/P3.20 remain unchecked.

## P3.19–P3.20 — Canonical TypeScript Functions Packaging Correction

**Status:** the maintainer-authorized packaging correction is complete. `functions/package.json` now declares the compiled CommonJS-independent ESM entrypoint, and Firebase builds Functions before emulator/deploy packaging while retaining compiled `lib/` output. P3.19/P3.20 are not complete because their authenticated HTTP task-endpoint test remains skipped.

### TDD Cycle Evidence

| Stage | Evidence |
|---|---|
| RED | Retained established RED: the Functions emulator previously rejected the package before loading the task endpoint. No failing mutation was fabricated or rerun. |
| GREEN | `npm --prefix functions run build` exited 0 before emulator launch. The Functions emulator loaded `onTaskDispatched` from compiled output and initialized its HTTP endpoint. |
| TRIANGULATE | `firebase emulators:exec --project p3-task-endpoint --only functions` loaded all definitions and initialized `http://127.0.0.1:5001/p3-task-endpoint/us-central1/onTaskDispatched`. The Firestore+Functions worker harness also loaded that endpoint. |
| REFACTOR | No source, test, dependency, or unrelated configuration change; `git diff --check` over the authorized artifacts exited 0. |

- **Packaging changes:** added `"main": "lib/index.js"` in `functions/package.json`; added `"predeploy": ["npm --prefix \"$RESOURCE_DIR\" run build"]` to Firebase Functions configuration; removed only `lib` from the Functions ignore list while retaining `node_modules` and `.git`.
- **Commands/evidence:** `npm --prefix functions run build` exited 0. `cd functions && ./node_modules/.bin/firebase emulators:exec --project p3-task-endpoint --only functions "node --input-type=module -e \"console.log('FUNCTIONS_EMULATOR_READY')\""` exited 0 after reporting `Loaded functions definitions from source: onTaskDispatched, provisioningDispatchCreated, provisioningOutboxRepair, submitProvisioning`, task queue creation, HTTP initialization of `onTaskDispatched`, and `FUNCTIONS_EMULATOR_READY`.
- **Endpoint rerun:** `cd functions && ./node_modules/.bin/firebase emulators:exec --project p3-task-endpoint --only firestore,functions "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` exited 0 with 67 pass, 0 fail, and 1 skip. The skipped test is `P3.19 posts the exact Cloud Tasks envelope to the Functions emulator and acquires the persisted dispatch`; no HTTP envelope/context/persistence acceptance can be claimed.
- **Cleanup:** both `emulators:exec` invocations reported orderly Functions, Eventarc, Tasks, Hub, Logging, and (when started) Firestore emulator shutdown. `functions/lib/` was retained because the updated Firebase package contract intentionally includes the compiled entrypoint; no generated output was deleted.
- **Task state:** P3.19 and P3.20 remain visibly unchecked. No deployment, install, source/test behavior edit, staging, commit, push, PR, native settlement, or task-checkbox mutation occurred.
- **Status/action context:** consumed parent-native apply-ready v2 status for `prepare-public-portfolio-repository`; `repo-local` workspace root was `<workspace-root>`, the allowed root matched, and no action-context warning occurred. Continued the parent-provided active token via acquire with state `proceed`; parent owns settlement.

## P3.19–P3.20 — Independent Functions Endpoint Acceptance

**Status:** completed from independent acceptance evidence; no emulator command was rerun in this corrective phase.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE | REFACTOR |
|---|---|---|---|---|
| P3.19 | Historical RED remains the missing `onTaskDispatched` export. | Prior `npm --prefix functions run build` exited 0; compiled Functions loaded and initialized `onTaskDispatched`. | Independent acceptance command below reached `us-central1-onTaskDispatched` and passed persisted dispatch-acquisition assertions. | Scoped whitespace check passed after bookkeeping; only generated `functions/lib/` was removed. |
| P3.20 | Historical RED remains the missing Cloud Tasks `data` envelope. | The retained endpoint/envelope implementation is covered by the compiled Functions startup evidence. | The same independent endpoint test passed with 1 passed, 0 failed, and 0 skipped. | No source, test, configuration, package, or metadata change was made. |

- **Independent acceptance command:** `firebase emulators:exec --project p3-task-endpoint --only functions,firestore 'FUNCTIONS_EMULATOR_HOST=127.0.0.1:5001 node --experimental-strip-types --test --test-name-pattern="P3.19" functions/test/provisioning/worker_auth.test.ts'` → exit 0; 1 passed, 0 failed, 0 skipped. The HTTP request reached `us-central1-onTaskDispatched`, persisted dispatch-acquisition assertions passed, and the function initialized at `http://127.0.0.1:5001/p3-task-endpoint/us-central1/onTaskDispatched`.
- **Non-blocking runtime noise:** the unrelated Firestore-triggered `provisioningDispatchCreated` logged an unavailable-composition error; it did not affect the targeted passing test. Functions, Firestore, Eventarc, Tasks, hub, and logging emulators stopped orderly.
- **Persisted task update:** P3.19 and P3.20 are visibly `- [x]`. P3.21 and later rows were not changed; remaining task: `- [ ] P3.21 RED: pending terminalization classifier — exact initial pending operation plus full dispatch/source tuple and null worker acknowledgement; write `failed/terminal`, `terminalCode=unavailable`, retry/failure evidence, failure audit, and current dispatch `workerAck=terminalized` atomically.`
- **Files changed:** `openspec/changes/prepare-public-portfolio-repository/tasks.md`; `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`; deleted generated `functions/lib/` only.
- **Verification:** `git diff --check` over the scoped endpoint/package/task/progress paths exited 0 before and after the bookkeeping update; `git status --short` confirmed that `functions/lib/` is absent from the untracked inventory.
- **Workload / PR boundary:** existing P3.19–P3.20 feature-branch-chain acceptance-only correction; no delivery action, source edit, test rerun, deploy, install, stage, commit, push, PR, native settlement, reset, or advance occurred.
- **Status consumed:** parent-authoritative `gentle-ai.sdd-status` v2 was apply-ready for `prepare-public-portfolio-repository`; action context was repo-local at `<workspace-root>` with that sole allowed edit root and no warning. The parent retains the active native attempt and settlement authority.


## P3.21–P3.22 — Initial Pending Terminalization

**Status:** implemented under strict TDD. `terminalizeInitialPending` accepts only the transaction-reread initial `pending/dispatch_pending` operation and deterministic unacknowledged `acquire/g0/sourceVersion0` dispatch. It atomically writes `failed/terminal`, `terminalCode:"unavailable"`, retry/failure evidence, an immutable failure audit, and `workerAck:"terminalized"`.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` exited 1 because `terminalizeInitialPending` was not exported. |
| GREEN | Same direct worker command exited 0: 57 pass, 15 expected emulator skips. |
| TRIANGULATE | Matching audit timestamp preservation and conflicting-audit rollback are covered by the strict fake; the Auth+Firestore emulator command exited 0: 71 pass, 1 Functions-only skip. |
| REFACTOR | Explicit NodeNext TypeScript, configured TypeScript, Functions build, and scoped diff check all exit 0. |

### Completion and verification

- Persisted task checkboxes: `P3.21` and `P3.22` changed to `- [x]`; no other task checkbox changed.
- Files changed: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, this progress record, and `tasks.md`.
- Commands: direct worker test; `./node_modules/.bin/tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/worker.ts test/provisioning/worker_auth.test.ts`; `./node_modules/.bin/tsc --noEmit`; `./node_modules/.bin/firebase emulators:exec --only firestore,auth "node --experimental-strip-types test/provisioning/worker_auth.test.ts"`; `npm --prefix functions run build`; scoped `git diff --check`.
- Design deviation: terminal evidence fields are persisted directly because the frozen `isValidOperation` validator deliberately accepts only newly submitted pending records; no schema, dependency, runtime export, or unrelated task was changed.
- Remaining implementation tasks include exact unchecked lines `- [ ] P3.23 RED: pending predicate mismatch — do not infer safety; reread + reclassify as exact pending/active/terminal; second mismatch/CAS loss returns success with no mutation.` and `- [ ] P3.24 GREEN: pending mismatch passes.`; P3.23+ remain untouched.
- Workload / PR boundary: Functions-only P3.21–P3.22 slice; no commit, PR, deployment, or settlement. The status consumed was `gentle-ai.sdd-status` v2, `applyState:"ready"`, repo-local action context with the workspace root as the allowed edit root; the active native attempt was continued with its supplied token, and settlement remains parent-owned.


## P3.23–P3.24 — Pending Predicate Mismatch Reclassification

**Status:** implemented under Strict TDD. `terminalizeInitialPending` preserves P3.21's atomic pending terminalization but retries no unsafe write: a failed initial predicate rereads and classifies only exact pending, active, terminal, or mismatch; active, terminal, and a second mismatch/CAS loss return successfully without mutation.

### TDD Cycle Evidence

| Task | RED | GREEN / TRIANGULATE / REFACTOR |
|---|---|---|
| P3.23 | Added the direct worker vector before source changes; `node --experimental-strip-types test/provisioning/worker_auth.test.ts` failed with one assertion because only one read occurred instead of the required reread. | Active, terminal, and persistent mismatch cases now make two read-only transactions and preserve every record. |
| P3.24 | The retained RED proved missing reclassification. | A controlled first-mismatch → exact-pending reread → second-mismatch vector proves three transactions, zero writes, unchanged dispatch/audits, and successful return. |

- **Files changed:** `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, and the P3.23/P3.24 checkboxes in `tasks.md`.
- **Verification:** direct worker harness 59 pass/15 expected emulator skips; Auth+Firestore emulator 73 pass/1 Functions-emulator skip; configured `./node_modules/.bin/tsc --noEmit`; scoped `git diff --check` all passed.
- **Deviation:** no design deviation; no P3.25+ retry, terminal, takeover, Auth, profile, Flutter, packaging, or delivery behavior was added.
- **Workload / PR boundary:** one feature-branch-chain slice, measured native accounting remains for the parent settlement; no size exception requested.
- **Status consumed:** `gentle-ai.sdd-status` v2 apply ready, repo-local workspace/edit root; active attempt continued with token `sha256:7fb5b9ba277f1299a6ab36e54b6760078f3695efabfe6492e69fafb03e2fc815`; no settlement performed by executor.
- **Remaining implementation tasks:** `- [ ] P3.25 RED: active with exact current owner + live lease — require complete active CAS tuple; safe phase -> failed/unavailable; otherwise -> manual_recovery/internal; evidence + audit + owner/lease clear + current ack commit together.`

## P3.27–P3.28 — Foreign Owner With Live Lease

**Status:** completed under Strict TDD for P3.27/P3.28 only. `terminalizeActiveCurrent` now rereads the active source and operation immediately before constructing any audit or write. A changed or foreign live owner fails the exact predicate and returns successfully without mutating the operation, dispatch, or audit; the stable exact-owner P3.25/P3.26 path remains unchanged.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|
| P3.27 | Direct worker harness failed 1/81 after the new final-reread CAS-loss vector observed only one operation read (`1 !== 2`). | Added the minimal trusted source/operation reread and exact-predicate gate before audit construction; direct worker harness: 64 pass, 17 emulator-gated skips, 0 fail. | Strict fake proves a first exact snapshot followed by a foreign-owner reread produces no audit or write calls. |
| P3.28 | Auth+Firestore foreign-owner live-lease vector was authored before emulator verification. | Auth+Firestore emulator harness: 80 pass, 1 Functions-only skip, 0 fail. | Firestore snapshots prove byte-identical operation and dispatch and an empty audit collection after successful return. |

### Verification and Accounting

- Node v24.20.0 and Java 21.0.12 passed the prerequisite gates.
- Direct RED: `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` → 63 pass, 17 skips, 1 fail (`P3.27 RED returns success without writes when a final active-owner reread loses CAS`).
- Direct GREEN: the same command → 64 pass, 17 skips, 0 fail.
- Auth+Firestore: `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore,auth "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` → 80 pass, 1 Functions-only skip, 0 fail; emulators shut down cleanly.
- Configured build: `cd functions && ./node_modules/.bin/tsc --noEmit` → exit 0.
- Scoped diff check: `git diff --check -- functions/src/provisioning/worker.ts functions/test/provisioning/worker_auth.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md` → exit 0.
- Persisted task updates: P3.27 and P3.28 are checked. Remaining immediate unchecked lines are `- [ ] P3.29 RED: active with expired lease — first transaction requires full observed expired tuple, increments generation + version, installs new owner token + live lease; same invocation applies complete active terminalization guard using the exact new tuple.` and `- [ ] P3.30 GREEN: expired-lease takeover passes.` All P3.31+ tasks remain outside this work unit.
- Files changed: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this progress file.
- Accounting: the production/test paths are pre-existing untracked candidates, so ordinary tracked `git diff --numstat` cannot provide a truthful slice-only total; native accounting remains active for parent settlement and is not inferred here.
- Workload / PR boundary: feature-branch-chain, P3.27–P3.28 only; no commit, PR, delivery, or settlement.
- Structured status consumed: `gentle-ai.sdd-status` v2 `applyState: ready`, repo-local canonical workspace and allowed root. Continued active attempt token `sha256:7c55d56dcbca616221db13486b71a6530950cf611940e93685c70072d1998d7c`; per instruction no settlement was performed.


## P3.29–P3.30 — Expired-Lease Takeover Then Terminalization (blocked verification)

**Status:** implementation candidate is not accepted and P3.29/P3.30 remain unchecked. Strict-TDD RED was captured before production edits: the direct worker harness failed the two new expired-lease assertions because an expired active tuple was left unchanged. GREEN then made `terminalizeActiveCurrent` first use the existing transactional expired-current takeover and require the terminalization transaction to reread the exact post-takeover operation/source tuple. The resulting terminalization uses generation 1/version 2 as its failure-audit/evidence source, yields generation 1/version 3, clears ownership, and acknowledges the retained source only during terminalization.

### TDD Cycle Evidence

| Task | RED | GREEN / focused evidence | Acceptance state |
|---|---|---|---|
| P3.29 | `node --experimental-strip-types test/provisioning/worker_auth.test.ts` exited 1: both new expired-lease assertions failed before production changes. | Direct worker harness: 66 pass, 18 expected emulator skips, 0 fail. It proves takeover `g0/v1 -> g1/v2`, exact-tuple terminalization to `g1/v3`, two audits, retained-source acknowledgement only at terminalization, and terminalization-CAS-loss bounded at the takeover commit. | Pending emulator suite acceptance. |
| P3.30 | Emulator-gated test was authored before production changes and skipped in direct mode. | Auth+Firestore run executed the new P3.30 test successfully. | Blocked because the same full worker emulator run has one pre-existing `REAL-TK-ONE-WINNER` failure: Firestore code 3 `Transaction is invalid or closed`. |

### Verification and Accounting

- Node v24.20.0 satisfied the runtime gate.
- Direct worker command passed: 66 pass, 18 skipped, 0 fail.
- Configured `cd functions && ./node_modules/.bin/tsc --noEmit` passed.
- Auth+Firestore command ran: `./node_modules/.bin/firebase emulators:exec --only firestore,auth "node --experimental-strip-types test/provisioning/worker_auth.test.ts"`; 82 pass, 1 fail, 1 skip. The new P3.30 emulator test passed, but existing `REAL-TK-ONE-WINNER` failed with Firestore code 3.
- Scoped `git diff --check -- functions/src/provisioning/worker.ts functions/test/provisioning/worker_auth.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md` passed; no task completion is claimed because the emulator suite still failed.
- Changed candidate paths: `functions/src/provisioning/worker.ts` and `functions/test/provisioning/worker_auth.test.ts`; the two permitted SDD artifacts remain in scope. Native changed-line accounting is not finalized because this active attempt is intentionally left unsettled per the current human instruction.
- Workload / PR boundary: feature-branch-chain P3.29–P3.30 only; no commit, PR, delivery, or settlement.
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState: ready`, repo-local workspace root and permitted edit root. Native acquire continued token `sha256:f19a76ad2fbfcc4c4372f50faf68837ad149fa1dcbd5306af25ac89492c5aeb3`; action context permits only the canonical workspace.
- Remaining implementation tasks include `- [ ] P3.29 RED: active with expired lease — first transaction requires full observed expired tuple, increments generation + version, installs new owner token + live lease; same invocation applies complete active terminalization guard using the exact new tuple.` and `- [ ] P3.30 GREEN: expired-lease takeover passes.`

## P3.29–P3.30 — Final Native Remediation Evidence

**Status:** completed from supplied independent corrective evidence for failed evidence `sha256:acff6790816d89aa04d86b98e2a44bf934f92958ec84310bbb2a3eae0e194251`; tests, emulators, and build were not rerun in this evidence-recording phase.

| Evidence | Recorded result |
|---|---|
| Direct worker | 84 tests: 66 pass, 18 skip, 0 fail. |
| Auth + Firestore | 84 tests: 83 pass, 1 expected Functions-only skip, 0 fail. |
| REAL concurrency | `REAL-TK-ONE-WINNER` passed; the prior closed-transaction failure did not reproduce. |
| Static/scope | TypeScript build and scoped diff passed; no residual process remained. |

- Semantic readback confirmed the complete expired tuple, generation/version increment, newly derived owner and live lease, preserved current dispatch, then terminalization against the exact committed tuple; takeover and terminal CAS loss are safe.
- Persisted task updates: only P3.29 and P3.30 are checked; P3.31+ remains untouched. Immediate remaining rows: `- [ ] P3.31 RED: terminal operation — return success without operation mutation or new audit; existing dispatch acknowledgement is idempotent in dispatch persistence and never causes a standalone `OperationState.version` increment.` and `- [ ] P3.32 GREEN: terminal idempotency passes.`
- Prior implementation accounting is 179 lines. Workload / PR boundary: P3.29–P3.30 only, feature-branch-chain; no P3.31+ work, code/test edit, cleanup, settlement, commit, or delivery action.
- Scoped OpenSpec `git diff --check` passed; scoped status shows only the pre-existing modified `tasks.md` and `apply-progress.md` artifacts. Structured `gentle-ai.sdd-status` v2 was apply-ready with the canonical repo-local workspace/allowed root; parent retains native remediation settlement authority.

## P3.31–P3.32 — Terminal Operation Replay Idempotency

**Status:** completed under Strict TDD for P3.31/P3.32 only. Terminal operation replays are detected from descriptor-safe persisted terminal status/phase fields before expired-lease takeover work. Replays preserve the terminal operation, the existing `terminalized` dispatch acknowledgement, and the immutable audit byte-for-byte; they do not create an audit or mutate `OperationState.version`.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|
| P3.31 | `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` exited 1 with the two new replay assertions: the prior path redundantly reread the acknowledged dispatch before identifying terminal state. | `terminalizeActiveCurrent` now recognizes a persisted terminal result during its existing takeover transaction and returns before a terminal mutation path. | Direct worker harness passes; P3.21–P3.30 regressions remain green. |
| P3.32 | The P3.31 focused RED provides the behavior-first failure for terminal replay. | Auth+Firestore emulator preserves operation, acknowledged dispatch, and audit bytes on replay. | Configured TypeScript build and scoped diff checks pass. |

### Verification and Accounting

- Node v24.20.0 satisfies the Node >=22.6.0 gate.
- Focused RED: `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` → exit 1, 66 pass, 2 fail, 18 skipped.
- Focused GREEN: direct worker harness → exit 0, 68 pass, 0 fail, 18 emulator-gated skips before the P3.32 emulator vector was added.
- Auth+Firestore emulator: `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore,auth "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` → exit 0, 86 pass, 0 fail, 1 Functions-only skip; P3.32 byte-preservation vector passed.
- Configured build: `cd functions && ./node_modules/.bin/tsc --noEmit` → exit 0.
- Files changed: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this progress file.
- Persisted task updates: P3.31 and P3.32 are checked. Remaining P3 tasks include the exact unchecked P3.15/P3.16 and P3.33+ rows; no P3.33+ work was performed.
- Deviation from design: none. The replay guard is descriptor-safe and accepts terminal records with immutable terminal evidence fields that are intentionally outside the initial-operation schema.
- Workload / PR boundary: feature-branch-chain; P3.31–P3.32 only; no commit, PR, delivery, settlement, or retry-policy work.
- Structured status consumed: `gentle-ai.sdd-status` v2 with `applyState: ready`, canonical repo-local workspace, and the canonical workspace root as the allowed edit root. Native attempt token `sha256:572dead48af0c8e1f44726929f3f5cb6875f0ea8ffdc83492ad7b9f954fefe72` remains active; per instruction, no settlement was performed.

### Remaining P3 Rows Outside This Slice

- `- [ ] P3.15 RED: crash/read reconstruction around every runtime effect — before/after enqueue delivery, Auth intent, Auth call, Auth return, each UID/email read, proof commit, profile/completion commit, and terminalization; no explicit crash/read event is added to the pure model.`
- `- [ ] P3.16 GREEN: crash injection passes.`
- `- [ ] P3.33 RED: 12/8 retry protocol — `retryCount` 0–7 may work; 8–11 terminalize only; non-integer/negative/>11 fail-closed; pre-handler 5xx semantics; no fictional post-exhaustion callback; permanent durable-store outage -> alert + runbook, not silent success.`
- `- [ ] P3.34 GREEN: 12/8 protocol passes.`
- `- [ ] P3.35 RED: reserved attempts 8, 9, 10, 11 repeat only guarded terminalization paths; failed terminalization transaction throws so next reserved attempt retries; committed terminal returns success.`
- `- [ ] P3.36 GREEN: reserved-attempt idempotency passes.`
- `- [ ] P3.37 RED: status authorization — unauthenticated -> `unauthenticated`; non-admin -> `permission-denied`; unknown operationId -> `not-found`; optional fingerprint mismatch -> `already-exists`; no mutation on either path.`
- `- [ ] P3.38 GREEN: status authorization passes.`
- `- [ ] P3.39 RED: status DTO projection — each status returns only its safe fields; no raw email/owner/lease/generation/version/evidence/audit identity.`
- `- [ ] P3.40 GREEN: DTO projection passes.`
- `- [ ] P3.41 RED: completed integrity — re-read both Auth indexes + full provenance-tagged profile; failure or inconsistency returns stable integrity error without changing terminal operation or generating a link; deduplicated integrity audit.`
- `- [ ] P3.42 GREEN: completed integrity passes.`
- `- [ ] P3.43 RED: fresh reset link — Auth `generatePasswordResetLink` called only after integrity passes; link returned; link never stored, logged, audited, or emailed; transient link failure returns stable retryable error leaving `completed` unchanged.`
- `- [ ] P3.44 GREEN: reset link passes.`
- `- [ ] P3.45 RED: full emulator flow — happy-path submission through to completed status with fresh reset link; no client-driven re-drive.`
- `- [ ] P3.46 GREEN: full emulator flow passes.`
- `- [ ] P3.47 RED: outbox race — trigger+sweeper race; duplicate event; out-of-order delivery; crash before enqueue; crash after enqueue; task already exists (`ALREADY_EXISTS` accepted).`
- `- [ ] P3.48 GREEN: outbox race passes.`
- `- [ ] P3.49 RED: retry threshold conformance — `retryCount` 7/8/9/10/11 valid; pre-handler 5xx first entry at 8–11; reserved attempts terminalize only; retryCount >11 or non-integer/negative fail-closed; poison behavior; no fictional exhaustion callback.`
- `- [ ] P3.50 GREEN: retry conformance passes.`
- `- [ ] P3.51 RED: Auth emulator matrix — foreign pre-attempt identity; exact create result; both UID/email reads; ambiguity; provenance conflict; all-or-nothing completion; completed integrity; no automatic deletion.`
- `- [ ] P3.52 GREEN: Auth matrix passes.`
- `- [ ] P3.53 RED: emulator/concurrency end-to-end — lease expiry/takeover; duplicate/out-of-order delivery; crash injection around every effect; first entry after pre-handler retries; exact pending guard per-field mutations; pending mismatch reclassification; active live owner; foreign live owner; expired takeover; terminal idempotency; failed reserved terminalization.`
- `- [ ] P3.54 GREEN: end-to-end passes.`
- `- [ ] P3.55 REFACTOR: finalize all callable exports; `npx tsc --noEmit` green; full `npm test` green.`
- `- [ ] P3.56 FREEZE: aggregate emulator + TypeScript + independent phase-contract validation + candidate freeze. RDD remains disabled; surface explicit maintainer enable decision at this point.`


## P3.33–P3.34 — Bounded Task Retry Protocol

**Status:** completed under Strict TDD for P3.33/P3.34 only. `onTaskDispatched` now validates retry metadata before constructing a Firestore store or running a handler: integer retry counts 0–7 run the existing guarded acquisition boundary; 8–11 run only the existing pending/active terminalization paths. Negative, noninteger, and greater-than-11 counts throw a retryable `unavailable` error before mutation. A durable-store failure on retry 11 emits a PII-safe `provisioning_durable_store_outage` error event with the existing outbox-recovery runbook path and throws; no post-exhaustion callback was added.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|
| P3.33 | `node --experimental-strip-types test/provisioning/worker_auth.test.ts` exited 1 because `processProvisioningTask` was not exported. | Direct worker harness passes 70 tests with 20 emulator-gated skips, including 0–7 work, 8–11 terminalization-only, invalid retry no-mutation, and retry-11 durable-outage alert/runbook vectors. | `./node_modules/.bin/tsc --noEmit` and `npm run build` pass. |
| P3.34 | The same missing-export test was the focused genuine RED before production routing existed. | The aligned Functions+Auth+Firestore emulator runs the actual task endpoint: malformed retry metadata returns HTTP 500 with no mutation; retry 8 returns 204 after terminalization. | `node --test --test-name-pattern='P3.34'` under the aligned emulators passes 1/1; generated `functions/lib` was removed. |

### Verification and Accounting

- Node v24.20.0 and Java 21.0.12 passed prerequisite gates.
- Direct worker: `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` → 70 pass, 20 expected emulator skips, 0 fail.
- Configured TypeScript: `cd functions && ./node_modules/.bin/tsc --noEmit` and `npm run build` → exit 0; build output was removed after each run.
- Aligned Functions+Auth+Firestore: `GCLOUD_PROJECT=demo-no-project FUNCTIONS_EMULATOR_HOST=127.0.0.1:5001 npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types --test --test-name-pattern='P3.34' test/provisioning/worker_auth.test.ts"` → 1 pass, 0 fail, 0 skip; Auth, Firestore, Functions, Tasks, Eventarc, hub, and logging emulators shut down orderly.
- Scoped `git diff --check` over the three implementation paths and two SDD artifacts exited 0.
- Files changed: `functions/src/index.ts`, `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this progress file.
- Persisted task updates: P3.33 and P3.34 are checked; P3.35+ remains unchecked.
- Accounting: the native begin tree recorded these source/test paths as untracked, so standard Git numstat cannot isolate this slice. Directly authored additions are 49 worker lines and 123 test lines (including the import), plus the small task-endpoint and SDD bookkeeping edits; this is below the session 800-line budget. No size exception, commit, PR, delivery, or settlement was performed.
- Workload / PR boundary: feature-branch-chain, P3.33–P3.34 only.
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState: ready`, repo-local canonical workspace and allowed root. The continued native token is `sha256:bb846092c40fb22ccfaf39c69af7a951cefcb7dd258e0bbcbc14602723a8fe90`; user instruction prohibits settlement in this phase.


## P3.35–P3.36 — Reserved-Attempt Terminalization Idempotency

**Status:** completed under Strict TDD for P3.35/P3.36 only. Reserved retries now stop after pending terminalization either commits or observes an already terminal pending operation; they do not run an unrelated active-terminalization transaction after a committed terminal result.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|
| P3.35 | `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` exited 1 (70 pass, 20 skipped, 1 fail): an injected third transaction showed that committed pending terminalization still entered active terminalization. | The same focused runner exited 0 (71 pass, 20 skipped, 0 fail). It proves retries 8/9/10/11 terminalize without `createDispatch`, a failed audit-create transaction rejects and retry 9 commits, and an already terminal replay preserves all strict-store bytes. | The one focused runner covers each reserved retry value, rollback before the later reserved retry, and two-read terminal replay; no further refactor was needed. |
| P3.36 | The P3.35 behavior-first test supplied the RED before the production correction. | The focused runner exited 0 with the same 71 pass, 20 skipped, 0 fail result. | No P3.37+ test, source, or task row was changed. |

### Verification and Accounting

- Focused runner: `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts` -> RED exit 1 (70 pass, 20 skipped, 1 fail), then GREEN exit 0 (71 pass, 20 skipped, 0 fail).
- Files changed: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this progress file.
- Persisted task updates: P3.35 and P3.36 are visibly checked in `tasks.md` immediately after GREEN.
- Native-begin source/test accounting: `git diff --no-index --numstat` against native begin tree `5a01de2fa52c36f1ad5f8951e73c5fd38e5081cd` reports worker `8 additions + 7 deletions`, worker test `49 additions + 0 deletions`, tasks `2 additions + 2 deletions`, and progress `25 additions + 0 deletions`, totaling 93 changed lines; below the 399-line maximum. The native status reports the active attempt at 0 settled lines until parent settlement; no settlement was performed.
- Workload / PR boundary: feature-branch-chain, P3.35–P3.36 only; no commit, PR, deployment, install, or lifecycle mutation.
- Deviation from design: none. `terminalizeInitialPending` now returns whether it committed or observed a terminal pending operation, allowing the caller to skip active terminalization only in that case.
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState: ready`, repo-local canonical workspace, and its workspace root was the sole allowed edit root. The status's stale active-attempt warning was reconciled by continuation acquire token `sha256:02e497f0c02e81c972515debd11e0201e36076987fe22713d732b7c8b948e633`; no settle/reset was performed as instructed.
- Remaining immediate unchecked rows (untouched):
  - [ ] P3.37 RED: status authorization — unauthenticated -> `unauthenticated`; non-admin -> `permission-denied`; unknown operationId -> `not-found`; optional fingerprint mismatch -> `already-exists`; no mutation on either path.
  - [ ] P3.38 GREEN: status authorization passes.


## P3.37–P3.38 — Status Authorization

**Status:** completed under Strict TDD for P3.37/P3.38 only. The new narrow status authorization handler authenticates the caller, requires an active `admin` profile, reads the requested operation, and accepts an absent or matching fingerprint. It returns stable `unauthenticated`, `permission-denied`, `not-found`, or `already-exists` errors without a mutation-capable port or persistent write.

### TDD Cycle Evidence

| Task | RED | GREEN | TRIANGULATE / REFACTOR |
|---|---|---|---|
| P3.37 | The first direct harness invocation exposed unsupported TypeScript parameter-property syntax in the new test fake; that test-only syntax was corrected before production code. The repaired test then failed genuinely with `ERR_MODULE_NOT_FOUND` for absent `status.ts`. | N/A — RED task. | The denial matrix covers unauthenticated, non-admin, unknown operation, and optional-fingerprint mismatch paths; each asserts zero fake mutations. |
| P3.38 | Retained genuine missing-module RED. | `cd functions && node --experimental-strip-types test/provisioning/status.test.ts` exited 0: 5 passing tests, 0 failures. | No production refactor was needed; the narrow handler deliberately excludes P3.39 DTO projection, integrity checks, reset links, and all P3.39+ behavior. |

### Verification and Accounting

- Test command runs: first exited 1 due to test-only unsupported parameter-property syntax; second exited 1 with genuine `ERR_MODULE_NOT_FOUND` for `status.ts`; third exited 0 with 5 passing tests.
- Files changed: `functions/src/provisioning/status.ts`, `functions/test/provisioning/status.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and this progress file. `functions/src/index.ts` remains unchanged because final callable wiring is P3.55 ownership.
- Persisted task updates: P3.37 and P3.38 are marked `- [x]`. Remaining relevant unchecked tasks: `- [ ] P3.39 RED: status DTO projection — each status returns only its safe fields; no raw email/owner/lease/generation/version/evidence/audit identity.` and `- [ ] P3.40 GREEN: DTO projection passes.`
- Workload / PR boundary: `feature-branch-chain`, P3.37–P3.38 only; native-begin accounting is 178 changed lines (53 source + 101 test + 4 task bookkeeping + 20 progress), below the 399-line ceiling. No commit, PR, delivery, or native settle/reset was performed.
- Structured status consumed: `gentle-ai.sdd-status` v2 (`applyState: ready`, repo-local authoritative root). `actionContext` permits only the canonical worktree; continuation acquire reused active token `sha256:69285e38fa847b79e7a0f476b7a27957fcc49c9faabc0b10a939802519c9bce5`.

## P3.37–P3.38 — Test-Only Read-Trace Correction

**Status:** corrected after failed evidence `sha256:6e772f4b765218c359da2d9adfc08c751834ff92684edfad3471b8d35b924f42`. The failed independent finding was limited to proof strength: denial tests used an unused mutation array and did not assert exact reads. Production `functions/src/provisioning/status.ts` was read and left unchanged.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED / correction contract | Updated `status.test.ts` to require exact denial-path read traces; this test-only proof correction introduces no production behavior. |
| GREEN | `cd functions && node --experimental-strip-types test/provisioning/status.test.ts` exited 0: 5 pass, 0 fail. |
| TRIANGULATE / REFACTOR | `authz.test.ts` reported 14 assertions and configured TypeScript exited 0. |

- Exact traces now prove unauthenticated `[]`; non-admin `["user:employee-uid"]`; unknown operation and fingerprint mismatch `["user:admin-uid", "operation:<operationId>"]`; authorized absent/matching fingerprints retain that same two-read trace.
- The removed mutation-array assertion was not structural evidence: the production `StatusAuthorizationPort` exposes only read methods, preserving the no-mutation boundary.
- Files changed: `functions/test/provisioning/status.test.ts` and this progress record only. No task checkbox changed; P3.39+ and production paths remain untouched.
- Workload / PR boundary: correction-only P3.37–P3.38 feature-branch-chain continuation; no install, delivery, commit, PR, settle, or reset.
- Structured status consumed: `gentle-ai.sdd-status` v2, `applyState:"ready"`, repo-local action context with the canonical workspace as the sole allowed edit root. Continuation acquire reused active token `sha256:dad6da3c7a4b0319dcd5cead2dbc1ef21cf2c9134e5840b252eaadaeea2b6ca3`; parent retains settlement authority.

## P3.41–P3.42 — Corrective Completed-Integrity Evidence

**Status:** corrected after failed evidence `sha256:659fbc190386eafe48187f8be4cd3b9ace1759313fa72312b5885f2b48f02108`. This correction changes only `status.ts` and its completed-integrity harness; it does not mutate a terminal operation or invoke a reset-link boundary.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | The canonical persisted completed fixture was authored first, with no root `schemaVersion`, no persisted `displayName`, and deterministic timestamps. `cd functions && node --experimental-strip-types test/provisioning/completed_integrity.test.ts` then failed 10/10 because the old implementation required the obsolete root field. |
| GREEN | The same focused command passed 10/10 after the completed reader accepted the 19 persisted payload fields, derived the profile display name, fixed profile schema version to `1`, settled all three reads, and bound audit `createdAt` to persisted `updatedAt`. |
| TRIANGULATE / REFACTOR | Status 7/7, DTO 69 assertions, authorization 14 assertions, and configured TypeScript all passed. |

- Closed blocker 1: canonical completed operations no longer require root `schemaVersion` or stored `displayName`; `deriveDisplayName` supplies the profile-only field and profile schema version is exactly `1`.
- Closed blocker 2: the harness uses fixed `createdAt`/`updatedAt`; integrity-audit `createdAt` deterministically equals persisted completion evidence (`updatedAt`), never `Date.now()`.
- Closed blocker 3: UID, email, and profile reads are started together with `Promise.allSettled`; any failure still produces only `integrity-failed` after all three reads are attempted.
- Closed blocker 4: matching replay retains one audit with unchanged bytes/timestamp, while incompatible same-ID audit reuse fails closed without an overwrite.
- Exact commands passed: `cd functions && node --experimental-strip-types test/provisioning/completed_integrity.test.ts` (10/10); `cd functions && node --experimental-strip-types test/provisioning/status.test.ts` (7/7); `cd functions && node --experimental-strip-types test/provisioning/dto.test.ts` (69 assertions); `cd functions && node --experimental-strip-types test/provisioning/authz.test.ts` (14 assertions); `cd functions && npx tsc --noEmit` (exit 0).
- Correction accounting: only `functions/src/provisioning/status.ts`, `functions/test/provisioning/completed_integrity.test.ts`, and this append were edited. Both source/test paths are already untracked and the progress file had pre-existing modifications, so no slice-only Git numstat is claimed. `tasks.md`, reset-link behavior, terminal persistence, and P3.43+ were not edited.
- Persisted tasks: P3.41 and P3.42 were already visibly `- [x]`; user scope expressly forbade a `tasks.md` write, so no checkbox was changed in this corrective execution.
- Workload / PR boundary: feature-branch-chain correction for P3.41–P3.42 only; no commit, PR, install, deploy, `sdd-attempt` status/acquire/settle/reset call, or delivery mutation occurred.
- Structured status consumed: `gentle-ai.sdd-status` v2 with `applyState:"ready"`; `actionContext` authorizes only the canonical repo-local workspace. Parent holds active token `sha256:487b83dad332b734f5291e2f4dcb5025c9534dbeed7f0de84d63cd1cf23e756b` and owns settlement citing the failed evidence revision above.
- Remaining unchecked implementation lines (untouched): `- [ ] P3.43 RED: fresh reset link — Auth generatePasswordResetLink called only after integrity passes; link returned; link never stored, logged, audited, or emailed; transient link failure returns stable retryable error leaving completed unchanged.` and `- [ ] P3.44 GREEN: reset link passes.`


## P3.41–P3.42 — Final Test-Only Fixture Correction

**Status:** completed correction for failed evidence `sha256:d3610e69359113284a2dd99cb0d5ead865d3802af936fd3c19641403aa643253`. The completed-integrity fixture now has a canonical terminal `OperationState`: null terminal owner/lease/current-dispatch fields and a correlated confirmed Auth attempt/proof. It continues to omit root `schemaVersion` and persisted `displayName`.

### TDD Cycle Evidence

| Cycle | Evidence |
|---|---|
| RED | Added `isValidState(operation) === true` before filling the missing lifecycle fields; the completed-integrity command failed 1/10 at the canonical-state assertion. |
| GREEN | Added only `ownerToken`, `leaseExpiresAt`, `currentDispatchId`, `authAttempted`, and a fully correlated confirmed `authAttempt`; the focused completed-integrity command passed 10/10. |
| TRIANGULATE / REFACTOR | Exact status, DTO, authorization, and completed-integrity plan commands all passed; no production refactor was needed. |

- Exact commands passed: `cd functions && node --experimental-strip-types test/provisioning/status.test.ts` (7/7); `cd functions && node --experimental-strip-types test/provisioning/dto.test.ts` (69 assertions); `cd functions && node --experimental-strip-types test/provisioning/authz.test.ts` (14 assertions); `cd functions && node --experimental-strip-types test/provisioning/completed_integrity.test.ts` (10/10).
- Correction-only accounting: this execution inserted 12 lines in `functions/test/provisioning/completed_integrity.test.ts` and this append; no production file, `tasks.md`, P3.43+ path, config, dependency, generated file, or native settlement was changed. The test path is untracked and this progress file was already modified, so a slice-only Git numstat is not asserted.
- Verified invariant: `isValidState(operation) === true`; timestamps remain deterministic, reads remain all-settled, audit replay remains deterministic, terminal immutability and no-reset-link behavior remain covered.
- Persisted task checkboxes: P3.41 and P3.42 remain visibly `- [x]`; no task artifact mutation was made because the authorized surface forbids it.
- Workload / PR boundary: feature-branch-chain, P3.41/P3.42 test-fixture correction only. Structured status consumed was `gentle-ai.sdd-status` v2, `applyState:"ready"`, repo-local canonical workspace, and the sole allowed edit root; no action-context warning. Parent owns settlement with active token `sha256:e4b06a2f0b0c5dbffe16b6d66b8efca50623a8451f4fdc7f878e2d157689a85a` and must cite the failed evidence revision above.
