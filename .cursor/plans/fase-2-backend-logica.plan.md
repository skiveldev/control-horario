# 📋 FASE 2 - PLANIFICACIÓN COMPLETA

## Backend + Lógica + Firebase

**Proyecto**: Sistema de Control Horario - Escuela de Música

**Estado**: 🚧 En Planificación

**Versión**: 2.0.0-planning

**Fecha**: Noviembre 2025

---

## 📊 Contexto del Proyecto

### ✅ Fase 1 Completada

- UI/UX completo con datos mock
- 8 pantallas implementadas
- Sistema de diseño completo
- Navegación con go_router
- **50 archivos** creados (~8,000 líneas)

### 🎯 Objetivo Fase 2

Implementar **backend funcional** con Firebase y lógica de negocio real, reemplazando todos los datos mock.

---

## 🏢 Requisitos del Cliente

### Datos de la Escuela

- **Empleados**: 458 (docentes + no docentes)
- **Todos fichan**: Sin excepciones
- **Contratos**: Todos fijos (horarios variables por empleado)
- **Histórico**: Conservar 4 años de registros

### Sistema de Fichaje

```
Flujo del día:
1. ENTRADA (obligatoria)
2. PAUSA (opcional, solo 1 vez)
3. RETORNO (si hubo pausa)
4. SALIDA (obligatoria)

Reglas:
- Solo 1 pausa permitida por día
- Pausa cuenta como tiempo trabajado
- Fichaje remoto permitido (docentes + trabajo remoto)
- Geolocalización: nice-to-have (auditorías futuras)
```

### Roles de Usuario

| Rol | Permisos | Cantidad |

|-----|----------|----------|

| **Empleado** | - Ver sus propios registros<br>- Fichar entrada/pausa/retorno/salida<br>- Editar solo ENTRADA (mismo día) | 456 |

| **RRHH** | - Ver todos los empleados<br>- Generar reportes<br>- Exportar PDF<br>- Gestionar horarios<br>- Aprobar horas extras | 1 |

| **Admin** | - Todo lo de RRHH +<br>- Crear/eliminar usuarios<br>- Corregir cualquier fichaje<br>- Configuración del sistema | 1 |

### Reglas de Negocio

1. **Validación de secuencia**: No permitir fichajes fuera de orden
2. **Edición de empleado**: Solo entrada, solo mismo día, sin aprobación
3. **Edición de admin**: Cualquier fichaje, cualquier fecha, con historial
4. **Cierre automático**: Si olvida fichar salida → cierre a fin de horario contratado
5. **Horas extras**: Requieren aprobación de RRHH o Admin
6. **Salida anticipada**: Diálogo de confirmación si faltan >1 hora

### Reportes Requeridos

- Horas mensuales por empleado
- Horas extras (pendientes/aprobadas/rechazadas)
- Anomalías (fichajes incompletos, auto-cerrados)
- Exportación a PDF

### Restricciones Técnicas

- **Budget**: Plan gratuito Firebase inicialmente
- **Performance**: Tiempo real no crítico (delay de minutos aceptable)
- **Archivado**: Mantener 3 meses accesibles, resto archivado
- **Escalabilidad**: Preparado para crecimiento futuro

### Stack Técnico (Fase 2)

- **State Management**: **Riverpod** (único y oficial del proyecto)
                                                                                                                                                                                                                                                                - NO usar `setState`, `InheritedWidget`, `Provider`, o `BLoC`
                                                                                                                                                                                                                                                                - TODO el estado se maneja con Riverpod
                                                                                                                                                                                                                                                                - Widgets consumen datos SOLO vía Riverpod providers
                                                                                                                                                                                                                                                                - Code generation con `riverpod_generator` + `freezed`
- **Backend**: Firebase (Auth, Firestore, Functions, Storage)
- **Navegación**: go_router (ya implementado en Fase 1)
- **UI**: Material Design 3 + Custom Theme (ya implementado en Fase 1)

---

## 🗄️ DISEÑO DE BASE DE DATOS FIREBASE

### Estructura de Colecciones

```
firestore/
├── users/                                    # Colección principal
│   └── {userId}/                             # Documento por usuario
│       ├── (campos del perfil)
│       ├── daily_records/                    # Subcolección de fichajes
│       │   └── {YYYY-MM-DD}/                 # 1 documento por día
│       │       ├── clocks (objeto)
│       │       └── metadata
│       └── monthly_summary/                  # Subcolección de resúmenes
│           └── {YYYY-MM}/                    # 1 documento por mes
│               └── (totales pre-calculados)
│
├── schedules/                                # Colección de horarios
│   └── {scheduleId}/
│       └── (configuración de horario)
│
├── overtime_requests/                        # Colección de horas extras
│   └── {requestId}/
│       └── (solicitud de aprobación)
│
└── system_config/                            # Colección de configuración
    └── settings/                             # Documento único
        └── (reglas globales del sistema)
```

---

## 🏗️ ARQUITECTURA DE STATE MANAGEMENT

### Principio: Riverpod para TODO

**REGLA FUNDAMENTAL**: Todo el estado de la aplicación se gestiona exclusivamente con **Riverpod**.

#### ❌ NO Usar para Estado de Aplicación:

- `setState()` para estado que afecta otros widgets o lógica de negocio
- `InheritedWidget` o `InheritedNotifier`
- `Provider` package (antiguo)
- `BLoC` pattern
- `GetX` o cualquier otro state management
- Variables globales o singletons con estado mutable

#### ⚠️ Excepción Permitida:

✅ `setState()` SOLO para UI local que NO afecta otros widgets:

- Estado de TextField antes de enviar
- Estado de Checkbox/Switch local
- Animaciones puramente visuales
- Hover states, focus states
- Expansión/colapso de widgets locales

**Regla**: Si el estado NO sale del widget → `setState` OK. Si sale → Riverpod obligatorio.

#### ✅ SÍ Usar:

- **Riverpod Providers** para todo el estado
- **ConsumerWidget** o **ConsumerStatefulWidget** para widgets que consumen estado
- **Consumer** o **ref.watch()** para escuchar cambios
- **ref.read()** solo en callbacks (nunca en build)
- **Code generation** con `riverpod_generator` y `freezed`

### Patrón de Arquitectura

```
┌─────────────────────────────────────────┐
│           UI Layer (Widgets)            │
│   - ConsumerWidget / ConsumerStateful   │
│   - NO lógica de negocio                │
│   - Solo presentación                   │
└──────────────┬──────────────────────────┘
               │ ref.watch() / ref.listen()
               ↓
┌─────────────────────────────────────────┐
│      Providers Layer (Riverpod)         │
│   - Stream/Future/State Providers       │
│   - Lógica de negocio                   │
│   - Transformaciones de datos           │
└──────────────┬──────────────────────────┘
               │ llama
               ↓
┌─────────────────────────────────────────┐
│       Services Layer (Firebase)         │
│   - FirebaseAuth                        │
│   - Firestore queries                   │
│   - Cloud Functions calls               │
│   - Storage operations                  │
└─────────────────────────────────────────┘
```

### Ejemplo Completo

