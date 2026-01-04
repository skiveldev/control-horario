# DÍA 4 - Testing Checklist

**📚 Plan Maestro:** [← Volver al Plan de 7 Días](plan-7-dias-produccion.md#día-4-panel-admin---ver-todos-)  
**Fecha:** 3 Enero 2026  
**Estado:** ✅ Implementación completada - En testing

---

## 📋 Resumen de Implementación

### Sprint 4.1: Provider de Todos los Empleados ✅
**Archivo creado:** `lib/features/admin/providers/admin_provider.dart`

**Providers implementados:**
- ✅ `allEmployeesProvider` - Stream de todos los empleados activos
- ✅ `employeesCountProvider` - Contador en tiempo real
- ✅ `filteredEmployeesProvider` - Filtro por búsqueda
- ✅ `employeesByDepartmentProvider` - Filtro por departamento
- ✅ `searchAndFilterEmployeesProvider` - Búsqueda + departamento combinados
- ✅ `employeeByIdProvider` - Obtener empleado específico

**Características:**
- Stream en tiempo real desde Firestore
- Solo empleados con `isActive == true`
- Ordenado alfabéticamente por `displayName`
- Filtros en memoria (no requieren índices en Firestore)

---

### Sprint 4.2: Conectar AdminDashboardScreen ✅
**Archivo modificado:** `lib/features/admin/presentation/screens/admin_dashboard_screen.dart`

**Cambios:**
- ✅ Convertido a `ConsumerWidget`
- ✅ Importado `admin_provider.dart`
- ✅ Observa `employeesCountProvider`
- ✅ Card "Total Empleados" muestra dato real desde Firestore
- ✅ Estados de loading (`...`) implementados
- ✅ Otras métricas siguen con MockData (se implementarán después)

---

### Sprint 4.3: Conectar EmployeesListScreen ✅
**Archivo modificado:** `lib/features/admin/presentation/screens/employees_list_screen.dart`

**Cambios:**
- ✅ Convertido a `ConsumerStatefulWidget`
- ✅ Importado `admin_provider.dart`
- ✅ Eliminado `MockData.employees`
- ✅ Observa `searchAndFilterEmployeesProvider` con query + departamento
- ✅ Lista actualizada en tiempo real vía Stream
- ✅ Búsqueda funcional (displayName, email, employeeId)
- ✅ Filtros por departamento funcionales
- ✅ Estados de AsyncValue implementados (data, loading, error)
- ✅ Mapeo de `UserModel` a formato esperado por `EmployeeListItem`
- ✅ Contador "Mostrando X de Y empleados" con datos reales

---

## ✅ Checklist de Testing (Sprint 4.4)

### A. Admin Dashboard
- [ ] Abrir Admin Dashboard (`/admin`)
- [ ] Verificar que "Total Empleados" muestra el número correcto
- [ ] Verificar que "Total Empleados" muestra "..." durante loading
- [ ] Si hay 0 empleados, debe mostrar "0"
- [ ] Si hay empleados de test, debe mostrar el número correcto (ej: 1, 2, 3...)
- [ ] Otras métricas siguen mostrando datos mock (esto es correcto)

### B. Lista de Empleados
- [ ] Abrir "Gestión de Empleados" (`/admin/employees`)
- [ ] **Caso 1: Sin empleados en Firestore**
  - [ ] Debe mostrar mensaje "No se encontraron empleados"
  - [ ] Contador debe mostrar "Mostrando 0 de 0 empleados"
- [ ] **Caso 2: Con empleados de test**
  - [ ] Debe mostrar lista de empleados
  - [ ] Cada empleado muestra: displayName, email, employeeId, department, position

### C. Búsqueda
- [ ] Escribir en campo de búsqueda (ej: "Paulo", "escuela", "paulo@")
- [ ] Lista se filtra automáticamente mientras escribes
- [ ] Búsqueda insensible a mayúsculas/minúsculas
- [ ] Búsqueda en displayName, email y employeeId funciona
- [ ] Contador muestra "Mostrando X de Y empleados" correctamente
- [ ] Si no hay coincidencias, muestra estado vacío

### D. Filtros por Departamento
- [ ] Click en chip "Todos" → muestra todos
- [ ] Click en chip "Tecnología" → filtra solo ese departamento
- [ ] Click en chip "Docente" → filtra solo ese departamento
- [ ] Empleados sin departamento no aparecen al filtrar por un departamento específico
- [ ] Contador se actualiza según filtro

### E. Búsqueda + Filtro Combinados
- [ ] Seleccionar departamento "Tecnología"
- [ ] Escribir en búsqueda "Juan"
- [ ] Debe mostrar solo empleados de Tecnología que coincidan con "Juan"
- [ ] Contador refleja correctamente la combinación de filtros

### F. Actualización en Tiempo Real
- [ ] Abrir la app en 2 pestañas del navegador
- [ ] En pestaña 1: Crear nuevo empleado desde drawer
- [ ] En pestaña 2: La lista debe actualizarse automáticamente (sin refrescar)
- [ ] El contador en Admin Dashboard debe actualizarse también

### G. Performance
- [ ] Con 5 empleados de test: debe ser instantáneo
- [ ] Con 50+ empleados: tiempo de carga aceptable (<2s)
- [ ] Búsqueda debe responder sin lag
- [ ] Cambio de filtros debe ser instantáneo

### H. Estados de Error
- [ ] Simular error de Firestore (apagar red o denegar permisos)
- [ ] Debe mostrar mensaje de error con ícono rojo
- [ ] Mensaje debe ser descriptivo
- [ ] Al restaurar conexión, debe recuperarse automáticamente

### I. Integración con Drawer (DÍA 1)
- [ ] Click en "Nuevo" → abre drawer
- [ ] Crear empleado → drawer se cierra
- [ ] Empleado aparece en lista automáticamente
- [ ] Admin Dashboard muestra contador actualizado
- [ ] No se requiere refrescar página

---

## 🐛 Problemas Conocidos a Verificar

### 1. EmployeeId Vacío
- [ ] Verificar si los empleados creados tienen `employeeId` vacío
- [ ] Si es así, confirmar que no rompe la búsqueda
- [ ] Si es así, confirmar que no rompe la visualización

### 2. Mapeo de Datos
- [ ] Verificar que el mapeo de `UserModel` a `EmployeeListItem` es correcto:
  - `userId` → `id`
  - `displayName` → `name`
  - `department` (nullable) → "Sin asignar" si es null
  - `position` (nullable) → "Sin cargo" si es null

### 3. Rendimiento con Streams
- [ ] Verificar que no hay rebuilds excesivos
- [ ] Abrir DevTools → Performance
- [ ] Escribir en búsqueda y verificar que no se reconstruye toda la app

---

## 📝 Notas de Implementación

### Decisiones Técnicas

1. **Por qué `searchAndFilterEmployeesProvider` en lugar de filtrar en UI:**
   - Centraliza lógica de filtrado
   - Facilita testing
   - Evita duplicación de código
   - Permite agregar más filtros fácilmente

2. **Por qué filtrar en memoria y no en Firestore:**
   - Búsqueda flexible (displayName, email, employeeId) sin índices complejos
   - Menos queries a Firestore = menor costo
   - Con ~500 empleados, filtrar en memoria es suficientemente rápido
   - Si crece a 10,000+ empleados, se puede migrar a Algolia o índices de Firestore

3. **Por qué `ConsumerStatefulWidget` en lugar de `ConsumerWidget`:**
   - Necesita `TextEditingController` (Stateful)
   - Necesita manejar `_isDrawerOpen` (Stateful local UI)
   - Según `.cursorrules`, setState es permitido para UI local

---

## 🚀 Próximos Pasos (DÍA 5)

Una vez completado el testing del DÍA 4:

1. **DÍA 5 - Sprint 5.1:** Provider para editar fichajes
2. **DÍA 5 - Sprint 5.2:** Modal de edición de fichaje
3. **DÍA 5 - Sprint 5.3:** Integrar en EmployeeDetailScreen
4. **DÍA 5 - Sprint 5.4:** Actualizar Firestore Rules
5. **DÍA 5 - Sprint 5.5:** Testing de ediciones

---

**Estado actual:** Esperando resultados de testing para marcar DÍA 4 como completado ✅

