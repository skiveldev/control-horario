import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../dashboard/providers/employee_schedule_provider.dart';
import '../../models/schedule_model.dart';

/// Visualizador de horario semanal
///
/// Muestra el horario completo de un empleado (lunes a domingo).
/// Si el empleado usa plantilla, muestra un resumen simple.
/// Si tiene horario personalizado, muestra turnos detallados.
///
/// ✅ Conectado a Firebase via employeeFullScheduleProvider
///
/// Ejemplo de uso:
/// ```dart
/// WeekScheduleViewer(
///   employeeId: 'EMP-042',
///   isReadOnly: false,
/// )
/// ```
class WeekScheduleViewer extends ConsumerWidget {
  /// ID del empleado
  final String employeeId;

  /// Si es de solo lectura (para vista de empleado)
  final bool isReadOnly;

  const WeekScheduleViewer({
    super.key,
    required this.employeeId,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar horario desde Firebase en tiempo real
    final scheduleAsync = ref.watch(employeeFullScheduleProvider(employeeId));

    return scheduleAsync.when(
      data: (schedule) {
        if (schedule == null) {
          return _buildEmptyState(context);
        }

        final isTemplate = schedule.type == 'template';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del tipo de horario
            _buildHeader(
              context,
              isTemplate,
              schedule.templateName,
              schedule.weeklyHours,
            ),

            AppSpacing.verticalSpaceMd,

            // Tabla de horarios
            _buildScheduleTable(context, schedule.schedule),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              AppSpacing.verticalSpaceMd,
              Text(
                'Error al cargar horario',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTemplate,
      String templateName, int weeklyHours) {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: isTemplate
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
            : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isTemplate
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTemplate ? Icons.assignment : Icons.person_outline,
            size: 20,
            color: isTemplate
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
          ),
          AppSpacing.horizontalSpaceSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTemplate ? 'Plantilla' : 'Horario personalizado',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  templateName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isTemplate
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '${weeklyHours}h/sem',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable(
    BuildContext context,
    Map<String, DaySchedule> weekSchedule,
  ) {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: days.asMap().entries.map((entry) {
          final index = entry.key;
          final dayKey = entry.value;
          final dayData = weekSchedule[dayKey];
          final isLast = index == days.length - 1;

          return _buildDayRow(context, dayKey, dayData, isLast: isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    String dayKey,
    DaySchedule? dayData, {
    required bool isLast,
  }) {
    final dayName = _getDayName(dayKey);
    final isWorkDay = dayData?.isWorkDay ?? false;
    final shifts = dayData?.shifts ?? [];
    final dailyHours = dayData?.dailyHours ?? 0;

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
      ),
      child: Padding(
        padding: AppSpacing.allMd,
        child: Row(
          children: [
            // Día de la semana
            SizedBox(
              width: 90,
              child: Text(
                dayName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isWorkDay
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight:
                          isWorkDay ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),

            AppSpacing.horizontalSpaceMd,

            // Horarios
            Expanded(
              child: isWorkDay
                  ? _buildShiftsList(context, shifts)
                  : Text(
                      'Libre',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
            ),

            // Horas del día
            if (isWorkDay)
              Container(
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  '${dailyHours}h',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftsList(BuildContext context, List<TimeShift> shifts) {
    if (shifts.isEmpty) {
      return Text(
        'Sin horario',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    // Si es solo un turno, mostrar directo
    if (shifts.length == 1) {
      final shift = shifts[0];
      return Text(
        '${shift.startTime} - ${shift.endTime}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      );
    }

    // Si son múltiples turnos, mostrar con separador
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: shifts.asMap().entries.map((entry) {
        final index = entry.key;
        final shift = entry.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${shift.startTime}-${shift.endTime}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            if (index < shifts.length - 1) ...[
              AppSpacing.horizontalSpaceXs,
              Text(
                '/',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              AppSpacing.horizontalSpaceXs,
            ],
          ],
        );
      }).toList(),
    );
  }

  /// Formatear nombre del día en español
  String _getDayName(String dayKey) {
    const names = {
      'monday': 'Lunes',
      'tuesday': 'Martes',
      'wednesday': 'Miércoles',
      'thursday': 'Jueves',
      'friday': 'Viernes',
      'saturday': 'Sábado',
      'sunday': 'Domingo',
    };
    return names[dayKey] ?? dayKey;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: AppSpacing.allXl,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          AppSpacing.verticalSpaceMd,
          Text(
            'Sin horario asignado',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            'Este empleado aún no tiene un horario configurado',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
