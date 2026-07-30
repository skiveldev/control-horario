# Tasks: Prepare Public Portfolio Repository

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: Accepted for P1a1 + P1b–P4 via maintainer size:exception; P1a2 sub-slices have NO size:exception
Delivery strategy: exception-ok (P1a1 + P1b–P4 only; P1a2 sub-slices use their own declared lower limits)
RDD routing: disabled — no automatic review activation. After cumulative backend emulator + TypeScript + independent phase-contract proof and candidate freeze at end of P3, surface explicit maintainer enable decision; no review before then.

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated aggregate changed lines (tasks-phase validated) | **8,115–10,735** |
| Aggregate ceiling | **None** — no invented aggregate ceiling; per-slice max governs |
| 400-line budget risk | Accepted for P1a1 + P1b–P4 via maintainer size:exception; P1a2 sub-slices have NO size:exception |
| Delivery strategy | exception-ok (P1a1 + P1b–P4 only; P1a2 sub-slices use their own declared lower limits) |
| Chain strategy | feature-branch-chain |
| Decision needed before apply | No (P1a1 + P1b–P4 size/chaining resolved; P1a2 sub-slices have explicit lower maxima) |
| Slice count | 10 chained implementation slices (P1a1, P1a2-i-A-1, P1a2-i-A-2, P1a2-i-B, P1a2-ii, P1a2-iii, P1b, P2, P3, P4) |
| Per-slice reforecast/STOP (P1a1 + P1b–P4 only) | 1,700 |
| Per-slice absolute max (P1a1 + P1b–P4 only) | 2,000 |
| P1a2-i-A absolute max | 600 (no size:exception) |
| P1a2-i-B absolute max | 600 (no size:exception) |
| P1a2-ii absolute max | 1,200 (no size:exception) |
| P1a2-iii absolute max | 1,200 (no size:exception) |
| Later independent chain | WU5–WU10 preserved (signing → de-branding → sanitization → README → archive → gates); each max 400, stop at 400; no inherited exception |

### Phase-Authority Decision

The previous `Decision needed before apply` workload/size question is resolved for P1a1 + P1b–P4: maintainer has explicitly approved `size:exception` up to 2,000 lines per slice for P1a1 and P1b–P4 only. **P1a2 sub-slices (i-A-1, i-A-2, i-B, ii, iii) do NOT have size:exception.** Each P1a2 sub-slice has its own declared lower maximum: P1a2-i-A-1 max 400, P1a2-i-A-2 max 300, P1a2-i-A combined max 600, P1a2-i-B max 600, P1a2-ii max 1,200, P1a2-iii max 1,200. WU5–WU10 retain ordinary max 400 per work unit; any future overrun in those work units requires a separate maintainer decision. Separately, **interactive phase approval + validated planning baseline** are still required before P1a1 may begin — that gate is about phase sequencing, not about size/chaining, and does not contradict the resolved workload decision.

### Supersession Notice

This revision **supersedes** the prior P1a plan. The single `P1a — Pure Contract + Model + Invariant Vectors` is replaced by two strictly separated slices: `P1a1 — Types + Normalization + IDs` and P1a2 (reducer + invariants). The prior P1a was invalidated by failed ordinal 22 (see below). P1a2 is further decomposed into five contract-complete sub-slices: `P1a2-i-A-1 — Immutable Vocabulary + Deep Freeze + Strict Guards`, `P1a2-i-A-2 — Validated Constructors + TypeScript Compatibility`, `P1a2-i-B — CAS Fence + Reducer Skeleton + Terminal/State/Data Immutability`, `P1a2-ii — Boundary Transitions + Auth Matrix + Crash Vectors`, `P1a2-iii — Terminalization Guards + Retry Thresholds`. The prior single P1a2 was invalidated by failed ordinals 27–28 (13 deterministic contract gaps, 2,178 lines). P1a2-i was further split into P1a2-i-A and P1a2-i-B after failed ordinal 29 (8 deterministic contract failures, 969 lines). P1a2-i-A was further split into P1a2-i-A-1 and P1a2-i-A-2 after failed ordinal 30 (8 deterministic contract failures, 529 lines). All downstream slices (P1b–P4) and later work units (WU5–WU10) are preserved architecturally; only their dependency edges shift where required by the P1a decomposition.

### Failed Ordinal 21 — Evidence (do NOT restore)

- **Ordinal 21** attempted the combined `P1-executable-contract-persistence` and produced **2,273 changed lines before any tests**: 1,893 source additions plus 380 apply-progress churn. It is invalid: implementation preceded behavior tests in violation of strict TDD, and the combined scope exceeded the reforecast/STOP threshold before the first RED test existed.
- **Stash**: `66424881e1b7b064a61d6bd884daa13f7793fa12` (visible as `stash@{0}: failed ordinal 21 P1 over-budget before tests`). Preserved as evidence only. **Never restore, copy, or cherry-pick this stash wholesale.** It may be inspected for line-accounting reference only.
- **Native authority** was explicitly reset after the maintainer decision; next action is `begin`, but this planning phase must not begin it.
- **Lesson applied here**: the combined slice is decomposed into independently executable slices, each with its own RED-first proof, rollback boundary, and reforecast/STOP discipline.

### Failed Ordinal 22 — Evidence (do NOT restore)

- **Ordinal 22** attempted the combined `P1a` and produced **2,679 all-path changed lines** (independent Git numstat), not the executor-reported 2,323.
- **Tracked**: 193 lines (`functions/tsconfig.json` 7 — **unauthorized**; apply-progress 116; tasks 70).
- **Untracked source/tests**: 2,486 lines: ids.ts 99, model.ts 533, normalize.ts 241, types.ts 119, fixtures.ts 121, ids.test.ts 147, model.test.ts 488, normalize.test.ts 381, types.test.ts 357.
- `functions/tsconfig.json` was **unauthorized** and must NOT be part of either P1a1 or P1a2. Tests must run using existing config/explicit CLI without config mutation.
- Executor-reported 112 green tests are **inadmissible** because of scope breach and undercount.
- **Stash**: `3ab7b419f344077b3c3b4667391b155700cfe9fe`. Preserved as evidence only. **Never restore, copy, cherry-pick, or carry completion checkboxes from it wholesale.**
- **Native authority** was explicitly reset at revision `sha256:6e04cd501986d26986f3caf6cd728c8520009b70b58d3533580ecde5378b6458`; next_action=begin. This planning phase must NOT begin it.
- **Lesson applied here**: P1a is further decomposed into P1a1 (types + normalization + IDs + fixtures — no reducer/model) and P1a2 (reducer + all invariant vectors — consuming frozen P1a1 contract). Each sub-slice has its own RED-first proof, rollback boundary, reforecast checkpoint at 1,500, mandatory STOP at 1,700, and absolute STOP before 2,000.

### Tasks-Phase Forecast Refinement

The tasks-phase forecast reflects honest per-slice sizing after the P1a decomposition into P1a1 + P1a2:

1. **First refinement (3,190–4,080)**: P4 was expanded to include the previously unallocated deferred Firestore rules hardening/proof.
2. **Second refinement (3,690–5,030)**: P4 expanded to full Flutter + Firestore rules footprint.
3. **Third refinement (5,425–7,410)**: P1 decomposed into P1a (pure contract/model) and P1b (persistence/conformance). Downstream ownership correction moves schemas/audit to P2 and profile to P3.
4. **Fourth refinement (6,865–8,865)**: P1a further decomposed into P1a1 (types + normalization + IDs + fixtures — no reducer/model) and P1a2 (reducer + all invariant vectors), driven by failed ordinal 22 (2,679 lines, stash `3ab7b419...`). Honest ordinal-22 measured data anchors the P1a1/P1a2 component tables.
5. **Fifth refinement (8,075–10,595)**: P1a2 further decomposed into P1a2-i (vocabulary + CAS fence + terminal immutability + state/data immutability + type guards), P1a2-ii (boundary transitions + Auth matrix + crash vectors + completion + dispatch safety), and P1a2-iii (terminalization guards + retry thresholds + negative probes), driven by failed ordinals 27–28 (2,178/2,182 lines, stash `213ff2fdf123bfa9c7b3b0ea0f83026a3b1f0306`, 13 deterministic contract gaps). Each sub-slice is independently contract-complete, targets <=1,200, and has no size:exception.
6. **Sixth refinement (8,145–10,785)**: P1a2-i further decomposed into P1a2-i-A (immutable vocabulary + runtime guards + TypeScript compatibility — no transitions) and P1a2-i-B (CAS fence + reducer skeleton + terminal/state/data immutability — only `reduce()` as public API), driven by failed ordinal 29 (969/1,200 lines, stash `527d4dfb2fd0bd30eacd7b09116bec3bda79250d`, 8 deterministic contract failures). Each sub-slice targets <=600 with combined max 1,200 and no size:exception.
7. **Seventh refinement (8,115–10,735)**: P1a2-i-A further decomposed into P1a2-i-A-1 (immutable vocabulary + deep freeze + strict guards — foundation consuming canonical P1a1 via `import type` only, no constructors, `Reflect.ownKeys`-based deep freeze) and P1a2-i-A-2 (validated constructors + TypeScript compatibility), driven by failed ordinal 30 (529/600 lines, stash `012c41516831e1579cd7162c378c123f503ee633`, 8 deterministic contract failures). P1a2-i-A-1 max 400 (STOP 350, expected 260–330), P1a2-i-A-2 max 300 (STOP 250, expected 120–170), combined P1a2-i-A max 600. No size:exception.

Per-slice breakdown (validated from ordinal-22 measured data + design grouping + downstream ownership):

| Slice | Focus | Expected |
|---|---|---:|
| P1a1 | Types + normalization + IDs + canonical fixtures (no reducer/model) | 1,400–1,650 |
| P1a2-i-A-1 | Immutable vocabulary + deep freeze + strict guards (foundation, consumes P1a1) | 260–330 |
| P1a2-i-A-2 | Validated constructors + TypeScript compatibility | 120–170 |
| P1a2-i-B | CAS fence + reducer skeleton + terminal/state/data immutability | 440–590 |
| P1a2-ii | Boundary transitions + Auth matrix + crash vectors + completion + dispatch safety | 850–1,100 |
| P1a2-iii | Terminalization guards + retry thresholds + negative probes | 630–830 |
| P1b | Persistence port + in-memory reference + Firestore emulator conformance + CAS primitives (narrowed) | 1,185–1,555 |
| P2 | Schemas + audit primitives + submission + reliable dispatch (former P1 schemas/audit + S4–S6) | 1,030–1,385 |
| P3 | Profile provenance + worker + status + full backend proof (former P1 profile + S7–S10) | 1,300–1,625 |
| P4 | Flutter migration + Firestore rules hardening/proof + dependency/bootstrap | 900–1,500 |
| **Total P1a1–P4** | | **8,115–10,735** |

### Per-Slice Exception Boundaries

| Slice | Early warning | STOP/reforecast | Absolute max | size:exception |
|---|---:|---:|---:|---|
| P1a1 | 1,500 | 1,700 | 2,000 | Accepted (committed 9167929) |
| P1a2-i-A-1 | 300 | 350 | 400 | **No** |
| P1a2-i-A-2 | 200 | 250 | 300 | **No** |
| P1a2-i-A combined | — | — | 600 | **No** |
| P1a2-i-B | 500 | 560 | 600 | **No** |
| P1a2-i combined | — | — | 1,200 | **No** |
| P1a2-ii | 1,100 | 1,200 | 1,200 | **No** |
| P1a2-iii | 1,100 | 1,200 | 1,200 | **No** |
| P1b | 1,500 | 1,700 | 2,000 | Accepted |
| P2 | 1,500 | 1,700 | 2,000 | Accepted |
| P3 | 1,500 | 1,700 | 2,000 | Accepted |
| P4 | 1,500 | 1,700 | 2,000 | Accepted |

WU5–WU10 do **not** inherit these boundaries. Each later work unit has max 400, stop at 400; any future overrun requires a separate maintainer decision.

### Line-Accounting Rules

- Per-slice expected range is the working budget for P1a1–P4.
- **P1a2-i-A-1, P1a2-i-A-2, P1a2-i-B, P1a2-ii, P1a2-iii do NOT inherit the P1a1/P1b–P4 size:exception.** P1a2-i-A-1 has early warning 300, STOP at 350, absolute max 400. P1a2-i-A-2 has early warning 200, STOP at 250, absolute max 300. Combined P1a2-i-A max 600. P1a2-i-B has early warning 500, STOP at 560, absolute max 600; combined P1a2-i (A-1+A-2+B) max 1,200. P1a2-ii and P1a2-iii each have early warning 1,100, STOP at 1,200, absolute max 1,200. If a coherent contract-complete slice cannot fit within its max, split it further — do NOT use size:exception.
- **Recount after every RED/GREEN pair**: measure all-path changed lines via Git-native counting only. **Tracked files**: `git diff --numstat <slice-baseline> -- <tracked paths>` (sum additions + deletions; no net accounting). **Untracked files (Windows PowerShell)**: `git diff --no-index --numstat -- NUL "<path>"` — exit code 1 is expected when differences exist; parse the numstat output for additions + deletions. **POSIX alternative**: `git diff --no-index --numstat -- /dev/null "<path>"`. Never use `Measure-Object -Line`.
- **Early warning**: P1a1/P1b–P4 at 1,500; P1a2-i-A-1 at 300; P1a2-i-A-2 at 200; P1a2-i-B at 500; P1a2-ii/iii at 1,100 — pause, assess remaining work, document.
- **STOP/reforecast**: P1a1/P1b–P4 at 1,700; P1a2-i-A-1 at 350; P1a2-i-A-2 at 250; P1a2-i-B at 560; P1a2-ii/iii at 1,200 — no further mutation without measured evidence and explicit continuation.
- **Absolute STOP**: P1a1/P1b–P4 before 2,000; P1a2-i-A-1 before 400 (STOP/reforecast at 350); P1a2-i-A-2 before 300 (STOP/reforecast at 250); combined P1a2-i-A before 600; P1a2-i-B before 600 (STOP/reforecast at 560); combined P1a2-i before 1,200; P1a2-ii/iii before 1,200 (STOP/reforecast at 1,200; hard max, no exception).
- WU5–WU10 each have max 400; if measured changed lines reach 400 within any of them, **STOP** — continuation requires a new, separate maintainer decision (no inherited exception).
- apply-progress reconciliation lines in P1a1 count inside P1a1's range. tasks.md update lines count inside the slice that introduces them.
- Test files count toward the slice they verify (no test-only slice).
- Tests are authored BEFORE the matching source in every RED→GREEN pair. A slice that has more source than failing tests at any commit boundary is invalid.
- Per-slice component forecasts MUST sum arithmetically to the headline range. No falsification.
- `functions/tsconfig.json` is **forbidden** in every slice — tests must run using existing config/explicit CLI without config mutation.

