import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/schedule_model.dart';
import '../../providers/schedule_management_provider.dart';
import '../../../../shared/widgets/editors/week_schedule_editor.dart';

/// Modal para crear o editar una plantilla de horario
///
/// Modo crear: existingTemplate = null
/// Modo editar: existingTemplate = ScheduleModel existente
///
/// ⚠️ Este widget usa setState para UI local del formulario (permitido por .cursorrules)
///
/// Ejemplo de uso:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => ScheduleTemplateModal(
///     existingTemplate: template, // null para crear
///   ),
/// );
/// ```
class ScheduleTemplateModal extends ConsumerStatefulWidget {
  /// Plantilla existente (null = modo crear)
  final ScheduleModel? existingTemplate;

  const ScheduleTemplateModal({
    super.key,
    this.existingTemplate,
  });

  @override
  ConsumerState<ScheduleTemplateModal> createState() =>
      _ScheduleTemplateModalState();
}

class _ScheduleTemplateModalState extends ConsumerState<ScheduleTemplateModal> {
  // ⚠️ setState PERMITIDO: Estado local de formulario
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late Map<String, DaySchedule> _weekSchedule;
  int _calculatedHours = 0;

  bool get _isEditMode => widget.existingTemplate != null;

  @override
  void initState() {
    super.initState();

    // Inicializar con datos existentes o vacíos
    if (_isEditMode) {
      _nameController =
          TextEditingController(text: widget.existingTemplate!.name);
      _descriptionController =
          TextEditingController(text: widget.existingTemplate!.description);
      _weekSchedule = Map.from(widget.existingTemplate!.weeklySchedule);
      _calculatedHours = widget.existingTemplate!.totalWeeklyHours;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _weekSchedule = _generateEmptyWeek();
      _calculatedHours = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observar estado del provider para loading/error
    final state = ref.watch(scheduleManagementProvider);

    return Dialog(
      child: Container(
        width: 900,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: AppSpacing.allXl,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                children: [
                  Icon(
                    _isEditMode ? Icons.edit : Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  AppSpacing.horizontalSpaceMd,
                  Expanded(
                    child: Text(
                      _isEditMode
                          ? 'Editar Plantilla de Horario'
                          : 'Nueva Plantilla de Horario',
                      style: AppTextStyles.h4,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed:
                        state.isLoading ? null : () => Navigator.pop(context),
                  ),
                ],
              ),

              AppSpacing.verticalSpaceLg,

              // ===== CAMPOS BÁSICOS =====
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la plantilla *',
                  hintText: 'Ej: Jornada 40h (9:00-17:00)',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
                enabled: !state.isLoading,
              ),

              AppSpacing.verticalSpaceMd,

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej: Lunes a Viernes con 1h de pausa',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                maxLines: 2,
                enabled: !state.isLoading,
              ),

              AppSpacing.verticalSpaceLg,

              // ===== EDITOR DE HORARIO SEMANAL =====
              Text(
                'Configuración del horario semanal',
                style: AppTextStyles.h6,
              ),
              AppSpacing.verticalSpaceSm,
              Text(
                'Define qué días son laborables y sus turnos de trabajo',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              AppSpacing.verticalSpaceMd,

              // Editor (scrolleable)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: WeekScheduleEditor(
                    initialSchedule: _weekSchedule,
                    onChanged: (newSchedule) {
                      setState(() {
                        _weekSchedule = newSchedule;
                        _calculatedHours = _calculateTotalHours(newSchedule);
                      });
                    },
                  ),
                ),
              ),

              AppSpacing.verticalSpaceLg,

              // ===== RESUMEN + BOTONES =====
              Row(
                children: [
                  // Badge de horas totales (resumen)
                  Expanded(
                    child: Container(
                      padding: AppSpacing.allMd,
                      decoration: BoxDecoration(
                        color: _calculatedHours > 0
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: _calculatedHours > 0
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _calculatedHours > 0
                                ? Icons.check_circle_outline
                                : Icons.warning_outlined,
                            color: _calculatedHours > 0
                                ? AppColors.success
                                : AppColors.error,
                            size: 20,
                          ),
                          AppSpacing.horizontalSpaceSm,
                          Flexible(
                            child: Text(
                              _calculatedHours > 0
                                  ? 'Total: $_calculatedHours horas semanales'
                                  : 'Configure al menos un turno de trabajo',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _calculatedHours > 0
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  AppSpacing.horizontalSpaceLg,

                  // Botón Cancelar
                  TextButton(
                    onPressed:
                        state.isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),

                  AppSpacing.horizontalSpaceMd,

                  // Botón Guardar
                  ElevatedButton.icon(
                    onPressed: state.isLoading ? null : _save,
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : Icon(_isEditMode ? Icons.save : Icons.add),
                    label: Text(
                        _isEditMode ? 'Guardar Cambios' : 'Crear Plantilla'),
                    style: ElevatedButton.styleFrom(
                      padding: AppSpacing.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // LÓGICA DE NEGOCIO
  // ==========================================================================

  /// Guardar plantilla (crear o editar)
  Future<void> _save() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) return;

    // Validar que tenga al menos un turno
    if (_calculatedHours <= 0) {
      _showError('Debe configurar al menos un turno de trabajo');
      return;
    }

    try {
      if (_isEditMode) {
        // EDITAR plantilla existente
        await ref.read(scheduleManagementProvider.notifier).updateTemplate(
              scheduleId: widget.existingTemplate!.scheduleId,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              weeklySchedule: _weekSchedule,
            );
      } else {
        // CREAR nueva plantilla
        await ref.read(scheduleManagementProvider.notifier).createTemplate(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              weeklySchedule: _weekSchedule,
            );
      }

      // Éxito
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Plantilla actualizada correctamente'
                  : 'Plantilla creada correctamente',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// Mostrar error en SnackBar
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// Calcular total de horas semanales
  int _calculateTotalHours(Map<String, DaySchedule> schedule) {
    return schedule.values
        .where((day) => day.isWorkDay)
        .fold(0.0, (sum, day) => sum + day.dailyHours)
        .round();
  }

  /// Generar semana vacía (todos los días libres)
  Map<String, DaySchedule> _generateEmptyWeek() {
    const emptyDay = DaySchedule(
      isWorkDay: false,
      shifts: [],
      dailyHours: 0,
    );

    return {
      'monday': emptyDay,
      'tuesday': emptyDay,
      'wednesday': emptyDay,
      'thursday': emptyDay,
      'friday': emptyDay,
      'saturday': emptyDay,
      'sunday': emptyDay,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
