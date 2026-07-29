/**
 * P1a1 — Normalization + Fingerprint vectors (ordinal 25 remediation).
 * Groups 2+3: canonical fingerprint, UUID v4, calendar dates, weeklyHours range.
 */
import { normalizePayload, canonicalPayloadKeys, fingerprintPayload, deriveDisplayName, type NormalizedPayload, PROVISIONING_ROLES } from "../../src/provisioning/normalize.ts";
import { strict as assert } from "node:assert";
import { test } from "node:test";

const OP = (suffix: string) => `550e8400-e29b-41d4-a716-44665544${suffix}`;
const MIN = { email: "test@test.com", nombre: "A", apellido1: "B", role: "employee" } as const;
const req = (overrides: Record<string, unknown>) => normalizePayload({ operationId: OP("0000"), ...MIN, ...overrides });

// --- Key order ---
test("canonicalPayloadKeys", () => {
  assert.deepStrictEqual(canonicalPayloadKeys, ["email","nombre","apellido1","apellido2","employeeId","weeklyHours","dni","telefono","cargo","departamento","empresa","scheduleId","calendarId","fechaInicio","fechaFin","role","isSupervisor","supervisorId","isActive"]);
});

// --- Happy path + trimming + NFC + lower-case ---
test("normalizePayload: minimal succeeds with defaults", () => {
  const r = normalizePayload({ operationId: OP("0001"), email: "  User@Example.COM  ", nombre: " Juan ", apellido1: " Pérez ", role: "employee" });
  assert.strictEqual(r.email, "user@example.com");
  assert.strictEqual(r.nombre, "Juan");
  assert.strictEqual(r.apellido1, "Pérez");
  assert.strictEqual(r.role, "employee");
  assert.strictEqual(r.weeklyHours, 40);
  assert.strictEqual(r.employeeId, "");
  assert.strictEqual(r.isSupervisor, false);
  assert.strictEqual(r.supervisorId, null);
  assert.strictEqual(r.isActive, true);
});

test("email lower-cased", () => { assert.strictEqual(req({ email: "UPPER@DOMAIN.COM" }).email, "upper@domain.com"); });

test("NFC normalized", () => {
  const nfd = "Juani\u0303o";
  const r = req({ nombre: nfd });
  assert.strictEqual(r.nombre, nfd.normalize("NFC"));
  assert.ok(r.nombre !== nfd);
});

test("whitespace trimmed", () => {
  const r = req({ email: " a@b.com ", nombre: " N ", apellido1: " P ", cargo: " Dev ", role: " employee " });
  assert.strictEqual(r.email, "a@b.com");
  assert.strictEqual(r.nombre, "N");
  assert.strictEqual(r.cargo, "Dev");
  assert.strictEqual(r.role, "employee");
});

// --- Table-driven rejection cases ---
test("blank optionals → null", () => {
  const r = req({ apellido2: "   ", dni: "", telefono: "\t", cargo: null });
  assert.strictEqual(r.apellido2, null);
  assert.strictEqual(r.dni, null);
  assert.strictEqual(r.telefono, null);
  assert.strictEqual(r.cargo, null);
});

test("valid dates pass", () => {
  const r = req({ fechaInicio: "2025-01-15", fechaFin: "2025-12-31" });
  assert.strictEqual(r.fechaInicio, "2025-01-15");
  assert.strictEqual(r.fechaFin, "2025-12-31");
});

test("explicit overrides over defaults", () => {
  const r = req({ weeklyHours: 30, employeeId: "E1", isSupervisor: true, supervisorId: "sv", isActive: false });
  assert.strictEqual(r.weeklyHours, 30);
  assert.strictEqual(r.employeeId, "E1");
  assert.strictEqual(r.isSupervisor, true);
  assert.strictEqual(r.supervisorId, "sv");
  assert.strictEqual(r.isActive, false);
});