### Chain Topology (feature-branch-chain)

```
main
  └── feature/tracker (draft/no-merge) — accumulates final integration
        └── P1a1 branch (base: feature/tracker) — COMMITTED 9167929
              └── P1a2-i-A-1 branch (base: P1a1)
                    └── P1a2-i-A-2 branch (base: P1a2-i-A-1)
                          └── P1a2-i-B branch (base: P1a2-i-A-2)
                                └── P1a2-ii branch (base: P1a2-i-B)
                                      └── P1a2-iii branch (base: P1a2-ii)
                                            └── P1b branch (base: P1a2-iii)
                                                  └── P2 branch (base: P1b)
                                                        └── P3 branch (base: P2)
                                                              └── P4 branch (base: P3)

Independent later chain (after P4 merges into tracker, tracker merges into main):
main ──→ WU5 (signing) ──→ WU6 (de-branding) ──→ WU7 (sanitization) ──→ WU8 (README) ──→ WU9 (archive) ──→ WU10 (gates)
```

Each child PR targets its immediate previous slice branch. Only the tracker ultimately targets `main`. No branch, commit, or PR is created in this planning phase.

### Commit / Work-Unit Mapping and Rollback Order

| Order | Slice | Commit message (conventional) | PR target | Rollback order |
|---|---|---|---|---|
| 1 | P1a1 | `feat(provisioning): add canonical types, normalization, IDs, fixtures` | feature/tracker | 10 (last to revert) |
| 2 | P1a2-i-A-1 | `feat(provisioning): add immutable vocabulary, deep freeze, strict guards` | P1a1 branch | 9 |
| 3 | P1a2-i-A-2 | `feat(provisioning): add validated constructors, TypeScript compatibility` | P1a2-i-A-1 branch | 8 |
| 4 | P1a2-i-B | `feat(provisioning): add CAS fence, reducer skeleton, terminal/state/data immutability` | P1a2-i-A-2 branch | 7 |
| 5 | P1a2-ii | `feat(provisioning): add boundary transitions, Auth matrix, crash vectors, completion, dispatch safety` | P1a2-i-B branch | 6 |
| 6 | P1a2-iii | `feat(provisioning): add terminalization guards, retry thresholds, negative probes` | P1a2-ii branch | 5 |
| 7 | P1b | `feat(provisioning): add persistence port, memory/Firestore stores, CAS primitives` | P1a2-iii branch | 4 |
| 8 | P2 | `feat(provisioning): add schemas, audit, submission, dispatch, outbox, metadata` | P1b branch | 3 |
| 9 | P3 | `feat(provisioning): add profile, worker, status, full backend proof` | P2 branch | 2 |
| 10 | P4 | `feat(client): migrate provisioning to trusted backend; harden Firestore rules` | P3 branch | 1 (first to revert) |

Rollback order is reverse of commit order. Each rollback removes only the enumerated files/behavior for that slice. P1a1 is the last to revert because all other slices depend on its frozen contract.

## Authority Reconciliation and Historical Evidence

### Architecture Reset

The validated design replaces the callable-only saga with outbox + Cloud Tasks + scheduled-repair topology. Runtime is idle after explicit redesign reset at revision `sha256:6e04cd501986d26986f3caf6cd728c8520009b70b58d3533580ecde5378b6458`. Each runtime-bearing slice reads `gentle-ai sdd-attempt status`, begins exactly once only when `next_action=begin`, and finishes truthfully.

### Failed Ordinals (historical evidence only)

- **Ordinal 19**: failed; no completion carried forward.
- **Ordinal 20**: failed; no completion carried forward.
- **Ordinal 21**: failed combined P1; 2,273 lines before tests; stash `66424881e1b7b064a61d6bd884daa13f7793fa12`. Never restore.
- **Ordinal 22**: failed P1a; 2,679 all-path lines (Git numstat); unauthorized `functions/tsconfig.json`; stash `3ab7b419f344077b3c3b4667391b155700cfe9fe`. Never restore.
- **Ordinal 27**: failed P1a2 candidate; Git-native 2,178 lines, violating 1,700 STOP and 2,000 max; executor underreported 1,979. Stash `213ff2fdf123bfa9c7b3b0ea0f83026a3b1f0306`. Never restore.
- **Ordinal 28**: failed P1a2 candidate; used maintainer-approved size:exception max 2,300 and mechanically revalidated 2,182 lines, but fresh independent validation failed every contract group despite 76 green tests. 13 deterministic contract gaps identified. Same stash `213ff2fdf123bfa9c7b3b0ea0f83026a3b1f0306`. Never restore.
- **Ordinal 29**: failed P1a2-i; 969/1,200 lines; 8 deterministic contract failures. Stash `527d4dfb2fd0bd30eacd7b09116bec3bda79250d`. Never restore.
- **Ordinal 30**: failed P1a2-i-A; 529/600 lines; 8 deterministic contract failures. Stash `012c41516831e1579cd7162c378c123f503ee633`. Never restore.
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

No false completion is carried forward from failed ordinals 19/20/21/22. WU4b/WU4c are fully replaced by P1a1–P4. P1a remains incomplete; no checkboxes carried forward from ordinal 22.

### Planning Baseline

This `tasks.md` revision, the current `spec.md`, and the current `design.md` are the validated planning baseline. No `sdd-apply` slice may begin until this baseline is intact. Planning spec/design/tasks changes require their own validated planning baseline before any apply slice.

### apply-progress Reconciliation

The apply-progress reconciliation MUST occur in P1a1 after the first RED evidence is captured but before the matching GREEN source implementation. It is a metadata-only write to `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` that:

1. Records the architecture reset (outbox + Cloud Tasks + scheduled-repair design).
2. Records the stale WU4b/WU4c split, the combined-P1 plan, and the single-P1a plan as superseded by the 6-slice plan (P1a1, P1a2, P1b, P2, P3, P4).
3. Records ordinals 19/20/21/22 as failed (no false implementation completion).
4. Records stashes `66424881e1b7b064a61d6bd884daa13f7793fa12` and `3ab7b419f344077b3c3b4667391b155700cfe9fe` as evidence-only; never restored.
5. Preserves truthful WU0–WU4a completion byte-for-byte.
6. Does NOT claim any implementation progress.
7. Lines count inside P1a1's range.

## Executable Node Contract (strict TDD local harness)

- **Local Node prerequisite**: Node >= 22.6.0 (for `node --experimental-strip-types`).
- **Fail-fast version check**: every test/emulator invocation verifies `node --version` satisfies >= 22.6.0 and aborts otherwise.
- **Direct `.ts` invocation contract**: every direct `.ts` test invocation uses `node --experimental-strip-types` or an npm script routing to it.
- **TypeScript build separate**: `npx tsc --noEmit` is the type-checking command and is independent of the Node contract. **Important**: project `functions/tsconfig.json` has `rootDir: src` and `include: ["src"]`, so plain `npx tsc --noEmit` does NOT include test files. For test-file typechecking, use explicit `npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions <exact files>` targeting source and test files directly. `functions/tsconfig.json` is forbidden and must not be created or modified.
- **Strict TDD**: every behavior row requires RED before GREEN. No test may be retroactively labeled RED.

---

## P1a1 — Types + Normalization + IDs + Canonical Fixtures

**Objective**: author the independent pure domain contract — canonical vocabulary/types, payload normalization + fingerprint, deterministic ID derivation, and canonical frozen vector fixtures. **No reducer, no model, no state transitions, no invariant vectors.** No persistence of any kind. No Firestore, no in-memory store, no emulator — pure functions over frozen fixtures only. The reducer and all invariant vectors belong to P1a2 and consume the frozen P1a1 contract.

**Spec traceability**: Requirement: Operation Identity and Idempotency; Requirement: Application Audit and Observability Contract (identity shape only).

**Design traceability**: Canonical vocabulary; deterministic IDs.

**Depends on**: — (first slice; base = `feature/tracker`).

**Base / branch**: `slice/p1a1-types-normalization-ids` branched from `feature/tracker`.

**Allowed paths** (exact):

