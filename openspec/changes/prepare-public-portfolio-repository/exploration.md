# Exploration Update: prepare-public-portfolio-repository under Gentle AI v2.2.0

## Version-Impact Matrix

| v2.2.0 PR/Commit | Feature | Impact on Current Change |
|---|---|---|
| #1638 / 61ef804 | Windows drive Object Manager reparse fix | **Unblocks** native `review start` on this Windows system. Original blocker resolved; review-544ad22fd4046a93 proves it works. |
| #1591 / 4907129 | Review start recovery provenance | **Strengthens** review resume after interruption; lineage provenance now durable. |
| #1588 / 74f6130 | Windows artifact manifest (BOM-safe) | **Fixes** BOM-safe artifact manifest ingestion on Windows. This is a general Windows reliability fix for review manifest handling; it is unrelated to the unauthorized lineage incident. |
| #1594 / 47b1513 | Review cwd locator storage | **Fixes** worktree-based review locator; relevant for isolated worktree path. |
| #1620 / 08bec1b | Preserved SDD attempt budget | **Mandatory** for future continuations: cumulative attempt budget survives across apply batches. |
| #1706 / 1f3fda4 | Git authority root resolution | **Fixes** worktree common-dir resolution; review authority now correctly binds to worktree scenarios. |
| #1708 / 48c428f | Provider apply context forwarding | **Fixes** apply context propagation; future `sdd-apply` continuations receive correct context. |
| #1714 / 942a395 | Common-dir identity binding | **Fixes** Git common-dir identity for review transactions; relevant since worktree shares `.git` with main checkout. |
| #1715 / e296d98 | Git-scoped binding | **Fixes** SDD binding discovery scoped to Git paths; prevents stale bindings from leaking across worktrees. |
| #1758 / 2da330e | Staged-scope recovery | **Fixes** scope expansion diagnostics; relevant when work units grow beyond initial scope. |
| #1693 / d4b1b10 | Final verification retry | **Strengthens** verify-phase resilience; final verification can retry without losing evidence. |
| feat(sdd) / c38c4fe | Native `sdd-attempt` CLI | **MANDATORY** for future runtime-bearing apply/verify: `gentle-ai sdd-attempt status/begin/finish` is the sole runtime authority. |
| fix(sdd) / 8071d27 | Attempt ledger keyed by work_unit | **Mandatory**: attempt tracking is keyed by work unit, not caller-authored counters. |
| fix(sdd) / 6da3ff0 | Cumulative runtime-attempt budget preservation | **Mandatory**: budget survives across continuations. |
| fix(sdd) / 56ecf8d | Route continuations through native runtime authority | **Mandatory**: all apply/verify continuations go through native runtime. |
| fix(sdd) / fe62ceb | Validate verify reports before persistence | **Strengthens** verify-phase admission; `gentle-ai sdd-verify-validate` validates before persistence. |

### Unauthorized Lineage Incident - Separate Root Cause

The unauthorized lineage `review-e8b86ef3f75f6020` was caused exclusively by a workflow routing failure: `opencode run --agent review-reliability` rejected the hidden `review-reliability` subagent and fell back to the default agent, which independently called `review start` outside the intended orchestration path. This is an agent-routing incident, not a gentle-ai bug. PR #1588 (BOM-safe manifests) is a separate Windows reliability improvement and did not cause or prevent this incident. The recommended mitigation is orchestration-level: use the direct Task reviewer route; never recommend `opencode run --agent` for hidden review subagents.

## Native Runtime Attempt Authority

### Current State
```
gentle-ai sdd-attempt status --cwd D:\control_horario --change prepare-public-portfolio-repository
-> next_ordinal: 1, cumulative_attempts: 0, decision_required: false, next_action: begin
```

### Implications
- Work unit 1 was completed BEFORE `sdd-attempt` existed. No attempt was recorded.
- Future runtime-bearing continuations (work units 2-11) MUST call `gentle-ai sdd-attempt begin` before work and `finish` after.
- The native ledger is the SOLE authority for ordinals, cumulative budgets, and runtime evidence.
- Caller-authored attempt counters in apply-progress artifacts are now advisory-only, not authoritative.
- Work unit 1's completion without a recorded attempt is acceptable; it predates the feature. No retroactive attempt creation is needed.

## Architecture Assessment (Proposal/Spec/Design)

### Still Valid - No Change Required

