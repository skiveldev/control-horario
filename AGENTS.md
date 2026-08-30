# Control Horario Agent Guide

This file defines durable repository rules for AI coding agents. Keep temporary
task state, active slice details, and acceptance evidence in OpenSpec rather
than duplicating them here.

## Start Here

1. Read this file and inspect the current worktree before changing anything.
2. For planned work, read the active change under `openspec/changes/` and treat
   its proposal, specification, design, tasks, and progress records as the
   authority for scope and verification.
3. Preserve unrelated user or agent changes. Never clean, restore, or rewrite
   files outside the requested scope.
4. Use the smallest correct change and run the narrowest relevant checks first.

## Project Shape

| Area | Location | Rules |
| --- | --- | --- |
| Flutter application | `lib/` | Feature-first UI built with Riverpod and Firebase. |
| Flutter tests | `test/` | Mirror the source area where practical. |
| Firebase Functions | `functions/src/` | Node ESM and strict TypeScript. |
| Functions tests | `functions/test/` | Include focused provisioning tests explicitly; the package test glob does not discover nested tests. |
| Firestore contract | `firestore.rules`, `firestore.indexes.json` | Change rules and emulator tests together. |
| SDD artifacts | `openspec/` | Source of truth for planned scope, budgets, dependencies, and acceptance. |

## Architecture Rules

- Riverpod is the only application state-management solution.
- Use `setState` only for state that remains local to one widget.
- Keep business logic and Firebase access out of widgets.
- Preserve the UI -> provider -> service dependency direction.
- Keep domain ports free of Firebase imports. External SDKs belong in adapters.
- Treat Firestore rules and provisioning state transitions as security and data
  integrity contracts, not implementation details.
- Do not add compatibility layers unless persisted data, shipped behavior, or an
  explicit external consumer requires them.

## Generated And Protected Paths

Do not hand-edit:

- `**/*.g.dart`
- `**/*.freezed.dart`
- `lib/firebase_options.dart`
- `build/`, `.dart_tool/`, `coverage/`, `.firebase/`, `node_modules/`

Regenerate Dart outputs with the declared build-runner command. An active
OpenSpec change may protect additional paths, including configuration files;
those constraints take precedence.

## Development Commands

Run commands from the repository root unless the active task says otherwise.

```bash
# Flutter
flutter test
flutter test --coverage
flutter analyze --fatal-infos --fatal-warnings
flutter build web --release
flutter pub run build_runner build --delete-conflicting-outputs
dart run tool/check_staged_dart_format.dart

# Firestore rules
npm run test:firestore-rules

# Firebase Functions
npm --prefix functions test
npm --prefix functions run build
npx --prefix functions tsc --noEmit
```

The provisioning tests are nested under `functions/test/provisioning/`; invoke
the focused files and explicit TypeScript command required by the active
OpenSpec task. Do not assume `npm --prefix functions test` covers them.

## Testing And SDD

- This repository uses Strict TDD for active SDD implementation work.
- Follow RED -> GREEN -> REFACTOR. Add each behavior test before its matching
  implementation and retain genuine RED evidence.
- Check the required Node version in the active task before running TypeScript
  tests or Firebase emulators. Provisioning work may require a newer Node
  version than `functions/package.json` declares.
- Run focused checks before broad suites. Do not run Firebase emulators or
  release builds when a passive documentation-only change needs only structural
  validation.
- Do not mark tasks complete without the checks and evidence required by the
  active OpenSpec artifact.
- Respect the active changed-line warning, STOP, and hard maximum. Never borrow
  budget from another work unit.
- Split work forecast above 400 changed lines unless the active task explicitly
  authorizes a size exception with its own hard limit.

## Context And Token Budget

Context is a bounded engineering resource. Enforce these rules mechanically:

- Parent orchestrators pass matching executor skill paths to delegated agents;
  they do not load complete executor-only skills into the parent context.
- Never print or load a complete SDD runtime ledger during normal routing.
  Project JSON output to only the current revision, objective, counters,
  decision flag, and next action. Read full history only for a proven diagnosis.
- Do not paste entire large artifacts into prompts. Read targeted sections or
  return hashes, line ranges, and concise findings.
- Reuse already-read source while it remains current. Do not reopen unchanged
  files merely to restate context.
- Keep delegated research results concise, normally at most 80 lines. Ask for
  evidence and file references, not narration.
- Delegate one coherent work unit at a time. Do not duplicate a delegated scan
  in the parent session.
- Allow at most one corrective retry for the same failure. If the runtime asks
  for a maintainer decision, stop and surface that decision instead of looping.
- On a typed terminal SDD transport failure, execute its exact continuation at
  most once, preserve the candidate, and stop. Never relaunch an SDD phase in
  the same session after the runtime latches dispatch.
- For large work, report the forecast and split along independently testable
  boundaries before implementation.

These safeguards reinforce rather than replace the native Gentle AI contract.
When this guide and a newer typed provider contract differ, follow the provider
contract and propose an evidence-backed update to this file.

## Git And Worktree Safety

- Work only in the current worktree unless the user explicitly authorizes
  another path.
- Never discard, stash, stage, or commit unrelated changes.
- Keep changes unstaged unless the user explicitly requests a commit.
- Do not use destructive Git commands or rewrite history.
- Before a requested commit, inspect status and diff, then stage only the
  intended work unit.
- Do not commit secrets, emulator data, generated build output, or local caches.

## Documentation Currency

`.cursorrules` contains historical project guidance and may be stale. Prefer
current manifests, source, tests, OpenSpec artifacts, and this file when they
conflict. Update this guide only for durable repository conventions, not for the
status of one temporary implementation slice.

## Maintaining This Guide

- When an agent discovers a durable convention, obsolete command, recurring
  failure, or missing protection, it should propose a focused `AGENTS.md`
  update.
- Every proposal must cite current repository evidence and explain which future
  failure or ambiguity it prevents.
- Agents must not modify `AGENTS.md` silently. Maintainer approval is required
  before changing repository agent policy.
- Do not add temporary task state, branch-specific instructions, speculative
  rules, or guidance already owned by an active OpenSpec artifact.
