import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../shared/widgets/cards/custom_card.dart';

/// Card de acciones rápidas
/// 
/// Muestra atajos a funcionalidades comunes.
/// 
/// MOCK DATA: Usa MockData.quickActions
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos mock
    final actions = MockData.quickActions;

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
                Icons.bolt,
                size: AppSpacing.iconMd,
                color: AppColors.accent,
              ),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Acciones Rápidas',
                  style: AppTextStyles.h5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceLg,

          // Lista de acciones
          ...actions.map((action) {
            return Padding(
              padding: AppSpacing.verticalSm,
              child: _buildActionItem(
                context: context,
                action: action,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required Map<String, dynamic> action,
  }) {
    final isEnabled = action['enabled'] as bool;
    final color = _getColorForType(action['color'] as String);
    final icon = _getIconForName(action['icon'] as String);

    return InkWell(
      onTap: isEnabled
          ? () {
              // TODO [FASE-2]: Implementar acciones reales
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${action['title']} - En desarrollo'),
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: isEnabled
              ? color.withValues(alpha: 0.05)
              : AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isEnabled
                ? color.withValues(alpha: 0.2)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Ícono
            Container(
              padding: AppSpacing.allSm,
              decoration: BoxDecoration(
                color: isEnabled
                    ? color.withValues(alpha: 0.1)
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Icon(
                icon,
                size: AppSpacing.iconMd,
                color: isEnabled ? color : AppColors.textTertiary,
              ),
            ),

            AppSpacing.horizontalSpaceMd,

            // Título
            Expanded(
              child: Text(
                action['title'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Flecha
            if (isEnabled)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: color,
              ),

            // Indicator "Próximamente"
            if (!isEnabled)
              Container(
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  'Próximo',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'info':
        return AppColors.info;
      case 'secondary':
        return AppColors.secondary;
      case 'accent':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  IconData _getIconForName(String name) {
    switch (name) {
      case 'calendar_month':
        return Icons.calendar_month;
      case 'edit':
        return Icons.edit;
      case 'assessment':
        return Icons.assessment;
      default:
        return Icons.help;
    }
  }
}