```dart
// ❌ INCORRECTO - No usar setState para estado de aplicación
class DashboardScreenOld extends StatefulWidget {
  @override
  State<DashboardScreenOld> createState() => _DashboardScreenOldState();
}

class _DashboardScreenOldState extends State<DashboardScreenOld> {
  List<DailyRecord> records = []; // ❌ Estado que afecta toda la pantalla
  
  @override
  void initState() {
    super.initState();
    loadRecords(); // ❌ NO
  }
  
  void loadRecords() async {
    final data = await FirebaseFirestore.instance
        .collection('users/$uid/daily_records')
        .get();
    setState(() { // ❌ NO USAR setState para estado de aplicación
      records = data.docs.map((doc) => DailyRecord.fromJson(doc.data())).toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(...); // ❌ MAL
  }
}

// ⚠️ EXCEPCIÓN VÁLIDA - setState para UI local
class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  
  const SearchBarWidget({required this.onSearch});
  
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  String _searchText = ''; // ✅ Estado local del widget
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        setState(() => _searchText = value); // ✅ OK: UI local
      },
      onSubmitted: (value) {
        widget.onSearch(value); // Solo aquí sale del widget
      },
    );
  }
}

// ✅ CORRECTO - Usar Riverpod
@riverpod
Stream<List<DailyRecord>> monthlyRecords(MonthlyRecordsRef ref, String userId) {
  return FirebaseFirestore.instance
      .collection('users/$userId/daily_records')
      .where('month', isEqualTo: getCurrentMonth())
      .snapshots()
      .map((snapshot) => 
          snapshot.docs.map((doc) => DailyRecord.fromJson(doc.data())).toList()
      );
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(monthlyRecordsProvider(getCurrentUserId()));
    
    return recordsAsync.when(
      data: (records) => ListView.builder(...), // ✅ BIEN
      loading: () => LoadingSpinner(),
      error: (error, stack) => ErrorState(error: error),
    );
  }
}
```

### Tipos de Providers a Usar

1. **StreamProvider**: Para datos que cambian en tiempo real (Firestore snapshots)
```dart
@riverpod
Stream<User> currentUser(CurrentUserRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.userChanges();
}
```

2. **FutureProvider**: Para operaciones asíncronas de una vez
```dart
@riverpod
Future<List<Schedule>> schedules(SchedulesRef ref) async {
  final db = ref.watch(firestoreProvider);
  final snapshot = await db.collection('schedules').get();
  return snapshot.docs.map((doc) => Schedule.fromJson(doc.data())).toList();
}
```

3. **StateProvider**: Para estado simple y local
```dart
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
```

4. **NotifierProvider**: Para estado complejo con métodos
```dart
@riverpod
class ClockingNotifier extends _$ClockingNotifier {
  @override
  ClockingState build() => ClockingState.notStarted();
  
  Future<void> clockIn() async {
    // Lógica de fichaje
    state = ClockingState.working();
  }
  
  Future<void> clockOut() async {
    // Lógica de fichaje
    state = ClockingState.finished();
  }
}
```


### Reglas de Uso

1. **En widgets (build method)**:

                                                                                                                                                                                                                                                                                                                                                                                                - ✅ Usar `ref.watch()` para escuchar cambios
                                                                                                                                                                                                                                                                                                                                                                                                - ❌ NUNCA usar `ref.read()` en build

2. **En callbacks (onPressed, onChanged)**:

                                                                                                                                                                                                                                                                                                                                                                                                - ✅ Usar `ref.read()` para ejecutar acciones
                                                                                                                                                                                                                                                                                                                                                                                                - ✅ Usar `ref.invalidate()` para refrescar datos

3. **En providers**:

                                                                                                                                                                                                                                                                                                                                                                                                - ✅ Usar `ref.watch()` para depender de otros providers
                                                                                                                                                                                                                                                                                                                                                                                                - ✅ Usar `ref.read()` para llamar métodos

4. **Dependencias**:

                                                                                                                                                                                                                                                                                                                                                                                                - ✅ Providers pueden depender de otros providers
                                                                                                                                                                                                                                                                                                                                                                                                - ✅ Auto-refetch cuando dependencias cambian
                                                                                                                                                                                                                                                                                                                                                                                                - ✅ Auto-dispose cuando no se usan

### Testing con Riverpod

```dart
// Unit test de provider
test('monthlyRecordsProvider returns records', () async {
  final container = ProviderContainer(
    overrides: [
      firestoreProvider.overrideWithValue(mockFirestore),
    ],
  );
  
  final records = await container.read(monthlyRecordsProvider('user123').future);
  
  expect(records, isNotEmpty);
});

// Widget test con provider
testWidgets('DashboardScreen shows records', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        monthlyRecordsProvider('user123').overrideWith((ref) => 
          Stream.value([mockRecord1, mockRecord2])
        ),
      ],
      child: MaterialApp(home: DashboardScreen()),
    ),
  );
  
  expect(find.byType(RecordsTable), findsOneWidget);
});
```

### Beneficios de Riverpod en este Proyecto

1. **Reactive**: UI se actualiza automáticamente cuando datos cambian
2. **Testeable**: Fácil mockear providers en tests
3. **Type-safe**: Errores en compile-time, no runtime
4. **Performance**: Auto-dispose y caché inteligente
5. **Developer Experience**: Code generation reduce boilerplate
6. **Debuggeable**: Riverpod DevTools para inspeccionar estado
7. **Escalable**: Fácil agregar nuevos providers sin refactorizar

---

## 📐 ESPECIFICACIONES POR SPRINT

### 🎯 Sprint 1: MVP - Core Básico (Semana 1)

**Objetivo**: Login funcional + Fichaje básico Entrada/Salida

#### Colecciones a Implementar

##### 1. Collection: `users`

```typescript
// Documento: /users/{userId}
interface User {
  // Identificación
  userId: string;              // Firebase Auth UID
  employeeId: string;          // ID interno ("EMP-001")
  email: string;
  displayName: string;
  
  // Información Laboral
  role: 'employee' | 'rrhh' | 'admin';
  position: string;            // "Profesor de Piano"
  contractType: 'full_time' | 'part_time';
  
  // Horario
  scheduleId: string;          // Referencia a schedule
  weeklyHours: number;         // Horas semanales contratadas (40)
  
  // Estado
  isActive: boolean;
  
  // Metadata
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

**Campos del MVP (Sprint 1)**:

```typescript
// Solo implementar en Sprint 1:
{
  userId: string;
  employeeId: string;
  email: string;
  displayName: string;
  role: 'employee' | 'rrhh' | 'admin';
  weeklyHours: number;
  isActive: boolean;
  createdAt: Timestamp;
}
```

##### 2. SubCollection: `users/{userId}/daily_records`

```typescript
// Documento: /users/{userId}/daily_records/{YYYY-MM-DD}
interface DailyRecord {
  // Identificación
  date: string;                // "2025-11-20" (YYYY-MM-DD)
  userId: string;
  
  // Fichajes (Sprint 1: solo in/out)
  clocks: {
    clockIn: string | null;     // "08:30:00" (HH:mm:ss)
    clockOut: string | null;    // "17:00:00" o null si no fichó
    // breakStart: null,        // Sprint 2
    // breakEnd: null,          // Sprint 2
  };
  
  // Timestamps (para queries)
  clockInTimestamp: Timestamp | null;
  clockOutTimestamp: Timestamp | null;
  
  // Estado
  status: 'incomplete' | 'complete';
  
  // Metadata
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

**Campos del MVP (Sprint 1)**:

```typescript
{
  date: "2025-11-20",
  userId: "uid123",
  clocks: {
    clockIn: "08:30:00",
    clockOut: null              // Aún no fichó salida
  },
  clockInTimestamp: Timestamp,
  clockOutTimestamp: null,
  status: "incomplete",
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

##### 3. Collection: `system_config`

```typescript
// Documento: /system_config/settings
interface SystemConfig {
  version: string;
  
  clockingRules: {
    maxDailyHours: number;      // 12
    allowEarlyClockIn: number;  // 15 minutos antes
    allowLateClockOut: number;  // 15 minutos después
  };
  
