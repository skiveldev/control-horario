import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../models/work_calendar_model.dart';
import '../../providers/calendar_management_provider.dart';
import '../widgets/calendar_card.dart';
import 'calendar_editor_screen.dart';

/// Pantalla de gestión de calendarios laborales (Admin)
///
/// Lista los calendarios creados (festivos nacionales, autonómicos y vacaciones)
/// y permite al administrador crear, editar, duplicar o eliminar calendarios.
class CalendarManagementScreen extends ConsumerWidget {
  const CalendarManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarsAsync = ref.watch(allCalendarsProvider);

    return AdminLayout(
      currentRoute: AppRouter.adminCalendars,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                context,
                ref,
                count: calendarsAsync.maybeWhen(
                  data: (c) => c.length,
                  orElse: () => 0,
                ),
              ),
              AppSpacing.verticalSpaceXl,
              calendarsAsync.when(
                data: (calendars) => calendars.isEmpty
                    ? _buildEmptyState(context, ref)
                    : _buildCalendarList(context, ref, calendars),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Error al cargar calendarios: $e',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error),
                  ),
                ),
              ),
              AppSpacing.verticalSpaceXl,
              _buildTipBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref, {
    required int count,
  }) {
    final isMobile = MediaQuery.of(context).size.width < Breakpoints.tablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Breadcrumbs
        Row(
          children: [
            GestureDetector(
              onTap: () => context.go(AppRouter.admin),
              child: Text(
                'Panel Admin',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                '›',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            Flexible(
              child: Text(
                'Calendarios Laborales',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceSm,
        // Título + botón condicional (solo visible cuando hay calendarios)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calendarios Laborales', style: AppTextStyles.h3),
                  AppSpacing.verticalSpaceXs,
                  Text(
                    'Gestiona festivos y vacaciones por región. '
                    'Tienes $count ${count == 1 ? 'calendario disponible' : 'calendarios disponibles'}.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (count > 0) ...[
              AppSpacing.horizontalSpaceLg,
              CustomButton(
                text: isMobile ? '' : 'Nuevo Calendario',
                icon: Icons.add,
                variant: ButtonVariant.brand,
                size: ButtonSize.large,
                onPressed: () => _navigateToEditor(context),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarList(
    BuildContext context,
    WidgetRef ref,
    List<WorkCalendarModel> calendars,
  ) {
    final columns = MediaQuery.of(context).size.width >= Breakpoints.desktop
        ? 2
        : MediaQuery.of(context).size.width >= Breakpoints.tablet
            ? 2
            : 1;
    const gap = AppSpacing.lg;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGaps = (columns - 1) * gap;
        final availableWidth = constraints.maxWidth - totalGaps;
        final cardWidth = availableWidth / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: calendars.map((calendar) {
            return SizedBox(
              width: cardWidth,
              child: CalendarCard(
                calendar: calendar,
                onEdit: () => _navigateToEditor(context, calendar: calendar),
                onDuplicate: () => _duplicateCalendar(context, ref, calendar),
                onDelete: () => _confirmDelete(context, ref, calendar),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.giant,
        horizontal: AppSpacing.massive,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSpacing.avatarXxl,
                height: AppSpacing.avatarXxl,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  size: AppSpacing.iconXxl,
                  color: AppColors.secondary,
                ),
              ),
              AppSpacing.verticalSpaceXl,
              Text(
                'No hay calendarios disponibles',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceMd,
              Text(
                'Crea tu primer calendario laboral para empezar a gestionar '
                'festivos, vacaciones y jornadas especiales por región o departamento.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceXl,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    text: 'Crear Primer Calendario',
                    icon: Icons.add,
                    variant: ButtonVariant.brand,
                    size: ButtonSize.large,
                    onPressed: () => _navigateToEditor(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipBanner() {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.surface,
            size: AppSpacing.iconLg,
          ),
          AppSpacing.horizontalSpaceMd,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Cómo funcionan los calendarios laborales?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  'Cada calendario define los días festivos y jornadas especiales '
                  'de una región. Puedes asignarlo a tus empleados para calcular '
                  'correctamente sus horas trabajadas.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.surface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditor(BuildContext context, {WorkCalendarModel? calendar}) {
    // TODO: Use GoRouter context.push() when CalendarEditorScreen route is added to app_router.dart
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CalendarEditorScreen(existingCalendar: calendar),
      ),
    );
  }

  Future<void> _duplicateCalendar(
    BuildContext context,
    WidgetRef ref,
    WorkCalendarModel original,
  ) async {
    try {
      await ref
          .read(calendarManagementProvider.notifier)
          .duplicateCalendar(original.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calendario "${original.name}" duplicado'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al duplicar: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WorkCalendarModel calendar,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar calendario'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${calendar.name}"?\n\n'
          'Los empleados asignados a este calendario quedarán sin calendario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(calendarManagementProvider.notifier)
                    .deleteCalendar(calendar.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calendario "${calendar.name}" eliminado'),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
