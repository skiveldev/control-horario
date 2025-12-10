import 'package:flutter/material.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Badge informativo de tiempo CON GRADIENTES
///
/// Muestra información de hora con etiqueta y fondo con gradientes profesionales.
/// Detecta el tipo de badge por la etiqueta y aplica el gradiente correspondiente:
/// - "Hora de entrada" → Gradiente CYAN
/// - "Salida estimada" / "pausa" → Gradiente MAGENTA
/// - Otros → Color sólido
///
/// Ejemplo de uso:
/// ```dart
/// TimeInfoBadge(
///   label: 'Hora de entrada',
///   time: '09:00',
///   color: AppColorsDark.secondary,
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
    // Detectar tipo de badge por label para aplicar gradiente
    final badgeType = _detectBadgeType(label);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: _buildDecoration(badgeType, isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label con ícono opcional
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(color: color),
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

  /// Detecta el tipo de badge por su label
  _BadgeType _detectBadgeType(String label) {
    final lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('entrada')) {
      return _BadgeType.entrance; // CYAN
    } else if (lowerLabel.contains('salida') || lowerLabel.contains('pausa')) {
      return _BadgeType.exit; // MAGENTA
    }
    return _BadgeType.other; // Color sólido
  }

  /// Construye la decoración - gradiente en dark mode, color sólido en light mode
  BoxDecoration _buildDecoration(_BadgeType type, bool isDark) {
    // En DARK MODE: usar gradientes
    if (isDark) {
      switch (type) {
        case _BadgeType.entrance:
          // CYAN: Hora de entrada (dark mode)
          return BoxDecoration(
            gradient: AppGradients.cardCyanSubtle,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: AppShadows.cardCyanGlow,
          );

        case _BadgeType.exit:
          // MAGENTA: Salida estimada / Tiempo de pausa (dark mode)
          return BoxDecoration(
            gradient: AppGradients.cardMagentaSubtle,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: const Color(0xFFD946EF).withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: AppShadows.cardMagentaGlow,
          );

        case _BadgeType.other:
          return BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          );
      }
    }

    // En LIGHT MODE: usar colores sólidos (como tu imagen)
    return BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
    );
  }
}

/// Tipos de badges para aplicar gradientes específicos
enum _BadgeType {
  entrance, // Cyan gradient
  exit, // Magenta gradient
  other, // Solid color
}
