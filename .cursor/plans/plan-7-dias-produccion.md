# Plan 7 Días - Sistema Control Horario Producción

**Última actualización:** 3 Enero 2026  
**Estado:** DÍA 2 ✅ + DÍA 3 ✅ + DÍA 4 ✅ completados - Listo para DÍA 5

---

## 📚 Documentación Relacionada

- 📋 [Plan general FASE 1](fase-1-ui-ux-d36c18be.plan.md) - Diseño UI/UX (completado)
- 📋 [Plan general FASE 2](fase-2-backend-logica.plan.md) - Backend + Lógica (en curso)
- 📋 [Drawer Nuevo Trabajador](drawer_nuevo_trabajador_ac10e796.plan.md) - Especificación completa

**Documentación por día:**
- 📄 [DÍA 4 - Testing Checklist](dia-4-testing-checklist.md) - Pruebas del panel admin
- 📄 [DÍA 4 - UserModel Update](dia-4-usermodel-update.md) - Estructura híbrida de datos

---

## 📋 Contexto
458 empleados empezarán a fichar en 7 días. Sistema debe tener:
- Fichaje completo: Entrada, Pausa (opcional, **cuenta como trabajo**), Salida
- Panel admin para crear usuarios manualmente
- Panel admin para ver y editar fichajes
- **Campos obligatorios para crear usuario:** Nombre, Primer Apellido, Email
- **Campos auto-generados:** employeeId (EMP-XXX secuencial), displayName (nombre completo)
- **Campos con valor por defecto:** weeklyHours (40.0), empresa ("Escuela Música")
- **Campos opcionales:** Segundo apellido, DNI, teléfono, cargo, departamento, scheduleId, fechaInicio, fechaFin

---

## ⚠️ REGLAS CRÍTICAS

### Antes de Modificar Código:
1. ❌ **NUNCA eliminar código sin consultar primero**
2. ✅ Comentar código en vez de eliminar
3. ✅ Agregar TODO con explicación
4. ✅ Preguntar antes de cualquier cambio destructivo

**Ejemplo correcto:**
```dart
// ✅ BIEN: Comentar y documentar
// TODO: Departamento opcional por ahora, reactivar cuando se necesite
// final department = formData['department'];
```

---

## 📅 DÍA 1: Crear Usuarios desde Panel Admin ✅ COMPLETADO

### Sprint 1.1: Preparar FirebaseService (2h)
**Objetivo:** Método para crear usuario en Auth + Firestore

**Archivos:**
- `lib/core/services/firebase_service.dart`

**Tareas:**
1. Método `createUserAccount(email, password)` en Firebase Auth
2. Método `createUserDocument(userId, userData)` en Firestore
3. Wrapper `createEmployee()` que llama ambos
4. Generar contraseña temporal aleatoria

**Test:**
```dart
final userId = await createEmployee(
  email: "test@escuela.com",
  nombre: "Juan",
  apellido1: "Pérez",
  apellido2: null, // opcional
  // employeeId se genera automático si es null
  // displayName se construye automático: "Juan Pérez"
  // weeklyHours = 40.0 por defecto
);
// Verificar en Firebase Console
```

---

### Sprint 1.2: Crear UserManagementProvider (2h)
**Objetivo:** Provider Riverpod para gestión de usuarios

**Archivos:**
- Crear: `lib/features/admin/providers/user_management_provider.dart`

**Tareas:**
1. Crear `UserManagementNotifier` con método `createEmployee()`
2. Manejar AsyncValue (loading, error, data)
3. Validar email único antes de crear
4. **Generar employeeId secuencial automático** si no se proporciona (EMP-001, EMP-002, ...)
5. **Construir displayName** = "nombre + apellido1 (+ apellido2 si existe)"
6. **Asignar weeklyHours = 40.0** si no se proporciona

---

### Sprint 1.3: Conectar NewEmployeeDrawer con Firebase (3h)
**Objetivo:** Drawer crea usuarios reales en vez de mock