| Decision | Status | Rationale |
|---|---|---|
| Admin panel -> callable trusted backend -> Admin SDK | Valid | v2.2.0 changes no provisioning architecture. |
| No plaintext passwords | Valid | Design invariant #2 unchanged. |
| Role allowlist (employee, rrhh only) | Valid | Least privilege unchanged. |
| Idempotency via caller key + fingerprint | Valid | Design invariant #6 unchanged. |
| Auth/Firestore saga (compensate on batch failure) | Valid | Design invariant #1 unchanged. |
| Atomic Firestore batch + audit in one commit | Valid | Design invariant #1 unchanged. |
| Repository-only portfolio (no live demo claim) | Valid | Spec requirement unchanged. |
| Cloud Functions v2 callable | Valid | No runtime platform change. |
| Protected path immutability | Valid | `.atl/*` and `app_colors.dart` still protected. |
| Feature-branch-chain topology | Valid | v2.2.0 changes no PR strategy. |

### Architecture Risks Unchanged

- Reachable Git history still contains credentials (out of scope).
- Provisioning gap: no backend in repo + hardened rules = non-functional admin UI against deployed rules.
- Firebase Console state unprovable from repo.
- License, history cleanup, Console hardening remain publication gates.

## Task Topology under v2.2

### Assessment: 11 Work Units Remain Proportionate - But Tasks Artifact MUST UPDATE

| Factor | Assessment |
|---|---|
| Feature-branch-chain | Still valid strategy. |
| <=400 authored lines per unit | Still the hard contract. WU1 (114 authored lines) well under. |
| Committed parent boundary before WU2 | **MUST enforce**: WU1 is uncommitted. WU2 MUST NOT begin until WU1 reviewed paths are staged without byte/mode changes, native `pre-commit` gate validates the approved receipt, and the user separately authorizes commit. |
| Staged/receipt gate | APPROVED receipt on `review-544ad22fd4046a93` is the WU1 gate. |
| `sdd-attempt` integration | **MUST add**: future WUs must use native attempt control. |
| 11 units proportionate | No re-split needed. Each unit is a deliverable behavior. |

### Task Artifact: MUST UPDATE Before WU2

The task topology (11 units, phases 1-7) is correct and requires no splitting or merging. However, the tasks artifact itself MUST be updated before WU2 begins, with the following additions:

1. **Native `sdd-attempt` gates**: Every future runtime-bearing apply, verify, or remediation work unit MUST use `gentle-ai sdd-attempt status/begin/finish`, keyed by this change (`prepare-public-portfolio-repository`) and the specific work unit. No caller-authored attempt counters; the native ledger is the sole authority for ordinals and cumulative budgets.

2. **WU1 approved target scope recorded**: The APPROVED receipt (`review-544ad22fd4046a93`) covers two paths: generated intended-untracked `.codegraph/.gitignore` (5 lines) and deletion of accidental `tatus` (114 lines). Total: 119 changed lines, 114 authored. Risk level: medium. Lens: reliability. Zero findings. Terminal state: approved.

3. **Parent-boundary rule (feature-branch-chain)**: Because feature-branch-chain is the selected strategy and WU1 is currently uncommitted in the worktree, WU2 MUST NOT begin until:
   - WU1 reviewed paths are staged in the worktree without byte/mode changes from the approved candidate tree `fd7b9edf6ac444e6f122b5f0dc929f38c0da8f36`.
   - Native `pre-commit` gate validates the approved receipt against the staged candidate.
   - The user separately and explicitly authorizes the commit. No commit/stage/push/PR/deploy is currently authorized.

4. **Direct Task reviewer route (orchestration constraint)**: Future review continuations MUST use the direct Task reviewer route only. Never recommend `opencode run --agent` for hidden review subagents. This is an orchestration/workflow constraint, not a product or source-code task.

## Apply-Progress Inaccuracies and Drift

### MUST Fix (factual errors)

| # | Issue | Current (wrong) | Correct Evidence |
|---|---|---|---|
| 1 | `git ls-files tatus` GREEN claim | `"git ls-files tatus" -> ""` | `git ls-files tatus` still returns `tatus` (deletion is unstaged in working tree, not yet added to index). The reliable evidence is: `Test-Path tatus = False`, `git diff --name-status = D tatus`, `git diff --numstat = 0/114`, `git diff --check = 0`, protected path diff count = 0. |
| 2 | `.codegraph/.gitignore` omitted from scope | Apply-progress mentions only `tatus` | The APPROVED review receipt (`review-544ad22fd4046a93`) covers BOTH `.codegraph/.gitignore` (5 lines, generated, intended-untracked) AND `tatus` (deletion). The `.codegraph/.gitignore` is generated (not authored), but it IS part of the reviewed candidate scope. |
| 3 | Line count attribution | "Authored: 114 deletions (1 file: tatus)" | Authored count is correctly 114 deletions. But the review covered 119 total changed lines (114 authored + 5 generated `.codegraph/.gitignore`). The distinction matters for the budget. |
| 4 | Review receipt state missing | Not mentioned | The APPROVED receipt on lineage `review-544ad22fd4046a93` with generation 1, risk level `medium`, lens `review-reliability`, 0 findings, is the authoritative gate for work unit 1. This must be recorded. |
| 5 | Worktree status description | "ONLY work-unit-1 authored change (unstaged deletion)" for `tatus` | Must also note `.codegraph/` is untracked and generated (excluded from authored scope but present in review candidate). |

