# Tasks: Prepare Public Portfolio Repository

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: High
Delivery strategy: auto-chain (P1a2 child slices retain their own lower limits)
RDD routing: disabled — no automatic review activation. After cumulative backend emulator + TypeScript + independent phase-contract proof and candidate freeze at end of P3, surface explicit maintainer enable decision; no review before then.

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated aggregate changed lines (tasks-phase validated) | **8,710–11,535** |
| Aggregate ceiling | **None** — no invented aggregate ceiling; per-slice max governs |
| 400-line budget risk | High |
| Delivery strategy | auto-chain (P1a2 child slices retain their own lower limits) |
| Chain strategy | feature-branch-chain |
| Decision needed before apply | No (auto-chain is already selected; each child still requires its independent acceptance gate) |
| Slice count | 16 chained implementation slices; P1a2-i-B is four ordered children |
| Per-slice reforecast/STOP (P1a1 + P1b–P4 only) | 1,700 |
| Per-slice absolute max (P1a1 + P1b–P4 only) | 2,000 |
| P1a2-i-A absolute max | 1,900 (no size:exception) |
| P1a2-i-B aggregate absolute max | 600 across B-1a/B-1b/B-2/B-3 (no size:exception) |
| P1a2-ii absolute max | 1,200 (no size:exception) |
| P1a2-iii absolute max | 1,200 (no size:exception) |
| Later independent chain | WU5–WU10 preserved (signing → de-branding → sanitization → README → archive → gates); each max 400, stop at 400; no inherited exception |

### Phase-Authority Decision

The previous `Decision needed before apply` workload/size question is resolved for P1a1 + P1b–P4: maintainer has explicitly approved `size:exception` up to 2,000 lines per slice for P1a1 and P1b–P4 only. **P1a2 sub-slices (i-A-1a, i-A-1b, i-A-1c, i-A-1d, i-A-2, i-B-1a, i-B-1b, i-B-2, i-B-3, ii, iii) do NOT have size:exception.** Each P1a2-i-A-1 child has max 400; combined P1a2-i-A-1 max 1,600; P1a2-i-A-2 max 300; combined P1a2-i-A max 1,900; P1a2-i-B-1a/B-1b/B-2/B-3 each max 200 with a 600 aggregate; combined P1a2-i max 2,500; P1a2-ii max 1,200; P1a2-iii max 1,200. WU5–WU10 retain ordinary max 400 per work unit; any future overrun in those work units requires a separate maintainer decision. Separately, **interactive phase approval + validated planning baseline** are still required before P1a1 may begin — that gate is about phase sequencing, not about size/chaining, and does not contradict the resolved workload decision.

### Supersession Notice

This revision **supersedes** the prior P1a plan. The single `P1a — Pure Contract + Model + Invariant Vectors` is replaced by two strictly separated slices: `P1a1 — Types + Normalization + IDs` and P1a2 (reducer + invariants). The prior P1a was invalidated by failed ordinal 22 (see below). P1a2 is further decomposed into five contract-complete sub-slices: `P1a2-i-A-1 — Immutable Vocabulary + Deep Freeze + Strict Guards`, `P1a2-i-A-2 — Validated Constructors + TypeScript Compatibility`, `P1a2-i-B — CAS Fence + Reducer Skeleton + Terminal/State/Data Immutability`, `P1a2-ii — Boundary Transitions + Auth Matrix + Crash Vectors`, `P1a2-iii — Terminalization Guards + Retry Thresholds`. The prior single P1a2 was invalidated by failed ordinals 27–28 (13 deterministic contract gaps, 2,178 lines). P1a2-i was further split into P1a2-i-A and P1a2-i-B after failed ordinal 29 (8 deterministic contract failures, 969 lines). P1a2-i-A was further split into P1a2-i-A-1 and P1a2-i-A-2 after failed ordinal 30 (8 deterministic contract failures, 529 lines). P1a2-i-A-1 was further split into P1a2-i-A-1a (Immutable Vocabulary + Genuine Type Proof), P1a2-i-A-1b (Descriptor-Safe Cycle-Safe Deep Freeze), P1a2-i-A-1c (Strict State Guard), P1a2-i-A-1d (Strict Event Guard) after failed ordinal 34 (6 deterministic blockers: Set mutability, _Eq/Extract type-proof weakness, getter-invoking deepFreeze, guard laxity on null/NaN/class/polluted roots, missing adversarial probes, over-budget compaction; 566 lines, stash `6425de640274d1990b824869b96535068ab450a5`). All downstream slices (P1b–P4) and later work units (WU5–WU10) are preserved architecturally; only their dependency edges shift where required by the P1a decomposition.

**Current surgical amendment**: the unstarted P1a2-i-B monolith in this historical notice is superseded only by B-1a (request contract + reducer surface), B-1b (CAS + lease + unsupported dispatch), B-2 (terminal immutability + monotonic state), and B-3 (five-class data immutability + `ack_dispatch` idempotency). P1a2-i-A-2 acceptance is preserved; no completed history or unrelated task is reopened.

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
8. **Eighth refinement (8,655–11,485)**: P1a2-i-A-1 further decomposed into four contract-complete child slices — P1a2-i-A-1a (Immutable Vocabulary + Genuine Type Proof, ~200–270), P1a2-i-A-1b (Descriptor-Safe Cycle-Safe Deep Freeze, ~200–270), P1a2-i-A-1c (Strict State Guard, ~200–270), P1a2-i-A-1d (Strict Event Guard, ~200–270) — driven by failed ordinal 34 (566 lines, stash `6425de640274d1990b824869b96535068ab450a5`, 6 deterministic blockers: Set mutability, _Eq/Extract type-proof weakness, getter-invoking deepFreeze, guard laxity on null/NaN/class/polluted roots, missing adversarial probes, over-budget compaction). Each child max 400 (STOP 350), combined P1a2-i-A-1 max 1,600. Corrective pass reconciled canonical arithmetic across all tables. No size:exception.
9. **Current B-1 refinement (8,710–11,535)**: fresh planning validation rejected the monolithic B-1 forecast of 215–260 lines against its STOP 190/absolute max 200 and found that targeting the tracker would pollute the child diff. The maintainer approved two ordered children: B-1a (Request Contract + Reducer Surface, 105–135) targets accepted P1a2-i-A-2; B-1b (CAS + Lease + Unsupported Dispatch, 105–130) targets B-1a. B-2/B-3 and the parent 600-line maximum remain unchanged; no implementation or acceptance is carried forward by this planning correction.

Per-slice breakdown (validated from ordinal-22 measured data + design grouping + downstream ownership):

| Slice | Focus | Expected |
|---|---|---:|
| P1a1 | Types + normalization + IDs + canonical fixtures (no reducer/model) | 1,400–1,650 |
| P1a2-i-A-1a | Immutable vocabulary + genuine type proof (consumes P1a1) | 200–270 |
| P1a2-i-A-1b | Descriptor-safe cycle-safe deep freeze | 200–270 |
| P1a2-i-A-1c | Strict state guard | 200–270 |
| P1a2-i-A-1d | Strict event guard | 200–270 |
| P1a2-i-A-2 | Validated constructors + TypeScript compatibility | 120–170 |
| P1a2-i-B-1a | Request contract + reducer surface | 105–135 |
| P1a2-i-B-1b | CAS + lease + unsupported dispatch | 105–130 |
| P1a2-i-B-2 | Terminal immutability + monotonic state | 140–180 |
| P1a2-i-B-3 | Data immutability + `ack_dispatch` idempotency | 145–195 |
| P1a2-ii | Boundary transitions + Auth matrix + crash vectors + completion + dispatch safety | 850–1,100 |
| P1a2-iii | Terminalization guards + retry thresholds + negative probes | 630–830 |
| P1b | Persistence port + in-memory reference + Firestore emulator conformance + CAS primitives (narrowed) | 1,185–1,555 |
| P2 | Schemas + audit primitives + submission + reliable dispatch (former P1 schemas/audit + S4–S6) | 1,030–1,385 |
| P3 | Profile provenance + worker + status + full backend proof (former P1 profile + S7–S10) | 1,300–1,625 |
| P4 | Flutter migration + Firestore rules hardening/proof + dependency/bootstrap | 900–1,500 |
| **Total P1a1–P4** | | **8,710–11,535** |

### Per-Slice Exception Boundaries

| Slice | Early warning | STOP/reforecast | Absolute max | size:exception |
|---|---:|---:|---:|---|
| P1a1 | 1,500 | 1,700 | 2,000 | Accepted (committed 9167929) |
| P1a2-i-A-1a | 300 | 350 | 400 | **No** |
| P1a2-i-A-1b | 300 | 350 | 400 | **No** |
| P1a2-i-A-1c | 300 | 350 | 400 | **No** |
| P1a2-i-A-1d | 300 | 350 | 400 | **No** |
| P1a2-i-A-1 combined | — | — | 1,600 | **No** |
| P1a2-i-A-2 | 200 | 250 | 300 | **No** |
| P1a2-i-A combined | — | — | 1,900 | **No** |
| P1a2-i-B-1a | 120 | 170 | 200 | **No** |
| P1a2-i-B-1b | 120 | 170 | 200 | **No** |
| P1a2-i-B-2 | 155 | 180 | 200 | **No** |
| P1a2-i-B-3 | 160 | 180 | 200 | **No** |
| P1a2-i-B aggregate | — | — | 600 parent cap (four children; no borrowing) | **No** |
| P1a2-i combined | — | — | 2,500 | **No** |
| P1a2-ii | 1,100 | 1,200 | 1,200 | **No** |
| P1a2-iii | 1,100 | 1,200 | 1,200 | **No** |
| P1b | 1,500 | 1,700 | 2,000 | Accepted |
| P2 | 1,500 | 1,700 | 2,000 | Accepted |
| P3 | 1,500 | 1,700 | 2,000 | Accepted |
| P4 | 1,500 | 1,700 | 2,000 | Accepted |

WU5–WU10 do **not** inherit these boundaries. Each later work unit has max 400, stop at 400; any future overrun requires a separate maintainer decision.

### Line-Accounting Rules

