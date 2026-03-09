# Estado Actual del Proyecto — Control Horario Escuela de Música

**Última Actualización:** Marzo 2026  
**Estado General:** Fase 2 en progreso activo

---

## Progreso General

```
PROYECTO CONTROL HORARIO
│
├─ FASE 1: UI/UX                                  ✅ 100% COMPLETADO
│
├─ FASE 2: Backend + Lógica + Firebase            🔶 ~65% COMPLETADO
│   ├─ Bloque A: Auth + Firebase Setup            ✅ Completado
│   ├─ Bloque B: Fichaje (Clocking)               ✅ Completado
│   ├─ Bloque C: Mi Control Horario               ✅ Completado
│   ├─ Bloque D: Panel Admin + Empleados          ✅ Completado
│   ├─ Bloque E: Gestión de Horarios              ✅ Completado
│   ├─ Bloque F: Gestión de Calendarios (UI)      ✅ Completado (UI Only)
│   ├─ Bloque G: Gestión de Calendarios (Backend) ⏳ Pendiente
│   ├─ Bloque H: Automatizaciones (Cloud Func.)   ⏳ Pendiente
│   ├─ Bloque I: Horas Extras + Aprobaciones      ⏳ Pendiente
│   └─ Bloque J: Reportes + Exportación PDF       ⏳ Pendiente
│
└─ FASE 3: Testing + Deploy                       ⏳ Pendiente
```

---

## Detalle de lo Implementado

### Bloque A: Autenticación y Firebase ✅

- Firebase Auth (Email/Password) conectado y funcional
- Login con redirección automática según rol (admin/employee)
- Splash screen con verificación de sesión
- Cierre de sesión desde sidebar admin y settings
- Rediseño completo del Login (gradiente azul-violeta, panel informativo)
- Protección de rutas en go_router (`AuthNotifier`)

