import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/models/user_model.dart';
import '../../providers/schedule_management_provider.dart';
import '../../providers/user_management_provider.dart';
import '../../models/schedule_model.dart';
import '../../../../shared/widgets/editors/week_schedule_editor.dart';

/// Modal para editar el horario de un empleado específico
///
/// Permite al admin:
/// - Ver horario actual
/// - Cambiar entre plantilla y horario personalizado
/// - Seleccionar plantilla del dropdown
/// - Configurar horario personalizado con WeekScheduleEditor
///
/// Ejemplo de uso:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => EmployeeScheduleEditorModal(employee: employee),
/// );
/// ```
class EmployeeScheduleEditorModal extends ConsumerStatefulWidget {
  /// Empleado cuyo horario se va a editar
  final UserModel employee;

  const EmployeeScheduleEditorModal({
    super.key,
    required this.employee,
  });

  @override
  ConsumerState<EmployeeScheduleEditorModal> createState() =>
      _EmployeeScheduleEditorModalState();
}

class _EmployeeScheduleEditorModalState
    extends ConsumerState<EmployeeScheduleEditorModal> {
  // Estado local del formulario (setState permitido)
  late String _scheduleType; // "template" | "custom"
  String? _selectedScheduleId;
  Map<String, DaySchedule>? _customSchedule;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Inicializar con datos actuales del empleado
    _scheduleType = widget.employee.scheduleType;
    _selectedScheduleId = widget.employee.scheduleId;

    // Si tiene custom schedule, parsearlo
    if (widget.employee.customSchedule != null) {
      _customSchedule = _parseCustomSchedule(widget.employee.customSchedule!);
    } else {
      _customSchedule = _generateEmptyWeek();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observar plantillas disponibles
    final templatesAsync = ref.watch(allScheduleTemplatesProvider);
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      child: Container(
        width: 900,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: AppSpacing.allXl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.primary,
                  size: 28,
                ),
                AppSpacing.horizontalSpaceMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar Horario',
                        style: AppTextStyles.h4,
                      ),
                      AppSpacing.verticalSpaceXs,
                      Text(
                        widget.employee.fullName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                ),
              ],
            ),

            AppSpacing.verticalSpaceLg,
            Divider(color: cs.outline),
            AppSpacing.verticalSpaceLg,

            // ===== TIPO DE HORARIO =====
            Text(
              'Tipo de horario',
              style: AppTextStyles.h6,
            ),
            AppSpacing.verticalSpaceSm,

            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Usar plantilla'),
                    subtitle:
                        const Text('Selecciona una plantilla predefinida'),
                    leading: Radio<String>(
                      value: 'template',
                      // ignore: deprecated_member_use
                      groupValue: _scheduleType,
                      // ignore: deprecated_member_use
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() => _scheduleType = value!);
                            },
                    ),
                    onTap: _isLoading
                        ? null
                        : () {
                            setState(() => _scheduleType = 'template');
                          },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Horario personalizado'),
                    subtitle: const Text('Configura un horario único'),
                    leading: Radio<String>(
                      value: 'custom',
                      // ignore: deprecated_member_use
                      groupValue: _scheduleType,
                      // ignore: deprecated_member_use
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() => _scheduleType = value!);
                            },
                    ),
                    onTap: _isLoading
                        ? null
                        : () {
                            setState(() => _scheduleType = 'custom');
                          },
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpaceLg,

            // ===== CONTENIDO SEGÚN TIPO =====
            Expanded(
              child: _scheduleType == 'template'
                  ? _buildTemplateSelector(cs, templatesAsync)
                  : _buildCustomScheduleEditor(cs),
            ),

            AppSpacing.verticalSpaceLg,
            Divider(color: cs.outline),
            AppSpacing.verticalSpaceMd,

            // ===== BOTONES =====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                AppSpacing.horizontalSpaceMd,
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Guardar Cambios'),
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
    );
  }

  // ==========================================================================
  // WIDGETS AUXILIARES
  // ==========================================================================

  Widget _buildTemplateSelector(
      ColorScheme cs, AsyncValue<List<ScheduleModel>> templatesAsync) {
    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 64,
                  color: cs.outline,
                ),
                AppSpacing.verticalSpaceMd,
                Text(
                  'No hay plantillas disponibles',
                  style: AppTextStyles.h6,
                ),
                AppSpacing.verticalSpaceSm,
                Text(
                  'Crea una plantilla primero o usa horario personalizado',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Validación defensiva: Verificar que el scheduleId existe en la lista
        final validScheduleId =
            templates.any((t) => t.scheduleId == _selectedScheduleId)
                ? _selectedScheduleId
                : null;

        // Si el scheduleId no existe, resetear la selección
        if (validScheduleId == null && _selectedScheduleId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedScheduleId = null);
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona una plantilla',
              style: AppTextStyles.labelLarge.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalSpaceSm,

            // Mostrar warning si el horario anterior no existe
            if (widget.employee.scheduleId != null &&
                validScheduleId == null) ...[
              Container(
                padding: AppSpacing.allSm,
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.warning),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber,
                        color: AppColors.warning, size: 20),
                    AppSpacing.horizontalSpaceSm,
                    Expanded(
                      child: Text(
                        'La plantilla anterior (${widget.employee.scheduleId}) ya no existe. Selecciona una nueva.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            DropdownButtonFormField<String>(
              initialValue: validScheduleId,
              decoration: InputDecoration(
                hintText: 'Selecciona una plantilla',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              items: templates.map((template) {
                return DropdownMenuItem(
                  value: template.scheduleId,
                  child: Text(
                    '${template.name} (${template.totalWeeklyHours}h/sem)',
                  ),
                );
              }).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() => _selectedScheduleId = value);
                    },
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Text(
          'Error al cargar plantillas: $error',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildCustomScheduleEditor(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configura el horario personalizado',
          style: AppTextStyles.labelLarge.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        AppSpacing.verticalSpaceSm,
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: WeekScheduleEditor(
              initialSchedule: _customSchedule!,
              onChanged: (newSchedule) {
                setState(() => _customSchedule = newSchedule);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // LÓGICA DE NEGOCIO
  // ==========================================================================

  Future<void> _save() async {
    // Validaciones
    if (_scheduleType == 'template' && _selectedScheduleId == null) {
      _showError('Debes seleccionar una plantilla');
      return;
    }

    if (_scheduleType == 'custom') {
      final totalHours = _calculateTotalHours(_customSchedule!);
      if (totalHours <= 0) {
        _showError('Debes configurar al menos un turno de trabajo');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Preparar datos según tipo
      Map<String, dynamic> updates = {
        'scheduleType': _scheduleType,
      };

      if (_scheduleType == 'template') {
        updates['scheduleId'] = _selectedScheduleId;
        updates['customSchedule'] = null; // Limpiar custom si existía
      } else {
        updates['scheduleId'] = null; // Limpiar scheduleId si existía
        updates['customSchedule'] = _serializeCustomSchedule(_customSchedule!);
        updates['weeklyHours'] =
            _calculateTotalHours(_customSchedule!).toDouble();
      }

      // Actualizar en Firebase
      await ref.read(userManagementProvider.notifier).updateEmployee(
            userId: widget.employee.userId,
            updates: updates,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Horario actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  int _calculateTotalHours(Map<String, DaySchedule> schedule) {
    return schedule.values
        .where((day) => day.isWorkDay)
        .fold(0.0, (sum, day) => sum + day.dailyHours)
        .round();
  }

  Map<String, dynamic> _serializeCustomSchedule(
      Map<String, DaySchedule> schedule) {
    return schedule.map((day, config) => MapEntry(
          day,
          {
            'isWorkDay': config.isWorkDay,
            'shifts': config.shifts
                .map((s) => {
                      'startTime': s.startTime,
                      'endTime': s.endTime,
                    })
                .toList(),
            'breakMinutes': config.breakMinutes,
            'dailyHours': config.dailyHours,
          },
        ));
  }

  Map<String, DaySchedule> _parseCustomSchedule(Map<String, dynamic> data) {
    return data.map((day, config) {
      final dayData = config as Map<String, dynamic>;
      final shiftsData = dayData['shifts'] as List<dynamic>? ?? [];
      final shifts = shiftsData.map((s) {
        final shiftMap = s as Map<String, dynamic>;
        return TimeShift(
          startTime: shiftMap['startTime'] as String? ?? '00:00',
          endTime: shiftMap['endTime'] as String? ?? '00:00',
        );
      }).toList();

      return MapEntry(
        day,
        DaySchedule(
          isWorkDay: dayData['isWorkDay'] as bool? ?? false,
          shifts: shifts,
          breakMinutes: dayData['breakMinutes'] as int? ?? 0,
          dailyHours: (dayData['dailyHours'] as num?)?.toDouble() ?? 0.0,
        ),
      );
    });
  }

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
}
