# Firestore, supervisor de equipo y seguridad (abril 2026)

Este documento resume el trabajo consolidado sobre **reglas de Firestore**, **panel de supervisor**, **Mi Control Horario**, **alta de empleados** y **tests de reglas**, incluida la revisión adversarial (“Día del Juicio”) y los temas dejados para iteraciones futuras.

## Objetivo

- Corregir errores `permission-denied` en consultas por subcolección (`users/{userId}/daily_records`, `users/{userId}/time_records`) y en el panel de equipo del supervisor.
- Endurecer reglas y cliente frente a escalada de privilegios, campos de auditoría y usuarios inactivos.
- Automatizar verificación con emulador de Firestore y JDK 21+.

## Cambios principales en reglas (`firestore.rules`)

- **Lectura por path**: las reglas de lectura de subcolecciones usan el `userId` del segmento del path (`match /users/{userId}/...`) para que las queries de lista no fallen por falta de `resource.data.userId` en todas las evaluaciones.
- **Usuarios inactivos**: el acceso operativo y el rol privilegiado exigen `isActive == true` donde aplica; el supervisor solo accede a empleados del equipo que estén **activos** (`isSupervisorOfEmployee` + documento del empleado).
- **`time_records` — create**: se exige coherencia de propiedad (`createdBy` alineado con el autor), y se rechazan campos de auditoría/bloqueo en la creación.
- **`time_records` — update**: ramas explícitas para **bloqueo/desbloqueo** solo administrador, coherentes con `TimeRecordsService`.
- **`team_month_closures`**: identidad del cierre y campos críticos acotados en creación; **actualizaciones posteriores denegadas** (documento inmutable tras crear).
- **Creación de `/users/{uid}`**: restricciones para evitar escalada vía `role` / `isSupervisor` en auto-registro o escrituras no autorizadas (según evolución del archivo).

## Cambios en la app (Flutter)

- **Equipo**: `supervisedTeamMembersProvider` filtra `isActive == true`; resumen mensual del equipo optimizado (p. ej. `collectionGroup('time_records')` con lotes en lugar de N+1 donde corresponda).
- **Cierre mensual**: `closeMonth()` restringido a **supervisor** (`isSupervisor`), alineado con las reglas que autorizan el cierre al supervisor dueño (no solo “puede supervisar” vía admin).
- **Acciones admin** en fichajes: `validateRecord` / `blockRecord` / `unblockRecord` comprueban también `user.isActive` para administradores.
- **Auth**: si el documento de usuario en Firestore tiene `isActive: false`, la sesión se invalida en cliente.
- **Admin — alta empleado**: creación con app/auth secundaria para no cerrar sesión del admin; persistencia correcta de `isActive` desde el formulario.
- **Admin — edición**: campos opcionales borrados en UI envían `FieldValue.delete()` para no dejar datos obsoletos en Firestore.

## Tests

- **`test/firestore/firestore_rules.test.js`**: suite con emulador (`npm run test:firestore-rules`). Cubre lecturas de subcolección, supervisor, admin, cierres mensuales, bloqueo/desbloqueo, inmutabilidad de cierres, etc.
- **Tests Dart**: providers y pantalla de equipo (`flutter test`), según archivos en `test/features/` y `test/core/`.

## Entorno local (Firestore emulator)

- **Java 21+** recomendado (Firebase CLI dejará de soportar versiones antiguas). En Windows, asegurar que `java` en PATH apunta al JDK correcto (p. ej. Eclipse Temurin 21) y, si hace falta, fijar `JAVA_HOME` antes de ejecutar los tests de reglas.

## Despliegue

- Reglas: `firebase deploy --only firestore:rules` (tras revisión local con tests).

## Revisión adversarial (Día del Juicio) — estado

Tras varias rondas de fixes y re-juicio, el veredicto quedó en **ESCALATED** por acumulación de advertencias de severidad “real” (p. ej. timestamps de auditoría generados en cliente, cobertura de tests para RRHH/collectionGroup, posible asimetría `isActive` en modelo vs reglas, endurecimiento adicional de auto-registro). **No bloquean el merge documentado aquí**, pero se listan como **deuda técnica / seguridad** para el siguiente ciclo.

## Referencias SDD

- [SDD_SUPERVISOR_EQUIPO_SPEC.md](SDD_SUPERVISOR_EQUIPO_SPEC.md)
- [SDD_SUPERVISOR_EQUIPO_TASKS.md](SDD_SUPERVISOR_EQUIPO_TASKS.md)
- [SDD_SUPERVISOR_EQUIPO_VERIFY_REPORT.md](SDD_SUPERVISOR_EQUIPO_VERIFY_REPORT.md)