**Archivos clave:**
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/core/router/auth_notifier.dart`
- `lib/features/auth/providers/auth_provider.dart`

---

### Bloque B: Fichaje (Clocking) ✅

- Botones Entrada / Pausa / Retorno / Salida funcionales
- Estado de fichaje en tiempo real desde Firestore
- Máquina de estados: `idle → active → paused → active → completed`
- Validaciones de negocio (no puede salir sin entrar, etc.)
- Campo `recordStatus` explícito (evita bugs de estados derivados)
- Diálogo de salida anticipada
- Diálogo de edición de hora de entrada

**Archivos clave:**
- `lib/features/dashboard/providers/clocking_provider.dart`
- `lib/features/dashboard/models/daily_record_model.dart`

---

### Bloque C: Mi Control Horario ✅

- Pantalla mensual con navegación por mes/año
- CRUD completo de registros (añadir, editar, copiar, eliminar)
- Sistema de validación y bloqueo de registros
- Vista expandible por día con detalle de turnos
- Diseño responsive (mobile/tablet/desktop)

**Archivos clave:**
- `lib/features/dashboard/presentation/screens/my_time_control_screen.dart`
- `lib/features/dashboard/providers/time_records_provider.dart`
- `lib/features/dashboard/services/time_records_service.dart`

---

### Bloque D: Panel Admin + Gestión de Empleados ✅

- Lista de empleados con búsqueda, filtros y paginación
- Creación de empleados en Firebase Auth + Firestore simultáneamente
- Generación automática de employeeId (EMP-001, EMP-002...)
- Formulario de nuevo empleado con 3 secciones (Personal, Laboral, Horario)
- Asignación de plantilla de horario al crear empleado
- Generación de contraseña temporal al crear usuario
- Pantalla de detalle de empleado
- Drawer lateral responsive (100% mobile, 650px desktop)
- Sistema de roles: employee / rrhh / admin

**Archivos clave:**
- `lib/features/admin/presentation/screens/employees_list_screen.dart`
- `lib/features/admin/presentation/widgets/new_employee_drawer.dart`
- `lib/features/admin/providers/user_management_provider.dart`

---

### Bloque E: Gestión de Horarios (Plantillas) ✅

- CRUD completo de plantillas de horario en Firestore
- Editor visual de turnos por día de semana (`WeekScheduleEditor`)
- Cálculo automático de `totalWeeklyHours`
- Soft delete (isActive = false para preservar histórico)
- Contador `usedByCount` (cuántos empleados usan la plantilla)
- Integración en el formulario de creación de empleados (dropdown)
- Stream en tiempo real con `allScheduleTemplatesProvider`

**Archivos clave:**
- `lib/features/admin/presentation/screens/schedule_management_screen.dart`
- `lib/features/admin/providers/schedule_management_provider.dart`
- `lib/core/services/schedule_service.dart`

---

### Bloque F: Gestión de Calendarios — UI/UX ✅ (Pendiente Backend)

- Modelos de datos: `HolidayType`, `CalendarEventModel`, `WorkCalendarModel`
- Pantalla lista `CalendarManagementScreen` con cards, duplicar y eliminar
- Editor visual `CalendarEditorScreen` con `TableCalendar`
- Festivos pintados con colores por tipo (rojo/azul/ámbar/verde)
- Diálogo `DayEditorDialog` con selector de tipo y opción de rango de fechas
- Panel resumen lateral de festivos configurados
- Navegación registrada en router (`/admin/calendars`)
- Ítem "Gestionar Calendarios" en el sidebar de admin
- Datos mock incluidos (Madrid 2025, Cataluña 2025, Remoto)

**Archivos clave:**
- `lib/features/admin/models/holiday_type.dart`
- `lib/features/admin/models/calendar_event_model.dart`
- `lib/features/admin/models/work_calendar_model.dart`
- `lib/features/admin/presentation/screens/calendar_management_screen.dart`
- `lib/features/admin/presentation/screens/calendar_editor_screen.dart`
- `lib/features/admin/presentation/widgets/calendar_card.dart`
- `lib/features/admin/presentation/widgets/day_editor_dialog.dart`

---

### Sistema de Diseño / UI ✅

- Dual Theme Light/Dark funcional con persistencia
- Paleta de colores completa (escalas 50-900, dark + light)
- Gradientes en botones con glow effects (brand, primary, danger, warning)
- **Estrategia de colores de botones:**
  - `ButtonVariant.brand` (azul-violeta) → Admin + Login
  - `ButtonVariant.primary` (verde) → EXCLUSIVO botón "Entrada"
  - `ButtonVariant.danger` (rojo) → Salida / Destructivos
  - `ButtonVariant.warning` (naranja) → Pausa
- Navegación responsive: sidebar colapsable (desktop) / drawer (mobile)
- Breakpoints: Mobile <640 / Tablet 640-1023 / Desktop ≥1024

---

## Lo que Falta — Fase 2

### Bloque G: Gestión de Calendarios — Backend ⏳

Prioridad: **Alta** (depende del Bloque F ya completado)

| Tarea | Descripción |
|---|---|
| `CalendarService` | CRUD en colección `calendars` de Firestore |
| `calendarManagementProvider` | Riverpod `NotifierProvider` para CRUD + `StreamProvider` para lista |
| Actualizar `UserModel` | Añadir campo `calendarId: String?` + serialización Firestore |
| Actualizar `NewEmployeeDrawer` | Dropdown de calendarios (igual que el de horarios) |
| Reemplazar mock data | Conectar `CalendarManagementScreen` con el provider real |
| Reglas Firestore | Solo admin puede crear/editar calendarios |

**Estructura Firebase:**
```
firestore/
└── calendars/{calendarId}
    ├── name: "Madrid 2025"
    ├── year: 2025
    ├── isActive: true
    ├── isTemplate: true
    └── events: [{ id, name, date, type }]   // Array de eventos
```

---

### Bloque H: Automatizaciones — Cloud Functions ⏳

Prioridad: **Media**

| Función | Descripción | Trigger |
|---|---|---|
| `autoCloseRecords` | Cierra fichajes abiertos al final del día | Cron diario 23:59 |
| `detectOvertime` | Detecta horas extra semanales y crea solicitudes | Cron semanal |
| `generateMonthlySummaries` | Pre-calcula resúmenes para reportes rápidos | Fin de mes |
| `archiveOldRecords` | Mueve registros >3 meses a Cloud Storage | Mensual |

**Nota:** Requiere cambiar a plan Blaze (pay-as-you-go) en Firebase para Cloud Functions.

---

### Bloque I: Horas Extras y Aprobaciones ⏳

Prioridad: **Media**

| Tarea | Descripción |
|---|---|
| `OvertimeRequestModel` | Modelo con Freezed + serialización |
| `OvertimeService` | CRUD en colección `overtime_requests` |
| `OvertimeProvider` | Stream de solicitudes pendientes, aprobar/rechazar |
| Panel RRHH | Pantalla de solicitudes pendientes de aprobación |
| Notificaciones | Avisar al empleado cuando se aprueba/rechaza |

**Estructura Firebase:**
```
firestore/
└── overtime_requests/{requestId}
    ├── userId: "..."
    ├── weekNumber: 47
    ├── overtimeMinutes: 120
    └── status: "pending" | "approved" | "rejected"
