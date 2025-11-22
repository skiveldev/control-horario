# ðŸ“‹ FASE 2 - PLANIFICACIÃ“N COMPLETA

## Backend + LÃ³gica + Firebase

**Proyecto**: Sistema de Control Horario - Escuela de MÃºsica

**Estado**: ðŸš§ En PlanificaciÃ³n

**VersiÃ³n**: 2.0.0-planning

**Fecha**: Noviembre 2025

---

## ðŸ“Š Contexto del Proyecto

### âœ… Fase 1 Completada

- UI/UX completo con datos mock
- 8 pantallas implementadas
- Sistema de diseÃ±o completo
- NavegaciÃ³n con go_router
- **50 archivos** creados (~8,000 lÃ­neas)

### ðŸŽ¯ Objetivo Fase 2

Implementar **backend funcional** con Firebase y lÃ³gica de negocio real, reemplazando todos los datos mock.

---

## ðŸ¢ Requisitos del Cliente

### Datos de la Escuela

- **Empleados**: 458 (docentes + no docentes)
- **Todos fichan**: Sin excepciones
- **Contratos**: Todos fijos (horarios variables por empleado)
- **HistÃ³rico**: Conservar 4 aÃ±os de registros

### Sistema de Fichaje

```
Flujo del dÃ­a:
1. ENTRADA (obligatoria)
2. PAUSA (opcional, solo 1 vez)
3. RETORNO (si hubo pausa)
4. SALIDA (obligatoria)

Reglas:
- Solo 1 pausa permitida por dÃ­a
- Pausa cuenta como tiempo trabajado
- Fichaje remoto permitido (docentes + trabajo remoto)
- GeolocalizaciÃ³n: nice-to-have (auditorÃ­as futuras)
```

### Roles de Usuario

| Rol | Permisos | Cantidad |

|-----|----------|----------|

| **Empleado** | - Ver sus propios registros<br>- Fichar entrada/pausa/retorno/salida<br>- Editar solo ENTRADA (mismo dÃ­a) | 456 |

| **RRHH** | - Ver todos los empleados<br>- Generar reportes<br>- Exportar PDF<br>- Gestionar horarios<br>- Aprobar horas extras | 1 |

| **Admin** | - Todo lo de RRHH +<br>- Crear/eliminar usuarios<br>- Corregir cualquier fichaje<br>- ConfiguraciÃ³n del sistema | 1 |

### Reglas de Negocio

1. **ValidaciÃ³n de secuencia**: No permitir fichajes fuera de orden
2. **EdiciÃ³n de empleado**: Solo entrada, solo mismo dÃ­a, sin aprobaciÃ³n
3. **EdiciÃ³n de admin**: Cualquier fichaje, cualquier fecha, con historial
4. **Cierre automÃ¡tico**: Si olvida fichar salida â†’ cierre a fin de horario contratado
5. **Horas extras**: Requieren aprobaciÃ³n de RRHH o Admin
6. **Salida anticipada**: DiÃ¡logo de confirmaciÃ³n si faltan >1 hora

### Reportes Requeridos

- Horas mensuales por empleado
- Horas extras (pendientes/aprobadas/rechazadas)
- AnomalÃ­as (fichajes incompletos, auto-cerrados)
- ExportaciÃ³n a PDF

### Restricciones TÃ©cnicas

- **Budget**: Plan gratuito Firebase inicialmente
- **Performance**: Tiempo real no crÃ­tico (delay de minutos aceptable)
- **Archivado**: Mantener 3 meses accesibles, resto archivado
- **Escalabilidad**: Preparado para crecimiento futuro

### Stack TÃ©cnico (Fase 2)

- **State Management**: **Riverpod** (Ãºnico y oficial del proyecto)
    - NO usar `setState`, `InheritedWidget`, `Provider`, o `BLoC`
    - TODO el estado se maneja con Riverpod
    - Widgets consumen datos SOLO vÃ­a Riverpod providers
    - Code generation con `riverpod_generator` + `freezed`
- **Backend**: Firebase (Auth, Firestore, Functions, Storage)
- **NavegaciÃ³n**: go_router (ya implementado en Fase 1)
- **UI**: Material Design 3 + Custom Theme (ya implementado en Fase 1)

---

## ðŸ—„ï¸ DISEÃ‘O DE BASE DE DATOS FIREBASE

### Estructura de Colecciones

```
firestore/
â”œâ”€â”€ users/    # ColecciÃ³n principal
â”‚   â””â”€â”€ {userId}/    # Documento por usuario
â”‚       â”œâ”€â”€ (campos del perfil)
â”‚       â”œâ”€â”€ daily_records/    # SubcolecciÃ³n de fichajes
â”‚       â”‚   â””â”€â”€ {YYYY-MM-DD}/                 # 1 documento por dÃ­a
â”‚       â”‚       â”œâ”€â”€ clocks (objeto)
â”‚       â”‚       â””â”€â”€ metadata
â”‚       â””â”€â”€ monthly_summary/                  # SubcolecciÃ³n de resÃºmenes
â”‚           â””â”€â”€ {YYYY-MM}/    # 1 documento por mes
â”‚               â””â”€â”€ (totales pre-calculados)
â”‚
â”œâ”€â”€ schedules/    # ColecciÃ³n de horarios
â”‚   â””â”€â”€ {scheduleId}/
â”‚       â””â”€â”€ (configuraciÃ³n de horario)
â”‚
â”œâ”€â”€ overtime_requests/    # ColecciÃ³n de horas extras
â”‚   â””â”€â”€ {requestId}/
â”‚       â””â”€â”€ (solicitud de aprobaciÃ³n)
â”‚
â””â”€â”€ system_config/    # ColecciÃ³n de configuraciÃ³n
    â””â”€â”€ settings/    # Documento Ãºnico
        â””â”€â”€ (reglas globales del sistema)
```

---

## ðŸ—ï¸ ARQUITECTURA DE STATE MANAGEMENT

### Principio: Riverpod para TODO

**REGLA FUNDAMENTAL**: Todo el estado de la aplicaciÃ³n se gestiona exclusivamente con **Riverpod**.

#### âŒ NO Usar para Estado de AplicaciÃ³n:

