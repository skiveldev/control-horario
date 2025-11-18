import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Sistema de estilos de texto del Control Horario
/// 
/// Utiliza la fuente Inter de Google Fonts con una escala tipográfica clara.
/// Todos los textos de la app deben usar estos estilos para mantener consistencia.
/// 
/// Ejemplo:
/// ```dart
/// Text(
///   'Título Principal',
///   style: AppTextStyles.h1,
/// )
/// ```
class AppTextStyles {
  // Prevenir instanciación
  AppTextStyles._();

  // ============================================================================
  // HEADINGS (Títulos)
  // ============================================================================

  /// H1 - Título principal de pantalla
  /// Peso: 700 (Bold), Tamaño: 32px
  /// Uso: Títulos de páginas principales
  static final TextStyle h1 = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// H2 - Título de sección
  /// Peso: 700 (Bold), Tamaño: 24px
  /// Uso: Títulos de secciones dentro de una página
  static final TextStyle h2 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// H3 - Subtítulo importante
  /// Peso: 600 (SemiBold), Tamaño: 20px
  /// Uso: Subtítulos, títulos de cards
  static final TextStyle h3 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// H4 - Subtítulo secundario
  /// Peso: 600 (SemiBold), Tamaño: 18px
  /// Uso: Subtítulos menores, headers de listas
  static final TextStyle h4 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  /// H5 - Título pequeño
  /// Peso: 600 (SemiBold), Tamaño: 16px
  /// Uso: Títulos de widgets pequeños
  static final TextStyle h5 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// H6 - Título mínimo
  /// Peso: 600 (SemiBold), Tamaño: 14px
  /// Uso: Etiquetas destacadas, mini-headers
  static final TextStyle h6 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // BODY TEXT (Texto de contenido)
  // ============================================================================

  /// Body Large - Texto principal grande
  /// Peso: 400 (Regular), Tamaño: 16px
  /// Uso: Párrafos, contenido principal
  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Body Medium - Texto principal mediano (defecto)
  /// Peso: 400 (Regular), Tamaño: 14px
  /// Uso: Texto estándar, descripción, contenido general
  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Body Small - Texto principal pequeño
  /// Peso: 400 (Regular), Tamaño: 12px
  /// Uso: Textos secundarios, notas al pie
  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // LABELS (Etiquetas)
  // ============================================================================

  /// Label Large - Etiqueta grande
  /// Peso: 500 (Medium), Tamaño: 14px
  /// Uso: Labels de inputs, etiquetas importantes
  static final TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  /// Label Medium - Etiqueta mediana
  /// Peso: 500 (Medium), Tamaño: 12px
  /// Uso: Labels estándar, botones
  static final TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  /// Label Small - Etiqueta pequeña
  /// Peso: 500 (Medium), Tamaño: 11px
  /// Uso: Labels pequeños, badges, tags
  static final TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // ============================================================================
  // SPECIAL STYLES (Estilos especiales)
  // ============================================================================

  /// Button Text - Texto de botón
  /// Peso: 600 (SemiBold), Tamaño: 14px
  /// Uso: Texto dentro de botones
  static final TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: AppColors.textOnPrimary,
  );

  /// Caption - Texto descriptivo
  /// Peso: 400 (Regular), Tamaño: 12px
  /// Uso: Pies de foto, timestamps, información auxiliar
  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  /// Overline - Texto sobre línea
  /// Peso: 600 (SemiBold), Tamaño: 10px
  /// Uso: Categorías, secciones superiores
  static final TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  ).copyWith(
    textBaseline: TextBaseline.alphabetic,
  );

  /// Display Large - Números grandes
  /// Peso: 700 (Bold), Tamaño: 48px
  /// Uso: Reloj digital, números destacados
  static final TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  /// Display Medium - Números medianos
  /// Peso: 600 (SemiBold), Tamaño: 36px
  /// Uso: Métricas importantes
  static final TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Display Small - Números pequeños destacados
  /// Peso: 600 (SemiBold), Tamaño: 28px
  /// Uso: Contadores, estadísticas
  static final TextStyle displaySmall = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  // ============================================================================
  // LINK (Enlaces)
  // ============================================================================

  /// Link - Texto de enlace
  /// Peso: 500 (Medium), Tamaño: 14px
  /// Uso: Links clickeables
  static final TextStyle link = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  /// Link Small - Texto de enlace pequeño
  /// Peso: 500 (Medium), Tamaño: 12px
  /// Uso: Links secundarios
  static final TextStyle linkSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  // ============================================================================
  // HELPERS (Métodos auxiliares)
  // ============================================================================

  /// Aplicar color personalizado a cualquier estilo
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Aplicar peso personalizado a cualquier estilo
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Aplicar tamaño personalizado a cualquier estilo
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}

/// Extensión para facilitar modificaciones de TextStyle
extension AppTextStylesExtension on TextStyle {
  /// Cambiar color del texto
  TextStyle colored(Color color) => copyWith(color: color);

  /// Cambiar peso del texto
  TextStyle weighted(FontWeight weight) => copyWith(fontWeight: weight);

  /// Cambiar tamaño del texto
  TextStyle sized(double size) => copyWith(fontSize: size);

  /// Hacer el texto bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// Hacer el texto semibold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Hacer el texto medium
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Hacer el texto regular
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// Aplicar color primario
  TextStyle get primary => copyWith(color: AppColors.primary);

  /// Aplicar color secundario
  TextStyle get secondary => copyWith(color: AppColors.textSecondary);

  /// Aplicar color terciario
  TextStyle get tertiary => copyWith(color: AppColors.textTertiary);

  /// Aplicar color de éxito
  TextStyle get success => copyWith(color: AppColors.success);

  /// Aplicar color de advertencia
  TextStyle get warning => copyWith(color: AppColors.warning);

  /// Aplicar color de error
  TextStyle get error => copyWith(color: AppColors.error);

  /// Aplicar color de info
  TextStyle get info => copyWith(color: AppColors.info);
}

