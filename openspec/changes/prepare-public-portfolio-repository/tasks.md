# Tasks: Prepare Public Portfolio Repository

Aggregate plan baseline: no pre-apply decision; child slices retain independent gates.
Aggregate chain recommendation: Yes
Aggregate chain strategy: feature-branch-chain
Aggregate 400-line risk: High
Aggregate delivery strategy: auto-chain (P1a2 child slices retain their own lower limits)
RDD routing: disabled — no automatic review activation. After cumulative backend emulator + TypeScript + independent phase-contract proof and candidate freeze at end of P3, surface explicit maintainer enable decision; no review before then.

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | Corrected P3.44a–P3.44e runtime-composition children: 835–1,185 cumulative direct changed lines across five independently capped slices |
| 400-line budget risk | High (each child remains below the hard 399-line cap) |
| Chained PRs recommended | Yes |
| Suggested split | P3.44a submission → P3.44b outbox → P3.44c worker routing/Auth → P3.44d status → P3.44e integrity/reset link |
| Delivery strategy | auto-chain |
| Chain strategy | feature-branch-chain |

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: High

This amended P3 plan uses five ordered feature-branch children; every child has an independent RED/GREEN boundary, a conservative additions-plus-deletions forecast below 399, and no borrowing or size exception.

## Next Bounded Unit Forecast — P3-B.2c Initial Pending Lease Acquisition

| Field | Value |
|---|---|
| Estimated changed lines | Reforecast pending; historical `289–370` omitted the accepted acquisition audit and is non-operative |
| 400-line budget risk | Pending CodeGraph-supported source-context reforecast; do not assert fit |
| Chained PRs recommended | Pending bounded planning; preserve the existing feature-branch chain |
| Suggested split | Parent planning must select a cohesive boundary only after the required reforecast |
| Delivery strategy | auto-chain |
| Chain strategy | feature-branch-chain |

Decision needed before apply: Reforecast required; no audit-semantic choice remains
Chained PRs recommended: Pending bounded reforecast
Chain strategy: feature-branch-chain
400-line budget risk: Pending reforecast
Parent independent gate before native acquire: Reforecast/doc gate only

## Current Planning Amendment — P1a2-i-B-3 Retired

P1a2-i-B-3 is retired/superseded as an executable work unit by maintainer authorization and the amended design. It was never implemented or accepted. The historical record below remains for audit clarity only; no unchecked B-3 task, branch, PR, or native-apply route remains. P1a2-i-C and P1a2-ii are independently accepted; ii preserves operation identity, normalized payload, intended UID, and confirmed Auth proof across real transitions. P2 retains schema/audit/dispatch foundations, while P3 owns full dispatch source-tuple and worker-ack behavior plus provisioning/profile provenance and terminal persistence/no-regression.

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated aggregate changed lines (tasks-phase validated) | **8,163–10,960** |
| Aggregate ceiling | **None** — no invented aggregate ceiling; per-slice max governs |
| 400-line budget risk | High |
| Delivery strategy | auto-chain (P1a2 child slices retain their own lower limits) |
| Chain strategy | feature-branch-chain |
| Decision needed before apply | No (auto-chain is already selected; each child still requires its independent acceptance gate) |
| Slice count | 15 chained implementation slices; P1a2-i-B is three ordered executable children, P1a2-i-C is independently accepted, and retired B-3 is historical only |
| Per-slice reforecast/STOP (P1a1 + P1b–P4 only) | 1,700 |
| Per-slice absolute max (P1a1 + P1b–P4 only) | 2,000 |
| P1a2-i-A absolute max | 1,900 (no size:exception) |
| P1a2-i-B aggregate absolute max | 600 across B-1a/B-1b/B-2 (no size:exception; retired B-3 is not executable) |
| P1a2-i-C absolute max | 400 (no size:exception; independent guard refinement) |
| P1a2-ii absolute max | 1,200 (no size:exception; independently accepted pure reducer) |
| P1a2-iii executable budget | **None — retired/superseded; historical only** |
| Later independent chain | WU5–WU10 preserved (signing → de-branding → sanitization → README → archive → gates); each max 400, stop at 400; no inherited exception |

### Phase-Authority Decision

The previous `Decision needed before apply` workload/size question is resolved for P1a1 + P1b-P4: maintainer has explicitly approved `size:exception` up to 2,000 lines per slice for P1a1 and P1b-P4 only. **Executable P1a2 sub-slices (i-A-1a, i-A-1b, i-A-1c, i-A-1d, i-A-2, i-B-1a, i-B-1b, i-B-2, i-C, ii) do NOT have size:exception; retired P1a2-iii has no executable budget.** Each P1a2-i-A-1 child has max 400; combined P1a2-i-A-1 max 1,600; P1a2-i-A-2 max 300; combined P1a2-i-A max 1,900; P1a2-i-B-1a/B-1b/B-2 each max 200 with a 600 aggregate; P1a2-i-C max 400 with warning 300 and STOP 350; combined P1a2-i max 2,900; P1a2-ii max 1,200 and is independently accepted after C acceptance. WU5-WU10 retain ordinary max 400 per work unit; any future overrun in those work units requires a separate maintainer decision. Separately, **interactive phase approval + validated planning baseline** are still required before P1a1 may begin - that gate is about phase sequencing, not about size/chaining, and does not contradict the resolved workload decision.

### Supersession Notice

This revision **supersedes** the prior P1a plan. The single `P1a - Pure Contract + Model + Invariant Vectors` is replaced by two strictly separated slices: `P1a1 - Types + Normalization + IDs` and P1a2 (reducer + invariants). The prior P1a was invalidated by failed ordinal 22 (see below). P1a2 was historically decomposed into `P1a2-i-A-1`, `P1a2-i-A-2`, `P1a2-i-B`, `P1a2-i-C`, `P1a2-ii`, and `P1a2-iii`; the current plan retains the executable portions through B-2 and the independently accepted C/ii eight-event pure matrix. P1a2-iii is retired/superseded and its runtime concerns are owned by P3. The prior single P1a2 was invalidated by failed ordinals 27-28 (13 deterministic contract gaps, 2,178 lines). P1a2-i was further split into P1a2-i-A and P1a2-i-B after failed ordinal 29 (8 deterministic contract failures, 969 lines). P1a2-i-A was further split into P1a2-i-A-1 and P1a2-i-A-2 after failed ordinal 30 (8 deterministic contract failures, 529 lines). P1a2-i-A-1 was further split into P1a2-i-A-1a (Immutable Vocabulary + Genuine Type Proof), P1a2-i-A-1b (Descriptor-Safe Cycle-Safe Deep Freeze), P1a2-i-A-1c (Strict State Guard), P1a2-i-A-1d (Strict Event Guard) after failed ordinal 34 (6 deterministic blockers: Set mutability, _Eq/Extract type-proof weakness, getter-invoking deepFreeze, guard laxity on null/NaN/class/polluted roots, missing adversarial probes, over-budget compaction; 566 lines, stash `6425de640274d1990b824869b96535068ab450a5`). All downstream slices (P1b-P4) and later work units (WU5-WU10) are preserved architecturally; only their dependency edges shift where required by the P1a decomposition.

**Earlier surgical amendment (historical)**: the unstarted P1a2-i-B monolith was previously decomposed into B-1a, B-1b, B-2, and B-3. The amended design now supersedes B-3 as an executable slice; B-3 was never implemented or accepted. P1a2-i-A-2 acceptance is preserved; no completed history or unrelated task is reopened.

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
5. **Fifth refinement (historical, 8,075–10,595)**: P1a2 was temporarily decomposed into P1a2-i (vocabulary + CAS fence + terminal rejection/non-mutation + state/data immutability + type guards), P1a2-ii (boundary transitions + Auth matrix + crash vectors + completion + dispatch safety), and P1a2-iii (terminalization guards + retry thresholds + negative probes), driven by failed ordinals 27–28 (2,178/2,182 lines, stash `213ff2fdf123bfa9c7b3b0ea0f83026a3b1f0306`, 13 deterministic contract gaps). The later maintainer correction retired P1a2-iii and narrowed executable P1a2-ii; no historical iii forecast or checklist remains active.
6. **Sixth refinement (8,145–10,785)**: P1a2-i further decomposed into P1a2-i-A (immutable vocabulary + runtime guards + TypeScript compatibility — no transitions) and P1a2-i-B (CAS fence + reducer skeleton + terminal/state/data immutability — only `reduce()` as public API), driven by failed ordinal 29 (969/1,200 lines, stash `527d4dfb2fd0bd30eacd7b09116bec3bda79250d`, 8 deterministic contract failures). Each sub-slice targets <=600 with combined max 1,200 and no size:exception.
7. **Seventh refinement (8,115–10,735)**: P1a2-i-A further decomposed into P1a2-i-A-1 (immutable vocabulary + deep freeze + strict guards — foundation consuming canonical P1a1 via `import type` only, no constructors, `Reflect.ownKeys`-based deep freeze) and P1a2-i-A-2 (validated constructors + TypeScript compatibility), driven by failed ordinal 30 (529/600 lines, stash `012c41516831e1579cd7162c378c123f503ee633`, 8 deterministic contract failures). P1a2-i-A-1 max 400 (STOP 350, expected 260–330), P1a2-i-A-2 max 300 (STOP 250, expected 120–170), combined P1a2-i-A max 600. No size:exception.
8. **Eighth refinement (8,655–11,485)**: P1a2-i-A-1 further decomposed into four contract-complete child slices — P1a2-i-A-1a (Immutable Vocabulary + Genuine Type Proof, ~200–270), P1a2-i-A-1b (Descriptor-Safe Cycle-Safe Deep Freeze, ~200–270), P1a2-i-A-1c (Strict State Guard, ~200–270), P1a2-i-A-1d (Strict Event Guard, ~200–270) — driven by failed ordinal 34 (566 lines, stash `6425de640274d1990b824869b96535068ab450a5`, 6 deterministic blockers: Set mutability, _Eq/Extract type-proof weakness, getter-invoking deepFreeze, guard laxity on null/NaN/class/polluted roots, missing adversarial probes, over-budget compaction). Each child max 400 (STOP 350), combined P1a2-i-A-1 max 1,600. Corrective pass reconciled canonical arithmetic across all tables. No size:exception.
9. **Prior B-1 refinement (historical pre-retirement)**: fresh planning validation rejected the monolithic B-1 forecast of 215–260 lines against its STOP 190/absolute max 200 and found that targeting the tracker would pollute the child diff. The maintainer approved two ordered children: B-1a (Request Contract + Reducer Surface, 105–135) targets accepted P1a2-i-A-2; B-1b (CAS + Lease + Unsupported Dispatch, 105–130) targets B-1a. B-2 ownership and the parent 600-line maximum remain unchanged; B-3 is now retired by the amended design and is not an executable child. B-2's corrected terminal rejection/non-mutation forecast is 68–110. No implementation or acceptance is carried forward by this planning correction.

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
| P1a2-i-B-2 | Terminal rejection + non-mutation | 68–110 |
| P1a2-i-C | AuthAttempt lifecycle guard refinement + B-2 fixture reconstruction | 220–340 |
| P1a2-ii | Pure OperationState transitions for exactly eight existing events after accepted C + independently authored lifecycle/correlation vectors | 680–940 |
| P1a2-iii | Retired/superseded historical plan; no executable forecast | **0** |
| P1b | Persistence port + in-memory reference + Firestore emulator conformance + CAS primitives (narrowed) | 1,185–1,555 |
| P2 | Schemas + audit primitives + submission + reliable dispatch (former P1 schemas/audit + S4–S6) | 1,030–1,385 |
| P3 | Profile provenance + worker + status + full backend proof (former P1 profile + S7–S10, including transferred runtime concerns) | 1,550–1,965 |
| P4 | Flutter migration + Firestore rules hardening/proof + dependency/bootstrap | 900–1,500 |
| **Total P1a1–P4** | | **8,163–10,960** |

### Recomputed direct and transitive review totals

| Roll-up | Direct forecast | Transitive forecast from prerequisites |
|---|---:|---:|
| P1a2-i | 1,418–1,965 | 1,418–1,965 |
| P1a2-ii | 680–940 | **2,098–2,905** (P1a2-i + ii) |
| P1b | 1,185–1,555 | **4,683–6,110** (P1a1 + P1a2 + P1b) |
| P2 | 1,030–1,385 | **5,713–7,495** (P1 + P2) |
| P3 | 1,550–1,965 | **7,263–9,460** (P1 + P2 + P3) |
| P4 | 900–1,500 | **8,163–10,960** (P1 + P2 + P3 + P4) |

Arithmetic: P1a2-i low/high = `1,198+220 = 1,418` / `1,625+340 = 1,965`; P1a2 low/high = `1,418+680 = 2,098` / `1,965+940 = 2,905`; P1 low/high = `1,400+2,098+1,185 = 4,683` / `1,650+2,905+1,555 = 6,110`; overall low/high = `4,683+1,030+1,550+900 = 8,163` / `6,110+1,385+1,965+1,500 = 10,960`. Retired P1a2-iii contributes zero direct or transitive executable lines.

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
| P1a2-i-C | 300 | 350 | 400 | **No** |
| P1a2-i-B aggregate | — | — | 600 parent cap (three executable children; no borrowing; B-3 retired) | **No** |
| P1a2-i combined | — | — | 2,900 | **No** |
| P1a2-ii | 1,100 | 1,200 | 1,200 | **No** |
| P1a2-iii | — | — | **None — retired** | **No executable work** |
| P1b | 1,500 | 1,700 | 2,000 | Accepted |
| P2 | 1,500 | 1,700 | 2,000 | Accepted |
| P3 | 1,500 | 1,700 | 2,000 | Accepted |
| P4 | 1,500 | 1,700 | 2,000 | Accepted |

WU5–WU10 do **not** inherit these boundaries. Each later work unit has max 400, stop at 400; any future overrun requires a separate maintainer decision.

### Line-Accounting Rules

- Per-slice expected range is the working budget for P1a1–P4.
- **P1a2-i-A-1a, P1a2-i-A-1b, P1a2-i-A-1c, P1a2-i-A-1d, P1a2-i-A-2, P1a2-i-B-1a, P1a2-i-B-1b, P1a2-i-B-2, P1a2-i-C, and P1a2-ii do NOT inherit the P1a1/P1b–P4 size:exception.** Each P1a2-i-A-1 child has early warning 300, STOP at 350, absolute max 400; combined P1a2-i-A-1 max 1,600 (4 × 400). P1a2-i-A-2 has early warning 200, STOP at 250, absolute max 300. Combined P1a2-i-A max 1,900 (1,600 + 300). P1a2-i-B-1a/B-1b each have early warning 120 and STOP at 170, absolute max 200; B-2 has early warning 155 and STOP at 180, absolute max 200; the executable B parent aggregate is capped at 600 across those three children and is not the sum of borrowable child budgets. P1a2-i-C has early warning 300, STOP at 350, absolute max 400. P1a2-ii has early warning 1,100, STOP at 1,200, absolute max 1,200 and is independently accepted after C acceptance. P1a2-iii has no budget or executable route. If a coherent contract-complete slice cannot fit within its max, split it further — do NOT use size:exception.
- **Recount after every RED/GREEN pair**: measure all-path changed lines via Git-native counting only. **Tracked files**: `git diff --numstat <slice-baseline> -- <tracked paths>` (sum additions + deletions; no net accounting). **Untracked files (Windows PowerShell)**: `git diff --no-index --numstat -- NUL "<path>"` — exit code 1 is expected when differences exist; parse the numstat output for additions + deletions. **POSIX alternative**: `git diff --no-index --numstat -- /dev/null "<path>"`. Never use `Measure-Object -Line`.
- **Early warning**: P1a1/P1b–P4 at 1,500; each P1a2-i-A-1 child at 300; P1a2-i-A-2 at 200; P1a2-i-B-1a/1b at 120, B-2 at 155, C at 300, and P1a2-ii at 1,100 — pause, assess remaining work, document. Retired P1a2-iii has no checkpoint.
- **STOP/reforecast**: P1a1/P1b–P4 at 1,700; each P1a2-i-A-1 child at 350; P1a2-i-A-2 at 250; P1a2-i-B-1a/1b at 170, B-2 at 180, C at 350, and P1a2-ii at 1,200 — no further mutation without measured evidence and explicit continuation. Retired P1a2-iii has no STOP.
- **Absolute STOP**: P1a1/P1b–P4 before 2,000; each P1a2-i-A-1 child before 400 (STOP/reforecast at 350); combined P1a2-i-A-1 before 1,600; P1a2-i-A-2 before 300 (STOP/reforecast at 250); combined P1a2-i-A before 1,900; each executable P1a2-i-B-1a/B-1b/B-2 child before 200, with B-1a/B-1b STOP/reforecast at 170 and B-2 at 180, and the parent aggregate before 600; P1a2-i-C before 400 (STOP/reforecast at 350); combined P1a2-i before 2,900; P1a2-ii before 1,200 (STOP/reforecast at 1,200; hard max, no exception). Retired P1a2-iii has no absolute limit because it has no executable work.
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
                                                          └── 📍 P1a2-i-C branch (base: P1a2-i-B-2)
                                                               └── P1a2-ii branch (base: P1a2-i-C)
                                                                    └── P1b branch (base: P1a2-ii)
                                                                                └── P2 branch (base: P1b)
                                                                                      └── P3 branch (base: P2)
                                                                                            └── P4 branch (base: P3)