**Archivos:**
- `lib/features/admin/presentation/widgets/new_employee_drawer.dart`

**Tareas:**
1. Convertir a `ConsumerStatefulWidget`
2. Reemplazar `MockData.addEmployee()` por `ref.read(userManagementProvider)`
3. **Actualizar validaciones:** solo 3 campos obligatorios
   - **Obligatorios (*):** Nombre, Primer Apellido, Email
   - **Opcionales:** Segundo apellido, DNI, teléfono, cargo, departamento
   - **Auto-generados:** employeeId (si está vacío), displayName (nombre + apellidos)
   - **Valor por defecto:** weeklyHours = 40.0 (si está vacío)
4. Campos opcionales pueden quedar vacíos sin error
5. Mostrar loading durante creación
6. Manejar errores (email duplicado, etc.)
7. SnackBar de éxito con credenciales temporales

**⚠️ IMPORTANTE:** 
- NO eliminar campos del drawer
- Solo cambiar cuáles son obligatorios (*)
- Mantener toda la UI existente
- employeeId se genera automático si no se especifica
- displayName = "Nombre + Primer Apellido (+ Segundo Apellido si existe)"

**Test:**
1. Abrir drawer desde EmployeesListScreen
2. Llenar solo 3 campos obligatorios: Nombre="Juan", Apellido1="Pérez", Email="juan@escuela.com"
3. Click "Guardar" 
   - employeeId se genera automático: "EMP-001"
   - displayName se crea automático: "Juan Pérez"
   - weeklyHours se asigna por defecto: 40.0
4. Llenar todos los campos incluido Apellido2="García" → displayName debe ser "Juan Pérez García"
5. Verificar en Firebase Console que usuario existe con todos los campos correctos

---

### Sprint 1.4: Actualizar Firestore Rules (30min)
**Objetivo:** Admin puede crear usuarios

**Archivos:**
- `firestore.rules`

**Cambios:**
```javascript
match /users/{userId} {
  allow read: if isAdmin() || request.auth.uid == userId;
  allow create: if isAdmin();
  allow update: if isAdmin();
}

function isAdmin() {
  return request.auth != null &&
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'rrhh'];
}
```

---

### Sprint 1.5: Testing Integrado Día 1 (1h)
**Checklist:**
- [ ] Admin puede abrir drawer
- [ ] Crear usuario con solo 3 campos obligatorios (nombre, apellido1, email)
- [ ] Verificar employeeId se generó automático (EMP-XXX)
- [ ] Verificar displayName correcto (nombre + apellido)
- [ ] Verificar weeklyHours = 40.0 por defecto
- [ ] Crear usuario con todos los campos opcionales
- [ ] Usuario aparece en Firebase Auth
- [ ] Documento existe en Firestore users/
- [ ] Crear 3 usuarios de prueba más

---

## 📅 DÍA 2: Sistema de Pausas - Backend ✅ COMPLETADO

### Sprint 2.1: Actualizar DailyRecordModel (1.5h) ✅
**Objetivo:** Agregar campos de pausa al modelo

**Archivos:**
- `lib/features/dashboard/models/daily_record_model.dart`

**Cambios:**
```dart
@freezed
class ClockTimes with _$ClockTimes {
  const factory ClockTimes({
    String? clockIn,
    String? breakStart,   // ✨ NUEVO
    String? breakEnd,     // ✨ NUEVO
    String? clockOut,
  }) = _ClockTimes;
}

@freezed
class DailyRecordModel with _$DailyRecordModel {
  const factory DailyRecordModel({
    // ... existentes
    DateTime? breakStartTimestamp,  // ✨ NUEVO
    DateTime? breakEndTimestamp,    // ✨ NUEVO
    int? totalMinutes,              // ✨ NUEVO (pausa incluida)
    // ...
  }) = _DailyRecordModel;
}
```

