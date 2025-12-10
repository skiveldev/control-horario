import 'package:flutter/material.dart';

/// Sistema de colores para tema oscuro del Control Horario
///
/// Paleta profesional optimizada para:
/// - Contraste WCAG AAA (accesibilidad)
/// - Reducción de fatiga visual nocturna
/// - Consistencia visual con tema claro
/// - Colores semánticos para estados de fichaje
class AppColorsDark {
  // Prevenir instanciación
  AppColorsDark._();

  // ============================================================================
  // BACKGROUNDS Y SURFACES (Navy profundo casi negro)
  // ============================================================================

  /// Fondo más oscuro - Navy casi negro
  /// Uso: Background gradients, overlays
  static const Color background = Color(0xFF000414); // ← Navy casi negro

  /// Fondo principal de la app - Navy casi negro
  /// Uso: Scaffold, background general
  static const Color backgroundSecondary = Color(
    0xFF000414,
  ); // ← Navy casi negro

  /// Superficie para cards principales - Slate oscuro
  /// Uso: Cards, contenedores de contenido, tarjetas de tiempo
  static const Color surface = Color(0xFF0F172B); // ← Slate oscuro para cards

  /// Superficie elevada - Cards con más elevación
  /// Uso: Modales, dropdowns, tooltips
  static const Color surfaceElevated = Color(0xFF1E293B); // Derivado más claro

  /// Superficie hover - Estados interactivos
  /// Uso: Hover states, elementos activos
  static const Color surfaceHover = Color(0xFF1E2740); // Derivado con hover

  /// Variante de superficie
  /// Uso: Fondos alternativos, secciones diferenciadas
  static const Color surfaceVariant = Color(0xFF0A0F1E); // Variante azul oscuro

  /// Superficie oscura profunda
  /// Uso: Overlays oscuros, fondos de modales
  static const Color surfaceDark = Color(
    0xFF00020A,
  ); // Navy casi negro más oscuro

  // ============================================================================
  // TEXT COLORS (Tipografía optimizada para tema oscuro)
  // ============================================================================

  /// Texto principal - Blanco puro
  /// Uso: Títulos principales, contenido importante
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Texto secundario - Gris claro
  /// Uso: Subtítulos, descripciones, labels
  static const Color textSecondary = Color(0xFFB0B8C4);

  /// Texto terciario - Gris medio
  /// Uso: Placeholders, información secundaria
  static const Color textTertiary = Color(0xFF8B949E);

  /// Texto muted - Gris oscuro
  /// Uso: Texto de menor importancia
  static const Color textMuted = Color(0xFF6E7681);

  /// Texto deshabilitado
  /// Uso: Elementos no interactivos
  static const Color textDisabled = Color(0xFF484F58);

  /// Texto sobre fondos oscuros
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Texto sobre color primario (verde)
  static const Color textOnPrimary = Color(0xFF0F172A);

  // ============================================================================
  // BORDERS & DIVIDERS (Bordes sutiles)
  // ============================================================================

  /// Borde principal
  static const Color border = Color(0xFF30363D);

  /// Borde claro
  static const Color borderLight = Color(0xFF3D444D);

  /// Borde sutil - Casi invisible
  static const Color borderSubtle = Color(0xFF21262D);

  /// Borde oscuro para contraste
  static const Color borderDark = Color(0xFF1E293B);

  /// Dividers entre secciones
  static const Color divider = Color(0xFF30363D);

  // ============================================================================
  // PRIMARY - VERDE (Escala completa profesional)
  // ============================================================================

  /// Escala de verdes para botón entrada, estados activos, sidebar
  static const Color primary50 = Color(0xFFECFDF5);
  static const Color primary100 = Color(0xFFD1FAE5);
  static const Color primary200 = Color(0xFFA7F3D0);
  static const Color primary300 = Color(0xFF6EE7B7);
  static const Color primary400 = Color(0xFF34D399);
  static const Color primary500 = Color(
    0xFF22C55E,
  ); // ← Principal (verde botón)
  static const Color primary600 = Color(0xFF16A34A);
  static const Color primary700 = Color(0xFF15803D);
  static const Color primary800 = Color(0xFF166534);
  static const Color primary900 = Color(0xFF14532D);