Independent later chain (after P4 merges into tracker, tracker merges into main):
main ──→ WU5 (signing) ──→ WU6 (de-branding) ──→ WU7 (sanitization) ──→ WU8 (README) ──→ WU9 (archive) ──→ WU10 (gates)
```

Each child PR targets its immediate previous slice branch. The tracker target remains the integration boundary for P1a1; the current B chain starts from the accepted P1a2-i-A-2 branch: B-1a targets A-2 (not the tracker), B-1b targets B-1a, B-2 targets B-1b, C targets B-2, P1a2-ii targets C only after C acceptance, and P1b targets P1a2-ii directly. Retired B-3 has no branch or PR target. Only the tracker ultimately targets `main`. The current first-slice boundary is `📍 P1a2-i-C`; each child diff contains only its own model/test/bookkeeping work unit. No branch, commit, or PR is created in this planning phase.

### Commit / Work-Unit Mapping and Rollback Order

| Order | Slice | Commit message (conventional) | PR target | Rollback order |
|---|---|---|---|---|
| 1 | P1a1 | `feat(provisioning): add canonical types, normalization, IDs, fixtures` | feature/tracker | 15 (last to revert) |
| 2 | P1a2-i-A-1a | `feat(provisioning): add immutable vocabulary and genuine type proof` | P1a1 branch | 14 |
| 3 | P1a2-i-A-1b | `feat(provisioning): add descriptor-safe cycle-safe deep freeze` | P1a2-i-A-1a branch | 13 |
| 4 | P1a2-i-A-1c | `feat(provisioning): add strict state guard` | P1a2-i-A-1b branch | 12 |
| 5 | P1a2-i-A-1d | `feat(provisioning): add strict event guard` | P1a2-i-A-1c branch | 11 |
| 6 | P1a2-i-A-2 | `feat(provisioning): add validated constructors, TypeScript compatibility` | P1a2-i-A-1d branch | 10 |
| 7 | P1a2-i-B-1a | `feat(provisioning): add reducer request contract and validation surface` | P1a2-i-A-2 branch | 9 |
| 8 | P1a2-i-B-1b | `feat(provisioning): add CAS lease fence and unsupported dispatch` | P1a2-i-B-1a branch | 8 |
| 9 | P1a2-i-B-2 | `feat(provisioning): add terminal rejection and non-mutation` | P1a2-i-B-1b branch | 7 |
| 10 | P1a2-i-C | `fix(provisioning): tighten AuthAttempt lifecycle guard` | P1a2-i-B-2 branch | 6 |
| 11 | P1a2-ii | `feat(provisioning): add pure OperationState transitions and invariants` | P1a2-i-C branch | 5 |
| 12 | P1b | `feat(provisioning): add persistence port, memory/Firestore stores, CAS primitives` | P1a2-ii branch | 4 |
| 13 | P2 | `feat(provisioning): add schemas, audit, submission, dispatch, outbox, metadata` | P1b branch | 3 |
| 14 | P3 | `feat(provisioning): add profile, worker, status, full backend proof` | P2 branch | 2 |
| 15 | P4 | `feat(client): migrate provisioning to trusted backend; harden Firestore rules` | P3 branch | 1 (first to revert) |

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

Frozen pure types + frozen normalization/fingerprint + frozen deterministic IDs + frozen canonical vector fixtures. P1a2-i builds the pure reducer vocabulary, CAS fence, terminal rejection/non-mutation, state/data immutability, and type guards consuming this frozen P1a1 contract.

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

## P1a2 — Reducer + Invariant Vectors (i-A, i-B, ii; iii retired — A-1 has 4 children)

The prior single P1a2 block is replaced by four executable sub-slices; P1a2-i-A-1 is further divided into four independently reviewable child slices. This decomposition addresses 13 deterministic contract gaps found in failed ordinals 27–28 (stash `213ff2fdf123bfa9c7b3b0ea0f83026a3b1f0306`, evidence only — never restore) and 8 deterministic contract failures found in failed ordinal 29 (stash `527d4dfb2fd0bd30eacd7b09116bec3bda79250d`, evidence only — never restore). P1a2-i-C is the independently accepted lifecycle-guard child after accepted B-2; P1a2-iii is a historical-only retired plan; P3 owns its former persistence/runtime concerns. Each executable slice has its own RED→GREEN cycle and no P1a2 child has a size:exception.

### Failed Ordinals 27–28 — Evidence (do NOT restore)

- **Ordinal 27**: Git-native 2,178 lines, violating 1,700 STOP and 2,000 max; executor underreported 1,979.
- **Ordinal 28**: Used maintainer-approved size:exception max 2,300 and mechanically revalidated 2,182 lines, but fresh independent validation failed every contract group despite 76 green tests. 13 deterministic contract gaps identified.
- **Stash**: `213ff2fdf123bfa9c7b3b0ea0f83026a3b1f0306`. Preserved as evidence only. **Never restore, copy, or cherry-pick.**
- **Deterministic contract gaps** (all MUST be prevented by the sub-slices below):

| # | Gap | Prevented by |
|---|---|---|
| 1 | `validateCAS` detached from reducer mutations; transitions checked partial fields, not full tuple | P1a2-i-B |
| 2 | Pending terminalization omitted fingerprint, dispatch source tuple, worker acknowledgement | P3 |
| 3 | Active terminalization lacked classifier; allowed expired/foreign/stale workers; wrong failed vs manual_recovery | P3 |
| 4 | Retry thresholds event-optional, off-by-one/unbounded; did not gate every normal-work event | P3 |
| 5 | Auth confirmation could proceed directly from intent; UID/email/dual-read absent; definite-no-effect lacked two-index evidence | P1a2-ii |
| 6 | Crash vectors were comments, not real reducer transitions | P3 |
| 7 | Completion did not model profile+completion+audit+ack as one pure transition | P1a2-ii candidate, P2, P3 |
| 8 | Payload/audit/dispatch/provenance/persisted-UID immutability missing | P1a2-i-B |
| 9 | Acquisition changed generation; takeover accepted arbitrary regression/jumps | P1a2-ii |
| 10 | Dispatch safety omitted next-dispatch/current-dispatch ack, orphan handling, idempotent enqueue | P1a2-ii guards, P2, P3 |
| 11 | Terminal immutability covered only 6 of 12 event types | P1a2-i-B |
| 12 | Public helpers/classifiers and malformed states/events could bypass type guards | P1a2-i-A |
| 13 | Bookkeeping understated candidate size | P1a2-i-A/i-B/ii/P3 (honest forecasts) |

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
| 6 | Terminal rejection semantics conflicted with downstream terminal-idempotent success | P1a2-i-B-2 plus later persistence/transition owners (B-2 blocks 11 state-transition events; later owners implement legal acknowledgement persistence) |
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
| 2 — Pending terminalization incomplete | P3 | P3.21–P3.24 (full pending predicate and mismatch reclassification) | Exhaustively mutate fingerprint, dispatch source, worker ack; every mismatch blocks terminalization |
| 3 — Active terminalization classifier | P3 | P3.25–P3.32 (exact-owner, foreign-owner, expired takeover, terminal idempotency) | Exact-owner-live, foreign-owner-unexpired, expired-takeover, terminal-idempotent; correct outcome per path |
| 4 — Retry thresholds | P3 | P3.33–P3.36 and P3.49–P3.50 (0–7 work, 8–11 terminalize-only, malformed fail-closed) | retryCount 0–7 allowed; 8–11 terminalize only; negative/non-integer/>11 fail-closed; exact boundary at 7/8 and 11/12 |
| 5 - Auth confirmation from intent | P1a2-i-C, P1a2-ii, P3 | C lifecycle guard plus P1a2-ii.10-ii.11 (`CONF-LIFE`, `CONF-ID`, `CONF-UID`, `CONF-EMAIL`, `CONF-PROOF`); P3 Auth read/reconstruction tasks | Intent alone cannot confirm; C rejects incoherent state, the pure reducer requires existing call-started/proof correlations, while P3 proves UID/email reads and definite-no-effect absence classification |
| 6 — Crash vectors as comments | P3 | P3.15–P3.16 and P3.53–P3.54 (real crash/reconstruction tests) | Each external-effect crash point and dual read is exercised in the worker/runtime boundary; no crash event is invented in the reducer |
| 7 — Completion not atomic | P1a2-ii candidate, P2, P3 | P1a2-ii completion candidate; P3.13–P3.16 and P3.41–P3.46 persistence proofs | P1a2-ii proves only the pure completed OperationState candidate; P2/P3 prove persisted profile + completion + audit + acknowledgement atomicity |
| 8 — Immutability missing | P1a2-ii, P2, P3 | P1a2-ii real-transition proof; P2 schema/dispatch/audit proof; P3 provenance/terminal persistence proof | Operation identity/normalized payload/intended UID and confirmed Auth proof stay immutable across pure transitions; P2 protects schema/dispatch/audit identity; P3 protects profile provenance and terminal no-regression persistence |
| 9 — Acquisition generation | P1a2-ii | P1a2-ii.2–ii.5 (`ACQ-PRED`, `TK-GEN`) | Acquire with generation!=0 rejected; takeover output probes prove exact prior `+1` and reject regression/jump behavior without inventing a payload generation field |
| 10 — Dispatch safety | P1a2-ii guards, P2, P3 | P1a2-ii representable guards; P2 schema/enqueue foundations; P3 worker delivery proof | P1a2-ii guards only existing `currentDispatchId`/`event.payload.dispatchId` relationships; P2 retains schema/audit/enqueue foundations; P3 proves full source tuple, orphan/dedup delivery, worker acknowledgement, and no regression |
| 11 — Terminal immutability 6/12 | P1a2-i-B-2; P1a2-ii/P2/P3 persistence boundaries | P1a2-i-B-2.1–2.6 (33 negative rejection vectors plus precedence/ack characterization controls); later transition/persistence proofs cover legal acknowledgements | `acquire,takeover,auth_intent,auth_start,auth_confirm,auth_no_effect,auth_ambiguous,auth_foreign_user,auth_preflight,profile_commit,terminalize` × `completed,failed,manual_recovery` = 33 `terminal_state` rejections; exact terminal `ack_dispatch` remains `unsupported_event` in accepted B-2 until later owners implement its persistence semantics |
| 12 - Type guards bypass | P1a2-i-A-1a + P1a2-i-A-1b + P1a2-i-A-1c + P1a2-i-A-1d + P1a2-i-A-2 + P1a2-i-C | P1a2-i-A-1c (strict state guard), P1a2-i-A-1d (strict event guard), P1a2-i-A-2.3-5 (constructor input validation), and C lifecycle-correlation guard | Malformed state/event rejected at type level and runtime with exact-field-set validation; C rejects lifecycle-incoherent AuthAttempt states as `invalid_state`; deep freeze prevents mutation; constructors reject invalid state/extra fields/malformed values |
| 13 - Bookkeeping understated | P1a2-i-A-1/A-2/i-B-1a/i-B-1b/B-2/C/ii/P3 | Each executable sub-slice has component-sum-verified forecast; retired B-3 and P1a2-iii are excluded | Each executable slice recounts after every RED/GREEN pair |

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

## P1a2-i-B — CAS, Reducer, and Terminal Non-Mutation (three ordered children)

**Surgical replan**: P1a2-i-A-2 is independently accepted and frozen; B-1a, B-1b, and B-2 are formally accepted. This section retains those accepted executable children and retires the unstarted B-3 plan. Completed history, the P1a2-i-A foundation, and unrelated tasks remain unchanged. The current edit does not modify `apply-progress.md`.

**Parent contract**: the three executable children remain pure-model work. B-1a establishes the request contract and reducer surface; B-1b adds the module-private CAS/lease fence and unsupported dispatch; B-2 installs terminal rejection/non-mutation. They consume the frozen P1a2-i-A vocabulary, guards, deep freeze, and constructors; expose only `reduce(state, request)` as the public transition API; implement no boundary transitions from P1a2-ii and no runtime terminalization (the former P1a2-iii plan is retired). B-2 has no successful mutation or positive version-monotonicity proof; P1a2-ii owns positive version monotonicity on its real operation mutations and the transferred operation/proof immutability. P2 retains schema/audit/dispatch foundations; P3 owns full dispatch source-tuple and worker-ack behavior, provisioning/profile provenance, and terminal persistence/no-regression. The 800-line session review budget is not a size exception: the executable parent aggregate remains capped at 600 changed lines with no exception.

**Terminal-policy boundary**: B-1a and B-1b do not install terminal policy. Until B-2 is accepted, even an exact terminal tuple may pass request/CAS checks and reach the non-mutating `unsupported_event` outcome. B-2 inserts policy after event validation and before CAS equality/lease liveness: `completed`, `failed`, and `manual_recovery` reject the 11 non-`ack_dispatch` event types with literal `terminal_state`; `ack_dispatch` is excluded and exact terminal acknowledgements remain `unsupported_event` until later persistence/transition owners implement legal acknowledgement semantics. No child in this parent implements a boundary transition or terminalization.

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

**Diff boundary**: request types, descriptor-safe request/ExpectedCAS validation, reducer-surface tests, and B-1a bookkeeping only. Existing `isValidState` behavior is preserved; B-1a tests MUST NOT claim new accessor/proxy fail-closed state validation. Do not carry B-1b CAS/lease/dispatch or B-2 behavior into this child.

**Strict TDD order (RED → GREEN → REFACTOR)**

- [x] P1a2-i-B-1a.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 against the accepted A-2 baseline before focused tests and type checks.
- [x] P1a2-i-B-1a.1 RED: author black-box request/ExpectedCAS tests before reducer source. Missing/extra/symbol/accessor/class/polluted-prototype/proxy-trap/malformed envelopes fail closed as `invalid_request`/`invalid_expected`; getter counters, canonical snapshots, direct references, and deep-field checks prove no getter execution, input mutation, or request mutation (JSON is supplementary only).
- [x] P1a2-i-B-1a.2 RED: author `observedAt` vectors for fractional, negative, non-finite, and malformed values, plus independent failure-precedence vectors through `invalid_event`; retain nested missing/extra strict event-payload probes without adding CAS fields to the event.
- [x] P1a2-i-B-1a.3 RED: add explicit TypeScript probes proving the new request signature compiles while old `reduce(state,event)` calls and missing/extra ExpectedCAS fields fail with `@ts-expect-error`; assert the readonly request carrier is not mutated or retained.
- [x] P1a2-i-B-1a.4 GREEN: define `ExpectedCAS`/`ReducerRequest` and descriptor-read exact-record validators; validate `observedAt`; keep the accepted `isValidState` and `isValidEvent` behavior unchanged.
- [x] P1a2-i-B-1a.5 GREEN: wire `reduce()` through `state → request → expected → event` validation and literal `invalid_state`/`invalid_request`/`invalid_expected`/`invalid_event` outcomes only. Do not compare CAS fields, evaluate lease liveness, or claim `unsupported_event` here.
- [x] P1a2-i-B-1a.6 REFACTOR: freeze B-1a, rerun the inherited A checks, explicit source+test TypeScript plus old-call probes, source-only `npx tsc --noEmit`, and the model harness.

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

Early warning is 120; STOP/reforecast is 170; absolute max is 200. No size:exception and no borrowing from B-1b/B-2. If this child cannot fit within 200 after an honest Git-native recount, stop and return `blocked` rather than exceeding its independent cap.

### P1a2-i-B-1b — CAS + Lease + Unsupported Dispatch

**Objective**: add the module-private eight-field equality predicate and authoritative lease liveness using `observedAt` on top of the accepted B-1a request surface. Prove eight independent mismatch vectors, keep lease equality separate from active lease liveness, and route an exact-live expected tuple to non-mutating `unsupported_event`. No boundary transition, terminalization, or public CAS helper is implemented.

**Depends on / branch**: accepted P1a2-i-B-1a; `slice/p1a2-i-b-1b-cas-lease` branched from `slice/p1a2-i-b-1a-request-reducer`; PR target is the B-1a branch.

**Diff boundary**: module-private CAS equality/liveness, unsupported dispatch, their tests, and B-1b bookkeeping only. Do not change B-1a request validation or add B-2 behavior.

**Strict TDD order (RED → GREEN → REFACTOR)**

- [x] P1a2-i-B-1b.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 and the accepted B-1a baseline before mutation.
- [x] P1a2-i-B-1b.1 RED: author independent `reduce()` vectors that alter each of `fingerprint,status,phase,generation,version,ownerToken,currentDispatchId,leaseExpiresAt` separately and expect literal `cas_mismatch`; canonical snapshots plus direct reference/deep-field checks prove the complete state/request/event inputs remain unchanged.
- [x] P1a2-i-B-1b.2 RED: author lease vectors showing equality is checked separately from liveness: equal-but-expired and active-null leases return literal `lease_not_live` using caller `observedAt`, while non-active/null-lease cases do not claim active lease liveness.
- [x] P1a2-i-B-1b.3 RED: author exact-live dispatch vectors for boundary and terminalization events and assert literal `unsupported_event` with no mutation; direct reference/deep-field checks cover state, request, and event inputs. Exact terminal tuples may reach this outcome because B-1a/B-1b do not install terminal policy. Keep all transition behavior absent.
- [x] P1a2-i-B-1b.4 GREEN: implement the module-private eight-field equality predicate, separate `observedAt` lease predicate, and non-mutating unsupported dispatch behind the validated B-1a request surface; never derive expectations, read a clock, retain a request, or mutate inputs.
- [x] P1a2-i-B-1b.5 REFACTOR: freeze B-1b, rerun B-1a/A request, event, state, and TypeScript regressions, source-only `npx tsc --noEmit`, and the focused model harness.

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

Early warning is 120; STOP/reforecast is 170; absolute max is 200. No size:exception and no borrowing from B-1a/B-2. If this child cannot fit within 200 after an honest Git-native recount, stop and return `blocked` rather than exceeding its independent cap.

### P1a2-i-B-2 — Terminal Rejection + Non-Mutation

**Objective**: install only terminal-state rejection on top of B-1b and prove that every B-2 outcome is non-mutating. The three terminal statuses are exactly `completed`, `failed`, and `manual_recovery`; the 11 rejected event types are exactly `acquire`, `takeover`, `auth_intent`, `auth_start`, `auth_confirm`, `auth_no_effect`, `auth_ambiguous`, `auth_foreign_user`, `auth_preflight`, `profile_commit`, and `terminalize`. After accepted state/request/ExpectedCAS/event validation, B-2 inserts terminal policy before CAS equality and lease liveness: a terminal status plus any listed event returns the existing `TransitionResult` failure with literal `reason: "terminal_state"`. `ack_dispatch` is excluded; exact terminal acknowledgements remain `unsupported_event` until later persistence/transition owners implement acknowledgement semantics. B-2 adds no successful mutation, acknowledgement semantics, version increment, generation change, or positive monotonicity proof; P1a2-ii proves positive version monotonicity on its real successful operation mutations.

**Depends on / branch**: P1a2-i-B-1b accepted; `slice/p1a2-i-b-2-terminal-monotonic` from `slice/p1a2-i-b-1b-cas-lease`; PR target the B-1b branch.

**Diff boundary**: only the terminal rejection policy, its 33 genuine RED vectors, three inherited mixed-input characterization/regression controls, three genuine stale-CAS controls, three inherited exact-terminal-ack characterization/regression controls, non-mutation assertions, and B-2 bookkeeping; do not change B-1a/B-1b request, CAS, lease, or unsupported-dispatch behavior. Do not add any successful mutation, acknowledgement semantics, version increment, generation change, data-class mutation handling, boundary transitions, or terminalization.

**Strict TDD order (RED → GREEN → REFACTOR)**

- [x] P1a2-i-B-2.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 and the accepted B-1b baseline before mutation.
- [x] P1a2-i-B-2.1 RED: author 33 independent terminal rejection vectors for the explicitly listed 11 event types × `completed|failed|manual_recovery`; each must return failure reason `terminal_state`, preserve the complete state, and leave version and generation unchanged. Capture canonical snapshots plus direct-reference/deep-field checks for state, request, and event.
- [x] P1a2-i-B-2.2 BASELINE CHARACTERIZATION/REGRESSION (may be green before B-2 production changes): retain three distinct terminal-state mixed-input controls inherited from accepted B-1a/B-1b — terminal state + malformed request returns `invalid_request`; terminal state + malformed ExpectedCAS returns `invalid_expected`; terminal state + a malformed/invalid event shape at the event-validation boundary returns `invalid_event` (not a valid but unsupported event type). Each uses complete state/request/event canonical-snapshot, direct-reference, and deep-field non-mutation evidence, including unchanged version and generation; these controls are not genuine B-2 RED work.
- [x] P1a2-i-B-2.3 RED: add terminal-plus-stale-ExpectedCAS precedence controls for each of `completed`, `failed`, and `manual_recovery`; use a valid listed non-ack event with a stale expected field and require `terminal_state` before CAS/lease diagnosis, with state/request/event, version, and generation unchanged. Keep these three controls distinct from the mixed-input controls.
- [x] P1a2-i-B-2.4 BASELINE CHARACTERIZATION/REGRESSION (may be green before B-2 production changes): retain three exact terminal `ack_dispatch` controls inherited from accepted B-1b; after accepted B-1b request/CAS/lease guards require `unsupported_event`, not terminal rejection or success, with the same canonical/direct/deep non-mutation proof and unchanged version/generation. Keep these three controls distinct from both preceding control families; they are not genuine B-2 RED work.
- [x] P1a2-i-B-2.5 GREEN: insert validation in exact order `state → request → expected → event → terminal policy → CAS equality → lease liveness → dispatch`; return `terminal_state` only for terminal status plus a listed non-ack event, exclude `ack_dispatch`, and leave every B-2 rejection/fallback non-mutating. Add no successful path or version/generation mutation.
- [x] P1a2-i-B-2.6 REFACTOR: freeze B-2, rerun the 33 genuine terminal RED vectors, three genuine stale-CAS RED controls, and six inherited baseline characterization/regression controls (three mixed-input, three terminal-ack), plus inherited B-1a/B-1b/A checks, explicit source+test TypeScript, source-only compatibility, and the model harness; retain later persistence/transition ownership of acknowledgement semantics and P1a2-ii ownership of positive version monotonicity.

**Strict-TDD classification**: genuine B-2 RED work is the 33 non-ack terminal-state vectors plus the three stale-CAS terminal-precedence controls; the three mixed-input controls and three exact terminal `ack_dispatch` controls are inherited baseline characterization/regression controls and may already be green before B-2 production changes. All 42 controls remain required: `33 + 3 mixed + 3 stale-CAS + 3 terminal-ack = 42`.

**Independent expected outcomes**: all 33 listed terminal vectors return the existing failure result with literal `terminal_state`; the three terminal-state mixed-input controls return `invalid_request`, `invalid_expected`, and `invalid_event` before terminal policy; all three terminal-plus-stale-CAS controls return `terminal_state` before CAS/lease precedence; all three exact terminal `ack_dispatch` controls return `unsupported_event` after accepted B-1b guards. Every B-2 rejection/fallback preserves canonical state, request, and event references/deep fields and leaves version and generation unchanged; B-2 has no success path. All expected states and requests are independently authored, not derived from reducer output.

**Focused test command**: `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` — B-2 terminal rejection, mixed-input, stale-CAS, and ack controls plus B-1a/B-1b/A regression coverage.

**Runtime harness**: the Node strip-types model harness runs the 33 terminal vectors plus three mixed-input, three stale-CAS, and three exact terminal-ack controls against independently authored in-memory states/requests/events; it does not emulate boundary delivery or terminalization.

**Acceptance gate**: 33/33 genuine terminal RED vectors return literal `terminal_state`; all three genuine stale-CAS RED controls preserve terminal precedence with `terminal_state`; the three inherited mixed-input characterization/regression controls return `invalid_request`, `invalid_expected`, and `invalid_event` before terminal policy; all three inherited exact terminal `ack_dispatch` characterization/regression controls remain `unsupported_event`. Canonical snapshot/direct-reference/deep-field proofs cover state, request, and event for all 42 controls; version and generation are unchanged on every B-2 outcome; no B-2 success path and no P1a2-ii/iii behavior exists. Positive version monotonicity and operation/proof immutability are first proven by P1a2-ii's real successful mutations.

**Rollback boundary**: revert only the B-2 terminal-policy/rejection controls, tests, and bookkeeping in `model.ts`, `model.test.ts`, `tasks.md`, and `apply-progress.md` to the accepted B-1b baseline. P1a2-i-B-1a, P1a2-i-B-1b, and P1a2-i-A remain intact; no later acknowledgement or positive monotonicity behavior is rolled back from P1a2-ii/P2/P3. The shared allowed-path contract authorizes B-2 bookkeeping in both SDD records, so neither record may retain B-2 bookkeeping after behavior rollback.

### P1a2-i-B-2 Forecast

| Component | Expected lines |
|---|---:|
| `model.ts` terminal policy and literal rejection result | 20–30 |
| `model.test.ts` 36 genuine RED vectors plus six inherited characterization/regression controls (33 terminal + 3 stale-CAS + 3 mixed-input + 3 terminal-ack) | 30–50 |
| B-2 bookkeeping in `tasks.md` + `apply-progress.md` | 18–30 |
| **Total P1a2-i-B-2** | **68–110** |

Early warning is 155; STOP/reforecast is 180; absolute max is 200. No size:exception, no split is required, and no borrowing from B-1a/B-1b. Component sum is verified: low `20+30+18 = 68`; high `30+50+30 = 110`; both are below the 155 warning. The three added mixed-input controls are included in the existing 30–50 test forecast; no forecast expansion is required. If this child cannot fit within 200 after an honest Git-native recount, stop and return `blocked` rather than exceeding its independent cap.

### P1a2-i-C — AuthAttempt Lifecycle Guard Refinement

**Status/objective**: P1a2-i-C and P1a2-ii are independently accepted. This C guard description is retained as historical context for the seven-row canonical lifecycle matrix.

**Depends on/paths**: accepted P1a2-i-B-2; only `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, `openspec/changes/prepare-public-portfolio-repository/tasks.md`, and `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` may change. No other source, test, config, persistence, product, P2, or P3 path.

### Strict TDD order (RED → GREEN → REFACTOR)

- [x] P1a2-i-C.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 and accepted B-2; capture no implementation or acceptance claim.
- [x] P1a2-i-C.1 RED ORACLE: author a test-owned literal table for exactly seven canonical status/phase rows and the finite complement over `Ø/I/C/D/K/A`; cover flag/null contradictions, per-variant nullability, and every confirmed attempt/UID/email/proof edge. Never derive validity from production.
- [x] P1a2-i-C.2 RED NEGATIVES: cover the finite complement: noncanonical pair, attempted/null mismatch, null UID, every variant nullability bit, phase/terminal incompatibility, active ambiguity, and each broken confirmed correlation; all fail existing `invalid_state` before later gates.
- [x] P1a2-i-C.3 RED RETENTION: for every rejection prove complete state/request/event/result byte identity, direct/deep reference retention, no mutation or graph retention, unchanged version/generation, and `invalid_state` precedence; canonical rows retain exact references.
- [x] P1a2-i-C.4 RED B-2 REGRESSION: replace exactly four pending-confirmed incoherent positives — the nested-boundary control plus its returned-UID-128, returned-UID-null, and proof-UID-128 variants — with canonical positives: reconstruct the three confirmed variants as `active/profile_commit+K` while varying only the tested scalar boundary, and reconstruct the nullable-return variant as `active/auth_preflight+D` with required returned fields/proof null. Replace 14 completed/terminal `Ø` vectors with `K`, 14 manual_recovery/terminal `Ø` vectors with `A`, and keep 14 failed/terminal `Ø` vectors unchanged. Preserve all 42 outcomes: 33 non-ack `terminal_state`, three stale-expected `terminal_state`, three malformed `invalid_request`/`invalid_expected`/`invalid_event`, and three terminal-ack `unsupported_event`, plus precedence, no mutation, graph detachment, and event/payload independence.
- [x] P1a2-i-C.5 GREEN: change only `isAuthAttempt`/`isValidState`; incoherent states return existing `invalid_state` before request/event/terminal/CAS/lease/dispatch, with no new behavior.
- [x] P1a2-i-C.6 REFACTOR/ACCEPTANCE: rerun inherited source+test TypeScript, Node model harness, all 42 B-2 controls, and independent design certification; recount after every RED/GREEN pair and stop at binding gates.