  updatedAt: Timestamp;
  updatedBy: string;            // uid del admin
}
```

#### Funcionalidades Sprint 1

**Autenticación**:

- [x] Login con Firebase Auth (email/password)
- [x] Logout
- [x] Protección de rutas (redirect si no autenticado)
- [x] Provider: `AuthProvider` (Riverpod)

**Fichaje**:

- [x] Botón "Fichar Entrada" → Crea documento en `daily_records/{today}`
- [x] Botón "Fichar Salida" → Actualiza documento con `clockOut`
- [x] Mostrar estado actual (sin fichar / en trabajo)
- [x] Provider: `ClockingProvider` (Riverpod)

**Dashboard**:

- [x] Mostrar fichajes del mes actual
- [x] Calcular total horas del día
- [x] Calcular total horas del mes
- [x] Provider: `DashboardProvider` (Riverpod)

#### Reglas de Seguridad Sprint 1

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isRRHH() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'rrhh';
    }
    
    // Users collection
    match /users/{userId} {
      // Leer: El propio usuario o admin/rrhh
      allow read: if isOwner(userId) || isAdmin() || isRRHH();
      
      // Escribir: Solo admin
      allow write: if isAdmin();
      
      // Subcolección de fichajes
      match /daily_records/{recordId} {
        // Leer: El propio usuario o admin/rrhh
        allow read: if isOwner(userId) || isAdmin() || isRRHH();
        
        // Crear: El propio usuario (fichaje)
        allow create: if isOwner(userId);
        
        // Actualizar: El propio usuario (solo mismo día) o admin
        allow update: if isOwner(userId) && recordId == getToday() || isAdmin();
        
        // Eliminar: Solo admin
        allow delete: if isAdmin();
      }
    }
    
    // System config (solo lectura para todos, escritura admin)
    match /system_config/{doc} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
  }
}
```

**Nota**: `getToday()` es función helper a implementar en el cliente, no en reglas.

#### Índices Compuestos Sprint 1

```javascript
// Firestore Indexes (crear en Firebase Console)

// Para queries de registros por usuario y mes
Collection: users/{userId}/daily_records
- date (Ascending)
- status (Ascending)

// Para queries de registros por fecha
Collection: users/{userId}/daily_records
- date (Descending)
```

#### Providers Riverpod Sprint 1

```dart
// lib/features/auth/providers/auth_provider.dart
- AuthStateProvider (Stream de User?)
- SignInProvider (Future login)
- SignOutProvider (Future logout)

// lib/features/dashboard/providers/clocking_provider.dart
- ClockInProvider (Future fichar entrada)
- ClockOutProvider (Future fichar salida)
- CurrentDayRecordProvider (Stream del registro de hoy)

// lib/features/dashboard/providers/dashboard_provider.dart
- MonthlyRecordsProvider (Stream de registros del mes)
- DailySummaryProvider (Computed del día actual)
- MonthlySummaryProvider (Computed del mes actual)
```

#### Testing Sprint 1

```dart
// Unit Tests
- AuthProvider tests
- ClockingProvider tests
- Cálculo de horas trabajadas

// Widget Tests
- LoginScreen con providers mock
- DashboardScreen con datos de prueba

// Integration Tests
- Flujo completo: Login → Fichar → Ver dashboard → Logout
```

---

### 🎯 Sprint 2: Pausas + Validaciones (Semana 2)

**Objetivo**: Añadir sistema de pausas + máquina de estados

#### Cambios en Estructura

##### Actualizar: `daily_records`

```typescript
interface DailyRecord {
  date: string;
  userId: string;
  
  // ✨ NUEVO: Agregar pausas
  clocks: {
    clockIn: string | null;
    breakStart: string | null;    // ✨ Sprint 2
    breakEnd: string | null;      // ✨ Sprint 2
    clockOut: string | null;
  };
  
  clockInTimestamp: Timestamp | null;
  breakStartTimestamp: Timestamp | null;    // ✨ Sprint 2
  breakEndTimestamp: Timestamp | null;      // ✨ Sprint 2
  clockOutTimestamp: Timestamp | null;
  
  // ✨ NUEVO: Cálculos
  totalWorkedMinutes: number | null;        // ✨ Sprint 2
  breakDurationMinutes: number | null;      // ✨ Sprint 2
  
  status: 'incomplete' | 'complete';
  
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

#### Funcionalidades Sprint 2

**Máquina de Estados**:

```typescript
enum ClockingState {
  NOT_STARTED,    // Inicio del día → Solo ENTRADA disponible
  WORKING,        // Fichó entrada → PAUSA o SALIDA disponibles
  ON_BREAK,       // Fichó pausa → Solo RETORNO disponible
  RETURNED,       // Fichó retorno → PAUSA o SALIDA disponibles (= WORKING)
  FINISHED        // Fichó salida → Nada disponible
}
```

**Validaciones**:

- [x] Deshabilitar botones según estado actual
- [x] Prevenir fichajes fuera de secuencia
- [x] Diálogo de confirmación en salida anticipada (falta >1h)
- [x] Provider: `ClockingStateProvider` (Riverpod)

**Cálculos**:

- [x] Calcular minutos trabajados (incluye pausas)
- [x] Calcular duración de pausa
- [x] Actualizar `totalWorkedMinutes` al fichar salida
- [x] Provider: `TimeCalculationProvider` (Riverpod)

#### Testing Sprint 2

```dart
// Unit Tests
- Máquina de estados (todas las transiciones)
- Validación de secuencia de fichajes
- Cálculo de minutos trabajados

// Widget Tests
- Botones deshabilitados según estado
- Diálogo de confirmación en salida anticipada

// Integration Tests
- Flujo completo con pausa: Entrada → Pausa → Retorno → Salida
- Intentar fichar fuera de orden (debe fallar)
```

---

### 🎯 Sprint 3: Panel Admin + Correcciones (Semana 3)

**Objetivo**: Admin puede ver todos los empleados y corregir fichajes

#### Cambios en Estructura

##### Actualizar: `daily_records`

```typescript
interface DailyRecord {
  // ... campos anteriores
  
  // ✨ NUEVO: Historial de ediciones
  editHistory: Array<{
    field: string;              // "clockIn" | "clockOut" | etc.
    oldValue: string | null;
    newValue: string | null;
    editedBy: string;           // uid del editor
    editedByRole: string;       // "employee" | "admin"
    editedAt: Timestamp;
    reason?: string;            // Opcional: motivo de corrección
  }> | null;                    // ✨ Sprint 3
  