- `functions/src/provisioning/types.ts` (new — canonical vocabulary, status/phase/boundary/result/category type literals)
- `functions/src/provisioning/normalize.ts` (new — canonical payload normalization + fingerprint + derived displayName)
- `functions/src/provisioning/ids.ts` (new — deterministic dispatchId/taskId/auditEventId/attemptId/ownerToken/fingerprint derivation)
- `functions/test/provisioning/types.test.ts` (new — type-level rejection of invalid `(status, phase)` pairs; first authored mutation in P1a1)
- `functions/test/provisioning/normalize.test.ts` (new — normalization + fingerprint vectors)
- `functions/test/provisioning/ids.test.ts` (new — deterministic ID vectors)
- `functions/test/provisioning/fixtures.ts` (new — frozen canonical vectors, payloads, identities, expected transitions)
- `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping updates for P1a1 — counted in all-path totals)
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata-only reconciliation — after first RED evidence, before matching source; counted in all-path totals)

**Forbidden in P1a1**: no `model.ts`, no `store.ts`, no `memory_store.ts`, no `firestore_store.ts`, no `schemas.ts`, no `cas.ts`, no `audit.ts`, no `profile.ts`, no `firebase-admin` import, no emulator dependency, no callable, no dispatch, no worker, no Auth.createUser, no persistence of any kind, **no `functions/tsconfig.json`** (unauthorized — tests must run using existing config/explicit CLI).

**Native `sdd-attempt` contract**:
- Work unit: P1a1
- Evidence goal: types + normalization + IDs + fixtures all green
- max = 2,000
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

### Line-accounting checkpoints

- **Recount after every RED/GREEN pair**: measure all-path changed lines.
- **Early warning at 1,500**: pause, assess remaining work, document.
- **Reforecast/STOP at 1,700**: no further mutation without measured evidence and explicit continuation.
- **Absolute STOP before 2,000**: no further mutation under any circumstance.

### Strict TDD order (RED → GREEN)

- [x] P1a1.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 before every test invocation. Node v24.11.1 confirmed.
- [x] P1a1.1 RED (FIRST AUTHORED MUTATION): author `functions/test/provisioning/types.test.ts` first — the test file is authored before any source. TS2307: Cannot find module — genuine RED.
- [x] P1a1.2 METADATA (after RED evidence captured, before source): reconcile `apply-progress.md` and update `tasks.md`.
- [x] P1a1.3 GREEN: `types.ts` defined; only valid pairs compile; invalid pairs rejected at type level; `types.test.ts` passes (30/30 runtime + type-check clean). — the test file is authored before any source. The test asserts type-level rejection of invalid `(status, phase)` pairs: status vocabulary exactly `pending | active | completed | failed | manual_recovery`; phase vocabulary exactly `dispatch_pending | auth_preflight | auth_create | profile_commit | terminal`; only valid pairs allowed. RED evidence is authoritative via explicit `npx tsc` invocation targeting the test file directly (project `tsconfig.json` has `rootDir: src` and `include: ["src"]`, so plain `npx tsc --noEmit` does NOT include test files and cannot provide the planned RED):

  ```bash
  cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions test/provisioning/types.test.ts
  ```

  This command fails because `test/provisioning/types.test.ts` imports from `types.ts` which does not yet exist. Non-zero exit is the RED gate. The runtime `node --experimental-strip-types` invocation of the test is secondary for this row and serves only to prove the test harness is wired. **Recount all-path changed lines after RED evidence is captured.**
- [x] P1a1.4 RED: normalization vectors — `normalize.test.ts` authored before `normalize.ts`. TS2307: Cannot find module — genuine RED.
- [x] P1a1.5 GREEN: `normalize.ts` defined; normalization vectors pass (37/37 runtime + type-check clean).
- [x] P1a1.6 RED: fingerprint stability — same payload same digest, different payload different digest, operationId excluded.
- [x] P1a1.7 GREEN: fingerprint vectors pass (37/37 runtime + type-check clean).
- [x] P1a1.8 RED: deterministic ID vectors — `ids.test.ts` authored before `ids.ts`. TS2307: Cannot find module — genuine RED.
- [x] P1a1.9 GREEN: `ids.ts` defined; deterministic ID vectors pass (18/18 runtime + type-check clean).
- [x] P1a1.10 RED: canonical fixtures — `fixtures.ts` authored with frozen canonical vectors, payloads, identities, expected transitions; test assertions verify fixture integrity.
- [x] P1a1.11 GREEN: fixtures pass integrity assertions (self-validating + type-check clean).
- [x] P1a1.12 REFACTOR (ordinal 25 — FAILED): bounded remediation of six CRITICAL phase-contract groups. Native measured 1,675 correction lines; independent comparison measured 1,729; both exceed max 1,000. Full candidate independently measured 1,780, not 1,869. Ordinal 25 is NOT accepted; no completion carried forward.
- [x] P1a1.13 REFACTOR (ordinal 26 — ACCEPTED): native ordinal 26 passed at revision `sha256:2d693675feac2b8a87400a4f019a7b4e9f50f601fb65119d2dfc74d004875af4`. Final candidate `sha256:cbc789d9a27f5fd0df86747a72683ca94fabb2bca171d82adebe1f3fdc3c7aa2`, tree `d4860f7206707c0a91e13fdb79038efbc6bf4134`; full candidate 1,909/2,000 changed lines, ordinal-26 residual 361/400. Fresh independent validation: all five groups PASS. Proof: types 36/36, normalize 36/36, ids 32/32, fixture integrity + recursive immutability pass, explicit source+test tsc pass, source-only tsc pass, and `git diff --check` clean. P1a2 and downstream remain pending.

  ```bash
  cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts
  ```

  Zero exit = all P1a1 source and test files typecheck. Plain `npx tsc --noEmit` (project default) remains available as a source-only compatibility check but is NOT evidence that tests typechecked.

### Verification commands

- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions test/provisioning/types.test.ts` (authoritative for type-level RED at P1a1.1 — fails before `types.ts` exists)
- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts` (authoritative for type-level GREEN at P1a1.12 — all P1a1 source + test files)
- `cd functions && npx tsc --noEmit` (source-only compatibility check — does NOT verify test files; NOT evidence that tests typechecked)
- `cd functions && node --experimental-strip-types test/provisioning/types.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/normalize.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/ids.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/fixtures.ts`

### Rollback boundary

Revert `functions/src/provisioning/{types,normalize,ids}.ts`, delete `functions/test/provisioning/{types.test,normalize.test,ids.test,fixtures}.ts`, revert `apply-progress.md` and `tasks.md` to pre-P1a1 state. Pure TypeScript only — fully removable without unrelated rollback. No emulator state, no config change, no dependency change.

### Forbidden actions

No `model.ts`, no `store.ts`, no `memory_store.ts`, no `firestore_store.ts`, no `schemas.ts`, no `cas.ts`, no `audit.ts`, no `profile.ts`. No `firebase-admin` import. No Firestore emulator. No `functions/tsconfig.json` creation or modification. No submission callable. No outbox trigger. No scheduled sweeper. No task worker. No status callable. No Auth.createUser call. No push/PR/deploy. No modification of `spec.md` or `design.md`. No modification of `D:\control_horario`. No restoration of stash `3ab7b419f344077b3c3b4667391b155700cfe9fe` or `66424881e1b7b064a61d6bd884daa13f7793fa12`.

### Handoff contract to P1a2-i

Frozen pure types + frozen normalization/fingerprint + frozen deterministic IDs + frozen canonical vector fixtures. P1a2-i builds the pure reducer vocabulary, CAS fence, terminal immutability, state/data immutability, and type guards consuming this frozen P1a1 contract.

### P1a1 Forecast (component sum verified)

| Component | Expected lines |
|---|---:|
| `types.ts` | 105–125 |
| `normalize.ts` | 220–255 |
| `ids.ts` | 85–105 |
| `types.test.ts` | 330–375 |
| `normalize.test.ts` | 350–395 |
| `ids.test.ts` | 130–155 |
| `fixtures.ts` | 105–125 |
| `tasks.md` + `apply-progress.md` bookkeeping | 75–115 |
| **Total P1a1** | **1,400–1,650** |

Reforecast/STOP at 1,700; absolute max 2,000. Component sum verified: low 105+220+85+330+350+130+105+75 = 1,400; high 125+255+105+375+395+155+125+115 = 1,650.

---

## P1a2 — Reducer + Invariant Vectors (four sub-slices)

The prior single P1a2 block is replaced by four contract-complete sub-slices driven by 13 deterministic contract gaps found in failed ordinals 27–28 (stash `213ff2fdf123bfa9c7b3b0ea0f83026a3b1f0306`, evidence only — never restore) and 8 deterministic contract failures found in failed ordinal 29 (stash `527d4dfb2fd0bd30eacd7b09116bec3bda79250d`, evidence only — never restore). Each sub-slice is independently reviewable, has its own RED→GREEN cycle, and has no size:exception.

### Failed Ordinals 27–28 — Evidence (do NOT restore)

- **Ordinal 27**: Git-native 2,178 lines, violating 1,700 STOP and 2,000 max; executor underreported 1,979.
- **Ordinal 28**: Used maintainer-approved size:exception max 2,300 and mechanically revalidated 2,182 lines, but fresh independent validation failed every contract group despite 76 green tests. 13 deterministic contract gaps identified.
- **Stash**: `213ff2fdf123bfa9c7b3b0ea0f83026a3b1f0306`. Preserved as evidence only. **Never restore, copy, or cherry-pick.**
- **Deterministic contract gaps** (all MUST be prevented by the sub-slices below):

| # | Gap | Prevented by |
|---|---|---|
| 1 | `validateCAS` detached from reducer mutations; transitions checked partial fields, not full tuple | P1a2-i-B |
| 2 | Pending terminalization omitted fingerprint, dispatch source tuple, worker acknowledgement | P1a2-iii |
| 3 | Active terminalization lacked classifier; allowed expired/foreign/stale workers; wrong failed vs manual_recovery | P1a2-iii |
| 4 | Retry thresholds event-optional, off-by-one/unbounded; did not gate every normal-work event | P1a2-iii |
| 5 | Auth confirmation could proceed directly from intent; UID/email/dual-read absent; definite-no-effect lacked two-index evidence | P1a2-ii |
| 6 | Crash vectors were comments, not real reducer transitions | P1a2-ii |
| 7 | Completion did not model profile+completion+audit+ack as one pure transition | P1a2-ii |
| 8 | Payload/audit/dispatch/provenance/persisted-UID immutability missing | P1a2-i-B |
| 9 | Acquisition changed generation; takeover accepted arbitrary regression/jumps | P1a2-ii |
| 10 | Dispatch safety omitted next-dispatch/current-dispatch ack, orphan handling, idempotent enqueue | P1a2-ii |
| 11 | Terminal immutability covered only 6 of 12 event types | P1a2-i-B |
| 12 | Public helpers/classifiers and malformed states/events could bypass type guards | P1a2-i-A |
| 13 | Bookkeeping understated candidate size | P1a2-i-A/i-B/ii/iii (honest forecasts) |

### Failed Ordinal 29 — Evidence (do NOT restore)

- **Ordinal 29** attempted P1a2-i in 969/1,200 lines but failed fresh validation. Focused tests were green but proved a weaker, self-consistent contract.
- **Stash**: `527d4dfb2fd0bd30eacd7b09116bec3bda79250d`. Preserved as evidence only. **Never restore, copy, or cherry-pick.**
- **8 deterministic contract failures** (all MUST be prevented by the P1a2-i-A/P1a2-i-B split):

| # | Failure | Prevented by |
|---|---|---|
| 1 | Public `applyAcquire` bypassed CAS and implemented forbidden later-slice behavior | P1a2-i-A (no transitions); P1a2-i-B (only `reduce()` with mandatory CAS) |
| 2 | `reduce` did not enforce runtime state/event guards | P1a2-i-B (reduce enforces type guards + CAS before every mutation) |
| 3 | Active state with `leaseExpiresAt=null` passed CAS | P1a2-i-B (explicit null-lease rejection in CAS predicate) |
| 4 | Event/output vocabulary incomplete; `EVENT_TYPE_VALUES` was mutable | P1a2-i-A (complete frozen vocabulary; `Object.freeze` at every level) |
| 5 | Acquisition behavior drifted beyond authorized P1a2-i scope | P1a2-i-A (no transitions); P1a2-i-B (no boundary transitions — those are P1a2-ii) |
| 6 | Terminal rejection semantics conflicted with downstream terminal-idempotent success | P1a2-i-B (separate `ack_dispatch` from 11 state-transition events; terminal blocks state transitions only) |
| 7 | Runtime objects remained mutable despite readonly TypeScript types | P1a2-i-A (deep `Object.freeze`, not just `readonly` type annotations) |
| 8 | Project-default TypeScript command failed with TS5097 | P1a2-i-A (source-only `npx tsc --noEmit` compatibility; test files use explicit CLI flags) |

### Failed Ordinal 30 — Evidence (do NOT restore)

- **Ordinal 30** attempted P1a2-i-A in 529 lines (model.ts 217, model.test.ts 174, apply-progress 122, tasks 8+/8-) but failed fresh validation. Green mechanical checks proved a weaker contract. Only 31 lines remained before STOP 560; no bounded correction forecast was defensible.
- **Stash**: `012c41516831e1579cd7162c378c123f503ee633`. Preserved as evidence only. **Never restore, copy, or cherry-pick.**
- **8 deterministic contract failures** (all MUST be prevented by the P1a2-i-A-1/P1a2-i-A-2 split):

| # | Failure | Prevented by |
|---|---|---|
| 1 | Nested valid-pair arrays and Sets mutable — deep freeze did not traverse into nested arrays/objects | P1a2-i-A-1 (deep freeze traverses ALL children including arrays, even when parent already frozen) |
| 2 | Status/Phase/AuthResult/valid pairs duplicated instead of consuming canonical P1a1 | P1a2-i-A-1 (imports P1a1 types via `import type { ... } from './types.js'` only — no runtime import, no semantic duplication, no consumption of P1a1 mutable Set exports; model-owned runtime constants compile-time constrained via `satisfies`) |
| 3 | `createSuccessResult` accepted invalid state — constructor did not validate input | P1a2-i-A-2 (each constructor validates its own inputs with strict shape/exact-field/no-extra-field checks before freezing) |
| 4 | `createInitialState` accepted extra fields and malformed createdAt | P1a2-i-A-2 (exact plain-record validation: rejects extra keys, validates createdAt is valid Date/number) |
| 5 | `deepFreeze` skipped nested children when parent already frozen | P1a2-i-A-1 (deep freeze uses `Reflect.ownKeys()` covering string-keyed AND symbol-keyed own properties; always enumerates and recurses, even on already-frozen parents) |
| 6 | Tests lacked array push/index/delete, pre-frozen-parent, and deep mutation probes | P1a2-i-A-1 (comprehensive probe suite: array push/index-assign/delete, pre-frozen-parent nested mutation, deep nested object mutation at every level) |
| 7 | State/event guards accepted missing/extra/weak fields | P1a2-i-A-1 (strict guards: exact field set, no missing required fields, no extra fields, no weak-typed values; independent literal expectations) |
| 8 | Bookkeeping falsely claimed 449 and completion | P1a2-i-A-1/A-2 (honest per-untracked-file Git-native counting; no premature checkboxes) |

### Gap-to-Task Coverage Matrix

| Gap | Sub-slice | Explicit task(s) | Explicit test probe(s) |
|---|---|---|---|
| 1 — validateCAS detached | P1a2-i-B | P1a2-i-B.1 (CAS via reduce black-box), P1a2-i-B.4 (every transition requires CAS via reduce) | Per-field CAS mutation suite via `reduce()` — each of 8 CAS fields independently altered; stale mutation rejected by reduce; live tuple accepted by reduce. No exported CAS helper. |
| 2 — Pending terminalization incomplete | P1a2-iii | P1a2-iii.5 (full pending predicate) | Exhaustively mutate fingerprint, dispatch source, worker ack; every mismatch blocks `failed/unavailable` |
| 3 — Active terminalization classifier | P1a2-iii | P1a2-iii.7 (4-path classifier), P1a2-iii.8 (failed vs manual_recovery) | Exact-owner-live, foreign-owner-unexpired, expired-takeover, terminal-idempotent; correct outcome per path |
| 4 — Retry thresholds | P1a2-iii | P1a2-iii.1 (gate every normal-work event; exact domain 0–7 normal, 8–11 terminalize, non-integer/negative/>11 fail-closed), P1a2-iii.10 (boundary probes at -1, 0, 7, 8, 11, 12, malformed) | retryCount 0–7 allowed; 8–11 terminalize only; -1/negative/non-integer/>11 fail-closed; exact boundary at 7/8 and 11/12 |
| 5 — Auth confirmation from intent | P1a2-ii | P1a2-ii.7 (Auth result matrix), P1a2-ii.8 (dual-read proof) | Intent alone cannot confirm; must have exact UID+email reads+proof; definite-no-effect requires two-index absence |
| 6 — Crash vectors as comments | P1a2-ii | P1a2-ii.9 (real crash transitions) | Each crash point modeled as explicit event; reducer produces correct terminal/continuation state |
| 7 — Completion not atomic | P1a2-ii | P1a2-ii.10 (one pure transition) | Profile+completed+audit+ack appear together; partial commit rejected |
| 8 — Immutability missing | P1a2-i-B | P1a2-i-B.6 (data immutability) | Operation identity/payload/UID, audit identity, dispatch identity, provenance, Auth proof — every mutation rejected |
| 9 — Acquisition generation | P1a2-ii | P1a2-ii.3 (acquisition: no generation change), P1a2-ii.4 (takeover: exact +1) | Acquire with generation!=0 rejected; takeover with generation jump > +1 rejected |
| 10 — Dispatch safety | P1a2-ii | P1a2-ii.11 (dispatch ack, orphan, idempotent enqueue) | Duplicate/stale/out-of-order dispatches cause no regression; orphan dispatch rejected |
| 11 — Terminal immutability 6/12 | P1a2-i-B | P1a2-i-B.4 (all 11 state-transition event types × 3 terminal statuses + ack_dispatch × 3) | 11 state-transition types × 3 terminal statuses = 33 negative rejection vectors; ack_dispatch × 3 terminal statuses = 3 positive idempotency vectors; 36 total terminal vectors |
| 12 — Type guards bypass | P1a2-i-A-1 + P1a2-i-A-2 | P1a2-i-A-1.5 (strict guards), P1a2-i-A-2.3–5 (constructor input validation) | Malformed state/event rejected at type level and runtime with exact-field-set validation; deep freeze prevents mutation; constructors reject invalid state/extra fields/malformed values |
| 13 — Bookkeeping understated | P1a2-i-A-1/A-2/i-B/ii/iii | Each sub-slice has component-sum-verified forecast | Each sub-slice recount after every RED/GREEN pair |

---

## P1a2-i-A-1 — Immutable Vocabulary + Deep Freeze + Strict Guards (Foundation)

**Objective**: create `model.ts` with the complete state/event/output vocabulary consuming canonical P1a1 types (no duplication), deep runtime immutability via `Object.freeze` that correctly traverses ALL nested children including arrays even when a parent is already frozen, immutable vocabulary constants (no mutable `Set`), and strict type guards that reject malformed states/events with exact-field-set validation (no missing fields, no extra fields, no weak-typed values). This sub-slice creates the vocabulary skeleton, deep-freeze primitive, and strict guards WITHOUT any constructors, transitions, CAS, or reducer logic.

**Ordinal-30 failures addressed**: 1 (nested arrays/Sets mutable), 2 (vocabulary duplication of P1a1), 5 (deepFreeze skipped nested when parent frozen), 6 (tests lacked comprehensive mutation probes), 7 (guards accepted missing/extra/weak fields), and partially 8 (honest counting).

**Spec traceability**: Requirement: Operation Invariants (vocabulary shape); Requirement: Operation Identity and Idempotency (identity shape only).

**Design traceability**: "Executable Contract Before Production Code"; canonical vocabulary; invariant table (vocabulary shape only).

**Depends on**: P1a1 (frozen types + normalization + IDs + fixtures).

**Base / branch**: `slice/p1a2-i-a-1-immutable-vocabulary` branched from `slice/p1a1-types-normalization-ids` (commit `860f3c3`).

**Allowed paths** (exact):

- `functions/src/provisioning/model.ts` (new — vocabulary ONLY: re-exports/consumption of P1a1 types via `import type`, state shape interfaces, complete event type union with all 12 event types, output type union, `deepFreeze` utility, strict type guards, vocabulary constants as frozen arrays)
- `functions/test/provisioning/model.test.ts` (new — vocabulary completeness, deep freeze traversal probes, strict guard probes; FIRST AUTHORED MUTATION in P1a2-i-A-1)
- `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping)
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates)