### Independent C acceptance gate

- [x] Independent certification confirms the seven-row literal oracle, finite complement, lifecycle/nullability/correlation rejection, complete retention proof, exact 42-control B-2 regression accounting, and only the four allowed paths changed. P1a2-ii was subsequently independently accepted.

### Verification, rollback, and workload boundary

- Focused command: `cd functions && node --experimental-strip-types test/provisioning/model.test.ts` (Node >= 22.6.0).
- Inherited source+test typecheck: `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts`; independent certification is read-only against the design hash and C gate.
- Rollback: remove only C guard/test/bookkeeping changes and restore the independently accepted B-2 `model.ts`/`model.test.ts` fixture state plus the prior SDD records; do not touch P1a1, A, B-1a/B-1b, P2, or P3.

### Local execution evidence (independent C acceptance recorded at ordinal 99)

- RED: the focused Node model harness exited 1 before guard changes; the first finite-complement lifecycle vector expected `invalid_state` but reached the inherited later-gate result.
- GREEN: focused Node model harness, explicit source+test TypeScript, and source-only TypeScript each exited 0 after the narrow guard change.
- The literal seven-row oracle exercises all 42 row/shape combinations, invalid flag/null and result-nullability families, confirmed correlation edges, precedence, snapshots, direct/deep reference retention, version/generation stability, and result graph detachment.
- B-2 remains 42/42: 33 non-ack terminal policy, 3 stale expected, 3 malformed precedence, and 3 `ack_dispatch` controls; completed uses `K`, failed uses `Ø`, and manual recovery uses `A`.

| Component | Expected lines |
|---|---:|
| `model.ts` guard correlation | 40–65 |
| `model.test.ts` oracle, finite complement, retention, B-2 migration | 160–245 |
| `tasks.md` + `apply-progress.md` bookkeeping | 20–30 |
| **Total P1a2-i-C** | **220–340** |

Early warning **300**; STOP/reforecast **350**; absolute max **400**. No borrowing, exception, or budget transfer is allowed. If the complete C contract cannot fit, stop and reforecast; do not widen scope.

### P1a2-i-B-3 — RETIRED / SUPERSEDED (historical only)

**Status**: Retired by maintainer planning decision and the amended design. This former executable five-class data-immutability and `ack_dispatch` slice was never implemented, never accepted, has no branch or PR, and MUST NOT be launched by native apply.

The claims are redistributed without a standalone reducer slice: P1a2-ii proves operation identity + normalized payload + intended UID and confirmed Auth proof across real state transitions; P2 proves audit identity and complete dispatch identity, enqueue acknowledgement, worker acknowledgement, deduplication, and guarded persistence; P3 proves provisioning/profile provenance and terminal persistence/no-regression. Enqueue acknowledgement is dispatch-only and never advances `OperationState.version`; worker acknowledgement advances version only inside an accompanying real transition. Exact terminal `ack_dispatch` remains B-2's `unsupported_event` characterization until those later owners implement its legal persistence semantics.

No checklist, executable forecast, entry gate, rollback boundary, or apply route exists for this retired work unit. Its former claims are retained here solely to make the supersession and ownership transfer auditable.

### P1a2-i-B Child Forecast and Order

| Order | Child | Expected | Early warning | STOP/reforecast | Absolute max | Feature-branch target |
|---:|---|---:|---:|---:|---:|---|
| 1 | P1a2-i-B-1a request contract + reducer surface | 105–135 | 120 | 170 | 200 | accepted P1a2-i-A-2 branch |
| 2 | P1a2-i-B-1b CAS + lease + unsupported dispatch | 105–130 | 120 | 170 | 200 | B-1a branch |
| 3 | P1a2-i-B-2 terminal rejection + non-mutation | 68–110 | 155 | 180 | 200 | B-1b branch |
| **Parent P1a2-i-B** | **three executable children** | **278–375 forecast; 600 binding cap** | **per child** | **per child** | **600 aggregate** | **no size:exception** |

Each executable child stops at its own absolute 200-line cap; the parent cannot borrow unused budget across children. The planned component forecast is `105–135 + 105–130 + 68–110 = 278–375`, below the 600-line parent cap. Accepted evidence is B-1a 111 lines, B-1b 76 lines, and B-2 173 lines: `111 + 76 + 173 = 360`; remaining parent capacity is `600 - 360 = 240`. Retired B-3 contributes no executable lines. At each warning, pause and recount all paths; at each STOP, no further mutation occurs without measured evidence and explicit continuation. The 800-line session review budget does not relax the 600-line parent maximum. Component sums remain verified: B-1a `30–40 + 55–70 + 20–25 = 105–135`; B-1b `35–45 + 50–65 + 20–20 = 105–130`; B-2 `20–30 + 30–50 + 18–30 = 68–110`; parent low `105+105+68 = 278`, high `135+130+110 = 375`.

### Aggregate independent phase-contract gates

- [x] B-1a: exact request/ExpectedCAS records, observedAt, failure precedence through `invalid_event`, unchanged nested event guards, old-call rejection, and canonical/direct non-mutation proof are accepted through `reduce()` without CAS equality/liveness or terminal policy.
- [x] B-1b: all eight CAS fields, separate lease equality/liveness, exact-live unsupported behavior, exact-terminal unsupported behavior before B-2, and canonical/direct non-mutation proof are accepted through `reduce()` without implementing a boundary transition.
- [x] B-2: 33 non-ack terminal `terminal_state` rejections, three mixed-input validation-precedence controls, three terminal-plus-stale-CAS precedence controls, three exact terminal `ack_dispatch` `unsupported_event` characterization controls, and unchanged version/generation on every outcome pass with independent expected states.
- [x] Retired B-3: former five-class data and acknowledgement scope is explicitly superseded; no implementation or acceptance is claimed, and its claims are assigned to P1a2-ii/P2/P3.
- [x] Aggregate: B-2's 33 negative vectors and nine distinct B-2 controls are present; only `reduce()` is public; P1a2-i-A is byte/foundation-frozen; P1a2-i-C and P1a2-ii are independently accepted, with ii owning the first real mutations; P1a2-iii terminalization remains absent.

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
| P1a2-i-B-2 | 68–110 |
| P1a2-i-C | 220–340 |
| **Total P1a2-i** | **1,418–1,965** |

Combined absolute max is 2,900 (1,600 + 300 + 600 + 400). No size:exception; the executable B parent forecast is 278–375, with 360 accepted baseline lines and 240 lines remaining under the 600-line parent cap. C is separate and cannot borrow from B. Retired B-3 has no executable budget.

### Handoff contract to P1a2-ii

Frozen immutable vocabulary + frozen deep runtime immutability + frozen type guards + frozen B-1a request/reducer surface + frozen B-1b module-private CAS/lease fence and unsupported dispatch + frozen B-2 terminal rejection/non-mutation (the 33 listed vectors return literal `terminal_state`; three terminal-state mixed-input controls return `invalid_request`/`invalid_expected`/`invalid_event` before terminal policy; three terminal-plus-stale-CAS controls preserve terminal precedence; exact terminal `ack_dispatch` controls remain `unsupported_event`; version and generation stay unchanged on every B-2 outcome) + C lifecycle guard and canonical Auth matrix, with C independently accepted before ii. P1a2-i-C is the handoff boundary for ii; the three executable B children and C implement no boundary transition or positive version monotonicity. **P1a2-ii alone proves positive version monotonicity on real operation mutations, exact acquisition (generation unchanged), exact takeover (+1 monotonic generation), and operation identity/normalized-payload/intended-UID plus confirmed-Auth-proof immutability across those mutations.** P2 owns audit/full-dispatch identity and acknowledgement persistence; P3 owns provisioning/profile provenance and terminal persistence/no-regression.

---

## P1a2-ii — Pure OperationState Transitions + Invariants (Exactly Eight Events)

**Objective**: after independent C acceptance, implement eight pure transitions: `acquire`, `takeover`, `auth_intent`, `auth_start`, `auth_confirm`, `auth_ambiguous`, `auth_foreign_user`, and `profile_commit`, using existing fields. Prove version `+1` per mutation, acquisition generation `0`, takeover generation `+1`, and immutability of operation identity, normalized payload, intended UID, and confirmed Auth proof.

`auth_preflight`, `auth_no_effect`, `ack_dispatch`, and `terminalize` remain explicitly unsupported in the pure reducer and return the existing `unsupported_event` failure after inherited validation/CAS/lease/terminal guards. They have no pure success path. No two-index reads or absence orchestration, explicit crash/read events, incoming delivery discrimination, duplicate/order/orphan persistence, queue or create-if-absent behavior, audit, profile/provenance persistence, acknowledgement persistence, retry, terminal evidence/codes, or atomic persistence proof belongs here. P2 retains schema/audit/dispatch foundations; P3 owns worker delivery/source-tuple and acknowledgement behavior, Auth reads/crash reconstruction, retry/terminalization, evidence/codes, profile/completion persistence, and persisted no-regression.

**Traceability**: design exact pure matrix/CAS/lease contract; spec Auth ambiguity, completion candidate, no pure deletion, and operation invariants. Gaps 5, 7, 9, 10 and operation/proof immutability are owned here; crash/read and terminalization remain P3.

**Depends on**: independently accepted P1a2-i-C after accepted P1a2-i-B-2. No standalone B-3 or P1a2-iii work unit is required or permitted.

**Base / branch**: `slice/p1a2-ii-pure-transitions` branched from the `slice/p1a2-i-c-auth-lifecycle-guard` boundary after C acceptance; PR target is the C branch only after its independent acceptance.

**Allowed paths** (exact):

- `functions/src/provisioning/model.ts` (extend only the eight matrix transitions and existing-field invariants)
- `functions/test/provisioning/model.test.ts` (extend with independent state/event/result vectors for the eight transitions and unsupported events)
- `openspec/changes/prepare-public-portfolio-repository/tasks.md` (SDD bookkeeping)
- `openspec/changes/prepare-public-portfolio-repository/apply-progress.md` (metadata updates during future apply)

**Forbidden in P1a2-ii**: all P1a2-i-A, P1a2-i-B, and P1a2-i-C changes; any new event, state, result, persistence entity, helper API, or field; `auth_preflight`/`auth_no_effect`/`ack_dispatch`/`terminalize` success paths; two-index read/absence or crash/read orchestration; explicit crash/read events; delivery classification; duplicate/order/orphan persistence; queue/create-if-absent behavior; audit; profile/provenance persistence; acknowledgement persistence; retry; terminal evidence/codes; atomic persistence; Firebase/Auth/Firestore/Cloud Tasks behavior. The inherited full CAS/lease/terminal guards remain first; no standalone `ack_dispatch` success or version advancement is permitted.

### Strict TDD order (RED → GREEN → REFACTOR)

- [x] P1a2-ii.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0, accepted B-2, and independent C acceptance; no ii work starts without separate authorization.
- [x] P1a2-ii.1 RED COMMON: author state/request/event/expected-output fixtures and a `family + label + expected reason + actual result` ledger; require exact success counts and zero negatives. Consume C's seven-row canonical lifecycle contract; takeover covers exactly `auth_preflight×{Ø,D}`, `auth_create×{I,C}`, and `profile_commit×{K}` (five rows), never an active ambiguity or phase/result Cartesian product. Terminal pairs -> `terminal_state`. Snapshot every negative's state/request/event, canonical values, refs, version/generation, and result retention; use no production oracle. Malformed state/request/expected/event -> `invalid_state`/`invalid_request`/`invalid_expected`/`invalid_event`; terminal/CAS/lease/unsupported controls are regression. Every successful expected state asserts `updatedAt=request.observedAt`.
- [x] P1a2-ii.1a RED INVARIANTS: check unchanged `operationId`, `fingerprint`, `normalizedPayload`, `intendedUid`, `createdAt`, existing `currentDispatchId`, and confirmed attempt/proof unless named; assert `updatedAt=request.observedAt` on all eight successes; retain no request/event graph.
- [x] P1a2-ii.2 RED `acquire`: pending/dispatch_pending only; generation/version `0/0`, null owner/lease/Auth, exact CAS, valid owner, payload lease `> observedAt`; expect active/auth_preflight with owner/lease, generation `0`, version `1`, `updatedAt=observedAt`, Auth false/null. `ACQ-LIFE`/`ACQ-PRED` cover nonzero generation, existing owner/lease, and valid-shape payload lease `<= observedAt`; non-live payload -> `lease_not_live` at lease stage, lifecycle/correlation -> `unsupported_event`, malformed lease -> inherited `invalid_event`; retain stale-CAS/terminal controls.
- [x] P1a2-ii.3 GREEN `acquire`: changes owner/lease/status/phase/version; preserves immutable fields/no request/event graph. Lifecycle/correlation -> `unsupported_event`; valid-shape non-live payload -> `lease_not_live`; malformed lease -> `invalid_event`; inherited controls unchanged.
- [x] P1a2-ii.4 RED `takeover`: consume exactly five C-admitted active rows: `auth_preflight+Ø`, `auth_preflight+D`, `auth_create+I`, `auth_create+C`, and `profile_commit+K`; preserve each lifecycle shape verbatim. Cover exact CAS, prior lease `<= observedAt`, different owner, live payload lease, `updatedAt=observedAt`, and no active ambiguity vector. Add `TK-LIFE`, live `TK-LEASE`, same-owner `TK-OWNER`, and `TK-GEN` with prior generations `0`/`2`, requiring outputs `1`/`3` (reject `prior-1`/`prior+2`). A still-live prior lease `> observedAt` is the applicable lease failure and returns `lease_not_live`, not `unsupported_event`.
- [x] P1a2-ii.5 GREEN `takeover`: preserve status/phase/AuthAttempt/immutable fields; replace owner/lease; generation/version prior `+1`; preserve existing `currentDispatchId` exactly, with no new/copied dispatch identity. TK lifecycle/correlation -> `unsupported_event`; live prior lease -> `lease_not_live`; malformed lease -> `invalid_event`.
- [x] P1a2-ii.6 RED `auth_intent`: active/auth_preflight, live lease, intendedUid non-null, Auth false/null, payload attemptId/intentAt; expect active/auth_create intent `{callStartedAt:null,result:"intent",returnedUid:null,returnedEmail:null,proof:null}`, version `+1`, generation unchanged, `updatedAt=observedAt`. Add `INT-LIFE`/`INT-FACT` (wrong lifecycle, attempted/non-null attempt, null UID, malformed/mismatched facts); malformed shape is regression.
- [x] P1a2-ii.7 GREEN `auth_intent`: install intent fields; preserve identity/payload/owner/lease/generation, version `+1`, no audit/dispatch/ack; misses -> `unsupported_event`.
- [x] P1a2-ii.8 RED `auth_start`: active/auth_create, live lease, attempted=true, intent-shaped attempt (null call/returns/proof), matching ID and callStartedAt; expect active/auth_create with only callStartedAt/result `"call_started"`, version `+1`, `updatedAt=observedAt`. Add `START-LIFE` wrong lifecycle, absent/non-intent/confirmed/ambiguous attempt, mismatched ID, malformed facts; no un-designed time-order predicate.
- [x] P1a2-ii.9 GREEN `auth_start`: matching intent only; preserve attemptId/intentAt/null returns/proof and immutable fields, version `+1`, no Auth call; lifecycle -> `unsupported_event`, malformed inputs inherited.
- [x] P1a2-ii.10 RED `auth_confirm`: active/auth_create, live lease, attempted=true, call-started attempt (callStartedAt non-null, returns/proof null), matching state/proof ID. Add `CONF-LIFE` (wrong lifecycle/direct intent/absent/non-call_started/confirmed/ambiguous), `CONF-ID`, independent `CONF-UID`/`CONF-EMAIL` link breaks, and `CONF-PROOF` absent/malformed/proven-before-call/inconsistent-read cases; expect active/profile_commit confirmed with exact returns/proof, version `+1`, `updatedAt=observedAt`.
- [x] P1a2-ii.11 GREEN `auth_confirm`: require call-started UID/email/proof; output active/profile_commit with preserved times, exact returns/proof and immutable fields/generation, version `+1`, no reads/persistence; `CONF-*` -> `unsupported_event`.
- [x] P1a2-ii.12 RED `auth_ambiguous`: active/auth_create, live lease, attempted=true, sole unproven call-started attempt (callStartedAt non-null, returns/proof null), matching ID; expect manual_recovery/terminal, result `"ambiguous"`, null returns/proof, cleared owner/lease, version `+1`, `updatedAt=observedAt`. `AMB-LIFE` covers wrong lifecycle, absent/intent/confirmed/definite_no_effect/already-ambiguous/proven, mismatched ID, and returned/proof identity; confirmed/proven is rejected.
- [x] P1a2-ii.13 GREEN `auth_ambiguous`: change only result/status/phase/owner/lease/version; preserve identity/times/generation, no code/evidence; `AMB-*` -> `unsupported_event`.
- [x] P1a2-ii.14 RED `auth_foreign_user`: active/auth_preflight, live lease, intendedUid non-null, Auth false/null; expect failed/terminal, cleared owner/lease, Auth false/null, version `+1`, `updatedAt=observedAt`. Add wrong lifecycle/prior attempt, both-identities-match rejection, both one-inequality foreign positives, and `FOR-LIFE` identity-copy/mutation probes.
- [x] P1a2-ii.15 GREEN `auth_foreign_user`: require UID-or-normalized-email inequality; output failed/terminal without payload identity, preserve operation fields/intendedUid/generation, clear owner/lease, version `+1`; matching-both/lifecycle/prior-attempt -> `unsupported_event`.
- [x] P1a2-ii.16 RED `profile_commit`: active/profile_commit, live lease, attempted=true, confirmed attempt (callStartedAt/returns/proof non-null); userId=returnedUid=proof.uidRead=intendedUid and returnedEmail=proof.emailRead=normalized target. Add `PRO-LIFE`, absent/non-confirmed, each `PRO-UID`/`PRO-EMAIL` link break, and `PRO-PARTIAL` proof/identity mutation; expect completed/terminal, version `+1`, `updatedAt=observedAt`.
- [x] P1a2-ii.17 GREEN `profile_commit`: require every correlation; preserve confirmed attempt/proof byte-identically and immutable fields, clear owner/lease, set completed/terminal, version `+1`; `PRO-*` -> `unsupported_event`, no persistence.
- [x] P1a2-ii.18 RED UNSUPPORTED/INVARIANTS: author exact valid `auth_preflight`, `auth_no_effect`, `ack_dispatch`, and `terminalize` vectors; each returns `unsupported_event` with no success/version change. Then re-run common success invariants.
- [x] P1a2-ii.19 GREEN UNSUPPORTED/INVARIANTS: retain the four unsupported events after inherited validation/CAS/lease/terminal gates; enforce common invariants without fields, helpers, reasons, persistence, or external observations.
- [x] P1a2-ii.20 REFACTOR/ACCEPTANCE: native ordinal 105 independently accepted the frozen eight-event matrix: 601/601 assertions; acquire, takeover, auth_intent, auth_start, auth_confirm, auth_ambiguous, auth_foreign_user, and profile_commit passed; focused Node, explicit source+test/source-only TypeScript, inherited 36/36 + 36/36 + 32/32, fixtures, and diff checks passed.

### Verification commands

- `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/types.ts src/provisioning/normalize.ts src/provisioning/ids.ts src/provisioning/model.ts test/provisioning/types.test.ts test/provisioning/normalize.test.ts test/provisioning/ids.test.ts test/provisioning/fixtures.ts test/provisioning/model.test.ts`
- `cd functions && node --experimental-strip-types test/provisioning/model.test.ts`
- Git-native count (Windows PowerShell): `git diff --numstat <P1a2-i-C-baseline> -- functions/src/provisioning/model.ts functions/test/provisioning/model.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md`; sum additions + deletions after each RED/GREEN pair.

### Independent phase-contract acceptance — RECORDED at native ordinal 105: evidence revision `sha256:8fa48fbbd0e387f0025c95afc8bbcab0ef967093010d926f308d9fed7b1c9dd6`; ordinal-102 endpoint scope `79 + 151 + 26 + 44 = 300` changed lines; hybrid parity passed and validation made zero mutation.

- [ ] Exactly eight pure successes and four unsupported events; allowed paths, ownership, retirements, and no fictional crash/read events remain unchanged.
- [ ] `ACQ-LIFE`/`ACQ-PRED`: acquire admits only pending/dispatch_pending, generation/version `0/0`, null owner/lease/Auth, exact CAS, and live payload lease; valid-shape payload lease `<= observedAt` -> `lease_not_live`, lifecycle/correlation -> `unsupported_event`, malformed lease -> `invalid_event`, other inherited guards retain reasons.
- [ ] `TK-LIFE`/`TK-LEASE`/`TK-OWNER`/`TK-GEN`: exactly five C-admitted rows (`auth_preflight+Ø`, `auth_preflight+D`, `auth_create+I`, `auth_create+C`, `profile_commit+K`), no active ambiguity or other variant. Expired lease/different owner -> generation/version `+1`; existing `currentDispatchId` is preserved exactly, with no new/copied dispatch identity; live prior lease -> `lease_not_live`; other TK lifecycle/correlation misses -> `unsupported_event` without mutation.
- [ ] `INT-LIFE`/`INT-FACT`: auth_intent requires active/auth_preflight, live lease, non-null intendedUid, false/null Auth fields, and exact intent output at active/auth_create; all listed contradictions fail closed.
- [ ] `START-LIFE`: auth_start requires active/auth_create and exact intent/ID, outputs call_started with only existing fields changed, and rejects all listed attempt/ID cases; no un-designed time ordering is added.
- [ ] `CONF-LIFE`/`CONF-ID`/`CONF-UID`/`CONF-EMAIL`/`CONF-PROOF`: auth_confirm rejects direct intent, wrong attempts, each independent ID/UID/email/proof break, and absent/malformed/proven-before-call/inconsistent proof; exact output is active/profile_commit.
- [ ] `AMB-LIFE`: auth_ambiguous accepts only matching unproven call_started; rejects absent/intent/confirmed/definite-no-effect/already-ambiguous/proven/mismatched cases; output is manual_recovery/terminal with null returns/proof and cleared owner/lease.
- [ ] `FOR-LIFE`/identity probes: auth_foreign_user requires pre-attempt active/auth_preflight and UID-or-email inequality; both-match rejects, one-inequality controls succeed, and payload identity is never copied.
- [ ] `PRO-LIFE`/`PRO-UID`/`PRO-EMAIL`/`PRO-PARTIAL`: profile_commit requires active/profile_commit, confirmed proof, and every UID/email link; exact output is completed/terminal with byte-identical proof; partial/identity mutations fail closed.
- [ ] Every negative returns the stable existing reason: lifecycle/correlation -> `unsupported_event`; valid-shape non-live acquire payload or live takeover prior lease -> `lease_not_live`; malformed lease -> `invalid_event`; otherwise inherited `invalid_*`, `terminal_state`, or `cas_mismatch`. Prove snapshots, refs, canonical fields, version/generation, no result graph.
- [ ] Every success has an independent expected status/phase/attempt and `updatedAt=request.observedAt`, version `+1`, takeover-only generation `+1`, immutable fields including exact existing `currentDispatchId`, terminal owner/lease clearing, and no request/event retention; unsupported outputs do not mutate/version.
- [ ] P2/P3 ownership remains intact: no pure audit/dispatch/profile/provenance/ack/retry/evidence/external proof; profile_commit remains only P3's persistence candidate.

