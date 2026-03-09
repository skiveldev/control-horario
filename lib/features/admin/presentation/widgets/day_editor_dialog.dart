import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/calendar_event_model.dart';
import '../../models/holiday_type.dart';

/// Diálogo para crear o editar un evento de festivo/vacaciones en el calendario
///
/// Aparece al tocar un día en CalendarEditorScreen.
///
/// Ejemplo de uso:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => DayEditorDialog(
///     selectedDate: DateTime(2025, 1, 1),
///     existingEvent: null,
///     onSave: (event) { ... },
///     onDelete: () { ... },
///   ),
/// );
/// ```
class DayEditorDialog extends StatefulWidget {
  /// Fecha seleccionada en el calendario
  final DateTime selectedDate;

  /// Evento existente (null si es nuevo)
  final CalendarEventModel? existingEvent;

  /// Callback al guardar el evento (o rango de eventos)
  final void Function(List<CalendarEventModel> events) onSave;

  /// Callback al eliminar el evento (solo si existingEvent != null)
  final VoidCallback? onDelete;

  const DayEditorDialog({
    super.key,
    required this.selectedDate,
    this.existingEvent,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<DayEditorDialog> createState() => _DayEditorDialogState();
}

class _DayEditorDialogState extends State<DayEditorDialog> {
  late HolidayType _selectedType;
  late TextEditingController _nameController;
  bool _isRange = false;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.existingEvent?.type ?? HolidayType.national;
    _nameController = TextEditingController(
      text: widget.existingEvent?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('d MMMM yyyy', 'es');

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: AppSpacing.allSm,
            decoration: BoxDecoration(
              color: _typeColor(_selectedType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              _typeIcon(_selectedType),
              color: _typeColor(_selectedType),
              size: 20,
            ),
          ),
          AppSpacing.horizontalSpaceMd,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingEvent == null
                      ? 'Añadir Festivo'
                      : 'Editar Festivo',
                  style: AppTextStyles.h5,
                ),
                Text(
                  formatter.format(widget.selectedDate),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de tipo
            Text(
              'Tipo de día',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalSpaceSm,
            _buildTypeSelector(),

            AppSpacing.verticalSpaceMd,

            // Nombre del festivo
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del festivo',
                hintText: _hintForType(_selectedType),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                contentPadding: AppSpacing.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),

            AppSpacing.verticalSpaceMd,

            // Opción de rango (útil para vacaciones)
            if (_selectedType == HolidayType.vacation) ...[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Aplicar a un rango de fechas',
                  style: AppTextStyles.bodyMedium,
                ),
                subtitle: Text(
                  'Marca múltiples días de una vez',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isRange,
                onChanged: (v) => setState(() {
                  _isRange = v ?? false;
                  if (!_isRange) _rangeEnd = null;
                }),
                activeColor: AppColors.primary,
              ),
              if (_isRange) ...[
                AppSpacing.verticalSpaceSm,
                _buildDateRangePicker(),
              ],
            ],
          ],
        ),
      ),
      actionsAlignment: widget.existingEvent != null && widget.onDelete != null
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.end,
      actions: [
        // Botón eliminar (solo si editando)
        if (widget.existingEvent != null && widget.onDelete != null)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete!();
            },
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              onPressed:
                  _nameController.text.trim().isEmpty ? null : _handleSave,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      children: HolidayType.values.map((type) {
        final isSelected = _selectedType == type;
        return InkWell(
          onTap: () => setState(() => _selectedType = type),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? _typeColor(type) : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              color: isSelected
                  ? _typeColor(type).withValues(alpha: 0.05)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _typeColor(type),
                    border:
                        isSelected ? null : Border.all(color: _typeColor(type)),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.label,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check, size: 16, color: _typeColor(type)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangePicker() {
    final formatter = DateFormat('d MMM yyyy', 'es');
    final rangeDisplay = _rangeEnd != null
        ? '${formatter.format(widget.selectedDate)} → ${formatter.format(_rangeEnd!)}'
        : 'Seleccionar fecha de fin';

    return InkWell(
      onTap: _pickRangeEnd,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          color: AppColors.surfaceVariant,
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, size: 18, color: AppColors.primary),
            AppSpacing.horizontalSpaceSm,
            Expanded(
              child: Text(
                rangeDisplay,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _rangeEnd != null
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _pickRangeEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate.add(const Duration(days: 1)),
      firstDate: widget.selectedDate.add(const Duration(days: 1)),
      lastDate: DateTime(widget.selectedDate.year, 12, 31),
    );
    if (picked != null) {
      setState(() => _rangeEnd = picked);
    }
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final List<CalendarEventModel> events = [];

    if (_isRange && _rangeEnd != null) {
      // Generar un evento por cada día del rango
      var current = widget.selectedDate;
      var idx = 0;
      while (!current.isAfter(_rangeEnd!)) {
        events.add(CalendarEventModel(
          id: 'event_${current.millisecondsSinceEpoch}_$idx',
          name: name,
          date: current,
          type: _selectedType,
        ));
        current = current.add(const Duration(days: 1));
        idx++;
      }
    } else {
      events.add(CalendarEventModel(
        id: widget.existingEvent?.id ??
            'event_${widget.selectedDate.millisecondsSinceEpoch}',
        name: name,
        date: widget.selectedDate,
        type: _selectedType,
      ));
    }

    Navigator.of(context).pop();
    widget.onSave(events);
  }

  Color _typeColor(HolidayType type) {
    switch (type) {
      case HolidayType.national:
        return AppColors.error;
      case HolidayType.regional:
        return AppColors.info;
      case HolidayType.local:
        return AppColors.warning;
      case HolidayType.vacation:
        return AppColors.success;
    }
  }

  IconData _typeIcon(HolidayType type) {
    switch (type) {
      case HolidayType.national:
        return Icons.flag_outlined;
      case HolidayType.regional:
        return Icons.location_city_outlined;
      case HolidayType.local:
        return Icons.place_outlined;
      case HolidayType.vacation:
        return Icons.beach_access_outlined;
    }
  }

  String _hintForType(HolidayType type) {
    switch (type) {
      case HolidayType.national:
        return 'Ej: Día de la Constitución';
      case HolidayType.regional:
        return 'Ej: Diada de Catalunya';
      case HolidayType.local:
        return 'Ej: San Isidro';
      case HolidayType.vacation:
        return 'Ej: Vacaciones de Verano';
    }
  }
}
