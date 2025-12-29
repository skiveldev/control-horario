# Mi Control Horario - Documentación

## Descripción General

"Mi Control Horario" es una pantalla adicional en el dashboard de empleados que permite visualizar y gestionar todos los registros de tiempo del mes de forma completa e intuitiva.

## Características Implementadas

### ✅ Vista Mensual Completa
- Navegación entre meses con flechas
- Resumen ejecutivo del mes (horas trabajadas, planificadas, diferencia)
- Lista de todos los días del mes con registros colapsables/expandibles
- Indicador visual del día actual

### ✅ Control de Meses Futuros
- Deshabilita la navegación hacia meses futuros
- Muestra mensaje informativo: "No se ha activado los días para este mes"
- Botón para volver al mes actual

### ✅ Gestión de Registros
- **Añadir:** Crear nuevos registros desde cada día
- **Editar:** Modificar registros existentes sin restricciones de fecha
- **Copiar:** Duplicar un registro a otro día
- **Eliminar:** Borrar registros con confirmación

### ✅ Sistema de Validación/Bloqueo
- **Estados de registro:**
  - `Editable`: Registro normal, puede ser modificado libremente
  - `Validado`: Marcado por admin, puede editarse pero queda como "modificado"
  - `Bloqueado`: No puede ser editado ni eliminado por el empleado
  - `Modificado post-validación`: Editado después de ser validado

- **Indicadores visuales:**
  - Badges de estado en cada registro
  - Modal informativo al intentar editar registro bloqueado
  - Aviso al editar registro validado

### ✅ Diseño Tabla-Like
- Vista expandida con encabezados: TIEMPO | CATEGORÍA | UBICACIÓN | ESTADO
- Filas horizontales con hover effect
- Iconos de acción sin texto (✏️ 📋 🗑️)
- Botón "+ Añadir" con border dashed

### ✅ Modal Añadir/Editar Profesional
- Tabs mejorados para Trabajo/Pausa con iconos grandes
- Time pickers con validación en tiempo real
- Cálculo automático de duración
- Dropdown de ubicación con iconos
- Validación de solapamientos (preparado)
- Responsive: Dialog en desktop, BottomSheet en mobile

### ✅ Responsive Design
- Mobile (<768px): Vista compacta con cards
- Tablet (768-1024px): Vista intermedia
- Desktop (>1024px): Vista tabla completa

## Arquitectura

### Estructura de Archivos

```
lib/features/dashboard/
├── models/
│   └── time_record_model.dart          # Modelo de registro individual
├── services/
│   └── time_records_service.dart       # Servicio Firestore
├── providers/
│   └── time_records_provider.dart      # Providers Riverpod
└── presentation/
    ├── screens/
    │   └── my_time_control_screen.dart # Pantalla principal
    └── widgets/
        ├── month_navigation_header.dart     # Header con navegación
        ├── day_record_card.dart              # Card de día
        ├── add_edit_record_modal.dart        # Modal principal
        ├── blocked_record_modal.dart         # Modal de bloqueado
        ├── category_tab_selector.dart        # Tabs de categoría
        └── future_month_empty_state.dart     # Estado de mes futuro

lib/shared/widgets/inputs/
└── time_picker_field.dart              # Campo de hora
```

### Modelo de Datos

```typescript
interface TimeRecord {
  id: string;
  userId: string;
  date: string;              // "2025-12-01"
  category: 'work' | 'break';
  startTime: string;         // "07:30"
  endTime: string;           // "14:00"
  location: string;          // "Oficina"
  durationMinutes: number;   // 390
  createdAt: Timestamp;
  updatedAt: Timestamp;
  createdBy: string;
  isManual: boolean;
  copiedFrom?: string;
  
  // Sistema de validación
  validationStatus: 'editable' | 'validated' | 'blocked' | 'modified_after_validation';
  validatedBy?: string;
  validatedAt?: Timestamp;
  blockedBy?: string;
  blockedAt?: Timestamp;
  blockReason?: string;
}
```

### Flujo de Datos

1. **Usuario navega a "Mi Control Horario"**
   - `MyTimeControlScreen` obtiene el usuario actual
   - Observa `monthTimeRecordsProvider` para el mes seleccionado
   - Renderiza lista de días con sus registros

2. **Usuario añade registro**
   - Click en "+ Añadir" del día
   - Abre `AddEditRecordModal`
   - Usuario completa formulario
   - Llama a `timeRecordsNotifier.addRecord()`
   - Firestore actualiza automáticamente el stream
   - UI se actualiza reactivamente

