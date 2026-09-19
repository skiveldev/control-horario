/**
 * P1a2-i-A-1a — Immutable vocabulary + genuine bidirectional type proof.
 * RED: model.ts absent → TS2307. GREEN: type-check pass + runtime pass.
 */
import type { ProvisioningStatus, ProvisioningPhase, StatusPhasePair } from "../../src/provisioning/types.ts";
import { EVENT_TYPES, STATUS_PHASE_MAP, createEvent, createFailureResult, createInitialState, createSuccessResult, isEventType, isPhase, isStatus, isValidEvent, isValidState, reduce, type EventType, type ExpectedCAS, type ModelEvent, type OperationState, type ReducerRequest, type TransitionResult } from "../../src/provisioning/model.ts";
import type { _ProofNoMissing, _ProofNoExtra, _StatusPhaseMap } from "../../src/provisioning/model.ts";

const ok = (c: boolean, m: string) => { if (!c) throw new Error(`FAIL: ${m}`); };

// ---- 12 frozen event types ----
ok(Array.isArray(EVENT_TYPES) && EVENT_TYPES.length === 12, `len=${EVENT_TYPES.length}`);
["ack_dispatch","acquire","takeover","auth_intent","auth_start","auth_confirm","auth_no_effect","auth_ambiguous","auth_foreign_user","auth_preflight","profile_commit","terminalize"].forEach(e =>
  ok(EVENT_TYPES.includes(e as typeof EVENT_TYPES[number]), `missing: ${e}`));
try { (EVENT_TYPES as unknown as string[]).push("x"); ok(false,"push"); } catch { /* frozen */ }
try { (EVENT_TYPES as unknown as string[])[0]="x"; ok(false,"set"); } catch { /* frozen */ }
const _et1: EventType = "ack_dispatch"; /* compile-time: EventType covers members */

// ---- Status→phase mapping ----
const XP: readonly [ProvisioningStatus, readonly ProvisioningPhase[]][] = [
  ["pending", ["dispatch_pending"]],
  ["active", ["auth_preflight","auth_create","profile_commit"]],
  ["completed", ["terminal"]], ["failed", ["terminal"]], ["manual_recovery", ["terminal"]],
];
XP.forEach(([s, phs]) => {
  const got = (STATUS_PHASE_MAP[s] as readonly string[]).slice().sort();
  ok(JSON.stringify(got)===JSON.stringify([...phs].sort()), `${s}: got ${got}`);
  ok(got.length===phs.length, `${s}: len ${got.length}!==${phs.length}`);
});
ok(JSON.stringify(Object.keys(STATUS_PHASE_MAP).sort())===JSON.stringify(["active","completed","failed","manual_recovery","pending"]),"keys mismatch");
try { (STATUS_PHASE_MAP as Record<string,unknown>).x=1; ok(false,"map-immut"); } catch { /* frozen */ }
try { (STATUS_PHASE_MAP.active as unknown as string[]).push("terminal"); ok(false,"nested-push"); } catch { /* frozen */ }
try { (STATUS_PHASE_MAP.pending as unknown as string[])[0]="x"; ok(false,"nested-set"); } catch { /* frozen */ }

// ---- Runtime bidirectional re-verification ----
const CANON: StatusPhasePair[] = [
  {status:"pending",phase:"dispatch_pending"},{status:"active",phase:"auth_preflight"},
  {status:"active",phase:"auth_create"},{status:"active",phase:"profile_commit"},
  {status:"completed",phase:"terminal"},{status:"failed",phase:"terminal"},{status:"manual_recovery",phase:"terminal"},
];
CANON.forEach(p => ok((STATUS_PHASE_MAP[p.status] as readonly string[]).includes(p.phase), `MISSING (${p.status},${p.phase})`));
const CANON_SET = new Set(CANON.map(p => `${p.status}|${p.phase}`));
(Object.entries(STATUS_PHASE_MAP) as [ProvisioningStatus, readonly ProvisioningPhase[]][]).forEach(([s,phs]) =>
  phs.forEach(ph => ok(CANON_SET.has(`${s}|${ph}`), `EXTRA (${s},${ph})`)));

// ---- Compile-time bidirectional proof (consumes production generics) ----
type RequireTrue<T extends true> = T;
type _V1 = RequireTrue<_ProofNoMissing<_StatusPhaseMap>>;
type _V2 = RequireTrue<_ProofNoExtra<_StatusPhaseMap>>;

// ---- Compile-negative: missing pair detected (consumes production _ProofNoMissing) ----
// Remove "pending" from the implementation map type; _ProofNoMissing returns false.
// Anti-vacuity: if _ProofNoMissing<M> is weakened to always return true,
// the @ts-expect-error below becomes unused → TS2578.
type _MissMap = Omit<_StatusPhaseMap, "pending">;
// @ts-expect-error — pending omitted; _ProofNoMissing<_MissMap> is false
type _MissDetect = RequireTrue<_ProofNoMissing<_MissMap>>;

// ---- Compile-negative: extra pair detected (consumes production _ProofNoExtra) ----
// Add "auth_preflight" to completed's phases from the implementation map type.
// _ProofNoExtra returns false because flat NOT extends StatusPhasePair.
// Anti-vacuity: if _ProofNoExtra<M> is weakened to always return true,
// the @ts-expect-error below becomes unused → TS2578.
type _ExtMap = Omit<_StatusPhaseMap, "completed"> & { readonly completed: readonly [..._StatusPhaseMap["completed"], "auth_preflight"] };
// @ts-expect-error — extra (completed,auth_preflight); _ProofNoExtra<_ExtMap> is false
type _ExtDetect = RequireTrue<_ProofNoExtra<_ExtMap>>;

// ---- TransitionResult discriminated union ----
const _trs: TransitionResult = { type:"success", state:{} as OperationState };
const _trf: TransitionResult = { type:"failure", reason:"err" };
ok(_trs.type==="success", "TransitionResult.success");
ok(_trf.type==="failure" && typeof _trf.reason==="string", "TransitionResult.failure");

// ---- OperationState interface shape ----
const _os: OperationState = { operationId:"x",fingerprint:"x",status:"pending",phase:"dispatch_pending",normalizedPayload:{} as OperationState["normalizedPayload"],intendedUid:null,generation:0,version:0,ownerToken:null,leaseExpiresAt:null,currentDispatchId:null,authAttempted:false,authAttempt:null,createdAt:0,updatedAt:0 };
ok(_os.status==="pending" && _os.phase==="dispatch_pending","OperationState shape");
ok(_os.authAttempt===null && _os.authAttempted===false,"authAttempt defaults");

// ---- Final immutability re-check ----
try { (EVENT_TYPES as unknown as string[]).push("z"); ok(false,"immut-final-push"); } catch {}
try { (EVENT_TYPES as unknown as string[])[0]="z"; ok(false,"immut-final-set"); } catch {}
try { (STATUS_PHASE_MAP as Record<string,unknown>).z=1; ok(false,"immut-final-prop"); } catch {}

// ---- P1a2-i-A-1b deepFreeze probes ---------------------------------------
import { deepFreeze } from "../../src/provisioning/model.ts";

// Helper: returns true if obj is frozen (top-level)
const isTopFrozen = (o: unknown): boolean => (typeof o === "object" && o !== null) ? Object.isFrozen(o) : true;
// Helper: returns the first non-frozen own-object reference, or null
const findUnfrozen = (root: object, seen = new WeakSet()): string | null => {
  if (seen.has(root)) return null;
  seen.add(root);
  for (const key of Reflect.ownKeys(root)) {
    const val = (root as Record<PropertyKey, unknown>)[key as string | symbol];
    if (typeof val === "object" && val !== null && !Object.isFrozen(val)) {
      return `unfrozen child at key ${String(key)}`;
    }
    if (typeof val === "object" && val !== null) {
      const deeper = findUnfrozen(val, seen);
      if (deeper) return deeper;
    }
  }
  return null;
};

// -- 1b.1: basic string-keyed own data property freeze --
{
  const obj = { a: 1, b: { c: 2 } };
  const frozen = deepFreeze(obj);
  // Must be same reference
  ok(frozen === obj, "1b.1 same-ref");
  // Top-level frozen
  ok(Object.isFrozen(frozen), "1b.1 top-frozen");
  // Nested frozen
  ok(Object.isFrozen((frozen as { b: object }).b), "1b.1 nested-frozen");
  // Mutation rejected (non-strict assignment fails silently or throws)
  let mutationCaught = false;
  try { (frozen as Record<string, unknown>).a = 99; } catch { mutationCaught = true; }
  ok(mutationCaught || (frozen as { a: number }).a === 1, "1b.1 mutation-rejected");
  // Delete rejected
  let delCaught = false;
  try { delete (frozen as Record<string, unknown>).a; } catch { delCaught = true; }
  ok(delCaught || (frozen as { a: number }).a === 1, "1b.1 delete-rejected");
}

// -- 1b.2: array push/index-assignment/delete rejected after freeze --
{
  const arr = [10, 20, { deep: true }];
  const frozenArr = deepFreeze(arr);
  ok(Array.isArray(frozenArr), "1b.2 is-array");
  ok(Object.isFrozen(frozenArr), "1b.2 array-frozen");
  ok(Object.isFrozen((frozenArr as unknown as Record<number, unknown>)[2] as object), "1b.2 nested-el-frozen");
  // push
  let pushCaught = false;
  try { (frozenArr as number[]).push(99); } catch { pushCaught = true; }
  ok(pushCaught, "1b.2 push-rejected");
  // index assignment
  let setIdxCaught = false;
  try { (frozenArr as number[])[0] = 99; } catch { setIdxCaught = true; }
  ok(setIdxCaught || (frozenArr as number[])[0] === 10, "1b.2 idx-set-rejected");
  // delete
  let delIdxCaught = false;
  try { delete (frozenArr as unknown[])[0]; } catch { delIdxCaught = true; }
  ok(delIdxCaught || (frozenArr as number[])[0] === 10, "1b.2 idx-del-rejected");
}

