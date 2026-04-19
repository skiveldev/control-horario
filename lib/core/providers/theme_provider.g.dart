// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'b5050ac0c185d8b7551a841d3d0640c64f7c799b';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$themeNotifierHash() => r'480e39adc591df3d4d7b48fb30367f786f23d417';

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
