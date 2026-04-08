import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Card de métrica mejorado para dashboard admin
///
/// Muestra un valor principal con ícono y badge de cambio opcional.
/// Incluye indicadores visuales de tendencia (↑↓) y porcentajes.
///
/// Ejemplo:
/// ```dart
/// MetricCard(
///   icon: Icons.people,
///   label: 'Total Empleados',
///   value: '500',
///   color: AppColors.primary,
///   badgeText: '+12',
///   badgeColor: AppColors.success,
///   onTap: () {},
/// )
/// ```
class MetricCard extends StatelessWidget {
  /// Ícono principal
  final IconData icon;

  /// Etiqueta descriptiva
  final String label;

  /// Valor principal a mostrar
  final String value;

  /// Color del tema (ícono y acentos)
  final Color color;

  /// Texto del badge de cambio (ej: '+12', '-2', '97%')
  final String? badgeText;

  /// Color del badge (verde para positivo, rojo para negativo)
  final Color? badgeColor;

  /// Progreso de la barra (0.0 – 1.0). Si es null, la barra no se muestra.
  final double? progress;

  /// Callback al hacer tap
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.badgeText,
    this.badgeColor,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Container(
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fila superior: Ícono + Badge
              Row(
                children: [
                  // Ícono con fondo de color
                  Container(
                    padding: AppSpacing.allMd,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Icon(
                      icon,
                      size: AppSpacing.iconXl,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  // Badge de cambio
                  if (badgeText != null) _buildBadge(),
                ],
              ),

              AppSpacing.verticalSpaceLg,

              // Valor principal
              Text(
                value,
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              AppSpacing.verticalSpaceXs,

              // Label descriptivo
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Barra de progreso sutil (solo si se proporciona progress)
              if (progress != null) ...[
                AppSpacing.verticalSpaceSm,
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress!.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    final isPositive = badgeText!.startsWith('+');
    final isPercentage = badgeText!.contains('%');
    final effectiveColor = badgeColor ??
        (isPositive
            ? AppColors.success
            : badgeText!.startsWith('-')
                ? AppColors.error
                : AppColors.textSecondary);

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flecha indicadora (solo si es +/-)
          if (!isPercentage) ...[
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: effectiveColor,
            ),
            const SizedBox(width: 2),
          ],
          // Texto del badge
          Text(
            badgeText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