// -- 1b.3: deep nesting — every level frozen --
{
  const deep = { l1: { l2: { l3: { value: "bottom" } } } };
  const frozen = deepFreeze(deep);
  ok(Object.isFrozen(frozen), "1b.3 l1-frozen");
  ok(Object.isFrozen((frozen as typeof deep).l1), "1b.3 l2-frozen");
  ok(Object.isFrozen((frozen as typeof deep).l1.l2), "1b.3 l3-frozen");
  ok(Object.isFrozen((frozen as typeof deep).l1.l2.l3), "1b.3 l4-frozen");
  const unfrozenFound = findUnfrozen(frozen);
  ok(unfrozenFound === null, `1b.3 unfrozen-found: ${unfrozenFound}`);
}

// -- 1b.4: pre-frozen parent — unfrozen children must still be traversed --
{
  const nested = { inner: 42 };
  const parent = Object.freeze({ child: nested });
  ok(Object.isFrozen(parent), "1b.4 parent-pre-frozen");
  ok(!Object.isFrozen(nested), "1b.4 child-NOT-frozen-before");
  const frozen = deepFreeze(parent);
  ok(frozen === parent, "1b.4 same-ref");
  ok(Object.isFrozen(frozen), "1b.4 parent-still-frozen");
  ok(Object.isFrozen(nested), "1b.4 child-NOW-frozen-after");
  let mutateChild = false;
  try { (nested as Record<string, unknown>).inner = 99; } catch { mutateChild = true; }
  ok(mutateChild || nested.inner === 42, "1b.4 child-mutation-rejected");
}

// -- 1b.5: symbol-keyed properties covered --
{
  const symA = Symbol("a");
  const symB = Symbol("b");
  const obj: Record<symbol, unknown> = {
    [symA]: "valueA",
    [symB]: { nested: "symval" },
  };
  (obj as Record<string, unknown>).stringKey = "vis via ownKeys";
  const frozen = deepFreeze(obj);
  ok(Object.isFrozen(frozen), "1b.5 top-frozen");
  ok(Object.isFrozen((frozen as Record<symbol, object>)[symB] as object), "1b.5 sym-nested-frozen");
  let symMutate = false;
  try { (frozen as Record<symbol, unknown>)[symA] = "changed"; } catch { symMutate = true; }
  ok(symMutate || frozen[symA] === "valueA", "1b.5 sym-mutation-rejected");
}

// -- 1b.6: non-enumerable own data properties covered --
{
  const obj: Record<string, unknown> = { vis: 1 };
  Object.defineProperty(obj, "hid", { value: "secret", enumerable: false, writable: true, configurable: true });
  ok((obj as Record<string, unknown>).hid === "secret", "1b.6 hidden-visible-before");
  const frozen = deepFreeze(obj);
  ok(Object.isFrozen(frozen), "1b.6 top-frozen");
  // Non-enumerable property should also be frozen
  const desc = Object.getOwnPropertyDescriptor(frozen, "hid");
  ok(desc !== undefined && desc.writable === false && desc.configurable === false, "1b.6 hidden-frozen");
}

// -- 1b.7: throwing getter does NOT abort traversal (descriptor-safe) --
{
  let getterInvoked = false;
  const obj = {
    safe: "ok",
    get boom(): string { getterInvoked = true; throw new Error("EXPLODE"); },
  };
  // deepFreeze must traverse via descriptors, NOT invoke getters
  const frozen = deepFreeze(obj);
  ok(getterInvoked === false, "1b.7 getter-NOT-invoked");
  // Safe property still frozen
  ok(Object.isFrozen(frozen), "1b.7 top-frozen");
  // Non-getter own property descriptors confirm immutability
  const safeDesc = Object.getOwnPropertyDescriptor(frozen, "safe");
  ok(safeDesc !== undefined && safeDesc.writable === false && safeDesc.configurable === false, "1b.7 safe-frozen");
  // Getter descriptor preserved (accessor descriptor)
  const boomDesc = Object.getOwnPropertyDescriptor(frozen, "boom");
  ok(boomDesc !== undefined && typeof boomDesc.get === "function", "1b.7 boom-accessor-preserved");
}

// -- 1b.8: cycle-safe (circular reference handled via WeakSet) --
{
  const circular: Record<string, unknown> = { a: 1 };
  circular.self = circular;
  const frozen = deepFreeze(circular);
  ok(frozen === circular, "1b.8 same-ref");
  ok(Object.isFrozen(frozen), "1b.8 top-frozen");
  // Self-reference is the same (frozen) object
  ok(frozen.self === frozen, "1b.8 self-ref-intact");
}

// -- 1b.9: children frozen before parent (parent already frozen when children done) --
{
  const obj = { outer: 1, child: { inner: 2 } };
  const frozen = deepFreeze(obj);
  // The parent being frozen implies children were processed (deep freeze semantics)
  ok(Object.isFrozen(frozen), "1b.9 parent-frozen");
  ok(Object.isFrozen((frozen as typeof obj).child), "1b.9 child-frozen");
}

// -- 1b.10: shared-reference DAG — every child frozen before each parent --
{
  const log: object[] = []; const _of = Object.freeze;
  (Object as {freeze:typeof Object.freeze}).freeze = (o:any)=>{log.push(o);return _of(o);};
  try {
    const s = {id:"shared"}; const r:any = {left:{shared:s},shared:s};
    deepFreeze(r);
    const si=log.indexOf(s),ri=log.indexOf(r as object),li=log.indexOf(r.left as object);
    ok(si<ri,`1b.10 shared(${si})<root(${ri})`);
    ok(si<li,`1b.10 shared(${si})<left(${li})`);
    ok(li<ri,`1b.10 left(${li})<root(${ri})`);
  } finally { Object.freeze = _of; }
}

console.log("\n=== P1a2-i-A-1b deepFreeze probes ===\nALL PASSED\n");

// ---- P1a2-i-A-1c strict state guard probes -------------------------------
const validState = (): OperationState => ({
  operationId: "123e4567-e89b-42d3-a456-426614174000", fingerprint: "a".repeat(64),
  status: "pending", phase: "dispatch_pending", normalizedPayload: { email:"employee@example.com",nombre:"Ana",apellido1:"Lopez",apellido2:null,employeeId:"",weeklyHours:40,dni:null,telefono:null,cargo:null,departamento:null,empresa:null,scheduleId:null,calendarId:null,fechaInicio:null,fechaFin:null,role:"employee",isSupervisor:false,supervisorId:null,isActive:true },
  intendedUid: null, generation: 0, version: 0, ownerToken: null,
  leaseExpiresAt: null, currentDispatchId: null, authAttempted: false,
  authAttempt: null, createdAt: 0, updatedAt: 0,
});
const rejectsState = (label: string, mutate: (state: Record<PropertyKey, unknown>) => void): void => {
  const state = validState() as unknown as Record<PropertyKey, unknown>;
  mutate(state);
  ok(!isValidState(state), label);
};
ok(isStatus("pending") && isStatus("manual_recovery"), "1c status vocabulary accepted");
ok(!isStatus("unknown"), "1c unknown status rejected");
ok(isPhase("dispatch_pending") && isPhase("terminal"), "1c phase vocabulary accepted");
ok(!isPhase("unknown"), "1c unknown phase rejected");
ok(isValidState(validState()), "1c valid state accepted");
rejectsState("1c null operationId rejected", state => { state.operationId = null; });
rejectsState("1c null fingerprint rejected", state => { state.fingerprint = null; });
rejectsState("1c NaN numeric field rejected", state => { state.generation = Number.NaN; });
rejectsState("1c mismatched status-phase pair rejected", state => { state.phase = "terminal"; });
class StateRoot {}
const classRoot = Object.assign(new StateRoot(), validState());
ok(!isValidState(classRoot), "1c class instance root rejected");
const pollutedRoot = validState() as unknown as object;
Object.setPrototypeOf(pollutedRoot, { polluted: true });
ok(!isValidState(pollutedRoot), "1c polluted prototype rejected");

rejectsState("1c non-plain normalized payload rejected", state => {
  state.normalizedPayload = new (class PayloadRoot {})();
});
rejectsState("1c missing required field rejected", state => { delete state.fingerprint; });
rejectsState("1c string-key extra rejected", state => { state.extra = true; });
rejectsState("1c symbol-key extra rejected", state => { state[Symbol("extra")] = true; });