  // ✨ NUEVO: Flag de corrección
  wasEdited: boolean;           // ✨ Sprint 3
  lastEditedAt: Timestamp | null; // ✨ Sprint 3
}
```

#### Funcionalidades Sprint 3

**Panel Admin**:

- [x] Lista de todos los empleados
- [x] Filtrar por departamento/rol/estado
- [x] Buscar por nombre/ID
- [x] Ver detalle de empleado
- [x] Provider: `AdminEmployeesProvider` (Riverpod)

**Corrección de Fichajes**:

- [x] Admin puede editar cualquier campo de cualquier fecha
- [x] Modal de confirmación con campo "motivo"
- [x] Guardar en `editHistory` cada cambio
- [x] Marcar registro como editado (`wasEdited: true`)
- [x] Provider: `AdminClockingProvider` (Riverpod)

**Lista de Anomalías**:

- [x] Query de registros con `status: "incomplete"`
- [x] Mostrar en panel admin
- [x] Botón para corregir desde lista
- [x] Provider: `AnomaliesProvider` (Riverpod)

#### Reglas de Seguridad Sprint 3

```javascript
// Actualizar regla de update en daily_records
match /daily_records/{recordId} {
  allow update: if (
    // Empleado: solo entrada, solo hoy, sin editar editHistory
    (isOwner(userId) && 
     recordId == getToday() && 
     !request.resource.data.keys().hasAny(['editHistory', 'wasEdited']))
    ||
    // Admin: todo
    isAdmin()
  );
}
```

#### Testing Sprint 3

```dart
// Unit Tests
- AdminEmployeesProvider (filtros, búsqueda)
- Historial de ediciones (agregar, formatear)

// Widget Tests
- Lista de empleados con filtros
- Modal de corrección de fichaje

// Integration Tests
- Admin corrige fichaje → Se guarda en editHistory
- Empleado intenta editar campo prohibido → Falla
```

---

### 🎯 Sprint 4: Cierre Automático + Horas Extras (Semana 4)

**Objetivo**: Automatizar cierres + sistema de aprobación de horas extras

#### Nuevas Colecciones

##### 1. Collection: `schedules`

```typescript
// Documento: /schedules/{scheduleId}
interface Schedule {
  scheduleId: string;           // "schedule_standard"
  name: string;                 // "Jornada Estándar"
  description: string;
  
  // Horario semanal
  weeklySchedule: {
    monday: DaySchedule;
    tuesday: DaySchedule;
    wednesday: DaySchedule;
    thursday: DaySchedule;
    friday: DaySchedule;
    saturday: DaySchedule;
    sunday: DaySchedule;
  };
  
  totalWeeklyHours: number;     // 40
  isActive: boolean;
  createdAt: Timestamp;
}

interface DaySchedule {
  isWorkDay: boolean;
  startTime: string | null;     // "08:00"
  endTime: string | null;       // "17:00"
  breakMinutes: number;         // 60
}
```

##### 2. Collection: `overtime_requests`

```typescript
// Documento: /overtime_requests/{requestId}
interface OvertimeRequest {
  requestId: string;
  userId: string;
  employeeName: string;
  
  // Periodo
  weekNumber: number;           // 47
  year: number;                 // 2025
  weekDateRange: string;        // "Nov 17 - Nov 23, 2025"
  
  // Horas extras
  contractedMinutes: number;    // 2400 (40h)
  workedMinutes: number;        // 2640 (44h)
  overtimeMinutes: number;      // 240 (4h)
  
  // Estado
  status: 'pending' | 'approved' | 'rejected';
  
  // Aprobación
  reviewedBy: string | null;    // uid de quien aprobó
  reviewedByName: string | null;
  reviewedAt: Timestamp | null;
  reviewNotes: string | null;
  
  // Metadata
  createdAt: Timestamp;
  autoGenerated: boolean;       // true si lo crea el sistema
}
```

#### Cambios en Estructura

##### Actualizar: `users`

```typescript
interface User {
  // ... campos anteriores
  
  scheduleId: string;           // ✨ Ahora se usa (Sprint 4)
}
```

##### Actualizar: `daily_records`

```typescript
interface DailyRecord {
  // ... campos anteriores
  
  // ✨ NUEVO: Cierre automático
  autoClosedAt: string | null;      // ✨ Sprint 4
  wasAutoClosed: boolean;           // ✨ Sprint 4
  requiresReview: boolean;          // ✨ Sprint 4 (anomalía)
}
```

#### Funcionalidades Sprint 4

**Cierre Automático**:

- [x] Cloud Function diaria (ejecuta a medianoche)
- [x] Query registros `status: "incomplete"` del día anterior
- [x] Obtener horario del empleado (`schedules`)
- [x] Cerrar con `clockOut: endTime` del horario
- [x] Marcar `wasAutoClosed: true`, `requiresReview: true`
- [x] **Archivo**: `functions/src/autoCloseRecords.ts`

**Detección de Horas Extras**:

- [x] Cloud Function semanal (ejecuta domingo 23:59)
- [x] Calcular total minutos trabajados de la semana
- [x] Comparar con `weeklyHours` contratadas
- [x] Si hay diferencia > 0 → Crear `overtime_request` con `status: "pending"`
- [x] **Archivo**: `functions/src/detectOvertime.ts`

**Aprobación de Horas Extras**:

- [x] Panel RRHH/Admin muestra solicitudes pendientes
- [x] Botones: Aprobar / Rechazar
- [x] Modal para agregar notas
- [x] Actualizar `status` y guardar `reviewedBy`, `reviewedAt`
- [x] Provider: `OvertimeProvider` (Riverpod)

#### Cloud Functions

```typescript
// functions/src/index.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Cloud Function: Cierre automático diario
export const autoCloseRecords = functions.pubsub
  .schedule('0 0 * * *')  // Cada día a medianoche
  .timeZone('Europe/Madrid')
  .onRun(async (context) => {
    // Lógica de cierre automático
  });

// Cloud Function: Detección de horas extras semanal
export const detectOvertime = functions.pubsub
  .schedule('59 23 * * 0')  // Domingos a las 23:59
  .timeZone('Europe/Madrid')
  .onRun(async (context) => {
    // Lógica de detección de horas extras
  });
```

#### Testing Sprint 4

```dart
// Unit Tests (Cloud Functions)
- autoCloseRecords (mockear Firestore)
- detectOvertime (mockear Firestore)

// Unit Tests (Flutter)
- OvertimeProvider (cargar, aprobar, rechazar)

// Widget Tests
- Panel de solicitudes de horas extras
- Modal de aprobación/rechazo

// Integration Tests
- Simular día sin fichar salida → Verificar cierre automático
- Simular semana con horas extras → Verificar creación de solicitud
```

---

### 🎯 Sprint 5: Reportes + Archivado (Semana 5)

**Objetivo**: Generación de reportes + archivado de registros antiguos

#### Nueva Colección

##### SubCollection: `users/{userId}/monthly_summary`

```typescript
// Documento: /users/{userId}/monthly_summary/{YYYY-MM}
interface MonthlySummary {
  month: string;                // "2025-11"
  userId: string;
  
  // Totales
  totalDaysWorked: number;      // 20
  totalMinutesWorked: number;   // 9600 (160h)
  avgDailyMinutes: number;      // 480 (8h)
  
  // Extras y anomalías
  overtimeMinutes: number;      // 120 (2h)
  incompleteDays: number;       // 2
  autoClosedDays: number;       // 1
  
  // Breakdown por semana
  weeklyBreakdown: Array<{
    weekNumber: number;
    minutesWorked: number;
    daysWorked: number;
  }>;
  
