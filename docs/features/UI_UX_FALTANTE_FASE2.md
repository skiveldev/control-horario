# 🎨 UI/UX FALTANTE PARA FASE 2

## 📋 Documento de Especificaciones UI/UX

**Proyecto**: Control Horario - Escuela de Música  
**Versión**: 2.0.0  
**Fecha**: Noviembre 2025  
**Estado**: 📝 Especificación para Implementación

---

## 🎯 Objetivo

Este documento lista EXCLUSIVAMENTE los cambios y elementos UI/UX que faltan o deben modificarse en las pantallas existentes para alinearlas con la lógica de negocio y base de datos de Fase 2.

**NO incluye**: Lógica de negocio, providers Riverpod, Firebase, ni implementación backend.

---

## 1️⃣ PANEL EMPLEADO - Dashboard (`dashboard_screen.dart`)

### ✅ Estado Actual
- ✅ Reloj con hora actual
- ✅ Botones de fichaje (Entrada/Pausa/Retorno/Salida)
- ✅ Resumen del día (horas trabajadas, progreso)
- ✅ Tabla de registros recientes
- ✅ Calendario mensual
- ✅ Resumen semanal

### 🔧 Cambios UI/UX Necesarios

#### 1.1. Banner de Estado Actual
**Estado**: ❌ YA EXISTE - NO HACER CAMBIOS

El estado actual ya se muestra en el componente `ClockingButtons`. No agregar banner adicional.

#### 1.2. Botones de Fichaje - Estados Visuales
**Archivo**: `lib/features/dashboard/presentation/widgets/clocking_buttons.dart`

**Cambios**:
- ✅ Los botones ya tienen la estructura de estados (`ClockingState`)
- ✅ Solo conectar con Riverpod provider (backend, no UI)
- ⚠️ **UI**: Verificar que los estados deshabilitados sean visualmente claros:
  - Botón deshabilitado: Opacidad 0.4, cursor not-allowed
  - Botón habilitado: Opacidad 1.0, hover effect
  - Color según estado (verde/naranja/azul/gris)

**Estados visuales a verificar**:
```
NOT_STARTED    → Solo "Entrada" habilitado (verde)
WORKING        → "Pausa" y "Salida" habilitados (naranja/rojo)
ON_BREAK       → Solo "Retorno" habilitado (azul)
RETURNED       → "Pausa" y "Salida" habilitados (= WORKING)
FINISHED       → Todos deshabilitados (gris)
```

#### 1.3. Diálogo de Confirmación - Salida Anticipada
**Archivo**: Nuevo widget `lib/features/dashboard/presentation/widgets/early_exit_dialog.dart`

**Cuándo mostrar**: Al presionar "Salida" si faltan más de 1 hora para terminar jornada.

**Diseño del diálogo**:
```
┌─────────────────────────────────────┐
│  ⚠️  Salida Anticipada              │
├─────────────────────────────────────┤
│                                     │
│  Aún te faltan 2h 15min para       │
│  completar tu jornada.             │
│                                     │
│  ¿Estás seguro de fichar salida?   │
│                                     │
│  [ Cancelar ]    [ Confirmar ]     │
└─────────────────────────────────────┘
```

**Especificaciones**:
- Icono: Warning (⚠️) color `AppColors.warning`
- Texto: Mostrar horas faltantes dinámicamente
- Botones:
  - "Cancelar": `ButtonVariant.secondary`
  - "Confirmar": `ButtonVariant.primary` (rojo si es crítico)
- Ancho máximo: 400px
- Bordes redondeados: 16px
- Sombra: `elevation: 24`

#### 1.4. Tabla de Registros Recientes - Indicadores Visuales
**Archivo**: `lib/features/dashboard/presentation/widgets/records_table.dart`

**Nuevos badges/estados**:
- 🔴 **"Incompleto"** - Fichaje sin salida (color rojo)
- ⚙️ **"Auto-cerrado"** - Cierre automático (color naranja, icono ⚙️)
- ✏️ **"Editado"** - Registro modificado (color azul, icono ✏️)
- ✅ **"Completo"** - Normal (color verde)

**Columna adicional**: "Estado" (después de "Salida")

**Tooltip en hover**: 
- Para "Auto-cerrado": "Este fichaje fue cerrado automáticamente"
- Para "Editado": "Este fichaje fue corregido" (mostrar ícono info)

---

## 2️⃣ PERFIL DE EMPLEADO (`profile_screen.dart`)

