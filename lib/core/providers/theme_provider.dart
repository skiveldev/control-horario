import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// Provider para gestionar el tema de la aplicación (claro/oscuro)
/// 
/// Funcionalidades:
/// - Toggle entre tema claro y oscuro
/// - Persistencia de preferencia con SharedPreferences
/// - Carga automática del tema guardado al iniciar
/// 
/// Uso:
/// ```dart
/// // Obtener el modo actual
/// final themeMode = ref.watch(themeNotifierProvider);
/// 
/// // Verificar si está en oscuro
/// final isDark = ref.watch(themeNotifierProvider.select((mode) => mode == ThemeMode.dark));
/// 
/// // Cambiar tema
/// ref.read(themeNotifierProvider.notifier).toggleTheme();
/// ```
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeModeKey = 'isDarkMode';
  
  @override
  ThemeMode build() {
    // Cargar tema guardado de forma asíncrona
    _loadThemePreference();
    
    // Retornar tema claro por defecto mientras carga
    return ThemeMode.light;
  }

  /// Carga la preferencia de tema desde SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeModeKey) ?? false;
      
      // Actualizar estado solo si es diferente
      final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
      if (state != newMode) {
        state = newMode;
      }
    } catch (e) {
      debugPrint('Error al cargar preferencia de tema: $e');
    }
  }

  /// Alterna entre tema claro y oscuro
  Future<void> toggleTheme() async {
    try {
      // Determinar nuevo modo
      final newMode = state == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
      
      // Actualizar estado inmediatamente
      state = newMode;
      
      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeModeKey, newMode == ThemeMode.dark);
    } catch (e) {
      debugPrint('Error al cambiar tema: $e');
      
      // Revertir estado en caso de error
      state = state == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
    }
  }

  /// Establece un tema específico
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      // Actualizar estado
      state = mode;
      
      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeModeKey, mode == ThemeMode.dark);
    } catch (e) {
      debugPrint('Error al establecer tema: $e');
    }
  }
  
  /// Verifica si el tema actual es oscuro
  bool get isDark => state == ThemeMode.dark;
  
  /// Verifica si el tema actual es claro
  bool get isLight => state == ThemeMode.light;
}


