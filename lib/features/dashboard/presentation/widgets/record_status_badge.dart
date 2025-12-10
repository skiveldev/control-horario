import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Badge de estado de registro
///
/// Muestra el estado de un fichaje (Completo, Incompleto, Sin fichar).
///
/// Ejemplo de uso:
/// ```dart
/// RecordStatusBadge(
///   status: 'completo',
/// )
/// ```
class RecordStatusBadge extends StatelessWidget {
  /// Estado del registro: 'completo', 'incompleto', 'sin_fichar'
  final String status;

  /// Tamaño compacto (sin texto, solo ícono)
  final bool compact;

  const RecordStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final data = _getStatusData(context, status);

    if (compact) {
      return Container(
        padding: AppSpacing.allXs,
        decoration: BoxDecoration(
          color: data['color'].withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          data['icon'] as IconData,
          size: 14,
          color: data['color'] as Color,
        ),
      );
    }

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: (data['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        border: Border.all(
          color: (data['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data['icon'] as IconData,
            size: 12,
            color: data['color'] as Color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              data['text'] as String,
              style: AppTextStyles.labelSmall.copyWith(
                color: data['color'] as Color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusData(BuildContext context, String status) {
    final colors = AppColorsHelper.of(context);
    switch (status.toLowerCase()) {
      case 'completo':
        return {
          'color': colors.success,
          'icon': Icons.check_circle,
          'text': 'Completo',
        };
      case 'incompleto':
        return {
          'color': colors.warning,
          'icon': Icons.warning,
          'text': 'Incompleto',
        };
      case 'sin_fichar':
        return {
          'color': colors.error,
          'icon': Icons.cancel,
          'text': 'Sin fichar',
        };
      default:
        return {
          'color': colors.textSecondary,
          'icon': Icons.help,
          'text': 'Desconocido',
        };
    }
  }
}
