import 'package:flutter/material.dart';

/// Gradientes profesionales para tema oscuro
/// 
/// Basado en la especificación de diseño del proyecto.
/// Incluye gradientes para botones, barras de progreso, cards y badges.
class AppGradients {
  // Prevenir instanciación
  AppGradients._();

  // ============================================================================
  // BOTÓN ENTRADA (Verde con glow)
  // ============================================================================
  
  /// Gradiente principal del botón "Entrada"
  /// Uso: ElevatedButton variant primary
  static const LinearGradient buttonPrimary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF34D399),  // Verde claro arriba
      Color(0xFF22C55E),  // Verde medio (primary500)
      Color(0xFF16A34A),  // Verde oscuro abajo
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Gradiente para hover del botón entrada
  static const LinearGradient buttonPrimaryHover = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4ADE80),  // Más claro
      Color(0xFF22C55E),
      Color(0xFF16A34A),
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Gradiente para pressed del botón entrada
  static const LinearGradient buttonPrimaryPressed = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF22C55E),
      Color(0xFF16A34A),
      Color(0xFF15803D),  // Más oscuro
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================================================
  // BOTÓN SALIDA (Rojo con glow) - Igual estilo que Entrada
  // ============================================================================
  
  /// Gradiente rojo para botón "Salida"
  static const LinearGradient buttonDanger = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF87171),  // Rojo claro arriba
      Color(0xFFEF4444),  // Rojo medio
      Color(0xFFDC2626),  // Rojo oscuro abajo
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================================================
  // BOTÓN PAUSA (Naranja/Amber con glow) - Igual estilo que Entrada
  // ============================================================================
  
  /// Gradiente naranja para botón "Pausa"
  static const LinearGradient buttonWarning = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFBBF24),  // Amber claro arriba
      Color(0xFFF59E0B),  // Amber medio
      Color(0xFFD97706),  // Amber oscuro abajo
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================================================
  // BOTÓN RETORNO (Azul/Cyan con glow) - Igual estilo que Entrada
  // ============================================================================
  
  /// Gradiente azul para botón "Retorno"
  static const LinearGradient buttonInfo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF38BDF8),  // Cyan claro arriba
      Color(0xFF0EA5E9),  // Cyan medio
      Color(0xFF0284C7),  // Cyan oscuro abajo
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================================================
  // BARRA DE PROGRESO (Cyan → Violeta → Magenta) ← CLAVE!
  // ============================================================================
  
  /// Gradiente para barra de progreso de horas trabajadas
  /// Uso: WorkHoursProgress widget
  /// Efecto visual: Cyan (inicio) → Violeta (medio) → Magenta (completo)
  static const LinearGradient progressBar = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF06B6D4),  // Cyan (secondary500)
      Color(0xFF8B5CF6),  // Violeta
      Color(0xFFD946EF),  // Magenta (accent500)
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Variante alternativa más clara
  static const LinearGradient progressBarAlt = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF22D3EE),  // Cyan claro (secondary400)
      Color(0xFFA855F7),  // Púrpura
      Color(0xFFE879F9),  // Magenta claro
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================================================
  // CARD HORA DE ENTRADA (Cyan/Teal) ← Para TimeInfoBadge
  // ============================================================================
  
  /// Gradiente para card "Hora de entrada"
  /// Uso: TimeInfoBadge cuando label = "Hora de entrada"
  static const LinearGradient cardCyan = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0E7490),  // Cyan oscuro (secondary700)
      Color(0xFF0891B2),  // Cyan medio (secondary600)
      Color(0xFF06B6D4),  // Cyan claro (secondary500)
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Gradiente sutil para fondo de card cyan
  static const LinearGradient cardCyanSubtle = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF155E75),  // secondary800
      Color(0xFF164E63),  // secondary900
    ],
  );

  // ============================================================================
  // CARD TIEMPO DE PAUSA / SALIDA ESTIMADA (Magenta/Purple)
  // ============================================================================
  
  /// Gradiente para card "Salida estimada" y "Tiempo de pausa"
  /// Uso: TimeInfoBadge cuando label contiene "Salida" o "pausa"
  static const LinearGradient cardMagenta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED),  // Violeta
      Color(0xFF9333EA),  // Púrpura (accent600)
      Color(0xFFA855F7),  // Púrpura claro
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Gradiente sutil para fondo de card magenta
  static const LinearGradient cardMagentaSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF581C87),  // Púrpura muy oscuro
      Color(0xFF6B21A8),  // Púrpura oscuro
    ],
  );

  // ============================================================================
  // BADGE "FUERA DE HORARIO" (Amarillo/Amber gradient)
  // ============================================================================
  
  /// Gradiente para badge de advertencia
  static const LinearGradient badgeWarning = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFD97706),  // Amber oscuro
      Color(0xFFEAB308),  // Amber medio (warning500)
      Color(0xFFFBBF24),  // Amber claro
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ============================================================================
  // BADGE "COMPLETO" (Verde/Teal gradient)
  // ============================================================================
  
  /// Gradiente para badge de éxito
  static const LinearGradient badgeSuccess = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF0D9488),  // Teal
      Color(0xFF14B8A6),  // Teal claro
    ],
  );

  // ============================================================================
  // FONDO PRINCIPAL (Sutil degradado de fondo)
  // ============================================================================
  
  /// Gradiente principal de fondo (opcional)
  static const LinearGradient backgroundMain = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D1117),  // backgroundSecondary
      Color(0xFF0B0E13),  // background
    ],
  );
  
  /// Glow radial verde sutil (decorativo)
  static const RadialGradient backgroundGlow = RadialGradient(
    center: Alignment.topRight,
    radius: 1.5,
    colors: [
      Color(0x1022C55E),  // Glow verde sutil (10% opacity)
      Color(0x00000000),  // Transparente
    ],
  );

  // ============================================================================
  // SIDEBAR ITEM ACTIVO (Gradiente sutil)
  // ============================================================================
  
  /// Gradiente para item activo del sidebar
  static const LinearGradient sidebarActive = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF1A2E23),  // Verde muy oscuro (cerca del borde)
      Color(0xFF151B23),  // Se funde con el fondo
    ],
  );

  // ============================================================================
  // RELOJ GRANDE (Gradiente sutil de texto)
  // ============================================================================
  
  /// Gradiente para texto del reloj (opcional, da efecto brillante)
  static const LinearGradient clockText = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),  // Blanco puro
      Color(0xFFE5E7EB),  // Gris muy claro
    ],
  );
}