- Per-slice expected range is the working budget for P1a1–P4.
- **P1a2-i-A-1a, P1a2-i-A-1b, P1a2-i-A-1c, P1a2-i-A-1d, P1a2-i-A-2, P1a2-i-B-1a, P1a2-i-B-1b, P1a2-i-B-2, P1a2-i-B-3, P1a2-ii, P1a2-iii do NOT inherit the P1a1/P1b–P4 size:exception.** Each P1a2-i-A-1 child has early warning 300, STOP at 350, absolute max 400; combined P1a2-i-A-1 max 1,600 (4 × 400). P1a2-i-A-2 has early warning 200, STOP at 250, absolute max 300. Combined P1a2-i-A max 1,900 (1,600 + 300). P1a2-i-B-1a/B-1b each have early warning 120, STOP at 170, absolute max 200; B-2/B-3 retain early warning 155/160 and STOP at 180, each with absolute max 200; the parent aggregate is capped at 600 and is not the sum of borrowable child budgets. P1a2-ii and P1a2-iii each have early warning 1,100, STOP at 1,200, absolute max 1,200. If a coherent contract-complete slice cannot fit within its max, split it further — do NOT use size:exception.
- **Recount after every RED/GREEN pair**: measure all-path changed lines via Git-native counting only. **Tracked files**: `git diff --numstat <slice-baseline> -- <tracked paths>` (sum additions + deletions; no net accounting). **Untracked files (Windows PowerShell)**: `git diff --no-index --numstat -- NUL "<path>"` — exit code 1 is expected when differences exist; parse the numstat output for additions + deletions. **POSIX alternative**: `git diff --no-index --numstat -- /dev/null "<path>"`. Never use `Measure-Object -Line`.
- **Early warning**: P1a1/P1b–P4 at 1,500; each P1a2-i-A-1 child at 300; P1a2-i-A-2 at 200; P1a2-i-B-1a/1b at 120 and B-2/B-3 at 155/160; P1a2-ii/iii at 1,100 — pause, assess remaining work, document.
- **STOP/reforecast**: P1a1/P1b–P4 at 1,700; each P1a2-i-A-1 child at 350; P1a2-i-A-2 at 250; P1a2-i-B-1a/1b at 170 and B-2/B-3 at 180; P1a2-ii/iii at 1,200 — no further mutation without measured evidence and explicit continuation.
- **Absolute STOP**: P1a1/P1b–P4 before 2,000; each P1a2-i-A-1 child before 400 (STOP/reforecast at 350); combined P1a2-i-A-1 before 1,600; P1a2-i-A-2 before 300 (STOP/reforecast at 250); combined P1a2-i-A before 1,900; each P1a2-i-B-1a/B-1b/B-2/B-3 child before 200, with B-1a/B-1b STOP/reforecast at 170 and B-2/B-3 at 180, and the parent aggregate before 600; combined P1a2-i before 2,500; P1a2-ii/iii before 1,200 (STOP/reforecast at 1,200; hard max, no exception).
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
              └── P1a2-i-A-1a branch (base: P1a1)
                    └── P1a2-i-A-1b branch (base: P1a2-i-A-1a)
                          └── P1a2-i-A-1c branch (base: P1a2-i-A-1b)
                                └── P1a2-i-A-1d branch (base: P1a2-i-A-1c)
                                      └── P1a2-i-A-2 branch (base: P1a2-i-A-1d)
                                       └── 📍 P1a2-i-B-1a branch (base: P1a2-i-A-2)
                                             └── P1a2-i-B-1b branch (base: P1a2-i-B-1a)
                                                   └── P1a2-i-B-2 branch (base: P1a2-i-B-1b)
                                                         └── P1a2-i-B-3 branch (base: P1a2-i-B-2)
                                                               └── P1a2-ii branch (base: P1a2-i-B-3)
                                                                    └── P1a2-iii branch (base: P1a2-ii)
                                                                          └── P1b branch (base: P1a2-iii)
                                                                                └── P2 branch (base: P1b)
                                                                                      └── P3 branch (base: P2)
                                                                                            └── P4 branch (base: P3)

