# ODD Feature: Resolve Portfolio Contract Review

## Objective

Reconcile the five confirmed documentation inconsistencies from the read-only partial review of `ff245fab`, without changing implementation or claiming that historical RED evidence, acceptance, or a native receipt exists.

## Scope and constraints

- Worktree: current feature worktree (`feat/prepare-public-portfolio-reconciled`).
- Edit only this feature record and `openspec/changes/prepare-public-portfolio-repository/{design.md,specs/public-portfolio-readiness/spec.md,tasks.md}`.
- Preserve unrelated `.pi/` and the existing delivery feature record; do not rewrite history, stage, commit, publish, or modify source/tests.
- The current branch is the descendant of `ff245fab`; corrections are new working-tree changes, not changes to that historical commit.
- Existing OpenSpec artifacts are planning/evidence records; no historical checked step may be represented as a newly observed RED.
- TDD: strict for future active SDD implementation, per repository `AGENTS.md`; documentation-only correction has no runtime test runner. Structural checks: cross-file consistency and `git diff --check`.
- Delivery strategy: ask-on-risk; forecast below 400 authored diff lines, excluding this record; no publication authorized.

## Tasks

- [x] ODD-CONTRACT-001 — Resolve autonomous liveness for a consumed current task when a competing owner holds a live lease; specify independent bounded recovery, idempotent ownership fencing, and behavior-first proof. Route: delegated writer (three non-trivial OpenSpec files). Planning-contract only; no implementation proof.
- [x] ODD-CONTRACT-002 — Correct historical P2.37 RED claims, bound frozen-artifact correction/revalidation, and replace dependency-resolution RED with behavior RED; retain accepted evidence without inventing new tests. Route: same delegated writer; independent structural readback passed.
- [x] ODD-CONTRACT-003 — Align retry-threshold scenario with pending/active safe-failure versus uncertainty classification; verify the three-document matrix and diff hygiene. Route: same delegated writer; independent structural readback and `git diff --check` passed.
- [x] ODD-CONTRACT-004 — Define the recovery dispatch's canonical issuance tuple, legal worker acknowledgement order, and generation invariant. Route: user-authorized documentary schema extension and one scoped correction, independently verified for structural coherence.
- [ ] ODD-CONTRACT-005 — Obtain explicit authorization before any local work-unit commit and candidate-native-review routing; do not treat this structural verification as runtime or historical `ff245fab` approval.

## Acceptance

- The planning contract specifies how a consumed current task is recovered after owner crash without stealing a live lease or reusing an already consumed deterministic task ID; runtime behavior remains unproven.
- P2.37 is not falsely presented as genuine earlier RED and future test-first order is explicit; any frozen P1/P2 correction is restricted, checked against its handoff and independently revalidated.
- P4 dependency resolution failure is setup, never behavior RED.
- Exact retry terminal outcomes depend on durable no-effect proof, not the numerical threshold alone.
- No implementation, runtime tests, P3/P4 OpenSpec acceptance checkbox, native review approval, or historical commit change is claimed from these documentation edits.

## Progress and evidence

- Current tree inspected; `ff245fab` partial review identified H1/H2/M1/M2/R1, not a native receipt. CodeGraph did not locate Markdown; user explicitly authorized a bounded text search within the three named files. Existing `.pi/` is unrelated and remains untouched.
- Initial H1 independent structural verification failed on issuance tuple/ack/generation. The user expressly authorized the proposed takeover-variant tuple and then chose the documentary dispatch-schema extension for an immutable consumed-delivery marker; this does not authorize implementation. A second verifier found a same-dispatch `I→C` version-advance liveness gap; one bounded correction replaced the stale marker-version write predicate with fresh reread/full CAS and current lifecycle classification. Its new independent readback passed H1/H2/M1/M2/R1 structurally. The final three-document diff was 34 additions and 15 deletions; `git diff --check` passed. No runtime tests or emulator were run because only documentation changed.
- Native read-only assessment remains unassessable because of untracked inventory (`.pi/` plus this record); independent verifier ran as required. Historical `ff245fab` remains unapproved; current candidate is preserved, unstaged, without commit, native START, or receipt. The underlying P3 recovery and P4 behavior tests remain future work.

## Next step

Request a separate explicit commit decision before closing a work unit or attempting committed-range native review. Do not claim implementation, runtime proof, or historical `ff245fab` approval.