### Rollback boundary

Revert only the eight-transition additions and invariant tests in `functions/src/provisioning/model.ts` and `functions/test/provisioning/model.test.ts`, plus this slice's `tasks.md`/`apply-progress.md` bookkeeping, to the independently accepted P1a2-i-C baseline. P1a1, P1a2-i-A, B-1a, B-1b, B-2, and C remain intact; no P2/P3 persistence behavior is rolled back.

### P1a2-ii Forecast (component sum verified)

| Component | Expected lines |
|---|---:|
| `model.ts` eight pure transitions + existing-field invariant enforcement | 180–240 |
| `model.test.ts` eight independent transitions + C-admitted lifecycle/correlation negative families + unsupported/guard/invariant probes | 440–620 |
| `tasks.md` + `apply-progress.md` bookkeeping | 60–80 |
| **Total P1a2-ii** | **680–940** |

Early warning is 1,100; STOP/reforecast and absolute max are 1,200. No size:exception, borrowing, invented field, or hidden transfer cost is allowed. Component sum is verified: low `180+440+60 = 680`; high `240+620+80 = 940`. If the complete pure slice cannot fit under 1,200, stop and return `blocked` with the exact decision needed; do not widen the reducer or use a size exception.

---

## P1a2-iii — RETIRED / SUPERSEDED (historical only)

P1a2-iii is permanently retired by the maintainer-authorized pure-reducer correction. It was never implemented, never accepted, has no checklist, forecast, entry gate, branch, PR, rollback boundary, native apply route, or executable dependency. It MUST NOT be launched or treated as an incomplete task.

Its former runtime/persistence claims are reassigned as follows: P3 owns retry thresholds, worker delivery classification, full dispatch tuple/source validation, worker acknowledgement, terminalization predicates, terminal evidence/codes, persisted terminal no-regression, and Auth/profile crash/read reconstruction. P2 retains schema/audit/dispatch foundations, including dispatch field definitions and enqueue foundations. P1a2-ii owns only the eight representable pure OperationState transitions and invariants listed above. The historical name is retained solely for audit traceability.

### P1a2 Aggregate (P1a2-i-B has 3 executable children; A-1 has 4 children; C gates ii)

| Sub-slice | Expected |
|---|---:|
| P1a2-i-A-1a | 200–270 |
| P1a2-i-A-1b | 200–270 |
| P1a2-i-A-1c | 200–270 |
| P1a2-i-A-1d | 200–270 |
| P1a2-i-A-2 | 120–170 |
| P1a2-i-B-1a | 105–135 |
| P1a2-i-B-1b | 105–130 |
| P1a2-i-B-2 | 68–110 |
| P1a2-i-C | 220–340 |
| P1a2-ii | 680–940 |
| P1a2-iii | **0 — retired** |
| **Total P1a2** | **2,098–2,905** |

P1a2 aggregate hard maximum: **4,100** (P1a2-i max 2,900 + P1a2-ii max 1,200). The B parent remains capped at 600 across its three executable children; its forecast is 278–375 and accepted baseline is 360/600. C has its independent 220–340 forecast and 400 max; ii is independently accepted at ordinal 105 (300 changed-line endpoint). Retired B-3 and P1a2-iii have no executable budget, and no size:exception exists for any P1a2 sub-slice.

### Handoff contract to P1b

Frozen pure types + frozen normalization/fingerprint + frozen deterministic IDs + frozen canonical vector fixtures + frozen immutable vocabulary + frozen deep runtime immutability + frozen type guards + frozen CAS fence + frozen reducer skeleton (only `reduce()` as public API) + frozen B-2 terminal rejection/non-mutation (11×3 `terminal_state` vectors, three terminal-state mixed-input `invalid_request`/`invalid_expected`/`invalid_event` controls, three terminal-plus-stale-CAS precedence controls, three exact terminal `ack_dispatch` `unsupported_event` controls, unchanged version/generation on every B-2 outcome) + C lifecycle guard accepted before ii + frozen P1a2-ii eight-event pure transition matrix, positive version monotonicity, generation rules, and operation/proof immutability. P1b builds the persistence port and implements the in-memory reference store and the Firestore emulator adapter; both MUST pass every frozen pure vector from P1a1+P1a2 identically. P2/P3 persistence ownership remains outside this pure-model handoff.

---

## P1b — Persistence Ports + Conformance (Memory Reference + Firestore Emulator)

**Objective**: define the domain `Store` port (no Firebase import in the port), implement the strict in-memory reference store, implement the Firestore emulator transaction adapter using real `firebase-admin` transactions, and author full CAS/lease primitives plus the generation fence. Run **every frozen P1a vector** against both stores and assert byte-equal outcomes. Run crash-point schedules around every transaction boundary. **No schema validators, no audit primitives, no profile provenance, and no terminalization predicates.** Schemas/audit move to P2; profile and terminalization move to P3. **No callable, no dispatch handler, no worker, no submission, no status, no Auth.createUser call.** This slice is the persistence contract and CAS/lease primitives only.

**Spec traceability**: Requirement: Operation Invariants; Requirement: Operation Identity and Idempotency; Requirement: Completion Atomic Commitment; Requirement: First-Slice Compensation Policy.

**Design traceability**: Persistence contracts (`/provisioningOperations`, `/provisioningDispatch`); indexes; full CAS and lease contract; "Executable Contract Before Production Code" (independent pure model + identical conformance vectors against both stores).

**Depends on**: accepted P1a2-ii (frozen eight-event pure reducer matrix + invariants; transitively includes frozen P1a1 types + normalization + IDs + fixtures and P1a2-i). P3, not P1b, owns runtime terminalization and retry behavior.

**Base / branch**: `slice/p1b-persistence-conformance` branched from `slice/p1a2-ii-pure-transitions`; PR target is the accepted P1a2-ii branch.

**Allowed paths** (exact):

- `functions/src/provisioning/store.ts` (new — domain port; NO firebase-admin import)
- `functions/src/provisioning/memory_store.ts` (new — strict in-memory reference implementation)
- `functions/src/provisioning/firestore_store.ts` (new — Firestore emulator transaction adapter; real firebase-admin)
- `functions/src/provisioning/cas.ts` (new — full CAS predicates, lease helpers, and generation fence; no terminalization predicates)
- `functions/test/provisioning/store_conformance.test.ts` (new — shared harness running every frozen P1a vector against a store)
- `functions/test/provisioning/memory_store.test.ts` (new — in-memory-specific tests)
- `functions/test/provisioning/firestore_store.test.ts` (new — Firestore emulator conformance)
- `functions/test/provisioning/cas.test.ts` (new — CAS predicate + lease + generation-fence vectors against both stores)
- `functions/package.json` (minimal: add emulator test script routing to `node --experimental-strip-types`; no new runtime dependencies — WU4a already has `firebase-admin`)

**Forbidden in P1b**: no `schemas.ts`, no `audit.ts`, no `profile.ts`, no callable (submit/status), no outbox trigger, no scheduled sweeper, no task worker, no dispatch handler, no Auth.createUser, no `index.ts` export changes, no `firebase.json` emulator port additions, no `firestore.indexes.json` changes.

**Native `sdd-attempt` contract**:
- Work unit: P1b
- Evidence goal: persistence port + memory store + Firestore emulator adapter + CAS primitives all green; every frozen P1a vector passes identically against both stores
- max = 2,000
- `status` → begin exactly once only when `next_action=begin` → `finish` truthfully
- no launch unless `next_action=begin`

### Strict TDD order (RED → GREEN)

- [x] P1b.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0 before every test/emulator invocation.
- [x] P1b.1 RED: domain port (`Store`) — type-level compile failure until interface defined; no firebase-admin import in the port.
- [x] P1b.2 GREEN: define `Store` port with transactional semantics (read, write, CAS, transaction wrapper); every conformance test fails because no implementation exists yet.
- [x] P1b.3 RED: in-memory reference store — every frozen P1a conformance vector fails against the in-memory store.
- [x] P1b.4 GREEN: implement in-memory store; pass every frozen P1a vector identically.
- [x] P1b.5 RED: CAS primitives — full tuple predicate, server-time lease check, and generation fence; terminalization predicates are excluded and owned by P3.
- [x] P1b.6 GREEN: CAS primitives pass against the in-memory store.
- [x] P1b.7 RED: Firestore emulator adapter — every frozen P1a conformance vector fails against the real emulator via `firebase-admin` transactions.
- [x] P1b.8 GREEN: implement Firestore adapter using real `firebase-admin` transactions against the Firestore emulator; pass every frozen P1a vector.
- [x] P1b.9 RED: divergence test — run identical frozen P1a conformance vectors against both stores and assert byte-equal outcomes; any reference-vs-emulator difference fails the build.
- [x] P1b.10 GREEN: divergence test passes.
- [x] P1b.11 RED: CAS primitives against Firestore emulator — full tuple predicate, server-time lease check, and generation fence; every stale mutation fails; exact live tuple succeeds; no terminalization predicate is added.
- [x] P1b.12 GREEN: CAS primitives pass against both stores identically.
- [x] P1b.13 RED: crash-point schedule around every transaction boundary — abort simulation, retry, idempotent re-entry; both stores must behave identically.
- [x] P1b.14 GREEN: crash-point schedule passes for both stores identically.
- [x] P1b.15 REFACTOR: freeze persistence port + stores + CAS primitives. `npx tsc --noEmit` green.

### Independent P1b acceptance — RECORDED

- [x] Fresh independent PASS at `sha256:7b0340540a81cf6034bdea8d5e30cc536ad55432932016a7b4db26e1d89e41b5` remediated failed evidence `sha256:701e1e83f97c2a9580bf03bd2c546bc9cb49b2154c65868cfb24aa54c2f24ac8`; native objective is complete.
- [x] All 12/12 native controls passed: Store 4/4, memory 1/1, Firestore 7/7, CAS 4/4, and TypeScript 2/2; all five evaluator inputs passed.
- [x] Exact OpenSpec/Engram parity, cleanup/zero mutation, and the 742/800 review scope passed; remediation evidence is `sha256:b7cbed7aef8db580233bbc394d89026cd80329d0020591690f9c7b2865fffa62`.

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

Frozen persistence port + frozen in-memory reference store + frozen Firestore emulator adapter + frozen CAS/lease/generation primitives. Every frozen P1a vector passes identically against both stores. P2 builds the schemas, audit primitives, submission callable, dispatch machinery, and outbox using these; P3 adds runtime terminalization predicates and worker behavior.

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

**Objective**: implement operation/dispatch/audit schema validators with PII-safety and dedup, the `submitProvisioning` App Check-enforced callable, authorization/denial audit, safe status DTO projection, atomic operation+initial outbox transaction, shared Cloud Tasks enqueue adapter, created-only retry-enabled trigger, scheduled stale-outbox sweeper, deterministic task IDs, deterministic create-if-absent dispatch entity behavior, `ALREADY_EXISTS` acceptance, orphan dispatch persistence lookup/rejection, and guarded enqueue acknowledgement persistence. P2 retains schema, audit, dispatch-identity, enqueue, and outbox foundations: it defines worker-acknowledgement fields but does not own worker delivery classification, full source-tuple validation, worker acknowledgement behavior, terminalization, retry, or crash/read reconstruction; those are P3. Enqueue acknowledgement updates only the dispatch record and never mutates or versions `OperationState`. Trigger/sweeper race safety and repository-preparation metadata for indexes, IAM, schedule, trigger, and monitoring/alerting/runbook remain in this slice.

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
- `functions/src/provisioning/deployment_metadata.ts` (new — declarative IAM/deployment metadata carrier exporting `provisioningDeploymentMetadata`; inert repository-preparation evidence only)
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

- [x] P2.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [x] P2.1 RED: operation schema validator — every invalid field combination fails.
- [x] P2.2 GREEN: operation schema validator; valid combinations pass; invalid rejected.
- [x] P2.3 RED: dispatch schema validator — immutable identity + enqueue/ack updates only.
- [x] P2.4 GREEN: dispatch schema passes.
- [x] P2.5 RED: audit schema + PII-safety — no raw email, names, DNI, telephone, body, token, reset link, SDK message in any audit field.
- [x] P2.6 GREEN: audit schema passes; PII-safety scan passes.
- [x] P2.7 RED: audit dedup — same `auditEventId` with matching identity fields is idempotent; mismatched identity fails.
- [x] P2.8 GREEN: audit dedup passes.

### P2.0–P2.8 Current Acceptance Record

- **Accepted**: correction `sha256:93b5138397a6fc507f6aa54be82196fe09a4f16e262747cc6e93c1fb5ddd89fd` and fresh independent acceptance `sha256:92d5e1f8a42edb9259172157367d05bea1ecec8fc317ccf4dd1801e8566388c7` supersede the prior failed evidence `sha256:4d632a9cbb929dbcd3d014e9618f7e54546c669fb4d1be8193e8f874e6730a3d`.
- **Current acceptance**: schemas 41/41, audit 46/46, durable total 87/87, supplemental 9/9; configured TypeScript and `git diff --check` passed with zero-mutation independent verification.
- **Scope**: cumulative P2 source/test scope 271/800; correction-only scope 47/200. P2.11+ remains unchecked and pending.
- **Artifact authority**: OpenSpec is canonical. Engram chunk observations #3433, #3457–#3459, #1725, and #3460 are immutable historical snapshots, not current parity gates, and MUST NOT be updated; Engram may retain only small path/hash/evidence summaries, never full artifact bytes.
- [x] P2.9 RED: admin authorization — unauthenticated -> `unauthenticated`; non-admin -> `permission-denied`; denial audit written before any mutation.
- [x] P2.10 GREEN: authorization + denial audit pass.
- [x] P2.11 RED: App Check metadata — `enforceAppCheck:true` structural assertion on exported callable. This test MUST be run RED against the WU4a placeholder BEFORE the callable export is introduced.
- [x] P2.12 GREEN: export callable with `enforceAppCheck:true`; metadata test passes.
- [x] P2.13 RED: submission handler — invalid schema -> `invalid-argument`; role not in `employee|rrhh` -> `invalid-argument`; missing `operationId/email/nombre/apellido1` -> `invalid-argument`.
- [x] P2.14 GREEN: schema validation passes.
- [x] P2.15 RED: submission transaction — atomic operation + initial dispatch creation; no Auth call; no profile write; return `{operationId, status:'pending'}`.
- [x] P2.16 GREEN: submission transaction passes.
- [x] P2.17 RED: idempotent replay — same `(operationId, fingerprint)` returns current safe status; different fingerprint returns `already-exists` without mutation.
- [x] P2.18 GREEN: idempotent replay passes.
- [x] P2.19 RED: safe DTO projection — each status projects only its safe fields; no raw email, owner, lease, generation/version, evidence, audit identity, reset link leaked.
- [x] P2.20 GREEN: DTO projection passes.
- [x] P2.21 RED: PII-safe log/audit structural check — application logs contain only allowlisted codes and domain-separated digests.
- [x] P2.22 GREEN: PII-safety passes.
- [x] P2.23 RED: enqueue adapter contract — injectable interface; strict fake proves outbox idempotency.
- [x] P2.24 GREEN: adapter contract + strict fake pass.
- [x] P2.25 RED: production adapter contract — deterministic queue/task construction from dispatch identity; same task ID for same dispatch.
- [x] P2.26 GREEN: production adapter contract passes.
- [x] P2.27 RED: created-trigger handler — validates immutable dispatch shape; calls shared adapter; success or `ALREADY_EXISTS` followed by guarded ack transaction (exact dispatch identity + `enqueued=false` -> `enqueued=true`).
- [x] P2.28 GREEN: trigger behavior passes; duplicate event, enqueue success, crash-before-ack, `ALREADY_EXISTS`, invalid dispatch, guarded ack, trigger+sweeper race vectors pass.
- [x] P2.29 RED: sweeper handler — invoke directly with Firestore-emulator records + shared enqueue adapter; 10-minute grace edge; `(enqueued, createdAt, __name__)` ordering/cursors; 100x5 bounds; rate/concurrency limits.
- [x] P2.30 GREEN: sweeper handler behavior passes.
- [x] P2.31 RED: sweeper forbidden operations — must NOT execute saga phases, mutate Auth/profile/operation state, acknowledge worker completion, create dispatches, or invent task identities.
- [x] P2.32 GREEN: forbidden operations test passes.
- [x] P2.33 RED exception: trigger+sweeper race characterization — maintainer authorized no genuine RED because P2.27–P2.32 already implement the required behavior; the definitive test proves one enqueue wins, the other observes `ALREADY_EXISTS`, and either acknowledgement order converges to `enqueued=true`.
- [x] P2.34 GREEN: deterministic race characterization passes.
- [x] P2.35 RED: partial failure/throw — per-record failure logs PII-safe digests; run processes its bounded page, then throws so Scheduler retry + next regular schedule repair.
- [x] P2.36 GREEN: partial failure/throw passes.
- [x] P2.37 RED: trigger metadata structural proof — retry-enabled `onDocumentCreated`, `retry:true`.
- [x] P2.38 GREEN: trigger metadata passes.
- [x] P2.39 RED: scheduler metadata structural proof — `retryCount=3`, `minBackoffSeconds=30`, `maxBackoffSeconds=300`, `maxDoublings=2`, `maxInstances=1`, `timeoutSeconds=240`, every-5-minute cadence.
- [x] P2.40 GREEN: scheduler metadata passes.
- [x] P2.41 RED: monitoring metadata structural proof — alert names/thresholds documented (no production alert created).
- [x] P2.42 GREEN: monitoring metadata passes.
- [x] P2.43 RED: IAM metadata structural proof — require `deployment_metadata.ts` and its `provisioningDeploymentMetadata` export; cover environment/project/region/rate/concurrency placeholders, logical per-function service accounts, Cloud Tasks queue/retry/rate-limit configuration, task OIDC identity, Scheduler invoker, Eventarc trigger identity, Cloud Tasks enqueuer capability, and required Firestore/Auth capabilities.
- [x] P2.44 GREEN: declarative metadata only — prove the carrier passes with placeholders and capability intent; explicitly forbid real project IDs, secrets, role/principal bindings, created resources, deployment effects, and guessed region/rate/concurrency values. P3 retains ownership of the final task-function export and reviewed runtime IAM bindings.
- [x] P2.45 RED: structural boundary (BACKEND-only) — BEFORE P2 Functions production files exist, test requires BOTH: (a) required P2 Functions production files/exports/metadata exist and are wired (`submit.ts` submission handler, `schemas.ts` validators, `audit.ts` primitives, `enqueue.ts` shared adapter, `outbox.ts` created trigger, `outbox_repair.ts` scheduled sweeper, `deployment_metadata.ts` declarative `provisioningDeploymentMetadata` carrier, `index.ts` callable exports with `enforceAppCheck:true`, metadata tests for trigger/scheduler/monitoring/IAM paths); `iam_metadata.test.ts` imports the carrier directly, with no required `index.ts` re-export; these are absent before P2, guaranteeing genuine RED; (b) forbidden BACKEND-only patterns remain absent in `functions/` scope (no raw HTTP task/callable workaround, no automatic Auth deletion, no client Firebase secondary-app logic copied into Functions, no unsafe direct profile mutation outside approved transaction primitives, no missing `enforceAppCheck:true` metadata on exported callables). Test scans ONLY Functions/`functions/` backend scope and MUST NOT require Flutter/client pattern removal. Test fails RED because required Functions files/exports are missing.
- [x] P2.46 GREEN: structural boundary (BACKEND-only) passes AFTER P2 implementation — all required P2 Functions production files exist and are wired in Functions scope, including the declarative `deployment_metadata.ts` carrier; `iam_metadata.test.ts` imports `provisioningDeploymentMetadata` directly from that carrier, with no required `index.ts` re-export; forbidden backend-only patterns remain absent in Functions scope. Client structural absence (secondary Firebase app, direct client Auth creation, direct profile write, client compensation, temp passwords) is P4's responsibility via `firebase_service_migration_test.dart` and related client/UI path tests. P3 retains the final task-function export and reviewed runtime IAM bindings.
- [x] P2.47 REFACTOR: write `docs/operations/outbox-recovery-runbook.md`; add all index additions to `firestore.indexes.json`; `npx tsc --noEmit` green.

### Review Workload Forecast — IAM Carrier Amendment

| Field | Amendment impact |
|---|---|
| Existing P2.43–P2.44 implementation budget | Unchanged; the carrier and direct-import proof remain within the existing IAM metadata-proof scope. |
| Chain recommendation | Unchanged; retain `auto-chain` with `feature-branch-chain`; no delivery action is triggered. |

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

Frozen schemas + frozen audit primitives + frozen submission callable + callable export with `enforceAppCheck:true` metadata + frozen shared enqueue adapter + frozen created-trigger + frozen sweeper + frozen indexes + frozen runbook. P3 consumes the dispatch schema/foundations and owns full dispatch source-tuple validation, worker acknowledgement behavior, delivery classification, Auth/profile crash/read reconstruction, retry thresholds, terminalization predicates/evidence/codes, persisted terminal no-regression, profile provenance, status callable, and full backend integration proof.

### P2 Forecast (component sum verified)

Original P2 forecast (without schemas/audit): 660–890. Moved schemas + audit from P1b: +370–495 (schemas.ts 120-160, audit.ts 80-110, schemas.test.ts 100-130, audit.test.ts 70-95).

**P2 Forecast**: 1,030–1,385 (660+370=1,030; 890+495=1,385). This forecast is unchanged: audit/full-dispatch ownership was already included in P2, so no retired B-3 executable cost is duplicated here.

Reforecast/STOP at 1,700; absolute max 2,000.

---

## P3 — Profile Provenance + Worker + Status + Full Backend Proof