**Forbidden in P1a2-i-A-1**: no constructors (`createInitialState`, `createEvent`, `createSuccessResult`, `createFailureResult` — those are P1a2-i-A-2), no `reduce()` function, no CAS predicate, no transition logic, no acquisition, no takeover, no auth transitions, no completion, no terminalization, no dispatch safety transitions. No `types.ts`/`normalize.ts`/`ids.ts`/`fixtures.ts` modification (frozen from P1a1). No `store.ts`, no `memory_store.ts`, no `firestore_store.ts`, no `schemas.ts`, no `cas.ts`, no `audit.ts`, no `profile.ts`, no `firebase-admin` import, no emulator dependency, no callable, no dispatch handler, no worker, no Auth.createUser, no persistence, **no `functions/tsconfig.json`**. No semantic duplication of P1a1 Status/Phase/AuthResult/valid-pair types — consume via `import type` only. No regular runtime import from `./types.js` (no built `types.js` exists; `node --experimental-strip-types` does not remap `.js` to `.ts`). No consumption of P1a1's mutable `Set` exports (`STATUS_VALUES`, `PHASE_VALUES`, etc.).

**Type-only import mechanism**: P1a2-i-A-1 consumes P1a1 canonical types via `import type { ProvisioningStatus, ProvisioningPhase, TerminalStatus, AuthAttemptResult, AuditCategory, StatusPhasePair } from './types.js'` — `import type` only, erased at runtime, NodeNext-compatible `.js` specifier, works with `node --experimental-strip-types` and `npx tsc --noEmit` without TS5097. No regular `import` from `./types.js` — there is no built output; the runtime uses raw `.ts` files. Model-owned runtime vocabulary constants (event type arrays, status/phase mapping tables) are defined locally in `model.ts` and compile-time constrained against imported P1a1 aliases using `satisfies` plus explicit type-level completeness/equality checks (no missing or extra union members). Valid status→phase mapping is a deeply frozen model-owned table constrained as `Record<ProvisioningStatus, readonly ProvisioningPhase[]>`, with independent literal tests and type-level compatibility with `StatusPhasePair`. Compile-time canonical type consumption and model-owned runtime constants are explicitly distinguished.

### Strict TDD order (RED → GREEN)

- [ ] P1a2-i-A-1.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [ ] P1a2-i-A-1.1 RED (FIRST AUTHORED MUTATION): author `functions/test/provisioning/model.test.ts` first — vocabulary completeness tests, deep freeze traversal tests (including array push/index/delete, pre-frozen-parent nested mutation, deep nested object mutation at every level), strict guard tests (missing fields, extra fields, weak-typed values all rejected with independent literal expectations). All fail because `model.ts` does not yet exist. RED via explicit `npx tsc` invocation:

  ```bash
  cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts
  ```

- [ ] P1a2-i-A-1.2 METADATA: update `tasks.md` and `apply-progress.md`. Recount all four paths.
- [ ] P1a2-i-A-1.3 GREEN — Immutable vocabulary consuming P1a1: define all 12 event types as a frozen array (`as const`), not a mutable `Set`. Consume Status/Phase/AuthAttemptResult/AuditCategory types from P1a1 via `import type { ... } from './types.js'` — no semantic duplication, no runtime import of P1a1 values. Define model-owned runtime constants (event type array, status→phase mapping) locally in `model.ts`, compile-time constrained via `satisfies Record<ProvisioningStatus, readonly ProvisioningPhase[]>` against imported P1a1 aliases. Define `TransitionResult` discriminated union. Define state shape interfaces (`OperationState`, `AuthAttempt`, `FailureEvidence`, `RetryEvidence`). All vocabulary constants deeply frozen. Tests pass: vocabulary completeness (12 types), no duplication of P1a1 types, status→phase mapping type-compatible with `StatusPhasePair`, independent literal tests for mapping completeness.
- [ ] P1a2-i-A-1.4 RED → GREEN — Deep runtime immutability: `deepFreeze<T>(obj: T): Readonly<T>` utility that recursively freezes ALL levels. Critical: uses `Reflect.ownKeys()` to enumerate ALL own properties (string-keyed AND symbol-keyed, including non-enumerable), recurses into each value BEFORE freezing the parent, handles arrays (freeze each element first, then the array), handles nested objects at every depth. Even if a parent is already frozen, children that were added before freezing must still be traversed and frozen. Strict guards explicitly reject symbol-keyed extras on guarded plain records (guarded data constrained to exact plain string-keyed records; any symbol-keyed property causes rejection). Tests: comprehensive probe suite — array push rejected, array index assignment rejected, array delete rejected, nested object mutation at every level rejected, pre-frozen-parent with unfrozen nested children → after deepFreeze ALL levels frozen, symbol-keyed property on guarded record → guard rejects. NOT just `readonly` type annotations — actual runtime `Object.freeze` at every level via `Reflect.ownKeys` traversal.
- [ ] P1a2-i-A-1.5 RED → GREEN — Strict type guards: `isEventType(value)`, `isStatus(value)`, `isPhase(value)`, `isValidState(value)`, `isValidEvent(value)`. Strict validation: exact field set (no missing required fields, no extra fields), correct types for every field (no weak-typed values like `any` or overly broad unions). Tests use independent literal expectations — each test constructs a specific malformed shape and asserts rejection. Probes: missing required field → false; extra unknown field → false; wrong type for known field → false; null where object expected → false; undefined where string expected → false.
- [ ] P1a2-i-A-1.6 REFACTOR: freeze P1a2-i-A-1. Final type-level GREEN via explicit `npx tsc`:

  ```bash
  cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts
  ```

  ```bash
  cd functions && npx tsc --noEmit
  ```

  Both commands pass. Second is source-only compatibility proof (no TS5097).

### Verification commands

- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts` (type-level RED — fails before `model.ts`)
- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts` (type-level GREEN — all P1a1+P1a2-i-A-1 files)
- `cd functions && npx tsc --noEmit` (source-only compatibility — no TS5097)
- `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` (runtime GREEN)
- Git-native count (Windows PowerShell): **tracked bookkeeping** — `git diff --numstat <P1a1-baseline> -- openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md`. **Untracked files** (both created new by P1a2-i-A-1; exit code 1 expected for each):
  - `git diff --no-index --numstat -- NUL "functions/src/provisioning/model.ts"`
  - `git diff --no-index --numstat -- NUL "functions/test/provisioning/model.test.ts"`
  Parse each numstat output for additions + deletions; sum across all four paths (2 tracked + 2 untracked).

### Independent phase-contract acceptance (UNCHECKED — fresh context)

- [ ] All 12 event types defined and frozen (no mutable Set)
- [ ] P1a1 types consumed ONLY via `import type { ... } from './types.js'` — no runtime import, no `Set` consumption, no semantic duplication
- [ ] Model-owned runtime constants compile-time constrained via `satisfies` against imported P1a1 aliases; status→phase mapping type-compatible with `StatusPhasePair`
- [ ] Deep freeze uses `Reflect.ownKeys()` — covers string-keyed AND symbol-keyed own properties; recurses into ALL children including arrays, even when parent already frozen
- [ ] Comprehensive mutation probes: array push/index/delete, pre-frozen-parent nested, deep nested at every level, symbol-keyed extras rejected by guards
- [ ] Strict guards: no missing fields, no extra fields, no weak-typed values, no symbol-keyed extras; independent literal expectations
- [ ] No constructors, no `reduce()`, no CAS predicate, no transition logic, no boundary behavior
- [ ] No `functions/tsconfig.json` modification

### Rollback boundary

Revert `functions/src/provisioning/model.ts`, delete `functions/test/provisioning/model.test.ts`, revert `tasks.md` and `apply-progress.md` to pre-P1a2-i-A-1 state. P1a1 intact. Pure TypeScript only.

### P1a2-i-A-1 Forecast (component sum verified)

| Component | Expected lines |
|---|---:|
| `model.ts` (vocabulary + deepFreeze via Reflect.ownKeys + strict guards + state shapes, consuming P1a1 via import type) | 140–170 |
| `model.test.ts` (vocabulary + deep freeze traversal probes + strict guard probes + symbol-key rejection) | 100–130 |
| `tasks.md` + `apply-progress.md` bookkeeping | 20–30 |
| **Total P1a2-i-A-1** | **260–330** |

Early warning at 300; STOP/reforecast at 350; absolute max 400. No size:exception. Component sum verified: low 140+100+20 = 260; high 170+130+30 = 330. High 330 is below STOP 350.

### Handoff contract to P1a2-i-A-2

Frozen vocabulary (12 event types, state shape interfaces, output types), deep freeze primitive (correctly traverses all nested children including arrays even when parent already frozen), strict type guards (exact field set, no missing/extra/weak fields), source-only TypeScript compatibility. P1a2-i-A-2 builds the four validated constructors on top of this frozen foundation.

---

## P1a2-i-A-2 — Validated Constructors + TypeScript Compatibility

**Objective**: implement all four non-transition constructors (`createInitialState`, `createEvent`, `createSuccessResult`, `createFailureResult`) that validate their own inputs with strict shape/exact-field/no-extra-field checks before deep-freezing outputs. Each constructor rejects invalid state, extra fields, and malformed values. Source-only TypeScript compatibility (`npx tsc --noEmit` works without TS5097). No transition behavior, no CAS, no reducer logic.

**Ordinal-30 failures addressed**: 3 (`createSuccessResult` accepted invalid state), 4 (`createInitialState` accepted extra fields and malformed createdAt), 8 (TS5097/honest counting — partially via separate slice).

**Spec traceability**: Requirement: Operation Invariants (constructor shape); Requirement: Operation Identity and Idempotency (initial state shape).

**Design traceability**: "Executable Contract Before Production Code"; canonical vocabulary.

**Depends on**: P1a2-i-A-1 (frozen vocabulary + deep freeze + strict guards).

**Base / branch**: `slice/p1a2-i-a-2-validated-constructors` branched from `slice/p1a2-i-a-1-immutable-vocabulary`.

**Allowed paths** (exact):

- `functions/src/provisioning/model.ts` (extend — add four constructors: `createInitialState`, `createEvent`, `createSuccessResult`, `createFailureResult`)
- `functions/test/provisioning/model.test.ts` (extend — add constructor input-validation probes)
- `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping)
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates)

**Forbidden in P1a2-i-A-2**: all P1a2-i-A-1 forbidden paths remain. Additionally: no modification of P1a2-i-A-1 frozen vocabulary, deep freeze, or type guards. No `reduce()`, no CAS predicate, no transition logic, no boundary behavior.

### Strict TDD order (RED → GREEN)

- [ ] P1a2-i-A-2.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [ ] P1a2-i-A-2.1 RED — Constructor input validation: tests for all four constructors with invalid inputs. `createInitialState` with extra fields → rejected; with malformed createdAt → rejected; with missing required fields → rejected. `createSuccessResult` with invalid state (wrong status/phase pair, missing fields) → rejected. `createEvent` with unknown event type → rejected; with missing payload fields → rejected. `createFailureResult` with empty reason → rejected. Tests fail because constructors don't exist yet.
- [ ] P1a2-i-A-2.2 METADATA: update `tasks.md` and `apply-progress.md`. Recount.
- [ ] P1a2-i-A-2.3 GREEN — `createInitialState(params)`: validates exact input shape (no extra keys, all required fields present, createdAt is valid Date/number, status is valid, phase matches status). Rejects extra fields, malformed createdAt, invalid status/phase pairs. Returns deeply frozen `OperationState`. No transition behavior.
- [ ] P1a2-i-A-2.4 RED → GREEN — `createEvent(type, payload)`: validates event type (must be one of 12), validates payload shape per event type. Rejects unknown types, missing payload fields, extra payload fields. Returns deeply frozen event object. No transition behavior.
- [ ] P1a2-i-A-2.5 RED → GREEN — `createSuccessResult(state)` and `createFailureResult(reason)`: `createSuccessResult` validates state via `isValidState()` guard (from P1a2-i-A-1) before freezing; rejects invalid state. `createFailureResult` validates non-empty reason string. Both return deeply frozen `TransitionResult`. No transition behavior.
- [ ] P1a2-i-A-2.6 RED → GREEN — Source-only TypeScript compatibility: `npx tsc --noEmit` passes. No TS5097.
- [ ] P1a2-i-A-2.7 REFACTOR: freeze P1a2-i-A-2. Final type-level GREEN via explicit `npx tsc`:

  ```bash
  cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts
  ```

  ```bash
  cd functions && npx tsc --noEmit
  ```

  ```bash
  cd functions && node --experimental-strip-types test/provisioning/model.test.ts
  ```

### Verification commands

- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts` (type-level GREEN — all P1a1+P1a2-i-A-1+P1a2-i-A-2 files)
- `cd functions && npx tsc --noEmit` (source-only compatibility — no TS5097)
- `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` (runtime GREEN)
- Git-native count (Windows PowerShell): all paths tracked after P1a2-i-A-1 commit — `git diff --numstat <P1a2-i-A-1-baseline> -- functions/src/provisioning/model.ts functions/test/provisioning/model.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md`; sum additions + deletions.

### Independent phase-contract acceptance (UNCHECKED — fresh context)

