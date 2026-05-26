import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'buttons/custom_button.dart';

/// Estado vacío personalizado
///
/// Widget para mostrar cuando no hay datos disponibles.
/// Incluye ícono, mensaje y acción opcional.
///
/// Ejemplo de uso:
/// ```dart
/// EmptyState(
///   icon: Icons.inbox,
///   title: 'No hay registros',
///   message: 'Aún no has realizado ningún fichaje.',
/// )
///
/// // Con acción
/// EmptyState(
///   icon: Icons.people,
///   title: 'Sin empleados',
///   message: 'No se encontraron empleados en el sistema.',
///   actionLabel: 'Agregar Empleado',
///   onAction: () {
///     // Navegar a formulario
///   },
/// )
///
/// // Compacto
/// EmptyState.compact(
///   message: 'No hay datos',
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Ícono representativo
  final IconData icon;

  /// Título principal
  final String title;

  /// Mensaje descriptivo
  final String? message;

  /// Etiqueta del botón de acción
  final String? actionLabel;

  /// Callback de la acción
  final VoidCallback? onAction;

  /// Si debe ocupar toda la pantalla
  final bool fullScreen;

  /// Tamaño del ícono
  final double? iconSize;

  /// Color del ícono
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.fullScreen = false,
    this.iconSize,
    this.iconColor,
  });

  /// Constructor para estado vacío compacto
  const EmptyState.compact({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.title = 'Sin datos',
    this.actionLabel,
    this.onAction,
    this.fullScreen = false,
    this.iconSize = 48.0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (fullScreen) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: content),
      );
    }

    return Center(child: content);
  }

  Widget _buildContent(BuildContext context) {
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
              color: (iconColor ?? Theme.of(context).colorScheme.outline)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize ?? 64.0,
              color: iconColor ?? Theme.of(context).colorScheme.outline,
            ),
          ),

          AppSpacing.verticalSpaceXxl,

          // Título
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          // Mensaje
          if (message != null) ...[
            AppSpacing.verticalSpaceMd,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          // Acción
          if (actionLabel != null && onAction != null) ...[
            AppSpacing.verticalSpaceXxl,
            CustomButton(
              text: actionLabel!,
              onPressed: onAction,
              variant: ButtonVariant.primary,
            ),
          ],
        ],
      ),
    );
  }
}
