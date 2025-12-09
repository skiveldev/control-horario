import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_gradients.dart';
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
    final colors = AppColorsHelper.of(context);
    final progress = workedHours / expectedHours;
    final percentage = (progress * 100).clamp(0, 100).toInt();
    final color = progressColor ?? _getProgressColor(context, progress);

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
                color: colors.textSecondary,
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
                color: colors.borderLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
            ),

            // Progress - Gradiente en dark mode, color sólido en light mode
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  // Gradiente SOLO en dark mode
                  gradient: Theme.of(context).brightness == Brightness.dark 
                      ? AppGradients.progressBar 
                      : LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  // Glow SOLO en dark mode
                  boxShadow: Theme.of(context).brightness == Brightness.dark ? [
                    BoxShadow(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: const Color(0xFFD946EF).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
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
              color: colors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(BuildContext context, double progress) {
    final colors = AppColorsHelper.of(context);
    if (progress >= 0.9) {
      return colors.success; // 90%+ completado
    } else if (progress >= 0.5) {
      return colors.info; // 50-90% en progreso
    } else {
      return colors.warning; // < 50% inicio
    }
  }
}

