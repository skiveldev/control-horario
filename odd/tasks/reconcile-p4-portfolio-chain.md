# ODD Feature: Reconcile the P4 Portfolio Chain

## Objective

Materialize a new isolated portfolio integration chain that preserves the accepted historical work units, inserts the verified Flutter 3.41.9 P4 compatibility boundary, advances the five WU10 stabilizations to their earliest safe positions, and transitions CI/toolchains without weakening gates.

## Scope

- Start from compatibility tip `6167e67f0ba98d2d0cb8239900e8cb2d26fc6a28`.
- Replay the 31 historical commits after P4-T1 through final CI tip `633225431bc69592553467e2db7cf2eaabef6d65` using controlled cherry-picks.
- Advance `811f8c2`, `e9aa90e`, and `45e4420` immediately after the compatibility base.
- Advance `40e2693` immediately after replayed P4 final-gate commit `16a8195`.
- Advance `eb40134` immediately after replayed WU6 branding commit `e6c2dae`.
- At WU5, replace the transitional P4 Android configuration with the exact accepted WU5 Android bytes.
- Insert a CI transition at WU5: Flutter 3.47.5 plus Android debug APK/artifact behavior.
- At final CI, preserve the exact accepted workflow bytes from `acc11dc`.
- Record every original-to-replay commit mapping.

## Non-goals

- Do not mutate, reset, rebase, delete, or force-update any original branch or worktree.
- Do not weaken tests, analyzer, sanitizer, signing, or review gates.
- Do not push, open pull requests, merge, deploy, or publish.
- Do not rewrite historical OpenSpec or ODD evidence to pretend replay hashes are original authoring identities.

## Constraints

- Worktree: `/home/skivel/control-horario-worktrees/portfolio-p4-flutter-reconciled`.
- Branch: `integration/portfolio-p4-flutter-compat`.
- Original source tip: `915fd5f1f0a0b59e9963c2469764d7985d005f48`.
- Original CI tip: `633225431bc69592553467e2db7cf2eaabef6d65`.
- Flutter 3.41.9 SDK: `/home/skivel/.local/share/flutter-3.41.9`.
- Flutter 3.47.5 SDK: `/home/skivel/.local/share/flutter`.
- Android SDK: `/home/skivel/.local/share/android-sdk`.
- JDK 21: `/home/skivel/.local/share/jdk-21`.
- Stop on any conflict outside the predicted WU5 Android and final CI workflow surfaces.
- Use exact source blobs for predicted conflict resolution; do not hand-merge accepted behavior.
- Use CodeGraph exclusively for code discovery and GitHub CLI exclusively for GitHub access.

## Acceptance Criteria

- Original branches and worktrees remain unchanged.
- `.atl/skill-registry.md` remains untracked and ignored throughout the new chain.
- Every replayed commit has an original-to-replay entry in the ledger.
- Early stabilization checkpoint passes the full Flutter suite and focused tool/widget checks under Flutter 3.41.9.
- P4 checkpoint passes P4 focused gates, fatal analysis, format/diff checks, Firestore rules, and Android debug assembly under the verified 3.41.9 compatibility stack.
- WU5 checkpoint uses exact accepted Gradle 9.3.1, AGP 9.1.0, KGP 2.4.0, JVM 17, and release-signing behavior; CI uses Flutter 3.47.5 and Android debug artifacts.
- WU6 checkpoint passes branding verification after the advanced sidebar contract fix.
- Final checkpoint matches the accepted final source and CI semantics, passes the full configured gates, and has no unintended tracked or untracked candidate paths.
- Independent verification confirms ordering, scope, ledger completeness, and transition semantics.

## Tasks

