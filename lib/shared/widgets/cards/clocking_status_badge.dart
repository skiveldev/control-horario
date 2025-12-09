import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = _getStatusData(status, isDark);
    
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
        color: data['backgroundColor'] as Color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: data['borderColor'] as Color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data['icon'] as IconData,
            size: small ? 12 : 14,
            color: data['textColor'] as Color,
          ),
          SizedBox(width: small ? 3 : 4),
          Flexible(
            child: Text(
              data['text'] as String,
              style: (small 
                  ? AppTextStyles.labelSmall.copyWith(fontSize: 10)
                  : AppTextStyles.labelSmall
              ).copyWith(
                color: data['textColor'] as Color,
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

  /// Obtiene los datos de visualización según el estado CON COLORES ESPECÍFICOS
  /// Usa colores exactos del archivo colores.txt para dark mode
  Map<String, dynamic> _getStatusData(ClockingStatus status, bool isDark) {
    switch (status) {
      case ClockingStatus.complete:
        // Badge "Completo" - Verde teal con colores específicos
        return {
          'backgroundColor': isDark 
              ? AppColorsDark.clockingCompleteBackground  // #134E4A
              : AppColors.clockingComplete.withValues(alpha: 0.1),
          'textColor': isDark 
              ? AppColorsDark.clockingCompleteText  // #5EEAD4
              : AppColors.clockingComplete,
          'borderColor': isDark 
              ? AppColorsDark.clockingCompleteBorder  // #0F766E
              : AppColors.clockingComplete.withValues(alpha: 0.2),
          'icon': Icons.check_circle,
          'text': 'Completo',
          'tooltip': null,
        };

      case ClockingStatus.incomplete:
        return {
          'backgroundColor': isDark 
              ? AppColors.clockingIncomplete.withValues(alpha: 0.1)
              : AppColors.clockingIncomplete.withValues(alpha: 0.1),
          'textColor': isDark 
              ? AppColors.clockingIncomplete
              : AppColors.clockingIncomplete,
          'borderColor': isDark 
              ? AppColors.clockingIncomplete.withValues(alpha: 0.2)
              : AppColors.clockingIncomplete.withValues(alpha: 0.2),
          'icon': Icons.warning_rounded,
          'text': 'Incompleto',
          'tooltip': 'Fichaje sin cierre registrado',
        };

      case ClockingStatus.autoClosed:
        return {
          'backgroundColor': isDark 
              ? AppColors.clockingAutoClosed.withValues(alpha: 0.1)
              : AppColors.clockingAutoClosed.withValues(alpha: 0.1),
          'textColor': isDark 
              ? AppColors.clockingAutoClosed
              : AppColors.clockingAutoClosed,
          'borderColor': isDark 
              ? AppColors.clockingAutoClosed.withValues(alpha: 0.2)
              : AppColors.clockingAutoClosed.withValues(alpha: 0.2),
          'icon': Icons.settings_rounded,
          'text': 'Auto-cerrado',
          'tooltip': 'Cierre automático por sistema',
        };

      case ClockingStatus.edited:
        return {
          'backgroundColor': isDark 
              ? AppColors.clockingEdited.withValues(alpha: 0.1)
              : AppColors.clockingEdited.withValues(alpha: 0.1),
          'textColor': isDark 
              ? AppColors.clockingEdited
              : AppColors.clockingEdited,
          'borderColor': isDark 
              ? AppColors.clockingEdited.withValues(alpha: 0.2)
              : AppColors.clockingEdited.withValues(alpha: 0.2),
          'icon': Icons.edit_rounded,
          'text': 'Editado',
          'tooltip': 'Registro modificado manualmente',
        };

      case ClockingStatus.ongoing:
        return {
          'backgroundColor': isDark 
              ? AppColors.clockingOnBreak.withValues(alpha: 0.1)
              : AppColors.clockingOnBreak.withValues(alpha: 0.1),
          'textColor': isDark 
              ? AppColors.clockingOnBreak
              : AppColors.clockingOnBreak,
          'borderColor': isDark 
              ? AppColors.clockingOnBreak.withValues(alpha: 0.2)
              : AppColors.clockingOnBreak.withValues(alpha: 0.2),
          'icon': Icons.access_time_rounded,
          'text': 'En curso',
          'tooltip': null,
        };
    }
  }
}

