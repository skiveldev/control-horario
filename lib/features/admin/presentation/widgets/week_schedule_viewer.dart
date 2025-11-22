import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/mock_schedules.dart';

/// Visualizador de horario semanal
/// 
/// Muestra el horario completo de un empleado (lunes a domingo).
/// Si el empleado usa plantilla, muestra un resumen simple.
/// Si tiene horario personalizado, muestra turnos detallados.
/// 
/// MOCK DATA: Usa MockSchedules.getEmployeeSchedule()
/// 
/// Ejemplo de uso:
/// ```dart
/// WeekScheduleViewer(
///   employeeId: 'EMP-042',
///   isReadOnly: false,
/// )
/// ```
class WeekScheduleViewer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // MOCK DATA: Obtener horario del empleado
    final scheduleData = MockSchedules.getEmployeeSchedule(employeeId);

    if (scheduleData == null) {
      return _buildEmptyState();
    }

    final isTemplate = scheduleData['type'] == 'template';
    final weekSchedule = scheduleData['schedule'] as Map<String, dynamic>;
    final weeklyHours = scheduleData['weeklyHours'] as int;
    final templateName = scheduleData['templateName'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con información del tipo de horario
        _buildHeader(isTemplate, templateName, weeklyHours),

        AppSpacing.verticalSpaceMd,

        // Tabla de horarios
        _buildScheduleTable(weekSchedule, isTemplate),
      ],
    );
  }

  Widget _buildHeader(bool isTemplate, String templateName, int weeklyHours) {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: isTemplate
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isTemplate
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.secondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTemplate ? Icons.assignment : Icons.person_outline,
            size: 20,
            color: isTemplate ? AppColors.primary : AppColors.secondary,
          ),
          AppSpacing.horizontalSpaceSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTemplate ? 'Plantilla' : 'Horario personalizado',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  templateName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isTemplate ? AppColors.primary : AppColors.secondary,
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
      Map<String, dynamic> weekSchedule, bool isTemplate) {
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
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: days.asMap().entries.map((entry) {
          final index = entry.key;
          final dayKey = entry.value;
          final dayData = weekSchedule[dayKey] as Map<String, dynamic>?;
          final isLast = index == days.length - 1;

          return _buildDayRow(
            dayKey,
            dayData,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayRow(
    String dayKey,
    Map<String, dynamic>? dayData, {
    required bool isLast,
  }) {
    final dayName = MockSchedules.formatDayName(dayKey);
    final isWorkDay = dayData?['isWorkDay'] ?? false;
    final shifts = (dayData?['shifts'] ?? []) as List<dynamic>;
    final dailyHours = dayData?['dailyHours'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.borderLight,
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
                style: AppTextStyles.labelMedium.copyWith(
                  color: isWorkDay
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontWeight:
                      isWorkDay ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            AppSpacing.horizontalSpaceMd,

            // Horarios
            Expanded(
              child: isWorkDay
                  ? _buildShiftsList(shifts)
                  : Text(
                      'Libre',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
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
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  '${dailyHours}h',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftsList(List<dynamic> shifts) {
    if (shifts.isEmpty) {
      return Text(
        'Sin horario',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textTertiary,
        ),
      );
    }

    // Si es solo un turno, mostrar directo
    if (shifts.length == 1) {
      final shift = shifts[0] as Map<String, dynamic>;
      return Text(
        '${shift['startTime']} - ${shift['endTime']}',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
        ),
      );
    }

    // Si son múltiples turnos, mostrar con separador
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: shifts.asMap().entries.map((entry) {
        final index = entry.key;
        final shift = entry.value as Map<String, dynamic>;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${shift['startTime']}-${shift['endTime']}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (index < shifts.length - 1) ...[
              AppSpacing.horizontalSpaceXs,
              Text(
                '/',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              AppSpacing.horizontalSpaceXs,
            ],
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: AppSpacing.allXl,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          AppSpacing.verticalSpaceMd,
          Text(
            'Sin horario asignado',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            'Este empleado aún no tiene un horario configurado',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