- `setState()` para estado que afecta otros widgets o lÃ³gica de negocio
- `InheritedWidget` o `InheritedNotifier`
- `Provider` package (antiguo)
- `BLoC` pattern
- `GetX` o cualquier otro state management
- Variables globales o singletons con estado mutable

#### âš ï¸ ExcepciÃ³n Permitida:

âœ… `setState()` SOLO para UI local que NO afecta otros widgets:

- Estado de TextField antes de enviar
- Estado de Checkbox/Switch local
- Animaciones puramente visuales
- Hover states, focus states
- ExpansiÃ³n/colapso de widgets locales

**Regla**: Si el estado NO sale del widget â†’ `setState` OK. Si sale â†’ Riverpod obligatorio.

#### âœ… SÃ Usar:

- **Riverpod Providers** para todo el estado
- **ConsumerWidget** o **ConsumerStatefulWidget** para widgets que consumen estado
- **Consumer** o **ref.watch()** para escuchar cambios
- **ref.read()** solo en callbacks (nunca en build)
- **Code generation** con `riverpod_generator` y `freezed`

### PatrÃ³n de Arquitectura

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚           UI Layer (Widgets)            â”‚
â”‚   - ConsumerWidget / ConsumerStateful   â”‚
â”‚   - NO lÃ³gica de negocio                â”‚
â”‚   - Solo presentaciÃ³n                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚ ref.watch() / ref.listen()
               â†“
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚      Providers Layer (Riverpod)         â”‚
â”‚   - Stream/Future/State Providers       â”‚
â”‚   - LÃ³gica de negocio                   â”‚
â”‚   - Transformaciones de datos           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
               â”‚ llama
               â†“
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚       Services Layer (Firebase)         â”‚
â”‚   - FirebaseAuth    â”‚
â”‚   - Firestore queries                   â”‚
â”‚   - Cloud Functions calls               â”‚
â”‚   - Storage operations                  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Ejemplo Completo

```dart
// âŒ INCORRECTO - No usar setState para estado de aplicaciÃ³n
class DashboardScreenOld extends StatefulWidget {
  @override
  State<DashboardScreenOld> createState() => _DashboardScreenOldState();
}

class _DashboardScreenOldState extends State<DashboardScreenOld> {
  List<DailyRecord> records = []; // âŒ Estado que afecta toda la pantalla
  
  @override
  void initState() {
    super.initState();
    loadRecords(); // âŒ NO
  }
  
  void loadRecords() async {
    final data = await FirebaseFirestore.instance
        .collection('users/$uid/daily_records')
        .get();
    setState(() { // âŒ NO USAR setState para estado de aplicaciÃ³n
      records = data.docs.map((doc) => DailyRecord.fromJson(doc.data())).toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(...); // âŒ MAL
  }
}

// âš ï¸ EXCEPCIÃ“N VÃLIDA - setState para UI local
class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  
  const SearchBarWidget({required this.onSearch});
  
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  String _searchText = ''; // âœ… Estado local del widget
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        setState(() => _searchText = value); // âœ… OK: UI local
      },
      onSubmitted: (value) {
        widget.onSearch(value); // Solo aquÃ­ sale del widget
      },
    );
  }
}

// âœ… CORRECTO - Usar Riverpod
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
      data: (records) => ListView.builder(...), // âœ… BIEN
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

2. **FutureProvider**: Para operaciones asÃ­ncronas de una vez
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

4. **NotifierProvider**: Para estado complejo con mÃ©todos
```dart
@riverpod
class ClockingNotifier extends _$ClockingNotifier {
  @override
  ClockingState build() => ClockingState.notStarted();
  
  Future<void> clockIn() async {
    // LÃ³gica de fichaje
    state = ClockingState.working();
  }
  
  Future<void> clockOut() async {
    // LÃ³gica de fichaje
    state = ClockingState.finished();
  }
}
```


### Reglas de Uso

1. **En widgets (build method)**:

    - âœ… Usar `ref.watch()` para escuchar cambios
    - âŒ NUNCA usar `ref.read()` en build

2. **En callbacks (onPressed, onChanged)**:

    - âœ… Usar `ref.read()` para ejecutar acciones
    - âœ… Usar `ref.invalidate()` para refrescar datos

3. **En providers**:

    - âœ… Usar `ref.watch()` para depender de otros providers
    - âœ… Usar `ref.read()` para llamar mÃ©todos

4. **Dependencias**:

    - âœ… Providers pueden depender de otros providers
    - âœ… Auto-refetch cuando dependencias cambian
    - âœ… Auto-dispose cuando no se usan

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

1. **Reactive**: UI se actualiza automÃ¡ticamente cuando datos cambian
2. **Testeable**: FÃ¡cil mockear providers en tests
3. **Type-safe**: Errores en compile-time, no runtime
4. **Performance**: Auto-dispose y cachÃ© inteligente
5. **Developer Experience**: Code generation reduce boilerplate
6. **Debuggeable**: Riverpod DevTools para inspeccionar estado
7. **Escalable**: FÃ¡cil agregar nuevos providers sin refactorizar

---

## ðŸ“ ESPECIFICACIONES POR SPRINT

### ðŸŽ¯ Sprint 1: MVP - Core BÃ¡sico (Semana 1)

**Objetivo**: Login funcional + Fichaje bÃ¡sico Entrada/Salida

#### Colecciones a Implementar

##### 1. Collection: `users`

```typescript
// Documento: /users/{userId}
interface User {
  // IdentificaciÃ³n
  userId: string;              // Firebase Auth UID
  employeeId: string;          // ID interno ("EMP-001")
  email: string;
  displayName: string;
  
  // InformaciÃ³n Laboral
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
  // IdentificaciÃ³n
  date: string;                // "2025-11-20" (YYYY-MM-DD)
  userId: string;
  
  // Fichajes (Sprint 1: solo in/out)
  clocks: {
    clockIn: string | null;     // "08:30:00" (HH:mm:ss)
    clockOut: string | null;    // "17:00:00" o null si no fichÃ³
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
    clockOut: null              // AÃºn no fichÃ³ salida
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
    allowLateClockOut: number;  // 15 minutos despuÃ©s
  };
  
