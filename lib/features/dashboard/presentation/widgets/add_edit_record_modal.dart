import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/inputs/time_picker_field.dart';
import '../../models/time_record_model.dart';
import 'category_tab_selector.dart';

/// Modal para añadir o editar un registro de tiempo
///
/// Features:
/// - Tabs de categoría (Trabajo/Pausa)
/// - Time pickers con validación
/// - Dropdown de ubicación
/// - Cálculo de duración en tiempo real
/// - Validaciones de solapamiento
/// - Aviso si registro está validado
class AddEditRecordModal extends StatefulWidget {
  final DateTime date;
  final TimeRecordModel? recordToEdit;
  final List<String> availableLocations;
  final Future<void> Function(TimeRecordModel) onSave;
  final List<TimeRecordModel> existingRecords; // Para validar solapamiento

  const AddEditRecordModal({
    super.key,
    required this.date,
    this.recordToEdit,
    required this.availableLocations,
    required this.onSave,
    this.existingRecords = const [],
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    TimeRecordModel? recordToEdit,
    required List<String> availableLocations,
    required Future<void> Function(TimeRecordModel) onSave,
    List<TimeRecordModel> existingRecords = const [],
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddEditRecordModal(
        date: date,
        recordToEdit: recordToEdit,
        availableLocations: availableLocations,
        onSave: onSave,
        existingRecords: existingRecords,
      ),
    );
  }

  @override
  State<AddEditRecordModal> createState() => _AddEditRecordModalState();
}

class _AddEditRecordModalState extends State<AddEditRecordModal> {
  late RecordCategory _selectedCategory;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedLocation;
  bool _isLoading = false;
  String? _startTimeError;
  String? _endTimeError;
  late bool _isActiveRecord; // ✨ Detectar si es registro activo

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      // Modo edición
      final record = widget.recordToEdit!;
      _selectedCategory = record.category;
      _startTime = _parseTime(record.startTime);
      _isActiveRecord = record.isActive; // ✨ Determinar si está activo

      // ✨ Solo cargar endTime si NO es activo
      if (!_isActiveRecord) {
        _endTime = _parseTime(record.endTime);
      }

