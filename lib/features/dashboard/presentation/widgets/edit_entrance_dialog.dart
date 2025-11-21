import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';

/// Diálogo para editar la hora de entrada del día actual
/// 
/// Permite al empleado corregir su hora de entrada si olvidó fichar.
/// Solo funciona para el día actual, días anteriores no son editables.
/// Adapta su presentación según el dispositivo (Dialog en desktop, BottomSheet en mobile).
/// 
/// Ejemplo de uso:
/// ```dart
/// showEditEntranceDialog(
///   context: context,
///   currentEntrance: TimeOfDay(hour: 9, minute: 0),
///   exitTime: TimeOfDay(hour: 18, minute: 0),
///   onSave: (newTime) {
///     // Guardar nueva hora de entrada
///   },
/// );
/// ```
Future<bool?> showEditEntranceDialog({
  required BuildContext context,
  required TimeOfDay currentEntrance,
  TimeOfDay? exitTime,
  required Function(TimeOfDay newTime) onSave,
}) {
  if (context.isMobile) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditEntranceBottomSheet(
        currentEntrance: currentEntrance,
        exitTime: exitTime,
        onSave: onSave,
      ),
    );
  } else {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _EditEntranceDialog(
        currentEntrance: currentEntrance,
        exitTime: exitTime,
        onSave: onSave,
      ),
    );
  }
}

// ==============================================================================
// DIALOG VARIANT (Desktop/Tablet)
// ==============================================================================

class _EditEntranceDialog extends StatefulWidget {
  final TimeOfDay currentEntrance;
  final TimeOfDay? exitTime;
  final Function(TimeOfDay newTime) onSave;

  const _EditEntranceDialog({
    required this.currentEntrance,
    required this.exitTime,
    required this.onSave,
  });

  @override
  State<_EditEntranceDialog> createState() => _EditEntranceDialogState();
}

