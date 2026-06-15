import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
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
        borderRadius: AppSpacing.borderRadiusLg,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top section: icon, title area, stats chips ──
          Padding(
            padding: AppSpacing.allXxl,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive: row layout on wider cards, column on narrow.
                // At >= 700px we have enough room for icon + title + stats in one row.
                if (constraints.maxWidth >= 700) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Calendar icon — fixed size
                      _buildIcon(context, cs),
                      AppSpacing.horizontalSpaceXl,
                      // Name, year, and status badge — flexible fill
                      Flexible(
                        flex: 3,
                        child: _buildTitleArea(context, cs),
                      ),
                      AppSpacing.horizontalSpaceXl,
                      // Stats chips — flexible so they wrap internally when
                      // the row is not wide enough for all three chips inline.
                      Flexible(
                        flex: 2,
                        child: _buildStatsRow(cs),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildIcon(context, cs),
                        AppSpacing.horizontalSpaceMd,
                        Flexible(child: _buildTitleArea(context, cs)),
                      ],
                    ),
                    AppSpacing.verticalSpaceMd,
                    _buildStatsRow(cs),
                  ],
                );
              },
            ),
          ),

          // ── Divider ──
          Divider(height: 1, thickness: 1, color: cs.outlineVariant),

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
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.10)
            : cs.surfaceContainerHighest,
        borderRadius: AppSpacing.borderRadiusLg,
      ),
      child: Icon(
        Icons.calendar_month,
        size: AppSpacing.iconXxl,
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
        // Name + status badge — both flexible so neither causes overflow
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 3,
              child: Text(
                calendar.name,
                style: AppTextStyles.h3.copyWith(color: cs.onSurface),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            AppSpacing.horizontalSpaceSm,
            Flexible(
              flex: 1,
              child: _buildStatusBadge(cs),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Year subtitle
        Text(
          'Configuración ${calendar.year}',
          style: AppTextStyles.bodyMedium.copyWith(
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
        ? AppColors.success.withValues(alpha: 0.10)
        : cs.surfaceContainerHighest;

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.borderRadiusCircular,
      ),
      child: Text(
        isActive ? 'Activo' : 'Borrador',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
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
      runSpacing: AppSpacing.sm,
      children: [
        _statChip(
          icon: Icons.flag_outlined,
          value: '$nationals',
          label: 'Nacionales',
          color: AppColors.error,
        ),
        _statChip(
          icon: Icons.location_city_outlined,
          value: '$regionals',
          label: 'Regionales',
          color: cs.primary,
        ),
        _statChip(
          icon: Icons.beach_access_outlined,
          value: '$vacations',
          label: 'Vacaciones',
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12, // reference: px-3
        vertical: 8, // reference: py-2
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: AppSpacing.borderRadiusMd, // reference: rounded-xl (12px)
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: color),
          AppSpacing.horizontalSpaceSm,
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
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
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Desktop/tablet: single row, right-aligned — matches reference
          // <div class="flex gap-2"> with three side-by-side buttons.
          if (constraints.maxWidth >= 450) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildDuplicateButton(cs),
                AppSpacing.horizontalSpaceSm,
                _buildDeleteButton(cs),
                AppSpacing.horizontalSpaceSm,
                _buildEditButton(),
              ],
            );
          }
          // Mobile: wrap for overflow safety.  Children stay compact
          // and never stretch full width because the Wrap gives each
          // child loose constraints.
          return Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildDuplicateButton(cs),
              _buildDeleteButton(cs),
              _buildEditButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDuplicateButton(ColorScheme cs) {
    return TextButton.icon(
      onPressed: onDuplicate,
      icon: const Icon(Icons.copy_outlined, size: 18),
      label: const Text('Duplicar'),
      style: TextButton.styleFrom(
        foregroundColor: cs.onSurfaceVariant,
        textStyle: AppTextStyles.labelMedium,
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(ColorScheme cs) {
    return TextButton.icon(
      onPressed: onDelete,
      icon: const Icon(Icons.delete_outline, size: 18),
      label: const Text('Eliminar'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.error,
        textStyle: AppTextStyles.labelMedium,
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }

  /// Edit action button — shares the same brand gradient style as
  /// "Nuevo Calendario" for visual coherence.  Medium size matches the
  /// reference scale without oversizing the action bar.
  Widget _buildEditButton() {
    return CustomButton(
      text: 'Editar Calendario',
      icon: Icons.edit_outlined,
      variant: ButtonVariant.brand,
      size: ButtonSize.medium,
      onPressed: onEdit,
    );
  }
}