**Objective**: implement profile provenance matching (moved from P1b), the one-effect-boundary `onTaskDispatched` worker, full dispatch source-tuple validation and worker acknowledgement, incoming delivery classification, Auth preflight/intent/create/dual-index reconstruction/manual recovery/no-deletion, profile+completed+success audit+ack atomicity, 12/8 pending+active terminalization, terminal evidence/codes and persisted no-regression, `getProvisioningStatus` callable with completed-integrity checks and fresh reset link generation, final exports and IAM metadata, and the full test suite (unit, crash/read, threshold, task HTTP, true concurrency, outbox race, full emulator integration). P3 explicitly owns every former P1a2-iii runtime concern: retry thresholds, worker delivery classification, full dispatch source tuple, worker acknowledgement behavior, terminalization predicates/evidence/codes, persisted terminal no-regression, and Auth/profile crash/read reconstruction. P2 retains only schema/audit/dispatch/enqueue foundations. A worker acknowledgement advances `OperationState.version` only in the same transaction as a real operation transition; enqueue acknowledgement never versions it. Because behavior and full proof share P3, same-slice backend corrections are allowed until final proof/freeze. After the last source mutation: aggregate emulator, TypeScript, independent phase-contract validation, candidate freeze. RDD remains disabled; surface explicit maintainer enable decision only after all gates.

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

- [x] P3.0 ENTRY/FAIL-FAST: verify `node --version` >= 22.6.0.
- [x] P3.1 RED: profile provenance match — UID + email + operationId + fingerprint + schema version + every normalized field must all match.
- [x] P3.2 GREEN: profile provenance passes.
- [x] P3.3 RED: profile provenance against Firestore emulator — match/missing/mismatch vectors.
- [x] P3.4 GREEN: profile provenance passes against Firestore emulator.
- [x] P3.5 RED: worker acquisition and delivery classification — validate the full persisted dispatch source tuple, acquire/take over lease, and classify duplicate/out-of-order/orphan/terminal deliveries; stale deliveries mark only the dispatch where legal and return 2xx without advancing operation state.
- [x] P3.6 GREEN: acquisition passes.
- [x] P3.7 RED: Auth preflight — mandatory UID + email reads before any create; foreign UID/email before intent -> `failed/already-exists`; no Auth mutation.
- [x] P3.8 GREEN: preflight passes.
- [x] P3.9 RED: Auth intent — one transaction flips `authAttempted=true`, persists `authAttempt.result=intent`, audit, version, deterministic `auth_create` dispatch, and worker acknowledgement using P2 schemas; the full source tuple and current-dispatch fence are verified.
- [x] P3.10 GREEN: intent commit passes.
- [x] P3.11 RED: Auth create boundary — CAS to `call_started`; call create once; exact return + UID/email reads + proof commit -> `profile_commit`; malformed/ambiguous/timeout/crash -> `manual_recovery` (no delete); definite no-effect -> back to `auth_preflight`.
- [x] P3.12 GREEN: Auth create boundary passes; no repeated ambiguous create; no automatic deletion.
- [x] P3.13 RED: profile_commit boundary — requires persisted Auth proof + mandatory matching UID/email reads; one transaction creates/verifies operation-matching profile + `completed/terminal` + `success.completed` audit + current ack; all-or-nothing.
- [x] P3.14 GREEN: profile_commit passes; conflicting profile -> `manual_recovery`; no deletion.
- [ ] P3.15 RED: crash/read reconstruction around every runtime effect — before/after enqueue delivery, Auth intent, Auth call, Auth return, each UID/email read, proof commit, profile/completion commit, and terminalization; no explicit crash/read event is added to the pure model.
- [ ] P3.16 GREEN: crash injection passes.








































































































### P3.15a — Approved Current-Effect Crash/Reconstruction Subslice

Terminalization remains deferred to P3.21+; P3.15 and P3.16 remain unchecked. This subslice covers only existing enqueue delivery, Auth intent/call/return, UID/email reads, proof commit, and profile/completion commit behavior. It adds no pure-model crash/read event and preserves P3.14 profile-conflict and bounded closed-transaction retry coverage.

- [x] P3.15a RED: author crash/restart/replay vectors for the implemented effects, including persisted `call_started` reconstruction and failed proof-commit retry, before changing production code. <!-- sdd-owner: implementation -->
- [x] P3.15a GREEN: reread both Auth indexes before terminally recording persisted `call_started` ambiguity; never repeat Auth create. <!-- sdd-owner: implementation -->
- [x] P3.15a TRIANGULATE: retain each-read ambiguity, existing enqueue replay, and profile completion rollback/retry vectors without weakening profile-conflict or closed-transaction coverage. <!-- sdd-owner: implementation -->
- [x] P3.15a REFACTOR: run focused worker/outbox tests and explicit/configured TypeScript checks; terminalization remains unimplemented. <!-- sdd-owner: implementation -->
- [x] P3.17 RED: true parallel emulator clients/workers — at least two actual parallel clients for one operation proving lease + CAS semantics (sequential mocks do not qualify). — Maintainer-authorized test-only characterization; existing production behavior passed the first REAL run, so no RED is claimed.
- [x] P3.18 GREEN: true parallel test passes. — Two independently initialized Firestore clients converged on one persisted operation under a shared pre-start barrier; independent emulator verification passed 67/67.
- [x] P3.19 RED: Functions emulator task endpoint — task worker exercised via authenticated HTTP POST to Functions emulator task endpoint with controlled TaskContext headers (no `emulators.tasks` config).
- [x] P3.20 GREEN: Functions emulator task endpoint test passes.
- [x] P3.21 RED: pending terminalization classifier — exact initial pending operation plus full dispatch/source tuple and null worker acknowledgement; write `failed/terminal`, `terminalCode=unavailable`, retry/failure evidence, failure audit, and current dispatch `workerAck=terminalized` atomically.
- [x] P3.22 GREEN: pending classifier passes.
- [x] P3.23 RED: pending predicate mismatch — do not infer safety; reread + reclassify as exact pending/active/terminal; second mismatch/CAS loss returns success with no mutation.
- [x] P3.24 GREEN: pending mismatch passes.
- [x] P3.25 RED: active with exact current owner + live lease — require complete active CAS tuple; safe phase -> `failed/unavailable`; otherwise -> `manual_recovery/internal`; evidence + audit + owner/lease clear + current ack commit together.
- [x] P3.26 GREEN: active exact-owner passes.
- [x] P3.27 RED: active with another owner's unexpired lease — no steal, no mutation; CAS loss returns success.
- [x] P3.28 GREEN: active foreign-owner passes.
- [x] P3.29 RED: active with expired lease — first transaction requires full observed expired tuple, increments generation + version, installs new owner token + live lease; same invocation applies complete active terminalization guard using the exact new tuple.
- [x] P3.30 GREEN: expired-lease takeover passes.
- [x] P3.31 RED: terminal operation — return success without operation mutation or new audit; existing dispatch acknowledgement is idempotent in dispatch persistence and never causes a standalone `OperationState.version` increment.
- [x] P3.32 GREEN: terminal idempotency passes.
- [x] P3.33 RED: 12/8 retry protocol — `retryCount` 0–7 may work; 8–11 terminalize only; non-integer/negative/>11 fail-closed; pre-handler 5xx semantics; no fictional post-exhaustion callback; permanent durable-store outage -> alert + runbook, not silent success.
- [x] P3.34 GREEN: 12/8 protocol passes.
- [x] P3.35 RED: reserved attempts 8, 9, 10, 11 repeat only guarded terminalization paths; failed terminalization transaction throws so next reserved attempt retries; committed terminal returns success.
- [x] P3.36 GREEN: reserved-attempt idempotency passes.
- [x] P3.37 RED: status authorization — unauthenticated -> `unauthenticated`; non-admin -> `permission-denied`; unknown operationId -> `not-found`; optional fingerprint mismatch -> `already-exists`; no mutation on either path.
- [x] P3.38 GREEN: status authorization passes.
- [x] P3.39 RED: status DTO projection — each status returns only its safe fields; no raw email/owner/lease/generation/version/evidence/audit identity.
- [x] P3.40 GREEN: DTO projection passes.
- [x] P3.41 RED: completed integrity — re-read both Auth indexes + full provenance-tagged profile; failure or inconsistency returns stable integrity error without changing terminal operation or generating a link; deduplicated integrity audit.
- [x] P3.42 GREEN: completed integrity passes.
- [x] P3.43 RED: fresh reset link — Auth `generatePasswordResetLink` called only after integrity passes; link returned; link never stored, logged, audited, or emailed; transient link failure returns stable retryable error leaving `completed` unchanged.
- [x] P3.44 GREEN: reset link passes.
### P3.44a–P3.44e — Corrected runtime-composition prerequisites

This corrected amendment is placed after the already accepted P3.44 and immediately before P3.45. The first child targets the current cumulative P3.43/P3.44 candidate; each later child targets the immediately preceding child. Existing accepted P3.17–P3.44 behavior is consumed, not re-authored. No child changes P3.15/P3.16 ownership, P3.47/P3.48 race proof, P3.49+ matrices, or P3.55 finalization.

#### P3.44a — Submission callable + Firestore persistence composition

**Depends on / branch:** current cumulative accepted P3.43/P3.44 candidate; `slice/p3-44a-submission-composition` branches from that candidate.

**Exact candidate edit paths:** `functions/src/index.ts`; `functions/src/provisioning/submit.ts`; `functions/src/provisioning/boundaries.ts`; `functions/test/provisioning/submit.test.ts`; `openspec/changes/prepare-public-portfolio-repository/tasks.md`; `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`. No other paths.

- [x] P3.44a.1 RED: extend `submit.test.ts` before composition with callable endpoint/App Check/auth wiring, canonical pending response, deterministic initial dispatch, same-identity replay, fingerprint conflict, and atomic Firestore persistence assertions; retain accepted P3.13/P3.14 domain tests as regressions rather than new RED.
- [x] P3.44a.2 GREEN: compose `submitProvisioning` with `persistInitialSubmission` and the existing Firestore transaction adapter; create operation and initial dispatch atomically, without Auth, queue, profile, or client re-drive effects.
- [x] P3.44a.3 TRIANGULATE: run the focused test, endpoint emulator test, explicit source+test TypeScript, source-only `npx tsc --noEmit`, and accepted submission/schema regressions.
    - [x] P3.44a.4 REFACTOR: retain the accepted submission/schema coverage while keeping callable composition limited to persistence and initial dispatch.

**Exact commands:** RED `cd functions && node --experimental-strip-types test/provisioning/submit.test.ts`; RED typecheck `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/index.ts src/provisioning/submit.ts src/provisioning/boundaries.ts src/provisioning/normalize.ts src/provisioning/schemas.ts test/provisioning/submit.test.ts`; GREEN repeats both, then `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/submit.test.ts"` and `cd functions && npx tsc --noEmit`.

**Rollback boundary:** revert only P3.44a paths and bookkeeping to the current accepted P3.44 candidate; no later child exists in this boundary. **Forecast:** `index.ts` 45–60 + `submit.ts`/`boundaries.ts` 35–50 + `submit.test.ts` 90–120 + bookkeeping 15–20 = **185–250** changed lines; warning 320, STOP 380, hard max 399.

#### P3.44b — Minimal outbox trigger/repair + enqueue/ack composition

**Depends on / branch:** accepted P3.44a; `slice/p3-44b-outbox-composition` branches from P3.44a.

**Exact candidate edit paths:** `functions/src/index.ts`; `functions/src/provisioning/enqueue.ts`; `functions/src/provisioning/outbox.ts`; `functions/src/provisioning/outbox_repair.ts`; `functions/test/provisioning/enqueue.test.ts`; `functions/test/provisioning/outbox.test.ts`; `functions/test/provisioning/outbox_repair.test.ts`; `openspec/changes/prepare-public-portfolio-repository/tasks.md`; `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`. No worker/status or configuration paths.

- [x] P3.44b.1 RED: add only the minimum created-dispatch happy-path vectors for shared enqueue, guarded `enqueued` acknowledgement, stale-record selection, and trigger/scheduler endpoint wiring before composition. Do not add race, duplicate, crash, or `ALREADY_EXISTS` matrix vectors here.
- [x] P3.44b.2 GREEN: compose the retry-enabled created trigger and scheduled repair with the existing enqueue and acknowledgement seams, preserving deterministic identity and dispatch-only acknowledgement.
- [x] P3.44b.3 TRIANGULATE: run focused enqueue/outbox tests, Firestore endpoint tests, explicit/source-only TypeScript, and accepted P2 outbox regressions. P3.47/P3.48 retain the complete trigger+sweeper race, duplicate/out-of-order, crash-before/after-enqueue, and `ALREADY_EXISTS` matrix unchanged.
    - [x] P3.44b.4 REFACTOR: preserve the shared adapter and dispatch-only acknowledgement without widening into worker or status behavior.

**Exact commands:** RED `cd functions && node --experimental-strip-types test/provisioning/enqueue.test.ts && node --experimental-strip-types test/provisioning/outbox.test.ts`; RED typecheck `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/index.ts src/provisioning/enqueue.ts src/provisioning/outbox.ts src/provisioning/outbox_repair.ts src/provisioning/schemas.ts src/provisioning/audit.ts test/provisioning/enqueue.test.ts test/provisioning/outbox.test.ts test/provisioning/outbox_repair.test.ts`; GREEN repeats both, then `cd functions && npx firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox.test.ts && node --experimental-strip-types test/provisioning/outbox_repair.test.ts"` and `cd functions && npx tsc --noEmit`. The repair harness remains emulator-only because it requires `FIRESTORE_EMULATOR_HOST`.

**Rollback boundary:** revert only P3.44b paths and bookkeeping to accepted P3.44a; P3.44c–P3.44e are future dependents and are not claimed intact. **Forecast:** `index.ts` 25–40 + enqueue/outbox/repair 25–40 + three focused tests 70–100 + bookkeeping 15–20 = **135–200** changed lines; warning 320, STOP 380, hard max 399.

#### P3.44c — Worker runtime phase routing + Firebase Auth composition

**Depends on / branch:** accepted P3.44b and already accepted focused P3.15a/P3.13–P3.14 regressions; `slice/p3-44c-worker-composition` branches from P3.44b.

**Exact candidate edit paths:** `functions/src/index.ts`; `functions/src/provisioning/worker.ts`; `functions/src/provisioning/boundaries.ts`; `functions/test/provisioning/worker_auth.test.ts`; `openspec/changes/prepare-public-portfolio-repository/tasks.md`; `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`. No terminalization, retry, concurrency, status, or broad crash-matrix paths.

- [x] P3.44c.1 RED: extend `worker_auth.test.ts` before composition only for task endpoint dispatch to the already implemented phase handlers, Firebase Auth adapter construction, and the minimum preflight/intent routing smoke path; accepted worker/domain tests remain regressions. Do not re-author P3.15/P3.16 crash vectors or P3.49+ retry/Auth/concurrency matrices.
- [x] P3.44c.2 GREEN: compose `onTaskDispatched` phase routing and Firebase Auth reader/creator injection for the minimum runtime path, preserving backend-owned liveness, persisted intent-before-effect, and no Auth deletion.
- [x] P3.44c.3 TRIANGULATE: run focused worker endpoint tests through Firestore/Auth/Functions emulators, explicit/source-only TypeScript, and already accepted worker regressions only.
    - [x] P3.44c.4 REFACTOR: retain backend-owned liveness, persisted intent-before-effect, and no-deletion boundaries while removing only composition duplication.

**Exact commands:** RED `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`; RED typecheck `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/index.ts src/provisioning/worker.ts src/provisioning/boundaries.ts test/provisioning/worker_auth.test.ts`; GREEN repeats both, then `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/worker_auth.test.ts"` and `cd functions && npx tsc --noEmit`.

**Rollback boundary:** revert only P3.44c paths and bookkeeping to accepted P3.44b; P3.44d/P3.44e are future dependents and are not claimed intact. **Forecast:** `worker.ts` 45–65 + `boundaries.ts`/`index.ts` 25–40 + `worker_auth.test.ts` 90–125 + bookkeeping 15–20 = **175–250** changed lines; warning 320, STOP 380, hard max 399.

#### P3.44d — Status callable + safe DTO composition

**Depends on / branch:** accepted P3.44c and accepted P3.37–P3.40 domain tests; `slice/p3-44d-status-composition` branches from P3.44c.

**Exact candidate edit paths:** `functions/src/index.ts`; `functions/src/provisioning/status.ts`; `functions/src/provisioning/boundaries.ts`; `functions/test/provisioning/status.test.ts`; `openspec/changes/prepare-public-portfolio-repository/tasks.md`; `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`.

- [x] P3.44d.1 RED: extend `status.test.ts` before composition only for missing callable/Firestore/Auth adapters, endpoint authorization wiring, and emulator invocation; retain accepted P3.37–P3.40 authorization and DTO cases as regressions, not new RED behavior.
- [x] P3.44d.2 GREEN: compose `getProvisioningStatus` with the existing authorization and safe DTO projection; expose no new fields and issue no reset link in this child.
- [x] P3.44d.3 TRIANGULATE: run focused endpoint tests in Firestore/Auth/Functions emulators plus explicit/source-only TypeScript and accepted status-domain regressions.
    - [x] P3.44d.4 REFACTOR: retain the safe DTO and authorization projection without adding reset-link or integrity behavior.

**Exact commands:** RED `cd functions && node --experimental-strip-types test/provisioning/status.test.ts`; RED typecheck `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/index.ts src/provisioning/status.ts src/provisioning/boundaries.ts src/provisioning/dto.ts test/provisioning/status.test.ts`; GREEN repeats both, then `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/status.test.ts"` and `cd functions && npx tsc --noEmit`.

**Rollback boundary:** revert only P3.44d paths and bookkeeping to accepted P3.44c; P3.44e is a future dependent and is not claimed intact. **Forecast:** `status.ts` 35–50 + `boundaries.ts`/`index.ts` 25–40 + `status.test.ts` 90–125 + bookkeeping 15–20 = **165–235** changed lines; warning 320, STOP 380, hard max 399.

#### P3.44e — Completed integrity + immediate fresh reset-link composition

**Depends on / branch:** accepted P3.44d, frozen `profile.ts`, and accepted P3.41–P3.44 domain tests; `slice/p3-44e-integrity-reset-link` branches from P3.44d.

**Exact candidate edit paths:** `functions/src/index.ts`; `functions/src/provisioning/status.ts`; `functions/src/provisioning/boundaries.ts`; `functions/test/provisioning/completed_integrity.test.ts`; `openspec/changes/prepare-public-portfolio-repository/tasks.md`; `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`.

- [x] P3.44e.1 RED: extend `completed_integrity.test.ts` before composition only for callable/emulator adapter invocation around the already accepted integrity and fresh-link domain functions; retain P3.41–P3.44 tests as regressions, not new domain RED.
- [x] P3.44e.2 GREEN: compose completed-resource integrity reads and Firebase Auth reset-link generation into the status endpoint; generate an immediate fresh link only after integrity passes, never store/log/audit/email it, and preserve completed state.
- [x] P3.44e.3 TRIANGULATE: run focused Firestore/Auth/Functions emulator endpoint tests, explicit/source-only TypeScript, and accepted integrity/reset-link regressions.
    - [x] P3.44e.4 REFACTOR: preserve immediate fresh-link issuance only after integrity success and keep the link out of persistence, logs, audits, and email.

**Exact commands:** RED `cd functions && node --experimental-strip-types test/provisioning/completed_integrity.test.ts`; RED typecheck `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/index.ts src/provisioning/status.ts src/provisioning/boundaries.ts src/provisioning/profile.ts test/provisioning/completed_integrity.test.ts`; GREEN repeats both, then `cd functions && npx firebase emulators:exec --only firestore,auth,functions "node --experimental-strip-types test/provisioning/completed_integrity.test.ts"` and `cd functions && npx tsc --noEmit`.

**Rollback boundary:** revert only P3.44e paths and bookkeeping to accepted P3.44d; no future dependent child exists in this boundary. **Forecast:** `status.ts` 35–50 + `boundaries.ts`/`index.ts` 25–40 + `completed_integrity.test.ts` 100–140 + bookkeeping 15–20 = **175–250** changed lines; warning 320, STOP 380, hard max 399.

#### Corrected P3.44a–P3.44e arithmetic and final boundary

| Slice | Forecast (additions + deletions) |
|:---|---:|
| P3.44a submission | 185–250 |
| P3.44b minimal outbox | 135–200 |
| P3.44c worker routing/Auth composition | 175–250 |
| P3.44d status callable/DTO | 165–235 |
| P3.44e integrity/fresh reset link | 175–250 |
| **Total five-child prerequisite segment** | **835–1,185** |

Arithmetic: `185+135+175+165+175 = 835`; `250+200+250+235+250 = 1,185`. Every child is below the hard 399-line maximum, with no borrowing or `size:exception`. P3.45/P3.46 are final for the happy path: submission through completed status, a fresh status-issued reset link, and no client-driven re-drive. P3.47/P3.48 retain the complete outbox race matrix; P3.49+ retain their existing retry/Auth/concurrency ownership. P3.55 remains the final export/full-suite refactor; these prerequisite children may compose only exports required for their own executable behavior.

- [x] P3.45 RED: full emulator flow — happy-path submission through to completed status with fresh reset link; no client-driven re-drive.
- [x] P3.46 GREEN: full emulator flow passes.

P3.45/P3.46 prior candidate is verification-rejected because it bypassed the durable-outbox acknowledgement gate; these checkboxes are retained only after the corrected emulator evidence proves every worker delivery follows a guarded trigger acknowledgement.
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

### P3 Forecast (historical baseline; runtime-composition rows superseded by P3.44a–P3.44e)

The former P1a2-iii executable reducer forecast is removed, not copied. The prior aggregate P3 component table is historical context only for the runtime-composition portion: the maintained execution forecast is the five-child P3.44a–P3.44e table inserted after accepted P3.44. The five-child arithmetic is direct and non-additive with the superseded worker/status rows; terminalization and final-proof tasks retain their existing ownership and ordering.

| Component | Expected lines |
|---|---:|
| `profile.ts` + `profile.test.ts` provenance contract | 120–165 |
| `worker.ts` + `boundaries.ts` dispatch/source tuple, acquisition, Auth boundary, and worker acknowledgement behavior | 260–330 |
| `terminalization.ts` + pending/active terminalization tests | 280–350 |
| Auth dual-read/crash reconstruction and retry-threshold tests | 240–300 |
| `status.ts` + status/integrity/reset-link tests | 180–230 |
| full integration/concurrency/outbox/retry proof and P3 bookkeeping | 470–590 |
| **Total P3** | **1,550–1,965** |

Component sum is verified: low `120+260+280+240+180+470 = 1,550`; high `165+330+350+300+230+590 = 1,965`. This remains below the existing authorized P3 absolute max of 2,000; no new size exception, borrowing, or hidden transfer cost is used. Reforecast/STOP at 1,700; absolute max 2,000. If the measured transferred runtime scope cannot fit under 2,000, stop and return `blocked` with the exact maintainer decision needed.

## CURRENT / APPROVED FOR APPLY — P3 Ordinary Takeover Unit

