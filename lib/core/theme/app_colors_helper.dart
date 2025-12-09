import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_colors_dark.dart';

/// Helper para obtener colores según el tema actual (claro/oscuro)
/// 
/// En lugar de usar AppColors directamente, usar AppColorsHelper.of(context)
/// para que los colores se adapten automáticamente al tema activo.
/// 
/// Ejemplo:
/// ```dart
/// // ❌ MAL - No se adapta al tema
/// Container(color: AppColors.background)
/// 
/// // ✅ BIEN - Se adapta automáticamente
/// Container(color: AppColorsHelper.of(context).background)
/// ```
class AppColorsHelper {
  final BuildContext context;
  
  const AppColorsHelper._(this.context);
  
  /// Obtener helper de colores según el tema actual
  static AppColorsHelper of(BuildContext context) {
    return AppColorsHelper._(context);
  }
  
  /// Verifica si el tema actual es oscuro
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  
  // ============================================================================
  // BACKGROUNDS Y SURFACES
  // ============================================================================
  
  Color get background => isDark ? AppColorsDark.background : AppColors.background;
  Color get surface => isDark ? AppColorsDark.surface : AppColors.surface;
  Color get surfaceVariant => isDark ? AppColorsDark.surfaceVariant : AppColors.surfaceVariant;
  Color get surfaceDark => isDark ? AppColorsDark.surfaceDark : AppColors.surfaceDark;
  
  // ============================================================================
  // TEXT COLORS
  // ============================================================================
  
  Color get textPrimary => isDark ? AppColorsDark.textPrimary : AppColors.textPrimary;
  Color get textSecondary => isDark ? AppColorsDark.textSecondary : AppColors.textSecondary;
  Color get textTertiary => isDark ? AppColorsDark.textTertiary : AppColors.textTertiary;
  Color get textOnDark => isDark ? AppColorsDark.textOnDark : AppColors.textOnDark;
  Color get textOnPrimary => isDark ? AppColorsDark.textOnPrimary : AppColors.textOnPrimary;
  
  // ============================================================================
  // BORDERS
  // ============================================================================
  
  Color get border => isDark ? AppColorsDark.border : AppColors.border;
  Color get borderLight => isDark ? AppColorsDark.borderLight : AppColors.borderLight;
  Color get borderDark => isDark ? AppColorsDark.borderDark : AppColors.borderDark;
  Color get divider => isDark ? AppColorsDark.divider : AppColors.divider;
  Color get shadow => isDark ? AppColorsDark.shadow : AppColors.shadow;
  
  // ============================================================================
  // PRIMARY - VERDE (Escala completa)
  // ============================================================================
  
  Color get primary50 => isDark ? AppColorsDark.primary50 : AppColorsDark.primary50;
  Color get primary100 => isDark ? AppColorsDark.primary100 : AppColorsDark.primary100;
  Color get primary200 => isDark ? AppColorsDark.primary200 : AppColorsDark.primary200;
  Color get primary300 => isDark ? AppColorsDark.primary300 : AppColorsDark.primary300;
  Color get primary400 => isDark ? AppColorsDark.primary400 : AppColorsDark.primary400;
  Color get primary500 => isDark ? AppColorsDark.primary500 : AppColors.primary;
  Color get primary600 => isDark ? AppColorsDark.primary600 : AppColorsDark.primary600;
  Color get primary700 => isDark ? AppColorsDark.primary700 : AppColorsDark.primary700;
  Color get primary800 => isDark ? AppColorsDark.primary800 : AppColorsDark.primary800;
  Color get primary900 => isDark ? AppColorsDark.primary900 : AppColorsDark.primary900;
  
  Color get primary => primary500; // Alias
  Color get primaryLight => primary400;
  Color get primaryDark => primary600;
  Color get primaryGlow => AppColorsDark.primaryGlow;
  
  // ============================================================================
  // SECONDARY - CYAN/TEAL (Escala completa)
  // ============================================================================
  
  Color get secondary50 => AppColorsDark.secondary50;
  Color get secondary100 => AppColorsDark.secondary100;
  Color get secondary200 => AppColorsDark.secondary200;
  Color get secondary300 => AppColorsDark.secondary300;
  Color get secondary400 => AppColorsDark.secondary400;
  Color get secondary500 => isDark ? AppColorsDark.secondary500 : AppColors.secondary;
  Color get secondary600 => AppColorsDark.secondary600;
  Color get secondary700 => AppColorsDark.secondary700;
  Color get secondary800 => AppColorsDark.secondary800;
  Color get secondary900 => AppColorsDark.secondary900;
  
  Color get secondary => secondary500; // Alias
  Color get secondaryLight => secondary400;
  Color get secondaryDark => secondary600;
  
  // ============================================================================
  // ACCENT - MAGENTA/FUCHSIA (Escala completa)
  // ============================================================================
  
  Color get accent50 => AppColorsDark.accent50;
  Color get accent100 => AppColorsDark.accent100;
  Color get accent200 => AppColorsDark.accent200;
  Color get accent300 => AppColorsDark.accent300;
  Color get accent400 => AppColorsDark.accent400;
  Color get accent500 => isDark ? AppColorsDark.accent500 : AppColors.accent;
  Color get accent600 => AppColorsDark.accent600;
  Color get accent700 => AppColorsDark.accent700;
  Color get accent800 => AppColorsDark.accent800;
  Color get accent900 => AppColorsDark.accent900;
  
