import 'package:flutter/material.dart';

/// Sombras y efectos glow para tema oscuro
/// 
/// Proporciona profundidad visual y jerarquía mediante sombras profesionales.
class AppShadows {
  // Prevenir instanciación
  AppShadows._();

  // ============================================================================
  // SOMBRAS DE CARDS
  // ============================================================================
  
  /// Sombra principal para cards
  /// Uso: CustomCard, contenedores principales
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Sombra sutil para elementos levemente elevados
  /// Uso: Botones secundarios, badges
  static final List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ============================================================================
  // GLOW VERDE - BOTÓN ENTRADA
  // ============================================================================
  
  /// Glow verde para botón "Entrada"
  /// Crea efecto de brillo verde alrededor del botón
  /// Uso: CustomButton variant primary (botón "→ Entrada")
  static final List<BoxShadow> buttonPrimaryGlow = [
    // Glow cercano (más intenso)
    BoxShadow(
      color: const Color(0xFF22C55E).withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    // Glow lejano (más difuso)
    BoxShadow(
      color: const Color(0xFF22C55E).withOpacity(0.2),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  // ============================================================================
  // GLOW ROJO - BOTÓN SALIDA (mismo estilo que Entrada)
  // ============================================================================
  
  /// Glow rojo para botón "Salida"
  static final List<BoxShadow> buttonDangerGlow = [
    BoxShadow(
      color: const Color(0xFFEF4444).withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFFEF4444).withOpacity(0.2),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  // ============================================================================
  // GLOW NARANJA - BOTÓN PAUSA (mismo estilo que Entrada)
  // ============================================================================
  
  /// Glow naranja para botón "Pausa"
  static final List<BoxShadow> buttonWarningGlow = [
    BoxShadow(
      color: const Color(0xFFF59E0B).withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFFF59E0B).withOpacity(0.2),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  // ============================================================================
  // GLOW AZUL - BOTÓN RETORNO (mismo estilo que Entrada)
  // ============================================================================
  
  /// Glow azul para botón "Retorno"
  static final List<BoxShadow> buttonInfoGlow = [
    BoxShadow(
      color: const Color(0xFF0EA5E9).withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF0EA5E9).withOpacity(0.2),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  // ============================================================================
  // GLOW CYAN - CARDS DE TIEMPO
  // ============================================================================
  
  /// Glow cyan para card "Hora de entrada"
  /// Uso: TimeInfoBadge cuando usa gradiente cyan
  static final List<BoxShadow> cardCyanGlow = [
    BoxShadow(
      color: const Color(0xFF06B6D4).withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ============================================================================
  // GLOW MAGENTA - CARD PAUSA/SALIDA
  // ============================================================================
  
  /// Glow magenta para card "Salida estimada" y "Tiempo de pausa"
  /// Uso: TimeInfoBadge cuando usa gradiente magenta
  static final List<BoxShadow> cardMagentaGlow = [
    BoxShadow(
      color: const Color(0xFFD946EF).withOpacity(0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ============================================================================
  // GLOW DEL RELOJ DIGITAL
  // ============================================================================
  
  /// Glow sutil para el ícono del reloj
  /// Uso: ClockDisplay widget
  static final List<BoxShadow> clockGlow = [
    BoxShadow(
      color: const Color(0xFF06B6D4).withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}

