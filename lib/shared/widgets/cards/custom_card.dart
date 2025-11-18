import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';

/// Variantes de elevación de card
enum CardElevation {
  /// Sin elevación (plano)
  none,

  /// Elevación baja - 2dp
  low,

  /// Elevación media - 4dp
  medium,

  /// Elevación alta - 8dp
  high,
}

/// Card personalizado del Control Horario
/// 
/// Contenedor reutilizable con diseño consistente.
/// Soporta diferentes elevaciones, padding y puede ser clickeable.
/// 
/// Ejemplo de uso:
/// ```dart
/// CustomCard(
///   child: Column(
///     children: [
///       Text('Título'),
///       Text('Contenido'),
///     ],
///   ),
/// )
/// 
/// // Card clickeable
/// CustomCard(
///   onTap: () {
///     print('Card presionado');
///   },
///   elevation: CardElevation.medium,
///   child: ListTile(
///     title: Text('Item'),
///     trailing: Icon(Icons.arrow_forward),
///   ),
/// )
/// 
/// // Card sin padding
/// CustomCard(
///   padding: EdgeInsets.zero,
///   child: Image.network('url'),
/// )
/// ```
class CustomCard extends StatelessWidget {
  /// Contenido del card
  final Widget child;

  /// Padding interno del card
  final EdgeInsets? padding;

  /// Margen externo del card
  final EdgeInsets? margin;

  /// Elevación del card
  final CardElevation elevation;

  /// Color de fondo personalizado
  final Color? backgroundColor;

  /// Color del borde (si se proporciona, se muestra borde)
  final Color? borderColor;

  /// Ancho del borde
  final double borderWidth;

  /// Radio de borde personalizado
  final double? borderRadius;

  /// Callback al hacer tap (hace el card clickeable)
  final VoidCallback? onTap;

  /// Callback al hacer long press
  final VoidCallback? onLongPress;

  /// Ancho del card
  final double? width;

  /// Alto del card
  final double? height;

  /// Clip behavior
  final Clip clipBehavior;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation = CardElevation.low,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: _getElevationValue(),
      color: backgroundColor ?? AppColors.surface,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusMd,
        ),
        side: borderColor != null
            ? BorderSide(
                color: borderColor!,
                width: borderWidth,
              )
            : BorderSide.none,
      ),
      margin: margin ?? EdgeInsets.zero,
      clipBehavior: clipBehavior,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? AppSpacing.card,
        child: child,
      ),
    );

    // Si es clickeable, envolver en InkWell
    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSpacing.radiusMd,
          ),
          child: card,
        ),
      );
    }

    return card;
  }

  double _getElevationValue() {
    switch (elevation) {
      case CardElevation.none:
        return AppConstants.elevationNone;
      case CardElevation.low:
        return AppConstants.elevationSm;
      case CardElevation.medium:
        return AppConstants.elevationMd;
      case CardElevation.high:
        return AppConstants.elevationLg;
    }
  }
}