### ✅ Estado Actual
- ✅ Avatar con foto de perfil
- ✅ Información personal (nombre, email, ID)
- ✅ Información laboral (puesto, departamento, horario)
- ✅ Sección de contacto
- ✅ Sección de preferencias

### 🔧 Cambios UI/UX Necesarios

#### 2.1. Información Laboral
**Archivo**: `lib/features/dashboard/presentation/screens/profile_screen.dart`

**Cambios en campos**:
- ✅ **Mantener**: "Departamento" (información necesaria)
- ✅ **Cambiar**: "Horas diarias" → **"Horas semanales"**
  - Label: "Horas Semanales Contratadas"
  - Ejemplo: "40 horas/semana"
- ❌ **NO agregar**: "Tipo de contrato"
- ❌ **NO agregar**: Sección "Resumen del Mes" (esto va en Panel RRHH)
- ❌ **NO expandir**: Sección "Horario" detallado (mantener simple)

**Formato actual correcto**:
```
╔═══════════════════════════════════════╗
║  📋 Información Laboral               ║
╠═══════════════════════════════════════╣
║  Puesto:          Profesor de Piano   ║
║  Departamento:    Música Clásica      ║
║  ID Empleado:     EMP-001             ║
║  Horas Semanales: 40 horas/semana     ║ ← CAMBIO AQUÍ
║  Horario:         Lunes-Viernes 9-17h ║
╚═══════════════════════════════════════╝
```

#### 2.2. Botón "Editar Perfil"
**Archivo**: `lib/features/dashboard/presentation/screens/profile_screen.dart`

**Estado actual**: Solo muestra SnackBar (mock)

**Cambio UI/UX necesario**: 
1. **Agregar pantalla modal o nueva ruta**: `/profile/edit`
2. **Crear widget**: `ProfileEditDialog` o `ProfileEditScreen`

**Campos editables por el empleado**:
- ✅ Nombre completo
- ✅ Foto de perfil (upload de imagen)
- ✅ Teléfono
- ✅ Preferencias (idioma, notificaciones)

**Campos NO editables** (solo visualización):
- ❌ Email (requiere re-autenticación)
- ❌ ID Empleado
- ❌ Puesto
- ❌ Departamento
- ❌ Horario
- ❌ Horas semanales

**Diseño del formulario de edición**:
```
┌───────────────────────────────────────┐
│  ✏️  Editar Perfil                    │
├───────────────────────────────────────┤
│                                       │
│  📷  [Avatar actual]   [Cambiar foto]│
│                                       │
│  Nombre completo *                    │
│  [________________]                   │
│                                       │
│  Teléfono                             │
│  [________________]                   │
│                                       │
│  Preferencias                         │
│  ☐ Notificaciones de email           │
│  ☐ Recordatorios de fichaje          │
│                                       │
│  [ Cancelar ]       [ Guardar ]      │
└───────────────────────────────────────┘
```

**Especificaciones**:
- Validación en tiempo real (nombre no vacío, teléfono formato válido)
- Botón "Guardar" deshabilitado hasta que haya cambios
- Confirmación: SnackBar "Perfil actualizado correctamente"
- Error: Mostrar mensaje si falla el guardado

---

## 3️⃣ PANEL ADMIN (`admin_dashboard_screen.dart`)

### ✅ Estado Actual
- ✅ Lista de todos los empleados
- ✅ Estadísticas generales (total empleados, activos, fichajes hoy)
- ✅ Búsqueda de empleados
- ✅ Detalle de empleado individual

### 🔧 Cambios UI/UX Necesarios

#### 3.1. Diferenciación de Roles Admin vs RRHH
**Archivo**: `lib/features/admin/presentation/screens/admin_dashboard_screen.dart`

**Problema actual**: Solo existe un "Panel Admin" sin diferenciar rol RRHH.

**Solución UI/UX**:
- El mismo componente `AdminDashboardScreen` se reutiliza
- **Cambio visual**: El título y las opciones cambian según el rol del usuario logueado

**Título dinámico**:
```dart
// Si rol == 'admin'
"Panel de Administración"

// Si rol == 'rrhh'
"Panel de Recursos Humanos"
```

**Opciones visibles por rol**:

| Opción | Admin | RRHH |
|--------|-------|------|
| Ver empleados | ✅ | ✅ |
| Crear usuario | ✅ | ❌ |
| Eliminar usuario | ✅ | ❌ |
| Editar fichajes | ✅ | ✅ |
| Ver reportes | ✅ | ✅ |
| Aprobar horas extras | ✅ | ✅ |
| Configuración del sistema | ✅ | ❌ |

