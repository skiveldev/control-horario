import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/custom_card.dart';

/// Card de acciones rápidas
///
/// Muestra atajos a funcionalidades comunes.
/// Las acciones no implementadas muestran badge "Próximo".
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  // Acciones definidas directamente (sin MockData)
  // Ninguna acción está implementada — todas muestran "Próximo"
  static const _actions = [
    {
      'id': 'request_vacation',
      'title': 'Solicitar vacaciones',
      'icon': 'calendar_month',
      'color': 'info',
      'enabled': false, // No implementado
    },
    {
      'id': 'edit_record',
      'title': 'Editar registro',
      'icon': 'edit',
      'color': 'secondary',
      'enabled': false, // No implementado — antes mock dialog, ahora honesto
    },
    {
      'id': 'view_reports',
      'title': 'Ver reportes',
      'icon': 'assessment',
      'color': 'accent',
      'enabled': false, // No implementado
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsHelper.of(context);
    final actions = _actions;

    return CustomCard(
      elevation: CardElevation.medium,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.bolt, size: AppSpacing.iconMd, color: colors.accent),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Acciones Rápidas',
                  style: AppTextStyles.h5.copyWith(color: colors.textPrimary),
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
              child: _buildActionItem(context: context, action: action),
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
      onTap: null, // Todas las acciones están deshabilitadas
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: isEnabled
              ? color.withValues(alpha: 0.05)
              : colors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isEnabled ? color.withValues(alpha: 0.2) : colors.border,
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
                  color: isEnabled ? colors.textPrimary : colors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Indicator "Próximamente"
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
}
