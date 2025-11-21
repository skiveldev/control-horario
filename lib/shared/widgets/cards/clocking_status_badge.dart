import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Estados posibles de un fichaje
enum ClockingStatus {
  /// Fichaje completado correctamente
  complete,
  
  /// Fichaje incompleto (sin salida registrada)
  incomplete,
  
  /// Fichaje cerrado automáticamente por el sistema
  autoClosed,
  
  /// Fichaje editado manualmente
  edited,
  
  /// Fichaje en curso (usuario trabajando actualmente)
  ongoing,
}

/// Badge de estado de fichaje tipo píldora
/// 
/// Muestra visualmente el estado de un registro de fichaje con colores
/// semánticos, iconos descriptivos y tooltips informativos.
/// 
/// Ejemplo de uso:
/// ```dart
/// ClockingStatusBadge(
///   status: ClockingStatus.complete,
///   small: false,
/// )
/// ```
class ClockingStatusBadge extends StatelessWidget {
  /// Estado del fichaje a mostrar
  final ClockingStatus status;

  /// Si debe mostrarse en tamaño reducido
  final bool small;

  const ClockingStatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final data = _getStatusData(status);
    
    final badge = Container(
      padding: small
          ? AppSpacing.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            )
          : AppSpacing.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
      decoration: BoxDecoration(
        color: (data['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (data['color'] as Color).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data['icon'] as IconData,
            size: small ? 12 : 14,
            color: data['color'] as Color,
          ),
          SizedBox(width: small ? 3 : 4),
          Flexible(
            child: Text(
              data['text'] as String,
              style: (small 
                  ? AppTextStyles.labelSmall.copyWith(fontSize: 10)
                  : AppTextStyles.labelSmall
              ).copyWith(
                color: data['color'] as Color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    // Aplicar tooltip solo si existe
    final tooltip = data['tooltip'] as String?;
    if (tooltip != null && tooltip.isNotEmpty) {
      return Tooltip(
        message: tooltip,
        child: badge,
      );
    }

    return badge;
  }

  /// Obtiene los datos de visualización según el estado
  Map<String, dynamic> _getStatusData(ClockingStatus status) {
    switch (status) {
      case ClockingStatus.complete:
        return {
          'color': AppColors.clockingComplete,
          'icon': Icons.check_circle,
          'text': 'Completo',
          'tooltip': null,
        };

      case ClockingStatus.incomplete:
        return {
          'color': AppColors.clockingIncomplete,
          'icon': Icons.warning_rounded,
          'text': 'Incompleto',
          'tooltip': 'Fichaje sin cierre registrado',
        };

      case ClockingStatus.autoClosed:
        return {
          'color': AppColors.clockingAutoClosed,
          'icon': Icons.settings_rounded,
          'text': 'Auto-cerrado',
          'tooltip': 'Cierre automático por sistema',
        };

      case ClockingStatus.edited:
        return {
          'color': AppColors.clockingEdited,
          'icon': Icons.edit_rounded,
          'text': 'Editado',
          'tooltip': 'Registro modificado manualmente',
        };

      case ClockingStatus.ongoing:
        return {
          'color': AppColors.clockingOnBreak,
          'icon': Icons.access_time_rounded,
          'text': 'En curso',
          'tooltip': null,
        };
    }
  }
}