Independent later chain (after P4 merges into tracker, tracker merges into main):
main ──→ WU5 (signing) ──→ WU6 (de-branding) ──→ WU7 (sanitization) ──→ WU8 (README) ──→ WU9 (archive) ──→ WU10 (gates)
```

Each child PR targets its immediate previous slice branch. The tracker target remains the integration boundary for P1a1; the current B chain starts from the accepted P1a2-i-A-2 branch: B-1a targets A-2 (not the tracker), B-1b targets B-1a, B-2 targets B-1b, and B-3 targets B-2. Only the tracker ultimately targets `main`. The current first-slice boundary is `📍 P1a2-i-B-1a`; each child diff contains only its own model/test/bookkeeping work unit. No branch, commit, or PR is created in this planning phase.

### Commit / Work-Unit Mapping and Rollback Order

| Order | Slice | Commit message (conventional) | PR target | Rollback order |
|---|---|---|---|---|
| 1 | P1a1 | `feat(provisioning): add canonical types, normalization, IDs, fixtures` | feature/tracker | 16 (last to revert) |
| 2 | P1a2-i-A-1a | `feat(provisioning): add immutable vocabulary and genuine type proof` | P1a1 branch | 15 |
| 3 | P1a2-i-A-1b | `feat(provisioning): add descriptor-safe cycle-safe deep freeze` | P1a2-i-A-1a branch | 14 |
| 4 | P1a2-i-A-1c | `feat(provisioning): add strict state guard` | P1a2-i-A-1b branch | 13 |
| 5 | P1a2-i-A-1d | `feat(provisioning): add strict event guard` | P1a2-i-A-1c branch | 12 |
| 6 | P1a2-i-A-2 | `feat(provisioning): add validated constructors, TypeScript compatibility` | P1a2-i-A-1d branch | 11 |
| 7 | P1a2-i-B-1a | `feat(provisioning): add reducer request contract and validation surface` | P1a2-i-A-2 branch | 10 |
| 8 | P1a2-i-B-1b | `feat(provisioning): add CAS lease fence and unsupported dispatch` | P1a2-i-B-1a branch | 9 |
| 9 | P1a2-i-B-2 | `feat(provisioning): add terminal immutability and monotonic state` | P1a2-i-B-1b branch | 8 |
| 10 | P1a2-i-B-3 | `feat(provisioning): add data immutability and dispatch ack idempotency` | P1a2-i-B-2 branch | 7 |
| 11 | P1a2-ii | `feat(provisioning): add boundary transitions, Auth matrix, crash vectors, completion, dispatch safety` | P1a2-i-B-3 branch | 6 |
| 12 | P1a2-iii | `feat(provisioning): add terminalization guards, retry thresholds, negative probes` | P1a2-ii branch | 5 |
| 13 | P1b | `feat(provisioning): add persistence port, memory/Firestore stores, CAS primitives` | P1a2-iii branch | 4 |
| 14 | P2 | `feat(provisioning): add schemas, audit, submission, dispatch, outbox, metadata` | P1b branch | 3 |
| 15 | P3 | `feat(provisioning): add profile, worker, status, full backend proof` | P2 branch | 2 |
| 16 | P4 | `feat(client): migrate provisioning to trusted backend; harden Firestore rules` | P3 branch | 1 (first to revert) |

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
- **Ordinal 34**: failed P1a2-i-A-1; 566/400 lines (exceeded absolute max); 6 deterministic blockers: (1) `Object.freeze(new Set(...))` leaves Set internal slots mutable via `add/delete/clear`; (2) `_Eq` plus `Extract<..., true>` accepts missing and extra canonical `StatusPhasePair` members; (3) `deepFreeze` reads properties and executes getters — throwing accessors abort traversal; (4) state/event guards accept null required identifiers/numbers, NaN, mismatched status-phase pairs, class/polluted roots, non-plain normalized payloads, event-specific missing/extra payload fields; (5) tests omitted those adversarial probes and bookkeeping falsely marked acceptance; (6) compaction transaction changed 491 lines versus 200-line native correction budget. Stash `6425de640274d1990b824869b96535068ab450a5`. Never restore.
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

## P1a2 — Reducer + Invariant Vectors (i-A, i-B, ii, iii — A-1 has 4 children)

The prior single P1a2 block is replaced by five major contract-complete sub-slices; P1a2-i-A-1 is further divided into four independently reviewable child slices. This decomposition addresses 13 deterministic contract gaps found in failed ordinals 27–28 (stash `213ff2fdf123bfa9c7b3b0ea0f83026a3b1f0306`, evidence only — never restore) and 8 deterministic contract failures found in failed ordinal 29 (stash `527d4dfb2fd0bd30eacd7b09116bec3bda79250d`, evidence only — never restore). Each slice has its own RED→GREEN cycle and no P1a2 child has a size:exception.

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
| 1 — validateCAS detached | P1a2-i-B-1a/B-1b | B-1a.1–1a.6 (request/reducer surface) and B-1b.1–1b.5 (CAS/lease/dispatch) through `reduce()` | B-1a proves exact plain-record request/ExpectedCAS validation, observedAt checks, failure precedence, unchanged nested event guards, and type compatibility; B-1b independently alters each of 8 CAS fields, proves lease equality/liveness, and reaches the non-mutating unsupported outcome. No exported CAS helper. |
| 2 — Pending terminalization incomplete | P1a2-iii | P1a2-iii.2 (full pending predicate), P1a2-iii.8 (negative probe) | Exhaustively mutate fingerprint, dispatch source, worker ack; every mismatch blocks `failed/unavailable` |
| 3 — Active terminalization classifier | P1a2-iii | P1a2-iii.4 (exact-owner 4-path classifier), P1a2-iii.5 (foreign-owner no-steal), P1a2-iii.6 (expired-lease takeover), P1a2-iii.9 (negative probe) | Exact-owner-live, foreign-owner-unexpired, expired-takeover, terminal-idempotent; correct outcome per path |
| 4 — Retry thresholds | P1a2-iii | P1a2-iii.1 (gate every normal-work event; exact domain 0–7 normal, 8–11 terminalize, non-integer/negative/>11 fail-closed), P1a2-iii.10 (boundary probes at -1, 0, 7, 8, 11, 12, malformed) | retryCount 0–7 allowed; 8–11 terminalize only; -1/negative/non-integer/>11 fail-closed; exact boundary at 7/8 and 11/12 |
| 5 — Auth confirmation from intent | P1a2-ii | P1a2-ii.7 (Auth result matrix), P1a2-ii.8 (dual-read proof) | Intent alone cannot confirm; must have exact UID+email reads+proof; definite-no-effect requires two-index absence |
| 6 — Crash vectors as comments | P1a2-ii | P1a2-ii.9 (real crash transitions) | Each crash point modeled as explicit event; reducer produces correct terminal/continuation state |
| 7 — Completion not atomic | P1a2-ii | P1a2-ii.10 (one pure transition) | Profile+completed+audit+ack appear together; partial commit rejected |
| 8 — Immutability missing | P1a2-i-B-3 | P1a2-i-B-3.1–3.2 (five data classes) | Operation identity/payload/UID, audit identity, dispatch identity, provenance, Auth proof — every mutation rejected |
| 9 — Acquisition generation | P1a2-ii | P1a2-ii.3 (acquisition: no generation change), P1a2-ii.4 (takeover: exact +1) | Acquire with generation!=0 rejected; takeover with generation jump > +1 rejected |
| 10 — Dispatch safety | P1a2-ii | P1a2-ii.11 (dispatch ack, orphan, idempotent enqueue) | Duplicate/stale/out-of-order dispatches cause no regression; orphan dispatch rejected |
| 11 — Terminal immutability 6/12 | P1a2-i-B-2/B-3 | P1a2-i-B-2.1–2.2 (33 negative vectors), P1a2-i-B-3.1–3.4 (3 positive terminal acknowledgements) | 11 state-transition types × 3 terminal statuses = 33 negative rejection vectors; ack_dispatch × 3 terminal statuses = 3 positive idempotency vectors; 36 total terminal vectors |
| 12 — Type guards bypass | P1a2-i-A-1a + P1a2-i-A-1b + P1a2-i-A-1c + P1a2-i-A-1d + P1a2-i-A-2 | P1a2-i-A-1c (strict state guard), P1a2-i-A-1d (strict event guard), P1a2-i-A-2.3–5 (constructor input validation) | Malformed state/event rejected at type level and runtime with exact-field-set validation; deep freeze prevents mutation; constructors reject invalid state/extra fields/malformed values |
| 13 — Bookkeeping understated | P1a2-i-A-1/A-2/i-B-1a/i-B-1b/B-2/B-3/ii/iii | Each sub-slice has component-sum-verified forecast | Each sub-slice recount after every RED/GREEN pair |

---

## P1a2-i-A-1a — Immutable Vocabulary + Genuine Type Proof

**Objective**: create `model.ts` with the complete state/event/output vocabulary consuming canonical P1a1 types via `import type` only. Immutable vocabulary constants as deeply frozen `as const` arrays (NOT mutable `Set` — `Object.freeze(new Set(...))` leaves `add/delete/clear` mutable). Genuine bidirectional type-level proof that the status→phase mapping covers every `StatusPhasePair` member with no missing and no extra pairs (NOT `_Eq<Extract<..., true>>` — that trick accepts missing and extra members). `TransitionResult` discriminated union. State shape interfaces. **No constructors, no deep freeze, no guards, no transitions, no CAS.**

**Ordinal-34 failures addressed**: 1 (no `Set` — use frozen `as const` arrays), 2 (genuine bidirectional type proof, not `_Eq`/`Extract` trick).

**Spec traceability**: Requirement: Operation Invariants (vocabulary shape).

**Design traceability**: "Executable Contract Before Production Code"; canonical vocabulary; invariant table (vocabulary shape only).

**Depends on**: P1a1 (frozen types + normalization + IDs + fixtures).

**Base / branch**: `slice/p1a2-i-a-1a-vocabulary-type-proof` branched from `slice/p1a1-types-normalization-ids`.

**Authorized paths**: `functions/src/provisioning/model.ts` (new — vocabulary ONLY), `functions/test/provisioning/model.test.ts` (new — vocabulary completeness + type proof), `openspec/changes/prepare-public-portfolio-repository/tasks.md`, `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`.

**Immutable protected paths**: `functions/src/provisioning/types.ts` read-only; `functions/tsconfig.json`, `.atl/skill-registry.md`, `.atl/.skill-registry.cache.json`, and `lib/core/theme/app_colors.dart` byte-identical.

**Forbidden**: no constructors, no `reduce()`, no CAS, no transitions, no deep freeze, no guards. No `types.ts`/`normalize.ts`/`ids.ts`/`fixtures.ts` modification. No `store.ts`/`memory_store.ts`/`firestore_store.ts`/`schemas.ts`/`cas.ts`/`audit.ts`/`profile.ts`. No `firebase-admin`. No `Set`. No `_Eq`/`Extract` type-proof trick. No runtime import from `./types.js` — only `import type { ... } from './types.js'`.

**Type-only import**: `import type { ProvisioningStatus, ProvisioningPhase, TerminalStatus, AuthAttemptResult, AuditCategory, StatusPhasePair } from './types.js'` — erased at runtime. Model-owned runtime constants (event type array, status→phase mapping) defined locally and compile-time constrained via `satisfies` against imported P1a1 aliases.

### Strict TDD order (RED → GREEN)

- [x] P1a2-i-A-1a.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0. Node v24.11.1 confirmed.
- [x] P1a2-i-A-1a.1 RED (FIRST AUTHORED MUTATION): author `functions/test/provisioning/model.test.ts` — vocabulary completeness (12 event types as frozen array), compile-negative bidirectional proof fixtures, independent literal tests for status→phase mapping. **Compile-negative fixtures (all must produce TS errors at type level)**: (a) deliberately omit one canonical `StatusPhasePair` member from the model's mapping — the test asserts this omission is detected; (b) deliberately add one extra `StatusPhasePair` member not in P1a1's canonical set — the test asserts this extra is detected. All fail because `model.ts` does not exist. RED via explicit `npx tsc` invocation:

  ```bash
  cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts
  ```
- [x] P1a2-i-A-1a.2 METADATA: update `tasks.md` and `apply-progress.md`. Recount.
- [x] P1a2-i-A-1a.3 GREEN: define 12 event types as `as const` frozen array. Consume P1a1 via `import type` only. Define model-owned status→phase mapping constrained as `Record<ProvisioningStatus, readonly ProvisioningPhase[]>` via `satisfies`. **Genuine bidirectional type proof** (NOT `_Eq<Extract<..., true>>` which accepts missing and extra members): use a non-distributive technique such as bidirectional assignability — assert `StatusPhasePair extends ModelStatusPhaseMap[keyof ModelStatusPhaseMap]` (no missing: every canonical pair is in the model map) AND `ModelStatusPhaseMap[keyof ModelStatusPhaseMap] extends StatusPhasePair` (no extra: every model map entry is canonical). Both directions must hold. The RED fixtures from step 1 verify that removing a pair breaks direction 1 and adding an extra pair breaks direction 2. Define `TransitionResult` discriminated union. Define state shape interfaces. All vocabulary constants deeply frozen. Tests pass.
- [x] P1a2-i-A-1a.4 REFACTOR: freeze. Type-level GREEN via explicit `npx tsc` on all P1a1 + `model.test.ts`.

### Verification commands

- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts` (type-level RED before `model.ts`)
- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts` (type-level GREEN — all P1a1 + A-1a files)
- `cd functions && npx tsc --noEmit` (source-only compatibility)
- `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` (runtime)
- Git-native count (Windows PowerShell): tracked — `git diff --numstat <P1a1-baseline> -- openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md`; untracked — `git diff --no-index --numstat -- NUL "functions/src/provisioning/model.ts"` and `git diff --no-index --numstat -- NUL "functions/test/provisioning/model.test.ts"` (exit code 1 expected). Sum additions + deletions across all four paths.

### Independent phase-contract acceptance (ordinal 35 FAILED; 36 FAILED; 37 FAILED; 38 INTERRUPTED; 39 FAILED; 40 FAILED; 41 INTERRUPTED; 42 FAILED; 43 FAILED)

- [x] All 12 event types defined as frozen `as const` array (no `Set`)
- [x] P1a1 types consumed ONLY via `import type` — no runtime import, no `Set`, no semantic duplication
- [x] Bidirectional type proof: no missing and no extra `StatusPhasePair` members (NOT `_Eq`/`Extract`) — compile-negative fixtures consume production `_ProofNoMissing`/`_ProofNoExtra` generics with direction-specific anti-vacuity (ordinal 42 fix, corrected by ordinal 43)
- [x] No constructors, no `reduce()`, no CAS, no transitions, no deep freeze, no guards
- [x] No `functions/tsconfig.json` modification
- [x] **Deep nested-array immutability** — `Object.freeze` per nested array (ordinal 36 fix, carried forward)
- [x] **Direction-specific generic anti-vacuity proof** — `_ProofNoMissing<M>` and `_ProofNoExtra<M>` are exported parameterized generics; compile-negative fixtures instantiate each with modified maps; weakening either generic alone to unconditional `true` triggers TS2578 on only its corresponding `@ts-expect-error` directive (ordinal 42+43)
- [ ] **Constraint domain correction** (ordinal 43) — `_FlatFromMap` and `_ProofNoMissing` constraints relaxed to `Record<string, readonly ProvisioningPhase[]>`, admitting missing-key maps as type arguments so only the proof body triggers TS2578; `_ProofNoExtra` keeps tight `Record<ProvisioningStatus,...>` domain since extra-map always has full key set. PENDING independent validation.

Ordinal 36 FAILED (120-line STOP breach). Ordinal 37 FAILED (anti-vacuity/bookkeeping). Ordinal 38 INTERRUPTED (zero changes). Ordinal 39 FAILED (direction anti-vacuity/stale records) at native 177. Ordinal 40 FAILED (unchanged). Ordinal 41 INTERRUPTED (zero-change/empty result). Ordinal 42 FAILED — `_ProofNoMissing<M extends Record<ProvisioningStatus,...>>` vacuous because the generic constraint itself consumed `@ts-expect-error` on `_MissMap`; weakening to `true` left compilation green; full candidate 289 lines, preserved with maintainer size exception. Ordinal 43 PENDING independent validation — relaxed constraint domain so missing-key map is admissible as type argument and failure comes only from proof body.

### Rollback boundary

Revert `functions/src/provisioning/model.ts`, delete `functions/test/provisioning/model.test.ts`, revert `openspec/changes/prepare-public-portfolio-repository/tasks.md` and `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` to pre-P1a2-i-A-1a state. P1a1 intact.

### P1a2-i-A-1a Forecast

| Component | Expected lines |
|---|---:|
| `model.ts` (vocabulary + type proof) | 90–110 |
| `model.test.ts` (vocabulary + type proof probes) | 90–130 |
| `tasks.md` + `apply-progress.md` | 20–30 |
| **Total** | **200–270** |

Warning at 300; STOP at 350; absolute max 400. No size:exception.

### Handoff to P1a2-i-A-1b

Frozen vocabulary (12 event types, state shape interfaces, output types, bidirectional type proof). P1a2-i-A-1b builds the deep freeze primitive on top.

---

## P1a2-i-A-1b — Descriptor-Safe Cycle-Safe Deep Freeze

**Objective**: implement `deepFreeze<T>(obj: T): Readonly<T>` in `model.ts` that safely traverses ALL nested children using descriptor-based enumeration (NOT direct property access — which invokes getters). Cycle-safe via `WeakSet`. Handles throwing accessors by detecting `get` descriptors. Covers string-keyed AND symbol-keyed own properties via `Reflect.ownKeys()`. **No constructors, no guards, no transitions, no vocabulary changes.**

**Ordinal-34 failures addressed**: 3 (descriptor-safe — no getter invocation, throwing accessors detected and skipped), cycle-safe (circular references do not abort), pre-frozen parent with unfrozen children still traversed.

**Depends on**: P1a2-i-A-1a (frozen vocabulary).

**Base / branch**: `slice/p1a2-i-a-1b-deep-freeze` branched from `slice/p1a2-i-a-1a-vocabulary-type-proof`.

**Authorized paths**: `functions/src/provisioning/model.ts` (extend — add `deepFreeze`), `functions/test/provisioning/model.test.ts` (extend — add freeze probes), `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping), `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates).

**Immutable protected paths**: `functions/src/provisioning/types.ts` read-only; `functions/tsconfig.json`, `.atl/skill-registry.md`, `.atl/.skill-registry.cache.json`, and `lib/core/theme/app_colors.dart` byte-identical.

**Forbidden**: no constructors, no guards, no transitions, no CAS. No vocabulary changes. No P1a1 file modification.

### Strict TDD order (RED → GREEN)

- [x] P1a2-i-A-1b.0 ENTRY/FAIL-FAST.
- [x] P1a2-i-A-1b.1 RED: author freeze probes — array push/index/delete rejected, pre-frozen-parent nested mutation, deep nested at every level, symbol-keyed properties, throwing getter does not abort traversal, circular reference handled, non-enumerable properties covered. All fail because `deepFreeze` does not exist.
- [x] P1a2-i-A-1b.2 METADATA: recount.
- [x] P1a2-i-A-1b.3 GREEN: `deepFreeze` uses `Object.getOwnPropertyDescriptors()` to enumerate properties (NOT `obj[key]` which invokes getters). Detects `get` descriptors and skips/handles throwing accessors safely. Uses `Reflect.ownKeys()` for coverage (string + symbol). Cycle-safe via `WeakSet`. Recurses into children BEFORE freezing parent. Even if parent already frozen, unfrozen children are still traversed. Tests pass.
- [x] P1a2-i-A-1b.4 REFACTOR: freeze. Type-level GREEN.

### Verification commands

- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/model.ts test/provisioning/model.test.ts`
- `cd functions && npx tsc --noEmit`
- `cd functions && node --experimental-strip-types test/provisioning/model.test.ts`
- Git-native count (Windows PowerShell): `git diff --numstat <A-1a-baseline> -- functions/src/provisioning/model.ts functions/test/provisioning/model.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md`; sum additions + deletions.

