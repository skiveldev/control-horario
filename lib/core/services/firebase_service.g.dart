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
String _$scheduleServiceHash() => r'1c8b2ed82808cd2ac5107a439a9a97381dfcb8d8';

/// Provider para el servicio de gestión de plantillas de horario
///
/// Proporciona acceso a operaciones CRUD de plantillas en Firestore.
/// Usado por ScheduleManagementProvider para lógica de negocio.
///
/// Copied from [scheduleService].
@ProviderFor(scheduleService)
final scheduleServiceProvider = AutoDisposeProvider<ScheduleService>.internal(
  scheduleService,
  name: r'scheduleServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScheduleServiceRef = AutoDisposeProviderRef<ScheduleService>;
String _$calendarServiceHash() => r'd52d042ed3e99b9e4ce10a851a8fa68fac0c55f8';

/// Provider para el servicio de gestión de calendarios laborales
///
/// Proporciona acceso a operaciones CRUD de calendarios en Firestore.
/// Usado por CalendarManagementProvider para lógica de negocio.
///
/// Copied from [calendarService].
@ProviderFor(calendarService)
final calendarServiceProvider = AutoDisposeProvider<CalendarService>.internal(
  calendarService,
  name: r'calendarServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CalendarServiceRef = AutoDisposeProviderRef<CalendarService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
