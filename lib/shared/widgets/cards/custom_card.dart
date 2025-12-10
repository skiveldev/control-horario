import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

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
    final radius = borderRadius ?? AppSpacing.radiusMd;

    // Usar Container con BoxShadow personalizado para mejor control
    final card = Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: _getBoxShadow(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: clipBehavior,
        child: Container(padding: padding ?? AppSpacing.card, child: child),
      ),
    );

    // Si es clickeable, envolver en Material + InkWell
    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(radius),
          child: card,
        ),
      );
    }

    return card;
  }

  /// Obtiene la sombra según el nivel de elevación
  ///
  /// Fase 1.5.1: Medium usa BoxShadow personalizado (opacity 0.10, blur 12)
  List<BoxShadow> _getBoxShadow() {
    switch (elevation) {
      case CardElevation.none:
        return [];

      case CardElevation.low:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4.0,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ];

      case CardElevation.medium:
        // Fase 1.5.1: Elevación media personalizada para mejor contraste
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ];

      case CardElevation.high:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20.0,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ];
    }
  }
}
