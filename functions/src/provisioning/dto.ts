import type { ProvisioningPhase, ProvisioningStatus } from "./types.ts";

export type SafeStatusDto =
  | Readonly<{ operationId: string; status: "pending"; retryAfterSeconds: number }>
  | Readonly<{ operationId: string; status: "active"; phase: "auth_preflight" | "auth_create" | "profile_commit"; retryAfterSeconds: number }>
  | Readonly<{ operationId: string; status: "completed"; userId: string; idempotent: true }>
  | Readonly<{ operationId: string; status: "failed"; terminalCode: string }>
  | Readonly<{ operationId: string; status: "manual_recovery"; terminalCode: string; recoveryCode: string }>;

const OPERATION_ID = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/;
const ACTIVE_PHASES = new Set<ProvisioningPhase>(["auth_preflight", "auth_create", "profile_commit"]);
const RETRY_AFTER_SECONDS = 1;

function readOwnData(value: unknown, key: string): unknown {
  try {
    if (value === null || typeof value !== "object" || Array.isArray(value) || Object.getPrototypeOf(value) !== Object.prototype) return undefined;
    const descriptor = Object.getOwnPropertyDescriptor(value, key);
    return descriptor !== undefined && "value" in descriptor ? descriptor.value : undefined;
  } catch {
    return undefined;
  }
}

function isCode(value: unknown): value is string {
  return typeof value === "string" && value.length > 0 && value === value.trim();
}

/** Projects only the status-specific public fields from a persisted operation. */
export function projectStatusDto(operation: unknown): SafeStatusDto | null {
  const operationId = readOwnData(operation, "operationId");
  const status = readOwnData(operation, "status");
  const phase = readOwnData(operation, "phase");
  if (typeof operationId !== "string" || !OPERATION_ID.test(operationId) || typeof status !== "string") return null;

  switch (status as ProvisioningStatus) {
    case "pending":
      return phase === "dispatch_pending"
        ? Object.freeze({ operationId, status: "pending", retryAfterSeconds: RETRY_AFTER_SECONDS })
        : null;
    case "active":
      return typeof phase === "string" && ACTIVE_PHASES.has(phase as ProvisioningPhase)
        ? Object.freeze({ operationId, status: "active", phase: phase as "auth_preflight" | "auth_create" | "profile_commit", retryAfterSeconds: RETRY_AFTER_SECONDS })
        : null;
    case "completed": {
      const userId = readOwnData(operation, "intendedUid");
      return phase === "terminal" && typeof userId === "string" && userId.length > 0
        ? Object.freeze({ operationId, status: "completed", userId, idempotent: true })
        : null;
    }
    case "failed": {
      const terminalCode = readOwnData(operation, "terminalCode");
      return phase === "terminal" && isCode(terminalCode)
        ? Object.freeze({ operationId, status: "failed", terminalCode })
        : null;
    }
    case "manual_recovery": {
      const terminalCode = readOwnData(operation, "terminalCode");
      const recoveryCode = readOwnData(operation, "recoveryCode");
      return phase === "terminal" && isCode(terminalCode) && isCode(recoveryCode)
        ? Object.freeze({ operationId, status: "manual_recovery", terminalCode, recoveryCode })
        : null;
    }
    default:
      return null;
  }
}
