import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/holiday_type.dart';
import '../../models/work_calendar_model.dart';

/// Card para mostrar un calendario laboral en la lista de gestión.
///
/// Diseño horizontal amplio: icono, título, badge de estado, chips de
/// estadísticas y barra de acciones con editar, duplicar y eliminar.
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
          // ── Top section: icon, title area, stats chips ──
          Padding(
            padding: AppSpacing.allLg,
            child: Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Large calendar icon
                _buildIcon(context, cs),
                // Name, year, and status badge
                _buildTitleArea(context, cs),
                // Stats chips
                _buildStatsRow(cs),
              ],
            ),
          ),

          // ── Divider ──
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),

          // ── Action bar ──
          _buildActions(cs),
        ],
      ),
    );
  }

  // ===========================================================================
  // ICON
  // ===========================================================================

  Widget _buildIcon(BuildContext context, ColorScheme cs) {
    final isActive = calendar.isActive;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.08)
            : cs.surfaceContainerHighest,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Icon(
        Icons.calendar_month,
        size: AppSpacing.iconXl,
        color: isActive ? AppColors.primary : cs.onSurfaceVariant,
      ),
    );
  }

  // ===========================================================================
  // TITLE AREA
  // ===========================================================================

  Widget _buildTitleArea(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name + status badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                calendar.name,
                style: AppTextStyles.h5.copyWith(color: cs.onSurface),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            AppSpacing.horizontalSpaceSm,
            _buildStatusBadge(cs),
          ],
        ),
        const SizedBox(height: 2),
        // Year subtitle
        Text(
          'Año ${calendar.year}',
          style: AppTextStyles.bodySmall.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // STATUS BADGE
  // ===========================================================================

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

  // ===========================================================================
  // STATS CHIPS
  // ===========================================================================

  Widget _buildStatsRow(ColorScheme cs) {
    final nationals =
        calendar.events.where((e) => e.type == HolidayType.national).length;
    final regionals = calendar.events
        .where((e) =>
            e.type == HolidayType.regional || e.type == HolidayType.local)
        .length;
    final vacations = calendar.totalVacationDays;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        _statChip(
          icon: Icons.flag_outlined,
          label: '$nationals festivos nac.',
          color: AppColors.error,
        ),
        _statChip(
          icon: Icons.location_city_outlined,
          label: '$regionals regionales',
          color: AppColors.info,
        ),
        _statChip(
          icon: Icons.beach_access_outlined,
          label: '$vacations días vac.',
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
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
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACTIONS
  // ===========================================================================

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
