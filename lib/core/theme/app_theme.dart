import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_colors_dark.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

/// Tema principal de la aplicación Control Horario
/// 
/// Integra todos los elementos del sistema de diseño:
/// - Colores (AppColors)
/// - Tipografía (AppTextStyles) 
/// - Espaciados (AppSpacing)
/// 
/// Ejemplo de uso:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme, // Futuro
///   home: MyApp(),
/// )
/// ```
class AppTheme {
  // Prevenir instanciación
  AppTheme._();

  // ============================================================================
  // LIGHT THEME (Tema claro - Principal)
  // ============================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      // ========================================================================
      // GENERAL
      // ========================================================================
      useMaterial3: true,
      brightness: Brightness.light,
      
      // ========================================================================
      // COLOR SCHEME
      // ========================================================================
      colorScheme: const ColorScheme.light(
        // Colores principales
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        
        // Colores secundarios
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnDark,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        
        // Colores terciarios (accent)
        tertiary: AppColors.accent,
        onTertiary: AppColors.textOnDark,
        tertiaryContainer: AppColors.accentLight,
        onTertiaryContainer: AppColors.accentDark,
        
        // Superficies
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        
        // Background - deprecated, usando surface en su lugar
        // background: AppColors.background,  // DEPRECATED en Flutter 3.18+
        // onBackground: AppColors.textPrimary, // DEPRECATED en Flutter 3.18+
        
        // Error
        error: AppColors.error,
        onError: AppColors.textOnDark,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.errorDark,
        
        // Otros
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
        shadow: AppColors.shadow,
        scrim: Colors.black54,
      ),

      // ========================================================================
      // SCAFFOLD
      // ========================================================================
      scaffoldBackgroundColor: AppColors.background,
      