**Regenerar:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### Sprint 2.2: Métodos de Pausa en ClockingProvider (2h) ✅
**Objetivo:** startBreak() y endBreak()

**Archivos:**
- `lib/features/dashboard/providers/clocking_provider.dart`

**Métodos nuevos:**
```dart
Future<void> startBreak() async {
  // Validar: debe tener clockIn
  // Actualizar breakStart + timestamp
}

Future<void> endBreak() async {
  // Validar: debe tener breakStart
  // Actualizar breakEnd + timestamp
}
```

**Actualizar clockOut():**
```dart
Future<void> clockOut() async {
  // Calcular totalMinutes (pausa cuenta como trabajo)
  final total = (clockOutTime - clockInTime).inMinutes;
  // NO restar tiempo de pausa
}
```

---

### Sprint 2.3: Provider de Estado de Fichaje (1.5h) ✅
**Archivos:**
- Crear: `lib/features/dashboard/providers/clocking_state_provider.dart`

**Provider:**
```dart
enum ClockingState {
  notStarted,
  working,
  onBreak,
  backFromBreak,
  finished,
}

@riverpod
ClockingState currentClockingState(CurrentClockingStateRef ref) {
  final record = ref.watch(todayRecordProvider).value;
  // Lógica para determinar estado
}
```

---

### Sprint 2.4: Testing Backend Pausas (1h) ✅
**Escenarios de prueba:**
1. ✅ Fichar entrada → estado: working
2. ✅ Iniciar pausa → estado: onBreak
3. ✅ Finalizar pausa → estado: backFromBreak
4. ✅ Fichar salida → estado: finished, totalMinutes correcto
5. ❌ Intentar pausa sin entrada → debe fallar
6. ❌ Intentar salida durante pausa → debe fallar

---

## 📅 DÍA 3: Sistema de Pausas - Frontend ✅ COMPLETADO

### Sprint 3.1: Actualizar TimeClockCard (2.5h) ✅
**Archivos:**
- `lib/features/dashboard/presentation/widgets/time_clock_card.dart`

**Cambios:**
- Observar `currentClockingStateProvider`
- Mostrar botones según estado:
  - `working` → "INICIAR PAUSA" + "FICHAR SALIDA"
  - `onBreak` → "FINALIZAR PAUSA"
  - `backFromBreak` → "FICHAR SALIDA"

---

### Sprint 3.2: Actualizar DaySummaryCard (1.5h) ✅
**Archivos:**
- `lib/features/dashboard/presentation/widgets/day_summary_card.dart`

**Mostrar:**
- Total trabajado (incluyendo pausa)
- Tiempo en pausa (info visual)

---

### Sprint 3.3: Actualizar RecentRecordsCard (1h) ✅
**Cambios:**
- Columna indicando si hubo pausa (ícono o "Sí/No")

---

### Sprint 3.4: Testing Integrado Pausas (2h) ✅
**Escenarios:**
1. Empleado ficha día completo con pausa
2. Empleado ficha día completo sin pausa
3. Empleado toma pausa pero olvida finalizarla
4. Varios empleados fichando simultáneamente

---

## 📅 DÍA 4: Panel Admin - Ver Todos ✅ COMPLETADO

### Sprint 4.1: Provider de Todos los Empleados (2h) ✅
**Archivos:**
- Creado: `lib/features/admin/providers/admin_provider.dart`

**Providers implementados:**
```dart
@riverpod
Stream<List<UserModel>> allEmployees(AllEmployeesRef ref) {
  return firestore.collection('users')
    .where('isActive', isEqualTo: true)
    // NOTE: En producción puede requerir índice compuesto (isActive + displayName).
    // En el código actual ordenamos en memoria para evitar dependencia de índices.
    .snapshots()
    .map((snapshot) => snapshot.docs.map((doc) => 
      UserModel.fromFirestore(doc)
    ).toList());
}

@riverpod
Stream<int> employeesCount(EmployeesCountRef ref) {
  return ref.watch(allEmployeesProvider)
    .map((users) => users.length);
}

// + filteredEmployees, employeesByDepartment, 
//   searchAndFilterEmployees, employeeById
```