  updatedAt: Timestamp;
  updatedBy: string;            // uid del admin
}
```

#### Funcionalidades Sprint 1

**AutenticaciÃ³n**:

- [x] Login con Firebase Auth (email/password)
- [x] Logout
- [x] ProtecciÃ³n de rutas (redirect si no autenticado)
- [x] Provider: `AuthProvider` (Riverpod)

**Fichaje**:

- [x] BotÃ³n "Fichar Entrada" â†’ Crea documento en `daily_records/{today}`
- [x] BotÃ³n "Fichar Salida" â†’ Actualiza documento con `clockOut`
- [x] Mostrar estado actual (sin fichar / en trabajo)
- [x] Provider: `ClockingProvider` (Riverpod)

**Dashboard**:

- [x] Mostrar fichajes del mes actual
- [x] Calcular total horas del dÃ­a
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
      
      // SubcolecciÃ³n de fichajes
      match /daily_records/{recordId} {
        // Leer: El propio usuario o admin/rrhh
        allow read: if isOwner(userId) || isAdmin() || isRRHH();
        
        // Crear: El propio usuario (fichaje)
        allow create: if isOwner(userId);
        
        // Actualizar: El propio usuario (solo mismo dÃ­a) o admin
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

**Nota**: `getToday()` es funciÃ³n helper a implementar en el cliente, no en reglas.

#### Ãndices Compuestos Sprint 1

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
- DailySummaryProvider (Computed del dÃ­a actual)
- MonthlySummaryProvider (Computed del mes actual)
```

#### Testing Sprint 1

```dart
// Unit Tests
- AuthProvider tests
- ClockingProvider tests
- CÃ¡lculo de horas trabajadas

// Widget Tests
- LoginScreen con providers mock
- DashboardScreen con datos de prueba

// Integration Tests
- Flujo completo: Login â†’ Fichar â†’ Ver dashboard â†’ Logout
```

---

### ðŸŽ¯ Sprint 2: Pausas + Validaciones (Semana 2)

**Objetivo**: AÃ±adir sistema de pausas + mÃ¡quina de estados

#### Cambios en Estructura

##### Actualizar: `daily_records`

```typescript
interface DailyRecord {
  date: string;
  userId: string;
  
  // âœ¨ NUEVO: Agregar pausas
  clocks: {
    clockIn: string | null;
    breakStart: string | null;    // âœ¨ Sprint 2
    breakEnd: string | null;      // âœ¨ Sprint 2
    clockOut: string | null;
  };
  
  clockInTimestamp: Timestamp | null;
  breakStartTimestamp: Timestamp | null;    // âœ¨ Sprint 2
  breakEndTimestamp: Timestamp | null;      // âœ¨ Sprint 2
  clockOutTimestamp: Timestamp | null;
  
  // âœ¨ NUEVO: CÃ¡lculos
  totalWorkedMinutes: number | null;        // âœ¨ Sprint 2
  breakDurationMinutes: number | null;      // âœ¨ Sprint 2
  
  status: 'incomplete' | 'complete';
  
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

#### Funcionalidades Sprint 2

**MÃ¡quina de Estados**:

```typescript
enum ClockingState {
  NOT_STARTED,    // Inicio del dÃ­a â†’ Solo ENTRADA disponible
  WORKING,        // FichÃ³ entrada â†’ PAUSA o SALIDA disponibles
  ON_BREAK,       // FichÃ³ pausa â†’ Solo RETORNO disponible
  RETURNED,       // FichÃ³ retorno â†’ PAUSA o SALIDA disponibles (= WORKING)
  FINISHED        // FichÃ³ salida â†’ Nada disponible
}
```

**Validaciones**:

- [x] Deshabilitar botones segÃºn estado actual
- [x] Prevenir fichajes fuera de secuencia
- [x] DiÃ¡logo de confirmaciÃ³n en salida anticipada (falta >1h)
- [x] Provider: `ClockingStateProvider` (Riverpod)

**CÃ¡lculos**:

- [x] Calcular minutos trabajados (incluye pausas)
- [x] Calcular duraciÃ³n de pausa
- [x] Actualizar `totalWorkedMinutes` al fichar salida
- [x] Provider: `TimeCalculationProvider` (Riverpod)

#### Testing Sprint 2

```dart
// Unit Tests
- MÃ¡quina de estados (todas las transiciones)
- ValidaciÃ³n de secuencia de fichajes
- CÃ¡lculo de minutos trabajados

// Widget Tests
- Botones deshabilitados segÃºn estado
- DiÃ¡logo de confirmaciÃ³n en salida anticipada

// Integration Tests
- Flujo completo con pausa: Entrada â†’ Pausa â†’ Retorno â†’ Salida
- Intentar fichar fuera de orden (debe fallar)
```

---

### ðŸŽ¯ Sprint 3: Panel Admin + Correcciones (Semana 3)

**Objetivo**: Admin puede ver todos los empleados y corregir fichajes

#### Cambios en Estructura

##### Actualizar: `daily_records`

```typescript
interface DailyRecord {
  // ... campos anteriores
  
  // âœ¨ NUEVO: Historial de ediciones
  editHistory: Array<{
    field: string;              // "clockIn" | "clockOut" | etc.
    oldValue: string | null;
    newValue: string | null;
    editedBy: string;           // uid del editor
    editedByRole: string;       // "employee" | "admin"
    editedAt: Timestamp;
    reason?: string;            // Opcional: motivo de correcciÃ³n
  }> | null;    // âœ¨ Sprint 3
  
