# 📋 FASE 2 - RESUMEN EJECUTIVO

**Estado**: 🚧 Planificación Completada - Listo para Implementar  
**Documento completo**: `../.cursor/plans/fase-2-backend-logica.plan.md`

---

## 🎯 Objetivo
Implementar backend funcional con Firebase + Riverpod, reemplazando todos los datos mock de Fase 1.

## 🏗️ Stack Técnico
- **State Management**: **Riverpod** (único y obligatorio)
  - 31 providers funcionales a implementar
  - Code generation con `riverpod_generator`
  - NO usar setState para estado de aplicación, Provider, BLoC, GetX
  - setState permitido SOLO para UI local (TextField, hover, etc.)
- **Backend**: Firebase (Auth, Firestore, Functions, Storage)
- **UI**: Material Design 3 + Custom Theme (Fase 1)
- **Navegación**: go_router (Fase 1)

---

## 👥 Requisitos Clave del Cliente

- **458 empleados** (docentes + no docentes)
- **Sistema de fichaje**: Entrada → Pausa (1 sola) → Retorno → Salida
- **3 roles**: Empleado (456) | RRHH (1) | Admin (1)
- **Histórico**: 4 años (3 meses accesibles, resto archivado)
- **Budget**: Plan gratuito Firebase

---

## 🗄️ Estructura Firebase (Simplificada)

```
firestore/
├── users/{userId}
│   ├── daily_records/{YYYY-MM-DD}      # 1 doc por día
│   └── monthly_summary/{YYYY-MM}       # Resúmenes pre-calculados
├── schedules/{scheduleId}              # Horarios de trabajo
├── overtime_requests/{requestId}       # Aprobaciones de horas extras
└── system_config/settings              # Configuración global
```

---

## 📅 Plan de 5 Sprints (6 semanas)

### Sprint 1: MVP - Core Básico (Semana 1)
**Entregable**: Login + Fichaje Entrada/Salida

```typescript
// Documento mínimo
{
  date: "2025-11-20",
  clocks: {
    clockIn: "08:30:00",
    clockOut: "17:00:00"
  },
  status: "complete"
}
```

**Tareas**:
- [ ] Configurar Firebase (Auth + Firestore)
- [ ] AuthProvider + Login funcional
- [ ] ClockingProvider + Botones de fichaje
- [ ] Dashboard con registros del mes

---

### Sprint 2: Pausas + Validaciones (Semana 2)
**Entregable**: Sistema de pausas + Máquina de estados

```typescript
// Agregar campos
{
  clocks: {
    clockIn: "08:30:00",
    breakStart: "13:00:00",    // ✨ Nuevo
    breakEnd: "14:00:00",      // ✨ Nuevo
    clockOut: "17:00:00"
  },
  totalWorkedMinutes: 480      // ✨ Nuevo
}
```

**Tareas**:
- [ ] ClockingStateProvider (máquina de estados)
- [ ] Deshabilitar botones según estado
- [ ] Cálculo de horas trabajadas
- [ ] Diálogo de confirmación (salida anticipada)

---

### Sprint 3: Panel Admin (Semana 3)
**Entregable**: Admin ve todos + Correcciones

```typescript
// Agregar campos
{
  editHistory: [{             // ✨ Nuevo
    field: "clockIn",
    oldValue: "08:45:00",
    newValue: "08:30:00",
    editedBy: "uid_admin",
    editedAt: Timestamp
  }],
  wasEdited: true              // ✨ Nuevo
}
```

**Tareas**:
- [ ] AdminEmployeesProvider (lista todos)
- [ ] AdminClockingProvider (corregir fichajes)
- [ ] AnomaliesProvider (fichajes incompletos)
- [ ] Historial de ediciones

---

### Sprint 4: Automatización (Semana 4)
**Entregable**: Cierre auto + Horas extras

```typescript
// Nueva colección: overtime_requests
{
  userId: "...",
  weekNumber: 47,
  overtimeMinutes: 120,
  status: "pending"           // pending | approved | rejected
}

// Campo en daily_records
{
  autoClosedAt: "17:00:00",   // ✨ Nuevo
  requiresReview: true         // ✨ Nuevo
}
```

**Tareas**:
- [ ] Cloud Function: autoCloseRecords (diaria)
- [ ] Cloud Function: detectOvertime (semanal)
- [ ] OvertimeProvider (aprobar/rechazar)
- [ ] Panel de solicitudes de horas extras

