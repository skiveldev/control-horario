import type { NormalizedPayload } from "./normalize.ts";

const NORMALIZED_PROFILE_FIELDS = [
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
  "displayName",
] as const satisfies readonly (keyof NormalizedPayload)[];

export interface ProfileExpectation {
  readonly intendedUid: string;
  readonly operationId: string;
  readonly fingerprint: string;
  readonly schemaVersion: number;
  readonly normalizedPayload: Readonly<NormalizedPayload>;
}

export interface ProfileReader {
  readProfile(userId: string): Promise<unknown | null>;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

/**
 * Decides whether an existing profile belongs to one exact provisioning
 * operation. This domain predicate deliberately has no Firebase dependency.
 */
export function matchesProfileProvenance(
  profile: unknown,
  expected: ProfileExpectation,
): boolean {
  if (!isRecord(profile)) return false;
  if (profile.userId !== expected.intendedUid
    || profile.email !== expected.normalizedPayload.email
    || profile.provisioningOperationId !== expected.operationId
    || profile.provisioningFingerprint !== expected.fingerprint
    || profile.provisioningSchemaVersion !== expected.schemaVersion
    || profile.provisionedBy !== "trusted-backend"
    || profile.provisionedAt === null
    || profile.provisionedAt === undefined) {
    return false;
  }

  return NORMALIZED_PROFILE_FIELDS.every(
    (field) => profile[field] === expected.normalizedPayload[field],
  );
}

/** Reads through an injected boundary and delegates all matching to pure logic. */
export async function storedProfileMatchesOperation(
  reader: ProfileReader,
  expected: ProfileExpectation,
): Promise<boolean> {
  const profile = await reader.readProfile(expected.intendedUid);
  return matchesProfileProvenance(profile, expected);
}