- [ ] `createInitialState` rejects extra fields, malformed createdAt, missing required fields
- [ ] `createSuccessResult` rejects invalid state (wrong status/phase pair, missing fields)
- [ ] `createEvent` rejects unknown types, missing/extra payload fields
- [ ] `createFailureResult` rejects empty reason
- [ ] All constructors deep-freeze their outputs using P1a2-i-A-1's `deepFreeze`
- [ ] No constructors perform transitions, CAS, acquisition, or reducer behavior
- [ ] Source-only `npx tsc --noEmit` passes (no TS5097)

### Rollback boundary

Revert `functions/src/provisioning/model.ts` to P1a2-i-A-1 frozen state, revert `functions/test/provisioning/model.test.ts` to P1a2-i-A-1 frozen state, revert `tasks.md` and `apply-progress.md` to pre-P1a2-i-A-2 state. P1a1 + P1a2-i-A-1 intact.

### P1a2-i-A-2 Forecast (component sum verified)

| Component | Expected lines |
|---|---:|
| `model.ts` extensions (four constructors with input validation) | 50–70 |
| `model.test.ts` extensions (constructor input-validation probes) | 50–70 |
| `tasks.md` + `apply-progress.md` bookkeeping | 20–30 |
| **Total P1a2-i-A-2** | **120–170** |

Early warning at 200; STOP/reforecast at 250; absolute max 300. No size:exception. Component sum verified: low 50+50+20 = 120; high 70+70+30 = 170. High 170 is below STOP 250.

### P1a2-i-A Combined Forecast

| Sub-slice | Expected |
|---|---:|
| P1a2-i-A-1 | 260–330 |
| P1a2-i-A-2 | 120–170 |
| **Total P1a2-i-A** | **380–500** |

Combined absolute max: 600. No size:exception. No combined early warning or STOP — only explicit per-sub-slice limits (A-1: EW 300, STOP 350, max 400; A-2: EW 200, STOP 250, max 300).

---

## P1a2-i-B — CAS Fence + Reducer Skeleton + Terminal/State/Data Immutability

**Objective**: build the pure reducer with module-private CAS predicate integrated into every transition, terminal immutability for 11 state-transition event types × 3 terminal statuses = 33 negative rejection vectors (with `ack_dispatch` × 3 terminal statuses = 3 positive idempotency vectors separated), monotonic state invariants (version on every mutation), and data immutability (5 classes). The ONLY public transition API is `reduce(state, event)` — no named transition functions, no public `applyAcquire`, no public `applyTakeover`, no public classifiers, no exported CAS helper.

**Ordinal-29 failures addressed**: 1 (no public bypass — only `reduce()`), 2 (reduce enforces guards), 3 (null-lease fails CAS), 5 (no acquisition drift — acquisition is P1a2-ii), 6 (ack_dispatch separated from state transitions), 8+11 (terminal immutability covers all 12 types).

**Spec traceability**: Requirement: Operation Invariants (terminal immutability, CAS, monotonic state, data immutability).

**Design traceability**: Full CAS and lease contract; invariant table.

**Depends on**: P1a2-i-A-2 (frozen vocabulary + deep freeze + strict guards + validated constructors).

**Base / branch**: `slice/p1a2-i-b-cas-reducer` branched from `slice/p1a2-i-a-2-validated-constructors`.

**Allowed paths** (exact):

- `functions/src/provisioning/model.ts` (extend — add `validateCAS`, `reduce()`, terminal immutability, monotonic state, data immutability, dispatch acknowledgement)
- `functions/test/provisioning/model.test.ts` (extend — add CAS per-field suite, terminal 12×3, monotonic, data immutability, dispatch ack idempotency)
- `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping)
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates)

**Forbidden in P1a2-i-B**: all P1a2-i-A forbidden paths remain. Additionally: no boundary transition implementations (acquire/takeover/auth/create/complete — those are P1a2-ii), no terminalization implementations (those are P1a2-iii). No modification of P1a2-i-A frozen vocabulary, deep freeze, or type guards. No named public transition functions (only `reduce()`).

### Strict TDD order (RED → GREEN)

- [ ] P1a2-i-B.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [ ] P1a2-i-B.1 RED — CAS fence (black-box via reduce): tests exercise `reduce(state, event)` with each of 8 CAS fields (fingerprint, status, phase, generation, version, ownerToken, currentDispatchId, leaseExpiresAt) independently altered from the expected live tuple. Tests also verify lease liveness (leaseExpiresAt=null fails for active mutations). `reduce()` rejects every stale mutation. Tests fail because `reduce()` does not yet enforce CAS.
- [ ] P1a2-i-B.2 GREEN — CAS fence: `reduce()` enforces all 8 CAS fields + lease liveness via module-private `validateCAS` (not exported). Explicit: `leaseExpiresAt=null` fails CAS for active mutations. Every field mismatch fails via `reduce()`. Exact live tuple passes via `reduce()`. No exported CAS function; CAS behavior proven only through `reduce()` black-box outcomes. Tests pass.
- [ ] P1a2-i-B.3 RED → GREEN — Terminal immutability (11 state-transition event types): every state-transition event (all 12 event types EXCEPT `ack_dispatch`) against each of 3 terminal statuses (`completed`, `failed`, `manual_recovery`) is rejected without mutation. 11 × 3 = 33 negative rejection vectors. `ack_dispatch` is NOT a state-transition event — it is idempotent and allowed against all 3 terminal statuses (3 positive idempotency vectors, not negative). Total terminal vectors: 33 negative + 3 positive = 36. Tests use independent expected outcomes.
- [ ] P1a2-i-B.4 RED → GREEN — Reducer skeleton: `reduce(state, event)` is the ONLY public transition API. It validates event type (type guard), validates state (type guard), checks terminal immutability for non-ack events, calls `validateCAS` before any non-terminal mutation. No named transition functions. No public `applyAcquire`, `applyTakeover`, etc. Tests: every mutation path goes through `reduce()`; no bypass exists.
- [ ] P1a2-i-B.5 RED → GREEN — Monotonic state: version increments on every successful mutation available in P1a2-i-B; no event available in i-B changes generation (boundary events like acquire/takeover are not implemented in i-B and are rejected as unsupported without mutation). Tests: version increments on every successful i-B transition; no i-B event changes generation. Exact takeover +1 generation success is proven solely in P1a2-ii.
- [ ] P1a2-i-B.6 RED → GREEN — Data immutability: operation identity (operationId, fingerprint, intendedUid), normalized payload, audit identity (eventId fields), dispatch identity (dispatchId, taskId, boundary, generation, sourceVersion), provisioning provenance fields, and Auth proof (once confirmed) cannot change after creation. Tests: every mutation attempt on immutable fields rejected.
- [ ] P1a2-i-B.7 RED → GREEN — Dispatch acknowledgement idempotency: `ack_dispatch` event against terminal state succeeds without mutation (idempotent). `ack_dispatch` against non-terminal state succeeds with guarded update. Tests: terminal ack idempotent; non-terminal ack guarded.
- [ ] P1a2-i-B.8 REFACTOR: freeze P1a2-i-B. Final type-level GREEN via explicit `npx tsc`:

  ```bash
  cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts
  ```

  ```bash
  cd functions && npx tsc --noEmit
  ```

  ```bash
  cd functions && node --experimental-strip-types test/provisioning/model.test.ts
  ```

### Verification commands

- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts` (type-level GREEN — all P1a1+P1a2-i-A+P1a2-i-B files)
- `cd functions && npx tsc --noEmit` (source-only compatibility — no TS5097)
- `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` (runtime GREEN)
- Git-native count (Windows PowerShell): all paths tracked after P1a2-i-A commit — `git diff --numstat <P1a2-i-A-baseline> -- functions/src/provisioning/model.ts functions/test/provisioning/model.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md`; sum additions + deletions.

### Independent phase-contract acceptance (UNCHECKED — fresh context)

- [ ] `reduce()` enforces all 8 CAS fields + lease liveness via module-private CAS predicate (not exported); `leaseExpiresAt=null` fails
- [ ] All 11 state-transition event types × 3 terminal statuses = 33 negative rejection vectors pass; `ack_dispatch` × 3 terminal statuses = 3 positive idempotency vectors pass (36 total terminal vectors)
- [ ] `ack_dispatch` is separated from state transitions; idempotent against terminal states
- [ ] `reduce()` is the ONLY public transition API; no bypass functions exist
- [ ] Monotonic state: version on every successful i-B mutation; no i-B event changes generation; boundary events rejected as unsupported
- [ ] Data immutability: 5 classes all reject mutation
- [ ] No boundary transition implementations (those are P1a2-ii)
- [ ] No terminalization implementations (those are P1a2-iii)
- [ ] All expected states in tests are independent (not derived from production helpers)

### Rollback boundary

Revert `functions/src/provisioning/model.ts` to P1a2-i-A frozen state, revert `functions/test/provisioning/model.test.ts` to P1a2-i-A frozen state, revert `tasks.md` and `apply-progress.md` to pre-P1a2-i-B state. P1a1 + P1a2-i-A intact.

### P1a2-i-B Forecast (component sum verified)

| Component | Expected lines |
|---|---:|
| `model.ts` extensions (module-private CAS + reduce + terminal 11×3 + ack 3 + monotonic + data immutability + dispatch ack) | 200–260 |
| `model.test.ts` extensions (CAS per-field via reduce + terminal 11×3 + ack 3 + monotonic + data immutability + dispatch ack) | 220–290 |
| `tasks.md` + `apply-progress.md` bookkeeping | 20–40 |
| **Total P1a2-i-B** | **440–590** |

Early warning at 500; STOP/reforecast at 560; absolute max 600. No size:exception. Component sum verified: low 200+220+20 = 440; high 260+290+40 = 590.

### P1a2-i Combined Forecast

| Sub-slice | Expected |
|---|---:|
| P1a2-i-A-1 | 260–330 |
| P1a2-i-A-2 | 120–170 |
| P1a2-i-B | 440–590 |
| **Total P1a2-i** | **820–1,090** |

Combined absolute max: 1,200. No size:exception.

### Handoff contract to P1a2-ii

Frozen immutable vocabulary + frozen deep runtime immutability + frozen type guards + frozen module-private CAS predicate + frozen `reduce()` as ONLY public API + frozen terminal immutability (11 state-transition types × 3 terminal = 33 negative rejection + ack_dispatch × 3 = 3 positive idempotency) + frozen monotonic state (version on every successful i-B mutation; no i-B event changes generation) + frozen data immutability + frozen dispatch acknowledgement. P1a2-i-B does NOT implement or prove boundary transitions. **Exact acquisition (generation unchanged) and exact takeover (+1 monotonic generation) success/failure are proven solely in P1a2-ii.**

---

## P1a2-ii — Boundary Transitions + Auth Matrix + Crash Vectors + Completion + Dispatch Safety

**Objective**: implement all boundary transitions (acquisition without generation change, takeover with exact +1 monotonic generation fence), Auth create result matrix (all 5 design rows with mandatory UID/email dual-read and proof), crash-point vectors as REAL reducer transitions (not comments), completion as one atomic pure transition (profile + completed + success audit + current dispatch ack), and dispatch safety (next-dispatch creation, current-dispatch ack, orphan handling, idempotent enqueue semantics).

**Gaps addressed**: 5 (Auth confirmation from intent), 6 (crash vectors real), 7 (completion atomic), 9 (acquisition generation / takeover fence), 10 (dispatch safety).

**Spec traceability**: Requirement: Auth Ambiguity and Reconstruction; Requirement: Completion Atomic Commitment; Requirement: First-Slice Compensation Policy; Requirement: Operation Invariants.

**Design traceability**: Worker acquisition and intent; Auth create result matrix; Profile and completion; Boundary and crash protocol.

**Depends on**: P1a2-i-B (frozen vocabulary + CAS fence + reducer skeleton + terminal/state/data immutability).

**Base / branch**: `slice/p1a2-ii-boundary-transitions` branched from `slice/p1a2-i-b-cas-reducer`.

**Allowed paths** (exact):

