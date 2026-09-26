# P3-B.2c Initial Acquisition Reforecast

**Status:** BLOCKED — the indivisible acquisition work unit cannot be defensibly forecast below the STOP 380 line threshold with margin. This is read-only planning evidence after completed P3-B.2c-pre; its 86 changed lines are not recounted.

## Evidence

- CodeGraph was already indexed for `<workspace-root>` and was used exclusively for source discovery.
- `worker.ts:1-196` currently implements only classification and stale acknowledgement; acquisition is absent. `boundaries.ts:10-21,38-69` already supplies `now`, three reads, operation/dispatch writes, and create-only dispatch/audit; no boundary change is evidenced.
- Reusable sources: `model.ts:341-462` (`ExpectedCAS`, `createEvent`, `reduce`); `ids.ts:40-48,97-100` (`deriveDispatchId`, `deriveOwnerToken`); `audit.ts:28-53` (`createAuditEvent`, `deduplicateAudit`); test helpers `worker_auth.test.ts:28-109,336-446,461-605` (operation/dispatch builders, `StrictWorkerStore`, snapshot, stale real-Firestore setup/concurrency and create-conflict patterns).
- The prequisite is checked complete in `tasks.md:1908-1916`; no acquisition completion is claimed.

## Fixed accounting (additions + deletions)

| Path/group | Adds | Deletes | Changed | Scope |
|---|---:|---:|---:|---|
| `functions/src/provisioning/worker.ts` | 81 | 5 | 86 | imports and an acquisition transaction: trusted rereads of dispatch/operation/audit/next before writes; full initial and source fences; deterministic owner and lease; reducer request; pointer assignment; source ack; immutable audit dedup/create; next dispatch creation and return contract. |
| `worker_auth.test.ts` strict-fake vectors | 157 | 3 | 160 | canonical acquire fixtures and strict proofs of read-all-before-write, full tuple/source fences, deterministic seed/owner and 60s lease, reducer g0/v1/null-pointer behavior, 14-field audit/dedup timestamp, atomic operation/source-ack/next-dispatch, each audit/dispatch/create/CAS conflict rollback, and unchanged loser. |
| `worker_auth.test.ts` REAL Firestore vectors | 121 | 1 | 122 | existing `FirestoreWorkerStore` harness reused for acceptance fixtures, pre-start barrier plus `Promise.all` competing transactions, exactly one winner/next dispatch/processed source ack/audit, unchanged loser, matching replay timestamp, and real create-conflict rollback (code 6). |
| `tasks.md` checkboxes/accounting | 8 | 0 | 8 | P3-B.2c task completion and measured evidence. |
| `apply-progress.md` evidence append | 8 | 0 | 8 | allowed future evidence append. |
| Contingency | 18 | 0 | 18 | strict TypeScript fixture shape, emulator transaction retry assertions, and required explicit-regression bookkeeping; not scope growth. |
| **Total** | **393** | **9** | **402** | **22 lines above STOP; 3 above hard maximum 399.** |

The estimate already reuses the current strict fake and all relevant primitives. It does not count P3-B.2c-pre, plan `boundaries.ts` changes, generic abstractions, or unrelated production behavior.

## Acceptance retained

One indivisible unit must prove: all four transaction reads before writes; exact initial tuple plus immutable `acquire/g0/sourceVersion0` source; deterministic `ownerSeed === deriveOwnerToken(dispatchId,0)` and owner; 60-second transaction-clock lease; reducer g0/v1 with adapter-only next pointer; source acknowledgement; exact 14-field state-transition audit; dedup timestamp preservation; next create; full rollback on audit/dispatch/create/CAS conflict; and real concurrent one-winner/unchanged-loser proof. The strict fake and REAL emulator proof cannot be split without weakening acceptance.

No new contract ambiguity or feature prerequisite was found. One fixture adjustment is required by existing contract, not new scope: `worker_auth.test.ts:20,45-57` uses a constant `ownerSeed`, whereas acquisition must test the derived persisted canonical seed; classification currently does not enforce that relation.

## Recommendation

Maintain BLOCKED. Under `ask-on-risk`, obtain a human delivery decision before apply: the complete normal-style unit is forecast at 402 and cannot honestly fit below STOP 380 with margin; no size exception is available. No files were implemented, tests/emulators run, or operational actions performed during exploration.
