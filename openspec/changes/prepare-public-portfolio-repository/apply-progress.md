# Apply Progress: Prepare Public Portfolio Repository

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
