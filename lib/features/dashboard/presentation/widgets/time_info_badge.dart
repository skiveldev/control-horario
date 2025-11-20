import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Badge informativo de tiempo
/// 
/// Muestra información de hora con etiqueta y fondo coloreado.
/// Usado para mostrar hora de entrada, salida, pausa, etc.
/// 
/// Ejemplo de uso:
/// ```dart
/// TimeInfoBadge(
///   label: 'Hora de entrada',
///   time: '09:00',
///   color: AppColors.success,
/// )
/// ```
class TimeInfoBadge extends StatelessWidget {
  /// Etiqueta descriptiva
  final String label;

  /// Hora a mostrar (formato HH:MM)
  final String time;

  /// Color de fondo
  final Color color;

  /// Ícono opcional
  final IconData? icon;

  const TimeInfoBadge({
    super.key,
    required this.label,
    required this.time,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label con ícono opcional
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 12,
                  color: color,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceXs,

          // Hora
          Text(
            time,
            style: AppTextStyles.h5.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