  // Metadata
  calculatedAt: Timestamp;
  lastUpdatedAt: Timestamp;
}
```

#### Funcionalidades Sprint 5

**Generación de Resúmenes Mensuales**:

- [x] Cloud Function mensual (ejecuta día 1 de cada mes)
- [x] Para cada usuario: calcular totales del mes anterior
- [x] Guardar en `monthly_summary/{YYYY-MM}`
- [x] **Archivo**: `functions/src/generateMonthlySummaries.ts`

**Reportes**:

- [x] Pantalla de reportes (RRHH/Admin)
- [x] Filtros: Empleado, Mes, Departamento
- [x] Mostrar datos de `monthly_summary`
- [x] Gráficos: horas trabajadas por semana
- [x] Provider: `ReportsProvider` (Riverpod)

**Exportación a PDF**:

- [x] Botón "Exportar PDF" en pantalla de reportes
- [x] Usar librería `pdf` de Flutter
- [x] Generar PDF con:
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                - Encabezado con logo escuela
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                - Tabla de fichajes del mes
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                - Totales y promedios
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                - Anomalías destacadas
- [x] Descargar archivo
- [x] Provider: `PDFExportProvider` (Riverpod)

**Archivado de Registros**:

- [x] Cloud Function mensual (ejecuta día 1 de cada mes)
- [x] Query registros con `date < (hoy - 90 días)`
- [x] Exportar a JSON comprimido
- [x] Subir a Cloud Storage: `gs://bucket/archive/{YYYY-MM}.json.gz`
- [x] Eliminar de Firestore
- [x] **Archivo**: `functions/src/archiveOldRecords.ts`

**Consulta de Archivados**:

- [x] Función helper para leer archivos de Storage
- [x] Botón "Ver histórico completo" (para admin/rrhh)
- [x] Descargar JSON de Storage y parsear
- [x] Mostrar en tabla (lectura lenta, warning de performance)
- [x] Provider: `ArchivedRecordsProvider` (Riverpod)

#### Cloud Functions Sprint 5

```typescript
// functions/src/index.ts

// Cloud Function: Generar resúmenes mensuales
export const generateMonthlySummaries = functions.pubsub
  .schedule('0 2 1 * *')  // Día 1 de cada mes a las 2am
  .timeZone('Europe/Madrid')
  .onRun(async (context) => {
    // Lógica de generación de resúmenes
  });

// Cloud Function: Archivar registros antiguos
export const archiveOldRecords = functions.pubsub
  .schedule('0 3 1 * *')  // Día 1 de cada mes a las 3am
  .timeZone('Europe/Madrid')
  .onRun(async (context) => {
    // Lógica de archivado
  });
```

#### Testing Sprint 5

```dart
// Unit Tests (Cloud Functions)
- generateMonthlySummaries (mockear Firestore)
- archiveOldRecords (mockear Firestore + Storage)

// Unit Tests (Flutter)
- ReportsProvider (filtros, queries)
- PDFExportProvider (generación de PDF)

// Widget Tests
- Pantalla de reportes con filtros
- Visualización de resúmenes mensuales

// Integration Tests
- Generar reporte → Exportar PDF → Verificar descarga
- Consultar registros archivados → Verificar lectura de Storage
```

---

## 🔐 REGLAS DE SEGURIDAD COMPLETAS

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ========================================
    // HELPER FUNCTIONS
    // ========================================
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    
    function isAdmin() {
      return isAuthenticated() && getUserData().role == 'admin';
    }
    
    function isRRHH() {
      return isAuthenticated() && getUserData().role == 'rrhh';
    }
    
    function isAdminOrRRHH() {
      return isAdmin() || isRRHH();
    }
    
    function getTodayDate() {
      // Implementar en cliente, no disponible en reglas
      // Esta función es solo ilustrativa
      return "2025-11-20";
    }
    
    // ========================================
    // USERS COLLECTION
    // ========================================
    
    match /users/{userId} {
      // Leer perfil
      allow read: if isOwner(userId) || isAdminOrRRHH();
      
      // Crear usuario: Solo admin
      allow create: if isAdmin();
      
      // Actualizar perfil: Solo admin (empleado no puede cambiar su propio perfil)
      allow update: if isAdmin();
      
      // Eliminar usuario: Solo admin
      allow delete: if isAdmin();
      
      // ========================================
      // DAILY RECORDS SUBCOLLECTION
      // ========================================
      
      match /daily_records/{date} {
        // Leer registros
        allow read: if isOwner(userId) || isAdminOrRRHH();
        
        // Crear registro: El propio usuario (fichaje)
        allow create: if isOwner(userId) && 
                      request.resource.data.userId == request.auth.uid;
        
        // Actualizar registro
        allow update: if (
          // Caso 1: Empleado edita solo entrada, solo hoy
          (isOwner(userId) && 
           request.resource.data.date == date &&  // Solo hoy (verificar en cliente)
           onlyEditingClockIn())
          ||
          // Caso 2: Admin edita cualquier cosa
          isAdmin()
        );
        
        // Eliminar: Solo admin
        allow delete: if isAdmin();
        
        // Helper: Verificar que solo se edita clockIn
        function onlyEditingClockIn() {
          let oldClocks = resource.data.clocks;
          let newClocks = request.resource.data.clocks;
          
          return (
            // Solo clockIn cambió
            newClocks.clockIn != oldClocks.clockIn &&
            newClocks.clockOut == oldClocks.clockOut &&
            newClocks.breakStart == oldClocks.breakStart &&
            newClocks.breakEnd == oldClocks.breakEnd
          );
        }
      }
      
      // ========================================
      // MONTHLY SUMMARY SUBCOLLECTION
      // ========================================
      
      match /monthly_summary/{month} {
        // Leer: El propio usuario o admin/rrhh
        allow read: if isOwner(userId) || isAdminOrRRHH();
        
        // Escribir: Solo Cloud Functions (admin service account)
        allow write: if false;  // Solo via Admin SDK
      }
    }
    
    // ========================================
    // SCHEDULES COLLECTION
    // ========================================
    
    match /schedules/{scheduleId} {
      // Leer: Todos los autenticados
      allow read: if isAuthenticated();
      
      // Escribir: Solo RRHH o Admin
      allow write: if isAdminOrRRHH();
    }
    
    // ========================================
    // OVERTIME REQUESTS COLLECTION
    // ========================================
    
    match /overtime_requests/{requestId} {
      // Leer: El empleado dueño de la solicitud o admin/rrhh
      allow read: if request.auth.uid == resource.data.userId || isAdminOrRRHH();
      
      // Crear: Solo Cloud Functions (auto-generadas)
      allow create: if false;  // Solo via Admin SDK
      
      // Actualizar: Solo admin/rrhh (para aprobar/rechazar)
      allow update: if isAdminOrRRHH();
      
      // Eliminar: Solo admin
      allow delete: if isAdmin();
    }
    
    // ========================================
    // SYSTEM CONFIG COLLECTION
    // ========================================
    
    match /system_config/{doc} {
      // Leer: Todos los autenticados
      allow read: if isAuthenticated();
      
      // Escribir: Solo admin
      allow write: if isAdmin();
    }
  }
}
```

---

## 📊 ÍNDICES COMPUESTOS NECESARIOS

```javascript
// Crear en Firebase Console → Firestore → Indexes

// 1. Para queries de registros por fecha (dashboard empleado)
Collection: users/{userId}/daily_records
- date (Descending)

// 2. Para queries de registros incompletos (panel admin)
Collection Group: daily_records
- status (Ascending)
- date (Descending)

// 3. Para queries de registros que requieren revisión
Collection Group: daily_records
- requiresReview (Ascending)
- date (Descending)

// 4. Para queries de horas extras pendientes (panel RRHH)
Collection: overtime_requests
- status (Ascending)
- createdAt (Descending)

// 5. Para queries de horas extras por usuario
Collection: overtime_requests
- userId (Ascending)
- status (Ascending)
- weekNumber (Descending)

// 6. Para queries de resúmenes mensuales
Collection: users/{userId}/monthly_summary
- month (Descending)
```

**Nota**: Firebase sugerirá crear índices automáticamente cuando ejecutes queries que los requieran.

---

## 💰 OPTIMIZACIÓN DE COSTOS

### Límites del Plan Gratuito

| Recurso | Límite Diario | Límite Mensual |

|---------|---------------|----------------|

| Reads | 50,000 | ~1,500,000 |

| Writes | 20,000 | ~600,000 |

| Deletes | 20,000 | ~600,000 |

| Storage | - | 1 GB |

| Network | - | 10 GB |

### Estimación de Uso

#### Writes

```
Fichajes diarios:
- 458 empleados × 1 documento/día = 458 writes/día
- Update de documento: 3 actualizaciones promedio/día = 1,374 writes/día
- Total: ~2,000 writes/día ✅ (10% del límite)

