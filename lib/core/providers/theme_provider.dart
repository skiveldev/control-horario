import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

/// Provider para la instancia de SharedPreferences
///
/// Debe ser sobreescrito (overrideWithValue) en el ProviderScope de main.dart
/// con la instancia pre-inicializada, para que ThemeNotifier.build() pueda
/// leer el tema guardado de forma síncrona y evitar el flash de tema incorrecto.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider debe ser overrideado en ProviderScope. '
    'Ver main.dart: ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)])',
  );
}

/// Provider para gestionar el tema de la aplicación (claro/oscuro)
///
/// Funcionalidades:
/// - Toggle entre tema claro y oscuro
/// - Persistencia de preferencia con SharedPreferences
/// - Carga síncrona del tema guardado al iniciar (sin flash)
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
    // Leer el tema guardado de forma síncrona usando la instancia pre-cargada.
    // SharedPreferences.getBool() es síncrono una vez que la instancia está lista.
    final prefs = ref.watch(sharedPreferencesProvider);
    final isDark = prefs.getBool(_themeModeKey) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Alterna entre tema claro y oscuro
  Future<void> toggleTheme() async {
    try {
      final newMode =
          state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

      state = newMode;

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_themeModeKey, newMode == ThemeMode.dark);
    } catch (e) {
      debugPrint('Error al cambiar tema: $e');

      // Revertir estado en caso de error
      state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }
  }

  /// Establece un tema específico
  Future<void> setThemeMode(ThemeMode mode) async {
    final previousState = state;
    try {
      state = mode;

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(_themeModeKey, mode == ThemeMode.dark);
    } catch (e) {
      debugPrint('Error al establecer tema: $e');
      state = previousState;
    }
  }

  /// Verifica si el tema actual es oscuro
  bool get isDark => state == ThemeMode.dark;

  /// Verifica si el tema actual es claro
  bool get isLight => state == ThemeMode.light;
}