  // âœ¨ NUEVO: Flag de correcciÃ³n
  wasEdited: boolean;           // âœ¨ Sprint 3
  lastEditedAt: Timestamp | null; // âœ¨ Sprint 3
}
```

#### Funcionalidades Sprint 3

**Panel Admin**:

- [x] Lista de todos los empleados
- [x] Filtrar por departamento/rol/estado
- [x] Buscar por nombre/ID
- [x] Ver detalle de empleado
- [x] Provider: `AdminEmployeesProvider` (Riverpod)

**CorrecciÃ³n de Fichajes**:

- [x] Admin puede editar cualquier campo de cualquier fecha
- [x] Modal de confirmaciÃ³n con campo "motivo"
- [x] Guardar en `editHistory` cada cambio
- [x] Marcar registro como editado (`wasEdited: true`)
- [x] Provider: `AdminClockingProvider` (Riverpod)

**Lista de AnomalÃ­as**:

- [x] Query de registros con `status: "incomplete"`
- [x] Mostrar en panel admin
- [x] BotÃ³n para corregir desde lista
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
- AdminEmployeesProvider (filtros, bÃºsqueda)
- Historial de ediciones (agregar, formatear)

// Widget Tests
- Lista de empleados con filtros
- Modal de correcciÃ³n de fichaje

// Integration Tests
- Admin corrige fichaje â†’ Se guarda en editHistory
- Empleado intenta editar campo prohibido â†’ Falla
```

---

### ðŸŽ¯ Sprint 4: Cierre AutomÃ¡tico + Horas Extras (Semana 4)

**Objetivo**: Automatizar cierres + sistema de aprobaciÃ³n de horas extras

#### Nuevas Colecciones

##### 1. Collection: `schedules`

```typescript
// Documento: /schedules/{scheduleId}
interface Schedule {
  scheduleId: string;           // "schedule_standard"
  name: string;                 // "Jornada EstÃ¡ndar"
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
  
  // AprobaciÃ³n
  reviewedBy: string | null;    // uid de quien aprobÃ³
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
  
  scheduleId: string;           // âœ¨ Ahora se usa (Sprint 4)
}
```

##### Actualizar: `daily_records`

```typescript
interface DailyRecord {
  // ... campos anteriores
  
  // âœ¨ NUEVO: Cierre automÃ¡tico
  autoClosedAt: string | null;      // âœ¨ Sprint 4
  wasAutoClosed: boolean;           // âœ¨ Sprint 4
  requiresReview: boolean;          // âœ¨ Sprint 4 (anomalÃ­a)
}
```

#### Funcionalidades Sprint 4

**Cierre AutomÃ¡tico**:

- [x] Cloud Function diaria (ejecuta a medianoche)
- [x] Query registros `status: "incomplete"` del dÃ­a anterior
- [x] Obtener horario del empleado (`schedules`)
- [x] Cerrar con `clockOut: endTime` del horario
- [x] Marcar `wasAutoClosed: true`, `requiresReview: true`
- [x] **Archivo**: `functions/src/autoCloseRecords.ts`

**DetecciÃ³n de Horas Extras**:

- [x] Cloud Function semanal (ejecuta domingo 23:59)
- [x] Calcular total minutos trabajados de la semana
- [x] Comparar con `weeklyHours` contratadas
- [x] Si hay diferencia > 0 â†’ Crear `overtime_request` con `status: "pending"`
- [x] **Archivo**: `functions/src/detectOvertime.ts`

**AprobaciÃ³n de Horas Extras**:

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

// Cloud Function: Cierre automÃ¡tico diario
export const autoCloseRecords = functions.pubsub
  .schedule('0 0 * * *')  // Cada dÃ­a a medianoche
  .timeZone('Europe/Madrid')
  .onRun(async (context) => {
    // LÃ³gica de cierre automÃ¡tico
  });

