import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

/// Tamaño del spinner
enum SpinnerSize {
  /// Pequeño - 16x16
  small,

  /// Mediano - 24x24
  medium,

  /// Grande - 32x32
  large,

  /// Extra grande - 48x48
  extraLarge,
}

/// Spinner de carga personalizado
///
/// Indicador de carga consistente con el diseño de la app.
/// Soporta diferentes tamaños y puede incluir texto.
///
/// Ejemplo de uso:
/// ```dart
/// LoadingSpinner()
///
/// // Con texto
/// LoadingSpinner(
///   message: 'Cargando datos...',
///   size: SpinnerSize.large,
/// )
///
/// // Solo spinner pequeño
/// LoadingSpinner(
///   size: SpinnerSize.small,
///   color: AppColors.primary,
/// )
/// ```
class LoadingSpinner extends StatelessWidget {
  /// Mensaje de carga opcional
  final String? message;

  /// Tamaño del spinner
  final SpinnerSize size;

  /// Color personalizado
  final Color? color;

  /// Si debe ocupar toda la pantalla
  final bool fullScreen;

  const LoadingSpinner({
    super.key,
    this.message,
    this.size = SpinnerSize.large,
    this.color,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final spinner = _buildSpinner(context);

    if (fullScreen) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: spinner),
      );
    }

    return spinner;
  }

  Widget _buildSpinner(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _getSize(),
          height: _getSize(),
          child: CircularProgressIndicator(
            strokeWidth: _getStrokeWidth(),
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
          ),
        ),
        if (message != null) ...[
          AppSpacing.verticalSpaceMd,
          Text(
            message!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  double _getSize() {
    switch (size) {
      case SpinnerSize.small:
        return 16.0;
      case SpinnerSize.medium:
        return 24.0;
      case SpinnerSize.large:
        return 32.0;
      case SpinnerSize.extraLarge:
        return 48.0;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case SpinnerSize.small:
        return 2.0;
      case SpinnerSize.medium:
        return 3.0;
      case SpinnerSize.large:
        return 3.0;
      case SpinnerSize.extraLarge:
        return 4.0;
    }
  }
}

/// Widget de carga con overlay
///
/// Muestra un overlay semi-transparente con spinner.
/// Útil para bloquear la UI durante operaciones.
///
/// Ejemplo de uso:
/// ```dart
/// Stack(
///   children: [
///     MyContent(),
///     if (isLoading)
///       LoadingOverlay(
///         message: 'Guardando...',
///       ),
///   ],
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// Mensaje de carga
  final String? message;

  /// Opacidad del overlay (0.0 - 1.0)
  final double opacity;

  const LoadingOverlay({super.key, this.message, this.opacity = 0.5});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: opacity),
      child: Center(
        child: Container(
          padding: AppSpacing.allXxl,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: LoadingSpinner(message: message, size: SpinnerSize.large),
        ),
      ),
    );
  }
}
