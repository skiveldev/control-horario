# ODD Feature: Align Flutter CI for Portfolio Integration

## Objective

Make the existing private-repository Flutter CI validate the verified portfolio candidate rather than the older master toolchain, before any push or pull request.

## Problem and Why

The current workflow uses Flutter 3.38.1, checks formatting by a mutating command limited to `lib/`, does not run the repository sanitizer, omits `slice/**` pushes, and requires an unsigned release APK. The portfolio candidate was locally verified with Flutter 3.47.5, check-only formatting across `lib test tool`, the sanitizer, and a debug Android build; release intentionally fails closed without local signing material. The latest green GitHub run predates this candidate.

## Scope

- Change only `.github/workflows/flutter_ci.yml` as source.
- Pin Flutter 3.47.5 consistently, include `slice/**` pushes, check formatting without mutation across `lib test tool`, run the sanitizer, and use a non-signing Android debug build while preserving the existing Flutter test and web build gates.
- Remove any misleading green-ready-to-deploy claim and avoid requiring release signing secrets.
- Preserve the maintainer-approved issue #19 as the future PR linkage; approval does not authorize delivery.

## Non-goals

- No push, PR, merge, public publication, deployment, license selection, history rewrite, Firebase Console changes, or worktree cleanup.
- No change to Android signing guards or Flutter product code.
- No changes to the existing dirty master, tracker, or source worktrees.

## Constraints

- Use the clean integration worktree on local branch `ci/portfolio-flutter-gates`, based on `915fd5f`.
- Strict TDD is enabled by `openspec/config.yaml`; the exact configured runner is `flutter test`. Since this task changes only CI YAML, use a pre-edit failing structural workflow contract check and a post-edit passing check, plus relevant Flutter tests without inventing a CI runtime success.
- CodeGraph is the exclusive code-discovery tool; the current session index belongs to another worktree, so do not use it as target evidence. Direct reads of the exact known workflow/config files and exact known-file checks are allowed.
- No parallel writes. Preserve unrelated worktrees and all generated state.
- Workload forecast: approximately 30–100 authored changed lines, excluding this ODD task artifact. Strategy: `auto-chain`, `feature-branch-chain`; this focused CI work unit is a separate local commit and is not a PR.

## Acceptance Criteria

- A pre-edit structural gate fails for current stale CI configuration and the same gate passes after the change.
- The workflow retains valid YAML and necessary push/PR coverage, and all Flutter/Android checks match the verified candidate without relying on release signing secrets.
- Focused available tests and exact read-only checks pass; any unavailable live GitHub Actions run is reported pending until a separately authorized push/PR.
- A local Conventional Commit records the focused work unit and its evidence; no delivery occurs.

## Tasks

- [x] **ODD-CI-001 — Align and verify Flutter CI.** Structural RED/GREEN, YAML semantics, independent verification, and scoped diff checks pass. Completed in local work-unit commit `acc11dc9299df9332ed7b4ace9e3e34a0fb3d0e4` (`ci(flutter): align portfolio verification gates`); live GitHub Actions remains pending an authorized reviewable PR. Route: bounded writer and independent verifier; parent committed only the workflow and this task document.

## Progress

- Read-only preflight proved master and the clean integration worktree share the stale workflow; the latest green GitHub run is on older commit `05685e0`.
- Created local `ci/portfolio-flutter-gates` at `915fd5f` in the clean integration worktree without moving any existing branch. Issue #19 was separately approved by the maintainer.

## Verification Evidence

- Strict structural RED: the unchanged workflow failed six contract assertions for stale Flutter, branch coverage, mutable format, missing sanitizer, and unsigned release build. The exact same command passed all six after the YAML change.
- Independent read-only verification: YAML parsed with `yaml.BaseLoader` (`on` remains a string); four Flutter setups use 3.47.5; check-only formatting, sanitizer, test/web gates, debug APK name/path, and `analyze` dependencies are structurally consistent. `git diff --check` and the parent's separate structural spot check pass.
- Focused Flutter tests in this fresh worktree are unavailable under `--no-pub` because `.dart_tool/package_config.json` is absent. Prior source-commit evidence passed 616/616, but it is not a live CI result for this YAML. A GitHub Actions run remains pending an authorized push/PR; a push to the new `ci/**` branch alone would not trigger the current filters, while a PR targeting `master` or `feat/**` would.
- `.atl/skill-registry.md` changed incidentally outside the task scope after the clean baseline. It remains intact and excluded from staging; neither a cause nor a recovery mutation is claimed.
- Work-unit commit: `acc11dc9299df9332ed7b4ace9e3e34a0fb3d0e4`; tracking closure commit: `86e3540`. Only `.github/workflows/flutter_ci.yml` and this task document were staged. `.atl/skill-registry.md` remains modified and unstaged, excluded from both commits.
- Native review inspect did not admit this commit: its ambient target was only the unrelated `.atl/skill-registry.md` change and it stopped with `managed_assets_outdated`. No sync, START, consent, receipt, or acknowledgement occurred. A read-only committed-range ASSESS at base `915fd5f` classified the two-commit candidate high risk and directed independent verification because native review was unavailable; that verification passed. The review blocker remains explicit rather than being treated as approval.

## Next Step

The local CI correction is complete. Before any PR, derive an isolated reviewable base so the diff does not include the 49 portfolio commits, then obtain separate authorization for push/PR. GitHub master remains unchanged and live Actions is unverified.