- [x] **ODD-CHAIN-001 — Materialize the stabilized P4 chain.** Planned at `d79f6c3`, advanced the three base-safe WU10 fixes, replayed P4 through `16a8195`, advanced `40e2693`, and replayed the P4 closure. The early checkpoint passed 576 full tests, 36 focused tests, fatal analysis, and diff-check. The final P4 checkpoint passed 608 full tests, 53 focused tests, fatal analysis, 269-file format check, 64 Firestore rules tests, Android debug assembly, dependency reproducibility, and diff-check. Root `npm ci` reported 12 dependency audit findings (9 moderate, 2 high, 1 critical) without changing tracked manifests; dependency remediation is outside this replay task.
- [x] **ODD-CHAIN-002 — Materialize WU5 and its CI transition.** Replayed WU5 at `8794ea6` using exact accepted Android bytes, added the bounded Flutter 3.47.5/debug-APK CI transition at `e04e741`, replayed the WU5 closure at `5132b4a`, and recorded the exact Flutter 3.47.5 resolver state at `7b0263b`. After cleaning stale Flutter 3.41 outputs, focused shader regressions passed 14/14 and 7/7, the full suite passed 608/608, fatal analysis passed, debug APK assembly succeeded, release assembly failed closed exactly for missing `release-signing.properties`, and Gradle 9.3.1 ran on JDK 21. The original Windows wrapper batch has 90 CRLF `diff --check` warnings in both historical and replay commits; its bytes remain exact by explicit maintainer decision rather than silently normalizing the generated wrapper.
- [ ] **ODD-CHAIN-003 — Materialize WU6 through the final source tip.** Replay WU6, advance `eb40134`, replay the remaining source commits while skipping all five original WU10 positions, replay final-gate documentation, record mappings, and verify WU6 plus the final source checkpoint.
- [ ] **ODD-CHAIN-004 — Materialize final CI and close the chain.** Replay `acc11dc` using its exact accepted workflow bytes, replay its two documentation commits, complete the mapping ledger, run final independent verification, and record closure evidence.

## Replay Ledger

Original hashes identify historical source artifacts and remain provenance evidence. Replay hashes identify delivery artifacts in this reconciled chain; they do not replace the originals.

| Original commit | Replay commit | Placement / note |
| --- | --- | --- |
| `811f8c2` | `7de3d1e` | Immediately after compatibility base |
| `e9aa90e` | `223553d` | Immediately after compatibility base |
| `45e4420` | `1225076` | Immediately after compatibility base |
| `f7b1e1a` | `0ea514e` | P4 callable contracts |
| `4880bc1` | `e6b958b` | P4 transport closure |
| `6d55f69` | `2338c1d` | P4 resilient polling |
| `da77c4b` | `e458dea` | P4 employee creation UX |
| `3f6e730` | `d29e9e6` | P4 direct-creation retirement |
| `1ae782e` | `1bd4ac8` | P4 Firestore hardening |
| `16a8195` | `17fcf26` | P4 final gates |
| `40e2693` | `ab14a59` | Immediately after replayed `16a8195` |
| `3a4e281` | `98d140f` | P4 closure |
| `eb40134` | pending | Immediately after replayed `e6c2dae` |
| `5b5f57c` | `8794ea6` | WU5 exact Android transition |
| new transition | `e04e741` | CI Flutter 3.47.5 and Android debug artifact |
| `b9c7a3b` | `5132b4a` | WU5 closure |
| new transition | `7b0263b` | Exact WU5/final Flutter 3.47.5 lockfile resolution |
| `acc11dc` | pending | Final exact CI workflow |
| Remaining historical commits | pending | Preserve original order, skipping advanced positions |

## Verification Evidence

- Read-only mapping proved 31 commits follow P4-T1 through final CI.
- Only WU5 overlaps Android compatibility files and final CI overlaps the workflow.
- No later historical commit touches `.atl/skill-registry.md`.
- CodeGraph semantic mapping supports the five advanced placements; runtime verification remains required before completion.
- Early checkpoint: full Flutter suite 576/576, focused widget/tool suite 36/36, fatal analysis, and diff-check passed under Flutter 3.41.9.
- P4 checkpoint: dependency/registrant hashes remained stable after `pub get`; full Flutter suite 608/608; focused provisioning/drawer suite 53/53; fatal analysis; 269-file format check; Firestore rules 64/64; Android debug APK `build/app/outputs/flutter-apk/app-debug.apk` (164,183,518 bytes); and diff-check passed.
- Ignored outputs retained: `node_modules/`, `build/`, and `firestore-debug.log`. `.atl/skill-registry.md` remains local, ignored, and untracked.
- WU5 checkpoint: exact Android path blobs match historical `5b5f57c`; workflow has four Flutter 3.47.5 pins and a debug APK artifact; lockfile matches historical WU5/final bytes. After `flutter clean`, shader regressions passed 14/14 and 7/7, full Flutter passed 608/608, fatal analysis passed, debug APK `build/app/outputs/flutter-apk/app-debug.apk` was 170,269,367 bytes, release failed closed only for missing signing properties, and Gradle reported 9.3.1 on JDK 21. The known analyzer migration and generated `android/build/` were removed under explicit authorization. `android/gradlew.bat` remains byte-identical to WU5 and carries its inherited 90 CRLF `diff --check` warnings as an explicit generated-wrapper exception.
