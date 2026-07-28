# Design: Prepare Public Portfolio Repository

## Technical Approach

Add a prerequisite hook-correction work unit (WU0, before WU1), then continue the <=400-authored-line feature-branch chain. The hook checks only verified staged Dart files without writing. Portfolio work preserves the trusted Cloud Functions v2/Admin SDK provisioning boundary, strict Firestore rules, sanitization, signing guards, and manual publication gates.

## Architecture Decisions

| Topic | Decision and rationale |
|---|---|
| Hook implementation | Both `.githooks/pre-commit` and `.githooks/pre-commit.bat` invoke one SDK-only `tool/check_staged_dart_format.dart`; one parser avoids shell/BAT divergence and untrusted-path interpolation. Reject whole-tree formatting and duplicated parsers because they mutate unrelated work or drift cross-platform. |
| Staged-byte safety | Read staged ACMR `.dart` paths from NUL-delimited Git output. Ignore deletions; preserve spaces/Unicode/renames. If a candidate also has unstaged content, fail closed because worktree bytes differ from index. Pass verified paths as process arguments to `dart format --output=none --set-exit-if-changed`; never write/stage, resolve/install dependencies, or interpolate a shell command. No candidates means success without formatter invocation. |
| Analyzer | Keep full-project analysis check-only and non-resolving. Before implementation, verify actual CLI support via help/version evidence; use `flutter analyze --no-pub --fatal-infos --fatal-warnings` only if supported, otherwise record the supported check-only equivalent. Propagate nonzero status. |
| Provisioning | Flutter admin UI calls a v2 callable; server claims authorize, roles are `employee|rrhh`, and App Check is defense-in-depth. A SHA-256 request fingerprint reserves idempotency. After Auth creation, user, audit, and completed reservation commit in one batch; batch failure deletes Auth and records failure. Matching retry returns a fresh reset link; mismatch conflicts; existing Auth without completed reservation is not success. |

## Data Flow and Contracts

`Git index -> NUL-safe helper -> clean-worktree guard -> check-only formatter -> full analyzer`

`Admin UI -> callable -> claim/role validation -> reservation -> Auth -> atomic Firestore user+audit+completion -> fresh unpersisted link`

Invariants: no successful provisioning without same-batch audit; no plaintext password/persisted reset link; no callable-created admin; remove `EmployeeCreationService` and temporary-password generator; production/emulator first-admin bootstrap remains separate; protected `.atl/*` and `lib/core/theme/app_colors.dart` remain untouched.

## File Changes

| File | Action |
|---|---|
| `tool/check_staged_dart_format.dart`, hook integration tests | Create: helper and strict RED coverage |
| `.githooks/pre-commit`, `.githooks/pre-commit.bat` | Modify: invoke shared helper, then verified analyzer command |
| `functions/package.json`, `functions/src/index.ts` | Create: callable, idempotency, compensation tests/runtime |
| `lib/core/services/admin_provisioning_service.dart` | Create: callable adapter |
| `firebase_service.dart`, admin provider/drawer/tests | Modify: remove direct provisioning/password UI; use invitation result |
| `firestore.rules`, rules tests, Android ignore/signing, mock/report data, README/metadata | Harden/sanitize/test |
| `docs/archive/**` | Delete |

## Testing Strategy

Strict WU0 RED-first integration tests: no staged Dart -> pass/no formatter/no mutation; formatted staged Dart -> pass; unformatted -> fail/no mutation; staged+unstaged same path -> fail closed; spaces/Unicode -> exact argument handling; deleted Dart -> ignored; formatter unavailable -> fail actionably; analyzer failure -> propagated; WU1 non-Dart index -> formatter no-op. Snapshot index/worktree before/after every case. Existing backend unit/emulator tests cover authorization, allowlist, idempotency, atomic audit, compensation and retries; Flutter service/widget tests cover links/errors and absence of passwords; rules, signing, secret/PII and protected-path checks remain.

## Threat Matrix

| Boundary | Status; safe/failure behavior; RED test |
|---|---|
| Documentation-like paths | N/A: fixed helper classifies only Git-reported `.dart`; no documentation execution. |
| Git repository selection | Applicable: helper anchors Git and formatter cwd to repository root, rejects discovery/command failure; RED from nested cwd and outside/non-repository cwd. |
| Commit state | Applicable: empty/non-Dart index no-ops; ACMR only, deletions ignored, partial staging fails closed; RED empty, WU1 non-Dart, rename/delete, staged+unstaged cases. `commit -a` is observed through the hook's resulting index. |
| Push state | N/A: hook does not resolve or push refs. |
| PR commands | N/A: no PR command composition. |

## Migration / Rollout

1. From current HEAD, create a separate clean worktree/branch; implement, test, review, and commit WU0 first without skip-hooks.
2. Advance the portfolio worktree base compatibly while preserving WU1 patch identity (`.codegraph/.gitignore` A + `tatus` D).
3. Revalidate the existing WU1 receipt against the unchanged candidate, then commit WU1 normally; WU2 remains blocked until that parent exists.
4. Continue backend, client, rules, sanitization, signing, docs chain. No deploy/publication; license, history cleanup, Firebase Console hardening and production email remain external gates.

## Open Questions

None blocking; analyzer flags are an implementation-time verified prerequisite, not an assumed contract.

## Migration / Final-State Note

This design records the pre-implementation rollout plan. After the extracted snapshot, WU0 was committed locally as `4915419` and corrected by `3e9146f`; formatting and `flutter analyze` passed with no issues. WU1 then advanced compatibly to `3e9146f`, inherited `.codegraph/.gitignore` from the WU0 base, and retained only the `tatus` deletion as its final delta before local commit `7772e14`. No push or PR occurred, and the original checkout remained untouched. These facts complete rollout steps 1-3 but do not alter the pending application design in step 4.
