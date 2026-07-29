/**
 * P1a1 — Canonical payload normalization and fingerprint derivation.
 *
 * Normalization: NFC, trimmed strings, lower-cased email, blank → null,
 * date format + calendar validation (UTC YYYY-MM-DD), defaults, role
 * enforcement, unknown-key rejection, UUID v4 operationId, weeklyHours
 * range 1–168, non-plain root rejection.
 *
 * Fingerprint: fixed-key-order canonical JSON → lower-case SHA-256 hex
 * including ALL 19 canonical keys with defaults applied. operationId
 * excluded. Omitted defaults and explicit defaults hash identically.
 * Unknown keys and invalid types are rejected (not silently coerced).
 */

import { createHash } from "node:crypto";

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/** Canonical payload keys in the exact design-defined order. */
export const canonicalPayloadKeys: readonly string[] = Object.freeze([
  "email",
  "nombre",
  "apellido1",
  "apellido2",
  "employeeId",
  "weeklyHours",
  "dni",
  "telefono",
  "cargo",
  "departamento",
  "empresa",
  "scheduleId",
  "calendarId",
  "fechaInicio",
  "fechaFin",
  "role",
  "isSupervisor",
  "supervisorId",
  "isActive",
]) as readonly string[];

/** Allowed provisioning roles. */
export const PROVISIONING_ROLES: ReadonlySet<string> = new Set(["employee", "rrhh"]);

/** Required fields that MUST be present in the input. */
const REQUIRED_FIELDS = new Set(["operationId", "email", "nombre", "apellido1", "role"]);

/** Fields whose canonical values are strings. */
const STRING_FIELDS = new Set([
  "email", "nombre", "apellido1", "apellido2", "employeeId",
  "dni", "telefono", "cargo", "departamento", "empresa",
  "scheduleId", "calendarId", "fechaInicio", "fechaFin",
  "role", "supervisorId",
]);

/** Fields that should be boolean. */
const BOOLEAN_FIELDS = new Set(["isSupervisor", "isActive"]);

/** Fields that should be numbers. */
const NUMBER_FIELDS = new Set(["weeklyHours"]);

/** All known field names (canonical keys + operationId). */
const ALL_KNOWN_FIELDS = new Set([
  "operationId", ...canonicalPayloadKeys,
]);

export const DEFAULT_WEEKLY_HOURS = 40;
export const DEFAULT_IS_ACTIVE = true;
export const WEEKLY_HOURS_MIN = 1;
export const WEEKLY_HOURS_MAX = 168;

/** Strict YYYY-MM-DD format regex. */
const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

/** Lower-case UUID v4 regex (8-4-4-4-12 with version 4 nibble). */
const UUID_V4_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;

/**
 * Validates that a YYYY-MM-DD string represents a real calendar date.
 * Month must be 01-12; day must be valid for that month (including leap years).
 */
function isValidCalendarDate(dateStr: string): boolean {
  if (!DATE_RE.test(dateStr)) return false;
  const parts = dateStr.split("-");
  const y = Number(parts[0]);
  const m = Number(parts[1]);
  const d = Number(parts[2]);
  if (m < 1 || m > 12) return false;
  // Days per month (Feb handled separately for leap year)
  const dim = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  const maxDay = m === 2
    ? (y % 4 === 0 && (y % 100 !== 0 || y % 400 === 0) ? 29 : 28)
    : dim[m];
  return d >= 1 && d <= maxDay;
}

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

/**
 * The raw input payload before normalization.
 * Values are unknown because the caller may send anything.
 */
export type CanonicalPayload = Record<string, unknown>;

/**
 * The normalized payload with all fields in canonical form.
 */
