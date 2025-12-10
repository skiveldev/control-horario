import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';

/// Diálogo de confirmación para salida anticipada
///
/// Modal de advertencia crítica que se muestra cuando el usuario intenta
/// salir antes de completar su jornada laboral. Adapta su presentación
/// según el dispositivo (Dialog en desktop, BottomSheet en mobile).
///
/// Ejemplo de uso:
/// ```dart
/// showEarlyExitDialog(
///   context: context,
///   remainingTime: Duration(hours: 2, minutes: 15),
///   onConfirm: () {
///     // Confirmar salida anticipada
///   },
///   onCancel: () {
///     // Cancelar salida
///   },
/// );
/// ```
Future<bool?> showEarlyExitDialog({
  required BuildContext context,
  required Duration remainingTime,
  required VoidCallback onConfirm,
  required VoidCallback onCancel,
}) {
  if (context.isMobile) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EarlyExitBottomSheet(
        remainingTime: remainingTime,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  } else {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EarlyExitDialog(
        remainingTime: remainingTime,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}

// ==============================================================================
// DIALOG VARIANT (Desktop/Tablet)
// ==============================================================================

class _EarlyExitDialog extends StatelessWidget {
  final Duration remainingTime;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _EarlyExitDialog({
    required this.remainingTime,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsHelper.of(context);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: AppSpacing.allXxl,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = AppColorsHelper.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono de advertencia
        Icon(
          Icons.warning_rounded,
          size: AppSpacing.iconXxxl,
          color: colors.warning,
        ),

        AppSpacing.verticalSpaceLg,

        // Título
        Text(
          'Salida Anticipada',
          style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
          textAlign: TextAlign.center,
        ),

        AppSpacing.verticalSpaceMd,

        // Mensaje principal
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
            children: [
              const TextSpan(text: 'Aún te faltan '),
              TextSpan(
                text: _formatDuration(remainingTime),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' para completar tu jornada laboral.'),
            ],
          ),
        ),

        AppSpacing.verticalSpaceSm,

        // Mensaje secundario
        Text(
          '¿Estás seguro de que deseas fichar la salida? Esto generará una incidencia.',
          style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
          textAlign: TextAlign.center,
        ),

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
                onPressed: () {
                  Navigator.of(context).pop(false);
                  onCancel();
                },
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: CustomButton(
                text: 'Confirmar Salida',
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                backgroundColor: colors.error,
                onPressed: () {
                  Navigator.of(context).pop(true);
                  onConfirm();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }
}

// ==============================================================================
// BOTTOM SHEET VARIANT (Mobile)
// ==============================================================================

class _EarlyExitBottomSheet extends StatelessWidget {
  final Duration remainingTime;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _EarlyExitBottomSheet({
    required this.remainingTime,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsHelper.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXl),
          topRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xxl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle visual (barra superior)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          AppSpacing.verticalSpaceLg,

          // Icono de advertencia
          Icon(
            Icons.warning_rounded,
            size: AppSpacing.iconXxxl,
            color: colors.warning,
          ),

          AppSpacing.verticalSpaceLg,

          // Título
          Text(
            'Salida Anticipada',
            style: AppTextStyles.h3.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalSpaceMd,

          // Mensaje principal
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textPrimary,
              ),
              children: [
                const TextSpan(text: 'Aún te faltan '),
                TextSpan(
                  text: _formatDuration(remainingTime),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' para completar tu jornada laboral.'),
              ],
            ),
          ),

          AppSpacing.verticalSpaceSm,

          // Mensaje secundario
          Text(
            '¿Estás seguro de que deseas fichar la salida? Esto generará una incidencia.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalSpaceXxl,

          // Botones (apilados en mobile)
          Column(
            children: [
              CustomButton(
                text: 'Confirmar Salida',
                variant: ButtonVariant.primary,
                size: ButtonSize.large,
                fullWidth: true,
                backgroundColor: colors.error,
                onPressed: () {
                  Navigator.of(context).pop(true);
                  onConfirm();
                },
              ),
              AppSpacing.verticalSpaceMd,
              CustomButton(
                text: 'Cancelar',
                variant: ButtonVariant.secondary,
                outline: true,
                size: ButtonSize.large,
                fullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop(false);
                  onCancel();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }
}
