# Changelog - Control Horario

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [1.4.0] - 2026-04-19

### Añadido
- Módulo **Equipo** para supervisores: pantalla `/team`, resumen mensual, validación de fichajes del equipo, cierre mensual (`team_month_closures`) y navegación condicionada.
- Suite **Node** para reglas Firestore (`npm run test:firestore-rules`) con emulador; dependencias en `package.json` / `package-lock.json`.
- Documentación en `docs/features/FIRESTORE_SUPERVISOR_SECURITY_2026-04.md` y enlaces en `docs/README.md`.

### Corregido / Seguridad
- Reglas Firestore: lecturas por subcolección alineadas con el `userId` del path; endurecimiento de `time_records` (create/update), cierres mensuales inmutables tras creación, bloqueo/desbloqueo solo admin donde corresponde, y coherencia con usuarios inactivos y supervisor de equipo.
- Alta de empleados desde admin sin cerrar sesión del administrador; persistencia de `isActive` y borrado de campos opcionales en edición.

### Cambiado
- `team_provider`: consultas de equipo y agregados mensuales más eficientes; miembros del equipo filtrados por `isActive`.
- Proveedores de fichajes y cierre mensual alineados con reglas (p. ej. cierre solo supervisor, comprobaciones de admin activo).

---

## [1.3.0] - 2026-02-18

### ✨ Modificado
- Botón "Nueva Plantilla" movido al header superior (reemplaza FloatingActionButton) — responsive: texto+icono en desktop, solo icono en mobile

---

## [1.2.0] - 2026-02-16

### ✨ Modificado
- Rediseño pantalla de Login: mejoras de UX/UI y corrección de tipografía

---

## [1.1.1] - 2026-02-12

### ✨ Añadido
- Sistema de horarios flexible con plantillas asignables a empleados

---

## [1.1.0] - 2026-01-27

### ✨ Añadido / Corregido
- Perfil del empleado conectado con Firebase (eliminados datos mock)
- Corrección 7 campos del drawer "Nuevo Trabajador" que no se guardaban en Firestore
- Actualizado `UserModel` con campos `nombre`, `apellido1`, `apellido2`

---

## [1.0.0] - 2025-12-14

### 🎉 Añadido - Funcionalidad "Mi Control Horario"

#### Modelos y Lógica de Negocio
- Modelo `TimeRecordModel` con Freezed para registros de tiempo
- Enum `RecordCategory` (work, breakTime)
- Enum `ValidationStatus` (editable, validated, blocked, modifiedAfterValidation)
- Servicio `TimeRecordsService` con operaciones CRUD completas
- Providers de Riverpod para gestión de estado reactivo
- Sistema de validación y bloqueo de registros

#### Interfaz de Usuario
- Pantalla principal `MyTimeControlScreen` con navegación mensual
- Widget `MonthNavigationHeader` con resumen de horas
- Widget `DayRecordCard` expandible/colapsable con tabla de registros
- Modal `AddEditRecordModal` para añadir/editar registros
- Modal `BlockedRecordModal` para información de registros bloqueados
- Widget `FutureMonthEmptyState` para meses sin activar
- Widget `CategoryTabSelector` para selección de categorías
- Widget `TimePickerField` reutilizable para selección de hora

#### Navegación
- Ruta `/my-time-control` configurada en `app_router.dart`
- Integración con menú lateral (hamburger menu)
- Acceso desde "Mi Control Horario" bajo sección "Calendario"

#### Firebase
- Reglas de seguridad para colección `time_records`
- Índice compuesto: `date` + `startTime` (Ascendente)
- Estructura de subcollection: `users/{userId}/time_records/{recordId}`

#### Localización
- Configuración de locale español (`es_ES`)
- Inicialización de `intl` con datos de localización
- Configuración de `flutter_localizations`
- Formateo de fechas en español

#### Documentación
- `docs/MI_CONTROL_HORARIO.md` - Guía de usuario y arquitectura
- `docs/IMPLEMENTACION_MI_CONTROL_HORARIO.md` - Resumen técnico
- `docs/DEPLOYMENT_MI_CONTROL_HORARIO.md` - Checklist de deployment
- `docs/REGISTRO_AVANCE.md` - Registro detallado de avance
- `firestore_indexes.md` - Documentación de índices de Firestore

### 🔧 Modificado

#### Configuración
- Actualizado `pubspec.yaml` con `intl: ^0.20.2`
- Añadido `flutter_localizations` a dependencias
- Configurado `main.dart` con inicialización de locales
- Configurado `app.dart` con soporte de localización

#### Navegación
- Actualizado `app_router.dart` con nueva ruta
- Modificado `navigation_items.dart` con ruta correcta

#### Firebase
- Actualizado `firestore.rules` con reglas para `time_records`

### 🐛 Corregido

1. **Error de Sintaxis PowerShell**
   - Cambiado `&&` a `;` en comandos de shell

2. **Error de Campo en UserModel**
   - Corregido acceso a `userId` en lugar de `uid`

3. **Error de Tipo de Retorno en Riverpod**
   - Actualizado tipo de retorno de `TimeRecordsNotifier.build()` a `FutureOr<String?>`

4. **Deprecación de Flutter**
   - Cambiado `DropdownButtonFormField.value` a `initialValue`

5. **LocaleDataException**
   - Añadido `initializeDateFormatting('es_ES', null)` en `main()`
   - Configurado `flutter_localizations` en MaterialApp

6. **Conflicto de Versión**
   - Actualizado `intl` de `^0.19.0` a `^0.20.2`

7. **Firestore Permission Denied**
   - Desplegadas reglas de Firestore con `firebase deploy --only firestore:rules`

8. **Firestore Index Missing**
   - Creado índice compuesto de tipo "Colección" para `date` + `startTime`

9. **Botones de Acción No Funcionaban**
   - Conectados callbacks en versión desktop de `DayRecordCard`

### 🎨 Mejoras de UI/UX

- Diseño responsive (Mobile, Tablet, Desktop)
- Animaciones suaves en expansión/colapso de días
- Badges visuales para estados de validación
- Indicador "HOY" para el día actual
- Colores diferenciados por categoría
- Indicadores visuales de diferencia de horas
- Feedback inmediato con SnackBars
- Estados de carga, error y vacío bien definidos

---

## Información de Versiones

### [1.0.0] - 2025-12-14
- **Estado:** ✅ Implementación Base Completada
- **Funcionalidades:** CRUD completo de registros, navegación mensual, sistema de validación
- **Plataforma:** Flutter Web
- **Backend:** Firebase (Firestore + Authentication)
- **Estado Management:** Riverpod 2.x

---

## Próximas Versiones (Planeadas)

### [1.1.0] - Por Definir
- [ ] Panel de administración para validar/bloquear registros
- [ ] Historial de cambios en registros
- [ ] Notificaciones push para validaciones

### [1.2.0] - Por Definir
- [ ] Exportación de registros a PDF
- [ ] Gráficos y reportes visuales
- [ ] Comparativas mensuales

### [2.0.0] - Por Definir
- [ ] Sistema de festivos y ausencias
- [ ] Sincronización offline
- [ ] Tests automatizados completos

---

**Mantenido por:** Control Horario Team  
**Última actualización:** 14 de Diciembre de 2025