test("roles: employee|rrhh accepted, others rejected", () => {
  assert.strictEqual(req({ role: "employee" }).role, "employee");
  assert.strictEqual(req({ role: "rrhh" }).role, "rrhh");
  assert.throws(() => req({ role: "admin" }));
  assert.throws(() => req({ role: "superadmin" }));
  assert.deepStrictEqual([...PROVISIONING_ROLES].sort(), ["employee", "rrhh"]);
});

test("displayName", () => {
  assert.strictEqual(deriveDisplayName("Juan", "Pérez"), "Juan Pérez");
  assert.strictEqual(deriveDisplayName("Juan", "Pérez", "López"), "Juan Pérez López");
  assert.strictEqual(deriveDisplayName("Ana", "García", null), "Ana García");
  const r = req({ nombre: "Juan", apellido1: "Pérez", apellido2: "López" });
  assert.strictEqual(r.displayName, "Juan Pérez López");
});

// --- Table-driven rejection table ---
test("reject: various invalid inputs", () => {
  const rejects: Array<[string, unknown]> = [
    ["non-UTC date", { fechaInicio: "15/01/2025" }],
    ["NaN", { weeklyHours: NaN }],
    ["Infinity", { weeklyHours: Infinity }],
    ["nested object", { cargo: { x: 1 } }],
    ["array", { departamento: ["X"] }],
    ["unknown key", { unknownField: "x" }],
    ["non-boolean isSupervisor", { isSupervisor: "y" }],
    ["missing email", { email: undefined }],
    ["missing nombre", { nombre: undefined }],
    ["missing apellido1", { apellido1: undefined }],
    ["missing role", { role: undefined }],
    ["blank email", { email: "" }],
    ["blank nombre", { nombre: "" }],
    ["blank apellido1", { apellido1: "" }],
    // Group 3: UUID v4
    ["upper-case UUID", { operationId: "A1B2C3D4-E5F6-4789-A012-3456789ABCDE" }],
    ["non-UUID operationId", { operationId: "not-a-uuid" }],
    ["UUID v1", { operationId: "c56a4180-65aa-11ec-90d6-0242ac120003" }],
    // Group 3: weeklyHours range
    ["weeklyHours 0", { weeklyHours: 0 }],
    ["weeklyHours 169", { weeklyHours: 169 }],
    ["weeklyHours -1", { weeklyHours: -1 }],
    // Group 3: calendar date validation
    ["Feb 30", { fechaInicio: "2025-02-30" }],
    ["Apr 31", { fechaFin: "2025-04-31" }],
    ["month 13", { fechaInicio: "2025-13-01" }],
    // Group 3: non-plain root
    ["root array", ["not","object"]],
    ["root string", "string"],
    ["root null", null],
  ];
  for (const [label, overrides] of rejects) {
    assert.throws(
      () => {
        if (Array.isArray(overrides) || typeof overrides !== "object" || overrides === null) {
          (normalizePayload as (x: unknown) => unknown)(overrides);
        } else {
          req({ ...(overrides as Record<string, unknown>), operationId: (overrides as Record<string, unknown>).operationId as string ?? OP("0099") });
        }
      },
      new RegExp(""),
      `should reject: ${label}`,
    );
  }
});

test("weeklyHours 168 accepted", () => { assert.strictEqual(req({ weeklyHours: 168 }).weeklyHours, 168); });
test("leap year Feb 29 accepted", () => { assert.strictEqual(req({ fechaInicio: "2024-02-29" }).fechaInicio, "2024-02-29"); });
test("date trimmed", () => { assert.strictEqual(req({ fechaInicio: "  2025-06-15  " }).fechaInicio, "2025-06-15"); });

test("isSupervisor boolean", () => {
  assert.strictEqual(req({ isSupervisor: false }).isSupervisor, false);
  assert.strictEqual(req({ isSupervisor: true }).isSupervisor, true);
  assert.throws(() => req({ isSupervisor: "truthy" }));
});

test("supervisorId defaults null", () => { assert.strictEqual(req({}).supervisorId, null); });

