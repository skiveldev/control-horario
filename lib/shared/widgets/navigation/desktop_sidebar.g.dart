// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desktop_sidebar.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sidebarNotifierHash() => r'c039ac56d0770ed8b3f5ad72f50c9a3c03bbd2c8';

/// Provider para gestionar el estado del sidebar (expandido/colapsado)
///
/// Funcionalidades:
/// - Toggle entre expandido (240px) y colapsado (64px)
/// - Persistencia de estado con SharedPreferences
/// - Carga automática del estado guardado
///
/// Copied from [SidebarNotifier].
@ProviderFor(SidebarNotifier)
final sidebarNotifierProvider =
    AutoDisposeNotifierProvider<SidebarNotifier, bool>.internal(
  SidebarNotifier.new,
  name: r'sidebarNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sidebarNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SidebarNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
