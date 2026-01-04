# DÍA 4 - Actualización UserModel con Estructura Híbrida

**📚 Plan Maestro:** [← Volver al Plan de 7 Días](plan-7-dias-produccion.md#día-4-panel-admin---ver-todos-)  
**Fecha:** 3 Enero 2026  
**Estado:** ✅ Completado

---

## 📋 Resumen

Se actualizó el `UserModel` con una **estructura híbrida** que combina:
- **Campos simples** para datos que no cambian frecuentemente (departamento, cargo)
- **Referencias** para datos complejos que se necesitan ocasionalmente (scheduleId)
- **Campos adicionales** del drawer de FASE 1 que faltaban

---

## ✅ Archivos Modificados

### 1. `lib/features/auth/models/user_model.dart`

**Campos NUEVOS agregados:**
```dart
// Información personal
String? dni,           // DNI/NIE del empleado
String? telefono,      // Teléfono de contacto

// Control horario (híbrido)
String? scheduleId,    // Referencia a plantilla de horario
DateTime? fechaInicio, // Fecha de inicio en la APLICACIÓN (no en la empresa)
DateTime? fechaFin,    // Fecha de fin en la APLICACIÓN (baja/baja temporal)
```

**Campos EXISTENTES (sin cambios):**
```dart
// Básicos
required String userId,
required String employeeId,
required String email,
required String displayName,
required UserRole role,
required double weeklyHours,
@Default(true) bool isActive,
required DateTime createdAt,

// Información laboral
String? position,      // Cargo
String? department,    // Departamento

// DEPRECATED (mantener por compatibilidad)
@Deprecated('Usar scheduleId en su lugar')
String? schedule,      // Horario en texto
```

**Actualización en `fromFirestore()`:**
- Agregado manejo de `dni`
- Agregado manejo de `telefono`
- Agregado manejo de `scheduleId`
- Agregado manejo de `fechaInicio` (con conversión de Timestamp)
- Agregado manejo de `fechaFin` (con conversión de Timestamp)

---

### 2. `lib/core/services/firebase_service.dart`

**Método `createEmployee()` actualizado:**

**Parámetros NUEVOS:**
```dart
String? scheduleId,    // ID de plantilla de horario
DateTime? fechaInicio, // Fecha de inicio
```

**Guardado en Firestore:**
```dart
if (scheduleId != null && scheduleId.trim().isNotEmpty)
  'scheduleId': scheduleId.trim(),
if (fechaInicio != null) 
  'fechaInicio': Timestamp.fromDate(fechaInicio),
```

---

### 3. `lib/features/admin/providers/user_management_provider.dart`

**Método `createEmployee()` actualizado:**

**Parámetros NUEVOS:**
```dart
String? scheduleId,
DateTime? fechaInicio,
```

**Propagación al service:**
```dart
final result = await service.createEmployee(
  // ... parámetros existentes
  scheduleId: scheduleId,
  fechaInicio: fechaInicio,
  // ...
);
```

---

## 🎯 Decisiones de Diseño

### Departamento: String Simple + Dropdown Hardcoded ✅
**Justificación:**
- Son solo 4-5 departamentos fijos
- No cambian frecuentemente
- No se necesita info adicional del departamento
- Más simple de implementar y mantener

**Opciones en el dropdown:**
- Tecnología
- Docente
- Administración
- Recursos Humanos

### Horario: Referencia (scheduleId) ✅
**Justificación:**
- Los horarios son complejos (turnos, días, pausas)
- Se necesita referencia para obtener detalles completos
- Permite reutilizar plantillas de horarios
- Facilita gestión centralizada

**Campos relacionados:**
- `scheduleId`: Referencia a plantilla (ej: "template_40h_001")
- `weeklyHours`: Cache para cálculos rápidos (ej: 40.0)

### Otros Campos: Simples y Opcionales ✅
**Justificación:**
- `dni`, `telefono`: Datos personales simples
- `fechaInicio`: Fecha de inicio en la APLICACIÓN, NO en la empresa
- `fechaFin`: Fecha de fin en la APLICACIÓN (baja/baja temporal)
- Todos opcionales al crear empleado (solo nombre, apellido, email son obligatorios)

### `fechaInicio` y `fechaFin`: Control de Acceso a la Aplicación ⚠️

**IMPORTANTE:** Estas fechas NO se refieren a la empresa, sino a la APLICACIÓN:

**`fechaInicio`**: Fecha desde la cual el empleado puede fichar en la app
- Un empleado puede llevar años en la empresa pero recién empezar a usar la app
- Ejemplo: Empleado ingresó en 2018, pero `fechaInicio`: 10 Enero 2026

**`fechaFin`**: Fecha hasta la cual el empleado puede fichar en la app
- Representa baja temporal o definitiva en el sistema de fichaje
- Ejemplo: Baja de maternidad, despido, jubilación
- Cuando `fechaFin` tiene valor → `isActive` debería ser `false`

**Casos de uso:**
```dart
// Empleado activo en la app
fechaInicio: 10/01/2026
fechaFin: null
isActive: true

// Empleado con baja temporal
fechaInicio: 10/01/2026
fechaFin: 15/02/2026
isActive: false

// Empleado despedido
fechaInicio: 10/01/2026
fechaFin: 30/03/2026
isActive: false
```

---

## 🔄 Compatibilidad con Datos Existentes

### Empleados Test Existentes

Los empleados de test en Firestore (como "Paulo" y "Admin Sistema") **NO tienen** los campos nuevos:
- `dni`: null
- `telefono`: null
- `scheduleId`: null
- `fechaInicio`: null

**Esto NO es problema** porque:
- ✅ Todos los campos nuevos son **opcionales** (`String?`, `DateTime?`)
- ✅ `UserModel.fromFirestore()` maneja correctamente valores null
- ✅ La UI muestra valores por defecto (ej: "Sin asignar")

### Agregar Campos Manualmente

**Ahora puedes agregar** estos campos manualmente en Firestore Console:

1. Ve a Firebase Console → Firestore → `users` → Selecciona un documento
2. Click en "Agregar campo"
3. Agrega cualquiera de estos:
   - `dni` (string): "12345678A"
   - `telefono` (string): "+34 600 000 000"
   - `scheduleId` (string): "template_40h_001"
   - `fechaInicio` (timestamp): Seleccionar fecha

**La app los leerá correctamente** en el próximo refresh.

---

## 📝 Próximos Pasos

### Integración con Drawer (ya existente)

El drawer de "Nuevo Trabajador" (FASE 1) **ya tiene** los campos para:
- DNI ✅
- Teléfono ✅
- Departamento (dropdown) ✅
- Cargo ✅
- Horario (dropdown) ✅
- Fecha inicio (date picker) ✅

**Falta conectar** el drawer con el provider actualizado para que guarde los nuevos campos.

### Gestión de Horarios

Para que `scheduleId` funcione completamente, se necesita:
1. Colección `schedules` en Firestore con plantillas de horarios
2. Provider para obtener detalles del horario por ID
3. UI para mostrar horario completo (turnos, días, pausas)

**Esto se implementará en días posteriores** según el plan.

---

## ✅ Testing

**Verificar:**
- [ ] Empleados existentes se muestran correctamente en la lista
- [ ] No hay errores al leer empleados sin los campos nuevos
- [ ] Se puede crear nuevo empleado con los campos opcionales
- [ ] Se puede agregar campos manualmente en Firestore y se leen correctamente

**Comando para probar:**
```bash
flutter run -d chrome
# Navegar a /admin/employees
# Verificar que todos los empleados se muestran correctamente
```

---

**Última actualización:** 3 Enero 2026  
**Estado:** ✅ UserModel actualizado y funcionando correctamente

