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
  final Function(TimeRecordModel) onSave;

  const AddEditRecordModal({
    super.key,
    required this.date,
    this.recordToEdit,
    required this.availableLocations,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    TimeRecordModel? recordToEdit,
    required List<String> availableLocations,
    required Function(TimeRecordModel) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddEditRecordModal(
        date: date,
        recordToEdit: recordToEdit,
        availableLocations: availableLocations,
        onSave: onSave,
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

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      // Modo edición
      final record = widget.recordToEdit!;
      _selectedCategory = record.category;
      _startTime = _parseTime(record.startTime);
      _endTime = _parseTime(record.endTime);
      _selectedLocation = record.location;
    } else {
      // Modo añadir
      _selectedCategory = RecordCategory.work;
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
              Row(
                children: [
                  Expanded(
                    child: TimePickerField(
                      label: 'Hora inicio',
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
                      label: 'Hora fin',
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

              // Duración estimada
              _buildDurationDisplay(),

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
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
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
        Text(
          'Duración estimada: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          hasValidTimes ? _formatDuration(duration) : '--h --m',
          style: AppTextStyles.bodyMedium.copyWith(
            color: hasValidTimes ? AppColors.primary : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedLocation,
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
          child: Row(
            children: [
              Icon(
                _getLocationIcon(location),
                size: AppSpacing.iconMd,
                color: AppColors.textSecondary,
              ),
              AppSpacing.horizontalSpaceSm,
              Text(location),
            ],
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

  IconData _getLocationIcon(String location) {
    if (location.toLowerCase().contains('oficina')) {
      return Icons.business;
    } else if (location.toLowerCase().contains('delegación')) {
      return Icons.location_city;
    } else if (location.toLowerCase().contains('remoto')) {
      return Icons.home;
    }
    return Icons.place;
  }

  void _validateTimes() {
    setState(() {
      _startTimeError = null;
      _endTimeError = null;
    });

    if (_startTime != null && _endTime != null) {
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
    return _startTime != null &&
        _endTime != null &&
        _selectedLocation != null &&
        _startTimeError == null &&
        _endTimeError == null;
  }

  Future<void> _handleSave() async {
    if (!_canSave()) return;

    setState(() {
      _isLoading = true;
    });

    // Simular guardado
    await Future.delayed(const Duration(milliseconds: 500));

    // Crear registro
    final record = TimeRecordModel(
      id: widget.recordToEdit?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.recordToEdit?.userId ?? 'user123', // TODO: Get from auth
      date: _formatDate(widget.date),
      category: _selectedCategory,
      startTime: _formatTimeOfDay(_startTime!),
      endTime: _formatTimeOfDay(_endTime!),
      location: _selectedLocation!,
      durationMinutes: _calculateDuration(),
      createdAt: widget.recordToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy:
          widget.recordToEdit?.createdBy ?? 'user123', // TODO: Get from auth
      isManual: true,
      validationStatus: widget.recordToEdit?.isValidated ?? false
          ? ValidationStatus.modifiedAfterValidation
          : ValidationStatus.editable,
      validatedBy: widget.recordToEdit?.validatedBy,
      validatedAt: widget.recordToEdit?.validatedAt,
    );

    widget.onSave(record);

    if (mounted) {
      Navigator.of(context).pop();
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