This planning correction supersedes the proposed T1→T2→T3 chain without changing any P3 checkbox. P3.5/P3.6 remain unchecked mixed acquisition/classification work. P3.29/P3.30 remain separately owned reserved-attempt takeover-plus-terminalization requirements and receive no completion authority from this unit. The maintainer approved implementation of this ordinary-takeover unit after accepting the measured forecast below.

**Cohesive boundary.** The one current unit implements the approved normal expired-current takeover behavior: full source and eight-field operation predicate; generation derived from the latest observed operation (`operation.generation+1`); deterministic owner/live lease; source dispatch unchanged/current with `workerAck:null`; no next dispatch; audited atomic ownership transition; and exact reread before later ordinary work. It includes strict-fake proof plus minimal REAL Firestore proof for one winner, replay/timestamp preservation, and rollback/atomicity. It excludes Auth/profile behavior and all reserved-attempt terminalization.

**Required proof.** RED covers source identity, each CAS field, expired/live lease edges, and the minimal REAL conflict/convergence vector before production changes. GREEN implements the strict-fake and REAL-backed transaction path as one acceptance unit. TRIANGULATE proves repeated takeover of a retained current source, replay timestamp preservation, one-winner convergence, loser/no-write behavior, and rollback on audit or transaction conflict. REFACTOR runs focused type/unit/emulator checks without reducing coverage.

**Measured gate accepted.** The current-byte pre-edit forecast is: `worker.ts` 70–86 additions; `worker_auth.test.ts` 156–186 additions; task bookkeeping 3–5 additions; apply-progress bookkeeping 16–22 additions; explicit review margin 38–46; no deletions expected; total 283–345 changed lines. This is a warning-range forecast but remains below STOP/reforecast 380 and hard maximum 399. The maintainer approved apply with warning 320, STOP 380, hard 399, no size exception, borrowing, or coverage reduction. REAL proof is not a standalone preventive split; split/reforecast only if the cohesive unit cannot remain below STOP 380 and hard 399.

**Reserved-attempt separation.** P3.29/P3.30 may later reuse the accepted takeover primitive, but they must not couple to this unit. Their existing terminalization, audit, source-acknowledgement, and retry semantics remain unchanged.

## Superseding P3-B Planning Amendment — Blocked, Provisional Chain Only

This documentation-only amendment supersedes the stale P3-B planning basis without changing any P3 checkbox, ID, order, code, config, native state, or authority record. P3-B remains blocked. Its provisional chain is **B1 acquisition/classification (P3.5–P3.6) → B2 preflight/intent (P3.7–P3.10)**, both feature-branch-chain slices from the frozen P2 handoff; no size exception or fresh budget is granted.

### Honest workload correction and accounting basis

- The original conversational estimate was **180–240 lines**; it was inaccurate and need not have appeared in this artifact.
- The full corrected candidate forecast is **505–650 lines**, a different basis from the **B1 incremental correction forecast of 346–439 lines**. Neither figure is completed work.
- The historical native observation was **232 charged with 168 remaining under 400**. That is not a caller-owned ledger and must not be presented as B1 budget or as proof that B1 fits 400.
- B1 incremental correction: `worker.ts 125–155 + boundaries.ts 28–40 + test 175–220 + tasks 4 + progress 14–20 = 346–439`; its endpoint against the historical observation is **578–671**. These are forecasts only.
- One honest slicing pass may narrow B1/B2 only along independently testable boundaries, counting deletion, tests, and documentation. No code-golf, deletion of proof, or iterative budget manipulation is permitted. If no cohesive subunit fits, remain blocked and request a maintainer decision.

### Candidate reuse failure and frozen validation contract

The reusable worker/boundary skeleton and existing Auth test are useful, but the tests are insufficient, not useless. The failed candidate must not be reused as completion or GREEN evidence. Known missing contracts are: TypeScript parameter properties incompatible with `node --experimental-strip-types`; deterministic incoming ID plus the complete dispatch source tuple; legal stale-dispatch acknowledgement and P2-validated/deduplicated audit; takeover reread and fencing; foreign identity classification as `failed/already-exists`; and read spies plus transaction atomicity vectors. A genuine historical missing-module RED is recorded, but no GREEN is accepted from it; configured TypeScript passing alone is insufficient.

### B1 acquisition/classification — P3.5–P3.6

- **Exact candidate files**: `functions/src/provisioning/worker.ts`, `functions/src/provisioning/boundaries.ts`, and `functions/test/provisioning/worker_auth.test.ts`; no new path is implied by this amendment.
- **Dependency/start**: accepted P2 schemas, deterministic IDs, enqueue/dispatch identity, audit dedup, and P1a2/P1b contracts; start only after a fresh native eligibility check and a new genuine RED.
- **Acceptance**: incoming dispatch ID is resolved deterministically; operation and dispatch full tuple (`operationId,fingerprint,boundary,generation,sourceVersion`) and `currentDispatchId` are checked; duplicate, out-of-order, orphan, terminal, and malformed deliveries are classified fail-closed; legal stale acknowledgement changes only dispatch acknowledgement fields and returns 2xx; acquisition uses exact initial fields; takeover requires full observed tuple, expired lease, generation `+1`, new fence, authoritative reread, and no external effect before the reread; transaction writes are atomic and P2 audit validation/dedup is used.
- **Required RED/GREEN proof**: direct `node --experimental-strip-types` tests plus explicit test-file `npx tsc`; Firestore/Auth/Functions emulator vectors with read spies, stale/no-mutation assertions, takeover-reread fences, and atomicity failure injection. The RED must precede source correction; no emulator or test is run in this planning phase.

### B2 preflight/intent — P3.7–P3.10

- **Exact candidate files**: the same three files, chained from accepted B1; B2 may not widen into Auth create, profile commit, terminalization, status, or retry work.
- **Acceptance**: mandatory UID and email reads occur before any create; read errors fail closed; a foreign UID/email produces `failed/already-exists` without Auth mutation; both absent reads permit exactly one atomic intent transaction with `authAttempted=true`, `intent`, deterministic `auth_create` dispatch, P2-validated/deduplicated audit, version increment, and current worker acknowledgement; incoming/full-tuple/fence checks and transaction atomicity remain mandatory.
- **Required RED/GREEN proof**: direct strip-types execution, explicit source+test TypeScript, and Firestore/Auth/Functions emulator tests with read spies, foreign identity controls, both-absent controls, duplicate/replay controls, and injected atomicity failures. `functions/package.json`, lockfile, and `functions/tsconfig.json` are frozen; TypeScript success alone is not runtime or contract proof.

### Authority, rescope, and validation preservation

Native rescope zero-drift means unchanged since settlement, **not zero accumulated lines**; narrowing carries its existing budgets. No supported widening or budget reset is authorized here, no tokens are stored, and docs must not be manipulated to enable a reset. This amendment can change candidate identity/post-settlement drift, so fresh native eligibility must be checked before future execution. Existing P3.5–P3.10 acceptance tasks and checks remain verbatim and unchecked; this amendment records planning boundaries only.

---

## P3-B Successor Narrowing Pass — P3-B.1 Delivery Identity Gate

**Planning status:** sound as a bounded successor; documentation only. This does not acquire an attempt, implement behavior, settle P3-B, or change P3.5–P3.10. It supersedes only the earlier reset/eligibility wording: the supplied native state is last-observed readiness at `next_action=begin`, not a fresh admission or semantic proof, while this task remains implementation-blocked because no apply is authorized. The supplied remediation revision is `sha256:01a82d5f9eb50f0f2cbb4ad310876fcaa598f22b9a1b92993c30b9e18b63062b`, with `objective=null`, current `0`, attempts `0`, lines `0`, and lifetime `5/794`.

### Smallest independently testable boundary

- **Unit:** deterministic delivery identity classification before any acquisition, lease mutation, Auth read, acknowledgement, or audit write.
- **Write paths (exact):** `functions/src/provisioning/worker.ts` and `functions/test/provisioning/worker_auth.test.ts`. The rewritten worker and test import no symbol from `functions/src/provisioning/boundaries.ts`; that file remains read-only and its preserved hash is historical evidence. No new path, manifest, config, emulator fixture, or generated file is allowed.
- **Current read evidence:** the unchanged candidate files are 101 lines (`worker.ts`), 58 lines (`boundaries.ts`), and 73 lines (`worker_auth.test.ts`), 232 lines total—not an assumed 310-ish source basis. These are source lengths, not changed-line budget.
- **Isolation required:** remove the currently reachable coupled acquisition/Auth-preflight path from the unit's callable export and retain only a classification surface. This explicitly counts deletion/isolation of premature unverified behavior; it must not remain reachable as if accepted.
- **Accepted behavior:** given `request.dispatchId` plus persisted operation/dispatch records, compare the request ID to persisted `dispatch.dispatchId`; the request has no task ID. Persisted `taskId === dispatchId` is enforced by the dispatch validator. Derive the expected ID with `deriveDispatchId(operationId, boundary, generation, sourceVersion)`, then compare fingerprint equality and `currentDispatchId` separately. Classify `eligible`, `duplicate`, `orphan`, `terminal`, `mismatch`, or `malformed` fail-closed; exact pending-initial and active-current tuples are the only eligible results. The classifier performs no external effect and returns no success claim for acquisition.
- **Adversarial vectors:** each source-tuple field changed independently; wrong `request.dispatchId`; persisted `taskId !== dispatchId`; deterministic-ID mismatch; pending nonzero generation/version or non-null owner/lease; active phase/boundary, generation, source-version, current-dispatch, or fingerprint mismatch; duplicate worker acknowledgement; terminal operation; missing operation; missing dispatch; invalid/extra persisted records; top-level accessor descriptors; and reflective/proxy exceptions that are caught and classified fail-closed. Add a descriptor-safe exact persisted-envelope extractor before `isValidState`: `isValidOperation` covers only initial pending and `isValidState` excludes the envelope, so active and pending envelope fields must be validated explicitly. Accessors are rejected without invoking getters; do not promise arbitrary Proxy traps never run. Assert no Auth call, persistence write, version/generation change, or stale acknowledgement from this unit.
- **Dependencies:** accepted P2 schemas, deterministic ID contract, frozen model/status-phase guards, P1a2/P1b lifecycle contract, and a fresh native eligibility check immediately before any future implementation. The historical failed evidence `sha256:1770af2293aa772bdfe644120e875fcdd18a2f73ea2e693c163c736615d30a54` remains an obligation, not GREEN evidence.
- **RED (not run):** `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`; then `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/worker.ts test/provisioning/worker_auth.test.ts`. New classifier and envelope-validator vectors must fail before the source correction.
- **GREEN (not run):** rerun both commands after the worker/test correction; no emulator or package install is part of this unit. Emulator/Auth/Functions persistence proof remains deferred.
- **Non-goals:** no Firestore transaction, worker acknowledgement, P2 audit creation/deduplication, acquisition, lease/takeover, Auth UID/email reads, `auth_intent`, Auth create, profile commit, terminalization, retry threshold, status callable, P3.5–P3.10 completion, checkbox change, native mutation, or reset.
- **Downstream ownership:** the next P3-B slice owns persistence-backed stale acknowledgement plus validated/deduplicated stale audit, transaction atomicity/read spies, exact acquisition, takeover reread/fencing, and their P3.5–P3.6 acceptance. B2 remains the chained owner of P3.7–P3.10 preflight/intent and may not claim this classifier as full B1 proof.

### First-unit changed-line forecast (local, not the historical B1 estimate)

| File | Additions | Deletions | Replacements shown (counted as add+delete) | Changed-line range |
|---|---:|---:|---:|---:|
| `functions/src/provisioning/worker.ts` | 60–74 | 72–88 | 16–22 | 132–162 |
| `functions/test/provisioning/worker_auth.test.ts` | 86–106 | 39–57 | 12–18 | 125–163 |
| `tasks.md` bookkeeping | 6–10 | 0 | 0 | 6–10 |
| `apply-progress.md` bookkeeping | 10–16 | 0 | 0 | 10–16 |
| **Total** | **162–206** | **111–145** | **28–40** | **273–351** |

The estimate includes the descriptor-safe envelope validator, accessor/proxy-exception tests, test vectors, removal/isolation, import/extraction overhead, and bookkeeping; replacement rows are descriptive and not added again. Local warning is **320**, STOP/reforecast is **380**, and the hard maximum is **399**; no size exception or borrowing is authorized. This unit is independently rollbackable by reverting the two code/test paths and its two bookkeeping records, without touching P2 or later P3 behavior.

## P3-B.2 — Persist Stale Delivery Acknowledgement + P2-Deduplicated Audit (Superseded Planning Record)

> Superseded by corrective P3-B.2a planning below. The prior 213–317 forecast and full persistence boundary remain retained evidence only; omitted boundary plumbing, legal stale matrix, rollback/concurrency, and emulator convergence are explicitly downstream.

**Order:** P3-B.1 classifier → this persistence slice → later P3.5–P3.6 acquisition/takeover; P3.7–P3.10 and all later P3 tasks remain unchecked. This is P3-B.2, not historical P1 B-1a.

**Chosen boundary:** persist only an out-of-order/mismatched delivery when the incoming `dispatchId` exactly matches the transaction-reread dispatch identity and both persisted envelopes validate. The transaction rereads operation and dispatch, validates the complete dispatch source tuple (`operationId,fingerprint,boundary,generation,sourceVersion`) plus `dispatchId/taskId`, operation identity/status/phase/generation/version/currentDispatchId, and re-runs the classifier before writing. It never derives a comparison from a stale caller copy.

**Atomic behavior:** use `isValidDispatchUpdate` for the sole legal `workerAck:null → stale` update; create or read the deterministic `progress/stale_delivery` audit through P2 `createAuditEvent`/`deduplicateAudit` and `deriveAuditEventId`; commit dispatch acknowledgement and audit together. Operation data, `OperationState.version`, leases, Auth, and profiles are never written. A matching replay rereads and deduplicates without rewriting provenance; an audit identity mismatch, invalid record, missing record, wrong request ID, orphan, malformed/accessor/proxy failure, or transaction failure commits nothing.

**Exact paths:** modify only `functions/src/provisioning/worker.ts`, `functions/src/provisioning/boundaries.ts` (add transaction audit reread), `functions/test/provisioning/worker_auth.test.ts`, and these two SDD records. Reuse the existing Firestore adapter shape and `outbox_repair.test.ts` emulator setup; no new path, manifest, config, or generated file.

**Acceptance vectors:** independent mutation of every source-tuple/identity field; wrong incoming ID and `taskId`; duplicate/terminal/orphan/malformed records; accessor and reflective failures; first stale acknowledgement; replay deduplication; conflicting existing audit; dispatch-only mutation and unchanged operation/version; injected audit/write failure rollback; two parallel Firestore transactions yielding one stale acknowledgement and one audit document; no acquisition, takeover, Auth read, or external effect.

**Strict TDD tasks:**
- [ ] RED: extend `functions/test/provisioning/worker_auth.test.ts` with stale-ack/audit, full-reread, rollback, and Firestore concurrency vectors before changing `worker.ts` or `boundaries.ts`. <!-- sdd-owner: implementation -->
- [ ] GREEN: implement the transaction reread, P2 audit validation/deduplication, and dispatch-only stale acknowledgement in `functions/src/provisioning/worker.ts` and `functions/src/provisioning/boundaries.ts`. <!-- sdd-owner: implementation -->
- [ ] TRIANGULATE: run `functions/test/provisioning/worker_auth.test.ts` against the pure fake and Firestore emulator, proving atomicity, one audit, unchanged operation/version, and no external-effect calls. <!-- sdd-owner: implementation -->
- [ ] REFACTOR: run inherited `functions/test/provisioning/{schemas,audit,outbox}.test.ts`, the worker test, and TypeScript checks; preserve all P3.5–P3.10 checkboxes as unchecked. <!-- sdd-owner: implementation -->

**Commands/dependencies:** require Node 24.x (`node --version`, minimum 22.6.0) and Java 21 (`java -version`) before every runtime/emulator command. RED is `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`, followed by explicit `npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/worker.ts src/provisioning/boundaries.ts test/provisioning/worker_auth.test.ts`; GREEN repeats both, adds `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"`, then `cd functions && npx tsc --noEmit`. No install or Functions/Auth emulator is needed.

**Forecast and boundary:**

| Path/category | Additions | Deletions | Changed-line range |
|---|---:|---:|---:|
| `worker.ts` | 62–82 | 8–18 | 70–100 |
| `boundaries.ts` | 10–18 | 0–4 | 10–22 |
| `worker_auth.test.ts` | 102–138 | 12–24 | 114–162 |
| `tasks.md` | 9–13 | 0–2 | 9–15 |
| `apply-progress.md` | 10–16 | 0–2 | 10–18 |
| New/extracted paths | 0 | 0 | 0 |
| **Total** | **193–267** | **20–50** | **213–317** |

Warning is 320; STOP/reforecast is 380; hard maximum is 399. Rollback reverts only the three code/test paths and these planning records; P2 remains frozen. The next unit after acceptance owns exact acquisition/takeover, not this slice.

## P3-B.2a — Safe Stale Delivery Eligibility Predicate (Planning Only)

**Authorized clarification:** one classifier, `classifyProvisioningDelivery`, must implement the design's complete `eligible | stale_eligible | orphan | duplicate | terminal | mismatch | malformed | corrupt` vocabulary and precedence; no helper may retain a competing stale predicate. Its pure output is never write authority. P3-B.2a remains classification-only: no acknowledgement, audit, acquisition, lease, Auth, or emulator behavior.

**Exact files:** `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `tasks.md`, and `apply-progress.md`. No `boundaries.ts`, new file, manifest, config, or generated output. The predicate is a direct consumer for the downstream persistence unit, not a syntax-only abstraction.

**Executable semantics:** implement the exact decision table in `design.md`. `malformed` remains structural/schema failure; only dispatch self-identity contradictions are `corrupt`; cross-record/delivery and impossible, future, boundary, or same-version relations are `mismatch`. Pending has no legal stale row. For active legal earlier relations `(dg=og && sv<ov) || (dg<og && sv<ov)` plus timestamp coherence, the dispatch is `eligible` when it remains the phase-matching `currentDispatchId` (same-boundary mutation/takeover retention), otherwise `stale_eligible`; exact current is also `eligible`. Orphan, duplicate, and terminal retain their names and no-write behavior.

**Trust gate:** add the adapter-owned document-reference/snapshot carrier needed to compare delivery ID, Firestore document ID, `dispatchId`, `taskId`, and deterministic identity, but expose no new unauthenticated caller contract. Before persistence planning proceeds, prove every reachable dispatch creation uses the backend atomic/create-if-absent paths and Firestore clients cannot write provisioning operation/dispatch collections. Current `functions/src/index.ts` runtime stubs mean that production premise is not yet proven.

**Legal matrix:** independently vary `operationId`, `fingerprint`, `boundary`, `generation`, `sourceVersion`, `currentDispatchId`, `taskId`, request ID, worker acknowledgement, pending initial fields, active lease/owner shape, terminal status, missing records, exact extra/accessor fields, and reflective failures. Every corrupt or no-write row proves input/reference retention and no persistence/Auth call; legal stale rows prove only classification, never an acknowledgement claim.

**Strict TDD and regression commands:** require Node 24.x (`cd functions && node --version`, minimum 22.6.0). RED/GREEN use `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`, then the explicit `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/worker.ts test/provisioning/worker_auth.test.ts`; GREEN also runs configured `cd functions && npx tsc --noEmit`. P2 regressions are exactly `cd functions && node --experimental-strip-types test/provisioning/schemas.test.ts`, `cd functions && node --experimental-strip-types test/provisioning/audit.test.ts`, and `cd functions && node --experimental-strip-types test/provisioning/outbox.test.ts`. These are pure/strict-fake checks; no emulator, Java, install, store/Auth write, or native operation is needed here.

**Next bounded unit — P3-B.2a-1 (implementation-ready for approved feature-branch-chain routing):** trusted adapter-owned snapshot/document-reference envelope plus the single classifier's structural identity gate. Interim eligibility is ONLY exact pending-initial or exact active-current. Retained historical current temporal relations and all temporal stale relations belong to P3-B.2a-2; every noncurrent/older temporal candidate is `mismatch`, and `stale_eligible` is unreachable until P3-B.2a-2. It covers valid identity, document-reference mismatch, request/delivery mismatch, `taskId` self-conflict as `corrupt`, deterministic self-conflict as `corrupt`, operation/fingerprint cross-record mismatch, terminal/duplicate/orphan precedence, exact extra/accessor/proxy failures, purity, and absence of competing predicate exports.

**Scoped P2 telemetry correction (user-authorized):** This frozen-boundary exception permits only the preexisting audit-telemetry correction in `functions/src/provisioning/outbox_repair.ts` and `functions/test/provisioning/outbox_repair.test.ts`: replace the audit-scanner-bypassing `console.error` with an injected safe application-log sink. Preserve all unrelated P2 history, checks, and scanner strength; this is not a design-wide override.

**TDD tasks:**
- [x] P3-B.2a-1.1 RED: add document-reference, valid/corrupt identity, precedence, reflection, purity, and no-write vectors in `functions/test/provisioning/worker_auth.test.ts` before changing `functions/src/provisioning/worker.ts`. <!-- sdd-owner: implementation -->
- [x] P3-B.2a-1.2 GREEN: add the adapter-owned carrier and extend only `classifyProvisioningDelivery` in `functions/src/provisioning/worker.ts`; keep `boundaries.ts` unchanged and unimported, with only exact pending-initial and exact active-current eligibility. <!-- sdd-owner: implementation -->
- [x] P3-B.2a-1.3 TRIANGULATE: run the worker test plus `schemas.test.ts`, `audit.test.ts`, and `outbox.test.ts`, proving interim temporal candidates mismatch, identity precedence, reference retention, purity, and no external effect. <!-- sdd-owner: implementation -->
- [x] P3-B.2a-1.4 REFACTOR: run the explicit and configured TypeScript checks, verify no competing classifier export, preserve P3.5–P3.10 unchecked, and record P3-B.2a-2 ownership in `apply-progress.md`. <!-- sdd-owner: implementation -->

**Full clarified vector inventory across the two bounded units:** independently vary `operationId`, `fingerprint`, document ID, delivery/request ID, `dispatchId`, `taskId`, deterministic tuple, `boundary`, `generation`, `sourceVersion`, `currentDispatchId`, worker acknowledgement, pending initial fields, active owner/lease shape, terminal status, missing records, exact extra/accessor fields, and reflective failures. P3-B.2a-1 covers only exact pending-initial and exact active-current; P3-B.2a-2 adds retained current temporal relations, same-generation lower-version retained, takeover-retained lower-generation/lower-version, stale non-current rows, same-version forks, future/mixed/unknown quadrants, wrong phase/boundary, and created/updated/dispatch timestamp failures. Until P3-B.2a-2, every non-exact temporal candidate is `mismatch` and `stale_eligible` is unreachable.

**Forecast — actual starting `worker.ts` classifier and `worker_auth.test.ts` fixture, not the historical estimate:**

| Path/category | Additions | Deletions | Changed-line range |
|---|---:|---:|---:|
| `worker.ts` — full carrier, identity, temporal classifier | 110–165 | 40–70 | 150–235 |
| `worker_auth.test.ts` — full identity and temporal matrix | 220–320 | 35–65 | 255–385 |
| `tasks.md` planning amendment | 20–35 | 8–15 | 28–50 |
| `apply-progress.md` supersession note | 10–18 | 2–6 | 12–24 |
| Review margin (distributed; no code-golf) | 5–6 | 0 | 5–6 |
| **Full clarified P3-B.2a total** | **365–544** | **85–156** | **450–700** |

**Safe first-boundary forecast (P3-B.2a-1):** `worker.ts` 65–90 additions/25–40 deletions (90–130); `worker_auth.test.ts` 95–135/18–30 (113–165); `tasks.md` 10–16/4–8 (14–24); `apply-progress.md` 8–14/0–2 (8–16); review margin 15–20; **sum 240–355**. Warning is 320, STOP is 380, and hard maximum is 399; the approved feature-branch-chain strategy removes any pending chain-choice or ask-on-risk decision. P3-B.2a-2 owns retained current temporal relations and the full temporal quadrant/timestamp matrix after B.2a-1 acceptance; until then, all non-exact temporal candidates mismatch and `stale_eligible` is unreachable. Persistence, acknowledgement, audit, acquisition, lease/takeover, Auth, emulator convergence, and P3.5–P3.10 remain unchecked.

## P3-B.2a-2 — Temporal Delivery Classifier (Planning Only)

**Dependency and boundary:** accepted P3-B.2a-1 identity gate plus the completed telemetry correction; modify only `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, `tasks.md`, and `apply-progress.md`. Preserve one `classifyProvisioningDelivery` authority. No persistence, stale acknowledgement, audit, lease, Auth, emulator, new file, or P3.5–P3.10 completion.

