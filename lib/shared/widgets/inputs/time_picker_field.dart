import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Campo de selección de hora con validación
///
/// Características:
/// - Icono de reloj
/// - Validación en tiempo real
/// - Picker nativo de Flutter
/// - Estados: normal, error, disabled
class TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay>? onChanged;
  final String? errorText;
  final bool enabled;

  const TimePickerField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final displayText = value != null ? _formatTime(value!) : '--:--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: enabled
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        AppSpacing.verticalSpaceXs,

        // Campo de entrada
        InkWell(
          onTap: enabled && onChanged != null
              ? () => _showTimePicker(context)
              : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: enabled
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : (enabled
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).colorScheme.outlineVariant),
                width: hasError ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: AppSpacing.iconMd,
                  color: hasError
                      ? AppColors.error
                      : (enabled
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.outline),
                ),
                AppSpacing.horizontalSpaceMd,
                Expanded(
                  child: Text(
                    displayText,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: enabled
                          ? (value != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.outline)
                          : Theme.of(context).colorScheme.outline,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: AppSpacing.iconLg,
                  color: enabled
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          ),
        ),

        // Error text
        if (hasError) ...[
          AppSpacing.verticalSpaceXs,
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: AppSpacing.iconXs,
                color: AppColors.error,
              ),
              AppSpacing.horizontalSpaceXs,
              Expanded(
                child: Text(
                  errorText!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final initialTime = value ?? const TimeOfDay(hour: 9, minute: 0);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Theme.of(context).colorScheme.surface,
                hourMinuteTextColor: Theme.of(context).colorScheme.onSurface,
                dialHandColor: AppColors.primary,
                dialBackgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                entryModeIconColor: AppColors.primary,
                helpTextStyle: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (pickedTime != null && onChanged != null) {
      onChanged!(pickedTime);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
