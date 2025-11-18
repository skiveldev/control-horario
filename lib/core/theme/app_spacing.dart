import 'package:flutter/material.dart';

/// Sistema de espaciado del Control Horario
/// 
/// Basado en una escala de 4px que garantiza consistencia visual.
/// Todos los espaciados deben usar estos valores en lugar de números mágicos.
/// 
/// Ejemplo:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.md),
///   child: Text('Contenido'),
/// )
/// ```
class AppSpacing {
  // Prevenir instanciación
  AppSpacing._();

  // ============================================================================
  // SPACING VALUES (Valores base - múltiplos de 4)
  // ============================================================================

  /// Espaciado extra pequeño - 4px
  /// Uso: Separación mínima, espacios muy ajustados
  static const double xs = 4.0;

  /// Espaciado pequeño - 8px
  /// Uso: Espaciado interno de componentes pequeños
  static const double sm = 8.0;

  /// Espaciado mediano - 12px
  /// Uso: Separación entre elementos relacionados
  static const double md = 12.0;

  /// Espaciado grande - 16px (BASE)
  /// Uso: Espaciado estándar, padding de cards
  static const double lg = 16.0;

  /// Espaciado extra grande - 20px
  /// Uso: Separación entre secciones menores
  static const double xl = 20.0;

  /// Espaciado doble extra grande - 24px
  /// Uso: Padding de pantallas, separación de secciones
  static const double xxl = 24.0;

  /// Espaciado triple extra grande - 32px
  /// Uso: Separación mayor entre secciones
  static const double xxxl = 32.0;

  /// Espaciado grande de sección - 40px
  /// Uso: Márgenes laterales, separación de bloques grandes
  static const double huge = 40.0;

  /// Espaciado extra grande de sección - 48px
  /// Uso: Espaciado de héroes, headers grandes
  static const double massive = 48.0;

  /// Espaciado gigante - 64px
  /// Uso: Espaciado máximo, separación de secciones principales
  static const double giant = 64.0;

  // ============================================================================
  // EDGE INSETS (Paddings predefinidos)
  // ============================================================================

  /// Sin padding
  static const EdgeInsets none = EdgeInsets.zero;

