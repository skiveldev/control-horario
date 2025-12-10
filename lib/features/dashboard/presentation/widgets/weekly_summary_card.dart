import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../shared/widgets/cards/custom_card.dart';

/// Card de resumen semanal
///
/// Muestra un resumen de las horas trabajadas en la semana actual.
/// Incluye gráfico de barras simple y total de horas.
///
/// MOCK DATA: Usa MockData.weeklySummary
class WeeklySummaryCard extends StatelessWidget {
  const WeeklySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsHelper.of(context);
    // Datos mock
    final summary = MockData.weeklySummary;
    final totalHours = summary['totalHours'] as double;
    final expectedHours = summary['expectedHours'] as double;
    final days = summary['days'] as List<Map<String, dynamic>>;

    return CustomCard(
      elevation: CardElevation.medium,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                size: AppSpacing.iconMd,
                color: colors.info,
              ),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Esta Semana',
                  style: AppTextStyles.h5.copyWith(color: colors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceLg,

          // Total de horas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total semanal',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${totalHours.toStringAsFixed(1)}h',
                      style: AppTextStyles.h4.copyWith(color: colors.primary),
                    ),
                    TextSpan(
                      text: ' / ${expectedHours.toStringAsFixed(0)}h',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceLg,

          // Gráfico de barras simple
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: days.map((day) {
                return _buildDayBar(
                  context: context,
                  day: day['day'] as String,
                  hours: day['hours'] as double,
                  maxHours: 10.0, // Escala máxima para el gráfico
                  status: day['status'] as String,
                );
              }).toList(),
            ),
          ),

          AppSpacing.verticalSpaceLg,

          // Progreso semanal
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            child: LinearProgressIndicator(
              value: totalHours / expectedHours,
              minHeight: 6,
              backgroundColor: colors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(context, totalHours / expectedHours),
              ),
            ),
          ),

          AppSpacing.verticalSpaceXs,

          // Porcentaje
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${((totalHours / expectedHours) * 100).toInt()}% de la semana',
              style: AppTextStyles.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayBar({
    required BuildContext context,
    required String day,
    required double hours,
    required double maxHours,
    required String status,
  }) {
    final colors = AppColorsHelper.of(context);
    final heightRatio = (hours / maxHours).clamp(0.0, 1.0);
    final barColor = _getColorForStatus(context, status);

    return Expanded(
      child: Padding(
        padding: AppSpacing.horizontalXs,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Horas
            Text(
              '${hours.toStringAsFixed(1)}h',
              style: AppTextStyles.labelSmall.copyWith(
                color: colors.textSecondary,
                fontSize: 10,
              ),
            ),

            AppSpacing.verticalSpaceXs,

            // Barra
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: heightRatio < 0.1 ? 0.1 : heightRatio,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusXs),
                        topRight: Radius.circular(AppSpacing.radiusXs),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            AppSpacing.verticalSpaceXs,

            // Día
            Text(
              day,
              style: AppTextStyles.labelSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForStatus(BuildContext context, String status) {
    final colors = AppColorsHelper.of(context);
    switch (status) {
      case 'completo':
        return colors.success;
      case 'incompleto':
        return colors.warning;
      case 'activo':
        return colors.info;
      default:
        return colors.textSecondary;
    }
  }

  Color _getProgressColor(BuildContext context, double progress) {
    final colors = AppColorsHelper.of(context);
    if (progress >= 0.9) {
      return colors.success;
    } else if (progress >= 0.7) {
      return colors.info;
    } else {
      return colors.warning;
    }
  }
}