**Características:**
- Stream en tiempo real desde Firestore
- Solo empleados activos (`isActive == true`)
- Ordenado alfabéticamente
- Filtros en memoria (sin índices en Firestore)

---

### Sprint 4.2: Conectar AdminDashboardScreen (2h) ✅
**Archivos:**
- Modificado: `lib/features/admin/presentation/screens/admin_dashboard_screen.dart`

**Cambios:**
- Convertido a `ConsumerWidget`
- Observa `employeesCountProvider`
- Card "Total Empleados" muestra dato real
- Estados de loading implementados (`...` mientras carga)
- Otras métricas siguen con MockData (DÍA 5+)

**Test manual:**
```bash
flutter run -d chrome
# Navegar a /admin
# Verificar "Total Empleados" muestra número correcto
```

---

### Sprint 4.3: Conectar EmployeesListScreen (2h) ✅
**Archivos:**
- Modificado: `lib/features/admin/presentation/screens/employees_list_screen.dart`

**Cambios:**
- Convertido a `ConsumerStatefulWidget`
- Observa `searchAndFilterEmployeesProvider`
- Lista actualizada en tiempo real
- Búsqueda funcional (displayName, email, employeeId)
- Filtros por departamento funcionales
- Estados AsyncValue (data, loading, error)
- Mapeo de `UserModel` a formato de `EmployeeListItem`

**Funcionalidad implementada:**
- ✅ Búsqueda en tiempo real
- ✅ Filtro por departamento
- ✅ Combinación búsqueda + filtro
- ✅ Contador "Mostrando X de Y empleados"
- ✅ Estado vacío si no hay resultados
- ✅ Estado de error si falla Firestore
- ✅ Loading mientras carga datos

---

### Sprint 4.4: Testing Integrado Admin Dashboard (1h) ✅
**📄 Documentación completa:** [dia-4-testing-checklist.md](.cursor/plans/dia-4-testing-checklist.md)  
**📄 Actualización UserModel:** [dia-4-usermodel-update.md](.cursor/plans/dia-4-usermodel-update.md)

**Escenarios probados:**
- ✅ Dashboard muestra total correcto
- ✅ Lista de empleados completa
- ✅ Búsqueda funciona en tiempo real
- ✅ Filtros por departamento funcionan
- ✅ Combinación búsqueda + filtro funciona
- ✅ Actualización automática al crear empleado
- ✅ Estados de loading y error
- ✅ Contador de empleados correcto

**Notas:**
- Performance con datos de test: Excelente
- Stream actualiza automáticamente sin refrescar
- Filtros responden instantáneamente
- Integración con drawer de DÍA 1 funciona perfectamente
- UserModel actualizado con estructura híbrida (dni, telefono, scheduleId, fechaInicio, fechaFin)

---

## 📅 DÍA 5: Editar Fichajes

### Sprint 5.1: Provider para Editar Fichajes (2h)
**Archivos:**
- Crear: `lib/features/admin/providers/admin_clocking_provider.dart`

**Provider:**
```dart
@riverpod
class AdminClockingNotifier extends _$AdminClockingNotifier {
  Future<void> editRecord({
    required String userId,
    required String date,
    required ClockTimes newTimes,
  }) async {
    // Validar que es admin
    // Actualizar documento
    // Recalcular totalMinutes
  }
}
```

---

### Sprint 5.2: Modal de Edición de Fichaje (3h)
**Archivos:**
- Crear: `lib/features/admin/presentation/widgets/edit_clocking_dialog.dart`

**Contenido:**
- TimePicker para entrada
- TimePicker para inicio pausa (opcional)
- TimePicker para fin pausa (opcional)
- TimePicker para salida
- Botones: Cancelar, Guardar

---

