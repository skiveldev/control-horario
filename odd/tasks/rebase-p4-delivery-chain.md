# ODD Feature: Rebase P4 Delivery Chain

## Objective

Reconstruct the verified public-portfolio chain on the current `origin/master` without publishing, preserve the reconciled functional history and ordering, and produce clean Feature Branch Chain boundaries for explicit delivery approval.

## Constraints

- Source worktree: `/home/skivel/control-horario-worktrees/portfolio-p4-flutter-reconciled`
- Source tip: `d2e9c1c2761cee47ecb8c186c883bc33696512d2`
- Source merge base: `05685e070d0972a47e1bb19f7dd9c9555597570b`
- Target base: `origin/master` at `e9952ed9a268ee7dc4ac328fd7c4aac1ca86dc0b`
- Target branch: `feat/prepare-public-portfolio-reconciled`
- Preserve the two target-base `AGENTS.md` commits.
- Do not push, open or edit pull requests, merge, deploy, or publish.
- Do not transfer prior size exceptions to changed boundaries without explicit maintainer approval.

## Tasks

- [ ] ODD-DELIVERY-001 — Replay the 78 source commits onto current `origin/master` in order, resolve only target-base conflicts, preserve functional bytes, and record the old-to-new commit ledger.
- [ ] ODD-DELIVERY-002 — Independently verify history completeness, source-byte parity modulo the intended `AGENTS.md` base delta, repository cleanliness, and required runtime gates.
- [ ] ODD-DELIVERY-003 — Measure one honest Feature Branch Chain slicing pass, record exact tracker/child boundaries and size exceptions, and stop before publication for explicit maintainer approval.

## Evidence

Pending.
