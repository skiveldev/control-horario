import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/custom_card.dart';

/// Card de resumen semanal
///
/// Muestra un placeholder hasta que se integren los datos reales de Firestore.
/// La estructura del widget se preserva para facilitar la futura integración.
class WeeklySummaryCard extends StatelessWidget {
  const WeeklySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsHelper.of(context);

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

          AppSpacing.verticalSpaceXl,

          // Estado vacío honesto
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Column(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: 40,
                    color: colors.textTertiary.withValues(alpha: 0.5),
                  ),
                  AppSpacing.verticalSpaceMd,
                  Text(
                    'Sin datos disponibles',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  AppSpacing.verticalSpaceXs,
                  Text(
                    'El resumen semanal estará disponible próximamente',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