### Independent phase-contract acceptance (UNCHECKED)

- [ ] Descriptor-based enumeration (no getter invocation)
- [ ] Throwing getter does not abort traversal
- [ ] Cycle-safe (circular reference handled)
- [ ] Pre-frozen parent with unfrozen children → all levels frozen after deepFreeze
- [ ] Symbol-keyed + non-enumerable properties covered
- [ ] Array push/index/delete rejected after freeze
- [ ] No constructors, no guards, no transitions

### Rollback boundary

Revert `functions/src/provisioning/model.ts` to P1a2-i-A-1a frozen state, revert `functions/test/provisioning/model.test.ts` to P1a2-i-A-1a frozen state, revert `openspec/changes/prepare-public-portfolio-repository/tasks.md` and `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` to pre-P1a2-i-A-1b state. P1a1 + A-1a intact.

### P1a2-i-A-1b Forecast

| Component | Expected lines |
|---|---:|
| `model.ts` extensions (`deepFreeze`) | 60–80 |
| `model.test.ts` extensions (freeze probes) | 120–160 |
| `tasks.md` + `apply-progress.md` | 20–30 |
| **Total** | **200–270** |

Warning at 300; STOP at 350; absolute max 400. No size:exception.

### Handoff to P1a2-i-A-1c

Frozen deep freeze primitive. P1a2-i-A-1c builds the strict state guard.

---

## P1a2-i-A-1c — Strict State Guard

**Objective**: implement `isValidState(value)`, `isStatus(value)`, `isPhase(value)` in `model.ts` with strict exact-field-set validation, canonical lower-case UUID/SHA identifiers, non-negative integer counters, finite non-negative timestamps, exact recursive `NormalizedPayload`/Auth shapes, Firebase UID length bounds, and exact `Object.prototype` roots. **No constructors, no event guard, no transitions, no CAS.**

**Ordinal-34 failures addressed**: 4 (state guard side — null ids, NaN, mismatched pairs, class/polluted roots, non-plain payloads).

### A-1c-R field-to-validator matrix (derived contract)

| Field / location | Spec/design/types source | Required validator | Exact nullability |
|---|---|---|---|
| `operationId` / `OperationState.operationId` | `design.md` Canonical Vocabulary and Identity; `types.ts` `OperationState` | Lower-case UUID-v4; reject malformed, upper-case, empty, or non-string values | Required, never `null` |
| `fingerprint` / `OperationState.fingerprint` | `design.md` identity and `(operationId,fingerprint)` idempotency; `types.ts` `OperationState` | Lower-case 64-hex SHA-256; `operationId` is excluded from the digest input | Required, never `null` |
| `ownerToken` / `OperationState.ownerToken` | `design.md` Full CAS and Lease Contract; `types.ts` `string | null` | `null` outside an owned active lease; active value must be a lower-case 64-hex fencing digest; reject empty/malformed/upper-case values | `null` in pending and terminal states; non-`null` for active ownership |
| `intendedUid` / `OperationState.intendedUid` | `design.md` canonical `intendedUid`; `types.ts` `string | null` | `null` or a non-empty Firebase UID of length 1–128; immutable after submission wins | Nullable in the model shape; lifecycle requires the generated UID after submission wins |
| `returnedUid` / `AuthAttempt.returnedUid` | `design.md` Auth attempt persistence; `types.ts` `AuthAttempt` | `null` or a non-empty Firebase UID of length 1–128; validate exact returned value, never coerce | Nullable |
| `authAttempt.attemptId` | `design.md` `attemptId` is the Auth-intent dispatch ID; `types.ts` `AuthAttempt` | Required lower-case 64-hex dispatch digest; must identify the single Auth intent | `authAttempt` may be `null`; field is non-`null` when the object exists |
| `authAttempt.proof.attemptId` | `design.md` Auth proof; `types.ts` `AuthProof` | Required lower-case 64-hex digest and exact equality with the parent `authAttempt.attemptId` | `proof` may be `null`; field is non-`null` when proof exists |
| `authAttempt.proof.uidRead` | `design.md` mandatory UID/email dual-read proof; `types.ts` `AuthProof` | Required non-empty Firebase UID of length 1–128; 128 accepted and 129 rejected | `proof` may be `null`; field is non-`null` when proof exists |
| `dispatchId` / `OperationState.currentDispatchId` | `design.md` dispatch identity and `/provisioningDispatch/{dispatchId}`; `types.ts` `currentDispatchId` | Lower-case 64-hex deterministic dispatch digest; dispatch record identity itself is required | Dispatch record `dispatchId` is required; `currentDispatchId` is `null` in pending/terminal and non-`null` while active |

Nested contract: `authAttempt` is `null | AuthAttempt`, `proof` is `null | AuthProof`, `callStartedAt` is `number | null`, and `returnedUid`/`returnedEmail` are `string | null`. These nullability rules come from `types.ts`; lifecycle-state restrictions come from `design.md` and are not broadened by the guard.

**Depends on**: P1a2-i-A-1b (frozen deep freeze).

**Base / branch**: `slice/p1a2-i-a-1c-state-guard` branched from `slice/p1a2-i-a-1b-deep-freeze`.

**Authorized paths**: `functions/src/provisioning/model.ts` (extend — add state guards), `functions/test/provisioning/model.test.ts` (extend — add state guard probes), `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping), `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates).

**Immutable protected paths**: `functions/src/provisioning/types.ts` read-only; `functions/tsconfig.json`, `.atl/skill-registry.md`, `.atl/.skill-registry.cache.json`, and `lib/core/theme/app_colors.dart` byte-identical.

**Forbidden**: no constructors, no event guard, no transitions, no CAS. No P1a1 file modification.

### Strict TDD order (RED → GREEN)

- [x] P1a2-i-A-1c.0 ENTRY/FAIL-FAST.
- [x] P1a2-i-A-1c.1 RED: author state guard probes — null `operationId` rejected, NaN `generation` rejected, mismatched status-phase pair rejected, class instance as root rejected, polluted prototype rejected, non-plain normalized payload rejected, missing required field rejected, extra field rejected, symbol-keyed property rejected. All fail because guards do not exist.
- [x] P1a2-i-A-1c.2 METADATA: recount.
- [x] P1a2-i-A-1c.3 GREEN: `isValidState` checks exact field set (no missing, no extra), plain object (not class instance, not polluted prototype), no null required identifiers, no NaN numbers, valid status-phase pair, no symbol-keyed extras. `isStatus` and `isPhase` validate against frozen vocabulary. Tests pass.
- [x] P1a2-i-A-1c.4 REFACTOR: freeze. Type-level GREEN.

Ordinal 53 FAILED fresh validation (`22/135`, evidence `sha256:fd128f77c161abc45a01ecd4de4b72e586fa2d6efeddfe47c532163aac4c01a8`). Ordinal 54 also FAILED (`192/183` correction; evidence `sha256:941715c1d228e00b94f63e8f220b026a07d578b5747ca922104fc8cc862bf5cb`) with seven semantic assertions still failing. A-1c.0–.4 remain historical implementation evidence only; independent acceptance stays unchecked. The earlier wording `NaN retryCount` is superseded: the ordinal-53 probe mutated `generation`; `retryCount` belongs to P1a2-iii and is not an A-1c field.
Ordinal 60 FAILED: six fractional timestamps were accepted (`sha256:021a5ea4c83ac511b90e87d6547657af3a8c8ac19f8ce7edabb12ba1d178f815`). Ordinal 61 corrects the shared timestamp predicate only; A-1c independent acceptance remains unchecked.

### Verification commands

- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts` (type-level GREEN — all P1a1 + A-1a + A-1b + A-1c files)
- `cd functions && npx tsc --noEmit` (source-only compatibility — no TS5097)
- `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` (runtime GREEN — includes all A-1a + A-1b + A-1c tests)
- Git-native count (Windows PowerShell): `git diff --numstat <A-1b-baseline> -- functions/src/provisioning/model.ts functions/test/provisioning/model.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md`; sum additions + deletions.

### Independent phase-contract acceptance (UNCHECKED)

- [ ] Null required identifiers rejected
- [ ] NaN rejected
- [ ] Mismatched status-phase pair rejected
- [ ] Class instance root rejected
- [ ] Polluted prototype rejected
- [ ] Non-plain normalized payload rejected
- [ ] Missing/extra fields rejected
- [ ] Symbol-keyed extras rejected
- [ ] No constructors, no event guard, no transitions

### Rollback boundary

Revert `functions/src/provisioning/model.ts` to P1a2-i-A-1b frozen state, revert `functions/test/provisioning/model.test.ts` to P1a2-i-A-1b frozen state, revert `openspec/changes/prepare-public-portfolio-repository/tasks.md` and `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` to pre-P1a2-i-A-1c state. P1a1 + A-1a + A-1b intact.

### P1a2-i-A-1c Forecast (historical implementation forecast)

| Component | Expected lines |
|---|---:|
| `model.ts` extensions (state guards) | 50–70 |
| `model.test.ts` extensions (state guard probes) | 130–170 |
| `tasks.md` + `apply-progress.md` | 20–30 |
| **Total** | **200–270** |

Warning at 300; STOP at 350; absolute max 400. No size:exception.

This `200–270` forecast belongs to the original implementation attempt; the recovery slice is governed only by the compaction-first A-1c-R forecast below.

### A-1c recovery replan — pending explicit native reset

The ordinal-54 correction budget is exhausted. The preserved candidate is not accepted: pre-recovery final A-1c scope is `333/350`, and the remaining proven blockers are malformed non-SHA `ownerToken` acceptance and Firebase UID values longer than 128 characters. No further correction may be attached to ordinal 54 or started without a new explicit native reset and declared budget.

A-1c-R is a recovery subplan under the existing A-1c slice, not a new downstream slice; the top-level 13-slice forecast and chain topology remain unchanged.

### Review Workload Forecast — A-1c-R

| Field | Decision |
|---|---|
| Recovery shape | One bounded recovery slice only |
| Chained PRs recommended | No; one slice is reviewable if the final `<350` proof remains valid |
| Size exception | None; the final STOP is binding |
| Pre-recovery final scope | `333/350`; compaction must reach `<=315` before additions |
| Fallback | If the complete root fix cannot fit below 350, stop without editing and replan; do not compress the truth afterward |

### Compaction-first changed-line forecast (mandatory preflight)

This is a conditional forecast, not authorization. The preflight MUST measure the complete root fix blob-aware from the new reset tree and original `ba061e5438d59c7494fc198ccb530eed7f15b0c5` before the first mutation. If the measured complete fix cannot remain `<350`, stop without editing.

| Step | Forecasted edit churn (additions + deletions) | Effect on final baseline scope | Projected final |
|---|---:|---:|---:|
| Test compaction/deletions first | `0A + 18D = 18` | `-18` | `315` |
| RED ownerToken/UID boundary probes | `12A + 0D = 12` | `+12` | `327` |
| Canonical predicates with helper reuse | `7A + 4D = 11` | `+3` | `330` |
| Truthful records (`tasks.md` now; `apply-progress.md` after GREEN) | `4A + 14D = 18` | `+4` | `334` |
| **Measured total** | **`<=67` correction churn** | **`+1`** | **`334/350`** |

The arithmetic leaves a conditional 37-line final margin, but the mandatory preflight overrides this estimate. No exception or safe-budget claim is valid until the measured complete root fix confirms `<350`.

- [x] Recovery assessment: preserve the four-path candidate and record ordinal 53/54 as failed; do not carry implementation checkmarks as acceptance.
- [ ] A-1c-R.0 ENTRY: after a maintainer-authorized reset, verify `next_action=begin`; do not modify `apply-progress.md`, code/tests, or the native ledger during planning.
- [x] A-1c-R.1 RED: compact redundant test scaffolding first, then add immutable causal probes for lowercase 64-hex `ownerToken`, exact nullability, and every UID-bearing field at lengths 128 and 129; reproduce the ordinal-54 RED before production edits.
- [x] A-1c-R.2 GREEN: implement only the minimum canonical owner-token and UID-length predicates in `model.ts`, reusing existing pure helpers; extend `model.test.ts` only for the proven failures.
- [x] A-1c-R.3 REFACTOR/ACCEPTANCE: native ordinal 64 passed the fresh 405/405 semantic matrix, all six fractional timestamp checks, and exact four-path scope 350/350.
- [x] A-1c-R.4 RECORDS: accepted at candidate tree `8bbf37438a41379a6214482a9571051d55a050a6`, evidence `sha256:0113ec2afd80162e4ef0b6524ae16843626b053cf870a0ce4addcea0aa53f738`.

### A-1c-R independent acceptance requirements (ACCEPTED)

- [x] Ordinal 64 proves the full semantic/type/runtime/identity/nullability/UID contract, exact 350/350 endpoint, zero validation-time repository changes, and deleted external harness.

Recovery boundary: `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, and the two SDD records only after reset; no size exception is implied. A-1d remains blocked until A-1c is independently accepted.

### Handoff to P1a2-i-A-1d

A-1c is accepted on ordinal-64 evidence; A-1d remains pending and untouched.

---

## P1a2-i-A-1d — Strict Event Guard

**Objective**: implement `isEventType(value)`, `isValidEvent(value)` in `model.ts` with strict per-event-type payload validation. Rejects missing payload fields, extra payload fields, null event identifiers, NaN numeric fields. **No constructors, no state guard changes, no transitions, no CAS.**

**Ordinal-34 failures addressed**: 4 (event guard side — missing/extra payload fields per event type, null ids, NaN).

**Depends on**: P1a2-i-A-1c (frozen state guard).

**Base / branch**: `slice/p1a2-i-a-1d-event-guard` branched from `slice/p1a2-i-a-1c-state-guard`.

**Authorized paths**: `functions/src/provisioning/model.ts` (extend — add event guards), `functions/test/provisioning/model.test.ts` (extend — add event guard probes), `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping), `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates).

**Immutable protected paths**: `functions/src/provisioning/types.ts` read-only; `functions/tsconfig.json`, `.atl/skill-registry.md`, `.atl/.skill-registry.cache.json`, and `lib/core/theme/app_colors.dart` byte-identical.

**Forbidden**: no constructors, no state guard changes, no transitions, no CAS. No P1a1 file modification.

### Strict TDD order (RED → GREEN)

- [x] P1a2-i-A-1d.0 ENTRY/FAIL-FAST.
- [x] P1a2-i-A-1d.1 RED: author event guard probes — unknown event type rejected, missing payload field for specific event type rejected, extra payload field rejected, null `eventId` rejected, NaN numeric fields rejected, non-finite (`Infinity`, `-Infinity`) rejected, **class-instance root rejected** (not a plain object), **polluted-prototype root rejected** (`Object.create(null)`-violating), **non-plain payloads rejected** (Date instance, class instance, polluted prototype as payload), **symbol-keyed extras on event root rejected**, event-specific missing/extra fields rejected. All fail because guards do not exist.
- [x] P1a2-i-A-1d.2 METADATA: recount.
- [x] P1a2-i-A-1d.3 GREEN: `isEventType` validates against frozen 12-type array. `isValidEvent` checks: (a) root is plain object (not class instance, not null, not array, not Date, not polluted prototype); (b) exact field set per event type (no missing, no extra payload fields); (c) correct types for every field (no null required identifiers, no NaN, no non-finite numbers); (d) no symbol-keyed extras on event root. Payload sub-objects are also checked for plain-object-ness (reject Date, class instances, polluted prototypes). Tests use independent literal expectations per event type. Tests pass.
- [x] P1a2-i-A-1d.4 REFACTOR: freeze P1a2-i-A-1. Final type-level GREEN via explicit `npx tsc` on all P1a1 + `model.ts` + `model.test.ts`. Source-only `npx tsc --noEmit` compatibility proof.
- [x] A-1d ordinal-69 bounded correction (implementation evidence only): reject root, payload, and nested-proof accessors and reflection-trapping proxies fail-closed through own-data descriptor inspection. Schema-equivalent `acquire`/`takeover` and `auth_no_effect`/`auth_ambiguous` payloads remain valid by shape; no absent provenance discriminant was invented. Independent acceptance remains unchecked.

### Verification commands

- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts`
- `cd functions && npx tsc --noEmit`
- `cd functions && node --experimental-strip-types test/provisioning/model.test.ts`
- Git-native count (Windows PowerShell): `git diff --numstat <A-1c-baseline> -- functions/src/provisioning/model.ts functions/test/provisioning/model.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md`; sum additions + deletions.

### Independent phase-contract acceptance (UNCHECKED)

- [x] Ordinal 73 independent acceptance: all 12 event-guard criteria passed.

### Rollback boundary

Revert `functions/src/provisioning/model.ts` to P1a2-i-A-1c frozen state, revert `functions/test/provisioning/model.test.ts` to P1a2-i-A-1c frozen state, revert `openspec/changes/prepare-public-portfolio-repository/tasks.md` and `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` to pre-P1a2-i-A-1d state. P1a1 + A-1a + A-1b + A-1c intact.

### P1a2-i-A-1d Forecast

| Component | Expected lines |
|---|---:|
| `model.ts` extensions (event guards) | 50–70 |
| `model.test.ts` extensions (event guard probes) | 130–170 |
| `tasks.md` + `apply-progress.md` | 20–30 |
| **Total** | **200–270** |

Warning at 300; STOP at 350; absolute max 400. No size:exception.

### P1a2-i-A-1 Combined Forecast (4 children)

| Child | Expected |
|---|---:|
| P1a2-i-A-1a | 200–270 |
| P1a2-i-A-1b | 200–270 |
| P1a2-i-A-1c | 200–270 |
| P1a2-i-A-1d | 200–270 |
| **Total P1a2-i-A-1** | **800–1,080** |

Combined absolute max: 1,600 (4 × 400). Expected range: 800–1,080. No size:exception. Each child has its own warning 300, STOP 350, max 400.

### Handoff contract to P1a2-i-A-2

Frozen vocabulary (12 event types, state shape interfaces, output types, bidirectional type proof) + frozen deep freeze primitive (descriptor-safe, cycle-safe, getter-safe) + frozen strict state guard (exact field set, no null/NaN/class/polluted/non-plain) + frozen strict event guard (exact per-event payload validation). P1a2-i-A-2 builds the four validated constructors on top of this frozen foundation.

---

## P1a2-i-A-2 — Validated Constructors + TypeScript Compatibility

**Objective**: implement all four non-transition constructors (`createInitialState`, `createEvent`, `createSuccessResult`, `createFailureResult`) that validate their own inputs with strict shape/exact-field/no-extra-field checks before deep-freezing outputs. Each constructor rejects invalid state, extra fields, and malformed values. Source-only TypeScript compatibility (`npx tsc --noEmit` works without TS5097). No transition behavior, no CAS, no reducer logic.

**Ordinal-30 failures addressed**: 3 (`createSuccessResult` accepted invalid state), 4 (`createInitialState` accepted extra fields and malformed createdAt), 8 (TS5097/honest counting — partially via separate slice).

**Spec traceability**: Requirement: Operation Invariants (constructor shape); Requirement: Operation Identity and Idempotency (initial state shape).

**Design traceability**: "Executable Contract Before Production Code"; canonical vocabulary.

**Depends on**: P1a2-i-A-1d (frozen vocabulary + deep freeze + strict state guard + strict event guard).

**Base / branch**: `slice/p1a2-i-a-2-validated-constructors` branched from `slice/p1a2-i-a-1d-event-guard`.

**Allowed paths** (exact):

- `functions/src/provisioning/model.ts` (extend — add four constructors: `createInitialState`, `createEvent`, `createSuccessResult`, `createFailureResult`)
- `functions/test/provisioning/model.test.ts` (extend — add constructor input-validation probes)
- `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping)
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates)

**Forbidden in P1a2-i-A-2**: all P1a2-i-A-1 forbidden paths remain. Additionally: no modification of P1a2-i-A-1 frozen vocabulary, deep freeze, or type guards. No `reduce()`, no CAS predicate, no transition logic, no boundary behavior.

### Strict TDD order (RED → GREEN)

