import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Empty State para meses futuros no activados
///
/// Muestra un mensaje informativo cuando el empleado intenta
/// acceder a registros de meses que aún no han comenzado.
class FutureMonthEmptyState extends StatelessWidget {
  final DateTime month;
  final VoidCallback onGoToCurrentMonth;

  const FutureMonthEmptyState({
    super.key,
    required this.month,
    required this.onGoToCurrentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy', 'es_ES').format(month);

    return Center(
      child: Padding(
        padding: AppSpacing.allXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono grande de calendario
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppSpacing.borderRadiusXl,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),

            AppSpacing.verticalSpaceXxl,

            // Título
            Text(
              'Mes no disponible',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            AppSpacing.verticalSpaceMd,

            // Mensaje principal
            Text(
              'No se ha activado los días para este mes',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            AppSpacing.verticalSpaceLg,

            // Mensaje descriptivo
            Container(
              padding: AppSpacing.allLg,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: AppSpacing.iconMd,
                  ),
                  AppSpacing.horizontalSpaceMd,
                  Expanded(
                    child: Text(
                      'Los registros de $monthName estarán disponibles cuando comience el período.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalSpaceXxl,

            // Botón para volver al mes actual
            ElevatedButton.icon(
              onPressed: onGoToCurrentMonth,
              icon: const Icon(Icons.arrow_back, size: AppSpacing.iconSm),
              label: const Text('Volver al mes actual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
