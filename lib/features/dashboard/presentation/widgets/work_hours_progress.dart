import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Barra de progreso de horas trabajadas
/// 
/// Muestra el progreso visual de las horas trabajadas vs esperadas.
/// Incluye porcentaje y etiquetas de horas.
/// 
/// Ejemplo de uso:
/// ```dart
/// WorkHoursProgress(
///   workedHours: 5.5,
///   expectedHours: 8.0,
/// )
/// ```
class WorkHoursProgress extends StatelessWidget {
  /// Horas trabajadas hasta el momento
  final double workedHours;

  /// Horas esperadas para el día
  final double expectedHours;

  /// Color de la barra de progreso
  final Color? progressColor;

  const WorkHoursProgress({
    super.key,
    required this.workedHours,
    required this.expectedHours,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = workedHours / expectedHours;
    final percentage = (progress * 100).clamp(0, 100).toInt();
    final color = progressColor ?? _getProgressColor(progress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Etiquetas superior (Horas trabajadas / Total)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total horas trabajadas',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${workedHours.toStringAsFixed(1)}h / ${expectedHours.toStringAsFixed(0)}h',
              style: AppTextStyles.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        AppSpacing.verticalSpaceSm,

        // Barra de progreso
        Stack(
          children: [
            // Background
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
            ),

            // Progress
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        AppSpacing.verticalSpaceXs,

        // Porcentaje
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$percentage%',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.9) {
      return AppColors.success; // 90%+ completado
    } else if (progress >= 0.5) {
      return AppColors.info; // 50-90% en progreso
    } else {
      return AppColors.warning; // < 50% inicio
    }
  }
}