- [x] P1a2-i-A-2.0 ENTRY/FAIL-FAST: `node --version` confirmed v24.11.1 (>= 22.6.0).
- [x] P1a2-i-A-2.1 RED — Constructor input validation tests for all four constructors were authored before source; native strip-types harness exits 1 because `createEvent` (and the other constructors) are not exported.
- [x] P1a2-i-A-2.2 METADATA: updated `tasks.md` and `apply-progress.md`; Git-native begin-tree recount after RED is 46 lines.
- [x] P1a2-i-A-2.3 GREEN — `createInitialState(params)` validates via the strict state guard after valid-Date timestamp canonicalization; extra/missing fields, malformed dates, invalid pairs, identifiers, counters, and nested payloads reject; valid result is deeply frozen.
- [x] P1a2-i-A-2.4 RED → GREEN — `createEvent(type, payload)` validates through the strict event guard; all 12 valid payload shapes deep-freeze, while unknown/missing/extra/proxy/malformed-proof inputs reject.
- [x] P1a2-i-A-2.5 RED → GREEN — `createSuccessResult(state)` calls `isValidState` before deep-freezing; `createFailureResult(reason)` uses the existing length-based non-empty-string predicate (whitespace-only strings remain valid); invalid values reject.
- [x] P1a2-i-A-2.6 RED → GREEN — Explicit source+test noEmit and source-only `tsc --noEmit -p functions/tsconfig.json` both pass without TS5097.
- [x] P1a2-i-A-2.7 REFACTOR: no further refactor needed; final runtime and TypeScript GREEN checks pass. Final type-level GREEN via explicit `npx tsc`:

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
- Git-native count (Windows PowerShell): all paths tracked after P1a2-i-A-1d commit — `git diff --numstat <P1a2-i-A-1d-baseline> -- functions/src/provisioning/model.ts functions/test/provisioning/model.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md`; sum additions + deletions.

### Independent phase-contract acceptance (UNCHECKED — fresh context)

- [x] `createInitialState` rejects extra fields, malformed createdAt, missing required fields
- [x] `createSuccessResult` rejects invalid state (wrong status/phase pair, missing fields)
- [x] `createEvent` rejects unknown types, missing/extra payload fields
- [x] `createFailureResult` rejects empty reason
- [x] All constructors deep-freeze their outputs using P1a2-i-A-1's `deepFreeze`
- [x] No constructors perform transitions, CAS, acquisition, or reducer behavior
- [x] Source-only `npx tsc --noEmit` passes (no TS5097)

### Rollback boundary

Revert `functions/src/provisioning/model.ts` to P1a2-i-A-1d frozen state, revert `functions/test/provisioning/model.test.ts` to P1a2-i-A-1d frozen state, revert `tasks.md` and `apply-progress.md` to pre-P1a2-i-A-2 state. P1a1 + P1a2-i-A-1 (all 4 children) intact.

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
| P1a2-i-A-1a | 200–270 |
| P1a2-i-A-1b | 200–270 |
| P1a2-i-A-1c | 200–270 |
| P1a2-i-A-1d | 200–270 |
| P1a2-i-A-2 | 120–170 |
| **Total P1a2-i-A** | **920–1,250** |

Combined absolute max: 1,900 (1,600 + 300). No size:exception. Per-child limits: each A-1 child EW 300, STOP 350, max 400; A-2 EW 200, STOP 250, max 300.

---

## P1a2-i-B — CAS, Reducer, and Immutability (four ordered children)

**Surgical replan**: P1a2-i-A-2 is independently accepted and frozen; P1a2-i-B has not started. This section replaces only the unstarted monolithic implementation plan with two ordered B-1 children followed by the preserved B-2 and B-3 children. Completed history, the P1a2-i-A foundation, and unrelated tasks remain unchanged. The current edit does not modify `apply-progress.md`.

**Parent contract**: all four children remain pure-model work. B-1a establishes the request contract and reducer surface; B-1b adds the module-private CAS/lease fence and unsupported dispatch; B-2 installs terminal immutability and monotonic state; B-3 completes data immutability and acknowledgement semantics. They consume the frozen P1a2-i-A vocabulary, guards, deep freeze, and constructors; expose only `reduce(state, request)` as the public transition API; implement no boundary transitions from P1a2-ii and no terminalization from P1a2-iii. The 800-line session review budget is not a size exception: the parent aggregate remains capped at 600 changed lines with no exception.

**Terminal-policy boundary**: B-1a and B-1b do not install terminal policy. Until B-2 is accepted, even an exact terminal tuple may pass request/CAS checks and reach the non-mutating `unsupported_event` outcome; B-2 is the first child allowed to reject state-transition events for terminal statuses. No child in this parent implements a boundary transition or terminalization.

**Spec traceability**: Requirement: Operation Invariants (terminal immutability, CAS, monotonic state, data immutability).

**Design traceability**: Full CAS and lease contract; invariant table; executable pure reducer contract.

**Parent dependency**: P1a2-i-A-2 (frozen vocabulary + deep freeze + strict guards + validated constructors).

**Shared allowed paths** (each child may touch only its own behavior plus its own bookkeeping):

- `functions/src/provisioning/model.ts`
- `functions/test/provisioning/model.test.ts`
- `openspec/changes/prepare-public-portfolio-repository/tasks.md`
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`

**Shared forbidden paths/behavior**: no modification of the P1a2-i-A foundation or `functions/tsconfig.json`; no Firebase/Auth/Firestore/Cloud Tasks/emulator code; no boundary transition implementations (`acquire`, `takeover`, `auth_*`, `profile_commit`); no terminalization implementation; no terminal-policy installation in B-1a/B-1b; no public CAS helper, classifier, or named transition function.

### Preserved B-1 history (parent-level; not child acceptance)

- [x] P1a2-i-B.0 HISTORY: inherited entry evidence verified `node --version` >= 22.6.0; local evidence was Node v24.11.1. This is preserved Node evidence only, not B-1a or B-1b acceptance.
- [x] P1a2-i-B.HISTORY (BLOCKED BEFORE RED): the inherited harness passed, but no B-1 test or production mutation was made because the old `reduce(state, event)` shape could not carry an independent expected tuple. This is historical evidence, not acceptance; no B-1a/B-1b completion is carried forward and `apply-progress.md` remains unchanged by this amendment.
- [x] P1a2-i-B.REPLAN: fresh planning validation rejected the monolithic B-1 budget and tracker target; the maintainer approved the ordered B-1a/B-1b split below. This records planning history only.

### P1a2-i-B-1a — Request Contract + Reducer Surface

**Objective**: add `ExpectedCAS`, `ReducerRequest`, and the exact `reduce(state: OperationState, request: ReducerRequest): TransitionResult` surface. Validate the exact descriptor-safe plain-record envelopes (`expected,observedAt,event` and the eight ExpectedCAS fields), including finite non-negative integral `observedAt`, without getter execution or mutation. Preserve `ModelEvent` payload shape and the nested strict event guard unchanged. This child stops after failure precedence through `invalid_event`; it does not implement CAS equality, lease liveness, unsupported dispatch, terminal policy, or any transition.

**Depends on / branch**: accepted P1a2-i-A-2; `slice/p1a2-i-b-1a-request-reducer` branched from `slice/p1a2-i-a-2-validated-constructors`; PR target is the accepted P1a2-i-A-2 branch, not `feature/tracker`.

**Diff boundary**: request types, descriptor-safe request/ExpectedCAS validation, reducer-surface tests, and B-1a bookkeeping only. Existing `isValidState` behavior is preserved; B-1a tests MUST NOT claim new accessor/proxy fail-closed state validation. Do not carry B-1b CAS/lease/dispatch behavior or B-2/B-3 behavior into this child.

**Strict TDD order (RED → GREEN → REFACTOR)**

- [ ] P1a2-i-B-1a.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 against the accepted A-2 baseline before focused tests and type checks.
- [ ] P1a2-i-B-1a.1 RED: author black-box request/ExpectedCAS tests before reducer source. Missing/extra/symbol/accessor/class/polluted-prototype/proxy-trap/malformed envelopes fail closed as `invalid_request`/`invalid_expected`; getter counters, canonical snapshots, direct references, and deep-field checks prove no getter execution, input mutation, or request mutation (JSON is supplementary only).
- [ ] P1a2-i-B-1a.2 RED: author `observedAt` vectors for fractional, negative, non-finite, and malformed values, plus independent failure-precedence vectors through `invalid_event`; retain nested missing/extra strict event-payload probes without adding CAS fields to the event.
- [ ] P1a2-i-B-1a.3 RED: add explicit TypeScript probes proving the new request signature compiles while old `reduce(state,event)` calls and missing/extra ExpectedCAS fields fail with `@ts-expect-error`; assert the readonly request carrier is not mutated or retained.
- [ ] P1a2-i-B-1a.4 GREEN: define `ExpectedCAS`/`ReducerRequest` and descriptor-read exact-record validators; validate `observedAt`; keep the accepted `isValidState` and `isValidEvent` behavior unchanged.
- [ ] P1a2-i-B-1a.5 GREEN: wire `reduce()` through `state → request → expected → event` validation and literal `invalid_state`/`invalid_request`/`invalid_expected`/`invalid_event` outcomes only. Do not compare CAS fields, evaluate lease liveness, or claim `unsupported_event` here.
- [ ] P1a2-i-B-1a.6 REFACTOR: freeze B-1a, rerun the inherited A checks, explicit source+test TypeScript plus old-call probes, source-only `npx tsc --noEmit`, and the model harness.

**Independent expected outcomes**: malformed request/ExpectedCAS records fail closed with the correct literal outcome; `observedAt` is exact and descriptor-safe; failure precedence reaches `invalid_event`; nested event guards remain unchanged; the new signature compiles and the old signature is rejected; canonical snapshots plus direct reference/deep-field checks prove every rejection is non-mutating. No CAS equality/liveness, unsupported dispatch, terminal policy, or transition behavior is accepted in B-1a.

**Focused test command**: `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` — B-1a request/reducer-surface assertions plus the frozen A baseline.

**Runtime harness**: the same Node strip-types command drives independent in-memory state/request/event fixtures through `reduce()`; no Firebase, Auth, Firestore, Cloud Tasks, or emulator runtime is claimed for this pure contract slice.

**Acceptance gate**: exact descriptor-safe request and ExpectedCAS records, `observedAt`, failure precedence through `invalid_event`, unchanged nested event validation, new-signature TypeScript acceptance, old-call rejection, and complete canonical-snapshot/direct-reference/deep-field non-mutation evidence pass; existing `isValidState` behavior is consumed without any new accessor/proxy state-validation claim; B-1b/B-2 behavior remains absent.

**Rollback boundary**: revert only B-1a additions in `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, and the B-1a bookkeeping entries to the accepted P1a2-i-A-2 baseline. P1a1 and all P1a2-i-A behavior remain intact.

### P1a2-i-B-1a Forecast

| Component | Expected lines |
|---|---:|
| `model.ts` request types, validation, and reducer surface | 30–40 |
| `model.test.ts` request/precedence/type/non-mutation probes | 55–70 |
| B-1a bookkeeping | 20–25 |
| **Total P1a2-i-B-1a** | **105–135** |

