import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Panel de alertas de control para dashboard admin
///
/// Muestra alertas importantes sobre el sistema y fichajes.
/// FASE 1: Alertas mock estáticas.
///
/// Ejemplo:
/// ```dart
/// ControlAlertsPanel(
///   alerts: [
///     {'type': 'warning', 'title': 'Fichajes Incompletos', 'message': '...'},
///   ],
/// )
/// ```
class ControlAlertsPanel extends StatelessWidget {
  /// Lista de alertas a mostrar
  final List<Map<String, String>> alerts;

  const ControlAlertsPanel({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Alertas de Control',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          AppSpacing.verticalSpaceLg,

          // Lista de alertas
          ...alerts.asMap().entries.map((entry) {
            final index = entry.key;
            final alert = entry.value;
            final isLast = index == alerts.length - 1;

            return Column(
              children: [
                _AlertItem(
                  type: alert['type'] ?? 'info',
                  title: alert['title'] ?? '',
                  message: alert['message'] ?? '',
                ),
                if (!isLast) AppSpacing.verticalSpaceMd,
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// Item individual de alerta
class _AlertItem extends StatelessWidget {
  final String type;
  final String title;
  final String message;

  const _AlertItem({
    required this.type,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final alertConfig = _getAlertConfig(type);

    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: alertConfig.color.withValues(alpha: 0.05),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(
          color: alertConfig.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono de alerta
          Container(
            padding: AppSpacing.allXs,
            decoration: BoxDecoration(
              color: alertConfig.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              alertConfig.icon,
              size: AppSpacing.iconMd,
              color: alertConfig.color,
            ),
          ),

          AppSpacing.horizontalSpaceMd,

          // Contenido de la alerta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  message,
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

  _AlertConfig _getAlertConfig(String type) {
    switch (type.toLowerCase()) {
      case 'warning':
        return _AlertConfig(
          color: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case 'error':
        return _AlertConfig(
          color: AppColors.error,
          icon: Icons.error_outline,
        );
      case 'success':
        return _AlertConfig(
          color: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case 'info':
      default:
        return _AlertConfig(
          color: AppColors.info,
          icon: Icons.info_outline,
        );
    }
  }
}

/// Configuración de estilo para cada tipo de alerta
class _AlertConfig {
  final Color color;
  final IconData icon;

  _AlertConfig({
    required this.color,
    required this.icon,
  });
}