      // ========================================================================
      // APP BAR
      // ========================================================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: AppSpacing.xs / 4, // 1dp
        shadowColor: AppColors.shadow,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h4,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppSpacing.iconLg,
        ),
      ),

      // ========================================================================
      // CARD
      // ========================================================================
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shadowColor: AppColors.shadow,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        margin: EdgeInsets.zero,
      ),

      // ========================================================================
      // ELEVATED BUTTON
      // ========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.shadow,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(80, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ========================================================================
      // TEXT BUTTON
      // ========================================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ========================================================================
      // OUTLINED BUTTON
      // ========================================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(80, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ========================================================================
      // ICON BUTTON
      // ========================================================================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          iconSize: AppSpacing.iconLg,
          padding: AppSpacing.allSm,
          minimumSize: const Size(40, 40),
        ),
      ),

      // ========================================================================
      // FLOATING ACTION BUTTON
      // ========================================================================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 6,
        shape: CircleBorder(),
      ),

      // ========================================================================
      // INPUT DECORATION (TextField)
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        
        // Border normal
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        
        // Border habilitado
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        
        // Border enfocado
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        
        // Border error
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        
        // Border error enfocado
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        
        // Border deshabilitado
        disabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        
        // Estilos de texto
        labelStyle: AppTextStyles.labelLarge.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
        helperStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        
        // Íconos
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ========================================================================
      // CHECKBOX
      // ========================================================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ========================================================================
      // RADIO
      // ========================================================================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
      ),

      // ========================================================================
      // SWITCH
      // ========================================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.borderLight;
        }),
      ),

      // ========================================================================
      // DIVIDER
      // ========================================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ========================================================================
      // DIALOG
      // ========================================================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        titleTextStyle: AppTextStyles.h3,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // ========================================================================
      // SNACKBAR
      // ========================================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textOnDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        elevation: 6,
      ),

      // ========================================================================
      // BOTTOM SHEET
      // ========================================================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLg),
            topRight: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),

      // ========================================================================
      // CHIP
      // ========================================================================
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.labelSmall,
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSm,
        ),
      ),

      // ========================================================================
      // TOOLTIP
      // ========================================================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textOnDark,
        ),
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      // ========================================================================
      // PROGRESS INDICATOR
      // ========================================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.borderLight,
        circularTrackColor: AppColors.borderLight,
      ),

      // ========================================================================
      // TEXT THEME
      // ========================================================================
      textTheme: TextTheme(
        // Display
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        
        // Headline
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        
        // Title
        titleLarge: AppTextStyles.h4,
        titleMedium: AppTextStyles.h5,
        titleSmall: AppTextStyles.h6,
        
        // Body
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        
        // Label
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // ========================================================================
      // ICON THEME
      // ========================================================================
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppSpacing.iconLg,
      ),

      // ========================================================================
      // PRIMARY ICON THEME
      // ========================================================================
      primaryIconTheme: const IconThemeData(
        color: AppColors.primary,
        size: AppSpacing.iconLg,
      ),
    );
  }

  // ============================================================================
  // DARK THEME (Tema oscuro)
  // ============================================================================

  static ThemeData get darkTheme {
    return ThemeData(
      // ========================================================================
      // GENERAL
      // ========================================================================
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // ========================================================================
      // COLOR SCHEME
      // ========================================================================
      colorScheme: ColorScheme.dark(
        // Colores principales - Verde (botones entrada)
        primary: AppColorsDark.primary500, // Verde #22C55E
        onPrimary: Colors.black87, // Texto oscuro sobre verde
        primaryContainer: AppColorsDark.primary600,
        onPrimaryContainer: Colors.white,
        
        // Colores secundarios - Cyan (badges info)
        secondary: AppColorsDark.secondary500, // Cyan #06B6D4
        onSecondary: Colors.white,
        secondaryContainer: AppColorsDark.secondary600,
        onSecondaryContainer: Colors.white,
        
        // Colores terciarios - Magenta (salida estimada)
        tertiary: AppColorsDark.accent500, // Magenta #D946EF
        onTertiary: Colors.white,
        tertiaryContainer: AppColorsDark.accent600,
        onTertiaryContainer: Colors.white,
        
        // Superficies
        surface: AppColorsDark.surface,
        onSurface: Colors.white, // ← FORZAR BLANCO PURO
        surfaceContainerHighest: AppColorsDark.surfaceVariant,
        
        // Error
        error: AppColorsDark.error,
        onError: AppColorsDark.textOnDark,
        errorContainer: AppColorsDark.errorLight,
        onErrorContainer: AppColorsDark.errorDark,
        
        // Otros
        outline: AppColorsDark.border,
        outlineVariant: AppColorsDark.borderLight,
        shadow: AppColorsDark.shadow,
        scrim: Colors.black87,
      ),

      // ========================================================================
      // SCAFFOLD
      // ========================================================================
      scaffoldBackgroundColor: AppColorsDark.background,
      
      // ========================================================================
      // APP BAR
      // ========================================================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsDark.surface,
        foregroundColor: AppColorsDark.textPrimary,
        elevation: AppSpacing.xs / 4, // 1dp
        shadowColor: AppColorsDark.shadow,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h4.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(
          color: AppColorsDark.textPrimary,
          size: AppSpacing.iconLg,
        ),
      ),

      // ========================================================================
      // CARD
      // ========================================================================
      cardTheme: CardThemeData(
        color: AppColorsDark.surface,
        shadowColor: AppColorsDark.shadow,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        margin: EdgeInsets.zero,
      ),

      // ========================================================================
      // ELEVATED BUTTON (Verde lima vibrante - EXACTO IMAGEN)
      // ========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.primary500, // Verde principal #22C55E
          foregroundColor: Color(0xFF0F172A), // Texto oscuro sobre verde brillante
          elevation: 2,
          shadowColor: AppColorsDark.shadow,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(80, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ========================================================================
      // TEXT BUTTON
      // ========================================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsDark.primary,
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ========================================================================
      // OUTLINED BUTTON
      // ========================================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsDark.primary,
          side: const BorderSide(
            color: AppColorsDark.primary,
            width: 2,
          ),
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          minimumSize: const Size(80, 48),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ========================================================================
      // ICON BUTTON
      // ========================================================================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColorsDark.textPrimary,
          iconSize: AppSpacing.iconLg,
          padding: AppSpacing.allSm,
          minimumSize: const Size(40, 40),
        ),
      ),

      // ========================================================================
      // FLOATING ACTION BUTTON (Verde lima - EXACTO IMAGEN)
      // ========================================================================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColorsDark.primary500, // Verde #22C55E
        foregroundColor: Color(0xFF0F172A), // Texto oscuro sobre verde brillante
        elevation: 6,
        shape: CircleBorder(),
      ),

      // ========================================================================
      // INPUT DECORATION (TextField)
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.surfaceVariant,
        contentPadding: AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        
        // Border normal
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColorsDark.border,
            width: 1,
          ),
        ),
        
        // Border habilitado
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColorsDark.border,
            width: 1,
          ),
        ),
        
        // Border enfocado
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColorsDark.primary,
            width: 2,
          ),
        ),
        
        // Border error
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColorsDark.error,
            width: 1,
          ),
        ),
        
        // Border error enfocado
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColorsDark.error,
            width: 2,
          ),
        ),
        
        // Border deshabilitado
        disabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(
            color: AppColorsDark.borderLight,
            width: 1,
          ),
        ),
        
        // Estilos de texto
        labelStyle: AppTextStyles.labelLarge.copyWith(
          color: AppColorsDark.textSecondary,
        ),
        floatingLabelStyle: AppTextStyles.labelLarge.copyWith(
          color: AppColorsDark.primary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColorsDark.textTertiary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColorsDark.error,
        ),
        helperStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColorsDark.textSecondary,
        ),
        
        // Íconos
        prefixIconColor: AppColorsDark.textSecondary,
        suffixIconColor: AppColorsDark.textSecondary,
      ),

      // ========================================================================
      // CHECKBOX
      // ========================================================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.primary;
          }
          return AppColorsDark.border;
        }),
        checkColor: WidgetStateProperty.all(AppColorsDark.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ========================================================================
      // RADIO
      // ========================================================================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.primary;
          }
          return AppColorsDark.border;
        }),
      ),

      // ========================================================================
      // SWITCH (Cyan brillante cuando activo)
      // ========================================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.info; // cyan-400 #22D3EE
          }
          return AppColorsDark.border;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsDark.primaryLight;
          }
          return AppColorsDark.borderLight;
        }),
      ),

      // ========================================================================
      // DIVIDER
      // ========================================================================
      dividerTheme: const DividerThemeData(
        color: AppColorsDark.divider,
        thickness: 1,
        space: 1,
      ),

      // ========================================================================
      // DIALOG
      // ========================================================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColorsDark.surface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        titleTextStyle: AppTextStyles.h3.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColorsDark.textPrimary,
        ),
      ),

      // ========================================================================
      // SNACKBAR
      // ========================================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsDark.surfaceVariant,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        elevation: 6,
      ),

      // ========================================================================
      // BOTTOM SHEET
      // ========================================================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColorsDark.surface,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLg),
            topRight: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),

      // ========================================================================
      // CHIP
      // ========================================================================
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsDark.surfaceVariant,
        selectedColor: AppColorsDark.primary,
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSm,
        ),
      ),

      // ========================================================================
      // TOOLTIP
      // ========================================================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColorsDark.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusSm,
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),

      // ========================================================================
      // PROGRESS INDICATOR (Verde lima)
      // ========================================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColorsDark.primary500, // Verde #22C55E
        linearTrackColor: AppColorsDark.borderLight,
        circularTrackColor: AppColorsDark.borderLight,
      ),

      // ========================================================================
      // TEXT THEME
      // ========================================================================
      textTheme: TextTheme(
        // Display
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        
        // Headline
        headlineLarge: AppTextStyles.h1.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        headlineMedium: AppTextStyles.h2.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        headlineSmall: AppTextStyles.h3.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        
        // Title
        titleLarge: AppTextStyles.h4.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        titleMedium: AppTextStyles.h5.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        titleSmall: AppTextStyles.h6.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        
        // Body
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColorsDark.textSecondary,
        ),
        
        // Label
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: AppColorsDark.textPrimary,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColorsDark.textSecondary,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColorsDark.textSecondary,
        ),
      ),

      // ========================================================================
      // ICON THEME
      // ========================================================================
      iconTheme: const IconThemeData(
        color: AppColorsDark.textPrimary,
        size: AppSpacing.iconLg,
      ),

      // ========================================================================
      // PRIMARY ICON THEME
      // ========================================================================
      primaryIconTheme: const IconThemeData(
        color: AppColorsDark.primary,
        size: AppSpacing.iconLg,
      ),
    );
  }
}

