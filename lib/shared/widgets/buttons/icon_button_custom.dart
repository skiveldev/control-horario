import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Variantes de botón con ícono
enum IconButtonVariant {
  /// Estándar - Sin fondo, color primary al hover
  standard,

  /// Filled - Con fondo sólido
  filled,

  /// Tonal - Con fondo tonal (surfaceVariant)
  tonal,

  /// Outlined - Con borde
  outlined,
}

/// Tamaños de botón con ícono
enum IconButtonSize {
  /// Pequeño - 32x32px
  small,

  /// Mediano - 40x40px
  medium,

  /// Grande - 48x48px (estándar)
  large,
}

/// Botón de ícono personalizado
///
/// Botón circular o cuadrado que contiene solo un ícono.
/// Ideal para acciones secundarias, toolbars, o navegación.
///
/// Ejemplo de uso:
/// ```dart
/// IconButtonCustom(
///   icon: Icons.notifications,
///   onPressed: () {
///     print('Notificaciones');
///   },
/// )
///
/// // Con badge
/// Stack(
///   children: [
///     IconButtonCustom(
///       icon: Icons.notifications,
///       variant: IconButtonVariant.filled,
///       onPressed: () {},
///     ),
///     Positioned(
///       right: 8,
///       top: 8,
///       child: Container(
///         width: 8,
///         height: 8,
///         decoration: BoxDecoration(
///           color: Colors.red,
///           shape: BoxShape.circle,
///         ),
///       ),
///     ),
///   ],
/// )
/// ```
class IconButtonCustom extends StatelessWidget {
  /// Ícono a mostrar
  final IconData icon;

  /// Callback cuando se presiona
  final VoidCallback? onPressed;

  /// Variante visual
  final IconButtonVariant variant;

  /// Tamaño del botón
  final IconButtonSize size;

  /// Color personalizado del ícono
  final Color? iconColor;

  /// Color personalizado del fondo (solo para filled y tonal)
  final Color? backgroundColor;

  /// Tooltip descriptivo
  final String? tooltip;

  /// Si el botón es circular (true) o cuadrado con bordes redondeados (false)
  final bool circular;

  const IconButtonCustom({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = IconButtonVariant.standard,
    this.size = IconButtonSize.large,
    this.iconColor,
    this.backgroundColor,
    this.tooltip,
    this.circular = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = _buildButton();

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  Widget _buildButton() {
    final iconWidget = Icon(
      icon,
      size: _getIconSize(),
      color: iconColor ?? _getDefaultIconColor(),
    );

    switch (variant) {
      case IconButtonVariant.standard:
        return IconButton(
          onPressed: onPressed,
          icon: iconWidget,
          iconSize: _getIconSize(),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: _getButtonSize(),
            minHeight: _getButtonSize(),
            maxWidth: _getButtonSize(),
            maxHeight: _getButtonSize(),
          ),
          style: IconButton.styleFrom(
            foregroundColor: iconColor ?? AppColors.textPrimary,
            disabledForegroundColor: AppColors.textTertiary,
            shape: circular
                ? const CircleBorder()
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
          ),
        );

      case IconButtonVariant.filled:
        return IconButton.filled(
          onPressed: onPressed,
          icon: iconWidget,
          iconSize: _getIconSize(),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: _getButtonSize(),
            minHeight: _getButtonSize(),
            maxWidth: _getButtonSize(),
            maxHeight: _getButtonSize(),
          ),
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: iconColor ?? AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.borderLight,
            disabledForegroundColor: AppColors.textTertiary,
            shape: circular
                ? const CircleBorder()
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
          ),
        );

      case IconButtonVariant.tonal:
        return IconButton.filledTonal(
          onPressed: onPressed,
          icon: iconWidget,
          iconSize: _getIconSize(),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: _getButtonSize(),
            minHeight: _getButtonSize(),
            maxWidth: _getButtonSize(),
            maxHeight: _getButtonSize(),
          ),
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.surfaceVariant,
            foregroundColor: iconColor ?? AppColors.textPrimary,
            disabledBackgroundColor: AppColors.borderLight,
            disabledForegroundColor: AppColors.textTertiary,
            shape: circular
                ? const CircleBorder()
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
          ),
        );

      case IconButtonVariant.outlined:
        return IconButton.outlined(
          onPressed: onPressed,
          icon: iconWidget,
          iconSize: _getIconSize(),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: _getButtonSize(),
            minHeight: _getButtonSize(),
            maxWidth: _getButtonSize(),
            maxHeight: _getButtonSize(),
          ),
          style: IconButton.styleFrom(
            foregroundColor: iconColor ?? AppColors.textPrimary,
            disabledForegroundColor: AppColors.textTertiary,
            side: BorderSide(
              color:
                  onPressed == null ? AppColors.borderLight : AppColors.border,
              width: 1,
            ),
            shape: circular
                ? const CircleBorder()
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
          ),
        );
    }
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  double _getButtonSize() {
    switch (size) {
      case IconButtonSize.small:
        return 32.0;
      case IconButtonSize.medium:
        return 40.0;
      case IconButtonSize.large:
        return 48.0;
    }
  }

  double _getIconSize() {
    switch (size) {
      case IconButtonSize.small:
        return AppSpacing.iconSm;
      case IconButtonSize.medium:
        return AppSpacing.iconMd;
      case IconButtonSize.large:
        return AppSpacing.iconLg;
    }
  }

  Color _getDefaultIconColor() {
    switch (variant) {
      case IconButtonVariant.standard:
      case IconButtonVariant.tonal:
      case IconButtonVariant.outlined:
        return AppColors.textPrimary;
      case IconButtonVariant.filled:
        return AppColors.textOnPrimary;
    }
  }
}
