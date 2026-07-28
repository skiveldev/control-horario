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
| WU3-WU11 | Pending | No later work unit is complete |

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
