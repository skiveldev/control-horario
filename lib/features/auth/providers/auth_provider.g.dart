// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'8d66f1b36c36fb23821c0fc880f8ccb5ae688e88';

/// Provider del estado de autenticación de Firebase
///
/// Emite User? de Firebase Auth cuando hay cambios en la autenticación.
/// - null si no hay usuario autenticado
/// - User si hay sesión activa
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$currentUserHash() => r'7d5ec57943b1da2930f438e108214a56a3026289';

/// Provider del usuario actual con datos completos
///
/// Combina Firebase Auth con Firestore para obtener UserModel completo.
/// Emite:
/// - null si no hay usuario autenticado
/// - UserModel con datos del empleado si hay sesión activa
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeStreamProvider<UserModel?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeStreamProviderRef<UserModel?>;
String _$userByIdHash() => r'd69a0360859b9ad604eea0971d39d0abdb39d799';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider para obtener usuario específico por ID
///
/// Stream de datos de cualquier usuario desde Firestore.
/// Usado para ver horarios, perfiles, etc. de otros empleados (admin/RRHH).
///
/// [userId]: ID del usuario a observar
///
/// Copied from [userById].
@ProviderFor(userById)
const userByIdProvider = UserByIdFamily();

/// Provider para obtener usuario específico por ID
///
/// Stream de datos de cualquier usuario desde Firestore.
/// Usado para ver horarios, perfiles, etc. de otros empleados (admin/RRHH).
///
/// [userId]: ID del usuario a observar
///
/// Copied from [userById].
class UserByIdFamily extends Family<AsyncValue<UserModel?>> {
  /// Provider para obtener usuario específico por ID
  ///
  /// Stream de datos de cualquier usuario desde Firestore.
  /// Usado para ver horarios, perfiles, etc. de otros empleados (admin/RRHH).
  ///
  /// [userId]: ID del usuario a observar
  ///
  /// Copied from [userById].
  const UserByIdFamily();

  /// Provider para obtener usuario específico por ID
  ///
  /// Stream de datos de cualquier usuario desde Firestore.
  /// Usado para ver horarios, perfiles, etc. de otros empleados (admin/RRHH).
  ///
  /// [userId]: ID del usuario a observar
  ///
  /// Copied from [userById].
  UserByIdProvider call(
    String userId,
  ) {
    return UserByIdProvider(
      userId,
    );
  }

  @override
  UserByIdProvider getProviderOverride(
    covariant UserByIdProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userByIdProvider';
}

/// Provider para obtener usuario específico por ID
///
/// Stream de datos de cualquier usuario desde Firestore.
/// Usado para ver horarios, perfiles, etc. de otros empleados (admin/RRHH).
///
/// [userId]: ID del usuario a observar
///
/// Copied from [userById].
class UserByIdProvider extends AutoDisposeStreamProvider<UserModel?> {
  /// Provider para obtener usuario específico por ID
  ///
  /// Stream de datos de cualquier usuario desde Firestore.
  /// Usado para ver horarios, perfiles, etc. de otros empleados (admin/RRHH).
  ///
  /// [userId]: ID del usuario a observar
  ///
  /// Copied from [userById].
  UserByIdProvider(
    String userId,
  ) : this._internal(
          (ref) => userById(
            ref as UserByIdRef,
            userId,
          ),
          from: userByIdProvider,
          name: r'userByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userByIdHash,
          dependencies: UserByIdFamily._dependencies,
          allTransitiveDependencies: UserByIdFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<UserModel?> Function(UserByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserByIdProvider._internal(
        (ref) => create(ref as UserByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<UserModel?> createElement() {
    return _UserByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserByIdProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserByIdRef on AutoDisposeStreamProviderRef<UserModel?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserByIdProviderElement
    extends AutoDisposeStreamProviderElement<UserModel?> with UserByIdRef {
  _UserByIdProviderElement(super.provider);

  @override
  String get userId => (origin as UserByIdProvider).userId;
}

String _$authNotifierHash() => r'8ff24c3efcc38681855185baee32b06aaf7fc85e';

/// Notifier para acciones de autenticación
///
/// Maneja operaciones como login y logout.
/// Expone AsyncValue<void> como estado para manejar loading/error.
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AsyncValue<void>>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
