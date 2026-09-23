# ODD Feature: Align P4 Flutter Compatibility

## Objective

Make the P4-T1 slice reproducibly validate with Flutter 3.41.9 / Dart 3.11.5 without pulling the full WU5 Android migration forward.

## Scope

- Pin the existing Flutter CI workflow to Flutter 3.41.9 at the P4-T1 boundary.
- Keep Gradle 8.12 and Android Gradle Plugin 8.7.3.
- Upgrade the Kotlin Gradle Plugin from 2.1.0 to 2.3.0.
- Replace the rejected legacy Kotlin `jvmTarget` string DSL with typed `compilerOptions` and `JvmTarget.JVM_11`.
- Preserve the Flutter 3.41.9 lockfile resolution and reproducible tracked desktop plugin registrants.
- Verify focused P4-T1 tests, fatal analysis, dependency reproducibility, and Android debug assembly with the isolated SDK/JDK toolchain.

## Non-goals

- Do not pull forward the WU5 Gradle 9.3.1, AGP 9.1.0, KGP 2.4.0, signing, or built-in Kotlin migration.
- Do not include `.atl/**`, `android/local.properties`, SDK/JDK installations, APKs, build outputs, or unrelated generated files.
- Do not push, open a pull request, merge, publish, or modify another worktree.

## Constraints

- Base commit: `276ad35dd3b297fee0a67d5c5c82467bc1137f10` (`feat(provisioning): add trusted callable transport`).
- Feature branch: `build/p4-flutter-3-41-compat`.
- Flutter SDK: `/home/skivel/.local/share/flutter-3.41.9`.
- Android SDK: `/home/skivel/.local/share/android-sdk`.
- JDK: `/home/skivel/.local/share/jdk-21`.
- Keep `.atl/skill-registry.md` unstaged and excluded.
- Use CodeGraph exclusively for code discovery and GitHub CLI exclusively for GitHub access.

## Acceptance Criteria

- `.github/workflows/flutter_ci.yml` pins all existing Flutter setup steps to exactly `3.41.9` without importing unrelated later CI changes.
- `flutter pub get` leaves the intended dependency and generated registrant files unchanged.
- `flutter test test/core/services/callable_transport_test.dart test/main/app_check_activation_test.dart` passes all five tests.
- `flutter analyze --fatal-infos --fatal-warnings` passes.
- `flutter build apk --debug` exits zero with Gradle 8.12, AGP 8.7.3, KGP 2.3.0, and JDK 21.
- Final tracked scope contains only this document, the workflow pin, the two Android configuration files, `pubspec.lock`, the macOS registrant, and the two Windows registrant files; `.atl/skill-registry.md` remains excluded from staging.
- The verified compatibility candidate is committed as one Conventional Commit work unit and its identity is recorded here.

## Tasks

- [x] **ODD-P4C-001 — Create the P4 Flutter 3.41 compatibility work unit.** Completed with work-unit commit `ba33e29e2fa2d9e5df85c4ca7f659aa52a7c2eb7` (`build(android): align P4 with Flutter 3.41`). The normalized candidate pins CI to Flutter 3.41.9, retains Gradle 8.12 and AGP 8.7.3, upgrades only KGP to 2.3.0 with typed JVM 11 compiler options, preserves reproducible lockfile/registrant output, and passes all acceptance gates plus independent and native review.

## Review Workload Forecast

Expected authored scope is eight repository files plus this task document, with approximately 60 changed lines excluding generated lockfile and registrant churn. This is one cohesive low-risk build-compatibility unit and remains well below the 400-line review heuristic.

## Evidence

- Exact P4-T1 initially failed Android compilation because `firebase_auth 6.7.0` carries Kotlin metadata 2.3.0 while KGP 2.1.0 expected metadata 2.1.0.
- KGP 2.3.0 removed that mismatch but rejected the legacy string `kotlinOptions.jvmTarget` DSL.
- Typed `compilerOptions` with `JvmTarget.JVM_11` then produced `build/app/outputs/flutter-apk/app-debug.apk` successfully under Flutter 3.41.9, Gradle 8.12, AGP 8.7.3, and JDK 21.
- The experimental sandbox passed the two focused test files (5/5) and fatal analysis before normalization.
- Writer verification after normalization passed reproducible `flutter pub get`, focused tests 5/5, fatal analysis, Android debug assembly, and scoped diff-check. The APK is `build/app/outputs/flutter-apk/app-debug.apk` (164,157,738 bytes).
- Independent verification passed the same gates, confirmed unchanged lockfile/registrant hashes after `pub get`, exact Flutter 3.41.9 workflow pins, Gradle 8.12, AGP 8.7.3, KGP 2.3.0, typed JVM 11 compiler options, no WU5 migration leakage, and 103 changed lines across eight candidate paths.
- `.atl/skill-registry.md` remains pre-existing harness drift and is excluded from the candidate.
- Work-unit commit: `ba33e29e2fa2d9e5df85c4ca7f659aa52a7c2eb7` (`build(android): align P4 with Flutter 3.41`).
- Native four-lens review lineage `review-c9ea84335bf8b055` approved the committed range and acknowledgement burned authority successfully.