### SHOULD Fix (context gaps)

| # | Issue | Recommendation |
|---|---|---|
| 6 | No mention of `sdd-attempt` for future continuations | Add a note: future apply batches (WU2+) must use `gentle-ai sdd-attempt begin/finish` keyed by change + work unit. |
| 7 | Unauthorized lineage not mentioned | Add note: `review-e8b86ef3f75f6020` (stuck `reviewing`, no receipt) exists but does NOT affect the current APPROVED receipt. It is a stale artifact from the `opencode run --agent` routing incident. |
| 8 | Protected baseline verification method | Add the specific commands used: `git diff HEAD -- .atl/skill-registry.md lib/core/theme/app_colors.dart` and hash comparison. |

## Stale Unauthorized Review Lineage

### Lineage `review-e8b86ef3f75f6020`

| Property | Value |
|---|---|
| State | `reviewing` (stuck; never completed) |
| Generation | 1 |
| Lens results | None (empty) |
| Findings | None |
| Receipt | None |
| Paths | `.atl/.skill-registry.cache.json`, `.atl/skill-registry.md`, `.codegraph/.gitignore`, `tatus` |
| Changed lines | 213 (original) |

### Assessment

- **Does NOT affect current target/receipt**: The APPROVED receipt on `review-544ad22fd4046a93` is authoritative, valid, and covers the correct intended scope. `review status` selects the approved lineage as current target.
- **Cause**: `opencode run --agent review-reliability` rejected the hidden subagent and fell back to the default agent, which independently called `review start`. This is an agent-routing incident, not a gentle-ai bug.
- **`.atl` impact**: The unauthorized run refreshed protected `.atl` files. These were explicitly restored/removed; intended target bytes were recovered.
- **Recommended follow-up**: Defer. The lineage is inert (no results, no receipt). It may be cleaned up later as a follow-up but does not block any work. Do NOT act on this lineage during exploration or apply.
- **Orchestration mitigation**: Use the direct Task reviewer route only; never recommend `opencode run --agent` for hidden review subagents.
- **Risk**: Low. The lineage is inert and does not block any future work.

## Exact Artifact Update List

### MUST Update Before WU2

**Artifact: `sdd/prepare-public-portfolio-repository/apply-progress`** (5 corrections)

1. Fix `git ls-files tatus` evidence: replace `"git ls-files tatus" -> ""` with reliable evidence set: `Test-Path tatus = False`, `git diff --name-status = D tatus`, `git diff --numstat = 0/114`, `git diff --check = 0`, protected path diff count = 0.
2. Add `.codegraph/.gitignore` to WU1 scope as generated/intended-untracked (not authored, but reviewed in receipt).
3. Record APPROVED review receipt: lineage `review-544ad22fd4046a93`, generation 1, risk `medium`, lens `review-reliability`, 0 findings, `terminal_state: approved`.
4. Add `sdd-attempt` integration note: future continuations (WU2+) must use `gentle-ai sdd-attempt begin/finish` keyed by change + work unit.
5. Note stale unauthorized lineage `review-e8b86ef3f75f6020` (inert, does not affect current receipt, deferred).

**Artifact: `sdd/prepare-public-portfolio-repository/tasks`** (4 additions)

1. Add native `sdd-attempt status/begin/finish` gates for every future runtime-bearing apply/verify/remediation work unit, keyed by change + work unit; no caller-authored attempt counters.
2. Record WU1 approved target scope (`.codegraph/.gitignore` + `tatus`), 119 total / 114 authored lines, approved lineage `review-544ad22fd4046a93` with receipt.
3. Add explicit parent-boundary rule: because feature-branch-chain is selected and WU1 is uncommitted, WU2 MUST NOT begin until WU1 reviewed paths are staged without byte/mode changes, native `pre-commit` gate validates the approved receipt, and the user separately authorizes commit. No commit is currently authorized.
4. Record direct Task reviewer route as an orchestration constraint (not a product/source task).