**Exact temporal matrix:** pending exact `pending/dispatch_pending`, `g=0,v=0`, null owner/lease/current ID, no Auth attempt, `acquire,g=0,sv=0`, and equal operation-created/updated/dispatch-created timestamps => `eligible`; every other pending boundary/generation/sourceVersion/timestamp relation => `mismatch` with no stale row. Active exact current `dg=og,sv=ov`, phase-matching boundary/current ID, and `operation.createdAt <= dispatch.createdAt <= operation.updatedAt` => `eligible`. Active retained current rows with `dg=og,sv<ov` or `dg<og,sv<ov` remain `eligible` only when the dispatch ID is current; otherwise those same two legal earlier quadrants with in-lifetime timestamps => `stale_eligible`. `dg>og`, `sv>ov`, `dg<og && sv>=ov`, every other unlisted generation/version quadrant, same-version fork/wrong current ID, wrong boundary/phase, or timestamp outside the operation lifetime => `mismatch`. Terminal precedes duplicate; both precede temporal classification.

**TDD tasks:**
- [x] P3-B.2a-2.1 RED: author independent temporal fixtures and assertions in `functions/test/provisioning/worker_auth.test.ts` first, covering exact pending timestamps, exact active/current retention, same-generation and takeover-retained current/noncurrent stale quadrants, all future/mixed/unlisted generation-version quadrants, same-version/boundary forks, timestamp `<`, `=`, `>` boundaries, purity, reference retention, and obsolete interim-mismatch deletions. <!-- sdd-owner: implementation -->
- [x] P3-B.2a-2.2 GREEN: extend only `classifyProvisioningDelivery` in `functions/src/provisioning/worker.ts` with the approved temporal matrix and timestamp coherence; keep `boundaries.ts` unchanged/unimported and expose no competing stale predicate or new caller authority. <!-- sdd-owner: implementation -->
- [x] P3-B.2a-2.3 TRIANGULATE: run Node 24 direct worker tests, explicit NodeNext TypeScript, configured TypeScript, and exact `schemas.test.ts`, `audit.test.ts`, and `outbox.test.ts` regressions; no emulator or persistence claim. <!-- sdd-owner: implementation -->
- [x] P3-B.2a-2.4 REFACTOR: prove one classifier export, preserve terminal/duplicate/orphan/malformed/corrupt precedence, run `git diff --check`, record evidence and rollback in `apply-progress.md`, and leave P3.5–P3.10 unchecked. <!-- sdd-owner: implementation -->

**First-unit changed-line forecast (actual current files; additions/deletions, tests/docs/deletion and refactor margin included):**

| Path/category | Changed-line range |
|---|---:|
| `functions/src/provisioning/worker.ts` temporal branches, timestamp checks, and obsolete interim logic | 70–102 |
| `functions/test/provisioning/worker_auth.test.ts` matrix, boundary vectors, retention, and removed interim expectations | 146–200 |
| `tasks.md` planning/tasks bookkeeping | 12–18 |
| `apply-progress.md` evidence/rollback bookkeeping | 10–15 |
| Refactor/review margin without code-golf or borrowed budget | 12–18 |
| **Total P3-B.2a-2** | **250–353** |

Warning is 320; STOP/reforecast is 380; hard maximum is 399. Approved delivery is feature-branch-chain; no new ask-on-risk decision or size exception is authorized. Rollback removes only this temporal classifier/test extension and its two planning records; P3-B.2a-1 identity and telemetry correction remain intact.

## P3-B.2b-1 — Transactional Stale Acknowledgement + Deduplicated Audit (superseded planning record — fake-only boundary rejected)

**Historical rationale only:** the complete persistence package is 430–560 lines after the accepted classifier; the former fake-only split deferred mandatory emulator proof and is rejected as an acceptance route. Preserve this record and IDs; do not execute it.

**Allowed writer paths (not repo-wide):** `functions/src/provisioning/worker.ts`, `functions/src/provisioning/boundaries.ts`, `functions/test/provisioning/worker_auth.test.ts`, and the two SDD records. Consume, but do not modify, `audit.ts`, `schemas.ts`, `store.ts`, `memory_store.ts`, and their P2/P1b tests. Preserve all older checkbox IDs/history and broader P3.5–P3.10 checkboxes.

**Prerequisite proof:** separately verify the trusted domain premise from `submit.ts` create-if-absent submission, `boundaries.ts` transaction `createDispatch`, and the Firestore catch-all client denial. Record that `index.ts` runtime composition is still undeployed/fail-closed; no deployment assertion is permitted.

- [ ] P3-B.2b-1.1 RED: independently author fake-backed vectors for trusted dispatch-document rereads, classifier rerun, `stale_eligible`-only authorization, `workerAck:null→stale`, validated `createAuditEvent`/`deduplicateAudit`, all-reads-before-writes, rollback, idempotent replay, race loss, immutable operation/version, and no caller counters/tokens stored. <!-- sdd-owner: implementation -->
- [ ] P3-B.2b-1.2 GREEN: remove parameter-property syntax from touched `boundaries.ts` classes; add `readAudit` to `WorkerTransaction`, Firestore adapter, and fake; implement only the stale acknowledgement transaction using trusted dispatch→operation→audit reads, the same classifier, `isValidDispatchUpdate`, and P2 audit primitives. <!-- sdd-owner: implementation -->
- [ ] P3-B.2b-1.3 TRIANGULATE: prove the fake commits dispatch acknowledgement plus audit atomically, writes neither on validation/CAS/audit failure, deduplicates matching replay, rejects identity drift, never changes operation/version, and leaves structured-log safety unchanged. <!-- sdd-owner: implementation -->
- [ ] P3-B.2b-1.4 REFACTOR: run the exact checks below, audit the allowed-path diff, record the deferred emulator boundary, and stop before acquisition/takeover or any runtime-composition claim. <!-- sdd-owner: implementation -->

**First-unit forecast (changed lines, including tests/docs/deletions/extraction margin):** `boundaries.ts` 26–38; `worker.ts` 84–110; `worker_auth.test.ts` 160–190; SDD records 22–30; review/refactor margin 13–24; **total 305–392**. Warning 320, STOP/reforecast 380, hard maximum 399; no exception or borrowing. Rollback removes only this transaction helper, port propagation, fake vectors, and two records; P3-B.2a-2 remains intact.

**Contract acceptance:** only a transaction-reread `stale_eligible` may write; delivery ID/document ID/dispatch self-identity and operation/fingerprint must match; all reads precede writes; acknowledgement changes only legal dispatch acknowledgement fields; audit is schema-validated and create-if-absent/deduplicated; concurrent loss rolls back; replay is idempotent; operation data, version, leases, Auth/profile, caller counters, and tokens are untouched; no new stale predicate, logger, endpoint, deployment, or native claim is introduced.

**Planned verification (not run in this planning phase):** Node 24 gate `cd functions && node --version` (expected installed `v24.11.1`), then `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`; explicit test-file TypeScript `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/worker.ts src/provisioning/boundaries.ts test/provisioning/worker_auth.test.ts`; configured `cd functions && npx tsc --noEmit`; regressions `node --experimental-strip-types test/provisioning/audit.test.ts`, `schemas.test.ts`, `store_conformance.test.ts`, and `memory_store.test.ts`.

**P3-B.2b-2 handoff:** run the same worker fake plus real Firestore transaction race/rollback/idempotency proof with installed Temurin 21.0.12.8: PowerShell `cd functions; $env:JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-21.0.12.8-hotspot'; $env:PATH="$env:JAVA_HOME\bin;$env:PATH"; npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"`. It must prove both concurrent arrivals reread trusted documents, one stale acknowledgement/audit commit wins, the loser retries safely, and no operation version update occurs.

## P3-B.2b prerequisite handoff — completed

**Status:** Completed under Strict TDD. This preserves fake-only P3-B.2b-1 as superseded history; the next bounded unit below owns the full atomic stale-ack+audit acceptance.

**Evidence basis:** current `functions/src/provisioning/boundaries.ts` has exactly three parameter-property constructors and no `readAudit`; current `worker_auth.test.ts` has classifier fixtures but no transaction read contract. Define `readAudit(eventId): Promise<WorkerRecord | null>` against exactly `provisioningAudit/{eventId}`: existing record returns, missing returns `null`, read errors propagate, and it performs zero writes.

| Future writer path | Changed lines (min–max, additions + deletions) |
|---|---:|
| `functions/src/provisioning/boundaries.ts` — strip all three constructors, port, Firestore adapter | 26–36 |
| `functions/test/provisioning/worker_auth.test.ts` — strict fake + emulator and rejecting-get vectors | 52–70 |
| `tasks.md` — scoped prerequisite bookkeeping | 4–8 |
| Eventual `apply-progress.md` evidence append (budget only; not edited now) | 6–10 |
| Independent validation/refactor margin | 7–11 |
| **Total** | **95–135** |

**Safe acceptance:** fake matrix covers record/absence/failure; REAL Firestore emulator covers record/absence; an injected rejecting transaction `get` separately proves adapter error propagation; all paths prove zero writes. The accepted classifier is reused unchanged. No stale acknowledgement or production-trust claim is accepted.

- [x] P3-B.2b-pre.1 RED: author the fake matrix and adapter rejecting-`get` vectors in `functions/test/provisioning/worker_auth.test.ts` before changing `boundaries.ts`. <!-- sdd-owner: implementation -->
- [x] P3-B.2b-pre.2 GREEN: explicitly rewrite `FirebaseAuthReader`, `FirestoreWorkerTransaction`, and `FirestoreWorkerStore` without parameter properties; add the exact `readAudit` port/adapter/fake contract and no stale-ack caller. <!-- sdd-owner: implementation -->
- [x] P3-B.2b-pre.3 TRIANGULATE: gate Node 24 and Java 21, run the REAL Firestore existing/absence command, and prove injected read failure plus zero writes. <!-- sdd-owner: implementation -->
- [x] P3-B.2b-pre.4 REFACTOR: run explicit NodeNext TypeScript, schema/audit/outbox regressions, and the scoped diff check; do not change `worker.ts` or P3.5–P3.10 checkboxes. <!-- sdd-owner: implementation -->

**Exact checks (planning only):** `cd functions && node --version`; `java -version` must report installed Java 21; `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`; `cd functions && npx firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"`; explicit `cd functions && npx tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/boundaries.ts src/provisioning/worker.ts test/provisioning/worker_auth.test.ts`; `cd functions && node --experimental-strip-types test/provisioning/schemas.test.ts`; `cd functions && node --experimental-strip-types test/provisioning/audit.test.ts`; `cd functions && npx firebase emulators:exec --only firestore,functions "node --experimental-strip-types test/provisioning/outbox.test.ts"`; configured `cd functions && npx tsc --noEmit`; and `git diff --check -- functions/src/provisioning/boundaries.ts functions/test/provisioning/worker_auth.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md`.

**Dependencies/rollback:** accepted P3-B.2a-2, P2 `audit.ts`/`schemas.ts`, existing Firebase CLI, installed Node 24/Java 21, no install. Rollback is `boundaries.ts`, `worker_auth.test.ts`, and `tasks.md`; future atomic stale-ack paths remain `worker.ts`, `boundaries.ts`, `worker_auth.test.ts`, and `tasks.md`, with full fake/reference CAS, legal `null→stale` only, no operation/version write, validated audit, read-before-write, rollback/replay/concurrency proof. P3.5–P3.10 remain unchecked.

## P3-B.2b-2 — Atomic Stale Acknowledgement + Deduplicated Audit (next coherent tranche)

**Status:** Maintainer-confirmed and implementation-ready after prerequisite evidence `ec00561095f904aec24d84bd7c89e6b7913908d484cdf6dfae5329d829215848`; no stale-audit field-choice blocker remains. Traceability: the accepted stale-audit table in `design.md`, the Atomic Stale-Delivery Acknowledgement Audit requirement in `spec.md`, and read-only prerequisite record `apply-progress.md:1753-1772`. This planning acceptance is not implementation or deployment evidence.

**Boundary:** apply may modify only `functions/src/provisioning/worker.ts`, `functions/src/provisioning/boundaries.ts`, `functions/test/provisioning/worker_auth.test.ts`, and `openspec/changes/prepare-public-portfolio-repository/tasks.md`; parent evidence may append only `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`. The writer receives exactly a `WorkerStore` and `deliveryDispatchId`; `store.transaction` supplies the existing `WorkerTransaction` ports (`readDispatch`, `readOperation`, `readAudit`, `writeDispatch`, `createAudit`) and its authoritative `now`. It accepts no caller snapshots, classifier result, audit candidate/override, clock, counters, tokens, or caller digests. No new file, manifest, config, install, `index.ts` surface, acquisition, lease/takeover, Auth/profile read, terminalization, deployment, or runtime-composition claim.

**Contract:** trusted-reread dispatch then operation, rerun `classifyProvisioningDelivery`, derive `eventId=deriveAuditEventId(operationId,"progress","stale_delivery",dispatch.generation,dispatch.sourceVersion)`, derive `correlationId=hexSha256("provision-correlation:v1\0"+operationId)`, and read the audit before any write. Populate all 14 fields exactly from the accepted design: actor/intended digests are null; dispatch ID/generation/sourceVersion use the immutable dispatch; `transaction.now` is only the candidate `createdAt` for first insertion. `deduplicateAudit` compares every field except `createdAt` and preserves a matching existing event unchanged. Only authoritative `stale_eligible` may atomically commit legal `workerAck:null → stale` plus that validated create-if-absent audit; every mismatch, race loss, or failure writes neither and never mutates operation/version or invokes external effects.

**Forecast (changed lines = additions + deletions):** correlation hashing and exact-field tests raise the honest range to `worker.ts` 78–102; `boundaries.ts` 24–36; `worker_auth.test.ts` 154–194; `tasks.md` 8–12; parent-only future `apply-progress.md` evidence 6–10; test/docs/refactor margin 14–22; **total 284–376**. Warning 320; STOP/reforecast 380; hard maximum 399; no exception or borrowing. Rollback removes only this writer, adapter, test vectors, and bookkeeping; the accepted prerequisite and classifier remain.

**Strict TDD and same-unit acceptance:**
- [x] P3-B.2b-2.1 RED: author fake and REAL Firestore vectors before source changes for trusted rereads, classifier rerun, legal `null→stale`, all 14 audit fields/IDs, all-reads-before-writes, every no-write classification, conflicting audit, injected failures, atomic rollback, replay, and coordinated concurrency. <!-- sdd-owner: implementation -->
- [x] P3-B.2b-2.2 GREEN: implement only the transaction stale-ack path in `worker.ts`/`boundaries.ts`; use the existing store/transaction ports and transaction `now`, derive every field from trusted rereads, and add no competing classifier, caller override, acquisition, or Auth. <!-- sdd-owner: implementation -->
- [x] P3-B.2b-2.3 TRIANGULATE: in this same unit, run the fake and REAL Firestore harness for all acceptance vectors; retain concurrent `Promise.all` worker replay convergence, and separately stage adapter `writeDispatch` then `createAudit` against an existing audit without a prior audit read to prove real Firestore `ALREADY_EXISTS` (code 6) atomically preserves dispatch/audit bytes. This replaces the deadlocking externally coordinated post-read interleaving; it proves adapter atomicity, not that old interleaving. No fake commit hook substitutes for emulator proof. <!-- sdd-owner: implementation -->
- [x] P3-B.2b-2.4 REFACTOR: gate Node 24 and Java 21, run the exact typecheck, emulator, three direct regressions, and full-path scoped diff check below; preserve broader P3.5–P3.10 and historical checkboxes as unchecked. <!-- sdd-owner: implementation -->

**Exact checks (run only during apply):** gate `cd functions && node --version` (Node >=22.6.0; installed Node 24) and `java -version` (Java 21); run `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`, REAL Firestore worker for all acceptance, `cd functions && ./node_modules/.bin/tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/worker.ts src/provisioning/boundaries.ts test/provisioning/worker_auth.test.ts`, and configured `cd functions && ./node_modules/.bin/tsc --noEmit`. The three direct regressions are exact: `cd functions && node --experimental-strip-types test/provisioning/schemas.test.ts`; `cd functions && node --experimental-strip-types test/provisioning/audit.test.ts`; `cd functions && node --experimental-strip-types test/provisioning/outbox.test.ts`. Also run `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"`. Scoped `git diff --check` names full paths `functions/src/provisioning/worker.ts functions/src/provisioning/boundaries.ts functions/test/provisioning/worker_auth.test.ts openspec/changes/prepare-public-portfolio-repository/tasks.md openspec/changes/prepare-public-portfolio-repository/apply-progress.md` when parent evidence changes; no install, `index.ts`, acquisition, or Auth emulator is allowed.

## P3-B.2c-pre-payload-contract — Persisted Payload Reducer Repair (required prerequisite)

**Status and ownership:** required, bounded reducer-contract repair before any P3-B.2c acquisition work. Persisted `normalizedPayload` has exactly 19 canonical fields; `displayName` is transiently derived at the normalize/profile boundary and must not become persisted state. This resolves the confirmed persisted-19 versus reducer-20 defect without changing hashing, submission persistence, normalization, or profile behavior. Acquisition remains **NO-GO** under its existing scope/budget decision.

**Allowed repair paths (exact):** `functions/src/provisioning/model.ts`, `functions/test/provisioning/model.test.ts`, `functions/test/provisioning/worker_auth.test.ts`, and this `tasks.md`. `functions/test/provisioning/fixtures.ts` is a read-only dependency and is not an allowed repair path: its canonical normalized vectors retain transient `displayName`, while active delivery fixtures must instead use the persisted 19-field record. A future evidence append is limited to 6–10 lines in `openspec/changes/prepare-public-portfolio-repository/apply-progress.md`; its existing prefix remains byte-for-byte intact. No other source, test, schema, persistence, profile, config, progress, or documentation path is authorized.

**Strict TDD and canonical ownership:**
- [x] P3-B.2c-pre-payload-contract.1 RED: first author reducer and active-delivery fixture assertions proving a 19-field persisted pending record transitions to active and supports a further valid transition without payload mutation; reject an otherwise valid persisted payload with extra `displayName`; prove deep-freeze/reference immutability and canonical fingerprint stability. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-pre-payload-contract.2 GREEN: change only `model.ts` persisted payload validation/typing to accept exactly the canonical 19 fields and reject transient `displayName`; keep `displayName` derivation, canonical-key hashing, submission stripping, and profile input behavior unchanged. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-pre-payload-contract.3 TRIANGULATE: make the active `worker_auth.test.ts` delivery fixture persisted-19, then run the exact focused reducer, worker-auth, schemas, and profile regressions plus explicit NodeNext and configured local `tsc`; no emulator is required because no adapter changes. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-pre-payload-contract.4 REFACTOR: retain one canonical persisted-payload ownership marker, remove no coverage to meet budget, run scoped diff check, and append only the bounded future evidence lines; leave acquisition and broader P3 checkboxes unchecked. <!-- sdd-owner: implementation -->

**Forecast (additions + deletions; complete accounting):** `model.ts` 12–22; `model.test.ts` 42–66; `worker_auth.test.ts` 8–16; `tasks.md` 18–28; future `apply-progress.md` evidence 6–10; deletion/refactor/documentation margin 14–24; **total 100–166**. Warning 320; STOP/reforecast 380; hard maximum 399; no exception, borrowing, or coverage reduction. Rollback removes only this repair's reducer/test/fixture edits and future bounded evidence append; it does not alter normalization, persistence, profile, or the retained acquisition NO-GO.

**Apply-only regression commands (not run in this planning amendment):** `cd functions && node --experimental-strip-types test/provisioning/model.test.ts`; `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`; `cd functions && node --experimental-strip-types test/provisioning/schemas.test.ts`; `cd functions && node --experimental-strip-types test/provisioning/profile.test.ts`; `cd functions && ./node_modules/.bin/tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/model.ts test/provisioning/model.test.ts test/provisioning/worker_auth.test.ts`; and `cd functions && ./node_modules/.bin/tsc --noEmit`. Node 24 is required; no emulator is authorized unless an adapter changes, which this prerequisite forbids.

## P3-B.2c — Initial Pending Lease Acquisition (planning-only; amended)

**Accepted two-unit gate — planning only.** The explicit human-approved split supersedes the prior same-unit NO-GO; its 428–533 figure is retained below as historical evidence for the rejected indivisible boundary, not a measured forecast for either new unit. Unit A is atomic production acquisition plus strict-fake proof; Unit B is REAL Firestore rollback/concurrency/replay acceptance. A passing Unit A is not full acquisition acceptance, and broader P3 remains incomplete until Unit B passes.