```

---

### Bloque J: Reportes y Exportación PDF ⏳

Prioridad: **Baja** (después de los bloques anteriores)

| Tarea | Descripción |
|---|---|
| `ReportsProvider` | Agrega datos de registros por empleado/periodo |
| Pantalla de reportes | Filtros por empleado, mes, año, departamento |
| `PDFExportProvider` | Generación de PDF con librería `pdf` + `printing` |
| Exportación CSV | Alternativa simple al PDF |
| `monthly_summary` | Subcolección con datos pre-calculados |

---

## Deuda Técnica Menor

| Item | Archivo | Descripción |
|---|---|---|
| `TODO: Copiar portapapeles` | `new_employee_drawer.dart` | Botón "COPIAR CREDENCIALES" en modal |
| Rol `supervisor` | `new_employee_drawer.dart` | Radio button existe pero no está en `UserRole` |
| Editar empleado | `employee_detail_screen.dart` | Pantalla de detalle existe, falta formulario de edición |
| Asignar/cambiar calendario | `employee_detail_screen.dart` | Campo `calendarId` pendiente de agregar |
| `Reportes Detallados` | `admin_sidebar.dart` | Ítem muestra "en desarrollo", pantalla no implementada |

---

## Estructura de Archivos Relevantes

```
lib/
├── core/
│   ├── theme/                         ✅ Completo (colores, gradientes, sombras, tipografías)
│   ├── constants/                     ✅ Completo (breakpoints, constantes, mocks)
│   ├── router/                        ✅ Completo (go_router, auth guard)
│   ├── providers/                     ✅ theme_provider
│   └── services/
│       ├── firebase_service.dart      ✅ Servicio base Firebase
│       ├── schedule_service.dart      ✅ CRUD plantillas horario
│       └── calendar_service.dart      ⏳ Por crear (Bloque G)
│
├── features/
│   ├── auth/                          ✅ Login, Splash, UserModel, AuthProvider
│   ├── dashboard/                     ✅ Dashboard, Fichaje, Mi Control Horario
│   └── admin/
│       ├── models/
│       │   ├── schedule_model.dart    ✅ Con Freezed
│       │   ├── holiday_type.dart      ✅ Nuevo
│       │   ├── calendar_event_model.dart ✅ Nuevo
│       │   └── work_calendar_model.dart  ✅ Nuevo (mock data)
│       ├── providers/
│       │   ├── user_management_provider.dart    ✅ Firebase
│       │   ├── schedule_management_provider.dart ✅ Firebase
│       │   └── calendar_management_provider.dart ⏳ Por crear (Bloque G)
│       └── presentation/
│           ├── screens/               ✅ Todos (+ calendar_management/editor nuevos)
│           └── widgets/               ✅ Todos (+ calendar_card/day_editor nuevos)
│
└── shared/
    └── widgets/                       ✅ Completo (buttons, cards, inputs, navigation)
```

---

## Stack Tecnológico

| Categoría | Tecnología | Estado |
|---|---|---|
| Framework | Flutter Web 3.24+ | ✅ |
| State Management | Riverpod 2.6.1 + Code Gen | ✅ |
| Navegación | go_router 12.1.3 | ✅ |
| Auth | Firebase Auth 6.1.3 | ✅ |
| Base de datos | Cloud Firestore 6.1.1 | ✅ |
| Calendario UI | table_calendar 3.1.2 | ✅ Nuevo |
| Persistencia local | shared_preferences | ✅ |
| Tipografías | google_fonts (Inter) | ✅ |
| Localización | flutter_localizations (es_ES) | ✅ |
| Modelos | freezed + json_serializable | ✅ |
| Cloud Functions | Firebase Functions | ⏳ Bloque H |
| Exportación | pdf + printing | ⏳ Bloque J |

---

## Próximos Pasos Recomendados

```
1. ─ Bloque G: CalendarService + calendarManagementProvider + UserModel.calendarId
   └── Estimado: 1 sesión de trabajo

2. ─ Bloque D (completar): Pantalla de edición de empleado (edit drawer)
   └── Estimado: 1 sesión de trabajo

3. ─ Bloque H: Cloud Functions (requiere plan Blaze)
   └── Estimado: 2 sesiones de trabajo

4. ─ Bloque I: Horas Extras + Panel RRHH
   └── Estimado: 2 sesiones de trabajo

5. ─ Bloque J: Reportes + PDF
   └── Estimado: 2 sesiones de trabajo
```