Early warning is 120; STOP/reforecast is 170; absolute max is 200. No size:exception and no borrowing from B-1b/B-2/B-3. If this child cannot fit within 200 after an honest Git-native recount, stop and return `blocked` rather than exceeding its independent cap.

### P1a2-i-B-1b — CAS + Lease + Unsupported Dispatch

**Objective**: add the module-private eight-field equality predicate and authoritative lease liveness using `observedAt` on top of the accepted B-1a request surface. Prove eight independent mismatch vectors, keep lease equality separate from active lease liveness, and route an exact-live expected tuple to non-mutating `unsupported_event`. No boundary transition, terminalization, or public CAS helper is implemented.

**Depends on / branch**: accepted P1a2-i-B-1a; `slice/p1a2-i-b-1b-cas-lease` branched from `slice/p1a2-i-b-1a-request-reducer`; PR target is the B-1a branch.

**Diff boundary**: module-private CAS equality/liveness, unsupported dispatch, their tests, and B-1b bookkeeping only. Do not change B-1a request validation or add B-2/B-3 behavior.

**Strict TDD order (RED → GREEN → REFACTOR)**

- [ ] P1a2-i-B-1b.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 and the accepted B-1a baseline before mutation.
- [ ] P1a2-i-B-1b.1 RED: author independent `reduce()` vectors that alter each of `fingerprint,status,phase,generation,version,ownerToken,currentDispatchId,leaseExpiresAt` separately and expect literal `cas_mismatch`; canonical snapshots plus direct reference/deep-field checks prove the complete state/request/event inputs remain unchanged.
- [ ] P1a2-i-B-1b.2 RED: author lease vectors showing equality is checked separately from liveness: equal-but-expired and active-null leases return literal `lease_not_live` using caller `observedAt`, while non-active/null-lease cases do not claim active lease liveness.
- [ ] P1a2-i-B-1b.3 RED: author exact-live dispatch vectors for boundary and terminalization events and assert literal `unsupported_event` with no mutation; direct reference/deep-field checks cover state, request, and event inputs. Exact terminal tuples may reach this outcome because B-1a/B-1b do not install terminal policy. Keep all transition behavior absent.
- [ ] P1a2-i-B-1b.4 GREEN: implement the module-private eight-field equality predicate, separate `observedAt` lease predicate, and non-mutating unsupported dispatch behind the validated B-1a request surface; never derive expectations, read a clock, retain a request, or mutate inputs.
- [ ] P1a2-i-B-1b.5 REFACTOR: freeze B-1b, rerun B-1a/A request, event, state, and TypeScript regressions, source-only `npx tsc --noEmit`, and the focused model harness.

**Independent expected outcomes**: each of the eight altered fields returns `cas_mismatch`; equal lease plus expired/active-null state returns `lease_not_live` from `observedAt`; an exact-live tuple reaches `unsupported_event`, including exact terminal tuples until B-2; every result is proven non-mutating for state, request, and event by canonical snapshot plus direct reference/deep-field checks; only `reduce()` is public and no transition/terminalization behavior exists.

**Focused test command**: `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` — B-1b CAS/lease/dispatch assertions plus the frozen B-1a/A baseline.

**Runtime harness**: the Node strip-types model harness drives independent in-memory state/request/event fixtures through `reduce()`; no Firebase, Auth, Firestore, Cloud Tasks, or emulator runtime is claimed for this pure slice.

**Acceptance gate**: module-private eight-field CAS equality, eight independent mismatch vectors, separate lease equality/liveness with authoritative `observedAt`, exact-live `unsupported_event`, exact terminal tuple behavior before B-2, complete canonical-snapshot/direct-reference/deep-field non-mutation proof, inherited B-1a/A regressions, and absence of transitions/terminalization/public CAS helpers all pass.

**Rollback boundary**: revert only B-1b additions in `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, and the B-1b bookkeeping entries to the accepted B-1a baseline. P1a1, P1a2-i-A, and B-1a remain intact.

### P1a2-i-B-1b Forecast

| Component | Expected lines |
|---|---:|
| `model.ts` module-private CAS, lease, and unsupported dispatch | 35–45 |
| `model.test.ts` mismatch/lease/dispatch/non-mutation probes | 50–65 |
| B-1b bookkeeping | 20–20 |
| **Total P1a2-i-B-1b** | **105–130** |

Early warning is 120; STOP/reforecast is 170; absolute max is 200. No size:exception and no borrowing from B-1a/B-2/B-3. If this child cannot fit within 200 after an honest Git-native recount, stop and return `blocked` rather than exceeding its independent cap.

### P1a2-i-B-2 — Terminal Immutability + Monotonic State

**Objective**: install terminal-state rejection and the version/generation monotonicity invariant on top of B-1b. B-1a/B-1b deliberately leave terminal policy uninstalled; this child is the first point where the 11 non-`ack_dispatch` event types are rejected for each terminal status. The existing nonterminal acknowledgement path is the only i-B mutation used to prove version advancement. Terminal acknowledgement idempotency remains B-3.

**Depends on / branch**: P1a2-i-B-1b accepted; `slice/p1a2-i-b-2-terminal-monotonic` from `slice/p1a2-i-b-1b-cas-lease`; PR target the B-1b branch.

**Diff boundary**: only terminal immutability and monotonic enforcement/tests/bookkeeping; do not change B-1a/B-1b request, CAS, lease, or unsupported-dispatch behavior; do not add data-class mutation handling, terminal `ack_dispatch` idempotency, boundary transitions, or terminalization.

**Strict TDD order (RED → GREEN → REFACTOR)**

- [ ] P1a2-i-B-2.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 and the accepted B-1b baseline before mutation.
- [ ] P1a2-i-B-2.1 RED: author 33 independent terminal rejection vectors — each of the 11 state-transition event types (all event types except `ack_dispatch`) against `completed`, `failed`, and `manual_recovery`; every result must reject without changing the complete state.
- [ ] P1a2-i-B-2.2 GREEN: enforce terminal immutability inside `reduce()` after state/event validation and before any transition path; admit only the existing nonterminal `ack_dispatch` mutation needed for the version proof, without claiming terminal idempotency or data-class coverage yet.
- [ ] P1a2-i-B-2.3 RED: author independent monotonic vectors for the permitted nonterminal acknowledgement mutation and for rejected/unsupported events; assert version regression, skipped increments, and generation changes fail.
- [ ] P1a2-i-B-2.4 GREEN: require version to increase by exactly one on every successful mutation currently admitted by i-B, keep generation unchanged for every i-B event, and reject any version regression or generation change. Exact takeover `+1` remains P1a2-ii only.
- [ ] P1a2-i-B-2.5 REFACTOR: freeze B-2 behavior, rerun all 33 vectors, inherited B-1a/B-1b/A checks, explicit source+test TypeScript, source-only compatibility, and the model harness.

**Independent expected outcomes**: 33 terminal vectors reject with byte-identical states; the permitted nonterminal acknowledgement mutation increments version exactly once; rejected events do not change version; no i-B event changes generation; all expected states are independently authored, not derived from reducer output.

**Focused test command**: `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` — B-2 terminal matrix and monotonic assertions plus B-1a/B-1b/A regression coverage.

**Runtime harness**: the Node strip-types model harness runs the 33 terminal vectors and nonterminal version/generation fixtures against independent in-memory states; it does not emulate boundary delivery or terminalization.

**Acceptance gate**: 33/33 negative terminal vectors pass; version is exactly +1 for each successful B-2 mutation; generation never changes; `ack_dispatch` terminal idempotency and the five data classes remain explicitly pending B-3; no P1a2-ii/iii behavior exists.

**Rollback boundary**: revert only B-2 additions in `model.ts`, `model.test.ts`, and the B-2 bookkeeping entries to the accepted B-1b baseline. P1a2-i-B-1a, P1a2-i-B-1b, and P1a2-i-A remain intact.

### P1a2-i-B-3 — Data Immutability + `ack_dispatch` Idempotency

**Objective**: complete the parent invariant set by freezing five immutable data classes and finalizing guarded acknowledgement semantics. The five classes are (1) operation identity + normalized payload + intended UID, (2) audit identity, (3) dispatch identity, (4) provisioning provenance, and (5) confirmed Auth proof.

**Depends on / branch**: P1a2-i-B-2 accepted; `slice/p1a2-i-b-3-data-ack` from `slice/p1a2-i-b-2-terminal-monotonic`; PR target the B-2 branch.

**Diff boundary**: only the five data immutability checks, terminal/nonterminal `ack_dispatch` behavior, their tests, and bookkeeping; do not change B-1a/B-1b/B-2 request, CAS, lease, reducer-surface, terminal, or monotonic semantics.

**Strict TDD order (RED → GREEN → REFACTOR)**

- [ ] P1a2-i-B-3.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 and the accepted B-2 baseline before mutation.
- [ ] P1a2-i-B-3.1 RED: author independent mutation attempts for all five immutable data classes; each attempt must reject or preserve the original value. Add terminal `ack_dispatch` vectors for `completed`, `failed`, and `manual_recovery`, plus guarded nonterminal vectors for `pending` and `active`.
- [ ] P1a2-i-B-3.2 GREEN: enforce immutable identity/payload/UID, audit identity, dispatch identity, provenance, and confirmed-proof fields in `reduce()` without adding new event types or persistence behavior.
- [ ] P1a2-i-B-3.3 RED: add explicit idempotency assertions showing terminal acknowledgements are accepted without state mutation, while nonterminal acknowledgements require the full live CAS/current-dispatch guard and advance version once.
- [ ] P1a2-i-B-3.4 GREEN: make `ack_dispatch` idempotent for all three terminal statuses and guarded for both nonterminal statuses; stale or mismatched acknowledgement attempts fail without regression or immutable-data mutation.
- [ ] P1a2-i-B-3.5 REFACTOR: freeze the complete parent contract, rerun all 36 terminal vectors, five data classes, B-1a/B-1b CAS/lease/unsupported regressions, monotonic regressions, explicit source+test TypeScript, source-only compatibility, and the model harness.

**Independent expected outcomes**: every one of the five immutable classes rejects mutation; terminal `ack_dispatch` has 3/3 positive no-mutation outcomes; nonterminal `ack_dispatch` is guarded for `pending` and `active` and increments version once; stale acknowledgement cannot regress state; the 33 inherited terminal rejections remain green.

**Focused test command**: `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` — B-3 data and acknowledgement assertions plus the complete frozen B-1a/B-1b/B-2/A baseline.

**Runtime harness**: the Node strip-types model harness runs independent in-memory data snapshots and terminal/nonterminal acknowledgement scenarios; no Firebase/Auth/Firestore/Cloud Tasks runtime is claimed.

**Acceptance gate**: 36 terminal vectors pass (33 negative state-transition rejections + 3 positive terminal acknowledgements); both nonterminal acknowledgement expectations pass; all five immutable data classes are protected; CAS, monotonicity, and `reduce()`-only API remain intact; no boundary or terminalization implementation exists.

**Rollback boundary**: revert only B-3 additions in `model.ts`, `model.test.ts`, and the B-3 bookkeeping entries to the accepted B-2 baseline. B-1a, B-1b, B-2, P1a2-i-A, and P1a1 remain intact.

### P1a2-i-B Child Forecast and Order

| Order | Child | Expected | Early warning | STOP/reforecast | Absolute max | Feature-branch target |
|---:|---|---:|---:|---:|---:|---|
| 1 | P1a2-i-B-1a request contract + reducer surface | 105–135 | 120 | 170 | 200 | accepted P1a2-i-A-2 branch |
| 2 | P1a2-i-B-1b CAS + lease + unsupported dispatch | 105–130 | 120 | 170 | 200 | B-1a branch |
| 3 | P1a2-i-B-2 terminal immutability + monotonic state | 140–180 | 155 | 180 | 200 | B-1b branch |
| 4 | P1a2-i-B-3 data immutability + `ack_dispatch` idempotency | 145–195 | 160 | 180 | 200 | B-2 branch |
| **Parent P1a2-i-B** | **all four children** | **495–640 forecast; 600 binding cap** | **per child** | **per child** | **600 aggregate** | **no size:exception** |

Each child stops at its own absolute 200-line cap; the parent cannot borrow unused budget across children. The honest component forecast is 495–640, so the 600-line parent cap is binding in the high case and must not be hidden by averaging or borrowing. At each warning, pause and recount all paths; at each STOP, no further mutation occurs without measured evidence and explicit continuation. Component sums are verified: B-1a `model.ts 30–40 + model.test.ts 55–70 + bookkeeping 20–25 = 105–135`; B-1b `35–45 + 50–65 + 20–20 = 105–130`; B-2 `45–60 + 80–100 + 15–20 = 140–180`; B-3 `50–65 + 75–105 + 20–25 = 145–195`. The 800-line session review budget does not relax the 600-line parent maximum; if the measured aggregate cannot remain at or below 600, stop and replan with no size exception.

### Aggregate independent phase-contract gates

- [ ] B-1a: exact request/ExpectedCAS records, observedAt, failure precedence through `invalid_event`, unchanged nested event guards, old-call rejection, and canonical/direct non-mutation proof are accepted through `reduce()` without CAS equality/liveness or terminal policy.
- [ ] B-1b: all eight CAS fields, separate lease equality/liveness, exact-live unsupported behavior, exact-terminal unsupported behavior before B-2, and canonical/direct non-mutation proof are accepted through `reduce()` without implementing a boundary transition.
- [ ] B-2: 33 non-ack terminal rejection vectors, exact version monotonicity, and unchanged generation pass with independent expected states.
- [ ] B-3: five immutable data classes, 3/3 terminal acknowledgements, and both nonterminal acknowledgement expectations pass.
- [ ] Aggregate: 36 terminal vectors are present; only `reduce()` is public; P1a2-i-A is byte/foundation-frozen; P1a2-ii boundary transitions and P1a2-iii terminalization remain absent.

### P1a2-i Combined Forecast

| Sub-slice | Expected |
|---|---:|
| P1a2-i-A-1a | 200–270 |
| P1a2-i-A-1b | 200–270 |
| P1a2-i-A-1c | 200–270 |
| P1a2-i-A-1d | 200–270 |
| P1a2-i-A-2 | 120–170 |
| P1a2-i-B-1a | 105–135 |
| P1a2-i-B-1b | 105–130 |
| P1a2-i-B-2 | 140–180 |
| P1a2-i-B-3 | 145–195 |
| **Total P1a2-i** | **1,415–1,890** |

Combined absolute max remains 2,500 (1,600 + 300 + 600). No size:exception.

### Handoff contract to P1a2-ii

Frozen immutable vocabulary + frozen deep runtime immutability + frozen type guards + frozen B-1a request contract/reducer surface + frozen B-1b module-private CAS/lease fence and unsupported dispatch + frozen terminal immutability (11 state-transition types × 3 terminal = 33 negative rejection + `ack_dispatch` × 3 = 3 positive idempotency) + frozen monotonic state (version on every successful i-B mutation; no i-B event changes generation) + frozen five-class data immutability + frozen terminal/nonterminal dispatch acknowledgement. P1a2-i-B-3 is the handoff boundary; none of the four children implements or proves boundary transitions. **Exact acquisition (generation unchanged) and exact takeover (+1 monotonic generation) success/failure are proven solely in P1a2-ii.**

---

## P1a2-ii — Boundary Transitions + Auth Matrix + Crash Vectors + Completion + Dispatch Safety

**Objective**: implement all boundary transitions (acquisition without generation change, takeover with exact +1 monotonic generation fence), Auth create result matrix (all 5 design rows with mandatory UID/email dual-read and proof), crash-point vectors as REAL reducer transitions (not comments), completion as one atomic pure transition (profile + completed + success audit + current dispatch ack), and dispatch safety (next-dispatch creation, current-dispatch ack, orphan handling, idempotent enqueue semantics).

**Gaps addressed**: 5 (Auth confirmation from intent), 6 (crash vectors real), 7 (completion atomic), 9 (acquisition generation / takeover fence), 10 (dispatch safety).

**Spec traceability**: Requirement: Auth Ambiguity and Reconstruction; Requirement: Completion Atomic Commitment; Requirement: First-Slice Compensation Policy; Requirement: Operation Invariants.

**Design traceability**: Worker acquisition and intent; Auth create result matrix; Profile and completion; Boundary and crash protocol.

**Depends on**: P1a2-i-B-3 (the frozen four-child handoff: vocabulary + B-1a request surface + B-1b CAS/lease fence + reducer skeleton + terminal/state/data immutability).

**Base / branch**: `slice/p1a2-ii-boundary-transitions` branched from `slice/p1a2-i-b-3-data-ack`.

**Allowed paths** (exact):

- `functions/src/provisioning/model.ts` (extend — add acquisition, takeover, Auth preflight/intent/create/confirm/definite-no-effect/foreign, crash-point transitions, completion transition, dispatch safety transitions)
- `functions/test/provisioning/model.test.ts` (extend — add all boundary/Auth/crash/completion/dispatch tests with independent expected states)
- `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping)
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates)