### SHOULD Update

**Artifact: `sdd/prepare-public-portfolio-repository/explore`** (this artifact)
- Updated with v2.2.0 version-impact matrix, corrected #1588 attribution, `sdd-attempt` integration, task MUST-UPDATE, and ordered decision sequence.

### No Change Required

| Artifact | Reason |
|---|---|
| `sdd/prepare-public-portfolio-repository/proposal` | Architecture decisions, scope, capabilities, risks all valid. |
| `sdd/prepare-public-portfolio-repository/spec` | All requirements and scenarios valid under v2.2.0. |
| `sdd/prepare-public-portfolio-repository/design` | Technical approach, data flow, contracts, testing strategy, invariants all valid. |

## Next Interactive Decisions - Ordered and Atomic

The following decisions are SEQUENTIAL. Each must complete before the next begins. No decision may be skipped or combined.

### A. Authorize metadata-only Engram corrections
Authorize corrections to `sdd/prepare-public-portfolio-repository/tasks` and `sdd/prepare-public-portfolio-repository/apply-progress` in Engram. These are metadata-only: they fix evidence accuracy, add receipt state, add `sdd-attempt` gates, and record the parent-boundary rule. No repository, review, or runtime mutations occur.

### B. Authorize WU1 staging + pre-commit validation + commit
After (A) is complete, decide whether to authorize staging WU1 reviewed paths in the worktree, running native `pre-commit` receipt validation, and committing on `feat/prepare-public-portfolio`. This establishes the committed parent boundary required by feature-branch-chain before any WU2 work. **No push, PR, deploy, or visibility change is included.** This decision is separate from (C) and must complete first.

### C. Authorize WU2 under native attempt authority
Only AFTER (B) produces a committed parent boundary: authorize work unit 2 ("Seed-script credential purge", tasks 2.1-2.2, ~293 authored lines). This continuation will use `gentle-ai sdd-attempt begin` for the work unit. Cannot proceed until (B) is done.

### D. Stale unauthorized lineage - deferred
The stale lineage `review-e8b86ef3f75f6020` may be deferred. Current-target status selects the approved lineage. Document it as a follow-up item for future cleanup. No action required in the current apply/verify cycle.

## Risks

- **Apply-progress evidence drift**: Factual errors (#1, #2, #4) cause confusion during verify/archive if uncorrected.
- **Task artifact missing runtime gates**: Without `sdd-attempt` gates and parent-boundary rule recorded, future apply continuations may bypass native authority or start WU2 before WU1 commit.
- **Stale lineage visibility**: `review-e8b86ef3f75f6020` appears in `review status` as `active`. Low risk; inert, no receipt, does not block work.
- **WU1 not in native attempt ledger**: WU1 predates `sdd-attempt`. Acceptable; no retroactive creation needed, but future WUs must begin attempts.
- **Protected path hashes**: Hashes from the original dirty checkout. If the checkout is modified before apply continues, hashes become stale. Current hashes valid as of this assessment.
- **No commit authorized**: WU1 changes remain uncommitted in the worktree. APPROVED receipt gates the commit, but the commit itself requires separate user authorization.

## Ready for Next Phase

**Yes; exploration update is complete and corrected.** The orchestrator should present decision (A) to the user: authorize metadata-only Engram corrections to tasks and apply-progress. Decisions (B), (C), and (D) follow sequentially after (A) completes.

## Migration / Final-State Note

The preceding exploration is the extracted historical snapshot. Its statements that WU0/WU1 were uncommitted and that decisions A/B remained pending were superseded before this OpenSpec migration:

- WU0 committed locally as `4915419` and correction commit `3e9146f`; final hook behavior passed formatting and `flutter analyze` with no issues.
- WU0 final approved lineage is `review-3b4a3a0f30245bc4`; the final correction worktree was clean at HEAD `3e9146f`, tree `448709be0613f746acfe168e0880e252d393dc10`.
- WU0.1 used native max 120 and finished at 116 lines; WU0.2 used max 10 and finished at 10 lines.
- WU1 advanced compatibly to base `3e9146f`; `.codegraph/.gitignore` became part of the WU0 base, leaving only deletion of `tatus` in the final WU1 delta.
- WU1 committed locally as `7772e14`; final approved lineage is `review-3447c0e8c1233521`; final tree is `b57799d0b19124e4d27c1c9d0370f0c18781e9d0`.
- No push or PR occurred. The original checkout remained untouched. WU2-WU11 remain pending and continue under native attempt authority.