**Implementación UI**:
- Mostrar/ocultar botones según rol
- Deshabilitar acciones no permitidas
- Mensaje de tooltip: "Requiere permisos de administrador"

#### 3.2. Sección "Anomalías" (Fichajes Incompletos)
**Archivo**: Nuevo widget `lib/features/admin/presentation/widgets/anomalies_list.dart`

**Ubicación**: Tab/sección dentro del panel admin

**Diseño**:
```
┌─────────────────────────────────────────────┐
│  ⚠️  Fichajes con Anomalías (12)            │
├─────────────────────────────────────────────┤
│  Filtros: [Todos ▼] [Esta semana ▼]        │
├─────────────────────────────────────────────┤
│                                             │
│  🔴 Juan Pérez - 2025-11-18                │
│     Sin fichaje de salida                  │
│     [Ver detalle] [Corregir]               │
│                                             │
│  ⚙️ María García - 2025-11-17              │
│     Cierre automático                      │
│     [Ver detalle] [Revisar]                │
│                                             │
│  ...                                        │
│                                             │
└─────────────────────────────────────────────┘
```

**Tipos de anomalías**:
- 🔴 **Incompleto**: Sin salida (más urgente)
- ⚙️ **Auto-cerrado**: Cerrado por el sistema
- ✏️ **Editado por admin**: Corrección manual

**Filtros**:
- Tipo: Todos / Incompletos / Auto-cerrados / Editados
- Período: Hoy / Esta semana / Este mes / Rango personalizado
- Empleado: Búsqueda por nombre

#### 3.3. Modal de Corrección de Fichaje
**Archivo**: Nuevo widget `lib/features/admin/presentation/widgets/edit_clocking_dialog.dart`

**Diseño**:
```
┌─────────────────────────────────────────┐
│  ✏️  Corregir Fichaje                   │
├─────────────────────────────────────────┤
│  Empleado: Juan Pérez                   │
│  Fecha: 2025-11-18                      │
│                                         │
│  Entrada:  [08:30] ←                    │
│  Pausa:    [13:00]                      │
│  Retorno:  [14:00]                      │
│  Salida:   [____] ← Campo a editar      │
│                                         │
│  Motivo de corrección:                  │
│  [________________________]             │
│  [________________________]             │
│                                         │
│  ⚠️ Esta acción quedará registrada     │
│                                         │
│  [ Cancelar ]       [ Guardar ]        │
└─────────────────────────────────────────┘
```

**Especificaciones**:
- Time pickers para cada campo
- Campo "Motivo" obligatorio (mínimo 10 caracteres)
- Warning visual: "Esta acción quedará registrada en el historial"
- Validación: No permitir horas inválidas (entrada < salida)
- Confirmación: "Fichaje corregido correctamente"

---

## 4️⃣ PANEL RRHH (NUEVO)

### ❌ Estado Actual
**No existe pantalla específica para RRHH**

### 🔧 Pantalla Nueva a Crear

**Archivo**: `lib/features/admin/presentation/screens/rrhh_dashboard_screen.dart`

**Nota**: En realidad, reutilizaremos `admin_dashboard_screen.dart` pero con opciones filtradas por rol (ver sección 3.1).

#### 4.1. Contenido del Panel RRHH

**Pantalla principal**:
```
┌───────────────────────────────────────────────┐
│  Panel de Recursos Humanos                   │
├───────────────────────────────────────────────┤
│                                               │
│  📊 Resumen General                           │
│  ┌──────────┬──────────┬──────────┐          │
│  │ Empleados│ Fichajes │  Horas   │          │
│  │   458    │   Hoy    │  Extras  │          │
│  │          │   442    │    12    │          │
│  └──────────┴──────────┴──────────┘          │
│                                               │
│  Tabs:                                        │
│  [Empleados] [Reportes] [Horas Extras]       │
│  [Anomalías] [Horarios]                      │
│                                               │
└───────────────────────────────────────────────┘
```

#### 4.2. Tab "Reportes" - Resumen Mensual por Empleado
**Archivo**: Nuevo widget `lib/features/admin/presentation/widgets/monthly_reports_card.dart`

