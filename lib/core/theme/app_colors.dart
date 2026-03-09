import 'package:flutter/material.dart';

/// Sistema de colores del Control_horario
///
/// Paleta profesional diseñada para escuela de música
/// - Azul profundo: Confianza y profesionalismo
/// - Violeta: Creatividad y expresión artística
/// - Coral: Calidez y accesibilidad
class AppColors {
  // Prevenir instanciacion
  AppColors._();

  // ============================================================================
  // BRAND COLORS (Identidad del Proyecto Libertad)
  // ============================================================================

  /// Color primario - Azul profundo #1E3A8A
  /// Uso: Botones principales, headers, elementos importantes
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E293B);

  /// Color secundario - Violeta vibrante #7C3AED
  /// Uso: Acentos creativos, badges, elementos musicales
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF6D28D9);

  /// Color de acento - Coral cálido #FB923C
  /// Uso: Call-to-actions secundarios, highlights
  static const Color accent = Color(0xFFFB923C);
  static const Color accentLight = Color(0xFFFDBA74);
  static const Color accentDark = Color(0xFFEA580C);

  // ============================================================================
  // FUNCTIONAL COLORS (Estados y acciones)
  // ============================================================================

  /// Verde esmeralda - Estados exitosos #10B981
  /// Uso: Mensajes de éxito, fichajes completos, confirmaciones
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  /// Ámbar - Advertencias #F59E0B
  /// Uso: Alertas, fichajes incompletos, información importante
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  /// Rojo - Errores #EF4444
  /// Uso: Mensajes de error, validaciones fallidas, acciones destructivas
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  /// Azul cielo - Información #3B82F6
  /// Uso: Tooltips, mensajes informativos, ayudas
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // ============================================================================
  // SURFACES (Fondos y contenedores)
  // ============================================================================

  /// Fondo principal de la app #F8FAFC
  static const Color background = Color(0xFFF8FAFC);

  /// Fondo de tarjetas y contenedores #FFFFFF
  static const Color surface = Color(0xFFFFFFFF);

  /// Variante de superficie (hover states) #F1F5F9
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  /// Superficie oscura para overlays
  static const Color surfaceDark = Color(0xFF1E293B);

  // ============================================================================
  // TEXT COLORS (Tipografía)
  // ============================================================================

  /// Texto principal - Casi negro #0F172A
  /// Uso: Títulos, contenido principal
  static const Color textPrimary = Color(0xFF0F172A);

  /// Texto secundario - Gris medio #64748B
  /// Uso: Subtítulos, descripciones, labels
  static const Color textSecondary = Color(0xFF64748B);

  /// Texto terciario - Gris claro #94A3B8
  /// Uso: Placeholders, texto deshabilitado
  static const Color textTertiary = Color(0xFF94A3B8);

  /// Texto sobre fondos oscuros
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Texto sobre color primario
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============================================================================
  // BORDERS & DIVIDERS
  // ============================================================================

  /// Bordes principales #E2E8F0
  static const Color border = Color(0xFFE2E8F0);

  /// Bordes suaves #F1F5F9
  static const Color borderLight = Color(0xFFF1F5F9);

  /// Bordes oscuros para contraste
  static const Color borderDark = Color(0xFFCBD5E1);

  /// Dividers entre secciones
  static const Color divider = Color(0xFFE2E8F0);

  // ============================================================================
  // SPECIAL STATES (Interacciones)
  // ============================================================================

  /// Overlay para hover states
  static const Color hover = Color(0x0F000000); // 6% opacity black

  /// Overlay para pressed states
  static const Color pressed = Color(0x1F000000); // 12% opacity black

  /// Overlay para focus states
  static const Color focus = Color(0x1F1E3A8A); // 12% opacity primary

  /// Shadow color
  static const Color shadow = Color(0x1A000000); // 10% opacity black

  // ============================================================================
  // GRADIENTS (Para elementos especiales)
  // ============================================================================

  /// Gradiente principal (primario a secundario)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de acento
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente sutil para fondos
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================================================
  // GLASSMORPHISM SUPPORT (Para efectos de vidrio)
  // ============================================================================

  /// Fondo para glassmorphism en login
  /// Colores ultra claros para que el efecto glassmorphism sea visible
  /// Azul ultra claro → Violeta ultra claro (tinte 5%)
  static const LinearGradient loginGlassBackground = LinearGradient(
    colors: [
      Color(0xFFF0F4FF), // Azul ultra claro (tinte azul 5%)
      Color(0xFFF8F4FF), // Violeta ultra claro (tinte violeta 5%)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // CLOCKING STATUS COLORS (Estados de fichaje - Semántica)
  // ============================================================================

  /// Color para fichaje completado correctamente
  static Color get clockingComplete => success;

  /// Color para fichaje en pausa
  static Color get clockingOnBreak => info;

  /// Color para fichaje incompleto (sin salida registrada)
  static Color get clockingIncomplete => warning;

  /// Color para salida anticipada (antes de completar jornada)
  static Color get clockingEarlyExit => error;

  /// Color para fichajes editados manualmente
  static Color get clockingEdited => secondary;

  /// Color para fichajes cerrados automáticamente por el sistema
  static Color get clockingAutoClosed => textSecondary;

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Obtener color según estado de fichaje
  static Color getFichingStateColor(String state) {
    switch (state) {
      case 'completo':
        return success;
      case 'incompleto':
        return warning;
      case 'sin_fichar':
        return error;
      case 'activo':
        return info;
      default:
        return textSecondary;
    }
  }

  /// Obtener color según rol de usuario
  static Color getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return primary;
      case 'rrhh':
        return secondary;
      case 'empleado':
        return accent;
      default:
        return textSecondary;
    }
  }
}

/// Extensión para facilitar uso de colores con opacidad
extension AppColorsExtension on Color {
  /// Retorna el color con la opacidad especificada
  Color withOpacityValue(double opacity) {
    final clampedOpacity = opacity.clamp(0.0, 1.0);
    return withValues(alpha: clampedOpacity);
  }
}