**Immutable scope:** one transaction must trusted-read source dispatch, operation, candidate audit, and next dispatch before writes; validate only the initial pending tuple and source `acquire/g0/sourceVersion0`; pure-reduce `acquire`; atomically write operation, source `processed` acknowledgement, 14-field audit, and deterministic next dispatch. It excludes takeover, Auth/profile, terminalization, and classifier remapping. The 60-second lease uses `transaction.now`; the source is `processed`; the audit is `progress/state_transition/started/success`, g0/sv0, approved correlation, and null actor/intended digests.

**Design skeleton (not implementation evidence):**

| Block | Concrete planned content | Lines |
|---|---|---:|
| `worker.ts` imports/types | `createHash`, audit/create-deduplicate, `deriveAuditEventId`/`deriveDispatchId`/`deriveOwnerToken`, reducer types and schema guards | 14–18 |
| trusted-read validation | dispatch → operation → audit → next dispatch; exact initial constants, identity relations, `ownerSeed===deriveOwnerToken(source.dispatchId,0)`, and all eight `ExpectedCAS` fields | 42–52 |
| reducer/write stages | `createEvent("acquire",…)`, `reduce`, lease `now+60_000`, adapter-only pointer, validated operation/source update, next create, audit create-or-deduplicate | 44–52 |
| test imports/helpers/fixture | canonical fixture factory derives operation/fingerprint/source/task/seed/audit/next IDs; `expectedCAS`, request, `assertUnchanged`, and call-order helpers | 54–64 |
| operation matrix | 17 named isolated mutation rows plus legal-equivalence rows; each has strict-map snapshot and no-write or successful outcome | 68–85 |
| source matrix | 16 named isolated mutation rows plus legal enqueue-shape rows; each has strict-map snapshot and no-write or successful outcome | 64–80 |
| positive/audit/replay fake cases | `ACQ-OK`, matching audit, processed replay, grouped timestamp relation, coherent recomputation, and rollback assertions | 54–70 |
| REAL emulator cases | matching-audit convergence/replay, `Promise.all` convergence, and four-write code-6 rollback with original/next-absence assertions | 54–64 |
| four checkbox replacements | four unchecked task lines replaced by four outcome lines | 8 |
| future progress evidence | bounded post-apply evidence append | 6–12 |
| contingency | formatting, type diagnostics, and assertion clarity; not code-golfed away | 20–28 |
| **Total** | **all blocks counted; no shared/omitted block** | **428–533** |

**Semantic matrix correction:** the 17 operation and 16 source fields are not “all invalid.” Named negative rows replace a field with an actual malformed value or broken acquisition constant/relation: `schemaVersion:2`; other valid UUID/digest identity mismatch; active/noninitial status or phase; nonzero generation/version; non-null initial owner/lease/pointer; `authAttempted:true` or coherent non-null attempt; unequal timestamps; wrong source boundary/generation/sourceVersion; wrong task/operation/fingerprint identity; wrong owner seed; acknowledged source; and malformed enqueue/ack shape. Positive rows use schema-valid alternate normalized payload/intended UID/submitted digest without pinning fixture values; grouped equal `operation.createdAt`/`updatedAt`/`source.createdAt`; both valid empty enqueue and valid trigger/sweeper acknowledged enqueue tuples; and a coherently recomputed operation/fingerprint/dispatch/task/seed/audit/next identity. The full eight-field CAS is preserved. Thus legal equivalents are distinguished from malformed or inconsistent persisted records.

**Proof skeleton:** fake `ACQ-OK` asserts four reads precede every write, reducer output retains null pointer until adapter assignment, lease/processed/audit/next values, and three-map snapshots. `ACQ-MATCHING-AUDIT` preserves existing `createdAt`; `ACQ-PROCESSED-REPLAY` proves replay bytes unchanged; `ACQ-ROLLBACK` covers audit mismatch, next conflict, create conflict, and reducer/CAS failure. REAL uses existing `StrictWorkerStore`/`strictStoreSnapshot` savings only for the fake, and existing Firebase app/store lifecycle plus `Promise.all` and code-6 pattern for emulator setup. REAL convergence asserts persisted final state rather than a returned loser. The code-6 case stages operation write, source acknowledgement write, next create, then conflicting audit create and asserts code 6, original operation/source/audit, and absent next dispatch.

**Execution order and gate:** Unit B depends on completed Unit A and reruns against A's committed candidate; it is never replaced by a fake substitute. No production edit is authorized in Unit B: a defect exposed there stops for a separately authorized bounded remediation. Each unit has warning 320, STOP/reforecast 380, hard maximum 399, no exception, no borrowing, no coverage reduction, and its own implementation-owner checklist.

### P3-B.2c-pre — StrictWorkerStore test-only `createDispatch` prerequisite

**Purpose and boundary (historical, completed):** Before completion, `StrictWorkerStore.createDispatch` always threw in `functions/test/provisioning/worker_auth.test.ts:345–378`. This completed prerequisite implemented only test-only create-if-absent behavior on the transaction working copy. Its prior edit surface was limited to `functions/test/provisioning/worker_auth.test.ts` and this `tasks.md`; no `worker.ts` or `boundaries.ts` change occurred, and planning does not write progress.

**Behavior:** duplicate creation rejects without overwrite; a later callback failure rolls back all three maps byte-for-byte; and success creates exactly once. Retain the existing stale-audit fake regressions. This prerequisite makes no claim of acquisition fake acceptance or emulator acceptance, and no emulator run is needed for passive planning.

**Strict TDD, independent acceptance:**
- [x] P3-B.2c-pre.1 RED: add focused `StrictWorkerStore` vectors that expose the always-throwing `createDispatch` behavior and specify create-if-absent success, duplicate rejection without overwrite, and byte-for-byte three-map rollback after a later callback failure. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-pre.2 GREEN: implement the test-only transaction-working-copy create-if-absent behavior in `worker_auth.test.ts`; retain stale-audit fake regressions and change no production source, `worker.ts`, or `boundaries.ts`. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-pre.3 TRIANGULATE: prove one successful create, duplicate preservation, and rollback of all three maps after a later callback failure using the strict fake only; do not represent this as acquisition fake or REAL Firestore acceptance. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-pre.4 REFACTOR: keep the fake-store helper and vectors clear without expanding the prerequisite surface; future parent bookkeeping remains append-only and is not written during planning. <!-- sdd-owner: implementation -->

**Prerequisite forecast (changed lines = additions + deletions; forecast only):** `worker_auth.test.ts` 26–44 (adds 24–38, deletes 2–6); `tasks.md` 5–10; parent-only future `apply-progress.md` 6–10; contingency 5–8; **total 42–72**. This is a standalone test-only work unit with terminal implementation ownership. It has no exception and does not alter the initial-acquisition budget decision.

**Acquisition implementation paths after prerequisite:** `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, and `tasks.md`; future apply evidence may append only 6–12 lines to `apply-progress.md`. `boundaries.ts` remains a read-only dependency: existing `WorkerTransaction` already supplies every required production primitive, so acquisition expects **zero** `boundaries.ts` changes. Planning does not edit `apply-progress.md`.

**Prerequisites/symbol map:** reuse `model.ts` `reduce`, `createEvent`, `ReducerRequest`, `ExpectedCAS`; `cas.ts` full-tuple/lease fences; `schemas.ts` `isValidOperation`, `isValidDispatch`, `isValidDispatchUpdate`; `ids.ts` `deriveDispatchId`, `deriveOwnerToken`; `worker.ts` `classifyProvisioningDelivery` and `acknowledgeStaleDelivery`; and read-only `boundaries.ts` `WorkerStore`, `WorkerTransaction`, `FirestoreWorkerStore`, authoritative `now`, trusted rereads, `writeOperation`, `writeDispatch`, `createDispatch`. Existing callers are `submit.ts` atomic initial operation/dispatch creation and `outbox.ts` enqueue-only acknowledgement; verify all callers and explicit TypeScript impact.

**Contract:** in one trusted transaction, read dispatch, operation, candidate audit, and next dispatch before any write. Require the full operation tuple and immutable source `acquire/g0/sourceVersion0` tuple, exact pending `dispatch_pending`, `version=0`, `currentDispatchId=null`, `workerAck=null`, server transaction clock, and deterministic owner-seed/token relation. Invoke the pure `acquire` reducer, which preserves `generation=0` and its null pointer while producing `version=1`; the adapter assigns the deterministic `auth_preflight/g0/sourceVersion1` next pointer. Atomically persist the 60-second lease, processed source acknowledgement, accepted 14-field `progress/state_transition/started/success` audit sourced from g0/sourceVersion0 with approved correlation hash and null actor/subject digests, and create-if-absent next dispatch. Matching replay preserves the original audit timestamp; any audit/dispatch/create/CAS conflict rolls back all writes, and concurrency has one winner.

Owner injection is a genuine contract: require `sourceDispatch.ownerSeed===deriveOwnerToken(sourceDispatch.dispatchId,0)` and assign that derived token as owner; tests may inject only the transaction clock and persisted canonical seed. The initial persisted pointer is normatively null, and only the adapter assigns the next pointer; no field or reducer behavior may be invented.

**Ordered work units, strict TDD, and canonical ownership:**

**Unit A — Atomic acquisition implementation + strict fake (first; implementation owner).** Allowed writes: `functions/src/provisioning/worker.ts`, `functions/test/provisioning/worker_auth.test.ts`, this `tasks.md`, and a future 6–10-line append to `apply-progress.md`; user-authorized repair additionally permits only persisted-19 constructor corrections in `functions/test/provisioning/store_conformance.test.ts` and `functions/test/provisioning/memory_store.test.ts`; all other production files are read-only. Reuse existing `StrictWorkerStore` and `strictStoreSnapshot` only for A's fake matrix; the existing canonical operation/dispatch data fixture may be shared with B. B independently uses its existing Firebase lifecycle, `Promise.all`, and code-6 pattern. A owns `ACQ-OK`, both complete named fence matrices, matching-audit fake, processed-replay fake, and every strict-fake rollback branch.
- [x] P3-B.2c-A.1 RED: add named strict-fake vectors before production edits for the four trusted reads-before-writes, all eight-field CAS, source constants/identity/seed, valid-versus-invalid operation/source mutations (including schema-invalid/broken relation rejection and legal payload/intendedUid/submittedByDigest, timestamp/identity, and empty/trigger/sweeper enqueue tuples), exact audit, matching-audit/replay distinction, and all rollback branches. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-A.2 GREEN: implement only initial pending acquisition in `worker.ts`: pure `acquire`, derived owner/lease60, adapter pointer, and one transaction writing operation, processed source acknowledgement, 14-field audit, and next dispatch atomically. No Auth/profile, takeover/renewal, terminalization, classifier, or `boundaries.ts` change. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-A.3 TRIANGULATE: prove the complete fake matrix, all four writes, reducer-null-pointer then adapter assignment, matching audit timestamp preservation, processed replay byte stability, and rollback of originals plus next absence. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-A.4 REFACTOR: retain readable cases and shared helper ownership without coverage removal; run Unit A commands and scoped diff check. A is complete only for implementation/fake proof; full acquisition remains unchecked pending B. <!-- sdd-owner: implementation -->

**Accepted A-only disposition:** Maintainer accepted the historical missing-export compilation RED deviation; no behavioral RED is claimed or fabricated. Independent verification passed 7 regressions, 2 TypeScript checks, worker 22 pass/3 skip, store 4/4, and memory 1/1. Unit B remains pending and must execute all REAL rollback, concurrency, and replay proof.

**Unit B — REAL Firestore rollback/concurrency/replay acceptance (second; depends on A; implementation owner).** Allowed writes are test/documentation only: `functions/test/provisioning/worker_auth.test.ts`, this `tasks.md`, `design.md`, `spec.md`, and a future 6–10-line `apply-progress.md` append. B executes against A's candidate and may read `worker.ts`, `boundaries.ts` (Firestore transaction/clock mapping), `model.ts`, `schemas.ts`, `ids.ts`, and `audit.ts`; it changes none. A REAL-exposed defect is a stop for separately authorized bounded remediation, never a silent B production roll-forward.
- [x] P3-B.2c-B.1 RED: add emulator-gated `REAL-ACQ-ONE-WINNER`, matching-audit, processed-replay, and `REAL-ACQ-CODE6-ROLLBACK` acceptance vectors before any remediation; use a pre-start barrier and `Promise.all`, never an external write or held post-read barrier. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-B.2 GREEN: run the REAL vectors against Unit A unchanged; assert convergence rather than a returned loser, matching-audit original timestamp, replay byte stability, and code-6 rollback of original operation/source/audit with next dispatch absent. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-B.3 TRIANGULATE: rerun REAL acceptance after the focused A fake regression and prove one active g0/v1 operation, one processed source ack, one deterministic next dispatch, and one accepted audit under concurrency. <!-- sdd-owner: implementation -->
- [x] P3-B.2c-B.4 REFACTOR: preserve test-only B scope, no coverage removal, scoped diff check, and bounded evidence append; only then mark full acquisition acceptance verified while broader P3 remains unchecked. <!-- sdd-owner: implementation -->

**Forecasts (additions + deletions; estimates, not measured source fit):** A: `worker.ts` 92–116; `worker_auth.test.ts` 140–165; `tasks.md` 25–33; future progress 6–10; margin 22–28; **285–352**. B: `worker_auth.test.ts` 104–136; `tasks.md` 20–28; `design.md`/`spec.md` 12–18; future progress 6–10; margin 20–26; **162–218**. A straddles warning 320, so review is required if actual change reaches it; B remains below warning. Both remain below STOP/reforecast 380 and hard maximum 399; no exception, borrowing, or coverage reduction.

### Concrete matrix and proof ownership

All cases are readable named cases, not a generic test abstraction. Unit A owns every strict-fake row and Unit B owns every REAL row; each operation and source-dispatch field gets an independently named mutation and three-map snapshot assertion. Acquisition fixtures derive `ownerSeed` with `deriveOwnerToken(acquireDispatchId, 0)` rather than the stale fixture constant. Only the existing canonical operation/dispatch data fixture may be shared; strict-fake helpers and Firebase lifecycle/concurrency/code-6 setup remain unit-specific.

| Named cases | Strict fake proves | REAL Firestore proves | Required assertions |
|---|---|---|---|
| `ACQ-OK` | Transaction call log reads source dispatch, operation, candidate audit, and next dispatch before any write; canonical initial records are accepted. | — | Full pending tuple; `acquire/g0/sourceVersion0`; null initial pointer; canonical derived seed/token; reducer yields `active/auth_preflight,g0,v1` with null pointer; adapter assigns deterministic `auth_preflight/g0/sourceVersion1` pointer; lease is `transaction.now + 60_000`; source `workerAck="processed"`. |
| `ACQ-FENCE-operation` | Independently replace every persisted operation field: `schemaVersion,operationId,fingerprint,normalizedPayload,intendedUid,submittedByDigest,status,phase,generation,version,ownerToken,leaseExpiresAt,currentDispatchId,authAttempted,authAttempt,createdAt,updatedAt`; malformed/broken constants or relations fail closed, while the separately named legal-equivalence values are accepted. | — | Invalid rows make no write and preserve operation, source/next dispatches, and audits byte-identically; legal rows reach the normal positive assertion. |
| `ACQ-FENCE-source` | Independently replace every persisted source field: `schemaVersion,dispatchId,taskId,operationId,fingerprint,boundary,generation,sourceVersion,ownerSeed,enqueued,enqueuedAt,enqueueSource,enqueueEventId,workerAck,workerAckAt,createdAt`; malformed/broken identity/seed/acquisition values fail closed, while valid empty and trigger/sweeper enqueue tuples are separately accepted. | — | Invalid rows fail closed without reducer/map writes; legal rows reach the normal positive assertion. |
| `ACQ-MATCHING-AUDIT` | Constructs and compares all 14 audit fields: g0/sv0 event ID, approved correlation hash, `progress/state_transition/started/success`, null actor/subject digests, source dispatch, and first-insert clock timestamp. | A preexisting matching audit on a valid pending acquisition preserves its timestamp while operation, source acknowledgement, and next dispatch commit. | No audit rewrite; acquisition commits exactly once. |
| `ACQ-PROCESSED-REPLAY` | After processed source acknowledgement, a fake replay leaves operation, source, next-dispatch, and audit byte unchanged. | After processed source acknowledgement, later invocation/replay leaves every operation, source, next-dispatch, and audit byte unchanged. | This is distinct from matching-audit acquisition and makes no result/winner discriminator claim. |
| `ACQ-ROLLBACK` | Explicit audit identity mismatch, existing conflicting next dispatch, dispatch create conflict, audit create conflict, and reducer/CAS failure rows each restore all three maps. | — | `assertUnchanged` after each rejection proves rollback of operation, source acknowledgement, next dispatch, and audit together. |
| `REAL-ACQ-ONE-WINNER` | — | Pre-start barrier plus `Promise.all` runs competing worker transactions against one initial pair. | Assert convergence only: one active g0/v1 operation, one processed source ack, one deterministic next dispatch, one accepted audit, then post-completion and replay byte stability. Do not infer a loser from `Promise<void>` or Firestore retries. |
| `REAL-ACQ-CODE6-ROLLBACK` | — | Stage operation write, source `workerAck:"processed"` write, next-dispatch `create`, and conflicting audit `create` against an existing audit, without prior audit read. | Firestore `ALREADY_EXISTS` code 6 rejects atomically; compare original operation, source dispatch, and audit individually, and prove next dispatch remains absent. |

The fake proves ordered port use, every individual persisted-field fence, and deterministic rollback. REAL Firestore proves convergence, matching-audit timestamp preservation, processed replay stability, and full multi-write create-precondition rollback; no fake-only branch is represented as REAL proof.

### Corrected accounting decision

**Historical accounting, superseded boundary:** 360, 390–440, and 428–533 remain traceability for the rejected indivisible same-unit plan, not a forecast for A or B and not measured source fit. The approved two-unit forecasts above govern execution; both preserve all acceptance and prohibit exception, borrowing, or coverage reduction.

**Source evidence and scope:** parent CodeGraph located `worker.ts` `classifyProvisioningDelivery:120` and `acknowledgeStaleDelivery:150`; direct reads confirm `boundaries.ts` supplies `now`, the four reads, two writes, `createDispatch`, `createAudit`, Firestore mapping, and transaction clock. `model.ts` supplies `OperationState`, `ExpectedCAS`, `ReducerRequest`, `createEvent`, and pure `reduce`; `schemas.ts` supplies initial/update guards; `ids.ts` derives dispatch/audit/owner IDs; `audit.ts` validates and deduplicates the 14-field record. Existing `worker_auth.test.ts` supplies `StrictWorkerStore`, `strictStoreSnapshot`, Firebase lifecycle, `Promise.all`, and code-6 pattern. Unit A writes only `worker.ts` and `worker_auth.test.ts`; Unit B writes only `worker_auth.test.ts`; `boundaries.ts`, `model.ts`, `schemas.ts`, `ids.ts`, `audit.ts`, `normalize.ts`, `submit.ts`, `profile.ts`, `fixtures.ts`, and `explore.md` stay read-only. Planning does not write `apply-progress.md`.

**Apply-only commands (not run in planning):** `cd functions && node --version` (Node 24.x); `java -version` (Java 21); `cd functions && node --experimental-strip-types test/provisioning/worker_auth.test.ts`; `cd functions && ./node_modules/.bin/tsc --noEmit --module NodeNext --moduleResolution NodeNext --target ES2022 --strict --esModuleInterop --skipLibCheck --allowImportingTsExtensions src/provisioning/worker.ts test/provisioning/worker_auth.test.ts`; `cd functions && ./node_modules/.bin/tsc --noEmit`; and, for B, `cd functions && ./node_modules/.bin/firebase emulators:exec --only firestore "node --experimental-strip-types test/provisioning/worker_auth.test.ts"`. Regressions are the local-CLI `schemas.test.ts`, `audit.test.ts`, `outbox.test.ts`, `store_conformance.test.ts`, and `memory_store.test.ts`; they are justified by A's schema/audit/store writes and B's real adapter path. No install, test/emulator run, native operation, commit, or progress write occurs in planning.

**Accepted normal-takeover subdecision; current unit remains blocked.** The maintainer accepted the normal-takeover audit/source-dispatch contract: the atomic takeover leaves the source dispatch byte-identical, current, and `workerAck:null`, creates no next dispatch, derives the next generation from the latest observed operation generation, increments version, installs deterministic owner/live lease, and preserves status/phase/AuthAttempt/source pointer. It creates or deduplicates `schemaVersion:1` `progress/state_transition/started/success` audit identity `deriveAuditEventId(operationId,"progress","state_transition",observedOperation.generation,observedOperation.version)` with trusted operation ID/correlation, null actor/intended-UID digests, source dispatch ID, and pre-takeover observed operation generation/version; first insert alone receives `transaction.now`, matching replay preserves `createdAt`, and any other-field mismatch rolls back all writes. After exact reread, an ordinary phase transition atomically acknowledges the source `processed` and creates/points to the deterministic next dispatch. A retained-source repeat uses the latest operation tuple and receives a distinct audit identity. The current ordinary-takeover unit combines strict-fake and minimal REAL Firestore one-winner, replay/timestamp, and rollback/atomicity proof; it remains implementation-blocked pending the measured 320/380/399 forecast. P3.29/P3.30 separately own reserved-attempt takeover plus terminalization and may later reuse this primitive without coupling.

**Decision, acceptance, and rollback:** this amendment authorizes planning only and marks no acquisition or P3.29/P3.30 task complete. The superseded A/B initial-acquisition rollback boundaries remain historical only; no takeover implementation boundary is authorized until the measured forecast fits. No Auth/profile, status, terminalization, classifier remapping, or broader P3.5–P3.10 completion is implied. Planning delta is measured from captured current bytes, never `HEAD`; no native baseline is invented.

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
- P1a2-i-B-1a/B-1b/B-2: early warning 120/120/155; STOP/reforecast 170/170/180; absolute max 200 each. Executable parent P1a2-i-B aggregate max 600; P1a2-i-C: warning 300, STOP/reforecast 350, max 400; combined P1a2-i (A-1+A-2+B+C) max 2,900. Retired B-3 has no budget or apply route. **No size:exception.**
- P1a2-ii: early warning 1,100; STOP/reforecast 1,200; absolute max 1,200. **No size:exception** — independently accepted at ordinal 105 within its 300 changed-line endpoint. Retired P1a2-iii has no guard or executable route.
- WU5–WU10: max 400 changed lines per work unit; stop at 400. **No inherited exception** — any overrun requires a new, separate maintainer decision.

## P3 Ordinary Takeover Unit — Applied, No P3 Checkbox Completion

- Implemented only the approved normal-work expired-current takeover primitive in `worker.ts` with focused fake and Firestore emulator proof.
- P3.5 and P3.6 remain globally unchecked because their acquisition/classification scope is broader than this unit.
- P3.29 and P3.30 remain unchecked and excluded: this unit neither enters reserved attempts nor terminalizes an operation.