  // Paddings uniformes (todos los lados iguales)
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);
  static const EdgeInsets allXxxl = EdgeInsets.all(xxxl);
  static const EdgeInsets allHuge = EdgeInsets.all(huge);

  // Paddings horizontales (izquierda y derecha)
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);
  static const EdgeInsets horizontalXxxl = EdgeInsets.symmetric(horizontal: xxxl);

  // Paddings verticales (arriba y abajo)
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXxl = EdgeInsets.symmetric(vertical: xxl);
  static const EdgeInsets verticalXxxl = EdgeInsets.symmetric(vertical: xxxl);

  // Paddings de página (uso común en pantallas)
  /// Padding estándar de página - 24px todos los lados
  static const EdgeInsets page = EdgeInsets.all(xxl);

  /// Padding de página para mobile - 16px todos los lados
  static const EdgeInsets pageMobile = EdgeInsets.all(lg);

  /// Padding de página para desktop - 40px horizontal, 32px vertical
  static const EdgeInsets pageDesktop = EdgeInsets.symmetric(
    horizontal: huge,
    vertical: xxxl,
  );

  // Paddings de card (uso común en tarjetas)
  /// Padding estándar de card - 16px todos los lados
  static const EdgeInsets card = EdgeInsets.all(lg);

  /// Padding de card pequeño - 12px todos los lados
  static const EdgeInsets cardSmall = EdgeInsets.all(md);

  /// Padding de card grande - 24px todos los lados
  static const EdgeInsets cardLarge = EdgeInsets.all(xxl);

  // ============================================================================
  // SIZED BOXES (Espaciadores predefinidos)
  // ============================================================================

  // Espaciadores horizontales
  static const Widget horizontalSpaceXs = SizedBox(width: xs);
  static const Widget horizontalSpaceSm = SizedBox(width: sm);
  static const Widget horizontalSpaceMd = SizedBox(width: md);
  static const Widget horizontalSpaceLg = SizedBox(width: lg);
  static const Widget horizontalSpaceXl = SizedBox(width: xl);
  static const Widget horizontalSpaceXxl = SizedBox(width: xxl);
  static const Widget horizontalSpaceXxxl = SizedBox(width: xxxl);

  // Espaciadores verticales
  static const Widget verticalSpaceXs = SizedBox(height: xs);
  static const Widget verticalSpaceSm = SizedBox(height: sm);
  static const Widget verticalSpaceMd = SizedBox(height: md);
  static const Widget verticalSpaceLg = SizedBox(height: lg);
  static const Widget verticalSpaceXl = SizedBox(height: xl);
  static const Widget verticalSpaceXxl = SizedBox(height: xxl);
  static const Widget verticalSpaceXxxl = SizedBox(height: xxxl);
  static const Widget verticalSpaceHuge = SizedBox(height: huge);

  // ============================================================================
  // GAPS (Para Flex widgets: Row, Column, Wrap)
  // ============================================================================

  /// Gap extra pequeño - 4px
  static const double gapXs = xs;

  /// Gap pequeño - 8px
  static const double gapSm = sm;

  /// Gap mediano - 12px
  static const double gapMd = md;

  /// Gap grande - 16px
  static const double gapLg = lg;

  /// Gap extra grande - 20px
  static const double gapXl = xl;

  /// Gap doble extra grande - 24px
  static const double gapXxl = xxl;

  /// Gap triple extra grande - 32px
  static const double gapXxxl = xxxl;

  // ============================================================================
  // BORDER RADIUS (Radios de borde)
  // ============================================================================

  /// Radio extra pequeño - 4px
  /// Uso: Badges pequeños, chips
  static const double radiusXs = 4.0;

  /// Radio pequeño - 8px
  /// Uso: Botones pequeños, inputs
  static const double radiusSm = 8.0;

  /// Radio mediano - 12px
  /// Uso: Cards, botones estándar
  static const double radiusMd = 12.0;

  /// Radio grande - 16px
  /// Uso: Cards grandes, modales
  static const double radiusLg = 16.0;

  /// Radio extra grande - 20px
  /// Uso: Cards especiales, elementos destacados
  static const double radiusXl = 20.0;

  /// Radio circular - 999px
  /// Uso: Avatares, botones circulares
  static const double radiusCircular = 999.0;

  // BorderRadius predefinidos
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusCircular => BorderRadius.circular(radiusCircular);

  // ============================================================================
  // ICON SIZES (Tamaños de íconos)
  // ============================================================================

  /// Ícono extra pequeño - 12px
  static const double iconXs = 12.0;

  /// Ícono pequeño - 16px
  static const double iconSm = 16.0;

  /// Ícono mediano - 20px
  static const double iconMd = 20.0;

  /// Ícono grande - 24px (estándar Material)
  static const double iconLg = 24.0;

  /// Ícono extra grande - 32px
  static const double iconXl = 32.0;

  /// Ícono doble extra grande - 40px
  static const double iconXxl = 40.0;

  /// Ícono triple extra grande - 48px
  static const double iconXxxl = 48.0;

  // ============================================================================
  // AVATAR SIZES (Tamaños de avatares)
  // ============================================================================

  /// Avatar pequeño - 32px
  static const double avatarSm = 32.0;

  /// Avatar mediano - 40px
  static const double avatarMd = 40.0;

  /// Avatar grande - 48px
  static const double avatarLg = 48.0;

  /// Avatar extra grande - 64px
  static const double avatarXl = 64.0;

  /// Avatar doble extra grande - 80px
  static const double avatarXxl = 80.0;

  /// Avatar huge - 120px
  static const double avatarHuge = 120.0;

  // ============================================================================
  // BUTTON HEIGHTS (Alturas de botones)
  // ============================================================================

  /// Botón pequeño - 32px
  static const double buttonHeightSm = 32.0;

  /// Botón mediano - 40px
  static const double buttonHeightMd = 40.0;

  /// Botón grande - 48px (estándar)
  static const double buttonHeightLg = 48.0;

  /// Botón extra grande - 56px
  static const double buttonHeightXl = 56.0;

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Crear EdgeInsets personalizado con valores del sistema
  static EdgeInsets custom({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: top ?? 0,
      bottom: bottom ?? 0,
      left: left ?? 0,
      right: right ?? 0,
    );
  }

  /// Crear EdgeInsets simétrico personalizado
  static EdgeInsets symmetric({
    double? horizontal,
    double? vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }
}

