# Tasks: Prepare Public Portfolio Repository

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: High (WU0: maintainer-approved size:exception <=800)

## Delivery & Runtime

Auth for WU0 worktree+branch. WU0 review/commit first, then escrow WU1 patch (`.codegraph/.gitignore` A + `tatus` D) hashed; clear only those paths; advance base to WU0 commit; reapply patch, verify identity/revalidation; WU1 commit under existing/renewed auth. WU2 blocked until WU1 parent. Every runtime-bearing WU: `gentle-ai sdd-attempt status/begin/finish` keyed by change+work unit. Native ledger sole authority; no caller counters. Direct Task reviewer; no `opencode run --agent`/skip-hooks.

## WU0 - Attempt 2: CANDIDATE (maintainer size:exception <=800)

Attempt 1: FAILED (658 lines, over 400 budget; formatter-unavailable RED skipped; evidence invalidated). Attempt 2 diff: `.githooks/pre-commit` (32A/72D), `.githooks/pre-commit.bat` (27A/50D), `tool/check_staged_dart_format.dart` (171A), `test/tool/check_staged_dart_format_test.dart` (307A) = 659 authored (537A+122D). Maintainer-approved size:exception <=800. Formatter-unavailable RED implemented (DART_FORMAT_BIN env override; ProcessException caught). Worktree: `C:\Users\Skivel\control-horario-worktrees\precommit-hook-fix`, branch `fix/pre-commit-staged-check`, HEAD `05685e0`. Unstaged/uncommitted (pause before stage/commit per auth).

Native attempt 2: ordinal 2, generation 2, objective `sha256:4c02a19a...`, revision `sha256:c9952b1b...`. Ledger reports changed_lines 0 (wrong-cwd from attempt 1 defect); verified diff is 659.

## WU1 Scope & Gate

`.codegraph/.gitignore` (5) + `tatus` (114) = 2 paths / 119 changed / 114 authored. Lineage `review-544ad22fd4046a93`; post-apply allow.

## Tasks

### WU0 - Pre-commit hook correction

- [x] 0.1 RED: 15 integration test cases in temp Git repos covering all threat-matrix scenarios (no-staged, non-Dart, WU1-like, formatted, unformatted+no-mutation, staged+unstaged fail-closed, spaces, Unicode, deleted, renamed, nested cwd, non-repo, multi-file, index-immutability, formatter-unavailable with DART_FORMAT_BIN override). 20 assertions.
- [x] 0.2 GREEN: `tool/check_staged_dart_format.dart` (171 lines) - NUL-safe ACMR, staged+unstaged guard, DART_FORMAT_BIN env override with secure default, ProcessException catch, check-only formatter via argument list, never writes/stages/resolves. Hooks invoke helper then `flutter analyze --no-pub --fatal-infos --fatal-warnings`.
- [x] 0.3 REFACTOR: Removed unused imports; tightened messages; all 15 cases/20 assertions pass.

### WU1

- [x] 1.1-1.6: Worktree, audit ledger, patch identity, `tatus` deletion, protected-path verify, pause.

### WU2+

- [ ] WU2 / tasks 2.1-2.2: Seed-script credential purge.
- [ ] WU3 / tasks 3.1-3.2: Deployment documentation and Firestore rules.
- [ ] WU4 / task 4.1: Trusted backend provisioning TDD.
- [ ] WU5 / task 5.1: Admin client provisioning TDD.
- [ ] WU6 / task 6.1: Android release-signing guard.
- [ ] WU7 / task 6.2: Generic organization de-branding while retaining application name.
- [ ] WU8 / task 7.1: Repository sanitization and protected-path checks.
- [ ] WU9 / task 7.2: Portfolio README rewrite.
- [ ] WU10 / task 7.3: Docs/archive removal plus secret scan.
- [ ] WU11 / task 7.4: Publication-gates documentation and final no-publication boundary.

**Forbidden**: no push, PR, deploy, visibility, history rewrite, account actions, skip-hooks, `opencode run --agent`.

## Migration / Final-State Note

The preceding text is the extracted task snapshot and remains historical evidence. The following later facts are authoritative for continuation:

- WU0 is complete. It was committed locally as `4915419` and corrected by local commit `3e9146f`. Final hook behavior passed formatting and `flutter analyze` with no issues.
- WU0 final approved lineage is `review-3b4a3a0f30245bc4` for the final correction target. Its worktree was clean at HEAD `3e9146f`, tree `448709be0613f746acfe168e0880e252d393dc10`.
- WU0.1's native bounded attempt used max 120 and finished at 116 lines. WU0.2 used max 10 and finished at 10 lines.
- WU1 is complete. Its base advanced compatibly to `3e9146f`; `.codegraph/.gitignore` became part of the WU0 base, so WU1's final delta was only deletion of `tatus`.
- WU1 was committed locally as `7772e14`; final approved lineage is `review-3447c0e8c1233521`; final tree is `b57799d0b19124e4d27c1c9d0370f0c18781e9d0`.
- No push or PR occurred. The original checkout remained untouched.
- All WU2-WU11 tasks remain pending. The forbidden-operation and native-attempt constraints remain in force.