  /// Verde principal - Alias para facilidad de uso
  static const Color primary = primary500;
  static const Color primaryLight = primary400;
  static const Color primaryDark = primary600;

  /// Glow del verde para efectos
  static const Color primaryGlow = Color(0x4022C55E);

  // ============================================================================
  // SECONDARY - CYAN/TEAL (Para badges info, día actual)
  // ============================================================================

  /// Escala de cyan para badges informativos
  static const Color secondary50 = Color(0xFFECFEFF);
  static const Color secondary100 = Color(0xFFCFFAFE);
  static const Color secondary200 = Color(0xFFA5F3FC);
  static const Color secondary300 = Color(0xFF67E8F9);
  static const Color secondary400 = Color(0xFF22D3EE);
  static const Color secondary500 = Color(0xFF06B6D4); // ← Principal cyan
  static const Color secondary600 = Color(0xFF0891B2);
  static const Color secondary700 = Color(0xFF0E7490);
  static const Color secondary800 = Color(0xFF155E75);
  static const Color secondary900 = Color(0xFF164E63);

  /// Cyan principal - Alias
  static const Color secondary = secondary500;
  static const Color secondaryLight = secondary400;
  static const Color secondaryDark = secondary600;

  // ============================================================================
  // ACCENT - MAGENTA/FUCHSIA (Para salida estimada, acentos creativos)
  // ============================================================================

  /// Escala de magenta para salida estimada, tiempo pausa
  static const Color accent50 = Color(0xFFFDF4FF);
  static const Color accent100 = Color(0xFFFAE8FF);
  static const Color accent200 = Color(0xFFF5D0FE);
  static const Color accent300 = Color(0xFFF0ABFC);
  static const Color accent400 = Color(0xFFE879F9);
  static const Color accent500 = Color(0xFFD946EF); // ← Principal magenta
  static const Color accent600 = Color(0xFFC026D3);
  static const Color accent700 = Color(0xFFA21CAF);
  static const Color accent800 = Color(0xFF86198F);
  static const Color accent900 = Color(0xFF701A75);

  /// Magenta principal - Alias
  static const Color accent = accent500;
  static const Color accentLight = accent400;
  static const Color accentDark = accent600;

  /// Purple para "Salida estimada" (de tu imagen)
  static const Color purple = Color(0xFFA855F7); // purple-500
  static const Color purpleLight = Color(0xFFC084FC);
  static const Color purpleDark = Color(0xFF9333EA);

  // ============================================================================
  // WARNING - AMARILLO/AMBER (Escala completa)
  // ============================================================================

  /// Escala de amarillo/amber para advertencias y "Fuera de horario"
  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning200 = Color(0xFFFDE68A);
  static const Color warning300 = Color(0xFFFCD34D);
  static const Color warning400 = Color(0xFFFBBF24);
  static const Color warning500 = Color(0xFFEAB308); // ← Principal warning
  static const Color warning600 = Color(0xFFCA8A04);
  static const Color warning700 = Color(0xFFA16207);
  static const Color warning800 = Color(0xFF854D0E);
  static const Color warning900 = Color(0xFF713F12);

  /// Warning principal - Alias
  static const Color warning = warning500;
  static const Color warningLight = warning400;
  static const Color warningDark = warning600;

  // ============================================================================
  // SUCCESS - ESMERALDA (Para badges "Completo")
  // ============================================================================

  /// Verde esmeralda para estados exitosos
  static const Color success = Color(0xFF10B981);
  static const Color successBackground = Color(0xFF0D3D30);
  static const Color successBorder = Color(0xFF166856);

  // ============================================================================
  // ERROR - ROJO (Para errores críticos)
  // ============================================================================

  /// Rojo para errores
  static const Color error = Color(0xFFEF4444);
  static const Color errorBackground = Color(0xFF3D1515);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  // ============================================================================
  // INFO - CYAN (Badge "Fuera de horario", estados informativos)
  // ============================================================================

  /// Cyan para badges informativos (usa secondary scale)
  static const Color info = secondary400; // #22D3EE
  static const Color infoLight = secondary300;
  static const Color infoDark = secondary500;

  // ============================================================================
  // SPECIAL STATES (Interacciones en tema oscuro)
  // ============================================================================