**Diseño**:
```
┌─────────────────────────────────────────────┐
│  📈 Reportes Mensuales                      │
├─────────────────────────────────────────────┤
│  Filtros:                                   │
│  Empleado: [Buscar...]                      │
│  Mes: [Noviembre 2025 ▼]                    │
│  Departamento: [Todos ▼]                    │
│  [ Buscar ]                                 │
├─────────────────────────────────────────────┤
│                                             │
│  Juan Pérez (EMP-001)                       │
│  Departamento: Música Clásica               │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ 📊 Resumen del Mes - Noviembre 2025│   │
│  ├─────────────────────────────────────┤   │
│  │                                     │   │
│  │  Horas Trabajadas:    168h 30min   │   │
│  │  Días Trabajados:     21 días      │   │
│  │  Promedio Diario:     8h 02min     │   │
│  │  Horas Extras:        8h 30min ⚠️  │   │
│  │                                     │   │
│  │  ⚠️ Fichajes Incompletos: 2        │   │
│  │  ⚙️ Cierres Automáticos: 1         │   │
│  │                                     │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  [📄 Exportar PDF] [📊 Ver Detalles]       │
│                                             │
└─────────────────────────────────────────────┘
```

**Especificaciones del Card**:
- **Horas Trabajadas**: Total del mes (formato: XXXh XXmin)
- **Días Trabajados**: Cantidad de días con fichajes completos
- **Promedio Diario**: Total / Días trabajados
- **Horas Extras**: Si > 0, mostrar con icono warning ⚠️
- **Alertas**: Si hay fichajes incompletos o auto-cerrados, mostrar con badge

**Sección de alertas visuales**:
- Si `incompleteDays > 0`: Mostrar badge rojo
- Si `autoClosedDays > 0`: Mostrar badge naranja
- Si `overtimeMinutes > 0`: Mostrar badge amarillo

#### 4.3. Tab "Horas Extras" - Sistema de Aprobación
**Archivo**: Nuevo widget `lib/features/admin/presentation/widgets/overtime_requests_list.dart`

**Diseño**:
```
┌─────────────────────────────────────────────┐
│  ⏱️  Solicitudes de Horas Extras            │
├─────────────────────────────────────────────┤
│  Filtros: [Pendientes ▼] [Este mes ▼]      │
├─────────────────────────────────────────────┤
│                                             │
│  🟡 PENDIENTE                               │
│  María García (EMP-045)                     │
│  Semana 47 (Nov 17-23, 2025)                │
│                                             │
│  Contratadas: 40h | Trabajadas: 44h         │
│  Horas extras: 4h 00min                     │
│                                             │
│  [❌ Rechazar] [✅ Aprobar]                 │
│                                             │
│  ──────────────────────────────────────     │
│                                             │
│  ✅ APROBADA                                │
│  Juan Pérez (EMP-001)                       │
│  Semana 46 (Nov 10-16, 2025)                │
│  Horas extras: 2h 30min                     │
│  Aprobado por: Admin el 18/11/2025          │
│                                             │
└─────────────────────────────────────────────┘
```

**Estados visuales**:
- 🟡 **Pendiente**: Badge amarillo + botones de acción
- ✅ **Aprobada**: Badge verde + info de aprobador
- ❌ **Rechazada**: Badge rojo + info de rechazo

**Modal de Aprobación/Rechazo**:
```
┌─────────────────────────────────────┐
│  Aprobar Horas Extras               │
├─────────────────────────────────────┤
│  Empleado: María García             │
│  Semana: 47 (Nov 17-23)             │
│  Horas extras: 4h 00min             │
│                                     │
│  Notas (opcional):                  │
│  [____________________]             │
│  [____________________]             │
│                                     │
│  [ Cancelar ]  [ Confirmar ]       │
└─────────────────────────────────────┘
```

#### 4.4. Tab "Horarios" - Gestión de Schedules
**Archivo**: Nuevo widget `lib/features/admin/presentation/widgets/schedules_manager.dart`

**Diseño**:
```
┌─────────────────────────────────────────────┐
│  📅 Gestión de Horarios                     │
├─────────────────────────────────────────────┤
│  [ + Crear Nuevo Horario ]                  │
├─────────────────────────────────────────────┤
│                                             │
│  📋 Jornada Estándar (40h/semana)          │
│  Lun-Vie: 9:00 - 17:00                     │
│  Empleados asignados: 320                   │
│  [Ver detalle] [Editar] [Duplicar]         │
│                                             │
│  ──────────────────────────────────────     │
│                                             │
│  📋 Jornada Tarde (40h/semana)             │
│  Lun-Vie: 13:00 - 21:00                    │
│  Empleados asignados: 85                    │
│  [Ver detalle] [Editar] [Duplicar]         │
│                                             │
│  ──────────────────────────────────────     │
│                                             │
│  📋 Docentes Variables (variable)           │
│  Horario personalizado por empleado         │
│  Empleados asignados: 53                    │
│  [Ver detalle] [Editar] [Duplicar]         │
│                                             │
└─────────────────────────────────────────────┘
```