      _selectedLocation = record.location;
    } else {
      // Modo añadir
      _selectedCategory = RecordCategory.work;
      _isActiveRecord = false; // ✨ Nuevos registros siempre son completados
      _selectedLocation = widget.availableLocations.isNotEmpty
          ? widget.availableLocations.first
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isEdit = widget.recordToEdit != null;
    final isValidated = widget.recordToEdit?.isValidated ?? false;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, isEdit, isMobile),

              AppSpacing.verticalSpaceLg,

              // Aviso si está validado
              if (isValidated) ...[
                _buildValidatedWarning(),
                AppSpacing.verticalSpaceLg,
              ],

              // ✨ Aviso si es registro activo
              if (_isActiveRecord) ...[
                _buildActiveRecordWarning(),
                AppSpacing.verticalSpaceLg,
              ],

              // Tipo de registro
              _buildSectionLabel('TIPO DE REGISTRO'),
              AppSpacing.verticalSpaceSm,
              CategoryTabSelector(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),

              AppSpacing.verticalSpaceXxl,

              // Horario
              _buildSectionLabel('HORARIO'),
              AppSpacing.verticalSpaceSm,
              // ✨ Mostrar layout diferente según si es activo o completado
              if (_isActiveRecord)
                // Registro activo: Solo hora inicio
                TimePickerField(
                  label: _getStartTimeLabel(), // ✨ Label contextual
                  value: _startTime,
                  errorText: _startTimeError,
                  onChanged: (time) {
                    setState(() {
                      _startTime = time;
                      _validateTimes();
                    });
                  },
                )
              else
                // Registro completado: Hora inicio + fin
                Row(
                  children: [
                    Expanded(
                      child: TimePickerField(
                        label: _getStartTimeLabel(), // ✨ Label contextual
                        value: _startTime,
                        errorText: _startTimeError,
                        onChanged: (time) {
                          setState(() {
                            _startTime = time;
                            _validateTimes();
                          });
                        },
                      ),
                    ),
                    AppSpacing.horizontalSpaceLg,
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.xl,
                      ),
                      child: Text(
                        '—',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    AppSpacing.horizontalSpaceLg,
                    Expanded(
                      child: TimePickerField(
                        label: _getEndTimeLabel(), // ✨ Label contextual
                        value: _endTime,
                        errorText: _endTimeError,
                        onChanged: (time) {
                          setState(() {
                            _endTime = time;
                            _validateTimes();
                          });
                        },
                      ),
                    ),
                  ],
                ),

              AppSpacing.verticalSpaceMd,

              // ✨ Duración solo si NO es activo
              if (!_isActiveRecord) _buildDurationDisplay(),

              AppSpacing.verticalSpaceXxl,

              // Lugar de trabajo
              _buildSectionLabel('LUGAR DE TRABAJO'),
              AppSpacing.verticalSpaceSm,
              _buildLocationDropdown(),

              AppSpacing.verticalSpaceXxl,

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  AppSpacing.horizontalSpaceMd,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSave() && !_isLoading ? _handleSave : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.textOnPrimary,
                                ),
                              ),
                            )
                          : Text(isEdit
                              ? 'Actualizar Registro'
                              : 'Guardar Registro'),
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

  Widget _buildHeader(BuildContext context, bool isEdit, bool isMobile) {
    final dateStr = DateFormat('d MMMM yyyy', 'es_ES').format(widget.date);
    final weekDay = DateFormat('EEEE', 'es_ES').format(widget.date);

    return Row(
      children: [
        Icon(
          isEdit ? Icons.edit : Icons.add_circle_outline,
          size: AppSpacing.iconXl,
          color: AppColors.primary,
        ),
        AppSpacing.horizontalSpaceMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Editar Registro' : 'Añadir Registro',
                style: isMobile ? AppTextStyles.h4 : AppTextStyles.h3,
              ),
              Text(
                '$weekDay, $dateStr',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Cerrar',
        ),
      ],
    );
  }

  Widget _buildValidatedWarning() {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: AppSpacing.iconMd,
            color: AppColors.info,
          ),
          AppSpacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Este registro fue validado',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  'Al editarlo, quedará marcado como modificado después de la validación.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✨ Warning para registros activos
  Widget _buildActiveRecordWarning() {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: AppSpacing.iconMd,
            color: AppColors.warning,
          ),
          AppSpacing.horizontalSpaceSm,
          Expanded(
            child: Text(
              _selectedCategory == RecordCategory.work
                  ? 'Registro en curso. Solo puedes editar la hora de entrada.'
                  : 'Pausa en curso. Solo puedes editar la hora de inicio de pausa.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✨ Obtener label contextual para hora de inicio
  String _getStartTimeLabel() {
    if (_selectedCategory == RecordCategory.work) {
      return 'Hora de entrada';
    } else {
      return 'Hora inicio de pausa';
    }
  }

  /// ✨ Obtener label contextual para hora de fin
  String _getEndTimeLabel() {
    if (_selectedCategory == RecordCategory.work) {
      return 'Hora de salida';
    } else {
      return 'Hora fin de pausa';
    }
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.overline.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDurationDisplay() {
    final duration = _calculateDuration();
    final hasValidTimes = _startTime != null && _endTime != null;

    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: AppSpacing.iconMd,
          color: hasValidTimes ? AppColors.primary : AppColors.textTertiary,
        ),
        AppSpacing.horizontalSpaceSm,
        Flexible(
          child: Text(
            'Duración estimada: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            hasValidTimes ? _formatDuration(duration) : '--h --m',
            style: AppTextStyles.bodyMedium.copyWith(
              color: hasValidTimes ? AppColors.primary : AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedLocation,
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.place, size: AppSpacing.iconMd),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      items: widget.availableLocations.map((location) {
        return DropdownMenuItem(
          value: location,
          child: Text(
            location,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLocation = value;
        });
      },
    );
  }

  void _validateTimes() {
    setState(() {
      _startTimeError = null;
      _endTimeError = null;
    });

    // ✨ Solo validar endTime si NO es registro activo
    if (!_isActiveRecord && _startTime != null && _endTime != null) {
      final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

      if (endMinutes <= startMinutes) {
        setState(() {
          _endTimeError = 'La hora de fin debe ser posterior a la de inicio';
        });
      }
    }
  }

  int _calculateDuration() {
    if (_startTime == null || _endTime == null) return 0;

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    return endMinutes > startMinutes ? endMinutes - startMinutes : 0;
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins.toString().padLeft(2, '0')}m';
  }

  bool _canSave() {
    // ✨ Si es activo: solo validar startTime
    if (_isActiveRecord) {
      return _startTime != null &&
          _selectedLocation != null &&
          _startTimeError == null;
    }

    // ✨ Si es completado: validar ambos campos
    return _startTime != null &&
        _endTime != null &&
        _selectedLocation != null &&
        _startTimeError == null &&
        _endTimeError == null;
  }

  Future<void> _handleSave() async {
    if (!_canSave()) return;

    // Validar solapamiento con registros existentes
    final overlapError = _checkOverlap();
    if (overlapError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(overlapError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Determinar recordStatus:
      // - Si EDITAMOS: preservar el estado original (puede ser active o completed)
      // - Si es NUEVO registro manual: siempre completed
      final recordStatus =
          widget.recordToEdit?.recordStatus ?? RecordStatus.completed;

      final record = TimeRecordModel(
        id: widget.recordToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        // TODO: This should never be null if auth is required
        userId: widget.recordToEdit?.userId ?? '',
        date: _formatDate(widget.date),
        category: _selectedCategory,
        startTime: _formatTimeOfDay(_startTime!),
        // ✨ Si es activo, preservar endTime original; si completado, usar nuevo valor
        endTime: _isActiveRecord
            ? widget.recordToEdit!
                .endTime // Preservar valor original (puede ser null o startTime)
            : _formatTimeOfDay(_endTime!), // Usar nuevo valor
        location: _selectedLocation!,
        // ✨ Si es activo, duración = 0; si completado, calcular duración
        durationMinutes: _isActiveRecord ? 0 : _calculateDuration(),
        recordStatus: recordStatus, // ✅ Preservar estado si es edición
        createdAt: widget.recordToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        // TODO: This should never be null if auth is required
        createdBy: widget.recordToEdit?.createdBy ?? '',
        isManual:
            widget.recordToEdit?.isManual ?? true, // Preservar si era manual
        validationStatus: widget.recordToEdit?.isValidated ?? false
            ? ValidationStatus.modifiedAfterValidation
            : ValidationStatus.editable,
        validatedBy: widget.recordToEdit?.validatedBy,
        validatedAt: widget.recordToEdit?.validatedAt,
      );

      // ✅ ESPERAR a que termine el guardado antes de cerrar
      await widget.onSave(record);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Verificar si el nuevo registro se solapa con registros existentes
  String? _checkOverlap() {
    // ✨ No validar solapamiento para registros activos (no tienen endTime completo)
    if (_isActiveRecord) return null;

    if (_startTime == null || _endTime == null) return null;

    final newStart = _timeToMinutes(_startTime!);
    final newEnd = _timeToMinutes(_endTime!);

    for (final existing in widget.existingRecords) {
      // Ignorar el registro que estamos editando
      if (widget.recordToEdit?.id == existing.id) continue;

      final existingStart = _parseTimeToMinutes(existing.startTime);
      final existingEnd = _parseTimeToMinutes(existing.endTime);

      if (existingStart == null || existingEnd == null) continue;

      // Verificar solapamiento
      // Solapan si: newStart < existingEnd AND newEnd > existingStart
      if (newStart < existingEnd && newEnd > existingStart) {
        return 'El horario se solapa con un registro existente (${existing.startTime} - ${existing.endTime})';
      }
    }

    return null; // Sin solapamiento
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  int? _parseTimeToMinutes(String time) {
    try {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      return null;
    }
  }

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