Mensual: ~44,000 writes/mes ✅
```

#### Reads

```
Pico matutino (9-10am):
- 229 empleados × 30 reads (cargar dashboard) = 6,870 reads/hora

Uso distribuido durante el día:
- 229 docentes × 20 reads (promedio) = 4,580 reads

Consultas admin/RRHH:
- 2 usuarios × 200 reads/día = 400 reads

Total: ~12,000 reads/día ✅ (24% del límite)
Mensual: ~360,000 reads/mes ✅
```

#### Storage

```
Registro por día: ~2 KB
458 empleados × 22 días × 12 meses × 3 años = 362,208 registros
362,208 × 2 KB = 724 MB ✅ (72% del límite de 1 GB)

Con archivado (solo 3 meses en Firestore):
458 × 22 × 3 = 30,228 registros
30,228 × 2 KB = 60 MB ✅ (6% del límite)
```

### Estrategias de Optimización

#### 1. **Caché Local Agresivo**

```dart
// Usar cached data cuando sea posible
FirebaseFirestore.instance
  .collection('users/$uid/daily_records')
  .doc(today)
  .get(GetOptions(source: Source.cache))  // Lee de caché primero
```

**Ahorro**: 60-80% de reads

#### 2. **Paginación Inteligente**

```dart
// Dashboard: Mostrar solo últimos 7 días por defecto
query.limit(7);

// Botón "Ver más" carga 30 días
query.limit(30).startAfterDocument(lastDocument);
```

**Ahorro**: 70% de reads en carga inicial

#### 3. **Resúmenes Pre-calculados**

```dart
// En vez de calcular totales del mes leyendo 22 documentos:
// Leer 1 documento de monthly_summary

// Ahorro: 22 reads → 1 read (95% menos)
```

#### 4. **Listeners Selectivos**

```dart
// NO escuchar toda la colección
// SÍ escuchar solo el documento de hoy

// ❌ MAL
db.collection('users/$uid/daily_records').snapshots()

// ✅ BIEN
db.collection('users/$uid/daily_records').doc(today).snapshots()
```

**Ahorro**: 90% de reads recurrentes

#### 5. **Archivado Automático**

- Registros > 3 meses → Cloud Storage
- Reduce storage en Firestore
- Reduce tiempo de queries

**Ahorro en Storage**: 90% (de 724 MB → 60 MB)

### Costos Proyectados

#### Escenario: Uso Optimizado (Con estrategias aplicadas)

```
Reads: ~12,000/día × 30 días = 360,000/mes ✅ GRATIS
Writes: ~2,000/día × 30 días = 60,000/mes ✅ GRATIS
Storage: 60 MB (Firestore) + 700 MB (Storage) ✅ GRATIS
```

**Costo mensual: $0** (dentro del plan gratuito)

#### Escenario: Uso Sin Optimizar (Sin estrategias)

```
Reads: ~35,000/día × 30 días = 1,050,000/mes
- Gratis: 1,500,000
- Exceso: 0 ✅ GRATIS (pero cerca del límite)

Writes: ~4,000/día × 30 días = 120,000/mes
- Gratis: 600,000 ✅ GRATIS

Storage: 724 MB ✅ GRATIS
```

**Costo mensual: $0** (pero riesgo de superar límite en picos)

#### Escenario: Crecimiento (600 empleados, sin optimizar)

```
Reads: 2,000,000/mes
- Gratis: 1,500,000
- Exceso: 500,000
- Costo: $0.18 (500K / 100K × $0.036)

Writes: 150,000/mes ✅ GRATIS
Storage: 900 MB ✅ GRATIS
```

**Costo mensual: ~$0.20** (muy bajo)

### Recomendación

✅ **Implementar estrategias de optimización desde Sprint 1**

✅ **Monitorear uso en Firebase Console**

✅ **Alertas si se supera 80% de límite diario**

---

## 🧪 ESTRATEGIA DE TESTING

### Niveles de Testing

#### 1. **Unit Tests**

```dart
// Providers
- AuthProvider (login, logout, state)
- ClockingProvider (fichar, validar secuencia)
- DashboardProvider (calcular totales)
- OvertimeProvider (aprobar, rechazar)

// Helpers
- TimeCalculation (calcular minutos trabajados)
- DateHelpers (formatear fechas, semana del año)
- ClockingStateMachine (transiciones de estado)

// Models
- User.fromJson() / toJson()
- DailyRecord.fromJson() / toJson()
- OvertimeRequest.fromJson() / toJson()
```

**Objetivo**: 80% de cobertura en lógica de negocio

#### 2. **Widget Tests**

```dart
// Screens
- LoginScreen (formulario, validación)
- DashboardScreen (mostrar datos, botones deshabilitados)
- AdminDashboardScreen (lista de empleados)

// Widgets
- ClockingButtons (estado de botones según ClockingState)
- RecordsTable (mostrar registros, paginación)
- OvertimeRequestCard (aprobar/rechazar)
```

**Objetivo**: 60% de cobertura en widgets críticos

#### 3. **Integration Tests**

```dart
// Flujos completos
- Login → Dashboard → Fichar → Logout
- Fichar día completo: Entrada → Pausa → Retorno → Salida
- Admin corrige fichaje → Verificar editHistory
- RRHH aprueba horas extras → Verificar estado cambiado
```

**Objetivo**: 5-10 flujos críticos cubiertos

#### 4. **Cloud Functions Tests**

```typescript
// functions/test/
- autoCloseRecords.test.ts
- detectOvertime.test.ts
- generateMonthlySummaries.test.ts
- archiveOldRecords.test.ts
```

**Herramientas**: Firebase Emulator Suite

### Entorno de Testing

#### Firebase Emulator Suite

```bash
# Instalar emuladores
firebase init emulators

# Seleccionar:
- Authentication
- Firestore
- Functions
- Storage

# Ejecutar
firebase emulators:start
```

**Beneficios**:

- ✅ Testing local sin costo
- ✅ Datos aislados de producción
- ✅ Rápido (sin latencia de red)

#### Test Data

```dart
// lib/core/constants/test_data.dart
class TestData {
  static User employeeUser = User(...);
  static User adminUser = User(...);
  static DailyRecord completeRecord = DailyRecord(...);
  static DailyRecord incompleteRecord = DailyRecord(...);
}
```

### CI/CD Pipeline

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
   - uses: actions/checkout@v2
      
      # Flutter tests
   - uses: subosito/flutter-action@v2
   - run: flutter pub get
   - run: flutter analyze
   - run: flutter test --coverage
      
      # Cloud Functions tests
   - uses: actions/setup-node@v2
   - run: cd functions && npm install
   - run: cd functions && npm test
      
      # Upload coverage
   - uses: codecov/codecov-action@v2
```

---

## 📦 DEPENDENCIAS ADICIONALES

### Flutter (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Fase 1 (existentes)
  flutter_riverpod: ^2.4.0
  google_fonts: ^6.1.0
  go_router: ^12.0.0
  intl: ^0.19.0
  
  # ✨ NUEVAS para Fase 2
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  
  # State Management
  riverpod_annotation: ^2.3.0
  
  # Utils
  freezed_annotation: ^2.4.1     # Para models immutables
  json_annotation: ^4.8.1        # Para serialización
  
  # PDF Generation
  pdf: ^3.10.0
  printing: ^5.11.0
  
  # Date/Time
  timezone: ^0.9.2
  
  # Logging
  logger: ^2.0.2

