# 📝 Implementación: Editar Hora de Entrada

**Fecha:** 21 de Noviembre 2025  
**Componente:** `EditEntranceDialog`  
**Estado:** ✅ Completado

---

## 📦 Archivo Creado

`lib/features/dashboard/presentation/widgets/edit_entrance_dialog.dart`

---

## 🎯 Características Implementadas

### ✅ Diseño Responsive
- **Desktop/Tablet**: Dialog centrado (380px ancho)
- **Mobile**: Bottom Sheet con handle visual

### ✅ Validaciones en Tiempo Real
1. **Hora no puede ser futura**: No permite seleccionar horas posteriores a la actual
2. **Entrada antes de salida**: Si hay salida registrada, valida que entrada < salida
3. **Sin cambios**: Deshabilita guardar si no modificó la hora
4. **Feedback visual**: Muestra errores en rojo con iconos descriptivos

### ✅ Restricciones
- Solo permite editar el día actual
- Requiere que exista un fichaje de entrada previo
- Salida es opcional (puede estar trabajando)

---

## 🔧 Uso del Componente

### Ejemplo Básico

```dart
import 'package:flutter/material.dart';
import 'edit_entrance_dialog.dart';

// Llamar desde botón "Editar Entrada" en Acciones Rápidas
void _editEntrance(BuildContext context) {
  showEditEntranceDialog(
    context: context,
    currentEntrance: TimeOfDay(hour: 9, minute: 0), // Hora actual registrada
    exitTime: TimeOfDay(hour: 18, minute: 0), // Opcional: null si no fichó salida
    onSave: (newTime) {
      // TODO [FASE-2]: Guardar en Firebase/Riverpod
      print('Nueva hora de entrada: ${newTime.hour}:${newTime.minute}');
      
      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hora de entrada actualizada')),
      );
    },
  );
}
```

### Desde Acciones Rápidas

```dart
// lib/features/dashboard/presentation/widgets/quick_actions_card.dart

CustomButton(
  text: 'Editar Entrada',
  icon: Icons.edit_calendar,
  variant: ButtonVariant.outline,
  onPressed: () => _editEntrance(context),
)
```

### Desde Tabla de Registros (Solo HOY)

```dart
// lib/features/dashboard/presentation/widgets/records_table.dart

Widget _buildTableRow(Map<String, dynamic> record) {
  final isToday = record['date'] == _getTodayFormatted();
  
  return TableRow(
    children: [
      _buildTableCell(record['date']),
      _buildEditableTimeCell(
        record['entrance'],
        isEditable: isToday,
        onEdit: isToday ? () {
          showEditEntranceDialog(
            context: context,
            currentEntrance: _parseTime(record['entrance']),
            exitTime: _parseTime(record['exit']),
            onSave: (newTime) {
              // Guardar cambio
            },
          );
        } : null,
      ),
      // ... resto de celdas
    ],
  );
}

Widget _buildEditableTimeCell(String time, {bool isEditable = false, VoidCallback? onEdit}) {
  return Padding(
    padding: AppSpacing.allMd,
    child: Row(
      children: [
        Text(time, style: AppTextStyles.bodyMedium),
        if (isEditable && onEdit != null) ...[
          AppSpacing.horizontalSpaceXs,
          InkWell(
            onTap: onEdit,
            child: Icon(
              Icons.edit,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    ),
  );
}
```

---

## 🎨 Aspectos Visuales

### Desktop (Dialog)
- Ancho máximo: 380px
- Padding: 24px
- Bordes redondeados: 16px
- TimePicker visual grande
- Botones lado a lado

### Mobile (Bottom Sheet)
- Ancho completo
- Handle superior para arrastrar
- Bordes superiores redondeados: 20px
- Botones apilados (uno debajo del otro)
- Responsive al teclado

---

## 🔐 Validaciones Implementadas

### 1. Hora Futura
```dart
// Error: "No puedes registrar una hora futura"
if (selectedTime > TimeOfDay.now()) {
  showError();
}
```

### 2. Entrada vs Salida
```dart
// Error: "La entrada debe ser anterior a la salida (18:00)"
if (exitTime != null && selectedTime >= exitTime) {
  showError();
}
```

### 3. Sin Cambios
```dart
// Botón deshabilitado si hora no cambió
if (selectedTime == currentEntrance) {
  disableSaveButton();
}
```

---

## 🚀 Próximos Pasos (Fase 2)

### Integración con Riverpod

```dart
// TODO [FASE-2-SPRINT-X]: Crear provider para editar entrada

@riverpod
class EditEntranceNotifier extends _$EditEntranceNotifier {
  @override
  FutureOr<void> build() {}
  
  Future<void> updateEntrance({
    required String recordId,
    required TimeOfDay newTime,
  }) async {
    state = const AsyncLoading();
    
    try {
      // Actualizar en Firestore
      await ref.read(clockingServiceProvider).updateEntrance(
        recordId: recordId,
        newTime: newTime,
      );
      
      // Actualizar cache local
      ref.invalidate(todayClockingProvider);
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
```

### Uso con Riverpod

```dart
void _editEntrance(BuildContext context, WidgetRef ref) {
  showEditEntranceDialog(
    context: context,
    currentEntrance: TimeOfDay(hour: 9, minute: 0),
    exitTime: TimeOfDay(hour: 18, minute: 0),
    onSave: (newTime) async {
      await ref.read(editEntranceNotifierProvider.notifier).updateEntrance(
        recordId: 'today_record_id',
        newTime: newTime,
      );
    },
  );
}
```

---

## ✅ Checklist de Calidad

- [x] Responsive (Dialog + BottomSheet)
- [x] Validaciones en tiempo real
- [x] Feedback visual de errores
- [x] Usa sistema de diseño (AppColors, AppSpacing, AppTextStyles)
- [x] Sin overflow en textos
- [x] TimePicker nativo de Flutter
- [x] Estados deshabilitados correctos
- [x] Documentación completa
- [x] Sin errores de linter
- [x] Cumple .cursorrules

---

## 📚 Documentación de Referencia

- **Componente similar**: `early_exit_dialog.dart`
- **Sistema de colores**: `lib/core/theme/app_colors.dart`
- **Breakpoints**: `lib/core/constants/breakpoints.dart`
- **Botones**: `lib/shared/widgets/buttons/custom_button.dart`

