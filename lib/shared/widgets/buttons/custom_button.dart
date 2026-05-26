import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// Variantes de botón disponibles
enum ButtonVariant {
  /// Botón primario - Acción principal (gradiente verde)
  primary,

  /// Botón brand - Login y acciones de marca (gradiente azul-violeta)
  brand,

  /// Botón secundario - Acción secundaria (fondo gris)
  secondary,

  /// Botón de texto - Acción terciaria (sin fondo)
  text,

  /// Botón con borde - Acción alternativa (solo borde)
  outline,

  /// Botón de éxito - Acciones positivas (gradiente azul)
  success,

  /// Botón de error - Acciones destructivas (gradiente rojo)
  danger,

  /// Botón de advertencia - Acciones de pausa (gradiente naranja)
  warning,
}

/// Tamaños de botón disponibles
enum ButtonSize {
  /// Botón pequeño - 32px de altura
  small,

  /// Botón mediano - 40px de altura
  medium,

  /// Botón grande - 48px de altura (estándar)
  large,

  /// Botón extra grande - 56px de altura
  extraLarge,
}

/// Botón personalizado del proyecto Control Horario
///
/// Widget de botón reutilizable con múltiples variantes y tamaños.
/// Soporta íconos, estados de carga y deshabilitado.
///
/// Ejemplo de uso:
/// ```dart
/// CustomButton(
///   text: 'Entrar',
///   variant: ButtonVariant.primary,
///   onPressed: () {
///     print('Botón presionado');
///   },
/// )
///
/// // Con ícono
/// CustomButton(
///   text: 'Descargar',
///   icon: Icons.download,
///   variant: ButtonVariant.secondary,
///   size: ButtonSize.large,
///   onPressed: () {},
/// )
///
/// // Estado de carga
/// CustomButton(
///   text: 'Procesando...',
///   isLoading: true,
///   onPressed: null, // Deshabilitado
/// )
/// ```
class CustomButton extends StatelessWidget {
  /// Texto del botón
  final String text;

  /// Callback cuando se presiona el botón
  final VoidCallback? onPressed;

  /// Variante visual del botón
  final ButtonVariant variant;

  /// Tamaño del botón
  final ButtonSize size;

  /// Ícono opcional (se muestra a la izquierda del texto)
  final IconData? icon;

  /// Ícono opcional a la derecha del texto
  final IconData? suffixIcon;

  /// Si el botón está en estado de carga
  final bool isLoading;

  /// Ancho completo (expandirse al contenedor)
  final bool fullWidth;

  /// Radio de borde personalizado
  final double? borderRadius;

  /// Color de fondo personalizado (sobrescribe el de la variante)
  final Color? backgroundColor;