// ---- Ordinal 54: causal strict-state remediation matrix (RED first) -------
const strictPayload = () => ({ email:"employee@example.com",nombre:"Ana",apellido1:"Lopez",apellido2:null,employeeId:"",weeklyHours:40,dni:null,telefono:null,cargo:null,departamento:null,empresa:null,scheduleId:null,calendarId:null,fechaInicio:null,fechaFin:null,role:"employee",isSupervisor:false,supervisorId:null,isActive:true });
const strictAttempt = (): NonNullable<OperationState["authAttempt"]> => ({ attemptId:"b".repeat(64),intentAt:0,callStartedAt:0,result:"confirmed",returnedUid:"uid-1",returnedEmail:"employee@example.com",proof:{attemptId:"b".repeat(64),confirmedAt:0,uidRead:"uid-1",emailRead:"employee@example.com"} });
const strictState = () => ({ operationId:"123e4567-e89b-42d3-a456-426614174000",fingerprint:"a".repeat(64),status:"pending",phase:"dispatch_pending",normalizedPayload:strictPayload(),intendedUid:null,generation:0,version:0,ownerToken:null,leaseExpiresAt:null,currentDispatchId:null,authAttempted:false,authAttempt:null,createdAt:0,updatedAt:0 });
const confirmedProfileState = () => ({ ...strictState(), status:"active", phase:"profile_commit", intendedUid:"uid-1", ownerToken:"c".repeat(64), leaseExpiresAt:10, authAttempted:true, authAttempt:strictAttempt() });
const definiteNoEffectPreflightState = () => ({ ...strictState(), status:"active", phase:"auth_preflight", intendedUid:"uid-1", ownerToken:"c".repeat(64), leaseExpiresAt:10, authAttempted:true, authAttempt:{ attemptId:"b".repeat(64), intentAt:0, callStartedAt:0, result:"definite_no_effect", returnedUid:null, returnedEmail:null, proof:null } });
const badState = (mutate: (state: Record<string, any>) => void): unknown => { const state = strictState() as Record<string, any>; mutate(state); return state; };
const redCases: readonly [string, () => unknown][] = [
  ["null-prototype root", () => Object.assign(Object.create(null), strictState())],
  ["uppercase operationId", () => badState(s => { s.operationId = s.operationId.toUpperCase(); })],
  ["malformed operationId", () => badState(s => { s.operationId = "not-a-uuid"; })],
  ["empty auth attempt id", () => badState(s => { s.authAttempt = strictAttempt(); s.authAttempt.attemptId = ""; })],
  ["uppercase fingerprint", () => badState(s => { s.fingerprint = s.fingerprint.toUpperCase(); })],
  ["malformed fingerprint", () => badState(s => { s.fingerprint = "a".repeat(63); })],
  ["empty auth proof uid", () => badState(s => { s.authAttempt = strictAttempt(); s.authAttempt.proof.uidRead = ""; })],
  ["negative generation", () => badState(s => { s.generation = -1; })],
  ["fractional generation", () => badState(s => { s.generation = 0.5; })],
  ["negative version", () => badState(s => { s.version = -1; })],
  ["fractional version", () => badState(s => { s.version = 0.5; })],
  ["negative createdAt", () => badState(s => { s.createdAt = -1; })],
  ["negative leaseExpiresAt", () => badState(s => { s.leaseExpiresAt = -1; })],
  ["null-prototype payload", () => badState(s => { s.normalizedPayload = Object.assign(Object.create(null), strictPayload()); })],
  ["payload missing key", () => badState(s => { delete s.normalizedPayload.isActive; })],
  ["payload extra key", () => badState(s => { s.normalizedPayload.extra = true; })],
  ["payload symbol key", () => badState(s => { s.normalizedPayload[Symbol("extra")] = true; })],
  ["payload invalid role", () => badState(s => { s.normalizedPayload.role = "admin"; })],
  ["payload empty nullable", () => badState(s => { s.normalizedPayload.apellido2 = ""; })],
  ["uppercase auth attempt id", () => badState(s => { s.authAttempt = strictAttempt(); s.authAttempt.attemptId = s.authAttempt.attemptId.toUpperCase(); })],
  ["negative auth intent timestamp", () => badState(s => { s.authAttempt = strictAttempt(); s.authAttempt.intentAt = -1; })],
  ["mismatched auth proof id", () => badState(s => { s.authAttempt = strictAttempt(); s.authAttempt.proof.attemptId = "c".repeat(64); })],
];
ok(isValidState(strictState()), "54 valid zero-boundary state accepted");
ok(isValidState(confirmedProfileState()), "54 valid confirmed profile boundary accepted");
ok(!isValidState(badState(s => { s.operationId = ""; })), "54 empty operationId rejected");
ok(!isValidState(badState(s => { s.fingerprint = ""; })), "54 empty fingerprint rejected");
const redFailures = redCases.filter(([, make]) => isValidState(make())).map(([label]) => label);
if (redFailures.length > 0) throw new Error(`ordinal 54 RED: ${redFailures.length}/22 accepted invalid states: ${redFailures.join(", ")}`);
console.log("=== Ordinal 54 strict state matrix: 22/22 rejected; 2 valid boundaries accepted ===");
const uid128 = "u".repeat(128), uid129 = "u".repeat(129);
const ownerState = (status: string, ownerToken: unknown) => badState(s => { s.status=status; s.phase=status === "pending" ? "dispatch_pending" : status === "active" ? "auth_preflight" : "terminal"; s.ownerToken=ownerToken; });
const uidState = (field: string, value: unknown) => {
  if (field === "intendedUid" && value === null) return strictState();
  if (field === "returnedUid" && value === null) return definiteNoEffectPreflightState();
  const state = confirmedProfileState() as Record<string, any>;
  if (field === "intendedUid") {
    state.intendedUid = value;
    state.authAttempt.returnedUid = value;
    state.authAttempt.proof.uidRead = value;
  } else if (field === "returnedUid") {
    state.intendedUid = value;
    state.authAttempt.returnedUid = value;
    state.authAttempt.proof.uidRead = value;
  } else {
    state.intendedUid = value;
    state.authAttempt.returnedUid = value;
    state.authAttempt.proof.uidRead = value;
  }
  return state;
};
const recoveryCases: readonly [string, boolean, unknown][] = [
  ["pending/null owner",true,ownerState("pending",null)], ["active/valid owner",true,ownerState("active","c".repeat(64))], ["active/null owner",false,ownerState("active",null)], ["pending/owner",false,ownerState("pending","c".repeat(64))], ["terminal/owner",false,ownerState("completed","c".repeat(64))],
  ["malformed owner",false,ownerState("active","bad")], ["uppercase owner",false,ownerState("active","C".repeat(64))], ["short owner",false,ownerState("active","c".repeat(63))],
  ["intended 128",true,uidState("intendedUid",uid128)], ["intended 129",false,uidState("intendedUid",uid129)], ["intended empty",false,uidState("intendedUid","")], ["intended null",true,uidState("intendedUid",null)],
  ["returned 128",true,uidState("returnedUid",uid128)], ["returned 129",false,uidState("returnedUid",uid129)], ["returned empty",false,uidState("returnedUid","")], ["returned null",true,uidState("returnedUid",null)], ["proof uid 128",true,uidState("uidRead",uid128)], ["proof uid 129",false,uidState("uidRead",uid129)], ["proof uid empty",false,uidState("uidRead","")], ["proof uid null",false,uidState("uidRead",null)],
];
const recoveryFailures = recoveryCases.filter(([, expected, state]) => isValidState(state) !== expected).map(([label]) => label);
if (recoveryFailures.length > 0) throw new Error(`ordinal 55 RED: ${recoveryFailures.length}/20 boundary mismatches: ${recoveryFailures.join(", ")}`);
console.log("=== Ordinal 55 owner-token and Firebase UID boundaries: 20/20 ===");

const fractionalTimestampCases: readonly [string, (state: Record<string, any>) => void][] = [
  ["createdAt", s => { s.createdAt = 0.5; }], ["updatedAt", s => { s.updatedAt = 0.5; }], ["leaseExpiresAt", s => { s.leaseExpiresAt = 0.5; }],
  ["authAttempt.intentAt", s => { s.authAttempt = strictAttempt(); s.authAttempt.intentAt = 0.5; }], ["authAttempt.callStartedAt", s => { s.authAttempt = strictAttempt(); s.authAttempt.callStartedAt = 0.5; }], ["authAttempt.proof.confirmedAt", s => { s.authAttempt = strictAttempt(); s.authAttempt.proof.confirmedAt = 0.5; }],
];
const acceptedFractionalTimestamps = fractionalTimestampCases.filter(([, mutate]) => isValidState(badState(mutate))).map(([field]) => field);
if (acceptedFractionalTimestamps.length > 0) throw new Error(`ordinal 61 RED: ${acceptedFractionalTimestamps.length}/6 fractional timestamps accepted: ${acceptedFractionalTimestamps.join(", ")}`);