// --- Defect 3: normalizePayload rejects class instances (non-plain prototype) ---
test("normalizePayload: rejects class instance root", () => {
  class FakePayload {
    operationId = OP("0060");
    email = "x@t.com";
    nombre = "A";
    apellido1 = "B";
    role = "employee";
  }
  assert.throws(
    () => normalizePayload(new FakePayload() as unknown as Record<string, unknown>),
    /plain/,
    "normalizePayload must reject class instance with non-Object.prototype prototype",
  );
});

// --- Fingerprint ---
test("fingerprint: deterministic same payload", () => {
  const p = { operationId: OP("0024"), email: "fp@test.com", nombre: "F", apellido1: "P", role: "employee" };
  assert.strictEqual(fingerprintPayload(p), fingerprintPayload(p));
  assert.strictEqual(fingerprintPayload(p).length, 64);
});

test("fingerprint: different email → different hash", () => {
  assert.notStrictEqual(
    fingerprintPayload({ ...MIN, operationId: OP("0025"), email: "a@t.com" }),
    fingerprintPayload({ ...MIN, operationId: OP("0026"), email: "b@t.com" }),
  );
});

test("fingerprint: operationId excluded", () => {
  const b = { email: "op@t.com", nombre: "O", apellido1: "E", role: "employee" };
  assert.strictEqual(
    fingerprintPayload({ ...b, operationId: "aaaaaaaa-0000-4000-a000-eeeeeeeeeee1" }),
    fingerprintPayload({ ...b, operationId: "aaaaaaaa-0000-4000-a000-eeeeeeeeeee2" }),
  );
});

test("fingerprint: key-order independent", () => {
  const fp1 = fingerprintPayload({ operationId: OP("0027"), email: "o@t.com", nombre: "O", apellido1: "T", role: "employee" });
  const fp2 = fingerprintPayload({ apellido1: "T", role: "employee", email: "o@t.com", nombre: "O", operationId: OP("0027") } as Record<string, unknown>);
  assert.strictEqual(fp1, fp2);
});

test("fingerprint: canonicalization (whitespace/case)", () => {
  assert.strictEqual(
    fingerprintPayload({ operationId: OP("0028"), email: "canon@test.com", nombre: "  Canon  ", apellido1: "Test", role: "employee" }),
    fingerprintPayload({ operationId: OP("0028"), email: "CANON@TEST.COM", nombre: "Canon", apellido1: "Test", role: "employee" }),
  );
});

// --- Group 2: fingerprint rejection cases ---
test("fingerprint: rejects invalid inputs", () => {
  const rejects: Array<[string, Record<string, unknown>]> = [
    ["unknown key", { unknownField: "x" }],
    ["non-boolean isSupervisor", { isSupervisor: "truthy" }],
    ["non-boolean isActive", { isActive: 1 }],
    ["non-finite weeklyHours", { weeklyHours: Infinity }],
    ["NaN weeklyHours", { weeklyHours: NaN }],
  ];
  for (const [label, overrides] of rejects) {
    assert.throws(
      () => fingerprintPayload({ operationId: OP("0040"), email: "fp@t.com", nombre: "A", apellido1: "B", role: "employee", ...overrides }),
      new RegExp(""),
      `fp should reject: ${label}`,
    );
  }
});

// --- Defect 2 RED: fingerprint must reject fully normalized contract violations ---
// These currently pass through fingerprintPayload's weaker validation.
// After fingerprint delegates to normalizePayload they MUST be rejected.
test("fingerprint: rejects invalid role", () => {
  assert.throws(
    () => fingerprintPayload({ operationId: OP("0050"), email: "x@t.com", nombre: "A", apellido1: "B", role: "admin" }),
    /role/,
    "fingerprint must reject invalid role 'admin'",
  );
});