  /// Si el botón outline debe usarse (para secondary)
  final bool outline;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.large,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderRadius,
    this.backgroundColor,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context, isDisabled),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildPrimaryButton(context, isDisabled);
      case ButtonVariant.brand:
        return _buildBrandButton(context, isDisabled);
      case ButtonVariant.secondary:
        return _buildSecondaryButton(context, isDisabled);
      case ButtonVariant.text:
        return _buildTextButton(context, isDisabled);
      case ButtonVariant.outline:
        return _buildOutlineButton(context, isDisabled);
      case ButtonVariant.success:
        return _buildSuccessButton(context, isDisabled);
      case ButtonVariant.danger:
        return _buildDangerButton(context, isDisabled);
      case ButtonVariant.warning:
        return _buildWarningButton(context, isDisabled);
    }
  }

  // ==========================================================================
  // VARIANTES DE BOTÓN
  // ==========================================================================

  Widget _buildPrimaryButton(BuildContext context, bool isDisabled) {
    // Si no hay backgroundColor personalizado, usar GRADIENTE VERDE
    if (backgroundColor == null) {
      return _buildGradientButton(
        context,
        isDisabled,
        gradient: AppGradients.buttonPrimary,
        glowShadow: AppShadows.buttonPrimaryGlow,
        textColor: AppColorsDark.textOnPrimary,
      );
    }

    // Si hay backgroundColor personalizado, usar botón sólido estándar
    final bgColor = backgroundColor!;
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: bgColor.withValues(alpha: 0.4),
        disabledForegroundColor: AppColors.textOnPrimary.withValues(alpha: 0.5),
        elevation: isDisabled ? 0 : 2,
        shadowColor: AppColors.shadow,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSpacing.radiusMd,
          ),
        ),
        textStyle: _getTextStyle(),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildBrandButton(BuildContext context, bool isDisabled) {
    // Usar GRADIENTE AZUL-VIOLETA (coherente con header de login)
    return _buildGradientButton(
      context,
      isDisabled,
      gradient: AppGradients.buttonBrand,
      glowShadow: AppShadows.buttonBrandGlow,
      textColor: AppColors.textOnPrimary,
    );
  }

  /// Botón con gradiente + glow genérico (TODOS los botones principales)
  Widget _buildGradientButton(
    BuildContext context,
    bool isDisabled, {
    required LinearGradient gradient,
    required List<BoxShadow> glowShadow,
    Color textColor = AppColors.textOnPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusMd,
        ),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            padding: _getPadding(),
            decoration: BoxDecoration(
              gradient: gradient, // ← Gradiente personalizado
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppSpacing.radiusMd,
              ),
              boxShadow: isDisabled ? null : glowShadow, // ← Glow personalizado
            ),
            child: Center(
              child: DefaultTextStyle(
                style: _getTextStyle().copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                child: _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool isDisabled) {
    final cs = Theme.of(context).colorScheme;
    // Si outline es true, usar OutlinedButton en lugar de ElevatedButton
    if (outline) {
      return OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          disabledForegroundColor: cs.outline.withValues(
            alpha: 0.5,
          ),
          side: BorderSide(
            color: isDisabled ? cs.outline.withValues(alpha: 0.4) : cs.outline,
            width: 2,
          ),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSpacing.radiusMd,
            ),
          ),
          textStyle: _getTextStyle(),
        ),
        child: _buildContent(context),
      );
    }

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.surfaceContainerHighest,
        foregroundColor: cs.onSurface,
        disabledBackgroundColor: cs.surfaceContainerHighest.withValues(
          alpha: 0.4,
        ),
        disabledForegroundColor: cs.onSurface.withValues(alpha: 0.5),
        elevation: 0,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSpacing.radiusMd,
          ),
        ),
        textStyle: _getTextStyle(),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildTextButton(BuildContext context, bool isDisabled) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: Theme.of(context).colorScheme.outline,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSpacing.radiusMd,
          ),
        ),
        textStyle: _getTextStyle(),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildOutlineButton(BuildContext context, bool isDisabled) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.primary.withValues(alpha: 0.4),
        side: BorderSide(
          color: isDisabled
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.primary,
          width: 2,
        ),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSpacing.radiusMd,
          ),
        ),
        textStyle: _getTextStyle(),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildSuccessButton(BuildContext context, bool isDisabled) {
    // Usar gradiente azul/cyan para success (botón Retorno)
    return _buildGradientButton(
      context,
      isDisabled,
      gradient: AppGradients.buttonInfo,
      glowShadow: AppShadows.buttonInfoGlow,
      textColor: AppColors.textOnPrimary,
    );
  }

  Widget _buildDangerButton(BuildContext context, bool isDisabled) {
    // Usar GRADIENTE ROJO para danger (botón Salida)
    return _buildGradientButton(
      context,
      isDisabled,
      gradient: AppGradients.buttonDanger,
      glowShadow: AppShadows.buttonDangerGlow,
      textColor: AppColors.textOnPrimary,
    );
  }

  Widget _buildWarningButton(BuildContext context, bool isDisabled) {
    // Usar GRADIENTE NARANJA para warning (botón Pausa)
    return _buildGradientButton(
      context,
      isDisabled,
      gradient: AppGradients.buttonWarning,
      glowShadow: AppShadows.buttonWarningGlow,
      textColor: AppColors.textOnPrimary,
    );
  }

  // ==========================================================================
  // CONTENT BUILDER
  // ==========================================================================

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingColor(context),
          ),
        ),
      );
    }

    final children = <Widget>[];

    // Ícono izquierdo
    if (icon != null) {
      children.add(Icon(icon, size: _getIconSize()));
      children.add(AppSpacing.horizontalSpaceSm);
    }

    // Texto - envuelto en Flexible para evitar overflow
    children.add(
      Flexible(child: Text(text, overflow: TextOverflow.ellipsis, maxLines: 1)),
    );

    // Ícono derecho
    if (suffixIcon != null) {
      children.add(AppSpacing.horizontalSpaceSm);
      children.add(Icon(suffixIcon, size: _getIconSize()));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.buttonHeightSm;
      case ButtonSize.medium:
        return AppSpacing.buttonHeightMd;
      case ButtonSize.large:
        return AppSpacing.buttonHeightLg;
      case ButtonSize.extraLarge:
        return AppSpacing.buttonHeightXl;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        );
      case ButtonSize.medium:
        return AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        );
      case ButtonSize.large:
        return AppSpacing.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.md,
        );
      case ButtonSize.extraLarge:
        return AppSpacing.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.lg,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.labelSmall;
      case ButtonSize.medium:
        return AppTextStyles.labelMedium;
      case ButtonSize.large:
      case ButtonSize.extraLarge:
        return AppTextStyles.button;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.iconSm;
      case ButtonSize.medium:
        return AppSpacing.iconMd;
      case ButtonSize.large:
        return AppSpacing.iconMd;
      case ButtonSize.extraLarge:
        return AppSpacing.iconLg;
    }
  }

  Color _getLoadingColor(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.brand:
      case ButtonVariant.success:
      case ButtonVariant.danger:
      case ButtonVariant.warning:
        return AppColors.textOnPrimary;
      case ButtonVariant.secondary:
        return Theme.of(context).colorScheme.onSurface;
      case ButtonVariant.text:
      case ButtonVariant.outline:
        return AppColors.primary;
    }
  }
}