class _EditEntranceDialogState extends State<_EditEntranceDialog> {
  late TimeOfDay selectedTime;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.currentEntrance;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: AppSpacing.allXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con título e icono
            Row(
              children: [
                Icon(
                  Icons.edit_calendar_rounded,
                  color: AppColors.primary,
                  size: AppSpacing.iconLg,
                ),
                AppSpacing.horizontalSpaceSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editar Hora de Entrada',
                        style: AppTextStyles.h4,
                      ),
                      Text(
                        'Solo registros del día actual',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpaceLg,

            // Fecha actual con badge
            Container(
              padding: AppSpacing.allMd,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppSpacing.iconSm,
                    color: AppColors.textSecondary,
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Text(
                    'HOY - ${_formatDate(DateTime.now())}',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalSpaceLg,

            // TimePicker
            _buildTimePicker(),

            AppSpacing.verticalSpaceMd,

            // Información actual
            _buildCurrentInfo(),

            // Mensaje de error si existe
            if (errorMessage != null) ...[
              AppSpacing.verticalSpaceSm,
              Container(
                padding: AppSpacing.allSm,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: AppColors.error,
                    ),
                    AppSpacing.horizontalSpaceXs,
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            AppSpacing.verticalSpaceXxl,

            // Botones
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancelar',
                    variant: ButtonVariant.secondary,
                    outline: true,
                    size: ButtonSize.large,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                AppSpacing.horizontalSpaceMd,
                Expanded(
                  child: CustomButton(
                    text: 'Guardar',
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    onPressed: _canSave() ? _handleSave : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _showTimePicker,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: AppSpacing.allLg,
        decoration: BoxDecoration(
          border: Border.all(
            color: errorMessage != null ? AppColors.error : AppColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: AppSpacing.iconXl,
              color: AppColors.primary,
            ),
            AppSpacing.horizontalSpaceMd,
            Text(
              _formatTimeOfDay(selectedTime),
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Icon(
              Icons.edit,
              size: AppSpacing.iconMd,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentInfo() {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.login,
            label: 'Entrada actual',
            value: _formatTimeOfDay(widget.currentEntrance),
            color: AppColors.textSecondary,
          ),
          if (widget.exitTime != null) ...[
            AppSpacing.verticalSpaceXs,
            _buildInfoRow(
              icon: Icons.logout,
              label: 'Salida registrada',
              value: _formatTimeOfDay(widget.exitTime!),
              color: AppColors.success,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        AppSpacing.horizontalSpaceXs,
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _validateTime();
      });
    }
  }

  void _validateTime() {
    setState(() {
      errorMessage = null;

      // Validar que no sea hora futura
      final now = TimeOfDay.now();
      if (_isTimeAfter(selectedTime, now)) {
        errorMessage = 'No puedes registrar una hora futura';
        return;
      }

      // Validar que sea anterior a la salida (si existe)
      if (widget.exitTime != null) {
        if (!_isTimeBefore(selectedTime, widget.exitTime!)) {
          errorMessage =
              'La entrada debe ser anterior a la salida (${_formatTimeOfDay(widget.exitTime!)})';
          return;
        }
      }
    });
  }

  bool _canSave() {
    // No puede guardar si hay error
    if (errorMessage != null) return false;

    // No puede guardar si no cambió nada
    if (selectedTime.hour == widget.currentEntrance.hour &&
        selectedTime.minute == widget.currentEntrance.minute) {
      return false;
    }

    return true;
  }

  void _handleSave() {
    widget.onSave(selectedTime);
    Navigator.of(context).pop(true);
  }

  String _formatDate(DateTime date) {
    // MOCK DATA: Formato simple para FASE 1 (solo UI)
    // TODO [FASE-2]: Usar DateFormat con locale español
    final day = date.day;
    final month = _getMonthName(date.month);
    final year = date.year;
    final weekday = _getWeekdayName(date.weekday);
    return '$weekday $day $month $year';
  }

  String _getMonthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return weekdays[weekday - 1];
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return true;
    if (time1.hour > time2.hour) return false;
    return time1.minute < time2.minute;
  }

  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour > time2.hour) return true;
    if (time1.hour < time2.hour) return false;
    return time1.minute > time2.minute;
  }
}

// ==============================================================================
// BOTTOM SHEET VARIANT (Mobile)
// ==============================================================================

class _EditEntranceBottomSheet extends StatefulWidget {
  final TimeOfDay currentEntrance;
  final TimeOfDay? exitTime;
  final Function(TimeOfDay newTime) onSave;

  const _EditEntranceBottomSheet({
    required this.currentEntrance,
    required this.exitTime,
    required this.onSave,
  });

  @override
  State<_EditEntranceBottomSheet> createState() =>
      _EditEntranceBottomSheetState();
}

class _EditEntranceBottomSheetState extends State<_EditEntranceBottomSheet> {
  late TimeOfDay selectedTime;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.currentEntrance;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXl),
          topRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle visual
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          AppSpacing.verticalSpaceLg,

          // Título
          Text(
            'Editar Hora de Entrada',
            style: AppTextStyles.h4,
            textAlign: TextAlign.center,
          ),
          
          AppSpacing.verticalSpaceXs,
          
          Text(
            'Solo registros del día actual',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalSpaceMd,

          // Fecha
          Container(
            padding: AppSpacing.allSm,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                AppSpacing.horizontalSpaceXs,
                Text(
                  'HOY - ${_formatDate(DateTime.now())}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.verticalSpaceLg,

          // TimePicker
          _buildTimePicker(),

          AppSpacing.verticalSpaceMd,

          // Información actual
          _buildCurrentInfo(),

          // Mensaje de error
          if (errorMessage != null) ...[
            AppSpacing.verticalSpaceSm,
            Container(
              padding: AppSpacing.allSm,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                  AppSpacing.horizontalSpaceXs,
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          AppSpacing.verticalSpaceXxl,

          // Botones (apilados en mobile)
          Column(
            children: [
              CustomButton(
                text: 'Guardar Cambios',
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                fullWidth: true,
                onPressed: _canSave() ? _handleSave : null,
              ),
              AppSpacing.verticalSpaceMd,
              CustomButton(
                text: 'Cancelar',
                variant: ButtonVariant.secondary,
                outline: true,
                size: ButtonSize.large,
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _showTimePicker,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: AppSpacing.allLg,
        decoration: BoxDecoration(
          border: Border.all(
            color: errorMessage != null ? AppColors.error : AppColors.border,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: AppSpacing.iconXl,
              color: AppColors.primary,
            ),
            AppSpacing.horizontalSpaceMd,
            Text(
              _formatTimeOfDay(selectedTime),
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Icon(
              Icons.edit,
              size: AppSpacing.iconMd,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentInfo() {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.login,
            label: 'Actual',
            value: _formatTimeOfDay(widget.currentEntrance),
            color: AppColors.textSecondary,
          ),
          if (widget.exitTime != null) ...[
            AppSpacing.verticalSpaceXs,
            _buildInfoRow(
              icon: Icons.logout,
              label: 'Salida',
              value: _formatTimeOfDay(widget.exitTime!),
              color: AppColors.success,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        AppSpacing.horizontalSpaceXs,
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _validateTime();
      });
    }
  }

  void _validateTime() {
    setState(() {
      errorMessage = null;

      // Validar que no sea hora futura
      final now = TimeOfDay.now();
      if (_isTimeAfter(selectedTime, now)) {
        errorMessage = 'No puedes registrar una hora futura';
        return;
      }

      // Validar que sea anterior a la salida (si existe)
      if (widget.exitTime != null) {
        if (!_isTimeBefore(selectedTime, widget.exitTime!)) {
          errorMessage =
              'La entrada debe ser anterior a la salida (${_formatTimeOfDay(widget.exitTime!)})';
          return;
        }
      }
    });
  }

  bool _canSave() {
    if (errorMessage != null) return false;
    if (selectedTime.hour == widget.currentEntrance.hour &&
        selectedTime.minute == widget.currentEntrance.minute) {
      return false;
    }
    return true;
  }

  void _handleSave() {
    widget.onSave(selectedTime);
    Navigator.of(context).pop(true);
  }

  String _formatDate(DateTime date) {
    // MOCK DATA: Formato simple para FASE 1 (solo UI)
    // TODO [FASE-2]: Usar DateFormat con locale español
    final day = date.day;
    final month = _getMonthName(date.month);
    final weekday = _getWeekdayName(date.weekday);
    return '$weekday $day $month';
  }

  String _getMonthName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return weekdays[weekday - 1];
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour < time2.hour) return true;
    if (time1.hour > time2.hour) return false;
    return time1.minute < time2.minute;
  }

  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour > time2.hour) return true;
    if (time1.hour < time2.hour) return false;
    return time1.minute > time2.minute;
  }
}

