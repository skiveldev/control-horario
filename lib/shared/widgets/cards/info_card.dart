import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import 'custom_card.dart';

/// Tipo de información que muestra el card
enum InfoCardType {
  /// Información neutral
  info,

  /// Éxito o estado positivo
  success,

  /// Advertencia
  warning,

  /// Error o estado crítico
  error,
}

/// Card de información con ícono, título, valor y descripción
/// 
/// Widget especializado para mostrar métricas o información resumida.
/// Ideal para dashboards y resúmenes.
/// 
/// Ejemplo de uso:
/// ```dart
/// InfoCard(
///   title: 'Total Horas',
///   value: '5.5h',
///   subtitle: 'de 8h trabajadas',
///   icon: Icons.schedule,
///   type: InfoCardType.info,
/// )
/// 
/// // Con porcentaje de progreso
/// InfoCard(
///   title: 'Fichajes Completos',
///   value: '18',
///   subtitle: '90% del mes',
///   icon: Icons.check_circle,
///   type: InfoCardType.success,
///   progress: 0.9,
/// )
/// 
/// // Clickeable
/// InfoCard(
///   title: 'Ausencias',
///   value: '2',
///   icon: Icons.event_busy,
///   type: InfoCardType.warning,
///   onTap: () {
///     // Ver detalles
///   },
/// )
/// ```
class InfoCard extends StatelessWidget {
  /// Título del card
  final String title;

  /// Valor principal (número, texto corto)
  final String value;

  /// Subtítulo o descripción adicional
  final String? subtitle;

  /// Ícono representativo
  final IconData icon;

  /// Tipo de información (define el color)
  final InfoCardType type;

  /// Progreso opcional (0.0 - 1.0)
  final double? progress;

  /// Callback al hacer tap
  final VoidCallback? onTap;

  /// Mostrar flecha de navegación
  final bool showArrow;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.type = InfoCardType.info,
    this.progress,
    this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return CustomCard(
      onTap: onTap,
      elevation: CardElevation.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (Ícono + Título)
          Row(
            children: [
              // Ícono con fondo circular
              Container(
                padding: AppSpacing.allSm,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: AppSpacing.iconMd,
                  color: color,
                ),
              ),

              AppSpacing.horizontalSpaceMd,

              // Título
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Flecha de navegación
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  size: AppSpacing.iconSm,
                  color: AppColors.textTertiary,
                ),
            ],
          ),

          AppSpacing.verticalSpaceMd,

          // Valor principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.displaySmall.copyWith(
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Subtítulo
          if (subtitle != null) ...[
            AppSpacing.verticalSpaceXs,
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Barra de progreso
          if (progress != null) ...[
            AppSpacing.verticalSpaceMd,
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColor() {
    switch (type) {
      case InfoCardType.info:
        return AppColors.info;
      case InfoCardType.success:
        return AppColors.success;
      case InfoCardType.warning:
        return AppColors.warning;
      case InfoCardType.error:
        return AppColors.error;
    }
  }
}