**Modal de Detalle de Horario**:
```
┌─────────────────────────────────────────┐
│  📋 Jornada Estándar                    │
├─────────────────────────────────────────┤
│  Total: 40 horas semanales              │
│                                         │
│  Lunes:     09:00 - 17:00 (8h)         │
│  Martes:    09:00 - 17:00 (8h)         │
│  Miércoles: 09:00 - 17:00 (8h)         │
│  Jueves:    09:00 - 17:00 (8h)         │
│  Viernes:   09:00 - 17:00 (8h)         │
│  Sábado:    Descanso                    │
│  Domingo:   Descanso                    │
│                                         │
│  Pausa comida: 60 minutos (cuenta)      │
│                                         │
│  [ Cerrar ] [ Editar ]                 │
└─────────────────────────────────────────┘
```

---

## 5️⃣ COMPONENTES COMPARTIDOS NUEVOS

### 5.1. Badge de Estado de Fichaje
**Archivo**: `lib/shared/widgets/clocking_status_badge.dart`

**Variantes**:
```dart
enum ClockingStatus {
  complete,      // Verde
  incomplete,    // Rojo
  autoClosed,    // Naranja
  edited,        // Azul
  pending,       // Amarillo
}
```

**Diseño visual**:
- Altura: 24px
- Border radius: 12px
- Padding: 4px 12px
- Font size: 12px
- Font weight: 600

### 5.2. Time Picker Personalizado
**Archivo**: `lib/shared/widgets/inputs/custom_time_picker.dart`

**Especificaciones**:
- Formato 24h
- Incrementos de 1 minuto
- Validación automática (00:00 - 23:59)
- Estilo consistente con `CustomTextField`

### 5.3. Export Button (PDF)
**Archivo**: `lib/shared/widgets/buttons/export_pdf_button.dart`

**Diseño**:
```
[ 📄 Exportar PDF ]
```
- Icono: document icon
- Variant: secondary
- Loading state al exportar
- Success feedback: "PDF descargado"

---

## 6️⃣ NAVEGACIÓN Y RUTAS

### 🔧 Rutas Nuevas a Agregar
**Archivo**: `lib/core/router/app_router.dart`

```dart
// Rutas existentes
'/dashboard'
'/profile'
'/settings'
'/admin'
'/admin/employees'
'/admin/employees/:id'

// ✨ Rutas nuevas para Fase 2
'/profile/edit'                    // Editar perfil empleado
'/admin/anomalies'                 // Lista de anomalías
'/admin/reports'                   // Reportes mensuales
'/admin/overtime'                  // Horas extras
'/admin/schedules'                 // Gestión de horarios
'/admin/employees/:id/edit'        // Editar fichaje (admin)
```

### 🔧 Navegación Dinámica por Rol

**Sidebar/Drawer del panel admin** debe mostrar opciones según rol:

```dart
// Para Admin
- Dashboard
- Empleados
- Reportes
- Horas Extras
- Anomalías
- Horarios
- Configuración ← Solo admin

// Para RRHH
- Dashboard
- Empleados
- Reportes
- Horas Extras
- Anomalías
- Horarios
```

---

## 7️⃣ ESTADOS Y FEEDBACK VISUAL

### 7.1. Estados de Carga (Loading)
**Uso**: Al cargar datos de Firebase

**Implementación**:
- Usar widget existente: `LoadingSpinner`
- Ubicación: Centro de la pantalla o sección específica
- No bloquear toda la UI si es carga parcial

### 7.2. Estados de Error
**Uso**: Si falla una operación

**Implementación**:
- Usar widget existente: `ErrorState`
- Mostrar mensaje de error claro
- Botón "Reintentar" si aplica

### 7.3. Estados Vacíos (Empty)
**Uso**: Si no hay datos que mostrar

**Implementación**:
- Usar widget existente: `EmptyState`
- Mensaje contextual: "No hay fichajes este mes"
- CTA si aplica: "Ficha tu primera entrada"

### 7.4. SnackBars de Confirmación
**Uso**: Feedback de acciones exitosas

**Tipos**:
- ✅ **Success**: "Fichaje registrado correctamente"
- ❌ **Error**: "No se pudo registrar el fichaje"
- ⚠️ **Warning**: "Recuerda fichar tu salida al terminar"
- ℹ️ **Info**: "Tienes 2 fichajes pendientes de revisar"