dev_dependencies:
  flutter_lints: ^3.0.0
  
  # ✨ NUEVAS
  build_runner: ^2.4.6           # Para code generation
  riverpod_generator: ^2.3.0
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  
  # Testing
  mockito: ^5.4.3
  fake_cloud_firestore: ^2.4.1+1
  firebase_auth_mocks: ^0.13.0
```

### Cloud Functions (package.json)

```json
{
  "name": "control-horario-functions",
  "engines": {
    "node": "18"
  },
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.5.0",
    "dayjs": "^1.11.10"
  },
  "devDependencies": {
    "@types/node": "^20.9.0",
    "typescript": "^5.2.2",
    "firebase-functions-test": "^3.1.0",
    "jest": "^29.7.0",
    "@types/jest": "^29.5.8"
  }
}
```

---

## 🚀 PLAN DE IMPLEMENTACIÓN

### Preparación (Antes de Sprint 1)

#### 1. Configurar Proyecto Firebase

- [ ] Crear proyecto en [Firebase Console](https://console.firebase.google.com)
- [ ] Habilitar Firebase Authentication
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                - [ ] Activar método Email/Password
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                - [ ] (Opcional) Activar Google Sign-In
- [ ] Crear Firestore Database
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                - [ ] Iniciar en **modo test** (cambiar a producción en Sprint 3)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                - [ ] Seleccionar región: `europe-west1`
- [ ] Habilitar Cloud Storage
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                - [ ] Crear bucket para archivado
- [ ] Habilitar Cloud Functions
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                - [ ] Actualizar plan a Blaze (pay-as-you-go, pero seguirá gratis con nuestro uso)

#### 2. Configurar Flutter con Firebase

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase en el proyecto
flutterfire configure

# Seguir wizard:
# - Seleccionar proyecto Firebase
# - Seleccionar plataformas (web, android, ios)
# - Generar archivos de configuración
```

#### 3. Poblar Datos Iniciales

```bash
# Script para crear usuarios de prueba
# functions/scripts/seedUsers.ts

# Crear:
# - 1 Admin
# - 1 RRHH
# - 10 Empleados de prueba
# - 2 Schedules (Jornada Estándar, Jornada Tarde)
```

#### 4. Configurar Emuladores

```bash
firebase init emulators

# Configurar puertos:
# - Auth: 9099
# - Firestore: 8080
# - Functions: 5001
# - Storage: 9199
```

### Cronograma

| Sprint | Duración | Fechas | Entregable |

|--------|----------|--------|------------|

| **Preparación** | 2 días | Nov 25-26 | Proyecto Firebase configurado |

| **Sprint 1** | 5 días | Nov 27 - Dic 1 | Login + Fichaje básico |

| **Sprint 2** | 5 días | Dic 2 - Dic 6 | Pausas + Validaciones |

| **Sprint 3** | 5 días | Dic 9 - Dic 13 | Panel Admin + Correcciones |

| **Sprint 4** | 5 días | Dic 16 - Dic 20 | Cierre automático + Horas extras |

| **Sprint 5** | 5 días | Ene 7 - Ene 10 | Reportes + Archivado |

| **Testing** | 3 días | Ene 13 - Ene 15 | Tests + Bug fixes |

| **Deploy** | 2 días | Ene 16 - Ene 17 | Producción |

**Total**: ~30 días laborables (~6 semanas)

---

## 📚 ESTRUCTURA DE ARCHIVOS FASE 2

### Archivos a Crear

```
lib/
├── core/
│   ├── services/
│   │   ├── firebase_service.dart              # ✨ Nuevo
│   │   └── auth_service.dart                  # ✨ Nuevo
│   └── utils/
│       ├── date_helpers.dart                  # ✨ Nuevo
│       ├── time_calculation.dart              # ✨ Nuevo
│       └── validators.dart                    # ✨ Nuevo
│
├── features/
│   ├── auth/
│   │   ├── models/
│   │   │   └── user_model.dart                # ✨ Nuevo
│   │   └── providers/
│   │       ├── auth_provider.dart             # ✨ Nuevo
│   │       └── auth_state_provider.dart       # ✨ Nuevo
│   │
│   ├── dashboard/
│   │   ├── models/
│   │   │   ├── daily_record_model.dart        # ✨ Nuevo
│   │   │   ├── monthly_summary_model.dart     # ✨ Nuevo
│   │   │   └── clocking_state.dart            # ✨ Nuevo
│   │   └── providers/
│   │       ├── clocking_provider.dart         # ✨ Nuevo
│   │       ├── clocking_state_provider.dart   # ✨ Nuevo
│   │       ├── dashboard_provider.dart        # ✨ Nuevo
│   │       └── time_calculation_provider.dart # ✨ Nuevo
│   │
│   └── admin/
│       ├── models/
│       │   ├── overtime_request_model.dart    # ✨ Nuevo
│       │   └── schedule_model.dart            # ✨ Nuevo
│       └── providers/
│           ├── admin_employees_provider.dart  # ✨ Nuevo
│           ├── admin_clocking_provider.dart   # ✨ Nuevo
│           ├── anomalies_provider.dart        # ✨ Nuevo
│           ├── overtime_provider.dart         # ✨ Nuevo
│           └── reports_provider.dart          # ✨ Nuevo
│
├── main.dart                                  # 🔄 Actualizar (Firebase init)
└── app.dart                                   # 🔄 Actualizar (Providers)

functions/
├── src/
│   ├── index.ts                               # ✨ Nuevo
│   ├── autoCloseRecords.ts                    # ✨ Nuevo
│   ├── detectOvertime.ts                      # ✨ Nuevo
│   ├── generateMonthlySummaries.ts            # ✨ Nuevo
│   └── archiveOldRecords.ts                   # ✨ Nuevo
├── test/
│   └── (tests para functions)                 # ✨ Nuevo
├── package.json                               # ✨ Nuevo
└── tsconfig.json                              # ✨ Nuevo

firestore.rules                                # ✨ Nuevo
firestore.indexes.json                         # ✨ Nuevo
storage.rules                                  # ✨ Nuevo
firebase.json                                  # ✨ Nuevo (config)
```

**Total de archivos nuevos**: ~35

**Archivos a actualizar**: ~15 (pantallas para conectar providers)

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Preparación

- [ ] Crear proyecto Firebase
- [ ] Configurar Authentication (Email/Password)
- [ ] Crear Firestore Database (modo test)
- [ ] Habilitar Cloud Storage
- [ ] Habilitar Cloud Functions (plan Blaze)
- [ ] Ejecutar `flutterfire configure`
- [ ] Configurar emuladores locales
- [ ] Poblar datos de prueba (script)

### Sprint 1: MVP

- [ ] Implementar `AuthService`
- [ ] Implementar `AuthProvider` (Riverpod)
- [ ] Conectar `LoginScreen` con Firebase Auth
- [ ] Proteger rutas (redirect si no autenticado)
- [ ] Implementar `UserModel`
- [ ] Implementar `DailyRecordModel`
- [ ] Implementar `ClockingProvider`
- [ ] Conectar botones de fichaje con Firestore
- [ ] Implementar `DashboardProvider`
- [ ] Mostrar registros del mes en dashboard
- [ ] Crear reglas de seguridad básicas
- [ ] Tests unitarios (Auth, Clocking)
- [ ] Test de integración (Login → Fichar → Logout)

### Sprint 2: Pausas