- `functions/src/provisioning/model.ts` (extend — add acquisition, takeover, Auth preflight/intent/create/confirm/definite-no-effect/foreign, crash-point transitions, completion transition, dispatch safety transitions)
- `functions/test/provisioning/model.test.ts` (extend — add all boundary/Auth/crash/completion/dispatch tests with independent expected states)
- `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping)
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates)

**Forbidden in P1a2-ii**: all P1a2-i-A and P1a2-i-B forbidden paths remain. Additionally: no terminalization implementations (those are P1a2-iii). No modification of P1a2-i-A frozen vocabulary/guards/immutability or P1a2-i-B frozen CAS/reducer/terminal-state invariants.

### Strict TDD order (RED → GREEN)

- [ ] P1a2-ii.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [ ] P1a2-ii.1 RED: acquisition transition — pending/dispatch_pending with exact initial predicate (fingerprint, generation=0, version=0, ownerToken=null, leaseExpiresAt=null, authAttempted=false, exact unacknowledged acquire dispatch). **No generation change.** Tests fail because transition not implemented.
- [ ] P1a2-ii.2 GREEN: acquisition passes; generation remains 0; version increments to 1; owner token installed; lease set; phase transitions to active/auth_preflight; acquire dispatch acknowledged.
- [ ] P1a2-ii.3 RED → GREEN — Takeover: requires exact +1 monotonic generation fence (no regression, no jumps > +1). Full expired-lease predicate. New owner token derived from dispatch ID + new generation. Tests: takeover with generation jump > +1 rejected; takeover with regression rejected; valid +1 takeover succeeds.
- [ ] P1a2-ii.4 RED → GREEN — Negative probe (Gap 9 direct): acquire with generation != 0 rejected; acquire with non-null ownerToken rejected; takeover with arbitrary generation accepted only at exact +1.
- [ ] P1a2-ii.5 RED → GREEN — Auth preflight: mandatory UID + email reads before any create. Foreign UID/email before any intent -> `failed/already-exists`. No Auth mutation on foreign path.
- [ ] P1a2-ii.6 RED → GREEN — Auth intent: one transaction flips `authAttempted=true`, persists `authAttempt.result=intent`, audit, version, deterministic `auth_create` dispatch, current dispatch ack.
- [ ] P1a2-ii.7 RED → GREEN — Auth create result matrix (all 5 rows): (a) exact live intent CAS to `call_started`; (b) exact returned UID + email + mandatory dual reads agreeing -> `active/profile_commit` + immutable proof; (c) malformed/ambiguous/timeout/crash -> `manual_recovery` (no delete, no retry create); (d) definite no-effect with BOTH indexes independently proving absence -> back to `auth_preflight` with new attempt identity; (e) foreign UID/email before intent -> `failed/already-exists`. Tests use independent expected states — NOT computed via production helpers.
- [ ] P1a2-ii.8 RED → GREEN — Negative probe (Gap 5 direct): confirmation CANNOT proceed directly from intent; must have persisted proof with exact UID + email reads agreeing. Definite-no-effect requires two-index absence evidence, not one.
- [ ] P1a2-ii.9 RED → GREEN — Crash-point vectors as REAL reducer transitions: before/after Auth intent, Auth call, Auth return, each dual read, proof commit, profile/completion commit. Each crash point modeled as an explicit event; reducer produces correct terminal or continuation state. Not comments — real transitions.
- [ ] P1a2-ii.10 RED → GREEN — Completion as one pure transition: profile + completed + success audit + current dispatch ack appear together in one transition result. Partial commit (e.g., profile without audit) is not representable. Tests prove all-or-nothing.
- [ ] P1a2-ii.11 RED → GREEN — Dispatch safety: next-dispatch creation is deterministic and idempotent (create-if-absent); current-dispatch acknowledgement is guarded; orphan dispatches (no matching operation) rejected; duplicate/stale/out-of-order dispatches cause no effect or regression. Tests: duplicate dispatch idempotent; stale dispatch no regression; orphan dispatch rejected.
- [ ] P1a2-ii.12 REFACTOR: freeze P1a2-ii extensions. Type-level GREEN via explicit `npx tsc` on all P1a1+P1a2-i+P1a2-ii files.

### Verification commands

- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/model.test.ts`
- Git-native count (Windows PowerShell): tracked — `git diff --numstat <P1a2-i-B-baseline> -- functions/src/provisioning/model.ts functions/test/provisioning/model.test.ts`; untracked — `git diff --no-index --numstat -- NUL "<path>"` (exit code 1 expected); sum additions + deletions across all changed paths since P1a2-i-B commit.

### Independent phase-contract acceptance (UNCHECKED — fresh context)

- [ ] Acquisition does NOT change generation; generation remains 0
- [ ] Takeover requires exact +1 generation; regression and jumps > +1 rejected
- [ ] Auth confirmation impossible without persisted proof + UID/email dual-read agreement
- [ ] Definite-no-effect requires two-index independent absence evidence
- [ ] Crash vectors are real transitions with correct outcomes (not comments)
- [ ] Completion transition produces profile + completed + audit + ack as one unit
- [ ] Dispatch safety: duplicate/stale/orphan cause no regression
- [ ] All expected states in tests are independent (not computed via production helpers)

### Rollback boundary

Revert `functions/src/provisioning/model.ts` to P1a2-i-B frozen state, revert `functions/test/provisioning/model.test.ts` to P1a2-i-B frozen state, revert `tasks.md` and `apply-progress.md` to pre-P1a2-ii state. P1a1 + P1a2-i-A-1 + P1a2-i-A-2 + P1a2-i-B intact.

### P1a2-ii Forecast (component sum verified)

| Component | Expected lines |
|---|---:|
| `model.ts` extensions (acquisition + takeover + auth matrix + crash transitions + completion + dispatch safety) | 400–500 |
| `model.test.ts` extensions (boundary + auth matrix + crash + completion + dispatch + 2 negative probes) | 400–520 |
| `tasks.md` + `apply-progress.md` bookkeeping | 50–80 |
| **Total P1a2-ii** | **850–1,100** |

Early warning at 1,100; STOP/reforecast at 1,200; absolute max 1,200. No size:exception. Component sum verified: low 400+400+50 = 850; high 500+520+80 = 1,100.

---

## P1a2-iii — Terminalization Guards + Retry Thresholds + Negative Probes