  /// Overlay para hover states
  static const Color hover = Color(0x1FFFFFFF); // 12% opacity white

  /// Overlay para pressed states
  static const Color pressed = Color(0x33FFFFFF); // 20% opacity white

  /// Overlay para focus states
  static const Color focus = Color(0x1F3B82F6); // 12% opacity primary

  /// Shadow color
  static const Color shadow = Color(0x33000000); // 20% opacity black

  // ============================================================================
  // GRADIENTS (Vibrantes para tema oscuro - Cyan → Purple)
  // ============================================================================

  /// Gradiente principal - Cyan a Purple (como en diseño original)
  /// Uso: Barra de progreso, headers especiales
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF06B6D4), // cyan-500
      Color(0xFFA855F7), // purple-500
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Gradiente de acento - Orange a Rosa
  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      Color(0xFFF97316), // orange-500
      Color(0xFFF472B6), // pink-400
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente sutil para fondos
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surfaceDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================================================
  // SIDEBAR COLORS (Navegación lateral)
  // ============================================================================

  /// Fondo del sidebar - Navy casi negro
  static const Color sidebarBackground = Color(
    0xFF000414,
  ); // ← Mismo color que background

  /// Item activo del sidebar (con borde verde)
  static const Color sidebarActiveItem = Color(
    0xFF0F172B,
  ); // ← Mismo color que surface

  /// Borde izquierdo del item activo
  static const Color sidebarBorder = primary500; // Verde

  // ============================================================================
  // AVATAR COLORS
  // ============================================================================

  /// Color de fondo del avatar
  static const Color avatarBackground = Color(0xFF1C4428);
  static const Color avatarGreen = primary500;

  // ============================================================================
  // CLOCKING STATUS COLORS (Estados específicos con fondo+texto+borde)
  // ============================================================================

  /// Estado COMPLETO - Verde teal
  /// Uso: Badge "Completo" en tabla de registros
  static const Color clockingCompleteBackground = Color(0xFF134E4A);
  static const Color clockingCompleteText = Color(0xFF5EEAD4);
  static const Color clockingCompleteBorder = Color(0xFF0F766E);

  /// Estado FUERA DE HORARIO - Amarillo/Amber
  /// Uso: Badge "Fuera de horario" en header
  static const Color clockingOutOfScheduleBackground = Color(0xFFEAB308);
  static const Color clockingOutOfScheduleText = Color(0xFF422006);

  /// Estado ACTIVO - Verde
  /// Uso: Badge "Activo" cuando está fichado
  static const Color clockingActiveBackground = Color(0xFF1A2E23);
  static const Color clockingActiveText = Color(0xFF22C55E);
  static const Color clockingActiveBorder = Color(0xFF22C55E);

  /// Estado INCOMPLETO - Warning
  static const Color clockingIncomplete = warning;

  /// Salida anticipada - Error rojo
  static const Color clockingEarlyExit = error;

  // ============================================================================
  // CALENDARIO - DÍAS ESPECIALES
  // ============================================================================

  /// Día seleccionado (Cyan)
  static const Color calendarSelected = Color(0xFF0891B2);
  static const Color calendarSelectedText = Color(0xFFFFFFFF);

  /// Día actual (Cyan claro con borde)
  static const Color calendarToday = Color(0xFF06B6D4);
  static const Color calendarTodayBorder = Color(0xFF22D3EE);

  /// Fin de semana (Amarillo)
  static const Color calendarWeekend = Color(0xFFCA8A04);
  static const Color calendarWeekendText = Color(0xFFFEF3C7);

  /// Día con registro (círculo cyan)
  static const Color calendarHasRecord = Color(0xFF155E75);

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Obtener color según estado de fichaje
  static Color getFichingStateColor(String state) {
    switch (state) {
      case 'completo':
        return success;
      case 'incompleto':
        return warningLight;
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

/// Extensión para facilitar uso de colores con opacidad en tema oscuro
extension AppColorsDarkExtension on Color {
  /// Retorna el color con la opacidad especificada
  Color withOpacityValue(double opacity) {
    final clampedOpacity = opacity.clamp(0.0, 1.0);
    return withValues(alpha: clampedOpacity);
  }
}
