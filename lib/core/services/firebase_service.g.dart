// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firestoreHash() => r'ef4a6b0737caace50a6d79dd3e4e2aa1bc3031d5';

/// Provider para la instancia de Firestore
///
/// Proporciona acceso a la base de datos Firestore.
/// Se puede configurar para usar emulator en desarrollo.
///
/// Copied from [firestore].
@ProviderFor(firestore)
final firestoreProvider = AutoDisposeProvider<FirebaseFirestore>.internal(
  firestore,
  name: r'firestoreProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreRef = AutoDisposeProviderRef<FirebaseFirestore>;
String _$firebaseAuthHash() => r'7791bf70ce0f01bf991a53a76abc915478673c0b';

/// Provider para la instancia de Firebase Auth
///
/// Proporciona acceso al sistema de autenticación.
/// Se puede configurar para usar emulator en desarrollo.
///
/// Copied from [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = AutoDisposeProvider<FirebaseAuth>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthRef = AutoDisposeProviderRef<FirebaseAuth>;
String _$employeeCreationServiceHash() =>
    r'ad681cd637964a38dd8affdbbe8083f86c6df40d';

/// Provider para el servicio de creación de empleados
///
/// Copied from [employeeCreationService].
@ProviderFor(employeeCreationService)
final employeeCreationServiceProvider =
    AutoDisposeProvider<EmployeeCreationService>.internal(
  employeeCreationService,
  name: r'employeeCreationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$employeeCreationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EmployeeCreationServiceRef
    = AutoDisposeProviderRef<EmployeeCreationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
