import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Card para mostrar una plantilla de horario o un horario personalizado
/// 
/// Ejemplo de uso:
/// ```dart
/// ScheduleCard(
///   name: 'Jornada Completa',
///   description: 'Lunes a viernes, 9:00-17:00',
///   weeklyHours: 40,
///   usedByCount: 280,
///   isTemplate: true,
///   onTap: () => print('Card tapped'),
/// )
/// ```
class ScheduleCard extends StatelessWidget {
  /// Nombre de la plantilla o del horario
  final String name;

  /// Descripción breve del horario
  final String description;

  /// Horas semanales totales
  final int weeklyHours;

  /// Número de empleados que usan esta plantilla (solo para templates)
  final int? usedByCount;

  /// Si es una plantilla (true) o un horario personalizado (false)
  final bool isTemplate;

  /// Fecha de creación
  final String? createdAt;

  /// Quién lo creó
  final String? createdBy;

  /// Callback al hacer tap en la card
  final VoidCallback? onTap;

  const ScheduleCard({
    super.key,
    required this.name,
    required this.description,
    required this.weeklyHours,
    this.usedByCount,
    this.isTemplate = true,
    this.createdAt,
    this.createdBy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: AppSpacing.allLg,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
            // Header: Icono + Nombre
            Row(
              children: [
                // Icono según tipo
                Container(
                  padding: AppSpacing.allSm,
                  decoration: BoxDecoration(
                    color: _getIconColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    _getIcon(),
                    size: AppSpacing.iconMd,
                    color: _getIconColor(),
                  ),
                ),

                AppSpacing.horizontalSpaceMd,

                // Nombre
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.h5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Badge de horas semanales
                Container(
                  padding: AppSpacing.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${weeklyHours}h/sem',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpaceMd,

            // Descripción
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            AppSpacing.verticalSpaceMd,

            // Información adicional
            Row(
              children: [
                // Contador de empleados (solo para templates)
                if (isTemplate && usedByCount != null) ...[
                  Icon(
                    Icons.people,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Usada por $usedByCount empleados',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                // Separador
                if (isTemplate &&
                    usedByCount != null &&
                    createdBy != null) ...[
                  AppSpacing.horizontalSpaceSm,
                  Text(
                    '•',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  AppSpacing.horizontalSpaceSm,
                ],

                // Info de creación
                if (createdBy != null)
                  Flexible(
                    child: Text(
                      'Creada por $createdBy',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Obtiene el ícono según el tipo de horario
  IconData _getIcon() {
    if (!isTemplate) {
      return Icons.person_outline;
    }

    // Para plantillas, variar según horas semanales
    if (weeklyHours >= 35) {
      return Icons.schedule;
    } else if (weeklyHours >= 20) {
      return Icons.access_time;
    } else {
      return Icons.timer;
    }
  }

  /// Obtiene el color del ícono según el tipo
  Color _getIconColor() {
    if (!isTemplate) {
      return AppColors.secondary;
    }

    if (weeklyHours >= 35) {
      return AppColors.primary;
    } else if (weeklyHours >= 20) {
      return AppColors.info;
    } else {
      return AppColors.accent;
    }
  }
}