- [ ] Actualizar `DailyRecordModel` (agregar pausas)
- [ ] Implementar `ClockingState` (enum)
- [ ] Implementar `ClockingStateProvider`
- [ ] Actualizar botones (deshabilitar según estado)
- [ ] Implementar `TimeCalculationProvider`
- [ ] Calcular minutos trabajados (incluye pausas)
- [ ] Implementar diálogo de confirmación (salida anticipada)
- [ ] Tests unitarios (State machine, Cálculos)
- [ ] Test de integración (Flujo completo con pausa)

### Sprint 3: Admin

- [ ] Implementar `AdminEmployeesProvider`
- [ ] Implementar lista de empleados (filtros, búsqueda)
- [ ] Implementar `AdminClockingProvider`
- [ ] Modal de corrección de fichaje
- [ ] Guardar `editHistory` en registros
- [ ] Implementar `AnomaliesProvider`
- [ ] Panel de anomalías
- [ ] Actualizar reglas de seguridad (admin puede todo)
- [ ] Tests unitarios (Admin providers)
- [ ] Test de integración (Admin corrige fichaje)

### Sprint 4: Automatización

- [ ] Implementar `ScheduleModel`
- [ ] Crear colección `schedules` con datos de prueba
- [ ] Actualizar `UserModel` (agregar `scheduleId`)
- [ ] Implementar `OvertimeRequestModel`
- [ ] Implementar `OvertimeProvider`
- [ ] Panel de horas extras (RRHH/Admin)
- [ ] Botones aprobar/rechazar
- [ ] Crear Cloud Function: `autoCloseRecords`
- [ ] Crear Cloud Function: `detectOvertime`
- [ ] Deploy de functions
- [ ] Probar functions en emulador
- [ ] Tests de functions

### Sprint 5: Reportes

- [ ] Implementar `MonthlySummaryModel`
- [ ] Crear Cloud Function: `generateMonthlySummaries`
- [ ] Implementar `ReportsProvider`
- [ ] Pantalla de reportes (filtros)
- [ ] Gráficos de horas trabajadas
- [ ] Implementar `PDFExportProvider`
- [ ] Generación de PDF
- [ ] Crear Cloud Function: `archiveOldRecords`
- [ ] Implementar `ArchivedRecordsProvider`
- [ ] Consulta de registros archivados
- [ ] Tests de reportes y PDF

### Testing Final

- [ ] Ejecutar todos los tests (unit + widget + integration)
- [ ] Cobertura > 70%
- [ ] Pruebas manuales de todos los flujos
- [ ] Pruebas de performance (carga de 100+ registros)
- [ ] Pruebas de seguridad (intentar acceso no autorizado)

### Deploy

- [ ] Actualizar reglas de seguridad (modo producción)
- [ ] Crear índices compuestos en Firestore
- [ ] Configurar alertas de cuota en Firebase Console
- [ ] Deploy de Cloud Functions a producción
- [ ] Build de Flutter Web (`flutter build web --release`)
- [ ] Deploy a Firebase Hosting
- [ ] Pruebas en producción
- [ ] Monitorear logs y errores

---

## 🎯 OBJETIVOS DE FASE 2

### Funcionales

- ✅ Login y autenticación real con Firebase
- ✅ Sistema de fichaje completo (Entrada/Pausa/Retorno/Salida)
- ✅ Validaciones de secuencia y máquina de estados
- ✅ Panel admin funcional (ver todos, corregir fichajes)
- ✅ Cierre automático de fichajes olvidados
- ✅ Sistema de aprobación de horas extras
- ✅ Reportes mensuales por empleado
- ✅ Exportación a PDF
- ✅ Archivado automático de registros antiguos

### Técnicos

- ✅ Firebase Authentication implementado
- ✅ Firestore con estructura escalable
- ✅ Riverpod providers funcionales
- ✅ Cloud Functions automatizadas
- ✅ Reglas de seguridad robustas
- ✅ Optimización de costos (plan gratuito)
- ✅ Tests con >70% de cobertura
- ✅ Código limpio y mantenible

### Negocio

- ✅ Sistema usable por los 458 empleados
- ✅ Admin y RRHH pueden gestionar empleados
- ✅ Cumple con requisitos de auditoría (histórico 4 años)
- ✅ Escalable para crecimiento futuro
- ✅ Costo mínimo (plan gratuito)

---

## 🔮 FASE 3: FUTURAS MEJORAS (No incluidas en Fase 2)

### Features Adicionales

- 📍 **Geolocalización**: Registrar ubicación GPS en fichajes
- 📱 **App Móvil Nativa**: Versión Android/iOS
- 👤 **Reconocimiento Facial**: Verificación biométrica
- 📅 **Gestión de Vacaciones**: Solicitudes y aprobaciones
- 📝 **Permisos y Bajas**: Gestión de ausencias
- 📊 **Dashboard Analítico**: Gráficos avanzados con charts
- 🔔 **Notificaciones Push**: Recordatorios de fichaje
- 📧 **Notificaciones Email**: Resúmenes semanales
- 🏢 **Multi-empresa**: Soporte para múltiples instituciones
- 🌐 **Multi-idioma**: i18n (inglés, catalán)
- 🎨 **Temas**: Dark mode
- 📤 **Exportar Excel**: Además de PDF
- 🔍 **Búsqueda Avanzada**: Filtros complejos en reportes
- 📈 **Predicciones**: ML para detectar patrones

### Optimizaciones Técnicas

- ⚡ **Offline Support**: App funcional sin internet
- 🔄 **Sync Incremental**: Solo sincronizar cambios
- 📦 **PWA**: Progressive Web App con install prompt
- 🚀 **Performance**: Lazy loading, code splitting
- 🔐 **2FA**: Autenticación de dos factores
- 📱 **Responsive Mejorado**: Tablet mode optimizado

---

## 📝 NOTAS FINALES

### Decisiones Tomadas

1. ✅ **1 pausa por día** (simplifica lógica y reduce writes)
2. ✅ **1 documento por día** (vs 1 por fichaje) - optimiza queries
3. ✅ **Horas extras necesitan aprobación** (RRHH o Admin)
4. ✅ **Cierre automático marcado como anomalía** (requiere revisión)
5. ✅ **Cloud Storage para archivado** (más barato que Firestore)
6. ✅ **Salida anticipada: warning si faltan >1 hora**
7. ✅ **Empleado solo edita entrada, mismo día, sin aprobación**
8. ✅ **Admin edita todo, con historial de cambios**

### Flexibilidad de Firebase

- ✅ **Estructura evolutiva**: Empezamos simple, agregamos campos según avancemos
- ✅ **No necesita schema rígido**: Fácil agregar/quitar campos
- ⚠️ **Planear colecciones bien**: Difícil cambiar estructura base después
- ✅ **Desarrollo iterativo**: Sprint por sprint, testeando en real

### Próximos Pasos

1. **Confirmar** que la planificación cubre todos los requisitos
2. **Hacer preguntas** si algo no está claro
3. **Iniciar Sprint 1**: Configurar Firebase → Implementar MVP
4. **Iterar**: Feedback después de cada Sprint

---

**Equipo**: Control Horario - Escuela de Música

**Documento**: Planificación Fase 2

**Versión**: 2.0.0-planning

**Estado**: 🚧 Pendiente de Aprobación

**Fecha**: Noviembre 2025

---

## ❓ ¿Listo para Empezar?

Una vez apruebes esta planificación, procederemos con:

1. **Configuración de Firebase** (Preparación)
2. **Implementación de Sprint 1** (MVP)
3. **Iteraciones** hasta completar Fase 2

**¿Alguna duda o ajuste a la planificación?** 🚀