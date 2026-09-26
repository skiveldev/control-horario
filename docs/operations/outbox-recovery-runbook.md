# Provisioning Outbox Recovery Runbook

Use this runbook when provisioning outbox dispatches stop being enqueued or remain stale after the normal repair window. The goal is to restore the approved enqueue path and confirm recovery without exposing PII or bypassing saga safety controls.

## Alert context

Investigate when any of these alerts fire:

- `outbox_stale_age_seconds` remains above 900 seconds for two consecutive five-minute periods.
- Eventarc outbox trigger delivery or execution failures occur.
- The scheduled sweeper reports failures or has no successful execution for 10 minutes.
- Cloud Tasks enqueue failures or task attempt-exhaustion alerts occur.

Use only operation and dispatch digests from logs, metrics, and audit records. Do not copy raw emails, names, DNI, telephone numbers, request bodies, tokens, reset links, or SDK messages into tickets or chat.

## Recovery order

1. Restore Firestore availability first. The operation, dispatch, and audit records are the durable source of truth.
2. Restore Eventarc delivery for the `provisioningDispatch` created-event trigger.
3. Restore Cloud Scheduler delivery for the five-minute outbox repair job.
4. Restore Cloud Tasks queue creation and dispatch capability.
5. After dependencies are healthy, either wait for the next normal five-minute repair schedule or invoke the same approved repair handler/adapter path used by the scheduled sweeper.

Do not enqueue by hand with ad hoc task IDs. Do not call a saga phase or worker boundary directly.

## Safe repair procedure

1. Identify stale dispatches using the production stale-outbox criteria:
   - collection: `/provisioningDispatch/{dispatchId}`
   - `enqueued == false`
   - `createdAt <= serverNow - 10 minutes`
   - order: `createdAt ASC, __name__ ASC`
2. Run recovery through the same shared enqueue adapter used by both the Eventarc trigger and scheduled sweeper.
3. For each dispatch, confirm the deterministic task identity:
   - `taskId` equals `dispatchId`.
   - the Cloud Tasks task name uses that deterministic task ID.
   - `ALREADY_EXISTS` for the same task ID is treated as accepted success, not as a duplicate failure.
4. Confirm the guarded enqueue acknowledgement commits only when dispatch identity still matches and `enqueued == false`.
5. Verify the dispatch now has `enqueued == true`, a server `enqueuedAt`, and the expected trigger or sweeper enqueue source metadata.
6. Re-run the stale inventory query with the same criteria until remaining rows are either recovered, newly created inside the 10-minute grace period, or explicitly assigned for operator follow-up by digest.

## Forbidden actions

Never directly mutate any of the following during outbox recovery:

- Firebase Auth users or credentials.
- `/users/{uid}` profile documents.
- `/provisioningOperations/{operationId}` operation state, leases, owner tokens, phases, generations, versions, or Auth-attempt proof.
- `workerAck` or `workerAckAt` fields.
- Saga phase fields or terminal status fields.

The sweeper repairs enqueue acknowledgement only. Worker acknowledgement, phase execution, terminalization, Auth reconstruction, profile writes, and manual-recovery classification remain owned by the worker/runtime path.

## Verification checklist

- [ ] Firestore, Eventarc, Scheduler, and Cloud Tasks are healthy again.
- [ ] Recovery used the normal five-minute sweeper or the same repair handler/adapter path.
- [ ] Every recovered task used deterministic `taskId == dispatchId` identity.
- [ ] `ALREADY_EXISTS` was accepted only for the same deterministic task identity.
- [ ] `enqueued=true` was written by the guarded acknowledgement path with no operation or worker acknowledgement mutation.
- [ ] Remaining stale dispatches were inventoried with the same `enqueued=false` and `createdAt<=serverNow-10m` criteria.
- [ ] The incident record contains only PII-safe digests and stable codes.
