import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/holiday_type.dart';
import '../../models/work_calendar_model.dart';

/// Card para mostrar un calendario laboral en la lista de gestión
///
/// Muestra nombre, año, estado (activo/borrador), estadísticas honestas
/// de festivos y vacaciones, y botones de acción.
///
/// Ejemplo de uso:
/// ```dart
/// CalendarCard(
///   calendar: WorkCalendarModel(id: '1', name: 'Madrid 2025', ...),
///   onEdit: () {},
///   onDuplicate: () {},
///   onDelete: () {},
/// )
/// ```
class CalendarCard extends StatelessWidget {
  final WorkCalendarModel calendar;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const CalendarCard({
    super.key,
    required this.calendar,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accent strip
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: calendar.isActive
                  ? AppColors.primary
                  : cs.outlineVariant.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusMd),
                topRight: Radius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),

          // Header
          _buildHeader(context, cs),

          // Divider
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),

          // Stats
          _buildStats(cs),

          // Divider
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),

          // Footer actions
          _buildActions(cs),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: AppSpacing.allLg,
      child: Row(
        children: [
          // Calendar icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: calendar.isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : cs.surfaceContainerHighest,
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              Icons.calendar_month,
              size: AppSpacing.iconLg,
              color:
                  calendar.isActive ? AppColors.primary : cs.onSurfaceVariant,
            ),
          ),

          AppSpacing.horizontalSpaceMd,

          // Name + year
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calendar.name,
                  style: AppTextStyles.h5.copyWith(color: cs.onSurface),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  'Año ${calendar.year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          _buildStatusBadge(cs),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ColorScheme cs) {
    final isActive = calendar.isActive;
    final color = isActive ? AppColors.success : cs.onSurfaceVariant;
    final bgColor = isActive
        ? AppColors.success.withValues(alpha: 0.08)
        : cs.surfaceContainerHighest;

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          AppSpacing.horizontalSpaceXs,
          Text(
            isActive ? 'Activo' : 'Borrador',
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(ColorScheme cs) {
    final nationals =
        calendar.events.where((e) => e.type == HolidayType.national).length;
    final regionals = calendar.events
        .where((e) =>
            e.type == HolidayType.regional || e.type == HolidayType.local)
        .length;
    final vacations = calendar.totalVacationDays;

    return Padding(
      padding: AppSpacing.allLg,
      child: Row(
        children: [
          _buildStatChip(
            icon: Icons.flag_outlined,
            label: '$nationals festivos nac.',
            color: AppColors.error,
          ),
          AppSpacing.horizontalSpaceSm,
          _buildStatChip(
            icon: Icons.location_city_outlined,
            label: '$regionals regionales',
            color: AppColors.info,
          ),
          AppSpacing.horizontalSpaceSm,
          _buildStatChip(
            icon: Icons.beach_access_outlined,
            label: '$vacations días vac.',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            AppSpacing.horizontalSpaceXs,
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(ColorScheme cs) {
    return Padding(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          TextButton.icon(
            onPressed: onDuplicate,
            icon: const Icon(Icons.copy_outlined, size: 16),
            label: const Text('Duplicar'),
            style: TextButton.styleFrom(
              foregroundColor: cs.onSurfaceVariant,
              textStyle: AppTextStyles.labelMedium,
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Eliminar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              textStyle: AppTextStyles.labelMedium,
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Editar'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              textStyle: AppTextStyles.labelMedium,
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              minimumSize: Size.zero,
            ),
          ),
        ],
      ),
    );
  }
}
