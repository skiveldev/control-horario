# Proposal: Supervisor en Panel Empleado (Equipo + Validacion Mensual)

## Intent

Hoy existe la opcion visual "Supervisor" al crear empleados, pero no existe un rol funcional ni capacidades reales de supervision de equipo.
Este cambio implementa el flujo para que un supervisor (que tambien es empleado) pueda revisar fichajes de su equipo desde el mismo panel de empleado, validar registros y cerrar el mes del equipo.

## Problem

- El rol `supervisor` no existe en `UserRole`; actualmente se guarda como `employee`.
- No hay relacion explicita entre supervisor y miembros de equipo.
- No existe vista "Equipo" en la navegacion del panel empleado.
- La validacion de fichajes esta restringida a admin en `TimeRecordsNotifier`.
- No existe cierre mensual por equipo.

## Goals

- Mantener un panel unico para empleado/supervisor.
- Habilitar una seccion `Equipo` visible solo para supervisores.
- Permitir al supervisor revisar fichajes del mes de su equipo.
- Permitir validacion de registros del equipo.
- Permitir cierre mensual por equipo cuando no queden pendientes.

## Non-Goals

- No reemplazar permisos de admin/RRHH.
- No redisenar completo del dashboard.
- No automatizar cierres con Cloud Functions en esta iteracion.
- No introducir jerarquias complejas de multiples niveles de supervisores.

## Proposed Approach

1. **Permiso compuesto sobre empleado**
   - Mantener `UserRole.employee` y agregar bandera/capacidad de supervision:
   - `isSupervisor: bool` (en `users`).
2. **Relacion de equipo**
   - Cada empleado tendra `supervisorId` (nullable) para asociacion simple 1 supervisor -> N empleados.
3. **Nueva vista Equipo**
   - Nueva ruta de empleado: `/team`.
   - Nuevo item de drawer/sidebar: `Equipo`, visible solo si `currentUser.isSupervisor == true`.
4. **Validacion por alcance**
   - Extender `validateRecord()` para permitir:
     - admin: cualquier empleado.
     - supervisor: solo empleados con `supervisorId == currentUser.userId`.
5. **Cierre mensual**
   - Coleccion propuesta: `team_month_closures/{supervisorId_YYYY_MM}`.
   - Estado minimo: `pending | closed`.
   - Cierre permitido solo si todos los registros del mes del equipo estan validados.

## Data Model Changes (High Level)

- `users`:
  - `isSupervisor: bool` (default `false`)
  - `supervisorId: String?` (solo para miembros de equipo)
- `team_month_closures`:
  - `id`: `${supervisorId}_${yyyyMM}`
  - `supervisorId`
  - `month` (ej. `2026-04`)
  - `status`
  - `closedAt`
  - `closedBy`
  - `teamSnapshot` (cantidad de miembros y resumen, opcional para auditoria)

## Impacted Areas

- `lib/features/auth/models/user_model.dart`
- `lib/features/admin/presentation/widgets/new_employee_drawer.dart`
- `lib/features/admin/providers/user_management_provider.dart`
- `lib/shared/widgets/navigation/navigation_items.dart`
- `lib/core/router/app_router.dart`
- `lib/features/dashboard/providers/time_records_provider.dart`
- `lib/features/dashboard/services/time_records_service.dart`
- Nuevo feature de equipo en `lib/features/dashboard/` (presentacion + providers + servicios).

## Risks and Mitigations

- **Riesgo: escalada de permisos accidental**  
  Mitigacion: checks de permiso centralizados en provider/servicio y reglas Firestore.

- **Riesgo: cerrar mes con datos incompletos**  
  Mitigacion: precondicion estricta de "sin pendientes" y confirmacion explicita.

- **Riesgo: inconsistencia de datos historicos sin `isSupervisor`**  
  Mitigacion: defaults seguros (`false`) y migracion progresiva en lectura.

## Rollout Plan

1. Modelos y permisos base.
2. Navegacion y pantalla `Equipo` con lectura.
3. Validacion por supervisor.
4. Cierre mensual manual.
5. Ajustes de reglas Firestore y pruebas de permisos.

## Success Criteria

- Un supervisor accede a `Equipo` desde su panel empleado.
- Ve solo miembros de su equipo.
- Puede validar fichajes de su equipo.
- Puede cerrar el mes solo cuando no hay pendientes.
- El cierre queda persistido y trazable.
