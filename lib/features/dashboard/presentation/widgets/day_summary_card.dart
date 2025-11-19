import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import 'work_hours_progress.dart';
import 'time_info_badge.dart';

/// Card de resumen del día
/// 
/// Muestra:
/// - Progreso de horas trabajadas
/// - Hora de entrada
/// - Salida estimada
/// - Tiempo de pausa acumulado
/// 
/// MOCK DATA: Usa MockData.todaySummary
class DaySummaryCard extends StatelessWidget {
  const DaySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos mock
    final summary = MockData.todaySummary;
    final totalHours = summary['totalHours'] as double;
    final expectedHours = summary['expectedHours'] as double;
    final breakTime = summary['breakTime'] as int;
    final entranceTime = summary['entranceTime'] as String;
    final estimatedExit = summary['estimatedExit'] as String;

    return CustomCard(
      elevation: CardElevation.medium,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del card
          Row(
            children: [
              Icon(
                Icons.today,
                size: AppSpacing.iconMd,
                color: AppColors.info,
              ),
              AppSpacing.horizontalSpaceSm,
              Text(
                'Resumen del Día',
                style: AppTextStyles.h5,
              ),
            ],
          ),

          AppSpacing.verticalSpaceLg,

          // Progreso de horas trabajadas
          WorkHoursProgress(
            workedHours: totalHours,
            expectedHours: expectedHours,
          ),

          AppSpacing.verticalSpaceXxl,

          // Badges de información
          LayoutBuilder(
            builder: (context, constraints) {
              // Si el ancho es pequeño, badges en columna
              if (constraints.maxWidth < 300 || context.isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TimeInfoBadge(
                      label: 'Hora de entrada',
                      time: entranceTime,
                      color: AppColors.success,
                      icon: Icons.login,
                    ),
                    AppSpacing.verticalSpaceMd,
                    TimeInfoBadge(
                      label: 'Salida estimada',
                      time: estimatedExit,
                      color: AppColors.warning,
                      icon: Icons.logout,
                    ),
                    AppSpacing.verticalSpaceMd,
                    _buildBreakTimeBadge(breakTime),
                  ],
                );
              }

              // Layout normal: grid 2 columnas
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TimeInfoBadge(
                          label: 'Hora de entrada',
                          time: entranceTime,
                          color: AppColors.success,
                          icon: Icons.login,
                        ),
                      ),
                      AppSpacing.horizontalSpaceMd,
                      Expanded(
                        child: TimeInfoBadge(
                          label: 'Salida estimada',
                          time: estimatedExit,
                          color: AppColors.warning,
                          icon: Icons.logout,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpaceMd,
                  _buildBreakTimeBadge(breakTime),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBreakTimeBadge(int breakMinutes) {
    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.coffee,
            size: AppSpacing.iconMd,
            color: AppColors.warning,
          ),
          AppSpacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tiempo de pausa',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  '${(breakMinutes ~/ 60)}h ${breakMinutes % 60}min acumulados hoy',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

