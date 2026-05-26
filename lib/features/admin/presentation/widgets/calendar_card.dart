import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/holiday_type.dart';
import '../../models/work_calendar_model.dart';

/// Card para mostrar un calendario laboral en la lista de gestión
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: cs.outline),
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
          // Header
          _buildHeader(cs),

          // Divider
          Divider(height: 1, color: cs.outline),

          // Contenido: contadores de festivos
          _buildStats(),

          // Footer: botones de acción
          _buildActions(cs),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    return Padding(
      padding: AppSpacing.allLg,
      child: Row(
        children: [
          // Icono
          Container(
            padding: AppSpacing.allSm,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              Icons.calendar_month,
              size: AppSpacing.iconMd,
              color: AppColors.info,
            ),
          ),

          AppSpacing.horizontalSpaceMd,

          // Nombre y año
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calendar.name,
                  style: AppTextStyles.h5,
                  overflow: TextOverflow.ellipsis,
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

          // Badge de estado
          _buildStatusBadge(cs),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ColorScheme cs) {
    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: calendar.isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : cs.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: calendar.isActive
              ? AppColors.success.withValues(alpha: 0.4)
              : cs.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: calendar.isActive ? AppColors.success : cs.outline,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            calendar.isActive ? 'Activo' : 'Borrador',
            style: AppTextStyles.labelSmall.copyWith(
              color: calendar.isActive ? AppColors.success : cs.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
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
            label: '$vacations días vacac.',
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
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
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
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: onDuplicate,
            icon: const Icon(Icons.copy_outlined, size: 16),
            label: const Text('Duplicar'),
            style: TextButton.styleFrom(
              foregroundColor: cs.onSurfaceVariant,
              textStyle: AppTextStyles.labelMedium,
            ),
          ),
          AppSpacing.horizontalSpaceSm,
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Eliminar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              textStyle: AppTextStyles.labelMedium,
            ),
          ),
          AppSpacing.horizontalSpaceSm,
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
            ),
          ),
        ],
      ),
    );
  }
}
