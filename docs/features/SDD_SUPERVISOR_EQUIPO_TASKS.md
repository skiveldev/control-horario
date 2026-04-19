# Tasks: Supervisor Equipo + Validacion + Cierre Mensual

## Phase 1 - Foundation (done)

- [x] 1.1 Extender `lib/features/auth/models/user_model.dart` con `isSupervisor`, `supervisorId` y helper `canSuperviseTeam`.
- [x] 1.2 Persistir `isSupervisor`/`supervisorId` en `lib/core/services/firebase_service.dart` y `lib/features/admin/providers/user_management_provider.dart`.
- [x] 1.3 Mapear opcion `supervisor` del alta en `lib/features/admin/presentation/widgets/new_employee_drawer.dart`.
- [x] 1.4 Mantener compatibilidad backward-compatible para usuarios sin campos nuevos.

## Phase 2 - Navigation + Team screen (done)

- [x] 2.1 Registrar `/team` en `lib/core/router/app_router.dart`.
- [x] 2.2 Mostrar `Equipo` solo para supervisores en `lib/shared/widgets/navigation/navigation_items.dart`, `mobile_drawer.dart` y `desktop_sidebar.dart`.
- [x] 2.3 Crear `lib/features/dashboard/presentation/screens/team_screen.dart` con estado vacío, selector de mes y listado.
- [x] 2.4 Crear `lib/features/dashboard/providers/team_provider.dart` para miembros por `supervisorId` y resumen mensual básico.

## Phase 3 - Remaining implementation

- [x] 3.1 Añadir selector de supervisor en `lib/features/admin/presentation/widgets/new_employee_drawer.dart`.
- [x] 3.2 Añadir edición de `supervisorId` en `lib/features/admin/presentation/widgets/employee_info_editor_modal.dart`.
- [x] 3.3 Crear provider reutilizable de supervisores (`users` con `isSupervisor=true`) en `lib/features/admin/providers/` o `lib/features/auth/providers/`.
- [x] 3.4 Reemplazar lecturas por miembro en `lib/features/dashboard/providers/team_provider.dart` por consulta/agregación más eficiente.
- [x] 3.5 Agregar resumen agregado del equipo en `lib/features/dashboard/presentation/screens/team_screen.dart` (totales del mes, pendientes, validados).

## Phase 4 - Supervisor validation UX

- [x] 4.1 Añadir acción `Validar` por miembro/registro en `lib/features/dashboard/presentation/screens/team_screen.dart` o widget extraído.
- [x] 4.2 Mostrar feedback claro de éxito/error de validación en `TeamScreen` con mensajes específicos de permisos.
- [x] 4.3 Mostrar desglose de pendientes por empleado antes de `Cerrar mes` en `TeamScreen`.
- [x] 4.4 Refactorizar componentes de `TeamScreen` a widgets pequeños en `lib/features/dashboard/presentation/widgets/` si supera tamaño razonable.

## Phase 5 - Security rules

- [x] 5.1 Actualizar reglas Firestore para permitir validación solo a admin o supervisor del empleado.
- [x] 5.2 Actualizar reglas Firestore para permitir lectura de equipo solo al supervisor dueño del alcance.
- [x] 5.3 Actualizar reglas Firestore para `team_month_closures` con creación/lectura restringida por `supervisorId`.

## Phase 6 - Tests and verification

- [x] 6.1 Crear tests/provider tests para `TimeRecordsNotifier.validateRecord` cubriendo admin, supervisor válido y supervisor fuera de equipo.
- [x] 6.2 Crear test/widget test para navegación: supervisor ve `Equipo`, empleado no supervisor no lo ve.
- [x] 6.3 Crear tests del cierre mensual: éxito, bloqueo por pendientes y doble cierre.
- [x] 6.4 Ejecutar `flutter analyze` y corregir el issue global restante en `lib/shared/utils/password_utils.dart`.
- [x] 6.5 Ejecutar `flutter test` y volver a emitir `docs/features/SDD_SUPERVISOR_EQUIPO_VERIFY_REPORT.md`.

## Deliverables

- [x] 7.1 Verify report en PASS o PASS WITH WARNINGS.
- [ ] 7.2 Aprobación final para archive (pendiente decisión de producto; documentación de cierre en `FIRESTORE_SUPERVISOR_SECURITY_2026-04.md` y `CHANGELOG.md` [1.4.0]).