---

### Sprint 5: Reportes (Semana 5)
**Entregable**: Reportes + PDF + Archivado

```typescript
// Nueva subcolección: monthly_summary
{
  month: "2025-11",
  totalDaysWorked: 20,
  totalMinutesWorked: 9600,
  overtimeMinutes: 120
}
```

**Tareas**:
- [ ] Cloud Function: generateMonthlySummaries
- [ ] Cloud Function: archiveOldRecords
- [ ] ReportsProvider + Pantalla de reportes
- [ ] PDFExportProvider + Generación de PDF

---

## 💰 Optimización de Costos

### Límites Plan Gratuito
- 50,000 reads/día
- 20,000 writes/día
- 1 GB storage

### Nuestro Uso (Optimizado)
- ~12,000 reads/día ✅ (24% del límite)
- ~2,000 writes/día ✅ (10% del límite)
- ~60 MB storage ✅ (6% del límite)

**Resultado**: $0/mes (dentro del plan gratuito)

### Estrategias Clave
1. **Caché local**: 60-80% menos reads
2. **Paginación**: Cargar solo 7 días por defecto
3. **Resúmenes pre-calculados**: 1 read vs 22 reads
4. **Archivado**: Mover registros >3 meses a Cloud Storage

---

## 📊 Métricas de Éxito

### Sprint 1
- ✅ Login funcional con Firebase Auth
- ✅ Fichaje funcional (guardar en Firestore)
- ✅ Dashboard muestra registros reales

### Sprint 2
- ✅ Sistema de pausas funcional
- ✅ Botones deshabilitados según estado
- ✅ Cálculo correcto de horas trabajadas

### Sprint 3
- ✅ Admin ve lista de 458 empleados
- ✅ Admin puede corregir cualquier fichaje
- ✅ Historial de ediciones guardado

### Sprint 4
- ✅ Fichajes incompletos se cierran automáticamente
- ✅ Horas extras detectadas y en cola de aprobación
- ✅ RRHH puede aprobar/rechazar

### Sprint 5
- ✅ Reportes mensuales generados
- ✅ Exportación a PDF funcional
- ✅ Registros >3 meses archivados en Storage

---

## 🔐 Reglas de Seguridad (Resumen)

```javascript
// Empleado
- Leer: Solo sus propios registros
- Crear: Fichajes propios
- Editar: Solo clockIn, solo hoy, sin aprobación

// RRHH
- Leer: Todos los empleados
- Reportes: Generar y exportar
- Aprobar: Horas extras

// Admin
- Todo lo de RRHH +
- Crear/eliminar usuarios
- Editar cualquier fichaje (con historial)
- Configuración del sistema
```

---

## 🧪 Testing

### Cobertura Objetivo
- Unit Tests: 80%
- Widget Tests: 60%
- Integration Tests: 5-10 flujos críticos
- Cloud Functions Tests: 100%

### Herramientas
- Firebase Emulator Suite (testing local)
- Mockito + fake_cloud_firestore
- Flutter test + Integration test

---

## 📦 Dependencias Nuevas

```yaml
# Firebase
firebase_core: ^2.24.0
firebase_auth: ^4.15.0
cloud_firestore: ^4.13.0
firebase_storage: ^11.5.0

# Code Generation
freezed: ^2.4.5
json_serializable: ^6.7.1
riverpod_generator: ^2.3.0

# PDF
pdf: ^3.10.0
printing: ^5.11.0
```

---

## ✅ Checklist Rápido

### Preparación
- [ ] Crear proyecto Firebase
- [ ] Habilitar Auth (Email/Password)
- [ ] Crear Firestore (modo test)
- [ ] Habilitar Functions (plan Blaze)
- [ ] Ejecutar `flutterfire configure`
- [ ] Configurar emuladores

### Por cada Sprint
- [ ] Implementar providers
- [ ] Actualizar UI conectar datos reales
- [ ] Escribir tests
- [ ] Probar en emulador
- [ ] Code review
- [ ] Deploy (si aplica)

---

## 🚀 Próximo Paso

**Iniciar Sprint 1**: Configurar Firebase y construir MVP

Comando para empezar:
```bash
# 1. Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Configurar proyecto
flutterfire configure

# 3. Iniciar emuladores
firebase init emulators
firebase emulators:start
```

---

**Documento completo**: Ver `../.cursor/plans/fase-2-backend-logica.plan.md` para especificaciones detalladas.