// ---- P1a2-i-A-1d strict event guard probes --------------------------------
const eventId = "e".repeat(64);
// Shape-equivalent payloads remain valid under either matching event type; no provenance discriminant exists here.
const eventCases: readonly { readonly type: string; readonly event: Record<string, unknown> }[] = [
  { type: "ack_dispatch", event: { eventId, type: "ack_dispatch", payload: { dispatchId: "a".repeat(64) } } },
  { type: "acquire", event: { eventId, type: "acquire", payload: { ownerToken: "b".repeat(64), leaseExpiresAt: 0 } } },
  { type: "takeover", event: { eventId, type: "takeover", payload: { ownerToken: "c".repeat(64), leaseExpiresAt: 1 } } },
  { type: "auth_intent", event: { eventId, type: "auth_intent", payload: { attemptId: "d".repeat(64), intentAt: 2 } } },
  { type: "auth_start", event: { eventId, type: "auth_start", payload: { attemptId: "f".repeat(64), callStartedAt: 3 } } },
  { type: "auth_confirm", event: { eventId, type: "auth_confirm", payload: { attemptId: "1".repeat(64), returnedUid: "uid-1", returnedEmail: "employee@example.com", proof: { attemptId: "1".repeat(64), confirmedAt: 4, uidRead: "uid-1", emailRead: "employee@example.com" } } } },
  { type: "auth_no_effect", event: { eventId, type: "auth_no_effect", payload: { attemptId: "2".repeat(64), code: "unavailable" } } },
  { type: "auth_ambiguous", event: { eventId, type: "auth_ambiguous", payload: { attemptId: "3".repeat(64), code: "internal" } } },
  { type: "auth_foreign_user", event: { eventId, type: "auth_foreign_user", payload: { uid: "foreign-uid", email: "foreign@example.com" } } },
  { type: "auth_preflight", event: { eventId, type: "auth_preflight", payload: { intendedUid: "uid-2", email: "employee@example.com" } } },
  { type: "profile_commit", event: { eventId, type: "profile_commit", payload: { userId: "uid-3" } } },
  { type: "terminalize", event: { eventId, type: "terminalize", payload: { terminalCode: "unavailable", recoveryCode: "internal" } } },
];
const copyEvent = (event: Record<string, unknown>): Record<string, unknown> => ({ ...event, payload: { ...(event.payload as Record<string, unknown>) } });
ok(!isEventType("unknown") && !isEventType(null), "1d unknown event type rejected");
eventCases.forEach(({ type, event }) => {
  ok(isEventType(type), `1d ${type} vocabulary accepted`);
  ok(isValidEvent(event), `1d ${type} literal event accepted`);
  const missing = copyEvent(event); delete (missing.payload as Record<string, unknown>)[Object.keys(missing.payload as object)[0]];
  ok(!isValidEvent(missing), `1d ${type} missing payload field rejected`);
  const extra = copyEvent(event); (extra.payload as Record<string, unknown>).extra = true;
  ok(!isValidEvent(extra), `1d ${type} extra payload field rejected`);
});
const firstEvent = eventCases[0].event;
const nullRootId = copyEvent(firstEvent); nullRootId.eventId = null;
const nullPayloadId = copyEvent(firstEvent); (nullPayloadId.payload as Record<string, unknown>).dispatchId = null;
ok(!isValidEvent(nullRootId) && !isValidEvent(nullPayloadId), "1d null event identifiers rejected");
const nonFiniteFailures = eventCases.flatMap(({ type, event }) => Object.entries(event.payload as Record<string, unknown>)
  .filter(([, value]) => typeof value === "number").flatMap(([field]) => [Number.NaN, Infinity, -Infinity].flatMap(value => {
    const candidate = copyEvent(event); (candidate.payload as Record<string, unknown>)[field] = value;
    return isValidEvent(candidate) ? [`${type}.${field}=${value}`] : [];
  })));
ok(nonFiniteFailures.length === 0, `1d non-finite numeric fields rejected: ${JSON.stringify(nonFiniteFailures)}`);
class EventRoot {}
class EventPayload {}
const eventClassRoot = Object.assign(new EventRoot(), firstEvent);
const eventNullPrototypeRoot = Object.assign(Object.create(null), firstEvent);
const eventPollutedRoot = copyEvent(firstEvent); Object.setPrototypeOf(eventPollutedRoot, { polluted: true });
const arrayRoot = [firstEvent];
const dateRoot = new Date();
ok(!isValidEvent(eventClassRoot) && !isValidEvent(eventNullPrototypeRoot) && !isValidEvent(eventPollutedRoot) && !isValidEvent(arrayRoot) && !isValidEvent(dateRoot), "1d non-plain event roots rejected");
const datePayload = copyEvent(firstEvent); datePayload.payload = new Date();
const classPayload = copyEvent(firstEvent); classPayload.payload = Object.assign(new EventPayload(), firstEvent.payload);
const nullPrototypePayload = copyEvent(firstEvent); nullPrototypePayload.payload = Object.assign(Object.create(null), firstEvent.payload);
const pollutedPayload = copyEvent(firstEvent); Object.setPrototypeOf(pollutedPayload.payload as object, { polluted: true });
const symbolExtra = copyEvent(firstEvent) as Record<PropertyKey, unknown>; symbolExtra[Symbol("extra")] = true;
const nestedPayload = copyEvent(eventCases[5].event); (nestedPayload.payload as Record<string, unknown>).proof = new Date();
ok(!isValidEvent(datePayload) && !isValidEvent(classPayload) && !isValidEvent(nullPrototypePayload) && !isValidEvent(pollutedPayload) && !isValidEvent(symbolExtra) && !isValidEvent(nestedPayload), "1d non-plain payloads and symbol root extras rejected");

// ---- Ordinal 69 RED: descriptor/proxy event-guard fail-closed matrix ------
const closed = (value: unknown): boolean => { try { return isValidEvent(value) === false; } catch { return false; } };
const descriptorEvent = () => ({ eventId, type: "ack_dispatch", payload: { dispatchId: "a".repeat(64) } });
const descriptorAuthEvent = () => ({ eventId, type: "auth_confirm", payload: { attemptId: "1".repeat(64), returnedUid: "uid-1", returnedEmail: "employee@example.com", proof: { attemptId: "1".repeat(64), confirmedAt: 4, uidRead: "uid-1", emailRead: "employee@example.com" } } });
const proxyTrap = (target: object, trap: "getPrototypeOf" | "ownKeys" | "getOwnPropertyDescriptor") => new Proxy(target, { [trap]: () => { throw new Error(`${trap} trap`); } });
const descriptorCases: readonly (readonly [string, () => boolean])[] = [
  ["root value accessor rejected without execution", () => { const value = descriptorEvent(); let read = false; Object.defineProperty(value, "eventId", { enumerable: true, get: () => { read = true; return eventId; } }); return closed(value) && !read; }],
  ["root throwing accessor fails closed", () => { const value = descriptorEvent(); Object.defineProperty(value, "eventId", { enumerable: true, get: () => { throw new Error("root getter"); } }); return closed(value); }],
  ...(["getPrototypeOf", "ownKeys", "getOwnPropertyDescriptor"] as const).map(trap => [`root ${trap} proxy fails closed`, () => closed(proxyTrap(descriptorEvent(), trap))] as const),
  ["payload value accessor rejected without execution", () => { const value = descriptorEvent(); let read = false; Object.defineProperty(value.payload, "dispatchId", { enumerable: true, get: () => { read = true; return "a".repeat(64); } }); return closed(value) && !read; }],
  ["payload throwing accessor fails closed", () => { const value = descriptorEvent(); Object.defineProperty(value.payload, "dispatchId", { enumerable: true, get: () => { throw new Error("payload getter"); } }); return closed(value); }],
  ...(["getPrototypeOf", "ownKeys", "getOwnPropertyDescriptor"] as const).map(trap => [`payload ${trap} proxy fails closed`, () => { const value = descriptorEvent(); value.payload = proxyTrap(value.payload, trap) as typeof value.payload; return closed(value); }] as const),
  ["proof value accessor rejected without execution", () => { const value = descriptorAuthEvent(); let read = false; Object.defineProperty(value.payload.proof, "attemptId", { enumerable: true, get: () => { read = true; return "1".repeat(64); } }); return closed(value) && !read; }],
  ["proof throwing accessor fails closed", () => { const value = descriptorAuthEvent(); Object.defineProperty(value.payload.proof, "attemptId", { enumerable: true, get: () => { throw new Error("proof getter"); } }); return closed(value); }],
  ...(["getPrototypeOf", "ownKeys", "getOwnPropertyDescriptor"] as const).map(trap => [`proof ${trap} proxy fails closed`, () => { const value = descriptorAuthEvent(); value.payload.proof = proxyTrap(value.payload.proof, trap) as typeof value.payload.proof; return closed(value); }] as const),
];
const descriptorFailures = descriptorCases.filter(([, check]) => !check()).map(([label]) => label);
if (descriptorFailures.length > 0) throw new Error(`ordinal 69 RED: ${descriptorFailures.length}/15 descriptor/proxy cases failed: ${descriptorFailures.join(", ")}`);
console.log("=== Ordinal 69 descriptor/proxy fail-closed matrix: 15/15 ===");

// ---- P1a2-i-A-2 validated constructor probes (RED) ------------------------
const throws = (action: () => unknown): boolean => {
  try { action(); return false; } catch { return true; }
};

const initialState = createInitialState(validState());
ok(isValidState(initialState), "A-2 initial state is valid");
ok(Object.isFrozen(initialState), "A-2 initial state is frozen");
ok(Object.isFrozen(initialState.normalizedPayload), "A-2 initial payload is frozen");
ok(createInitialState({ ...validState(), createdAt: new Date(1) }).createdAt === 1, "A-2 valid Date canonicalizes to timestamp");
const invalidInitialStates: readonly [string, () => unknown][] = [
  ["extra field", () => createInitialState({ ...validState(), extra: true })],
  ["missing field", () => { const state = validState() as unknown as Record<string, unknown>; delete state.fingerprint; return createInitialState(state); }],
  ["invalid Date", () => createInitialState({ ...validState(), createdAt: new Date("invalid") })],
  ["invalid pair", () => createInitialState({ ...validState(), phase: "terminal" })],
  ["malformed identifier", () => createInitialState({ ...validState(), operationId: "invalid" })],
  ["fractional counter", () => createInitialState({ ...validState(), generation: 0.5 })],
  ["malformed nested payload", () => createInitialState({ ...validState(), normalizedPayload: new Date() })],
];
invalidInitialStates.forEach(([label, action]) => ok(throws(action), `A-2 initial ${label} rejected`));

