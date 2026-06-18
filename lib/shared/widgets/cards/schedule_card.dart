import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Card para mostrar una plantilla de horario o un horario personalizado.
///
/// Rediseño bento-style con mejor jerarquía visual, badge de horas semanales
/// en píldora, icono contenedor y footer con empleados/creador.
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
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusXl,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppSpacing.borderRadiusXl,
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── TOP ROW: Icon container + weekly hours badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getIconColor().withValues(alpha: 0.10),
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: Icon(
                    _getIcon(),
                    size: AppSpacing.iconLg,
                    color: _getIconColor(),
                  ),
                ),

                const Spacer(),

                // Weekly hours badge (pill)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: AppSpacing.borderRadiusCircular,
                  ),
                  child: Text(
                    '${weeklyHours}h/sem',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpaceMd,

            // ── NAME ──
            Text(
              name,
              style: AppTextStyles.h5.copyWith(color: cs.onSurface),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),

            const SizedBox(height: 4),

            // ── DESCRIPTION ──
            Row(
              children: [
                Icon(
                  Icons.event_repeat,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Divider ──
            Divider(height: 1, thickness: 1, color: cs.outlineVariant),

            const SizedBox(height: AppSpacing.md),

            // ── FOOTER: employee count + createdBy ──
            Row(
              children: [
                // Employee count (solo para templates)
                if (isTemplate && usedByCount != null) ...[
                  Icon(
                    Icons.people,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Usada por $usedByCount ${usedByCount == 1 ? 'empleado' : 'empleados'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                // Separator dot
                if (isTemplate && usedByCount != null && createdBy != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Created by
                if (createdBy != null)
                  Flexible(
                    child: Text(
                      'Creada por $createdBy',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const Spacer(),

                // Edit hint arrow (subtle, only when tappable)
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
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