### Sprint 5.3: Integrar en EmployeeDetailScreen (1.5h)
**Cambios:**
- Botón "Editar Fichaje" en cada registro
- Abrir modal con datos actuales
- Actualizar vista tras edición

---

### Sprint 5.4: Actualizar Firestore Rules (30min)
**Rules:**
```javascript
allow update: if isAdmin() || 
              (request.auth.uid == userId && !isBlocked());
```

---

### Sprint 5.5: Testing Ediciones (1h)
**Escenarios:**
- [ ] Admin edita fichaje incompleto
- [ ] Admin corrige horario con pausa
- [ ] Cambios se reflejan en dashboard empleado

---

## 📅 DÍA 6: Crear Usuarios Masivo

### Sprint 6: Crear 458 Usuarios en Lotes (8h)
**Estrategia:** 8 lotes de ~60 usuarios/hora

**Por cada lote (1 hora):**
1. Preparar lista con 60 nombres/emails (Excel: Nombre | Apellido1 | Email)
2. Crear desde drawer (~1 min/usuario con solo 3 campos obligatorios)
   - employeeId se genera automático
   - weeklyHours usa valor por defecto (40)
3. Verificar que todos se crearon
4. Anotar credenciales generadas en Excel

**Lotes:**
- Lote 1: Usuarios 1-60
- Lote 2: Usuarios 61-120
- Lote 3: Usuarios 121-180
- Lote 4: Usuarios 181-240
- Lote 5: Usuarios 241-300
- Lote 6: Usuarios 301-360
- Lote 7: Usuarios 361-420
- Lote 8: Usuarios 421-458

---

## 📅 DÍA 7: Testing y Ajustes

### Sprint 7.1: Testing con Usuarios Piloto (3h)
**Objetivo:** 10 usuarios reales probando

**Escenarios:**
1. Fichar entrada/salida sin pausa
2. Fichar entrada/salida con pausa
3. Olvidar fichar salida
4. Admin corrige fichaje
5. Ver dashboard actualizado

---

### Sprint 7.2: Corrección de Bugs Críticos (3h)
**Prioridad:** Solo bugs que bloquean fichaje

---

### Sprint 7.3: Preparar Documentación (1h)
**Crear:**
- Manual empleado (1 página)
- Manual admin (2 páginas)
- Email de credenciales

---

### Sprint 7.4: Verificación Final (1h)
**Checklist:**
- [ ] 458 usuarios creados
- [ ] Backup configurado
- [ ] Fichaje funciona
- [ ] Pausas funcionan
- [ ] Admin puede editar
- [ ] Monitoring configurado

---

## 📊 Resumen de Archivos

**Nuevos (~8 archivos):**
1. `lib/core/services/firebase_service.dart` (método createEmployee)
2. `lib/features/admin/providers/user_management_provider.dart`
3. `lib/features/admin/providers/admin_provider.dart`
4. `lib/features/admin/providers/admin_clocking_provider.dart`
5. `lib/features/dashboard/providers/clocking_state_provider.dart`
6. `lib/features/admin/presentation/widgets/edit_clocking_dialog.dart`

**Modificados (~6 archivos):**
1. `lib/features/dashboard/models/daily_record_model.dart`
2. `lib/features/dashboard/providers/clocking_provider.dart`
3. `lib/features/admin/presentation/widgets/new_employee_drawer.dart`
4. `lib/features/dashboard/presentation/widgets/time_clock_card.dart`
5. `lib/features/admin/presentation/screens/admin_dashboard_screen.dart`
6. `firestore.rules`

---

## 🔄 Estrategia de Rollback
Cada sprint tiene commit independiente. Si falla:
```bash
git log --oneline  # Ver commits
git revert <commit-hash>  # Revertir sprint específico
```

---

**Última actualización:** 3 Enero 2026  
**Próximo paso:** Empezar DÍA 5 - Sprint 5.1 (Provider para editar fichajes)