eventCases.forEach(({ type, event }) => {
  const created = createEvent(type, event.payload);
  ok(isValidEvent(created), `A-2 ${type} event is valid`);
  ok(Object.isFrozen(created), `A-2 ${type} event is frozen`);
  ok(Object.isFrozen(created.payload), `A-2 ${type} payload is frozen`);
});
ok(throws(() => createEvent("unknown", {})), "A-2 unknown event rejected");
ok(throws(() => createEvent("ack_dispatch", {})), "A-2 missing event payload rejected");
ok(throws(() => createEvent("ack_dispatch", { dispatchId: "a".repeat(64), extra: true })), "A-2 extra event payload rejected");
ok(throws(() => createEvent("auth_confirm", { ...eventCases[5].event.payload as Record<string, unknown>, proof: new Date() })), "A-2 malformed nested proof rejected");
ok(throws(() => createEvent("ack_dispatch", new Proxy({ dispatchId: "a".repeat(64) }, { ownKeys: () => { throw new Error("proxy"); } }))), "A-2 proxy payload rejected");

const success = createSuccessResult(validState());
if (success.type !== "success") throw new Error("FAIL: A-2 success result type");
ok(isValidState(success.state), "A-2 success result is valid");
ok(Object.isFrozen(success) && Object.isFrozen(success.state), "A-2 success result is frozen");
ok(throws(() => createSuccessResult({ ...validState(), phase: "terminal" })), "A-2 invalid success pair rejected");
ok(throws(() => { const state = validState() as unknown as Record<string, unknown>; delete state.operationId; return createSuccessResult(state); }), "A-2 missing success state field rejected");

const whitespaceFailure = createFailureResult(" ");
ok(whitespaceFailure.type === "failure" && whitespaceFailure.reason === " ", "A-2 whitespace reason remains a non-empty string");
ok(Object.isFrozen(whitespaceFailure), "A-2 failure result is frozen");
ok(throws(() => createFailureResult("")), "A-2 empty reason rejected");
ok(throws(() => createFailureResult(null)), "A-2 non-string reason rejected");

// ---- P1a2-i-B-1a request contract and reducer surface (RED) ---------------
const expectedFor = (state: OperationState = validState()): ExpectedCAS => ({
  fingerprint: state.fingerprint, status: state.status, phase: state.phase,
  generation: state.generation, version: state.version, ownerToken: state.ownerToken,
  currentDispatchId: state.currentDispatchId, leaseExpiresAt: state.leaseExpiresAt,
});
const requestFor = (event: unknown = eventCases[0].event): ReducerRequest => ({ expected: expectedFor(), observedAt: 0, event: event as never });
const failureReason = (result: TransitionResult, reason: string): void => ok(result.type === "failure" && result.reason === reason, `B-1a ${reason}`);
const containsReference = (root: unknown, needle: object, seen = new WeakSet<object>()): boolean => {
  if (root === needle) return true;
  if (root === null || typeof root !== "object" || seen.has(root)) return false;
  seen.add(root);
  for (const descriptor of Object.values(Object.getOwnPropertyDescriptors(root))) {
    if ("value" in descriptor && containsReference(descriptor.value, needle, seen)) return true;
  }
  return false;
};
const ownData = (value: unknown, field: string): unknown => {
  try { const descriptor = Object.getOwnPropertyDescriptor(value as object, field); return descriptor && "value" in descriptor ? descriptor.value : undefined; } catch { return undefined; }
};
const unchanged = (state: OperationState, request: ReducerRequest, stateJson: string, expected: unknown, event: unknown): void => {
  ok(JSON.stringify(state) === stateJson, "B-1a canonical state snapshot unchanged");
  ok(ownData(request, "expected") === expected && ownData(request, "event") === event && (event === undefined || ownData(ownData(request, "event"), "payload") === ownData(event, "payload")), "B-1a direct and deep references unchanged");
};
const assertRejected = (request: ReducerRequest, reason: "invalid_request" | "invalid_expected" | "invalid_event"): void => {
  const state = validState(), expected = ownData(request, "expected"), event = ownData(request, "event");
  const stateJson = JSON.stringify(state);
  const result = reduce(state, request);
  failureReason(result, reason); unchanged(state, request, stateJson, expected, event);
  ok(!containsReference(result, request) && !(event instanceof Object && containsReference(result, event)), "B-1a result retains no request/event graph reference");
};
const requestBad = [
  () => ({ ...requestFor(), extra: true }), () => { const r = requestFor() as unknown as Record<PropertyKey, unknown>; delete r.event; return r; },
  () => Object.assign(new (class Request {})(), requestFor()), () => { const r = requestFor(); Object.setPrototypeOf(r, { polluted: true }); return r; },
  () => { const r = requestFor() as unknown as Record<PropertyKey, unknown>; r[Symbol("extra")] = true; return r; },
  () => new Proxy(requestFor(), { ownKeys: () => { throw new Error("trap"); } }),
] as const;
requestBad.forEach(make => assertRejected(make() as ReducerRequest, "invalid_request"));
const expectedBad = [
  () => ({ ...requestFor(), expected: { ...expectedFor(), extra: true } }), () => { const r = requestFor(); delete (r.expected as unknown as Record<string, unknown>).version; return r; },
  () => ({ ...requestFor(), expected: Object.assign(new (class Expected {})(), expectedFor()) }), () => { const r = requestFor(); Object.setPrototypeOf(r.expected, { polluted: true }); return r; },
  () => ({ ...requestFor(), expected: new Proxy(expectedFor(), { ownKeys: () => { throw new Error("trap"); } }) }),
] as const;
expectedBad.forEach(make => assertRejected(make() as ReducerRequest, "invalid_expected"));
[0.5, -1, Number.NaN, Infinity, "0"].forEach(observedAt => assertRejected({ ...requestFor(), observedAt } as ReducerRequest, "invalid_request"));
const accessorRequest = requestFor() as unknown as Record<string, unknown>; let requestGetterRead = false;
Object.defineProperty(accessorRequest, "observedAt", { enumerable: true, get: () => { requestGetterRead = true; return 0; } });
assertRejected(accessorRequest as unknown as ReducerRequest, "invalid_request"); ok(!requestGetterRead, "B-1a request getter was not executed");
const accessorExpected = requestFor(); let expectedGetterRead = false;
Object.defineProperty(accessorExpected.expected, "fingerprint", { enumerable: true, get: () => { expectedGetterRead = true; return "a".repeat(64); } });
assertRejected(accessorExpected, "invalid_expected"); ok(!expectedGetterRead, "B-1a expected getter was not executed");
const malformedEvent = { ...eventCases[0].event, payload: {} };
assertRejected(requestFor(malformedEvent), "invalid_event");
const extraEvent = { ...eventCases[0].event, payload: { ...(eventCases[0].event.payload as object), extra: true } };
assertRejected(requestFor(extraEvent), "invalid_event");
assertRejected({ ...requestFor(), expected: { ...expectedFor(), status: "not-a-status" } } as unknown as ReducerRequest, "invalid_expected");
const validRequest = requestFor(); failureReason(reduce(validState(), validRequest), "unsupported_event");
reduce(validState(), validRequest);
// @ts-expect-error B-1a replaces reduce(state, event) with a request envelope.
reduce(validState(), validRequest.event);
// @ts-expect-error ExpectedCAS object literals require all eight fields.
const missingExpected: ExpectedCAS = { fingerprint: "a".repeat(64), status: "pending", phase: "dispatch_pending", generation: 0, version: 0, ownerToken: null, currentDispatchId: null };
// @ts-expect-error ExpectedCAS object literals reject extra fields.
const extraExpected: ExpectedCAS = { ...expectedFor(), extra: true };
void missingExpected; void extraExpected;

// ---- P1a2-i-B-1b CAS, lease, and dispatch fence (RED) --------------------
const activeState = (): OperationState => ({ ...validState(), status: "active", phase: "auth_preflight", ownerToken: "b".repeat(64), leaseExpiresAt: 10, currentDispatchId: "c".repeat(64) });
const b1bRequest = (state: OperationState, event: unknown = eventCases[0].event, observedAt = 5): ReducerRequest => ({ expected: expectedFor(state), observedAt, event: event as never });
const b1bFailure = (state: OperationState, request: ReducerRequest, reason: string, label: string): void => {
  const stateJson = JSON.stringify(state), requestJson = JSON.stringify(request), statePayload = state.normalizedPayload, expected = request.expected, event = request.event, payload = event.payload;
  const result = reduce(state, request); failureReason(result, reason);
  ok(JSON.stringify(state) === stateJson && JSON.stringify(request) === requestJson, `B-1b ${label} snapshots unchanged`);
  ok(state.normalizedPayload === statePayload && request.expected === expected && request.event === event && event.payload === payload && !containsReference(result, state) && !containsReference(result, request), `B-1b ${label} references unchanged`);
};
const live = activeState(), exact = expectedFor(live);
const casMismatches: readonly [string, ExpectedCAS][] = [
  ["fingerprint", { ...exact, fingerprint: "d".repeat(64) }], ["status", { ...exact, status: "pending" }],
  ["phase", { ...exact, phase: "auth_create" }], ["generation", { ...exact, generation: 1 }],
  ["version", { ...exact, version: 1 }], ["ownerToken", { ...exact, ownerToken: "d".repeat(64) }],
  ["currentDispatchId", { ...exact, currentDispatchId: "d".repeat(64) }], ["leaseExpiresAt", { ...exact, leaseExpiresAt: 11 }],
];
casMismatches.forEach(([field, expected]) => b1bFailure(live, { ...b1bRequest(live), expected }, "cas_mismatch", `${field} mismatch`));
b1bFailure({ ...live, leaseExpiresAt: 5 }, b1bRequest({ ...live, leaseExpiresAt: 5 }, eventCases[1].event, 5), "lease_not_live", "expired lease");
b1bFailure({ ...live, leaseExpiresAt: null }, b1bRequest({ ...live, leaseExpiresAt: null }, eventCases[1].event), "lease_not_live", "active null lease");
eventCases.filter(({ type }) => ["auth_preflight", "auth_no_effect", "ack_dispatch", "terminalize"].includes(type)).forEach(({ type, event }) => b1bFailure(live, b1bRequest(live, event), "unsupported_event", `${type} dispatch`));
const terminal = { ...validState(), status: "completed" as const, phase: "terminal" as const, intendedUid:"uid-1", authAttempted:true, authAttempt:strictAttempt() };
b1bFailure(terminal, b1bRequest(terminal), "unsupported_event", "terminal dispatch");

