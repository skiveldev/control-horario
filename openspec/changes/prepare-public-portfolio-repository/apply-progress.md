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
| WU2-WU11 | Pending | No later work unit is complete |

No push or PR occurred. The original checkout remained untouched.