**Estilo**:
- Duración: 4 segundos
- Posición: Bottom center
- Icono según tipo
- Botón de cerrar (X)

---

## 8️⃣ RESPONSIVE DESIGN

### 🔧 Adaptaciones por Dispositivo

Todos los componentes nuevos deben seguir el sistema de breakpoints existente:

```dart
class Breakpoints {
  static const mobile = 640;   // < 640px
  static const tablet = 768;   // 640-1023px
  static const desktop = 1024; // >= 1024px
}
```

#### Mobile (< 640px)
- Modales y diálogos a pantalla completa
- Botones más grandes (min-height: 48px)
- Tablas con scroll horizontal
- Tabs con scroll horizontal si no caben

#### Tablet (640-1023px)
- Modales con ancho máximo 600px
- Grid de 2 columnas para cards
- Sidebar colapsable

#### Desktop (>= 1024px)
- Modales con ancho máximo 800px
- Grid de 3-4 columnas para cards
- Sidebar siempre visible
- Tooltips en hover

---

## 9️⃣ ACCESIBILIDAD

### 🔧 Requisitos Mínimos

1. **Contrast Ratio**: Mínimo 4.5:1 para textos
2. **Touch Targets**: Mínimo 44x44px en mobile
3. **Focus Indicators**: Visible en navegación por teclado
4. **Screen Readers**: Labels en todos los inputs
5. **Error Messages**: Descriptivos y claros

---

## 🎨 RESUMEN DE WIDGETS NUEVOS A CREAR

### Widgets de Dashboard
- ✅ `early_exit_dialog.dart` - Diálogo de confirmación salida anticipada

### Widgets de Perfil
- ✅ `profile_edit_dialog.dart` - Modal para editar perfil

### Widgets de Admin
- ✅ `anomalies_list.dart` - Lista de fichajes con anomalías
- ✅ `edit_clocking_dialog.dart` - Modal de corrección de fichaje

### Widgets de RRHH
- ✅ `monthly_reports_card.dart` - Card con resumen mensual por empleado
- ✅ `overtime_requests_list.dart` - Lista de solicitudes de horas extras
- ✅ `overtime_approval_dialog.dart` - Modal para aprobar/rechazar horas extras
- ✅ `schedules_manager.dart` - Gestión de horarios
- ✅ `schedule_detail_dialog.dart` - Detalle de un horario

### Widgets Compartidos
- ✅ `clocking_status_badge.dart` - Badge de estados (completo/incompleto/etc)
- ✅ `custom_time_picker.dart` - Selector de hora personalizado
- ✅ `export_pdf_button.dart` - Botón de exportar PDF

**Total de widgets nuevos**: 12

---

## 🎯 PRIORIDADES DE IMPLEMENTACIÓN UI/UX

### Sprint 1: MVP
- ✅ Modificar botones de fichaje (estados deshabilitados)
- ✅ Modificar tabla de registros (columna "Estado")

### Sprint 2: Pausas
- ✅ Diálogo de confirmación salida anticipada

### Sprint 3: Admin
- ✅ Lista de anomalías
- ✅ Modal de corrección de fichaje
- ✅ Diferenciación visual Admin/RRHH

### Sprint 4: Horas Extras
- ✅ Lista de solicitudes de horas extras
- ✅ Modal de aprobación/rechazo

### Sprint 5: Reportes
- ✅ Card de resumen mensual
- ✅ Botón de exportar PDF
- ✅ Gestión de horarios

### Post-Sprint: Perfil
- ✅ Modal de editar perfil
- ✅ Modificar campo "Horas diarias" → "Horas semanales"

---

## 📝 NOTAS FINALES

### Consistencia Visual
- Seguir sistema de diseño existente (`AppColors`, `AppTextStyles`, `AppSpacing`)
- Reutilizar widgets existentes siempre que sea posible
- Mantener coherencia en iconografía y mensajes

### Testing Visual
- Probar en múltiples resoluciones (mobile, tablet, desktop)
- Verificar que no hay overflows
- Comprobar estados de loading/error/empty

### Documentación
- Agregar comentarios explicativos en widgets complejos
- Documentar props y ejemplos de uso
- Actualizar README de widgets compartidos

---

**Equipo**: Control Horario - Escuela de Música  
**Documento**: UI/UX Faltante Fase 2  
**Versión**: 2.0.0  
**Estado**: ✅ Listo para Implementación  
**Fecha**: Noviembre 2025