**Forbidden in P1a2-ii**: all P1a2-i-A and P1a2-i-B-1a/B-1b/B-2/B-3 forbidden paths remain. Additionally: no terminalization implementations (those are P1a2-iii). No modification of P1a2-i-A frozen vocabulary/guards/immutability or the P1a2-i-B-1a/B-1b/B-2/B-3 frozen CAS/reducer/terminal-state invariants.

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
- Git-native count (Windows PowerShell): tracked — `git diff --numstat <P1a2-i-B-3-baseline> -- functions/src/provisioning/model.ts functions/test/provisioning/model.test.ts`; untracked — `git diff --no-index --numstat -- NUL "<path>"` (exit code 1 expected); sum additions + deletions across all changed paths since P1a2-i-B-3 commit.

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

Revert `functions/src/provisioning/model.ts` to P1a2-i-B-3 frozen state, revert `functions/test/provisioning/model.test.ts` to P1a2-i-B-3 frozen state, revert `tasks.md` and `apply-progress.md` to pre-P1a2-ii state. P1a1 + P1a2-i-A-1 (all 4 children) + P1a2-i-A-2 + P1a2-i-B-1a/B-1b/B-2/B-3 intact.

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

**Forbidden**: all prior forbidden paths remain. No modification of P1a2-i-A, P1a2-i-B-1a/B-1b/B-2/B-3, or P1a2-ii frozen behavior.

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

### P1a2 Aggregate (P1a2-i-B has 4 children; A-1 has 4 children)

| Sub-slice | Expected |
|---|---:|
| P1a2-i-A-1a | 200–270 |
| P1a2-i-A-1b | 200–270 |
| P1a2-i-A-1c | 200–270 |
| P1a2-i-A-1d | 200–270 |
| P1a2-i-A-2 | 120–170 |
| P1a2-i-B-1a | 105–135 |
| P1a2-i-B-1b | 105–130 |
| P1a2-i-B-2 | 140–180 |
| P1a2-i-B-3 | 145–195 |
| P1a2-ii | 850–1,100 |
| P1a2-iii | 630–830 |
| **Total P1a2** | **2,895–3,820** |

P1a2 aggregate hard maximum: **4,900** (1,600 + 300 + 600 + 1,200 + 1,200). The B parent remains capped at 600 even though the four-child forecast is 495–640; no size:exception exists for any P1a2 sub-slice.

### Handoff contract to P1b

Frozen pure types + frozen normalization/fingerprint + frozen deterministic IDs + frozen canonical vector fixtures + frozen immutable vocabulary + frozen deep runtime immutability + frozen type guards + frozen CAS fence + frozen reducer skeleton (only `reduce()` as public API) + frozen terminal immutability (11×3 negative vectors plus 3 terminal `ack_dispatch` idempotency vectors) + frozen monotonic state + frozen five-class data immutability + frozen boundary transitions + frozen Auth matrix + frozen crash vectors + frozen completion atomicity + frozen dispatch safety + frozen terminalization guards + frozen retry thresholds + frozen 5 negative probes. P1b builds the persistence port and implements the in-memory reference store and the Firestore emulator adapter; both MUST pass every frozen vector from P1a1+P1a2 identically.

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
- No restoration of stash `6425de640274d1990b824869b96535068ab450a5` (ordinal 34 evidence).
- No creation or modification of `functions/tsconfig.json` in any slice.

## Global Verification Contract (per slice)

Every slice MUST deliver:

- Focused test command and exact result.
- Runtime harness command/scenario and exact result, or explicit `N/A` with reason.
- Rollback boundary stated independently of commit creation.
- Native `sdd-attempt` begin/finish evidence with `next_action=begin` respected.

**Exception scope**:

- P1a1, P1b–P4: max 2,000 changed lines per slice; reforecast/stop at 1,700; absolute stop at 2,000. Maintainer-approved `size:exception`.
- P1a2-i-A-1a, P1a2-i-A-1b, P1a2-i-A-1c, P1a2-i-A-1d: early warning 300; STOP/reforecast 350; absolute max 400 each. Combined P1a2-i-A-1 max 1,600. **No size:exception.**
- P1a2-i-A-2: early warning 200; STOP/reforecast 250; absolute max 300. Combined P1a2-i-A absolute max 1,900. **No size:exception.**
- P1a2-i-B-1a/B-1b/B-2/B-3: early warning 120/120/155/160; STOP/reforecast 170/170/180/180; absolute max 200 each. Parent P1a2-i-B aggregate max 600; combined P1a2-i (A-1+A-2+B) max 2,500. **No size:exception.**
- P1a2-ii, P1a2-iii: early warning 1,100; STOP/reforecast 1,200; absolute max 1,200. **No size:exception** — if a contract-complete sub-slice cannot fit within 1,200, split it further.
- WU5–WU10: max 400 changed lines per work unit; stop at 400. **No inherited exception** — any overrun requires a new, separate maintainer decision.
