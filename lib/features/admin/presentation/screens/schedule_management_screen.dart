import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../../shared/widgets/cards/schedule_card.dart';
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
        data: (templates) => Stack(
          children: [
            // Contenido principal
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con título y descripción
                    _buildHeader(templates.length),

                    AppSpacing.verticalSpaceXl,

                    // Lista de plantillas
                    templates.isEmpty
                        ? _buildEmptyState(context)
                        : _buildTemplatesList(context, templates),
                  ],
                ),
              ),
            ),

            // Floating Action Button - SOLO cuando hay plantillas
            if (templates.isNotEmpty)
              Positioned(
                right: 24,
                bottom: 24,
                child: FloatingActionButton.extended(
                  onPressed: () =>
                      _showTemplateModal(context, existingTemplate: null),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva Plantilla'),
                  backgroundColor: AppColors.primary,
                ),
              ),
          ],
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
                color: AppColors.error,
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
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int templateCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plantillas de Horario', style: AppTextStyles.h3),
        AppSpacing.verticalSpaceSm,
        Text(
          'Plantillas predefinidas que puedes asignar a tus empleados. Tienes $templateCount ${templateCount == 1 ? 'plantilla disponible' : 'plantillas disponibles'}.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplatesList(
    BuildContext context,
    List templates,
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
              color: AppColors.textTertiary,
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
                color: AppColors.textSecondary,
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
    required existingTemplate,
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