// Cloud Function: DetecciÃ³n de horas extras semanal
export const detectOvertime = functions.pubsub
  .schedule('59 23 * * 0')  // Domingos a las 23:59
  .timeZone('Europe/Madrid')
  .onRun(async (context) => {
    // LÃ³gica de detecciÃ³n de horas extras
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
- Modal de aprobaciÃ³n/rechazo

// Integration Tests
- Simular dÃ­a sin fichar salida â†’ Verificar cierre automÃ¡tico
- Simular semana con horas extras â†’ Verificar creaciÃ³n de solicitud
```

---

### ðŸŽ¯ Sprint 5: Reportes + Archivado (Semana 5)

**Objetivo**: GeneraciÃ³n de reportes + archivado de registros antiguos

#### Nueva ColecciÃ³n

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
  
  // Extras y anomalÃ­as
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

**GeneraciÃ³n de ResÃºmenes Mensuales**:

- [x] Cloud Function mensual (ejecuta dÃ­a 1 de cada mes)
- [x] Para cada usuario: calcular totales del mes anterior
- [x] Guardar en `monthly_summary/{YYYY-MM}`
- [x] **Archivo**: `functions/src/generateMonthlySummaries.ts`

**Reportes**:

- [x] Pantalla de reportes (RRHH/Admin)
- [x] Filtros: Empleado, Mes, Departamento
- [x] Mostrar datos de `monthly_summary`
- [x] GrÃ¡ficos: horas trabajadas por semana
- [x] Provider: `ReportsProvider` (Riverpod)

**ExportaciÃ³n a PDF**:

- [x] BotÃ³n "Exportar PDF" en pantalla de reportes
- [x] Usar librerÃ­a `pdf` de Flutter
- [x] Generar PDF con:
    - Encabezado con logo escuela
    - Tabla de fichajes del mes
    - Totales y promedios
    - AnomalÃ­as destacadas
- [x] Descargar archivo
- [x] Provider: `PDFExportProvider` (Riverpod)

**Archivado de Registros**:

- [x] Cloud Function mensual (ejecuta dÃ­a 1 de cada mes)
- [x] Query registros con `date < (hoy - 90 dÃ­as)`
- [x] Exportar a JSON comprimido
- [x] Subir a Cloud Storage: `gs://bucket/archive/{YYYY-MM}.json.gz`
- [x] Eliminar de Firestore
- [x] **Archivo**: `functions/src/archiveOldRecords.ts`

**Consulta de Archivados**:

- [x] FunciÃ³n helper para leer archivos de Storage
- [x] BotÃ³n "Ver histÃ³rico completo" (para admin/rrhh)
- [x] Descargar JSON de Storage y parsear
- [x] Mostrar en tabla (lectura lenta, warning de performance)
- [x] Provider: `ArchivedRecordsProvider` (Riverpod)

#### Cloud Functions Sprint 5

```typescript
// functions/src/index.ts

// Cloud Function: Generar resÃºmenes mensuales
export const generateMonthlySummaries = functions.pubsub
  .schedule('0 2 1 * *')  // DÃ­a 1 de cada mes a las 2am
  .timeZone('Europe/Madrid')
  .onRun(async (context) => {
    // LÃ³gica de generaciÃ³n de resÃºmenes
  });

// Cloud Function: Archivar registros antiguos
export const archiveOldRecords = functions.pubsub
  .schedule('0 3 1 * *')  // DÃ­a 1 de cada mes a las 3am
  .timeZone('Europe/Madrid')
  .onRun(async (context) => {
    // LÃ³gica de archivado
  });
```

#### Testing Sprint 5

```dart
// Unit Tests (Cloud Functions)
- generateMonthlySummaries (mockear Firestore)
- archiveOldRecords (mockear Firestore + Storage)

// Unit Tests (Flutter)
- ReportsProvider (filtros, queries)
- PDFExportProvider (generaciÃ³n de PDF)

// Widget Tests
- Pantalla de reportes con filtros
- VisualizaciÃ³n de resÃºmenes mensuales

// Integration Tests
- Generar reporte â†’ Exportar PDF â†’ Verificar descarga
- Consultar registros archivados â†’ Verificar lectura de Storage
```

---

## ðŸ” REGLAS DE SEGURIDAD COMPLETAS

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
      // Esta funciÃ³n es solo ilustrativa
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
            // Solo clockIn cambiÃ³
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
      // Leer: El empleado dueÃ±o de la solicitud o admin/rrhh
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

## ðŸ“Š ÃNDICES COMPUESTOS NECESARIOS

```javascript
// Crear en Firebase Console â†’ Firestore â†’ Indexes

// 1. Para queries de registros por fecha (dashboard empleado)
Collection: users/{userId}/daily_records
- date (Descending)

// 2. Para queries de registros incompletos (panel admin)
Collection Group: daily_records
- status (Ascending)
- date (Descending)

// 3. Para queries de registros que requieren revisiÃ³n
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

// 6. Para queries de resÃºmenes mensuales
Collection: users/{userId}/monthly_summary
- month (Descending)
```

**Nota**: Firebase sugerirÃ¡ crear Ã­ndices automÃ¡ticamente cuando ejecutes queries que los requieran.

---

## ðŸ’° OPTIMIZACIÃ“N DE COSTOS

### LÃ­mites del Plan Gratuito

| Recurso | LÃ­mite Diario | LÃ­mite Mensual |

|---------|---------------|----------------|

| Reads | 50,000 | ~1,500,000 |

| Writes | 20,000 | ~600,000 |

| Deletes | 20,000 | ~600,000 |

| Storage | - | 1 GB |

| Network | - | 10 GB |

### EstimaciÃ³n de Uso

#### Writes

```
Fichajes diarios:
- 458 empleados Ã— 1 documento/dÃ­a = 458 writes/dÃ­a
- Update de documento: 3 actualizaciones promedio/dÃ­a = 1,374 writes/dÃ­a
- Total: ~2,000 writes/dÃ­a âœ… (10% del lÃ­mite)

Mensual: ~44,000 writes/mes âœ…
```

#### Reads

```
Pico matutino (9-10am):
- 229 empleados Ã— 30 reads (cargar dashboard) = 6,870 reads/hora

Uso distribuido durante el dÃ­a:
- 229 docentes Ã— 20 reads (promedio) = 4,580 reads

Consultas admin/RRHH:
- 2 usuarios Ã— 200 reads/dÃ­a = 400 reads

Total: ~12,000 reads/dÃ­a âœ… (24% del lÃ­mite)
Mensual: ~360,000 reads/mes âœ…
```

#### Storage

```
Registro por dÃ­a: ~2 KB
458 empleados Ã— 22 dÃ­as Ã— 12 meses Ã— 3 aÃ±os = 362,208 registros
362,208 Ã— 2 KB = 724 MB âœ… (72% del lÃ­mite de 1 GB)

Con archivado (solo 3 meses en Firestore):
458 Ã— 22 Ã— 3 = 30,228 registros
30,228 Ã— 2 KB = 60 MB âœ… (6% del lÃ­mite)
```

### Estrategias de OptimizaciÃ³n

#### 1. **CachÃ© Local Agresivo**

```dart
// Usar cached data cuando sea posible
FirebaseFirestore.instance
  .collection('users/$uid/daily_records')
  .doc(today)
  .get(GetOptions(source: Source.cache))  // Lee de cachÃ© primero
```

**Ahorro**: 60-80% de reads

#### 2. **PaginaciÃ³n Inteligente**

```dart
// Dashboard: Mostrar solo Ãºltimos 7 dÃ­as por defecto
query.limit(7);

// BotÃ³n "Ver mÃ¡s" carga 30 dÃ­as
query.limit(30).startAfterDocument(lastDocument);
```

**Ahorro**: 70% de reads en carga inicial

#### 3. **ResÃºmenes Pre-calculados**

```dart
// En vez de calcular totales del mes leyendo 22 documentos:
// Leer 1 documento de monthly_summary

// Ahorro: 22 reads â†’ 1 read (95% menos)
```

#### 4. **Listeners Selectivos**

```dart
// NO escuchar toda la colecciÃ³n
// SÃ escuchar solo el documento de hoy

// âŒ MAL
db.collection('users/$uid/daily_records').snapshots()

// âœ… BIEN
db.collection('users/$uid/daily_records').doc(today).snapshots()
```

**Ahorro**: 90% de reads recurrentes

#### 5. **Archivado AutomÃ¡tico**

- Registros > 3 meses â†’ Cloud Storage
- Reduce storage en Firestore
- Reduce tiempo de queries

**Ahorro en Storage**: 90% (de 724 MB â†’ 60 MB)

### Costos Proyectados

#### Escenario: Uso Optimizado (Con estrategias aplicadas)

```
Reads: ~12,000/dÃ­a Ã— 30 dÃ­as = 360,000/mes âœ… GRATIS
Writes: ~2,000/dÃ­a Ã— 30 dÃ­as = 60,000/mes âœ… GRATIS
Storage: 60 MB (Firestore) + 700 MB (Storage) âœ… GRATIS
```

**Costo mensual: $0** (dentro del plan gratuito)

#### Escenario: Uso Sin Optimizar (Sin estrategias)

```
Reads: ~35,000/dÃ­a Ã— 30 dÃ­as = 1,050,000/mes
- Gratis: 1,500,000
- Exceso: 0 âœ… GRATIS (pero cerca del lÃ­mite)

Writes: ~4,000/dÃ­a Ã— 30 dÃ­as = 120,000/mes
- Gratis: 600,000 âœ… GRATIS

Storage: 724 MB âœ… GRATIS
```

**Costo mensual: $0** (pero riesgo de superar lÃ­mite en picos)

#### Escenario: Crecimiento (600 empleados, sin optimizar)

```
Reads: 2,000,000/mes
- Gratis: 1,500,000
- Exceso: 500,000
- Costo: $0.18 (500K / 100K Ã— $0.036)

Writes: 150,000/mes âœ… GRATIS
Storage: 900 MB âœ… GRATIS
```

**Costo mensual: ~$0.20** (muy bajo)

### RecomendaciÃ³n

âœ… **Implementar estrategias de optimizaciÃ³n desde Sprint 1**

âœ… **Monitorear uso en Firebase Console**

âœ… **Alertas si se supera 80% de lÃ­mite diario**

---

## ðŸ§ª ESTRATEGIA DE TESTING

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
- DateHelpers (formatear fechas, semana del aÃ±o)
- ClockingStateMachine (transiciones de estado)

// Models
- User.fromJson() / toJson()
- DailyRecord.fromJson() / toJson()
- OvertimeRequest.fromJson() / toJson()
```

**Objetivo**: 80% de cobertura en lÃ³gica de negocio

#### 2. **Widget Tests**

```dart
// Screens
- LoginScreen (formulario, validaciÃ³n)
- DashboardScreen (mostrar datos, botones deshabilitados)
- AdminDashboardScreen (lista de empleados)

// Widgets
- ClockingButtons (estado de botones segÃºn ClockingState)
- RecordsTable (mostrar registros, paginaciÃ³n)
- OvertimeRequestCard (aprobar/rechazar)
```

**Objetivo**: 60% de cobertura en widgets crÃ­ticos

#### 3. **Integration Tests**

```dart
// Flujos completos
- Login â†’ Dashboard â†’ Fichar â†’ Logout
- Fichar dÃ­a completo: Entrada â†’ Pausa â†’ Retorno â†’ Salida
- Admin corrige fichaje â†’ Verificar editHistory
- RRHH aprueba horas extras â†’ Verificar estado cambiado
```

**Objetivo**: 5-10 flujos crÃ­ticos cubiertos

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

- âœ… Testing local sin costo
- âœ… Datos aislados de producciÃ³n
- âœ… RÃ¡pido (sin latencia de red)

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

## ðŸ“¦ DEPENDENCIAS ADICIONALES

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
  
  # âœ¨ NUEVAS para Fase 2
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  
  # State Management
  riverpod_annotation: ^2.3.0
  
  # Utils
  freezed_annotation: ^2.4.1     # Para models immutables
  json_annotation: ^4.8.1        # Para serializaciÃ³n
  
  # PDF Generation
  pdf: ^3.10.0
  printing: ^5.11.0
  
  # Date/Time
  timezone: ^0.9.2
  
  # Logging
  logger: ^2.0.2

dev_dependencies:
  flutter_lints: ^3.0.0
  
  # âœ¨ NUEVAS
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

## ðŸš€ PLAN DE IMPLEMENTACIÃ“N

### PreparaciÃ³n (Antes de Sprint 1)

#### 1. Configurar Proyecto Firebase

- [ ] Crear proyecto en [Firebase Console](https://console.firebase.google.com)
- [ ] Habilitar Firebase Authentication
    - [ ] Activar mÃ©todo Email/Password
    - [ ] (Opcional) Activar Google Sign-In
- [ ] Crear Firestore Database
    - [ ] Iniciar en **modo test** (cambiar a producciÃ³n en Sprint 3)
    - [ ] Seleccionar regiÃ³n: `europe-west1`
- [ ] Habilitar Cloud Storage
    - [ ] Crear bucket para archivado
- [ ] Habilitar Cloud Functions
    - [ ] Actualizar plan a Blaze (pay-as-you-go, pero seguirÃ¡ gratis con nuestro uso)

#### 2. Configurar Flutter con Firebase

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase en el proyecto
flutterfire configure

# Seguir wizard:
# - Seleccionar proyecto Firebase
# - Seleccionar plataformas (web, android, ios)
# - Generar archivos de configuraciÃ³n
```

#### 3. Poblar Datos Iniciales

```bash
# Script para crear usuarios de prueba
# functions/scripts/seedUsers.ts

# Crear:
# - 1 Admin
# - 1 RRHH
# - 10 Empleados de prueba
# - 2 Schedules (Jornada EstÃ¡ndar, Jornada Tarde)
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

| Sprint | DuraciÃ³n | Fechas | Entregable |

|--------|----------|--------|------------|

| **PreparaciÃ³n** | 2 dÃ­as | Nov 25-26 | Proyecto Firebase configurado |

| **Sprint 1** | 5 dÃ­as | Nov 27 - Dic 1 | Login + Fichaje bÃ¡sico |

| **Sprint 2** | 5 dÃ­as | Dic 2 - Dic 6 | Pausas + Validaciones |

| **Sprint 3** | 5 dÃ­as | Dic 9 - Dic 13 | Panel Admin + Correcciones |

| **Sprint 4** | 5 dÃ­as | Dic 16 - Dic 20 | Cierre automÃ¡tico + Horas extras |

| **Sprint 5** | 5 dÃ­as | Ene 7 - Ene 10 | Reportes + Archivado |

| **Testing** | 3 dÃ­as | Ene 13 - Ene 15 | Tests + Bug fixes |

| **Deploy** | 2 dÃ­as | Ene 16 - Ene 17 | ProducciÃ³n |

**Total**: ~30 dÃ­as laborables (~6 semanas)

---

## ðŸ“š ESTRUCTURA DE ARCHIVOS FASE 2

### Archivos a Crear

```
lib/
â”œâ”€â”€ core/
â”‚   â”œâ”€â”€ services/
â”‚   â”‚   â”œâ”€â”€ firebase_service.dart              # âœ¨ Nuevo
â”‚   â”‚   â””â”€â”€ auth_service.dart                  # âœ¨ Nuevo
â”‚   â””â”€â”€ utils/
â”‚       â”œâ”€â”€ date_helpers.dart                  # âœ¨ Nuevo
â”‚       â”œâ”€â”€ time_calculation.dart              # âœ¨ Nuevo
â”‚       â””â”€â”€ validators.dart    # âœ¨ Nuevo
â”‚
â”œâ”€â”€ features/
â”‚   â”œâ”€â”€ auth/
â”‚   â”‚   â”œâ”€â”€ models/
â”‚   â”‚   â”‚   â””â”€â”€ user_model.dart                # âœ¨ Nuevo
â”‚   â”‚   â””â”€â”€ providers/
â”‚   â”‚       â”œâ”€â”€ auth_provider.dart             # âœ¨ Nuevo
â”‚   â”‚       â””â”€â”€ auth_state_provider.dart       # âœ¨ Nuevo
â”‚   â”‚
â”‚   â”œâ”€â”€ dashboard/
â”‚   â”‚   â”œâ”€â”€ models/
â”‚   â”‚   â”‚   â”œâ”€â”€ daily_record_model.dart        # âœ¨ Nuevo
â”‚   â”‚   â”‚   â”œâ”€â”€ monthly_summary_model.dart     # âœ¨ Nuevo
â”‚   â”‚   â”‚   â””â”€â”€ clocking_state.dart            # âœ¨ Nuevo
â”‚   â”‚   â””â”€â”€ providers/
â”‚   â”‚       â”œâ”€â”€ clocking_provider.dart         # âœ¨ Nuevo
â”‚   â”‚       â”œâ”€â”€ clocking_state_provider.dart   # âœ¨ Nuevo
â”‚   â”‚       â”œâ”€â”€ dashboard_provider.dart        # âœ¨ Nuevo
â”‚   â”‚       â””â”€â”€ time_calculation_provider.dart # âœ¨ Nuevo
â”‚   â”‚
â”‚   â””â”€â”€ admin/
â”‚       â”œâ”€â”€ models/
â”‚       â”‚   â”œâ”€â”€ overtime_request_model.dart    # âœ¨ Nuevo
â”‚       â”‚   â””â”€â”€ schedule_model.dart            # âœ¨ Nuevo
â”‚       â””â”€â”€ providers/
â”‚           â”œâ”€â”€ admin_employees_provider.dart  # âœ¨ Nuevo
â”‚           â”œâ”€â”€ admin_clocking_provider.dart   # âœ¨ Nuevo
â”‚           â”œâ”€â”€ anomalies_provider.dart        # âœ¨ Nuevo
â”‚           â”œâ”€â”€ overtime_provider.dart         # âœ¨ Nuevo
â”‚           â””â”€â”€ reports_provider.dart          # âœ¨ Nuevo
â”‚
â”œâ”€â”€ main.dart    # ðŸ”„ Actualizar (Firebase init)
â””â”€â”€ app.dart    # ðŸ”„ Actualizar (Providers)

functions/
â”œâ”€â”€ src/
â”‚   â”œâ”€â”€ index.ts    # âœ¨ Nuevo
â”‚   â”œâ”€â”€ autoCloseRecords.ts    # âœ¨ Nuevo
â”‚   â”œâ”€â”€ detectOvertime.ts    # âœ¨ Nuevo
â”‚   â”œâ”€â”€ generateMonthlySummaries.ts            # âœ¨ Nuevo
â”‚   â””â”€â”€ archiveOldRecords.ts                   # âœ¨ Nuevo
â”œâ”€â”€ test/
â”‚   â””â”€â”€ (tests para functions)                 # âœ¨ Nuevo
â”œâ”€â”€ package.json    # âœ¨ Nuevo
â””â”€â”€ tsconfig.json    # âœ¨ Nuevo

firestore.rules    # âœ¨ Nuevo
firestore.indexes.json    # âœ¨ Nuevo
storage.rules    # âœ¨ Nuevo
firebase.json    # âœ¨ Nuevo (config)
```

**Total de archivos nuevos**: ~35

**Archivos a actualizar**: ~15 (pantallas para conectar providers)

---

## âœ… CHECKLIST DE IMPLEMENTACIÃ“N

### PreparaciÃ³n

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
- [ ] Crear reglas de seguridad bÃ¡sicas
- [ ] Tests unitarios (Auth, Clocking)
- [ ] Test de integraciÃ³n (Login â†’ Fichar â†’ Logout)

### Sprint 2: Pausas

- [ ] Actualizar `DailyRecordModel` (agregar pausas)
- [ ] Implementar `ClockingState` (enum)
- [ ] Implementar `ClockingStateProvider`
- [ ] Actualizar botones (deshabilitar segÃºn estado)
- [ ] Implementar `TimeCalculationProvider`
- [ ] Calcular minutos trabajados (incluye pausas)
- [ ] Implementar diÃ¡logo de confirmaciÃ³n (salida anticipada)
- [ ] Tests unitarios (State machine, CÃ¡lculos)
- [ ] Test de integraciÃ³n (Flujo completo con pausa)

### Sprint 3: Admin

- [ ] Implementar `AdminEmployeesProvider`
- [ ] Implementar lista de empleados (filtros, bÃºsqueda)
- [ ] Implementar `AdminClockingProvider`
- [ ] Modal de correcciÃ³n de fichaje
- [ ] Guardar `editHistory` en registros
- [ ] Implementar `AnomaliesProvider`
- [ ] Panel de anomalÃ­as
- [ ] Actualizar reglas de seguridad (admin puede todo)
- [ ] Tests unitarios (Admin providers)
- [ ] Test de integraciÃ³n (Admin corrige fichaje)

### Sprint 4: AutomatizaciÃ³n

- [ ] Implementar `ScheduleModel`
- [ ] Crear colecciÃ³n `schedules` con datos de prueba
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
- [ ] GrÃ¡ficos de horas trabajadas
- [ ] Implementar `PDFExportProvider`
- [ ] GeneraciÃ³n de PDF
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

- [ ] Actualizar reglas de seguridad (modo producciÃ³n)
- [ ] Crear Ã­ndices compuestos en Firestore
- [ ] Configurar alertas de cuota en Firebase Console
- [ ] Deploy de Cloud Functions a producciÃ³n
- [ ] Build de Flutter Web (`flutter build web --release`)
- [ ] Deploy a Firebase Hosting
- [ ] Pruebas en producciÃ³n
- [ ] Monitorear logs y errores

---

## ðŸŽ¯ OBJETIVOS DE FASE 2

### Funcionales

- âœ… Login y autenticaciÃ³n real con Firebase
- âœ… Sistema de fichaje completo (Entrada/Pausa/Retorno/Salida)
- âœ… Validaciones de secuencia y mÃ¡quina de estados
- âœ… Panel admin funcional (ver todos, corregir fichajes)
- âœ… Cierre automÃ¡tico de fichajes olvidados
- âœ… Sistema de aprobaciÃ³n de horas extras
- âœ… Reportes mensuales por empleado
- âœ… ExportaciÃ³n a PDF
- âœ… Archivado automÃ¡tico de registros antiguos

### TÃ©cnicos

- âœ… Firebase Authentication implementado
- âœ… Firestore con estructura escalable
- âœ… Riverpod providers funcionales
- âœ… Cloud Functions automatizadas
- âœ… Reglas de seguridad robustas
- âœ… OptimizaciÃ³n de costos (plan gratuito)
- âœ… Tests con >70% de cobertura
- âœ… CÃ³digo limpio y mantenible

### Negocio

- âœ… Sistema usable por los 458 empleados
- âœ… Admin y RRHH pueden gestionar empleados
- âœ… Cumple con requisitos de auditorÃ­a (histÃ³rico 4 aÃ±os)
- âœ… Escalable para crecimiento futuro
- âœ… Costo mÃ­nimo (plan gratuito)

---

## ðŸ”® FASE 3: FUTURAS MEJORAS (No incluidas en Fase 2)

### Features Adicionales

- ðŸ“ **GeolocalizaciÃ³n**: Registrar ubicaciÃ³n GPS en fichajes
- ðŸ“± **App MÃ³vil Nativa**: VersiÃ³n Android/iOS
- ðŸ‘¤ **Reconocimiento Facial**: VerificaciÃ³n biomÃ©trica
- ðŸ“… **GestiÃ³n de Vacaciones**: Solicitudes y aprobaciones
- ðŸ“ **Permisos y Bajas**: GestiÃ³n de ausencias
- ðŸ“Š **Dashboard AnalÃ­tico**: GrÃ¡ficos avanzados con charts
- ðŸ”” **Notificaciones Push**: Recordatorios de fichaje
- ðŸ“§ **Notificaciones Email**: ResÃºmenes semanales
- ðŸ¢ **Multi-empresa**: Soporte para mÃºltiples instituciones
- ðŸŒ **Multi-idioma**: i18n (inglÃ©s, catalÃ¡n)
- ðŸŽ¨ **Temas**: Dark mode
- ðŸ“¤ **Exportar Excel**: AdemÃ¡s de PDF
- ðŸ” **BÃºsqueda Avanzada**: Filtros complejos en reportes
- ðŸ“ˆ **Predicciones**: ML para detectar patrones

### Optimizaciones TÃ©cnicas

- âš¡ **Offline Support**: App funcional sin internet
- ðŸ”„ **Sync Incremental**: Solo sincronizar cambios
- ðŸ“¦ **PWA**: Progressive Web App con install prompt
- ðŸš€ **Performance**: Lazy loading, code splitting
- ðŸ” **2FA**: AutenticaciÃ³n de dos factores
- ðŸ“± **Responsive Mejorado**: Tablet mode optimizado

---

## ðŸ“ NOTAS FINALES

### Decisiones Tomadas

1. âœ… **1 pausa por dÃ­a** (simplifica lÃ³gica y reduce writes)
2. âœ… **1 documento por dÃ­a** (vs 1 por fichaje) - optimiza queries
3. âœ… **Horas extras necesitan aprobaciÃ³n** (RRHH o Admin)
4. âœ… **Cierre automÃ¡tico marcado como anomalÃ­a** (requiere revisiÃ³n)
5. âœ… **Cloud Storage para archivado** (mÃ¡s barato que Firestore)
6. âœ… **Salida anticipada: warning si faltan >1 hora**
7. âœ… **Empleado solo edita entrada, mismo dÃ­a, sin aprobaciÃ³n**
8. âœ… **Admin edita todo, con historial de cambios**

### Flexibilidad de Firebase

- âœ… **Estructura evolutiva**: Empezamos simple, agregamos campos segÃºn avancemos
- âœ… **No necesita schema rÃ­gido**: FÃ¡cil agregar/quitar campos
- âš ï¸ **Planear colecciones bien**: DifÃ­cil cambiar estructura base despuÃ©s
- âœ… **Desarrollo iterativo**: Sprint por sprint, testeando en real

### PrÃ³ximos Pasos

1. **Confirmar** que la planificaciÃ³n cubre todos los requisitos
2. **Hacer preguntas** si algo no estÃ¡ claro
3. **Iniciar Sprint 1**: Configurar Firebase â†’ Implementar MVP
4. **Iterar**: Feedback despuÃ©s de cada Sprint

---

**Equipo**: Control Horario - Escuela de MÃºsica

**Documento**: PlanificaciÃ³n Fase 2

**VersiÃ³n**: 2.0.0-planning

**Estado**: ðŸš§ Pendiente de AprobaciÃ³n

**Fecha**: Noviembre 2025

---

## â“ Â¿Listo para Empezar?

Una vez apruebes esta planificaciÃ³n, procederemos con:

1. **ConfiguraciÃ³n de Firebase** (PreparaciÃ³n)
2. **ImplementaciÃ³n de Sprint 1** (MVP)
3. **Iteraciones** hasta completar Fase 2

**Â¿Alguna duda o ajuste a la planificaciÃ³n?** ðŸš€