**Objective**: implement pending terminalization with the FULL required tuple (fingerprint, status, phase, generation, version, ownerToken, lease, authAttempted, authAttempt, current dispatch ID, dispatch identity/source tuple, worker acknowledgement), active terminalization 4-path classifier (exact current owner + live lease, another owner's unexpired lease, expired lease takeover, terminal idempotent) with correct failed vs manual_recovery outcome, retry thresholds gating EVERY normal-work event with exact closed domain (0–7 normal work, 8–11 terminalize only, non-integer/negative/>11 fail-closed — no mutation and no terminalization), and direct negative probes for the 5 observed unsafe behaviors.

**Gaps addressed**: 2 (pending terminalization complete), 3 (active terminalization classifier), 4 (retry thresholds), 13 (honest bookkeeping).

**Spec traceability**: Requirement: Bounded Retry and Terminal Failure Finalization; Requirement: Operation Invariants.

**Design traceability**: Retry and exhaustion semantics (exact pending/active classifier table); boundary and crash protocol.

**Depends on**: P1a2-ii (frozen boundary transitions + Auth matrix + crash vectors + completion + dispatch safety).

**Base / branch**: `slice/p1a2-iii-terminalization-retry` branched from `slice/p1a2-ii-boundary-transitions`.

**Allowed paths** (exact):

- `functions/src/provisioning/model.ts` (extend — add pending terminalization, active terminalization classifier, retry threshold gates)
- `functions/test/provisioning/model.test.ts` (extend — add terminalization tests, retry threshold tests, 5 direct negative probes)
- `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping)
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates)

**Forbidden**: all prior forbidden paths remain. No modification of P1a2-i-A, P1a2-i-B, or P1a2-ii frozen behavior.

### Strict TDD order (RED → GREEN)

- [ ] P1a2-iii.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [ ] P1a2-iii.1 RED → GREEN — Retry thresholds with exact closed domain: `retryCount` 0–7 allows normal boundary work; `retryCount` 8–11 allows ONLY terminalization (no normal work); any non-integer, negative, or >11 value fails closed as malformed — no mutation, no terminalization, no state change. Explicit boundary probes: retryCount -1 (fail-closed), 0 (normal work allowed), 7 (normal work allowed), 8 (terminalization only), 11 (terminalization only), 12 (fail-closed), non-integer e.g. 7.5 or "abc" (fail-closed). Pre-handler 5xx semantics: first handler entry can have retryCount 8–11 from pre-handler retries; if retryCount >11 at first entry, fail-closed. No fictional post-exhaustion callback.
- [ ] P1a2-iii.2 RED → GREEN — Pending terminalization (full tuple): requires ALL of operation fingerprint, status=pending, phase=dispatch_pending, generation=0, version=0, ownerToken=null, leaseExpiresAt=null, authAttempted=false, authAttempt=null, currentDispatchId equal to initial dispatch, AND that dispatch's exact operationId, fingerprint, boundary=acquire, generation=0, sourceVersion=0, workerAck=null. Writes failed/terminal, version=1, terminalCode=unavailable, retry evidence, failure audit, current dispatch workerAck=terminalized atomically. Every field independently mutated in tests — every mismatch blocks.
- [ ] P1a2-iii.3 RED → GREEN — Pending predicate mismatch: do not infer safety; reread and reclassify; second mismatch returns success with no mutation.
- [ ] P1a2-iii.4 RED → GREEN — Active terminalization, exact current owner + live lease: require complete active CAS tuple + current dispatch identity. Safe phase (no Auth intent: authAttempted=false, authAttempt=null) -> `failed/unavailable`. Otherwise -> `manual_recovery/internal`. Evidence + failure audit + owner/lease clear + current ack commit together.
- [ ] P1a2-iii.5 RED → GREEN — Active terminalization, another owner's unexpired lease: no steal, no mutation. CAS loss returns success.
- [ ] P1a2-iii.6 RED → GREEN — Active terminalization, expired lease: first transaction takes over (exact +1 generation, new owner token, live lease); same invocation then applies complete active classifier with new tuple.
- [ ] P1a2-iii.7 RED → GREEN — Terminal operation idempotent: return success without mutation or new audit; existing dispatch ack idempotent.
- [ ] P1a2-iii.8 RED → GREEN — Negative probe (Gap 2 direct): pending terminalization with missing fingerprint rejected; missing dispatch source tuple rejected; missing worker ack rejected.
- [ ] P1a2-iii.9 RED → GREEN — Negative probe (Gap 3 direct): active terminalization with expired lease WITHOUT takeover first rejected; active terminalization with foreign owner's unexpired lease rejected; active terminalization with stale worker rejected.
- [ ] P1a2-iii.10 RED → GREEN — Negative probe (Gap 4 direct): retryCount 8 attempting normal work rejected; retryCount 7 allowed; retryCount 12 (beyond 11) fails closed — no mutation, no terminalization; retryCount -1 fails closed; non-integer retryCount fails closed; every normal-work event gated by exact domain check.
- [ ] P1a2-iii.11 REFACTOR: freeze P1a2-iii. Final type-level GREEN. Aggregate RED/GREEN for ALL P1a1+P1a2-i+P1a2-ii+P1a2-iii.

  ```bash
  cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts
  ```

  ```bash
  cd functions && node --experimental-strip-types test/provisioning/model.test.ts
  ```

### Verification commands

- Same type-level and runtime commands as P1a2-ii but including all P1a2-iii tests
- Git-native count (Windows PowerShell): tracked — `git diff --numstat <P1a2-ii-baseline> -- functions/src/provisioning/model.ts functions/test/provisioning/model.test.ts`; untracked — `git diff --no-index --numstat -- NUL "<path>"` (exit code 1 expected); sum additions + deletions across all changed paths since P1a2-ii commit.

### Independent phase-contract acceptance (UNCHECKED — fresh context)

- [ ] Pending terminalization requires all 12+ predicate fields; every independent mismatch blocks
- [ ] Active terminalization: 4 paths produce correct outcomes (failed/unavailable, success-no-mutation, takeover+terminalize, idempotent)
- [ ] Active terminalization never allows expired/foreign/stale workers without proper takeover
- [ ] Retry thresholds: exact closed domain — 0–7 work; 8–11 terminalize only; non-integer/negative/>11 fail-closed (no mutation, no terminalization); exact 7/8 and 11/12 boundaries correct
- [ ] 5 direct negative probes all pass:
  1. Arbitrary acquire generation -> rejected
  2. Expired active terminalization without takeover -> rejected
  3. Malformed pending terminalization (missing fields) -> rejected
  4. Confirmation directly from intent (no proof) -> rejected (tested in P1a2-ii)
  5. Invalid active/auth_preflight acquire -> rejected
- [ ] All expected states in tests are independent (not computed via production helpers or duplicate of production transition table)

### Rollback boundary

Revert `functions/src/provisioning/model.ts` to P1a2-ii frozen state, revert `functions/test/provisioning/model.test.ts` to P1a2-ii frozen state, revert `tasks.md` and `apply-progress.md` to pre-P1a2-iii state. P1a1 + P1a2-i + P1a2-ii intact.

### P1a2-iii Forecast (component sum verified)

| Component | Expected lines |
|---|---:|
| `model.ts` extensions (pending terminalization + active classifier + retry gates) | 280–350 |
| `model.test.ts` extensions (terminalization + retry + 5 negative probes + exhaustive tables) | 300–400 |
| `tasks.md` + `apply-progress.md` bookkeeping | 50–80 |
| **Total P1a2-iii** | **630–830** |

Early warning at 1,100; STOP/reforecast at 1,200; absolute max 1,200. No size:exception. Component sum verified: low 280+300+50 = 630; high 350+400+80 = 830.

### P1a2 Aggregate (five sub-slices)

| Sub-slice | Expected |
|---|---:|
| P1a2-i-A-1 | 260–330 |
| P1a2-i-A-2 | 120–170 |
| P1a2-i-B | 440–590 |
| P1a2-ii | 850–1,100 |
| P1a2-iii | 630–830 |
| **Total P1a2** | **2,300–3,020** |

### Handoff contract to P1b

Frozen pure types + frozen normalization/fingerprint + frozen deterministic IDs + frozen canonical vector fixtures + frozen immutable vocabulary + frozen deep runtime immutability + frozen type guards + frozen CAS fence + frozen reducer skeleton (only `reduce()` as public API) + frozen terminal immutability (12×3, ack_dispatch separated) + frozen monotonic state + frozen data immutability + frozen boundary transitions + frozen Auth matrix + frozen crash vectors + frozen completion atomicity + frozen dispatch safety + frozen terminalization guards + frozen retry thresholds + frozen 5 negative probes. P1b builds the persistence port and implements the in-memory reference store and the Firestore emulator adapter; both MUST pass every frozen vector from P1a1+P1a2 identically.

---

## P1b — Persistence Ports + Conformance (Memory Reference + Firestore Emulator)

**Objective**: define the domain `Store` port (no Firebase import in the port), implement the strict in-memory reference store, implement the Firestore emulator transaction adapter using real `firebase-admin` transactions, and author CAS/lease primitives. Run **every frozen P1a vector** against both stores and assert byte-equal outcomes. Run crash-point schedules around every transaction boundary. **No schema validators, no audit primitives, no profile provenance.** Schemas/audit move to P2; profile moves to P3. **No callable, no dispatch handler, no worker, no submission, no status, no Auth.createUser call.** This slice is the persistence contract and CAS primitives only.

**Spec traceability**: Requirement: Operation Invariants; Requirement: Operation Identity and Idempotency; Requirement: Completion Atomic Commitment; Requirement: First-Slice Compensation Policy.

**Design traceability**: Persistence contracts (`/provisioningOperations`, `/provisioningDispatch`); indexes; full CAS and lease contract; "Executable Contract Before Production Code" (independent pure model + identical conformance vectors against both stores).

**Depends on**: P1a2-iii (frozen reducer + invariants + terminalization + retry; P1a2-iii transitively includes frozen P1a1 types + normalization + IDs + fixtures and P1a2-i/P1a2-ii).

**Base / branch**: `slice/p1b-persistence-conformance` branched from `slice/p1a2-iii-terminalization-retry`.

**Allowed paths** (exact):

- `functions/src/provisioning/store.ts` (new — domain port; NO firebase-admin import)
- `functions/src/provisioning/memory_store.ts` (new — strict in-memory reference implementation)
- `functions/src/provisioning/firestore_store.ts` (new — Firestore emulator transaction adapter; real firebase-admin)
- `functions/src/provisioning/cas.ts` (new — full CAS predicates, lease helpers, terminalization helpers)
- `functions/test/provisioning/store_conformance.test.ts` (new — shared harness running every frozen P1a vector against a store)
- `functions/test/provisioning/memory_store.test.ts` (new — in-memory-specific tests)
- `functions/test/provisioning/firestore_store.test.ts` (new — Firestore emulator conformance)
- `functions/test/provisioning/cas.test.ts` (new — CAS predicate + lease + terminalization vectors against both stores)
- `functions/package.json` (minimal: add emulator test script routing to `node --experimental-strip-types`; no new runtime dependencies — WU4a already has `firebase-admin`)

**Forbidden in P1b**: no `schemas.ts`, no `audit.ts`, no `profile.ts`, no callable (submit/status), no outbox trigger, no scheduled sweeper, no task worker, no dispatch handler, no Auth.createUser, no `index.ts` export changes, no `firebase.json` emulator port additions, no `firestore.indexes.json` changes.

**Native `sdd-attempt` contract**:
- Work unit: P1b
- Evidence goal: persistence port + memory store + Firestore emulator adapter + CAS primitives all green; every frozen P1a vector passes identically against both stores
- max = 2,000
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

### Strict TDD order (RED → GREEN)

- [ ] P1b.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 before every test/emulator invocation.
- [ ] P1b.1 RED: domain port (`Store`) — type-level compile failure until interface defined; no firebase-admin import in the port.
- [ ] P1b.2 GREEN: define `Store` port with transactional semantics (read, write, CAS, transaction wrapper); every conformance test fails because no implementation exists yet.
- [ ] P1b.3 RED: in-memory reference store — every frozen P1a conformance vector fails against the in-memory store.
- [ ] P1b.4 GREEN: implement in-memory store; pass every frozen P1a vector identically.
- [ ] P1b.5 RED: CAS primitives — full tuple predicate, lease check (server time), terminalization helper, generation fence.
- [ ] P1b.6 GREEN: CAS primitives pass against the in-memory store.
- [ ] P1b.7 RED: Firestore emulator adapter — every frozen P1a conformance vector fails against the real emulator via `firebase-admin` transactions.
- [ ] P1b.8 GREEN: implement Firestore adapter using real `firebase-admin` transactions against the Firestore emulator; pass every frozen P1a vector.
- [ ] P1b.9 RED: divergence test — run identical frozen P1a conformance vectors against both stores and assert byte-equal outcomes; any reference-vs-emulator difference fails the build.
- [ ] P1b.10 GREEN: divergence test passes.
- [ ] P1b.11 RED: CAS primitives against Firestore emulator — full tuple predicate, lease check, terminalization helper, generation fence; every stale mutation fails; exact live tuple succeeds.
- [ ] P1b.12 GREEN: CAS primitives pass against both stores identically.
- [ ] P1b.13 RED: crash-point schedule around every transaction boundary — abort simulation, retry, idempotent re-entry; both stores must behave identically.
- [ ] P1b.14 GREEN: crash-point schedule passes for both stores identically.
- [ ] P1b.15 REFACTOR: freeze persistence port + stores + CAS primitives. `npx tsc --noEmit` green.

### Verification commands

- `cd functions && node --experimental-strip-types test/provisioning/store_conformance.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/memory_store.test.ts`
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/firestore_store.test.ts"`
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/cas.test.ts"`
- `cd functions && npx tsc --noEmit`

### Rollback boundary

Revert all `functions/src/provisioning/{store,memory_store,firestore_store,cas}.ts`, delete all P1b test files listed above, revert `functions/package.json` additions (if any). P1a foundation intact. No emulator state, no `firebase.json`, no `firestore.indexes.json`, no callable, no dispatch, no worker.

### Forbidden actions

No schemas, no audit, no profile. No submission callable. No outbox trigger. No scheduled sweeper. No task worker. No status callable. No Auth.createUser call. No push/PR/deploy. No modification of `spec.md` or `design.md`. No modification of `D:\control_horario`. No modification of P1a frozen artifacts.

### Handoff contract to P2

Frozen persistence port + frozen in-memory reference store + frozen Firestore emulator adapter + frozen CAS/lease primitives. Every frozen P1a vector passes identically against both stores. P2 builds the schemas, audit primitives, submission callable, dispatch machinery, and outbox using these.

### P1b Forecast (component sum verified)

| Component | Expected lines |
|---|---:|
| `store.ts` | 60–80 |
| `memory_store.ts` | 180–230 |
| `firestore_store.ts` | 250–320 |
| `cas.ts` | 180–230 |
| `store_conformance.test.ts` | 150–200 |
| `memory_store.test.ts` | 80–110 |
| `firestore_store.test.ts` | 120–160 |
| `cas.test.ts` | 160–210 |
| `functions/package.json` delta | 5–15 |
| **Total P1b** | **1,185–1,555** |

Reforecast/STOP at 1,700; absolute max 2,000. Component sum verified: low 60+180+250+180+150+80+120+160+5 = 1,185; high 80+230+320+230+200+110+160+210+15 = 1,555.

---

## P2 — Schemas + Audit + Submission + Reliable Dispatch

**Objective**: implement operation/dispatch/audit schema validators with PII-safety and dedup, the `submitProvisioning` App Check-enforced callable, authorization/denial audit, safe status DTO projection, atomic operation+initial outbox transaction, shared Cloud Tasks enqueue adapter, created-only retry-enabled trigger, scheduled stale-outbox sweeper, deterministic task IDs, `ALREADY_EXISTS` acceptance, guarded acknowledgement, trigger/sweeper race safety, and the repository-preparation metadata for indexes, IAM, schedule, trigger, and monitoring/alerting/runbook.

**Spec traceability**: Requirement: App Check Pre-Handler Enforcement; Requirement: Asynchronous Provisioning Submission; Requirement: Operation Identity and Idempotency; Requirement: Autonomous Backend Liveness; Requirement: Protected Status Query; Requirement: Application Audit and Observability Contract; Requirement: Explicit Non-Goals and Compatibility.

**Design traceability**: Callable contracts and security; submission transaction; outbox enqueue; scheduled outbox repair; repository files and deployment metadata; risks and operational controls.

**Depends on**: P1b (frozen persistence port + stores + CAS primitives).

**Base / branch**: `slice/p2-submission-dispatch` branched from `slice/p1b-persistence-conformance`.

**Allowed paths** (exact):

- `functions/src/provisioning/schemas.ts` (new — operation/dispatch/audit schema validators; moved from P1b)
- `functions/src/provisioning/audit.ts` (new — audit event creation + dedup; PII-safety; moved from P1b)
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
- `functions/test/provisioning/schemas.test.ts` (new — schema validation vectors; moved from P1b)
- `functions/test/provisioning/audit.test.ts` (new — audit dedup + PII-safety vectors; moved from P1b)
- `functions/test/provisioning/submit.test.ts` (new)
- `functions/test/provisioning/authz.test.ts` (new)
- `functions/test/provisioning/dto.test.ts` (new)
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
- Evidence goal: schemas + audit + submission callable + dispatch machinery + metadata proof all green
- max = 2,000
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

### Strict TDD order (RED → GREEN)

- [ ] P2.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [ ] P2.1 RED: operation schema validator — every invalid field combination fails.
- [ ] P2.2 GREEN: operation schema validator; valid combinations pass; invalid rejected.
- [ ] P2.3 RED: dispatch schema validator — immutable identity + enqueue/ack updates only.
- [ ] P2.4 GREEN: dispatch schema passes.
- [ ] P2.5 RED: audit schema + PII-safety — no raw email, names, DNI, telephone, body, token, reset link, SDK message in any audit field.
- [ ] P2.6 GREEN: audit schema passes; PII-safety scan passes.
- [ ] P2.7 RED: audit dedup — same `auditEventId` with matching identity fields is idempotent; mismatched identity fails.
- [ ] P2.8 GREEN: audit dedup passes.
- [ ] P2.9 RED: admin authorization — unauthenticated -> `unauthenticated`; non-admin -> `permission-denied`; denial audit written before any mutation.
- [ ] P2.10 GREEN: authorization + denial audit pass.
- [ ] P2.11 RED: App Check metadata — `enforceAppCheck:true` structural assertion on exported callable. This test MUST be run RED against the WU4a placeholder BEFORE the callable export is introduced.
- [ ] P2.12 GREEN: export callable with `enforceAppCheck:true`; metadata test passes.
- [ ] P2.13 RED: submission handler — invalid schema -> `invalid-argument`; role not in `employee|rrhh` -> `invalid-argument`; missing `operationId/email/nombre/apellido1` -> `invalid-argument`.
- [ ] P2.14 GREEN: schema validation passes.
- [ ] P2.15 RED: submission transaction — atomic operation + initial dispatch creation; no Auth call; no profile write; return `{operationId, status:'pending'}`.
- [ ] P2.16 GREEN: submission transaction passes.
- [ ] P2.17 RED: idempotent replay — same `(operationId, fingerprint)` returns current safe status; different fingerprint returns `already-exists` without mutation.
- [ ] P2.18 GREEN: idempotent replay passes.
- [ ] P2.19 RED: safe DTO projection — each status projects only its safe fields; no raw email, owner, lease, generation/version, evidence, audit identity, reset link leaked.
- [ ] P2.20 GREEN: DTO projection passes.
- [ ] P2.21 RED: PII-safe log/audit structural check — application logs contain only allowlisted codes and domain-separated digests.
- [ ] P2.22 GREEN: PII-safety passes.
- [ ] P2.23 RED: enqueue adapter contract — injectable interface; strict fake proves outbox idempotency.
- [ ] P2.24 GREEN: adapter contract + strict fake pass.
- [ ] P2.25 RED: production adapter contract — deterministic queue/task construction from dispatch identity; same task ID for same dispatch.
- [ ] P2.26 GREEN: production adapter contract passes.
- [ ] P2.27 RED: created-trigger handler — validates immutable dispatch shape; calls shared adapter; success or `ALREADY_EXISTS` followed by guarded ack transaction (exact dispatch identity + `enqueued=false` -> `enqueued=true`).
- [ ] P2.28 GREEN: trigger behavior passes; duplicate event, enqueue success, crash-before-ack, `ALREADY_EXISTS`, invalid dispatch, guarded ack, trigger+sweeper race vectors pass.
- [ ] P2.29 RED: sweeper handler — invoke directly with Firestore-emulator records + shared enqueue adapter; 10-minute grace edge; `(enqueued, createdAt, __name__)` ordering/cursors; 100x5 bounds; rate/concurrency limits.
- [ ] P2.30 GREEN: sweeper handler behavior passes.
- [ ] P2.31 RED: sweeper forbidden operations — must NOT execute saga phases, mutate Auth/profile/operation state, acknowledge worker completion, create dispatches, or invent task identities.
- [ ] P2.32 GREEN: forbidden operations test passes.
- [ ] P2.33 RED: trigger+sweeper race — one enqueue wins, the other observes `ALREADY_EXISTS`; either acknowledgement wins while the other verifies `enqueued=true`.
- [ ] P2.34 GREEN: race passes.
- [ ] P2.35 RED: partial failure/throw — per-record failure logs PII-safe digests; run processes its bounded page, then throws so Scheduler retry + next regular schedule repair.
- [ ] P2.36 GREEN: partial failure/throw passes.
- [ ] P2.37 RED: trigger metadata structural proof — retry-enabled `onDocumentCreated`, `retry:true`.
- [ ] P2.38 GREEN: trigger metadata passes.
- [ ] P2.39 RED: scheduler metadata structural proof — `retryCount=3`, `minBackoffSeconds=30`, `maxBackoffSeconds=300`, `maxDoublings=2`, `maxInstances=1`, `timeoutSeconds=240`, every-5-minute cadence.
- [ ] P2.40 GREEN: scheduler metadata passes.
- [ ] P2.41 RED: monitoring metadata structural proof — alert names/thresholds documented (no production alert created).
- [ ] P2.42 GREEN: monitoring metadata passes.
- [ ] P2.43 RED: IAM metadata structural proof — least-privilege service accounts; queue; OIDC; Scheduler invoker; Eventarc trigger; enqueuer role; required Firestore/Auth permissions; environment/project placeholders.
- [ ] P2.44 GREEN: IAM metadata passes; no production project ID/secret/role binding/queue/scheduler job/alert/deployment created.
- [ ] P2.45 RED: structural boundary (BACKEND-only) — BEFORE P2 Functions production files exist, test requires BOTH: (a) required P2 Functions production files/exports/metadata exist and are wired (`submit.ts` submission handler, `schemas.ts` validators, `audit.ts` primitives, `enqueue.ts` shared adapter, `outbox.ts` created trigger, `outbox_repair.ts` scheduled sweeper, `index.ts` callable exports with `enforceAppCheck:true`, metadata tests for trigger/scheduler/monitoring/IAM paths); these are absent before P2, guaranteeing genuine RED; (b) forbidden BACKEND-only patterns remain absent in `functions/` scope (no raw HTTP task/callable workaround, no automatic Auth deletion, no client Firebase secondary-app logic copied into Functions, no unsafe direct profile mutation outside approved transaction primitives, no missing `enforceAppCheck:true` metadata on exported callables). Test scans ONLY Functions/`functions/` backend scope and MUST NOT require Flutter/client pattern removal. Test fails RED because required Functions files/exports are missing.
- [ ] P2.46 GREEN: structural boundary (BACKEND-only) passes AFTER P2 implementation — all required P2 Functions production files exist and are wired in Functions scope; forbidden backend-only patterns remain absent in Functions scope. Client structural absence (secondary Firebase app, direct client Auth creation, direct profile write, client compensation, temp passwords) is P4's responsibility via `firebase_service_migration_test.dart` and related client/UI path tests.
- [ ] P2.47 REFACTOR: write `docs/operations/outbox-recovery-runbook.md`; add all index additions to `firestore.indexes.json`; `npx tsc --noEmit` green.

### Verification commands

- `cd functions && node --experimental-strip-types test/provisioning/schemas.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/audit.test.ts`
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

Revert `schemas.ts`, `audit.ts`, `submit.ts`, `dto.ts`, `authz.ts`, `enqueue.ts`, `outbox.ts`, `outbox_repair.ts`, `index.ts`; revert `functions/package.json` and `firebase.json` additions; revert `firestore.indexes.json` additions; delete all P2 test files and `docs/operations/outbox-recovery-runbook.md`. P1a and P1b foundations intact.

### Forbidden actions

No `profile.ts` (owned by P3). No task worker. No status callable. No Auth.createUser call. No reset link generation. No push/PR/deploy. No production Scheduler job/Cloud Tasks queue/Eventarc trigger/alert created. No modification of P1a/P1b frozen artifacts. No modification of `spec.md` or `design.md`. No modification of `D:\control_horario`.

### Handoff contract to P3

Frozen schemas + frozen audit primitives + frozen submission callable + callable export with `enforceAppCheck:true` metadata + frozen shared enqueue adapter + frozen created-trigger + frozen sweeper + frozen indexes + frozen runbook. P3 builds the profile provenance primitives, task worker, status callable, and full backend integration proof.

### P2 Forecast (component sum verified)

Original P2 forecast (without schemas/audit): 660–890. Moved schemas + audit from P1b: +370–495 (schemas.ts 120-160, audit.ts 80-110, schemas.test.ts 100-130, audit.test.ts 70-95).

**P2 Forecast**: 1,030–1,385 (660+370=1,030; 890+495=1,385).

Reforecast/STOP at 1,700; absolute max 2,000.

---

## P3 — Profile Provenance + Worker + Status + Full Backend Proof

**Objective**: implement profile provenance matching (moved from P1b), the one-effect-boundary `onTaskDispatched` worker, Auth preflight/intent/create/dual-index reconstruction/manual recovery/no-deletion, profile+completed+success audit+ack atomicity, 12/8 pending+active terminalization, `getProvisioningStatus` callable with completed-integrity checks and fresh reset link generation, final exports and IAM metadata, and the full test suite (unit, crash, threshold, task HTTP, true concurrency, outbox race, full emulator integration). Because behavior and full proof share P3, same-slice backend corrections are allowed until final proof/freeze; no frozen-backend contradiction within this slice. After the last source mutation: aggregate emulator, TypeScript, independent phase-contract validation, candidate freeze. RDD remains disabled; surface explicit maintainer enable decision only after all gates.

**Spec traceability**: all provisioning-domain requirements.

**Design traceability**: Worker acquisition and intent; Auth create result matrix; profile and completion; retry and exhaustion semantics; callable contracts and security; emulator and verification strategy.

**Depends on**: P2 (frozen dispatch + schemas + audit).

**Base / branch**: `slice/p3-worker-proof` branched from `slice/p2-submission-dispatch`.

**Allowed paths** (exact):

- `functions/src/provisioning/profile.ts` (new — provenance-tagged profile shape + operation-matching predicate; moved from P1b)
- `functions/src/provisioning/worker.ts` (new — task worker entry)
- `functions/src/provisioning/boundaries.ts` (new — one-boundary-per-dispatch handlers: acquire, auth_preflight, auth_create, profile_commit)
- `functions/src/provisioning/terminalization.ts` (new — reserved-attempt classifier)
- `functions/src/provisioning/status.ts` (new — status handler)
- `functions/src/index.ts` (add task function export + status callable export)
- `functions/test/provisioning/profile.test.ts` (new — provenance match/missing/mismatch vectors; moved from P1b)
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
- Evidence goal: profile provenance + task worker + status callable + full backend proof green; candidate freeze
- max = 2,000
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

### Strict TDD order (RED → GREEN)

- [ ] P3.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [ ] P3.1 RED: profile provenance match — UID + email + operationId + fingerprint + schema version + every normalized field must all match.
- [ ] P3.2 GREEN: profile provenance passes.
- [ ] P3.3 RED: profile provenance against Firestore emulator — match/missing/mismatch vectors.
- [ ] P3.4 GREEN: profile provenance passes against Firestore emulator.
- [ ] P3.5 RED: worker acquisition — acquire/take over lease; duplicate/out-of-order/terminal deliveries atomically mark dispatch stale and return 2xx; never advance operation state.
- [ ] P3.6 GREEN: acquisition passes.
- [ ] P3.7 RED: Auth preflight — mandatory UID + email reads before any create; foreign UID/email before intent -> `failed/already-exists`; no Auth mutation.
- [ ] P3.8 GREEN: preflight passes.
- [ ] P3.9 RED: Auth intent — one transaction flips `authAttempted=true`, persists `authAttempt.result=intent`, audit, version, deterministic `auth_create` dispatch, current ack.
- [ ] P3.10 GREEN: intent commit passes.
- [ ] P3.11 RED: Auth create boundary — CAS to `call_started`; call create once; exact return + UID/email reads + proof commit -> `profile_commit`; malformed/ambiguous/timeout/crash -> `manual_recovery` (no delete); definite no-effect -> back to `auth_preflight`.
- [ ] P3.12 GREEN: Auth create boundary passes; no repeated ambiguous create; no automatic deletion.
- [ ] P3.13 RED: profile_commit boundary — requires persisted Auth proof + mandatory matching UID/email reads; one transaction creates/verifies operation-matching profile + `completed/terminal` + `success.completed` audit + current ack; all-or-nothing.
- [ ] P3.14 GREEN: profile_commit passes; conflicting profile -> `manual_recovery`; no deletion.
- [ ] P3.15 RED: crash injection around every external effect — before/after enqueue, Auth intent, Auth call, Auth return, each dual read, proof commit, profile/completion commit.
- [ ] P3.16 GREEN: crash injection passes.
- [ ] P3.17 RED: true parallel emulator clients/workers — at least two actual parallel clients for one operation proving lease + CAS semantics (sequential mocks do not qualify).
- [ ] P3.18 GREEN: true parallel test passes.
- [ ] P3.19 RED: Functions emulator task endpoint — task worker exercised via authenticated HTTP POST to Functions emulator task endpoint with controlled TaskContext headers (no `emulators.tasks` config).
- [ ] P3.20 GREEN: Functions emulator task endpoint test passes.
- [ ] P3.21 RED: pending classifier — exact initial pending state predicate; writes `failed/terminal` + `version=1` + `terminalCode=unavailable` + retry evidence + failure audit + current dispatch `workerAck=terminalized` atomically.
- [ ] P3.22 GREEN: pending classifier passes.
- [ ] P3.23 RED: pending predicate mismatch — do not infer safety; reread + reclassify as exact pending/active/terminal; second mismatch/CAS loss returns success with no mutation.
- [ ] P3.24 GREEN: pending mismatch passes.
- [ ] P3.25 RED: active with exact current owner + live lease — require complete active CAS tuple; safe phase -> `failed/unavailable`; otherwise -> `manual_recovery/internal`; evidence + audit + owner/lease clear + current ack commit together.
- [ ] P3.26 GREEN: active exact-owner passes.
- [ ] P3.27 RED: active with another owner's unexpired lease — no steal, no mutation; CAS loss returns success.
- [ ] P3.28 GREEN: active foreign-owner passes.
- [ ] P3.29 RED: active with expired lease — first transaction requires full observed expired tuple, increments generation + version, installs new owner token + live lease; same invocation applies complete active terminalization guard using the exact new tuple.
- [ ] P3.30 GREEN: expired-lease takeover passes.
- [ ] P3.31 RED: terminal operation — return success without operation mutation or new audit; existing dispatch acknowledgement idempotent.
- [ ] P3.32 GREEN: terminal idempotency passes.
- [ ] P3.33 RED: 12/8 protocol — `retryCount` 0–7 may work; 8–11 terminalize only; non-integer/negative/>11 fail-closed; pre-handler 5xx semantics; no fictional post-exhaustion callback; permanent durable-store outage -> alert + runbook, not silent success.
- [ ] P3.34 GREEN: 12/8 protocol passes.
- [ ] P3.35 RED: reserved attempts 8, 9, 10, 11 repeat only guarded terminalization paths; failed terminalization transaction throws so next reserved attempt retries; committed terminal returns success.
- [ ] P3.36 GREEN: reserved-attempt idempotency passes.
- [ ] P3.37 RED: status authorization — unauthenticated -> `unauthenticated`; non-admin -> `permission-denied`; unknown operationId -> `not-found`; optional fingerprint mismatch -> `already-exists`; no mutation on either path.
- [ ] P3.38 GREEN: status authorization passes.
- [ ] P3.39 RED: status DTO projection — each status returns only its safe fields; no raw email/owner/lease/generation/version/evidence/audit identity.
- [ ] P3.40 GREEN: DTO projection passes.
- [ ] P3.41 RED: completed integrity — re-read both Auth indexes + full provenance-tagged profile; failure or inconsistency returns stable integrity error without changing terminal operation or generating a link; deduplicated integrity audit.
- [ ] P3.42 GREEN: completed integrity passes.
- [ ] P3.43 RED: fresh reset link — Auth `generatePasswordResetLink` called only after integrity passes; link returned; link never stored, logged, audited, or emailed; transient link failure returns stable retryable error leaving `completed` unchanged.
- [ ] P3.44 GREEN: reset link passes.
- [ ] P3.45 RED: full emulator flow — happy-path submission through to completed status with fresh reset link; no client-driven re-drive.
- [ ] P3.46 GREEN: full emulator flow passes.
- [ ] P3.47 RED: outbox race — trigger+sweeper race; duplicate event; out-of-order delivery; crash before enqueue; crash after enqueue; task already exists (`ALREADY_EXISTS` accepted).
- [ ] P3.48 GREEN: outbox race passes.
- [ ] P3.49 RED: retry threshold conformance — `retryCount` 7/8/9/10/11 valid; pre-handler 5xx first entry at 8–11; reserved attempts terminalize only; retryCount >11 or non-integer/negative fail-closed; poison behavior; no fictional exhaustion callback.
- [ ] P3.50 GREEN: retry conformance passes.
- [ ] P3.51 RED: Auth emulator matrix — foreign pre-attempt identity; exact create result; both UID/email reads; ambiguity; provenance conflict; all-or-nothing completion; completed integrity; no automatic deletion.
- [ ] P3.52 GREEN: Auth matrix passes.
- [ ] P3.53 RED: emulator/concurrency end-to-end — lease expiry/takeover; duplicate/out-of-order delivery; crash injection around every effect; first entry after pre-handler retries; exact pending guard per-field mutations; pending mismatch reclassification; active live owner; foreign live owner; expired takeover; terminal idempotency; failed reserved terminalization.
- [ ] P3.54 GREEN: end-to-end passes.
- [ ] P3.55 REFACTOR: finalize all callable exports; `npx tsc --noEmit` green; full `npm test` green.
- [ ] P3.56 FREEZE: aggregate emulator + TypeScript + independent phase-contract validation + candidate freeze. RDD remains disabled; surface explicit maintainer enable decision at this point.

### Verification commands

- `cd functions && node --experimental-strip-types test/provisioning/profile.test.ts`
- `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/profile.test.ts"`
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

Revert `profile.ts`, `worker.ts`, `boundaries.ts`, `terminalization.ts`, `status.ts`; revert `index.ts` additions; delete all P3 test files. P2 intact, including the frozen `functions/test/provisioning/structural_absence.test.ts` which P3 consumed as read-only cumulative regression verification and must NOT modify or delete.

### Forbidden actions

No Flutter client change yet (P4). No production deploy. No modification of P1a/P1b/P2 frozen artifacts (except where P3's own same-slice backend corrections require it before the final freeze). No modification of `spec.md` or `design.md`. No modification of `D:\control_horario`. No automatic Auth deletion. No fictional post-exhaustion callback. No sequential-mock-labeled-as-concurrency.

### Handoff contract to P4

Frozen profile provenance + frozen full backend capability + complete integration proof. P4 migrates the Flutter client and hardens Firestore rules.

### P3 Forecast (component sum verified)

Original P3 forecast (without profile): 1,180–1,460. Moved profile provenance from P1b: +120–165 (profile.ts 60-80, profile.test.ts 60-85).

**P3 Forecast**: 1,300–1,625 (1,180+120=1,300; 1,460+165=1,625).

Reforecast/STOP at 1,700; absolute max 2,000.

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
- No restoration of stash `66424881e1b7b064a61d6bd884daa13f7793fa12` (ordinal 21 evidence).
- No restoration of stash `3ab7b419f344077b3c3b4667391b155700cfe9fe` (ordinal 22 evidence).
- No restoration of stash `213ff2fdf123bfa9c7b3b0ea0f83026a3b1f0306` (ordinals 27–28 evidence).
- No restoration of stash `527d4dfb2fd0bd30eacd7b09116bec3bda79250d` (ordinal 29 evidence).
- No restoration of stash `012c41516831e1579cd7162c378c123f503ee633` (ordinal 30 evidence).
- No creation or modification of `functions/tsconfig.json` in any slice.

## Global Verification Contract (per slice)

Every slice MUST deliver:

- Focused test command and exact result.
- Runtime harness command/scenario and exact result, or explicit `N/A` with reason.
- Rollback boundary stated independently of commit creation.
- Native `sdd-attempt` begin/finish evidence with `next_action=begin` respected.

**Exception scope**:

- P1a1, P1b–P4: max 2,000 changed lines per slice; reforecast/stop at 1,700; absolute stop at 2,000. Maintainer-approved `size:exception`.
- P1a2-i-A-1: early warning 300; STOP/reforecast 350; absolute max 400. **No size:exception.**
- P1a2-i-A-2: early warning 200; STOP/reforecast 250; absolute max 300. Combined P1a2-i-A absolute max 600. **No size:exception.**
- P1a2-i-B: early warning 500; STOP/reforecast 560; absolute max 600. Combined P1a2-i (A-1+A-2+B) max 1,200. **No size:exception.**
- P1a2-ii, P1a2-iii: early warning 1,100; STOP/reforecast 1,200; absolute max 1,200. **No size:exception** — if a contract-complete sub-slice cannot fit within 1,200, split it further.
- WU5–WU10: max 400 changed lines per work unit; stop at 400. **No inherited exception** — any overrun requires a new, separate maintainer decision.
