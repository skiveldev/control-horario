import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import 'custom_card.dart';

/// Card de estadística compacto
///
/// Widget simple para mostrar una estadística con ícono y valor.
/// Más compacto que InfoCard, ideal para grids de métricas.
///
/// Ejemplo de uso:
/// ```dart
/// StatCard(
///   icon: Icons.people,
///   label: 'Empleados',
///   value: '500',
///   color: AppColors.primary,
/// )
///
/// // Con tendencia
/// StatCard(
///   icon: Icons.trending_up,
///   label: 'Fichajes hoy',
///   value: '485',
///   trend: '+5%',
///   trendPositive: true,
/// )
///
/// // Clickeable
/// StatCard(
///   icon: Icons.warning,
///   label: 'Incidencias',
///   value: '3',
///   color: AppColors.warning,
///   onTap: () {
///     // Ver incidencias
///   },
/// )
/// ```
class StatCard extends StatelessWidget {
  /// Ícono representativo
  final IconData icon;

  /// Label o descripción
  final String label;

  /// Valor principal
  final String value;

  /// Color principal (aplica a ícono y valor)
  final Color? color;

  /// Texto de tendencia opcional (ej: "+5%", "-2%")
  final String? trend;

  /// Si la tendencia es positiva (verde) o negativa (roja)
  final bool trendPositive;

  /// Callback al hacer tap
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.trend,
    this.trendPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = color ?? AppColors.primary;

    return CustomCard(
      onTap: onTap,
      elevation: CardElevation.low,
      padding: AppSpacing.allLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícono
          Container(
            padding: AppSpacing.allSm,
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: AppSpacing.iconLg, color: mainColor),
          ),

          AppSpacing.verticalSpaceMd,

          // Label
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          AppSpacing.verticalSpaceXs,

          // Valor y tendencia
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Valor
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.h2.copyWith(color: mainColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Tendencia
              if (trend != null)
                Container(
                  padding: AppSpacing.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: (trendPositive ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trendPositive
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 10,
                        color:
                            trendPositive ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: trendPositive
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