// ---- P1a2-i-B-2 terminal rejection and non-mutation (RED) ----------------
const terminalState = (status: "completed" | "failed" | "manual_recovery"): OperationState => ({
  ...validState(), status, phase: "terminal",
  ...(status === "completed" ? { intendedUid:"uid-1", authAttempted:true, authAttempt:strictAttempt() } : {}),
  ...(status === "manual_recovery" ? { intendedUid:"uid-1", authAttempted:true, authAttempt:{ attemptId:"b".repeat(64), intentAt:0, callStartedAt:0, result:"ambiguous", returnedUid:null, returnedEmail:null, proof:null } } : {}),
});
const b2Failure = (state: OperationState, request: ReducerRequest, reason: string, label: string): string | null => {
  const stateJson = JSON.stringify(state), requestJson = JSON.stringify(request);
  const payload = state.normalizedPayload, expected = request.expected, event = request.event, eventPayload = event.payload;
  const version = state.version, generation = state.generation;
  const result = reduce(state, request);
  const valid = result.type === "failure" && result.reason === reason
    && JSON.stringify(state) === stateJson && JSON.stringify(request) === requestJson
    && state.normalizedPayload === payload && request.expected === expected
    && request.event === event && event.payload === eventPayload
    && state.version === version && state.generation === generation
    && !containsReference(result, state) && !containsReference(result, request) && !containsReference(result, event);
  return valid ? null : `${label}: expected ${reason}, got ${result.type === "failure" ? result.reason : result.type}`;
};
const terminalStatuses = ["completed", "failed", "manual_recovery"] as const;
const nonAckEvents = eventCases.filter(({ type }) => type !== "ack_dispatch");
const b2RedFailures: string[] = [];
for (const status of terminalStatuses) {
  for (const { type, event } of nonAckEvents) {
    const state = terminalState(status);
    const failure = b2Failure(state, b1bRequest(state, event), "terminal_state", `${status}/${type}`);
    if (failure) b2RedFailures.push(failure);
  }
}
for (const status of terminalStatuses) {
  const state = terminalState(status);
  const request = { ...b1bRequest(state, eventCases[1].event), expected: { ...expectedFor(state), version: state.version + 1 } };
  const failure = b2Failure(state, request, "terminal_state", `${status}/stale-expected`);
  if (failure) b2RedFailures.push(failure);
}
if (b2RedFailures.length > 0) throw new Error(`B-2 RED: ${b2RedFailures.length}/36 terminal-policy vectors failed: ${b2RedFailures.join("; ")}`);

const b2BaselineFailures: string[] = [];
for (const [status, label, request, reason] of [
  ["completed", "malformed-request", (state: OperationState) => ({ ...b1bRequest(state), observedAt: -1 } as ReducerRequest), "invalid_request"],
  ["failed", "malformed-expected", (state: OperationState) => ({ ...b1bRequest(state), expected: { ...expectedFor(state), version: -1 } } as ReducerRequest), "invalid_expected"],
  ["manual_recovery", "malformed-event", (state: OperationState) => b1bRequest(state, { ...eventCases[1].event, payload: {} }), "invalid_event"],
] as const) {
  const state = terminalState(status);
  const failure = b2Failure(state, request(state), reason, `${status}/${label}`);
  if (failure) b2BaselineFailures.push(failure);
}
for (const status of terminalStatuses) {
  const state = terminalState(status);
  const failure = b2Failure(state, b1bRequest(state, eventCases[0].event), "unsupported_event", `${status}/terminal-ack`);
  if (failure) b2BaselineFailures.push(failure);
}
if (b2BaselineFailures.length > 0) throw new Error(`B-2 baseline regression: ${b2BaselineFailures.join("; ")}`);
console.log("=== B-2 controls: 36 genuine RED vectors and 6 inherited baseline controls ===");

// ---- P1a2-i-C RED: literal AuthAttempt lifecycle oracle -------------------
// This table is deliberately test-owned. It is not derived from model helpers.
type LifecycleShape = "Ø" | "I" | "C" | "D" | "K" | "A";
const LIFECYCLE_ORACLE: readonly { readonly status: string; readonly phase: string; readonly admitted: readonly LifecycleShape[] }[] = [
  { status:"pending", phase:"dispatch_pending", admitted:["Ø"] },
  { status:"active", phase:"auth_preflight", admitted:["Ø","D"] },
  { status:"active", phase:"auth_create", admitted:["I","C"] },
  { status:"active", phase:"profile_commit", admitted:["K"] },
  { status:"completed", phase:"terminal", admitted:["K"] },
  { status:"failed", phase:"terminal", admitted:["Ø","D"] },
  { status:"manual_recovery", phase:"terminal", admitted:["I","C","D","K","A"] },
];
const lifecycleAttempt = (shape: Exclude<LifecycleShape,"Ø"> = "I", uid = "uid-1", email = "employee@example.com") => {
  const base = { attemptId:"b".repeat(64), intentAt:1, callStartedAt:null as number | null, result:"intent", returnedUid:null as string | null, returnedEmail:null as string | null, proof:null as Record<string, unknown> | null };
  if (shape === "I") return base;
  if (shape === "K") return { ...base, callStartedAt:2, result:"confirmed", returnedUid:uid, returnedEmail:email, proof:{ attemptId:base.attemptId, confirmedAt:3, uidRead:uid, emailRead:email } };
  return { ...base, callStartedAt:2, result:shape === "C" ? "call_started" : shape === "D" ? "definite_no_effect" : "ambiguous" };
};
const lifecycleState = (status: string, phase: string, shape: LifecycleShape): OperationState => {
  const attempted = shape !== "Ø";
  return {
    ...validState(), status:status as OperationState["status"], phase:phase as OperationState["phase"],
    intendedUid:attempted ? "uid-1" : null, ownerToken:status === "active" ? "c".repeat(64) : null,
    leaseExpiresAt:status === "active" ? 10 : null, authAttempted:attempted,
    authAttempt:attempted ? lifecycleAttempt(shape as Exclude<LifecycleShape,"Ø">) : null,
  } as OperationState;
};
const lifecycleRequest = (state: OperationState): ReducerRequest => ({ expected:expectedFor(state), observedAt:5, event:eventCases[1].event as never });
const lifecycleRejected = (label: string, state: OperationState): void => {
  const request = lifecycleRequest(state), stateJson = JSON.stringify(state), requestJson = JSON.stringify(request);
  const payload = state.normalizedPayload, attempt = state.authAttempt, expected = request.expected, event = request.event, eventPayload = event.payload;
  const version = state.version, generation = state.generation, result = reduce(state, request);
  failureReason(result, "invalid_state");
  ok(JSON.stringify(state) === stateJson && JSON.stringify(request) === requestJson, `C ${label} snapshots retained`);
  ok(state.normalizedPayload === payload && state.authAttempt === attempt && request.expected === expected && request.event === event && event.payload === eventPayload, `C ${label} direct references retained`);
  ok(state.version === version && state.generation === generation && !containsReference(result, state) && !containsReference(result, request) && !containsReference(result, event), `C ${label} no mutation or result graph`);
};
for (const row of LIFECYCLE_ORACLE) {
  for (const shape of ["Ø","I","C","D","K","A"] as const) {
    const state = lifecycleState(row.status, row.phase, shape);
    const label = `${row.status}/${row.phase}/${shape}`;
    if (row.admitted.includes(shape)) {
      ok(isValidState(state), `C canonical ${label} admitted`);
      const request = lifecycleRequest(state), stateJson = JSON.stringify(state), requestJson = JSON.stringify(request);
      reduce(state, request);
      ok(JSON.stringify(state) === stateJson && JSON.stringify(request) === requestJson && state.authAttempt === (shape === "Ø" ? null : state.authAttempt), `C canonical ${label} retained`);
    } else lifecycleRejected(`complement ${label}`, state);
  }
}

