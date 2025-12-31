// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userManagementHash() => r'dc97f8557c7c7788984109581cd0e53a9a1687ba';

/// Provider para gestión de usuarios (creación, edición, eliminación)
///
/// Gestiona todas las operaciones CRUD de usuarios desde el panel admin.
/// Usa EmployeeCreationService para interactuar con Firebase.
///
/// Copied from [UserManagement].
@ProviderFor(UserManagement)
final userManagementProvider =
    AutoDisposeNotifierProvider<UserManagement, UserCreationState>.internal(
  UserManagement.new,
  name: r'userManagementProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userManagementHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserManagement = AutoDisposeNotifier<UserCreationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
