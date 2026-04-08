// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'a3c9e1b2f4d5e6a7b8c9d0e1f2a3b4c5d6e7f8a9';

/// Provider para la instancia de SharedPreferences
///
/// Debe ser sobreescrito (overrideWithValue) en el ProviderScope de main.dart
/// con la instancia pre-inicializada, para que ThemeNotifier.build() pueda
/// leer el tema guardado de forma síncrona y evitar el flash de tema incorrecto.
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;

String _$themeNotifierHash() => r'6751f6bd6c89d01c0525dfeaabf2c2bca657d3c2';

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
///
/// Copied from [ThemeNotifier].
@ProviderFor(ThemeNotifier)
final themeNotifierProvider =
    AutoDisposeNotifierProvider<ThemeNotifier, ThemeMode>.internal(
  ThemeNotifier.new,
  name: r'themeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeNotifier = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
