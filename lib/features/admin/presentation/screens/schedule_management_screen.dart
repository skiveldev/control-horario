import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../../shared/widgets/cards/schedule_card.dart';
import '../../models/schedule_model.dart';
import '../../providers/schedule_management_provider.dart';
import '../widgets/schedule_template_modal.dart';

/// Pantalla de gestión de horarios (Admin/RRHH)
///
/// Muestra lista de plantillas de horarios predefinidas desde Firebase.
/// Admin puede crear, editar y ver plantillas en tiempo real.
///
/// ✅ Conectado a Firebase via allScheduleTemplatesProvider
class ScheduleManagementScreen extends ConsumerWidget {
  const ScheduleManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar plantillas desde Firebase en tiempo real
    final templatesAsync = ref.watch(allScheduleTemplatesProvider);

    return AdminLayout(
      currentRoute: AppRouter.adminSchedules,
      child: templatesAsync.when(
        data: (templates) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con título, descripción y botón
                _buildHeader(context, templates.length),

                AppSpacing.verticalSpaceXl,

                // Lista de plantillas
                templates.isEmpty
                    ? _buildEmptyState(context)
                    : _buildTemplatesList(context, templates),
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              AppSpacing.verticalSpaceMd,
              Text(
                'Error al cargar plantillas',
                style: AppTextStyles.h5,
              ),
              AppSpacing.verticalSpaceSm,
              Text(
                error.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int templateCount) {
    final isMobile = MediaQuery.of(context).size.width < Breakpoints.tablet;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna con título y descripción (Flexible para evitar overflow)
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plantillas de Horario', style: AppTextStyles.h3),
              AppSpacing.verticalSpaceSm,
              Text(
                'Plantillas predefinidas que puedes asignar a tus empleados. Tienes $templateCount ${templateCount == 1 ? 'plantilla disponible' : 'plantillas disponibles'}.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        AppSpacing.horizontalSpaceLg,

        // Botón "Nueva Plantilla" (responsive: texto completo en desktop, solo icono en mobile)
        CustomButton(
          text: isMobile ? '' : 'Nueva Plantilla',
          icon: Icons.add,
          variant: ButtonVariant.brand,
          size: ButtonSize.large,
          onPressed: () => _showTemplateModal(context, existingTemplate: null),
        ),
      ],
    );
  }

  Widget _buildTemplatesList(
    BuildContext context,
    List<ScheduleModel> templates,
  ) {
    final columns = context.responsiveValue(
      mobile: 1,
      tablet: 2,
      desktop: 2,
    );
    final gap = context.gridGap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGaps = (columns - 1) * gap;
        final availableWidth = constraints.maxWidth - totalGaps;
        final cardWidth = availableWidth / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: templates.map((template) {
            return SizedBox(
              width: cardWidth,
              child: ScheduleCard(
                name: template.name,
                description: template.description,
                weeklyHours: template.totalWeeklyHours,
                usedByCount: template.usedByCount,
                isTemplate: template.isTemplate,
                createdBy: template.createdBy,
                onTap: () => _showTemplateModal(
                  context,
                  existingTemplate: template,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allHuge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            AppSpacing.verticalSpaceLg,
            Text(
              'No hay plantillas disponibles',
              style: AppTextStyles.h4,
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              'Crea tu primera plantilla de horario',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalSpaceLg,
            ElevatedButton.icon(
              onPressed: () =>
                  _showTemplateModal(context, existingTemplate: null),
              icon: const Icon(Icons.add),
              label: const Text('Crear Plantilla'),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar modal de crear/editar plantilla
  void _showTemplateModal(
    BuildContext context, {
    required ScheduleModel? existingTemplate,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScheduleTemplateModal(
        existingTemplate: existingTemplate,
      ),
    );
  }
}