  Color get accent => accent500; // Alias
  Color get accentLight => accent400;
  Color get accentDark => accent600;
  
  // Purple (para "Salida estimada")
  Color get purple => AppColorsDark.purple;
  Color get purpleLight => AppColorsDark.purpleLight;
  Color get purpleDark => AppColorsDark.purpleDark;
  
  // ============================================================================
  // WARNING - AMARILLO/AMBER (Escala completa)
  // ============================================================================
  
  Color get warning50 => AppColorsDark.warning50;
  Color get warning100 => AppColorsDark.warning100;
  Color get warning200 => AppColorsDark.warning200;
  Color get warning300 => AppColorsDark.warning300;
  Color get warning400 => AppColorsDark.warning400;
  Color get warning500 => isDark ? AppColorsDark.warning500 : AppColors.warning;
  Color get warning600 => AppColorsDark.warning600;
  Color get warning700 => AppColorsDark.warning700;
  Color get warning800 => AppColorsDark.warning800;
  Color get warning900 => AppColorsDark.warning900;
  
  Color get warning => warning500; // Alias
  Color get warningLight => warning400;
  Color get warningDark => warning600;
  
  // ============================================================================
  // SUCCESS - ESMERALDA
  // ============================================================================
  
  Color get success => isDark ? AppColorsDark.success : AppColors.success;
  Color get successBackground => AppColorsDark.successBackground;
  Color get successBorder => AppColorsDark.successBorder;
  Color get successLight => isDark ? AppColors.successLight : AppColors.successLight;
  Color get successDark => isDark ? AppColors.successDark : AppColors.successDark;
  
  // ============================================================================
  // ERROR - ROJO
  // ============================================================================
  
  Color get error => isDark ? AppColorsDark.error : AppColors.error;
  Color get errorBackground => AppColorsDark.errorBackground;
  Color get errorLight => isDark ? AppColorsDark.errorLight : AppColors.errorLight;
  Color get errorDark => isDark ? AppColorsDark.errorDark : AppColors.errorDark;
  
  // ============================================================================
  // INFO - CYAN
  // ============================================================================
  
  Color get info => isDark ? AppColorsDark.info : AppColors.info;
  Color get infoLight => isDark ? AppColorsDark.infoLight : AppColors.infoLight;
  Color get infoDark => isDark ? AppColorsDark.infoDark : AppColors.infoDark;
  
  // ============================================================================
  // SIDEBAR COLORS
  // ============================================================================
  
  Color get sidebarBackground => AppColorsDark.sidebarBackground;
  Color get sidebarActiveItem => AppColorsDark.sidebarActiveItem;
  Color get sidebarBorder => AppColorsDark.sidebarBorder;
  
  // ============================================================================
  // AVATAR COLORS
  // ============================================================================
  
  Color get avatarBackground => AppColorsDark.avatarBackground;
  Color get avatarGreen => AppColorsDark.avatarGreen;
  
  // ============================================================================
  // CLOCKING STATUS COLORS (Con fondo+texto+borde específicos)
  // ============================================================================
  
  // Estado COMPLETO
  Color get clockingCompleteBackground => AppColorsDark.clockingCompleteBackground;
  Color get clockingCompleteText => AppColorsDark.clockingCompleteText;
  Color get clockingCompleteBorder => AppColorsDark.clockingCompleteBorder;
  
  // Estado FUERA DE HORARIO
  Color get clockingOutOfScheduleBackground => AppColorsDark.clockingOutOfScheduleBackground;
  Color get clockingOutOfScheduleText => AppColorsDark.clockingOutOfScheduleText;
  
  // Estado ACTIVO
  Color get clockingActiveBackground => AppColorsDark.clockingActiveBackground;
  Color get clockingActiveText => AppColorsDark.clockingActiveText;
  Color get clockingActiveBorder => AppColorsDark.clockingActiveBorder;
  
  // Otros estados
  Color get clockingIncomplete => AppColorsDark.clockingIncomplete;
  Color get clockingEarlyExit => AppColorsDark.clockingEarlyExit;
  
  // ============================================================================
  // CALENDARIO - DÍAS ESPECIALES
  // ============================================================================
  
  Color get calendarSelected => AppColorsDark.calendarSelected;
  Color get calendarSelectedText => AppColorsDark.calendarSelectedText;
  Color get calendarToday => AppColorsDark.calendarToday;
  Color get calendarTodayBorder => AppColorsDark.calendarTodayBorder;
  Color get calendarWeekend => AppColorsDark.calendarWeekend;
  Color get calendarWeekendText => AppColorsDark.calendarWeekendText;
  Color get calendarHasRecord => AppColorsDark.calendarHasRecord;
}

/// Extension para acceso rápido a los colores del tema actual
extension BuildContextColorsExtension on BuildContext {
  /// Acceso rápido a los colores del tema actual
  /// 
  /// Uso: `context.colors.primary` en lugar de `AppColors.primary`
  AppColorsHelper get colors => AppColorsHelper.of(this);
}

