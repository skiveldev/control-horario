// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeNotifierHash() => r'6751f6bd6c89d01c0525dfeaabf2c2bca657d3c2';

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