3. **Usuario edita registro**
   - Click en ✏️ del registro
   - Verifica si está bloqueado → Muestra `BlockedRecordModal`
   - Si es editable → Abre `AddEditRecordModal` con datos
   - Si está validado → Muestra aviso, permite editar
   - Llama a `timeRecordsNotifier.updateRecord()`
   - Estado cambia a `modified_after_validation` si estaba validado

4. **Usuario copia registro**
   - Click en 📋 del registro
   - Muestra DatePicker para seleccionar día destino
   - Llama a `timeRecordsNotifier.copyRecord()`
   - Crea nuevo registro en la fecha seleccionada

5. **Usuario elimina registro**
   - Click en 🗑️ del registro
   - Muestra diálogo de confirmación
   - Llama a `timeRecordsNotifier.deleteRecord()`
   - Registro desaparece de la lista

## Uso

### Acceso
1. Login como empleado
2. Click en hamburger menu (mobile) o sidebar (desktop)
3. Click en "Mi Control Horario"

### Navegación
- **Flechas ← →**: Cambiar mes
- **Volver al mes actual**: Desde empty state de mes futuro

### Gestión de Registros
1. **Añadir:**
   - Expandir el día deseado
   - Click en "+ Añadir"
   - Seleccionar tipo (Trabajo/Pausa)
   - Ingresar horas
   - Seleccionar ubicación
   - Guardar

2. **Editar:**
   - Click en ✏️ del registro
   - Modificar campos
   - Guardar cambios

3. **Copiar:**
   - Click en 📋 del registro
   - Seleccionar fecha destino
   - Confirmar

4. **Eliminar:**
   - Click en 🗑️ del registro
   - Confirmar eliminación

## Validación y Bloqueo (Admin)

### Estados
- **Validado**: Admin ha revisado y aprobado el registro
  - Empleado puede editar, pero queda marcado como modificado
  - Útil para auditorías y control de cambios

- **Bloqueado**: Admin ha cerrado el registro
  - Empleado NO puede editar ni eliminar
  - Típicamente usado para períodos cerrados (cierre de nómina)
  - Muestra modal informativo con detalles del bloqueo

### Funciones Admin (Pendientes de UI)
Los métodos están implementados en `TimeRecordsService`:
- `validateRecord()`: Marcar como validado
- `blockRecord()`: Bloquear registro
- `unblockRecord()`: Desbloquear registro

## Pendientes (Futuras Implementaciones)

### No Implementado Ahora
- ❌ Panel de admin para validar/bloquear registros
- ❌ Sistema de festivos y ausencias
- ❌ Funcionalidad del menú de 3 puntos (ver resumen, copiar día, exportar)
- ❌ Validación avanzada de solapamientos
- ❌ Historial de cambios y auditoría
- ❌ Reportes PDF del mes
- ❌ Estadísticas y gráficos

### Recomendaciones para Futuras Mejoras
1. **Validación de Solapamientos:**
   - Detectar registros que se solapan en tiempo
   - Mostrar warning en el modal
   - Permitir override con confirmación

2. **Historial de Cambios:**
   - Registrar cada modificación en subcolección `history`
   - Mostrar quién editó qué y cuándo
   - Útil para auditorías

3. **Notificaciones:**
   - Notificar al empleado cuando un registro es validado/bloqueado
   - Recordatorio de registros pendientes

4. **Límites y Restricciones:**
   - Máximo de horas por día
   - Mínimo de pausa requerida
   - Validación de horarios laborales

## Índices de Firestore Requeridos

Ver `firestore_indexes.md` para detalles completos.

**Índice principal necesario:**
- Colección: `time_records`
- Campos: `date` (ASC), `startTime` (ASC)

## Testing

### Manual Testing
- ✅ Navegación entre meses
- ✅ Control de mes futuro
- ✅ Añadir registro
- ✅ Editar registro normal
- ✅ Editar registro validado (aviso)
- ✅ Intentar editar registro bloqueado (modal)
- ✅ Copiar registro
- ✅ Eliminar registro
- ✅ Responsive en mobile, tablet, desktop

### Tests Automatizados (Pendiente)
- [ ] Unit tests de providers
- [ ] Unit tests de service
- [ ] Widget tests de componentes
- [ ] Integration test del flujo completo

## Problemas Conocidos

Ninguno reportado hasta el momento.

## Soporte

Para dudas o problemas, contactar con el equipo de desarrollo.

---

**Última actualización:** 14 Diciembre 2025
**Versión:** 1.0.0
**Estado:** ✅ Implementado y funcional












