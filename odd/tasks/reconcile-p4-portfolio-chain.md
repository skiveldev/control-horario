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

- Worktree: `<reconciled-worktree>`.
- Branch: `integration/portfolio-p4-flutter-compat`.
- Original source tip: `915fd5f1f0a0b59e9963c2469764d7985d005f48`.
- Original CI tip: `633225431bc69592553467e2db7cf2eaabef6d65`.
- Flutter 3.41.9 SDK: `<flutter-3.41-sdk>`.
- Flutter 3.47.5 SDK: `<flutter-sdk>`.
- Android SDK: `<android-sdk>`.
- JDK 21: `<jdk-21>`.
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
- [x] **ODD-CHAIN-003 — Materialize WU6 through the final source tip.** Replayed WU6, advanced `eb40134` immediately after the branding implementation, replayed the remaining source commits while skipping all five original WU10 positions, and replayed final-gate documentation. The WU6 checkpoint passed 9/9 branding tests, 612/612 full tests, fatal analysis, and diff-check. The final source checkpoint passed sanitizer, 273-file format check, 616/616 full tests, fatal analysis, 64/64 Firestore rules tests, debug APK assembly, expected release-signing fail-closed, and committed-range diff-check. Final source semantics differ from historical `915fd5f` only on the intended compatibility, CI transition, reordered stabilization, ODD ledger, and `.atl` untracking surfaces.
- [x] **ODD-CHAIN-004 — Materialize final CI and close the chain.** Replayed `acc11dc` at `c0ba541` with byte-identical accepted workflow content, replayed its two documentation commits at `0abd032` and `7e8b6a8`, completed the mapping ledger, and ran final independent verification. The workflow has exact final semantics, sanitizer and 273-file format checks pass, source differences remain confined to documented compatibility/replay surfaces, and original worktree refs remain unchanged.

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
| `e6c2dae` | `4950632` | WU6 branding implementation |
| `eb40134` | `873aac2` | Immediately after replayed `e6c2dae` |
| `3ac85d6` | `b179389` | WU6 closure |
| `5b5f57c` | `8794ea6` | WU5 exact Android transition |
| new transition | `e04e741` | CI Flutter 3.47.5 and Android debug artifact |
| `b9c7a3b` | `5132b4a` | WU5 closure |
| new transition | `7b0263b` | Exact WU5/final Flutter 3.47.5 lockfile resolution |
| `edaf2ce` | `47c4493` | Sanitization scanner |
| `6d4203a` | `81daac8` | Portfolio configuration sanitization |
| `4f24beb` | `ff90fad` | Sanitization slice evidence |
| `fa5d3df` | `29b2655` | Deployment quickstart replacement |
| `b5efba9` | `514c2e4` | Deployment claim retirement |
| `f835de5` | `10190bc` | Sanitization closure |
| `194b474` | `f5abdd6` | Portfolio README |
| `47d07e3` | `1fa28aa` | README evidence |
| `146390a` | `b10fa27` | Archive removal |
| `aa42d24` | `ee9cdf6` | README/archive closure |
| `915fd5f` | `5d3255c` | Final source-gate evidence; original WU10 fixes skipped because advanced |
| `acc11dc` | `c0ba541` | Final exact CI workflow; blob-identical |
| `86e3540` | `0abd032` | Final CI closure |
| `6332254` | `7e8b6a8` | CI review-stop evidence |

## Verification Evidence

- Read-only mapping proved 31 commits follow P4-T1 through final CI.
- Only WU5 overlaps Android compatibility files and final CI overlaps the workflow.
- No later historical commit touches `.atl/skill-registry.md`.
- CodeGraph semantic mapping supports the five advanced placements; runtime verification remains required before completion.
- Early checkpoint: full Flutter suite 576/576, focused widget/tool suite 36/36, fatal analysis, and diff-check passed under Flutter 3.41.9.
- P4 checkpoint: dependency/registrant hashes remained stable after `pub get`; full Flutter suite 608/608; focused provisioning/drawer suite 53/53; fatal analysis; 269-file format check; Firestore rules 64/64; Android debug APK `build/app/outputs/flutter-apk/app-debug.apk` (164,183,518 bytes); and diff-check passed.
- Ignored outputs retained: `node_modules/`, `build/`, and `firestore-debug.log`. `.atl/skill-registry.md` remains local, ignored, and untracked.
- WU5 checkpoint: exact Android path blobs match historical `5b5f57c`; workflow has four Flutter 3.47.5 pins and a debug APK artifact; lockfile matches historical WU5/final bytes. After `flutter clean`, shader regressions passed 14/14 and 7/7, full Flutter passed 608/608, fatal analysis passed, debug APK `build/app/outputs/flutter-apk/app-debug.apk` was 170,269,367 bytes, release failed closed only for missing signing properties, and Gradle reported 9.3.1 on JDK 21. The known analyzer migration and generated `android/build/` were removed under explicit authorization. `android/gradlew.bat` remains byte-identical to WU5 and carries its inherited 90 CRLF `diff --check` warnings as an explicit generated-wrapper exception.
- Native four-lens review `review-b6948162ea7de328` approved the WU5 slice and acknowledgement burned authority. Four advisory findings remain informational follow-ups around signing configuration readability/reliability/resilience; none opened correction.
- WU6 checkpoint: branding tests 9/9, full Flutter 612/612, fatal analysis, and committed-range diff-check passed.
- Final source checkpoint: sanitizer passed after replacing eight user-machine paths in ODD docs with portable placeholders; format checked 273 files; full Flutter passed 616/616; fatal analysis and Firestore rules 64/64 passed; debug APK assembly produced 170,756,392 bytes; release failed closed only for missing signing properties; committed-range diff-check passed. The recurring analyzer migration and generated `android/build/` were removed after verification.
- Final CI: replayed workflow blob `a74dbe0` is byte-identical to historical `acc11dc`, with four Flutter 3.47.5 pins, check-only format across `lib test tool`, sanitizer, tests, debug APK artifact, web release build, and analyze dependencies. Final independent verification passed sanitizer, 273-file format check, committed and working diff-check, source/path isolation, worktree isolation, and workflow semantics. A live GitHub Actions run remains unavailable until separately authorized delivery.