export interface NormalizedPayload {
  email: string;
  nombre: string;
  apellido1: string;
  apellido2: string | null;
  employeeId: string;
  weeklyHours: number;
  dni: string | null;
  telefono: string | null;
  cargo: string | null;
  departamento: string | null;
  empresa: string | null;
  scheduleId: string | null;
  calendarId: string | null;
  fechaInicio: string | null;
  fechaFin: string | null;
  role: "employee" | "rrhh";
  isSupervisor: boolean;
  supervisorId: string | null;
  isActive: boolean;
  displayName: string;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function normalizeString(value: unknown): string | null {
  if (value === null || value === undefined) return null;
  if (typeof value !== "string") {
    throw new TypeError(`expected string, got ${typeof value}`);
  }
  const trimmed = value.trim();
  if (trimmed.length === 0) return null;
  return trimmed.normalize("NFC");
}

function isValidDate(value: unknown): value is string {
  if (typeof value !== "string") return false;
  return DATE_RE.test(value);
}

function checkPlainValue(value: unknown, field: string): void {
  if (value === null || value === undefined) return;
  const t = typeof value;
  if (t === "object") {
    throw new TypeError(`field "${field}": nested objects or arrays are not allowed`);
  }
}

/** Derives a display name from name components. */
export function deriveDisplayName(
  nombre: string,
  apellido1: string,
  apellido2?: string | null,
): string {
  const parts = [nombre.trim(), apellido1.trim()];
  if (apellido2 && apellido2.trim().length > 0) {
    parts.push(apellido2.trim());
  }
  return parts.map((p) => p.normalize("NFC")).join(" ");
}

// ---------------------------------------------------------------------------
// Main normalization
// ---------------------------------------------------------------------------

/**
 * Normalizes and validates a raw payload into a canonical NormalizedPayload.
 * Throws on any validation failure.
 */
export function normalizePayload(input: Record<string, unknown>): NormalizedPayload {
  // --- 0. Non-plain root -----------------------------------------------------
  if (input === null || typeof input !== "object" || Array.isArray(input)) {
    throw new TypeError("input must be a plain object (record), got " + (input === null ? "null" : Array.isArray(input) ? "array" : typeof input));
  }
  const proto = Object.getPrototypeOf(input);
  if (proto !== Object.prototype && proto !== null) {
    throw new TypeError("input must be a plain object (prototype must be Object.prototype or null)");
  }

  // --- 1. Unknown keys -------------------------------------------------------
  for (const key of Object.keys(input)) {
    if (!ALL_KNOWN_FIELDS.has(key)) {
      throw new TypeError(`unknown field: "${key}"`);
    }
  }

  // --- 2. operationId validation (lower-case UUID v4) ------------------------
  const rawOpId = input["operationId"];
  if (typeof rawOpId !== "string" || !UUID_V4_RE.test(rawOpId)) {
    throw new TypeError("operationId must be a lower-case UUID v4 string");
  }

  // --- 3. Required fields ----------------------------------------------------
  for (const field of REQUIRED_FIELDS) {
    if (!(field in input) || input[field] === undefined) {
      throw new TypeError(`missing required field: "${field}"`);
    }
  }

  // --- 4. Type checks (non-finite numbers, non-plain values) ------------------
  for (const [key, value] of Object.entries(input)) {
    if (value === null || value === undefined) continue;

    // Non-plain values (objects, arrays) rejected
    if (typeof value === "object") {
      throw new TypeError(`field "${key}": nested objects or arrays are not allowed`);
    }

    if (NUMBER_FIELDS.has(key)) {
      if (typeof value !== "number" || !Number.isFinite(value)) {
        throw new TypeError(`field "${key}": must be a finite number`);
      }
    }

    if (BOOLEAN_FIELDS.has(key)) {
      if (typeof value !== "boolean") {
        throw new TypeError(`field "${key}": must be a boolean`);
      }
    }
  }

  // --- 5. String normalization (NFC + trim + blank → null + email lower) -----
  const safeGetString = (key: string): string | null => {
    const raw = input[key];
    return normalizeString(raw);
  };

  const email = safeGetString("email");
  const nombre = safeGetString("nombre");
  const apellido1 = safeGetString("apellido1");

  if (!email) throw new TypeError("email is required and must not be blank");
  if (!nombre) throw new TypeError("nombre is required and must not be blank");
  if (!apellido1) throw new TypeError("apellido1 is required and must not be blank");

  const normalizedEmail = email.toLowerCase();

  // --- 6. Role enforcement ---------------------------------------------------
  const role = safeGetString("role");
  if (!role || !PROVISIONING_ROLES.has(role)) {
    throw new TypeError(
      `role must be one of: ${[...PROVISIONING_ROLES].join(", ")}, got "${role}"`,
    );
  }

  // --- 7. Optional string fields ---------------------------------------------
  const apellido2 = safeGetString("apellido2");
  const employeeId = safeGetString("employeeId") ?? "";
  const dni = safeGetString("dni");
  const telefono = safeGetString("telefono");
  const cargo = safeGetString("cargo");
  const departamento = safeGetString("departamento");
  const empresa = safeGetString("empresa");
  const scheduleId = safeGetString("scheduleId");
  const calendarId = safeGetString("calendarId");

  // --- 8. Date fields (trimmed, then calendar-validated) ---------------------
  const fechaInicioRaw = input["fechaInicio"];
  const fechaFinRaw = input["fechaFin"];

  let fechaInicio: string | null = null;
  if (fechaInicioRaw !== undefined && fechaInicioRaw !== null) {
    if (typeof fechaInicioRaw !== "string") {
      throw new TypeError("fechaInicio must be a string");
    }
    const trimmed = fechaInicioRaw.trim();
    if (trimmed.length === 0) {
      fechaInicio = null;
    } else if (!isValidCalendarDate(trimmed)) {
      throw new TypeError("fechaInicio must be a valid UTC date in YYYY-MM-DD format");
    } else {
      fechaInicio = trimmed;
    }
  }

  let fechaFin: string | null = null;
  if (fechaFinRaw !== undefined && fechaFinRaw !== null) {
    if (typeof fechaFinRaw !== "string") {
      throw new TypeError("fechaFin must be a string");
    }
    const trimmed = fechaFinRaw.trim();
    if (trimmed.length === 0) {
      fechaFin = null;
    } else if (!isValidCalendarDate(trimmed)) {
      throw new TypeError("fechaFin must be a valid UTC date in YYYY-MM-DD format");
    } else {
      fechaFin = trimmed;
    }
  }

  // --- 9. Numeric fields with defaults + range validation ---------------------
  let weeklyHours: number;
  if (input["weeklyHours"] === undefined || input["weeklyHours"] === null) {
    weeklyHours = DEFAULT_WEEKLY_HOURS;
  } else {
    weeklyHours = input["weeklyHours"] as number;
    if (weeklyHours < WEEKLY_HOURS_MIN || weeklyHours > WEEKLY_HOURS_MAX) {
      throw new TypeError(
        `weeklyHours must be between ${WEEKLY_HOURS_MIN} and ${WEEKLY_HOURS_MAX}, got ${weeklyHours}`,
      );
    }
  }

  // --- 10. Boolean fields with defaults ---------------------------------------
  const isSupervisor = (input["isSupervisor"] as boolean) ?? false;
  const isActive = (input["isActive"] as boolean) ?? DEFAULT_IS_ACTIVE;

  // --- 11. supervisorId -------------------------------------------------------
  const supervisorId = safeGetString("supervisorId");

  // --- 12. displayName derivation ---------------------------------------------
  const displayName = deriveDisplayName(nombre, apellido1, apellido2);

  return {
    email: normalizedEmail,
    nombre,
    apellido1,
    apellido2,
    employeeId,
    weeklyHours,
    dni,
    telefono,
    cargo,
    departamento,
    empresa,
    scheduleId,
    calendarId,
    fechaInicio,
    fechaFin,
    role: role as "employee" | "rrhh",
    isSupervisor,
    supervisorId,
    isActive,
    displayName,
  };
}

// ---------------------------------------------------------------------------
// Fingerprint
// ---------------------------------------------------------------------------

/**
 * Computes a deterministic SHA-256 fingerprint of the canonicalized payload.
 *
 * Delegates to `normalizePayload` for full validation and normalization,
 * then builds the canonical all-19-key (operationId excluded) JSON in
 * fixed key order.  Omitted defaults and explicit defaults hash identically
 * because normalization applies the same defaults.
 *
 * Rejects everything `normalizePayload` rejects: non-plain root (null, array,
 * class instances), invalid UUID v4, missing required fields, invalid role,
 * impossible calendar dates, weeklyHours outside 1–168, unknown keys, nested
 * objects, non-boolean bool fields, and non-finite numbers.
 *
 * Lower-case SHA-256 hex output.
 */
export function fingerprintPayload(input: Record<string, unknown>): string {
  // Full validation + normalization.
  const normalized = normalizePayload(input);

  // Build canonical fingerprint object with all 19 keys in fixed order.
  // operationId is excluded by construction.
  const canonical: Record<string, unknown> = {};
  for (const key of canonicalPayloadKeys) {
    canonical[key] = (normalized as unknown as Record<string, unknown>)[key];
  }

  const json = JSON.stringify(canonical);
  return createHash("sha256").update(json, "utf8").digest("hex");
}
