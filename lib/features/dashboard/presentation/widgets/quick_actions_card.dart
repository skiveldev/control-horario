import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import 'edit_entrance_dialog.dart';

/// Card de acciones rápidas
/// 
/// Muestra atajos a funcionalidades comunes.
/// 
/// MOCK DATA: Usa MockData.quickActions
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsHelper.of(context);
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
                color: colors.accent,
              ),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Acciones Rápidas',
                  style: AppTextStyles.h5.copyWith(
                    color: colors.textPrimary,
                  ),
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
    final colors = AppColorsHelper.of(context);
    final isEnabled = action['enabled'] as bool;
    final color = _getColorForType(context, action['color'] as String);
    final icon = _getIconForName(action['icon'] as String);

    return InkWell(
      onTap: isEnabled
          ? () {
              // Detectar si es la acción "Editar Registro"
              final title = action['title'] as String;
              if (title.contains('Editar') || title.toLowerCase().contains('registro')) {
                _handleEditEntrance(context);
              } else {
                // TODO [FASE-2]: Implementar otras acciones
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${action['title']} - En desarrollo'),
                  ),
                );
              }
            }
          : null,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: isEnabled
              ? color.withValues(alpha: 0.05)
              : colors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isEnabled
                ? color.withValues(alpha: 0.2)
                : colors.border,
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
                    : colors.borderLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Icon(
                icon,
                size: AppSpacing.iconMd,
                color: isEnabled ? color : colors.textTertiary,
              ),
            ),

            AppSpacing.horizontalSpaceMd,

            // Título
            Expanded(
              child: Text(
                action['title'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isEnabled
                      ? colors.textPrimary
                      : colors.textTertiary,
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
                  color: colors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  'Próximo',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(BuildContext context, String type) {
    final colors = AppColorsHelper.of(context);
    switch (type) {
      case 'info':
        return colors.info;
      case 'secondary':
        return colors.secondary;
      case 'accent':
        return colors.accent;
      default:
        return colors.primary;
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

  /// Maneja la acción de editar hora de entrada (DEMO)
  void _handleEditEntrance(BuildContext context) {
    // MOCK DATA: Datos de ejemplo para demostración visual
    final currentEntrance = const TimeOfDay(hour: 9, minute: 0);
    final exitTime = const TimeOfDay(hour: 18, minute: 0);

    showEditEntranceDialog(
      context: context,
      currentEntrance: currentEntrance,
      exitTime: exitTime,
      onSave: (newTime) {
        final colors = AppColorsHelper.of(context);
        // TODO [FASE-2]: Guardar en Firebase/Riverpod
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hora de entrada actualizada a ${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}',
            ),
            backgroundColor: colors.success,
          ),
        );
      },
    );
  }
}

