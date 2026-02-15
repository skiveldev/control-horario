import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/admin/models/schedule_model.dart';

/// Editor interactivo de horario semanal
///
/// Permite configurar el horario completo de la semana (Lun-Dom):
/// - Marcar días laborables/libres (Switch)
/// - Añadir múltiples turnos por día (jornada partida)
/// - TimePicker para inicio/fin de cada turno
/// - Auto-cálculo de horas diarias y semanales
///
/// ⚠️ Este widget usa setState para UI local del formulario (permitido por .cursorrules)
///
/// Ejemplo de uso:
/// ```dart
/// WeekScheduleEditor(
///   initialSchedule: existingSchedule,
///   onChanged: (newSchedule) {
///     setState(() => _weekSchedule = newSchedule);
///   },
/// )
/// ```
class WeekScheduleEditor extends StatefulWidget {
  /// Horario inicial (para edición)
  final Map<String, DaySchedule> initialSchedule;

  /// Callback cuando cambia el horario
  final ValueChanged<Map<String, DaySchedule>> onChanged;

  const WeekScheduleEditor({
    super.key,
    required this.initialSchedule,
    required this.onChanged,
  });

  @override
  State<WeekScheduleEditor> createState() => _WeekScheduleEditorState();
}

class _WeekScheduleEditorState extends State<WeekScheduleEditor> {
  /// Horario actual (estado local del formulario - setState permitido)
  late Map<String, DaySchedule> _schedule;

  /// Total de horas semanales calculado
  int _totalWeeklyHours = 0;

  @override
  void initState() {
    super.initState();
    _schedule = Map.from(widget.initialSchedule);
    _calculateTotalHours();
  }