const lifecycleInvalids: readonly [string, (state: Record<string, any>) => void][] = [
  ["noncanonical pair", s => { s.phase = "terminal"; }],
  ["false with attempt", s => { s.authAttempted=false; s.authAttempt=lifecycleAttempt("I"); s.intendedUid="uid-1"; }],
  ["true with null", s => { s.authAttempted=true; s.authAttempt=null; }],
  ["attempt with null intended UID", s => { s.authAttempted=true; s.authAttempt=lifecycleAttempt("I"); s.intendedUid=null; }],
  ["intent call started must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("I"); s.authAttempt.callStartedAt=2; }],
  ["intent returned UID must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("I"); s.authAttempt.returnedUid="uid-1"; }],
  ["intent returned email must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("I"); s.authAttempt.returnedEmail="employee@example.com"; }],
  ["intent proof must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("I"); s.authAttempt.proof={ attemptId:"b".repeat(64), confirmedAt:3, uidRead:"uid-1", emailRead:"employee@example.com" }; }],
  ["call started timestamp required", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("C"); s.authAttempt.callStartedAt=null; }],
  ["call started returned UID must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("C"); s.authAttempt.returnedUid="uid-1"; }],
  ["call started returned email must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("C"); s.authAttempt.returnedEmail="employee@example.com"; }],
  ["call started proof must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("C"); s.authAttempt.proof={ attemptId:"b".repeat(64), confirmedAt:3, uidRead:"uid-1", emailRead:"employee@example.com" }; }],
  ["definite timestamp required", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("D"); s.authAttempt.callStartedAt=null; }],
  ["definite result returned UID must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("D"); s.authAttempt.returnedUid="uid-1"; }],
  ["definite returned email must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("D"); s.authAttempt.returnedEmail="employee@example.com"; }],
  ["definite proof must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("D"); s.authAttempt.proof={ attemptId:"b".repeat(64), confirmedAt:3, uidRead:"uid-1", emailRead:"employee@example.com" }; }],
  ["ambiguous timestamp required", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("A"); s.authAttempt.callStartedAt=null; }],
  ["ambiguous returned UID must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("A"); s.authAttempt.returnedUid="uid-1"; }],
  ["ambiguous returned email must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("A"); s.authAttempt.returnedEmail="employee@example.com"; }],
  ["ambiguous proof must be null", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("A"); s.authAttempt.proof={ attemptId:"b".repeat(64), confirmedAt:3, uidRead:"uid-1", emailRead:"employee@example.com" }; }],
  ["confirmed call started required", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("K"); s.authAttempt.callStartedAt=null; }],
  ["confirmed returned UID required", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("K"); s.authAttempt.returnedUid=null; }],
  ["confirmed returned email required", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("K"); s.authAttempt.returnedEmail=null; }],
  ["confirmed proof required", s => { s.authAttempted=true; s.intendedUid="uid-1"; s.authAttempt=lifecycleAttempt("K"); s.authAttempt.proof=null; }],
];
for (const [label, mutate] of lifecycleInvalids) {
  const state = lifecycleState("active", "auth_create", "I") as unknown as Record<string, any>;
  mutate(state); lifecycleRejected(label, state as OperationState);
}
for (const [shape, status, phase] of [["I","active","auth_create"],["C","active","auth_create"],["D","active","auth_preflight"],["K","active","profile_commit"],["A","manual_recovery","terminal"]] as const) {
  const state = lifecycleState(status, phase, shape) as unknown as Record<string, any>;
  state.intendedUid = null; lifecycleRejected(`${shape} attempt with null intended UID`, state as OperationState);
}
for (const [label, mutate] of [
  ["confirmed attempt ID", (s: Record<string, any>) => { s.authAttempt.proof.attemptId="d".repeat(64); }],
  ["confirmed returned UID", (s: Record<string, any>) => { s.authAttempt.returnedUid="other-uid"; }],
  ["confirmed proof UID", (s: Record<string, any>) => { s.authAttempt.proof.uidRead="other-uid"; }],
  ["confirmed returned email", (s: Record<string, any>) => { s.authAttempt.returnedEmail="other@example.com"; }],
  ["confirmed proof email", (s: Record<string, any>) => { s.authAttempt.proof.emailRead="other@example.com"; }],
] as const) {
  const state = lifecycleState("active", "profile_commit", "K") as unknown as Record<string, any>;
  mutate(state); lifecycleRejected(label, state as OperationState);
}
console.log("=== P1a2-i-C RED oracle: 7 rows, 42-row finite complement, lifecycle/correlation retention ===");

// ---- P1a2-ii RED: exact eight-event transition matrix --------------------
const iiOwner = "d".repeat(64), iiOtherOwner = "f".repeat(64), iiDispatch = "9".repeat(64);
const iiAttempt = "7".repeat(64), iiUid = "uid-1", iiEmail = "employee@example.com";
const iiEvent = (type: EventType, payload: Record<string, unknown>): ModelEvent => createEvent(type, payload);
const iiRequest = (state: OperationState, event: ModelEvent, observedAt = 5): ReducerRequest => ({ expected: expectedFor(state), observedAt, event });
const iiActive = (phase: "auth_preflight" | "auth_create" | "profile_commit", shape: LifecycleShape): OperationState => ({
  ...lifecycleState("active", phase, shape), ownerToken: "c".repeat(64), leaseExpiresAt: 10, currentDispatchId: iiDispatch,
});
const iiWithUid = (state: OperationState): OperationState => ({ ...state, intendedUid: iiUid });
const iiProof = () => ({ attemptId: iiAttempt, confirmedAt: 3, uidRead: iiUid, emailRead: iiEmail });
const iiConfirmed = (): OperationState => iiActive("profile_commit", "K");
const iiCallStarted = (): OperationState => ({
  ...iiActive("auth_create", "C"), authAttempt: { ...(lifecycleAttempt("C") as NonNullable<OperationState["authAttempt"]>), attemptId: iiAttempt }, intendedUid: iiUid,
});
const iiIntent = (): OperationState => ({
  ...iiActive("auth_create", "I"), authAttempt: { ...(lifecycleAttempt("I") as NonNullable<OperationState["authAttempt"]>), attemptId: iiAttempt }, intendedUid: iiUid,
});
const iiReject = (label: string, state: OperationState, request: ReducerRequest, reason: string): void => {
  const stateJson = JSON.stringify(state), requestJson = JSON.stringify(request);
  const refs = [state.normalizedPayload, state.authAttempt, request.expected, request.event, request.event.payload];
  const result = reduce(state, request);
  failureReason(result, reason);
  ok(JSON.stringify(state) === stateJson && JSON.stringify(request) === requestJson, `ii ${label} snapshots retained`);
  ok(refs[0] === state.normalizedPayload && refs[1] === state.authAttempt && refs[2] === request.expected && refs[3] === request.event && refs[4] === request.event.payload, `ii ${label} references retained`);
  ok(!containsReference(result, request) && !containsReference(result, request.event), `ii ${label} result retains no request/event graph`);
};
const iiSuccess = (label: string, state: OperationState, request: ReducerRequest, check: (next: OperationState) => void): void => {
  const stateJson = JSON.stringify(state), requestJson = JSON.stringify(request);
  const result = reduce(state, request);
  ok(result.type === "success", `ii ${label} succeeds`);
  if (result.type !== "success") return;
  const next = result.state;
  ok(JSON.stringify(state) === stateJson && JSON.stringify(request) === requestJson, `ii ${label} inputs retained`);
  ok(next.operationId === state.operationId && next.fingerprint === state.fingerprint && JSON.stringify(next.normalizedPayload) === JSON.stringify(state.normalizedPayload)
    && next.intendedUid === state.intendedUid && next.createdAt === state.createdAt && next.currentDispatchId === state.currentDispatchId,
  `ii ${label} common immutable fields`);
  ok(next.updatedAt === request.observedAt && next.version === state.version + 1, `ii ${label} timestamp and version`);
  ok(Object.isFrozen(result) && Object.isFrozen(next) && !containsReference(result, request) && !containsReference(result, request.event), `ii ${label} frozen detached result`);
  check(next);
};

// ii.2 RED acquire: exact initial state and live payload lease only.
{
  const state = validState(), event = iiEvent("acquire", { ownerToken: iiOwner, leaseExpiresAt: 10 });
  iiSuccess("ACQ", state, iiRequest(state, event), next => {
    ok(next.status === "active" && next.phase === "auth_preflight" && next.ownerToken === iiOwner && next.leaseExpiresAt === 10, "ii ACQ output owner/lease");
    ok(next.generation === 0 && next.authAttempted === false && next.authAttempt === null, "ii ACQ generation/auth retained");
  });
  const nonInitial = { ...state, version: 1 };
  iiReject("ACQ-LIFE", nonInitial, iiRequest(nonInitial, event), "unsupported_event");
  const nonLive = iiEvent("acquire", { ownerToken: iiOwner, leaseExpiresAt: 5 });
  iiReject("ACQ-PRED", state, iiRequest(state, nonLive), "lease_not_live");
}

// ii.4 RED takeover: all and only the five C-admitted active lifecycle rows.
for (const [phase, shape] of [["auth_preflight", "Ø"], ["auth_preflight", "D"], ["auth_create", "I"], ["auth_create", "C"], ["profile_commit", "K"]] as const) {
  const state = { ...iiActive(phase, shape), leaseExpiresAt: 5 }, event = iiEvent("takeover", { ownerToken: iiOtherOwner, leaseExpiresAt: 10 });
  iiSuccess(`TK-${phase}-${shape}`, state, iiRequest(state, event), next => {
    ok(next.status === state.status && next.phase === state.phase && JSON.stringify(next.authAttempt) === JSON.stringify(state.authAttempt), `ii TK-${shape} lifecycle retained`);
    ok(next.ownerToken === iiOtherOwner && next.leaseExpiresAt === 10 && next.generation === state.generation + 1, `ii TK-${shape} owner/generation`);
  });
}
{
  const state = iiActive("auth_preflight", "Ø"), live = iiRequest(state, iiEvent("takeover", { ownerToken: iiOtherOwner, leaseExpiresAt: 11 }));
  iiReject("TK-LEASE", state, live, "lease_not_live");
  const expired = { ...state, leaseExpiresAt: 5 };
  iiReject("TK-OWNER", expired, iiRequest(expired, iiEvent("takeover", { ownerToken: expired.ownerToken!, leaseExpiresAt: 10 })), "unsupported_event");
  const generationTwo = { ...expired, generation: 2 };
  iiSuccess("TK-GEN", generationTwo, iiRequest(generationTwo, iiEvent("takeover", { ownerToken: iiOtherOwner, leaseExpiresAt: 10 })), next => ok(next.generation === 3, "ii TK prior generation +1"));
  iiReject("TK-PAYLOAD-LEASE", expired, iiRequest(expired, iiEvent("takeover", { ownerToken: iiOtherOwner, leaseExpiresAt: 5 })), "lease_not_live");
}

// ii.6 RED auth_intent and ii.8 RED auth_start.
{
  const state = iiWithUid(iiActive("auth_preflight", "Ø")), event = iiEvent("auth_intent", { attemptId: iiAttempt, intentAt: 1 });
  iiSuccess("INT", state, iiRequest(state, event), next => {
    ok(next.status === "active" && next.phase === "auth_create" && next.authAttempted && next.authAttempt?.result === "intent", "ii INT output");
    ok(next.authAttempt?.attemptId === iiAttempt && next.authAttempt?.callStartedAt === null && next.authAttempt?.proof === null, "ii INT shape");
  });
  const wrong = iiActive("auth_preflight", "D");
  iiReject("INT-LIFE", wrong, iiRequest(wrong, event), "unsupported_event");
  const intent = iiIntent(), start = iiEvent("auth_start", { attemptId: iiAttempt, callStartedAt: 2 });
  iiSuccess("START", intent, iiRequest(intent, start), next => {
    ok(next.phase === "auth_create" && next.authAttempt?.result === "call_started" && next.authAttempt.callStartedAt === 2, "ii START output");
    ok(next.authAttempt?.attemptId === iiAttempt && next.authAttempt?.intentAt === 1 && next.authAttempt?.returnedUid === null && next.authAttempt?.proof === null, "ii START preserves intent fields");
  });
  const mismatched = iiEvent("auth_start", { attemptId: "8".repeat(64), callStartedAt: 2 });
  iiReject("START-LIFE", intent, iiRequest(intent, mismatched), "unsupported_event");
  const nullUid = iiActive("auth_preflight", "Ø");
  iiReject("INT-FACT", nullUid, iiRequest(nullUid, event), "unsupported_event");
}

// ii.10 RED auth_confirm: call_started plus all existing identity correlations.
{
  const state = iiCallStarted(), event = iiEvent("auth_confirm", { attemptId: iiAttempt, returnedUid: iiUid, returnedEmail: iiEmail, proof: iiProof() });
  iiSuccess("CONF", state, iiRequest(state, event), next => {
    ok(next.phase === "profile_commit" && next.authAttempt?.result === "confirmed", "ii CONF output phase/result");
    ok(next.authAttempt?.returnedUid === iiUid && next.authAttempt.returnedEmail === iiEmail && next.authAttempt.proof?.uidRead === iiUid, "ii CONF exact proof");
  });
  iiReject("CONF-LIFE", iiIntent(), iiRequest(iiIntent(), event), "unsupported_event");
  for (const [label, payload] of [
    ["CONF-ID", { ...event.payload as Record<string, unknown>, attemptId: "8".repeat(64), proof: { ...iiProof(), attemptId: "8".repeat(64) } }],
    ["CONF-UID", { ...event.payload as Record<string, unknown>, returnedUid: "other-uid" }],
    ["CONF-EMAIL", { ...event.payload as Record<string, unknown>, returnedEmail: "other@example.com" }],
    ["CONF-PROOF", { ...event.payload as Record<string, unknown>, proof: { ...iiProof(), uidRead: "other-uid" } }],
  ] as const) iiReject(label, state, iiRequest(state, iiEvent("auth_confirm", payload)), "unsupported_event");
}

// ii.12 RED auth_ambiguous and ii.14 RED auth_foreign_user.
{
  const state = iiCallStarted(), event = iiEvent("auth_ambiguous", { attemptId: iiAttempt, code: "internal" });
  iiSuccess("AMB", state, iiRequest(state, event), next => {
    ok(next.status === "manual_recovery" && next.phase === "terminal" && next.ownerToken === null && next.leaseExpiresAt === null, "ii AMB terminal clear");
    ok(next.authAttempt?.result === "ambiguous" && next.authAttempt.returnedUid === null && next.authAttempt.proof === null, "ii AMB attempt shape");
  });
  iiReject("AMB-LIFE", iiIntent(), iiRequest(iiIntent(), event), "unsupported_event");
  iiReject("AMB-ID", state, iiRequest(state, iiEvent("auth_ambiguous", { attemptId: "8".repeat(64), code: "internal" })), "unsupported_event");
  const foreign = iiWithUid(iiActive("auth_preflight", "Ø")), foreignEvent = iiEvent("auth_foreign_user", { uid: "foreign-uid", email: iiEmail });
  iiSuccess("FOR", foreign, iiRequest(foreign, foreignEvent), next => ok(next.status === "failed" && next.phase === "terminal" && next.ownerToken === null && next.authAttempt === null, "ii FOR terminal no copy"));
  const emailForeign = iiEvent("auth_foreign_user", { uid: iiUid, email: "foreign@example.com" });
  iiSuccess("FOR-EMAIL", foreign, iiRequest(foreign, emailForeign), next => ok(next.status === "failed" && next.intendedUid === iiUid, "ii FOR one-email inequality succeeds"));
  const bothMatch = iiEvent("auth_foreign_user", { uid: iiUid, email: iiEmail });
  iiReject("FOR-LIFE", foreign, iiRequest(foreign, bothMatch), "unsupported_event");
  const postAttempt = iiActive("auth_preflight", "D");
  iiReject("FOR-ATTEMPT", postAttempt, iiRequest(postAttempt, foreignEvent), "unsupported_event");
}

// ii.16 RED profile_commit and ii.18 RED retained unsupported events.
{
  const state = iiConfirmed(), event = iiEvent("profile_commit", { userId: iiUid });
  iiSuccess("PRO", state, iiRequest(state, event), next => {
    ok(next.status === "completed" && next.phase === "terminal" && next.ownerToken === null && next.leaseExpiresAt === null, "ii PRO completed clear");
    ok(JSON.stringify(next.authAttempt) === JSON.stringify(state.authAttempt), "ii PRO proof byte-identically retained");
  });
  iiReject("PRO-UID", state, iiRequest(state, iiEvent("profile_commit", { userId: "other-uid" })), "unsupported_event");
  const callStarted = iiCallStarted();
  iiReject("PRO-LIFE", callStarted, iiRequest(callStarted, event), "unsupported_event");
  const live = iiWithUid(iiActive("auth_preflight", "Ø"));
  for (const event of [
    iiEvent("auth_preflight", { intendedUid: iiUid, email: iiEmail }),
    iiEvent("auth_no_effect", { attemptId: iiAttempt, code: "unavailable" }),
    iiEvent("ack_dispatch", { dispatchId: iiDispatch }),
    iiEvent("terminalize", { terminalCode: "unavailable", recoveryCode: "internal" }),
  ]) iiReject(`UNSUPPORTED-${event.type}`, live, iiRequest(live, event), "unsupported_event");
}
console.log("=== P1a2-ii RED matrix: eight successes and negative/invariant families ===");

// ---- P3-B.2c-pre payload contract RED: persisted state has only 19 fields --
{
  const persistedPayload = (): OperationState["normalizedPayload"] => ({
    ...validState().normalizedPayload,
  });
  const persistedPending = (): OperationState => ({
    ...validState(), intendedUid: "uid-1", normalizedPayload: persistedPayload(),
  });
  const pending = persistedPending();
  const pendingPayload = pending.normalizedPayload;
  const pendingSnapshot = JSON.stringify(pending);
  const acquire = iiEvent("acquire", { ownerToken: iiOwner, leaseExpiresAt: 10 });

  ok(isValidState(pending), "P3-B.2c persisted 19-field pending state accepted");
  const acquired = reduce(pending, iiRequest(pending, acquire));
  ok(acquired.type === "success", "P3-B.2c persisted pending state acquires");
  if (acquired.type === "success") {
    const active = acquired.state;
    ok(active.status === "active" && active.phase === "auth_preflight", "P3-B.2c persisted pending becomes active");
    ok(active.normalizedPayload !== pendingPayload && JSON.stringify(active.normalizedPayload) === JSON.stringify(pendingPayload), "P3-B.2c acquisition preserves detached persisted payload");
    ok(active.fingerprint === pending.fingerprint, "P3-B.2c acquisition preserves canonical fingerprint");
    ok(Object.isFrozen(active) && Object.isFrozen(active.normalizedPayload), "P3-B.2c acquisition result is deeply frozen");
    const intent = iiEvent("auth_intent", { attemptId: iiAttempt, intentAt: 2 });
    const afterIntent = reduce(active, iiRequest(active, intent));
    ok(afterIntent.type === "success", "P3-B.2c active persisted state supports a later valid transition");
    if (afterIntent.type === "success") {
      ok(JSON.stringify(afterIntent.state.normalizedPayload) === JSON.stringify(pendingPayload), "P3-B.2c later transition does not mutate persisted payload");
      ok(afterIntent.state.fingerprint === pending.fingerprint, "P3-B.2c later transition preserves canonical fingerprint");
      ok(Object.isFrozen(afterIntent.state.normalizedPayload), "P3-B.2c later payload remains frozen");
    }
  }
  ok(JSON.stringify(pending) === pendingSnapshot && pending.normalizedPayload === pendingPayload, "P3-B.2c persisted input snapshot and reference remain unchanged");

  const transientPayload = { ...persistedPayload(), displayName: "Ana Lopez" };
  ok(!isValidState({ ...validState(), normalizedPayload: transientPayload as unknown as OperationState["normalizedPayload"] }), "P3-B.2c transient displayName is rejected from persisted state");
}