test("fingerprint: rejects impossible date", () => {
  assert.throws(
    () => fingerprintPayload({ operationId: OP("0051"), email: "x@t.com", nombre: "A", apellido1: "B", role: "employee", fechaInicio: "2025-02-30" }),
    /fechaInicio/,
    "fingerprint must reject impossible calendar date Feb 30",
  );
});

test("fingerprint: rejects weeklyHours below 1", () => {
  assert.throws(
    () => fingerprintPayload({ operationId: OP("0052"), email: "x@t.com", nombre: "A", apellido1: "B", role: "employee", weeklyHours: 0 }),
    /weeklyHours/,
    "fingerprint must reject weeklyHours 0",
  );
});

test("fingerprint: rejects weeklyHours above 168", () => {
  assert.throws(
    () => fingerprintPayload({ operationId: OP("0053"), email: "x@t.com", nombre: "A", apellido1: "B", role: "employee", weeklyHours: 169 }),
    /weeklyHours/,
    "fingerprint must reject weeklyHours 169",
  );
});

test("fingerprint: rejects missing email", () => {
  assert.throws(
    () => fingerprintPayload({ operationId: OP("0054"), nombre: "A", apellido1: "B", role: "employee" }),
    /email/,
    "fingerprint must reject missing email",
  );
});

test("fingerprint: rejects missing nombre", () => {
  assert.throws(
    () => fingerprintPayload({ operationId: OP("0055"), email: "x@t.com", apellido1: "B", role: "employee" }),
    /nombre/,
    "fingerprint must reject missing nombre",
  );
});

test("fingerprint: rejects missing apellido1", () => {
  assert.throws(
    () => fingerprintPayload({ operationId: OP("0056"), email: "x@t.com", nombre: "A", role: "employee" }),
    /apellido1/,
    "fingerprint must reject missing apellido1",
  );
});

test("fingerprint: rejects missing role", () => {
  assert.throws(
    () => fingerprintPayload({ operationId: OP("0057"), email: "x@t.com", nombre: "A", apellido1: "B" }),
    /role/,
    "fingerprint must reject missing role",
  );
});

test("fingerprint: rejects non-plain root (array)", () => {
  assert.throws(
    () => (fingerprintPayload as (x: unknown) => string)(["not", "object"]),
    /plain object/,
    "fingerprint must reject array root",
  );
});

test("fingerprint: rejects non-plain root (null)", () => {
  assert.throws(
    () => (fingerprintPayload as (x: unknown) => string)(null),
    /plain object/,
    "fingerprint must reject null root",
  );
});

// --- Defect 3 RED: fingerprint rejects class instance (non-plain prototype) ---
test("fingerprint: rejects class instance root", () => {
  class FakePayload { email = "x@t.com"; nombre = "A"; apellido1 = "B"; role = "employee"; operationId = OP("0058"); }
  assert.throws(
    () => fingerprintPayload(new FakePayload() as unknown as Record<string, unknown>),
    /plain/,
    "fingerprint must reject class instance root",
  );
});

// --- Group 2: omitted vs explicit defaults identical ---
test("fingerprint: omitted defaults ≡ explicit defaults", () => {
  const b = { email: "d@t.com", nombre: "D", apellido1: "T", role: "employee" };
  const omitted = fingerprintPayload({ ...b, operationId: OP("0039") });
  const explicit = fingerprintPayload({ ...b, operationId: OP("0039"), weeklyHours: 40, employeeId: "", isSupervisor: false, supervisorId: null, isActive: true });
  assert.strictEqual(omitted, explicit);
  assert.strictEqual(omitted.length, 64);
});

// --- Group 2: canonical literal fingerprint ---
test("fingerprint: canonical minimal literal", () => {
  assert.strictEqual(
    fingerprintPayload({ operationId: "00000000-0000-4000-a000-000000000001", email: "juan.perez@example.com", nombre: "Juan", apellido1: "Pérez", role: "employee" }),
    "5adb42d0a7b58690da0fd3b99151a2912d1a47b76248c8d9caa83fabc1365b52",
  );
});