  @override
  Widget build(BuildContext context) {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge con total de horas
        Container(
          padding: AppSpacing.allMd,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: AppColors.primary, size: 20),
              AppSpacing.horizontalSpaceSm,
              Text(
                'Total: $_totalWeeklyHours horas semanales',
                style:
                    AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),

        AppSpacing.verticalSpaceMd,

        // Lista de días
        Expanded(
          child: ListView.separated(
            itemCount: days.length,
            separatorBuilder: (_, __) => Divider(height: 1),
            itemBuilder: (context, index) {
              final dayKey = days[index];
              final dayName = _getDayName(dayKey);
              final daySchedule = _schedule[dayKey]!;
              final isWeekend = dayKey == 'saturday' || dayKey == 'sunday';

              return ExpansionTile(
                title: Row(
                  children: [
                    // Switch: Día laborable
                    Switch(
                      value: daySchedule.isWorkDay,
                      onChanged: (isWork) => _toggleWorkDay(dayKey, isWork),
                    ),
                    AppSpacing.horizontalSpaceMd,

                    // Nombre del día
                    Expanded(
                      child: Text(
                        dayName,
                        style: AppTextStyles.h6.copyWith(
                          color: isWeekend
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // Badge de horas del día
                    if (daySchedule.isWorkDay)
                      Container(
                        padding: AppSpacing.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXs),
                        ),
                        child: Text(
                          '${daySchedule.dailyHours.toStringAsFixed(1)}h',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                children: daySchedule.isWorkDay
                    ? [
                        Padding(
                          padding: AppSpacing.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Lista de turnos
                              ...daySchedule.shifts.asMap().entries.map(
                                (entry) {
                                  final shiftIndex = entry.key;
                                  final shift = entry.value;
                                  return _buildShiftRow(
                                    dayKey,
                                    shiftIndex,
                                    shift,
                                  );
                                },
                              ),

                              AppSpacing.verticalSpaceMd,

                              // Botón añadir turno
                              OutlinedButton.icon(
                                onPressed: () => _addShift(dayKey),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Añadir turno'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                ),
                              ),

                              // Info: jornada partida
                              if (daySchedule.shifts.length > 1) ...[
                                AppSpacing.verticalSpaceSm,
                                Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        size: 14, color: AppColors.info),
                                    AppSpacing.horizontalSpaceXs,
                                    Flexible(
                                      child: Text(
                                        'Jornada partida (${daySchedule.shifts.length} turnos)',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.info,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ]
                    : [],
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // WIDGETS AUXILIARES
  // ==========================================================================

  /// Widget de un turno individual con sus botones
  Widget _buildShiftRow(String dayKey, int shiftIndex, TimeShift shift) {
    return Padding(
      padding: AppSpacing.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          // Ícono de turno
          Icon(Icons.schedule_outlined,
              size: 18, color: AppColors.textSecondary),
          AppSpacing.horizontalSpaceSm,

          // Hora inicio
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pickTime(dayKey, shiftIndex, isStart: true),
              child: Text(
                shift.startTime,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),

          AppSpacing.horizontalSpaceSm,

          // Separador
          const Text('—'),

          AppSpacing.horizontalSpaceSm,

          // Hora fin
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pickTime(dayKey, shiftIndex, isStart: false),
              child: Text(
                shift.endTime,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),

          // Botón eliminar (solo si hay más de un turno)
          if (_schedule[dayKey]!.shifts.length > 1) ...[
            AppSpacing.horizontalSpaceSm,
            IconButton(
              icon: const Icon(Icons.delete_outline),
              iconSize: 20,
              color: AppColors.error,
              onPressed: () => _removeShift(dayKey, shiftIndex),
              tooltip: 'Eliminar turno',
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // LÓGICA DE NEGOCIO LOCAL
  // ==========================================================================

  /// Toggle día laborable/libre
  void _toggleWorkDay(String dayKey, bool isWork) {
    setState(() {
      _schedule[dayKey] = isWork
          ? DaySchedule(
              isWorkDay: true,
              shifts: const [TimeShift(startTime: '09:00', endTime: '17:00')],
              dailyHours: 8.0,
            )
          : DaySchedule(isWorkDay: false, shifts: const [], dailyHours: 0);

      _calculateTotalHours();
      widget.onChanged(_schedule);
    });
  }

  /// Añadir turno adicional (para jornada partida)
  void _addShift(String dayKey) {
    final currentShifts = List<TimeShift>.from(_schedule[dayKey]!.shifts);
    currentShifts.add(const TimeShift(startTime: '16:00', endTime: '20:00'));
    _updateDay(dayKey, currentShifts);
  }

  /// Eliminar turno
  void _removeShift(String dayKey, int index) {
    if (_schedule[dayKey]!.shifts.length <= 1) {
      // No permitir eliminar el último turno
      return;
    }

    final currentShifts = List<TimeShift>.from(_schedule[dayKey]!.shifts);
    currentShifts.removeAt(index);
    _updateDay(dayKey, currentShifts);
  }

  /// Mostrar TimePicker y actualizar hora
  Future<void> _pickTime(
    String dayKey,
    int shiftIndex, {
    required bool isStart,
  }) async {
    final shift = _schedule[dayKey]!.shifts[shiftIndex];
    final currentTime = isStart ? shift.startTime : shift.endTime;

    final initialTime = TimeOfDay(
      hour: int.parse(currentTime.split(':')[0]),
      minute: int.parse(currentTime.split(':')[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              dialBackgroundColor: AppColors.surfaceVariant,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      final shifts = List<TimeShift>.from(_schedule[dayKey]!.shifts);
      shifts[shiftIndex] = isStart
          ? TimeShift(startTime: timeString, endTime: shift.endTime)
          : TimeShift(startTime: shift.startTime, endTime: timeString);
      _updateDay(dayKey, shifts);
    }
  }

  /// Actualizar día completo con nuevos turnos
  void _updateDay(String dayKey, List<TimeShift> shifts) {
    final dailyHours = _calculateDailyHours(shifts);
    setState(() {
      _schedule[dayKey] = DaySchedule(
        isWorkDay: true,
        shifts: shifts,
        dailyHours: dailyHours,
      );
      _calculateTotalHours();
      widget.onChanged(_schedule);
    });
  }

  /// Calcular horas de un día (suma de todos los turnos)
  double _calculateDailyHours(List<TimeShift> shifts) {
    return shifts.fold(0.0, (sum, shift) {
      final start = _timeToMinutes(shift.startTime);
      final end = _timeToMinutes(shift.endTime);
      return sum + (end - start) / 60.0;
    });
  }

  /// Calcular total de horas semanales
  void _calculateTotalHours() {
    _totalWeeklyHours = _schedule.values
        .where((day) => day.isWorkDay)
        .fold(0.0, (sum, day) => sum + day.dailyHours)
        .round();
  }

  /// Convertir hora "HH:mm" a minutos
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Obtener nombre del día en español
  String _getDayName(String key) {
    const names = {
      'monday': 'Lunes',
      'tuesday': 'Martes',
      'wednesday': 'Miércoles',
      'thursday': 'Jueves',
      'friday': 'Viernes',
      'saturday': 'Sábado',
      'sunday': 'Domingo',
    };
    return names[key] ?? key;
  }
}
