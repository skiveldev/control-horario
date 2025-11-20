import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'buttons/custom_button.dart';

/// Estado de error personalizado
/// 
/// Widget para mostrar cuando ocurre un error.
/// Incluye ícono, mensaje y botón de reintento.
/// 
/// Ejemplo de uso:
/// ```dart
/// ErrorState(
///   message: 'No se pudieron cargar los datos',
///   onRetry: () {
///     // Reintentar carga
///   },
/// )
/// 
/// // Error de red
/// ErrorState.network(
///   onRetry: () {
///     _recargarDatos();
///   },
/// )
/// 
/// // Error personalizado
/// ErrorState(
///   icon: Icons.warning,
///   title: 'Acceso Denegado',
///   message: 'No tienes permisos para ver esta información.',
///   retryLabel: 'Volver',
///   onRetry: () {
///     Navigator.pop(context);
///   },
/// )
/// ```
class ErrorState extends StatelessWidget {
  /// Ícono representativo
  final IconData icon;

  /// Título del error
  final String title;

  /// Mensaje descriptivo del error
  final String message;

  /// Etiqueta del botón de reintento
  final String retryLabel;

  /// Callback al presionar reintento
  final VoidCallback? onRetry;

  /// Si debe ocupar toda la pantalla
  final bool fullScreen;

  /// Color del ícono
  final Color? iconColor;

  const ErrorState({
    super.key,
    this.icon = Icons.error_outline,
    this.title = 'Error',
    required this.message,
    this.retryLabel = 'Reintentar',
    this.onRetry,
    this.fullScreen = false,
    this.iconColor,
  });

  /// Constructor para error de red
  factory ErrorState.network({
    VoidCallback? onRetry,
    bool fullScreen = false,
  }) {
    return ErrorState(
      icon: Icons.wifi_off,
      title: 'Sin conexión',
      message: 'Verifica tu conexión a internet e intenta nuevamente.',
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }

  /// Constructor para error genérico
  factory ErrorState.generic({
    VoidCallback? onRetry,
    bool fullScreen = false,
  }) {
    return ErrorState(
      icon: Icons.error_outline,
      title: 'Algo salió mal',
      message: 'Ha ocurrido un error inesperado. Por favor, intenta nuevamente.',
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }

  /// Constructor para error de permisos
  factory ErrorState.permission({
    String? message,
    VoidCallback? onRetry,
    bool fullScreen = false,
  }) {
    return ErrorState(
      icon: Icons.lock_outline,
      title: 'Acceso Denegado',
      message: message ?? 'No tienes permisos para acceder a este recurso.',
      retryLabel: 'Volver',
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }

  /// Constructor para error 404
  factory ErrorState.notFound({
    String? message,
    VoidCallback? onRetry,
    bool fullScreen = false,
  }) {
    return ErrorState(
      icon: Icons.search_off,
      title: 'No encontrado',
      message: message ?? 'El recurso que buscas no existe o fue eliminado.',
      retryLabel: 'Volver',
      onRetry: onRetry,
      fullScreen: fullScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    if (fullScreen) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: content),
      );
    }

    return Center(child: content);
  }

  Widget _buildContent() {
    return Padding(
      padding: AppSpacing.allXxl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono
          Container(
            padding: AppSpacing.allXl,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.error).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64.0,
              color: iconColor ?? AppColors.error,
            ),
          ),

          AppSpacing.verticalSpaceXxl,

          // Título
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalSpaceMd,

          // Mensaje
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Botón de reintento
          if (onRetry != null) ...[
            AppSpacing.verticalSpaceXxl,
            CustomButton(
              text: retryLabel,
              icon: Icons.refresh,
              onPressed: onRetry,
              variant: ButtonVariant.primary,
            ),
          ],
        ],
      ),
    );
  }
}

