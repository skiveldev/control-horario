// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allEmployeesHash() => r'418572fbbd8ad2c245952e22f091cedbf12f7ddf';

/// Provider que obtiene todos los empleados activos desde Firestore
///
/// Retorna un Stream de lista de UserModel, escuchando cambios en tiempo real.
/// Solo incluye empleados con isActive == true.
///
/// Uso en widgets:
/// ```dart
/// final employeesAsync = ref.watch(allEmployeesProvider);
/// employeesAsync.when(
///   data: (employees) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
///
/// Copied from [allEmployees].
@ProviderFor(allEmployees)
final allEmployeesProvider =
    AutoDisposeStreamProvider<List<UserModel>>.internal(
  allEmployees,
  name: r'allEmployeesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allEmployeesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllEmployeesRef = AutoDisposeStreamProviderRef<List<UserModel>>;
String _$employeesCountHash() => r'cf39a93a00b0a8eed1174e2057d3261ef160c04b';

/// Provider que cuenta el total de empleados activos
///
/// Se deriva automáticamente de allEmployeesProvider.
/// Se actualiza en tiempo real cuando cambia la lista.
///
/// Uso en widgets:
/// ```dart
/// final countAsync = ref.watch(employeesCountProvider);
/// countAsync.when(
///   data: (count) => Text('$count empleados'),
///   loading: () => Text('...'),
///   error: (err, stack) => Text('Error'),
/// );
/// ```
///
/// Copied from [employeesCount].
@ProviderFor(employeesCount)
final employeesCountProvider = AutoDisposeStreamProvider<int>.internal(
  employeesCount,
  name: r'employeesCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$employeesCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EmployeesCountRef = AutoDisposeStreamProviderRef<int>;
String _$filteredEmployeesHash() => r'e316c1ca447b79e21aab0bfb13d845315b518ebc';

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

/// Provider para filtrar empleados por query de búsqueda
///
/// Parámetros:
/// - [query]: Texto de búsqueda (busca en displayName, email, employeeId)
///
/// Nota: El filtro se hace en memoria (no en Firestore) para permitir
/// búsqueda flexible sin índices complejos.
///
/// Uso:
/// ```dart
/// final filteredAsync = ref.watch(filteredEmployeesProvider('Juan'));
/// ```
///
/// Copied from [filteredEmployees].
@ProviderFor(filteredEmployees)
const filteredEmployeesProvider = FilteredEmployeesFamily();

/// Provider para filtrar empleados por query de búsqueda
///
/// Parámetros:
/// - [query]: Texto de búsqueda (busca en displayName, email, employeeId)
///
/// Nota: El filtro se hace en memoria (no en Firestore) para permitir
/// búsqueda flexible sin índices complejos.
///
/// Uso:
/// ```dart
/// final filteredAsync = ref.watch(filteredEmployeesProvider('Juan'));
/// ```
///
/// Copied from [filteredEmployees].
class FilteredEmployeesFamily extends Family<AsyncValue<List<UserModel>>> {
  /// Provider para filtrar empleados por query de búsqueda
  ///
  /// Parámetros:
  /// - [query]: Texto de búsqueda (busca en displayName, email, employeeId)
  ///
  /// Nota: El filtro se hace en memoria (no en Firestore) para permitir
  /// búsqueda flexible sin índices complejos.
  ///
  /// Uso:
  /// ```dart
  /// final filteredAsync = ref.watch(filteredEmployeesProvider('Juan'));
  /// ```
  ///
  /// Copied from [filteredEmployees].
  const FilteredEmployeesFamily();

  /// Provider para filtrar empleados por query de búsqueda
  ///
  /// Parámetros:
  /// - [query]: Texto de búsqueda (busca en displayName, email, employeeId)
  ///
  /// Nota: El filtro se hace en memoria (no en Firestore) para permitir
  /// búsqueda flexible sin índices complejos.
  ///
  /// Uso:
  /// ```dart
  /// final filteredAsync = ref.watch(filteredEmployeesProvider('Juan'));
  /// ```
  ///
  /// Copied from [filteredEmployees].
  FilteredEmployeesProvider call(
    String query,
  ) {
    return FilteredEmployeesProvider(
      query,
    );
  }

  @override
  FilteredEmployeesProvider getProviderOverride(
    covariant FilteredEmployeesProvider provider,
  ) {
    return call(
      provider.query,
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
  String? get name => r'filteredEmployeesProvider';
}

/// Provider para filtrar empleados por query de búsqueda
///
/// Parámetros:
/// - [query]: Texto de búsqueda (busca en displayName, email, employeeId)
///
/// Nota: El filtro se hace en memoria (no en Firestore) para permitir
/// búsqueda flexible sin índices complejos.
///
/// Uso:
/// ```dart
/// final filteredAsync = ref.watch(filteredEmployeesProvider('Juan'));
/// ```
///
/// Copied from [filteredEmployees].
class FilteredEmployeesProvider
    extends AutoDisposeStreamProvider<List<UserModel>> {
  /// Provider para filtrar empleados por query de búsqueda
  ///
  /// Parámetros:
  /// - [query]: Texto de búsqueda (busca en displayName, email, employeeId)
  ///
  /// Nota: El filtro se hace en memoria (no en Firestore) para permitir
  /// búsqueda flexible sin índices complejos.
  ///
  /// Uso:
  /// ```dart
  /// final filteredAsync = ref.watch(filteredEmployeesProvider('Juan'));
  /// ```
  ///
  /// Copied from [filteredEmployees].
  FilteredEmployeesProvider(
    String query,
  ) : this._internal(
          (ref) => filteredEmployees(
            ref as FilteredEmployeesRef,
            query,
          ),
          from: filteredEmployeesProvider,
          name: r'filteredEmployeesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredEmployeesHash,
          dependencies: FilteredEmployeesFamily._dependencies,
          allTransitiveDependencies:
              FilteredEmployeesFamily._allTransitiveDependencies,
          query: query,
        );

  FilteredEmployeesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    Stream<List<UserModel>> Function(FilteredEmployeesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredEmployeesProvider._internal(
        (ref) => create(ref as FilteredEmployeesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<UserModel>> createElement() {
    return _FilteredEmployeesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredEmployeesProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredEmployeesRef on AutoDisposeStreamProviderRef<List<UserModel>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _FilteredEmployeesProviderElement
    extends AutoDisposeStreamProviderElement<List<UserModel>>
    with FilteredEmployeesRef {
  _FilteredEmployeesProviderElement(super.provider);

  @override
  String get query => (origin as FilteredEmployeesProvider).query;
}

String _$employeesByDepartmentHash() =>
    r'6da9fda40cc344c102ac87bbbc8e824d65e5cfb1';

/// Provider para filtrar empleados por departamento
///
/// Parámetros:
/// - [department]: Nombre del departamento (ej: "Tecnología", "Docente")
///                 Si es "todos" o vacío, retorna todos los empleados
///
/// Uso:
/// ```dart
/// final techEmployeesAsync = ref.watch(
///   employeesByDepartmentProvider('Tecnología'),
/// );
/// ```
///
/// Copied from [employeesByDepartment].
@ProviderFor(employeesByDepartment)
const employeesByDepartmentProvider = EmployeesByDepartmentFamily();

/// Provider para filtrar empleados por departamento
///
/// Parámetros:
/// - [department]: Nombre del departamento (ej: "Tecnología", "Docente")
///                 Si es "todos" o vacío, retorna todos los empleados
///
/// Uso:
/// ```dart
/// final techEmployeesAsync = ref.watch(
///   employeesByDepartmentProvider('Tecnología'),
/// );
/// ```
///
/// Copied from [employeesByDepartment].
class EmployeesByDepartmentFamily extends Family<AsyncValue<List<UserModel>>> {
  /// Provider para filtrar empleados por departamento
  ///
  /// Parámetros:
  /// - [department]: Nombre del departamento (ej: "Tecnología", "Docente")
  ///                 Si es "todos" o vacío, retorna todos los empleados
  ///
  /// Uso:
  /// ```dart
  /// final techEmployeesAsync = ref.watch(
  ///   employeesByDepartmentProvider('Tecnología'),
  /// );
  /// ```
  ///
  /// Copied from [employeesByDepartment].
  const EmployeesByDepartmentFamily();

  /// Provider para filtrar empleados por departamento
  ///
  /// Parámetros:
  /// - [department]: Nombre del departamento (ej: "Tecnología", "Docente")
  ///                 Si es "todos" o vacío, retorna todos los empleados
  ///
  /// Uso:
  /// ```dart
  /// final techEmployeesAsync = ref.watch(
  ///   employeesByDepartmentProvider('Tecnología'),
  /// );
  /// ```
  ///
  /// Copied from [employeesByDepartment].
  EmployeesByDepartmentProvider call(
    String department,
  ) {
    return EmployeesByDepartmentProvider(
      department,
    );
  }

  @override
  EmployeesByDepartmentProvider getProviderOverride(
    covariant EmployeesByDepartmentProvider provider,
  ) {
    return call(
      provider.department,
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
  String? get name => r'employeesByDepartmentProvider';
}

/// Provider para filtrar empleados por departamento
///
/// Parámetros:
/// - [department]: Nombre del departamento (ej: "Tecnología", "Docente")
///                 Si es "todos" o vacío, retorna todos los empleados
///
/// Uso:
/// ```dart
/// final techEmployeesAsync = ref.watch(
///   employeesByDepartmentProvider('Tecnología'),
/// );
/// ```
///
/// Copied from [employeesByDepartment].
class EmployeesByDepartmentProvider
    extends AutoDisposeStreamProvider<List<UserModel>> {
  /// Provider para filtrar empleados por departamento
  ///
  /// Parámetros:
  /// - [department]: Nombre del departamento (ej: "Tecnología", "Docente")
  ///                 Si es "todos" o vacío, retorna todos los empleados
  ///
  /// Uso:
  /// ```dart
  /// final techEmployeesAsync = ref.watch(
  ///   employeesByDepartmentProvider('Tecnología'),
  /// );
  /// ```
  ///
  /// Copied from [employeesByDepartment].
  EmployeesByDepartmentProvider(
    String department,
  ) : this._internal(
          (ref) => employeesByDepartment(
            ref as EmployeesByDepartmentRef,
            department,
          ),
          from: employeesByDepartmentProvider,
          name: r'employeesByDepartmentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$employeesByDepartmentHash,
          dependencies: EmployeesByDepartmentFamily._dependencies,
          allTransitiveDependencies:
              EmployeesByDepartmentFamily._allTransitiveDependencies,
          department: department,
        );

  EmployeesByDepartmentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.department,
  }) : super.internal();

  final String department;

  @override
  Override overrideWith(
    Stream<List<UserModel>> Function(EmployeesByDepartmentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EmployeesByDepartmentProvider._internal(
        (ref) => create(ref as EmployeesByDepartmentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        department: department,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<UserModel>> createElement() {
    return _EmployeesByDepartmentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EmployeesByDepartmentProvider &&
        other.department == department;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, department.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EmployeesByDepartmentRef
    on AutoDisposeStreamProviderRef<List<UserModel>> {
  /// The parameter `department` of this provider.
  String get department;
}

class _EmployeesByDepartmentProviderElement
    extends AutoDisposeStreamProviderElement<List<UserModel>>
    with EmployeesByDepartmentRef {
  _EmployeesByDepartmentProviderElement(super.provider);

  @override
  String get department => (origin as EmployeesByDepartmentProvider).department;
}

String _$searchAndFilterEmployeesHash() =>
    r'e8f4e1283a5e9a4bd41780662cdbb105ec17e1f5';

/// Provider para filtrar empleados por query de búsqueda Y departamento
///
/// Combina ambos filtros (búsqueda + departamento).
///
/// Parámetros:
/// - [query]: Texto de búsqueda
/// - [department]: Departamento ("todos" para no filtrar)
///
/// Uso:
/// ```dart
/// final filteredAsync = ref.watch(
///   searchAndFilterEmployeesProvider('Juan', 'Tecnología'),
/// );
/// ```
///
/// Copied from [searchAndFilterEmployees].
@ProviderFor(searchAndFilterEmployees)
const searchAndFilterEmployeesProvider = SearchAndFilterEmployeesFamily();

/// Provider para filtrar empleados por query de búsqueda Y departamento
///
/// Combina ambos filtros (búsqueda + departamento).
///
/// Parámetros:
/// - [query]: Texto de búsqueda
/// - [department]: Departamento ("todos" para no filtrar)
///
/// Uso:
/// ```dart
/// final filteredAsync = ref.watch(
///   searchAndFilterEmployeesProvider('Juan', 'Tecnología'),
/// );
/// ```
///
/// Copied from [searchAndFilterEmployees].
class SearchAndFilterEmployeesFamily
    extends Family<AsyncValue<List<UserModel>>> {
  /// Provider para filtrar empleados por query de búsqueda Y departamento
  ///
  /// Combina ambos filtros (búsqueda + departamento).
  ///
  /// Parámetros:
  /// - [query]: Texto de búsqueda
  /// - [department]: Departamento ("todos" para no filtrar)
  ///
  /// Uso:
  /// ```dart
  /// final filteredAsync = ref.watch(
  ///   searchAndFilterEmployeesProvider('Juan', 'Tecnología'),
  /// );
  /// ```
  ///
  /// Copied from [searchAndFilterEmployees].
  const SearchAndFilterEmployeesFamily();

  /// Provider para filtrar empleados por query de búsqueda Y departamento
  ///
  /// Combina ambos filtros (búsqueda + departamento).
  ///
  /// Parámetros:
  /// - [query]: Texto de búsqueda
  /// - [department]: Departamento ("todos" para no filtrar)
  ///
  /// Uso:
  /// ```dart
  /// final filteredAsync = ref.watch(
  ///   searchAndFilterEmployeesProvider('Juan', 'Tecnología'),
  /// );
  /// ```
  ///
  /// Copied from [searchAndFilterEmployees].
  SearchAndFilterEmployeesProvider call(
    String query,
    String department,
  ) {
    return SearchAndFilterEmployeesProvider(
      query,
      department,
    );
  }

  @override
  SearchAndFilterEmployeesProvider getProviderOverride(
    covariant SearchAndFilterEmployeesProvider provider,
  ) {
    return call(
      provider.query,
      provider.department,
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
  String? get name => r'searchAndFilterEmployeesProvider';
}

/// Provider para filtrar empleados por query de búsqueda Y departamento
///
/// Combina ambos filtros (búsqueda + departamento).
///
/// Parámetros:
/// - [query]: Texto de búsqueda
/// - [department]: Departamento ("todos" para no filtrar)
///
/// Uso:
/// ```dart
/// final filteredAsync = ref.watch(
///   searchAndFilterEmployeesProvider('Juan', 'Tecnología'),
/// );
/// ```
///
/// Copied from [searchAndFilterEmployees].
class SearchAndFilterEmployeesProvider
    extends AutoDisposeStreamProvider<List<UserModel>> {
  /// Provider para filtrar empleados por query de búsqueda Y departamento
  ///
  /// Combina ambos filtros (búsqueda + departamento).
  ///
  /// Parámetros:
  /// - [query]: Texto de búsqueda
  /// - [department]: Departamento ("todos" para no filtrar)
  ///
  /// Uso:
  /// ```dart
  /// final filteredAsync = ref.watch(
  ///   searchAndFilterEmployeesProvider('Juan', 'Tecnología'),
  /// );
  /// ```
  ///
  /// Copied from [searchAndFilterEmployees].
  SearchAndFilterEmployeesProvider(
    String query,
    String department,
  ) : this._internal(
          (ref) => searchAndFilterEmployees(
            ref as SearchAndFilterEmployeesRef,
            query,
            department,
          ),
          from: searchAndFilterEmployeesProvider,
          name: r'searchAndFilterEmployeesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchAndFilterEmployeesHash,
          dependencies: SearchAndFilterEmployeesFamily._dependencies,
          allTransitiveDependencies:
              SearchAndFilterEmployeesFamily._allTransitiveDependencies,
          query: query,
          department: department,
        );

  SearchAndFilterEmployeesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.department,
  }) : super.internal();

  final String query;
  final String department;

  @override
  Override overrideWith(
    Stream<List<UserModel>> Function(SearchAndFilterEmployeesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchAndFilterEmployeesProvider._internal(
        (ref) => create(ref as SearchAndFilterEmployeesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        department: department,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<UserModel>> createElement() {
    return _SearchAndFilterEmployeesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchAndFilterEmployeesProvider &&
        other.query == query &&
        other.department == department;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, department.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchAndFilterEmployeesRef
    on AutoDisposeStreamProviderRef<List<UserModel>> {
  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `department` of this provider.
  String get department;
}

class _SearchAndFilterEmployeesProviderElement
    extends AutoDisposeStreamProviderElement<List<UserModel>>
    with SearchAndFilterEmployeesRef {
  _SearchAndFilterEmployeesProviderElement(super.provider);

  @override
  String get query => (origin as SearchAndFilterEmployeesProvider).query;
  @override
  String get department =>
      (origin as SearchAndFilterEmployeesProvider).department;
}

String _$employeeByIdHash() => r'c8665264fa6de4f71b5e93121cc9717b24698244';

/// Provider para obtener un empleado específico por ID
///
/// Parámetros:
/// - [userId]: ID del documento en Firestore
///
/// Retorna Stream<UserModel?> (null si no existe)
///
/// Uso:
/// ```dart
/// final employeeAsync = ref.watch(employeeByIdProvider('userId123'));
/// ```
///
/// Copied from [employeeById].
@ProviderFor(employeeById)
const employeeByIdProvider = EmployeeByIdFamily();

/// Provider para obtener un empleado específico por ID
///
/// Parámetros:
/// - [userId]: ID del documento en Firestore
///
/// Retorna Stream<UserModel?> (null si no existe)
///
/// Uso:
/// ```dart
/// final employeeAsync = ref.watch(employeeByIdProvider('userId123'));
/// ```
///
/// Copied from [employeeById].
class EmployeeByIdFamily extends Family<AsyncValue<UserModel?>> {
  /// Provider para obtener un empleado específico por ID
  ///
  /// Parámetros:
  /// - [userId]: ID del documento en Firestore
  ///
  /// Retorna Stream<UserModel?> (null si no existe)
  ///
  /// Uso:
  /// ```dart
  /// final employeeAsync = ref.watch(employeeByIdProvider('userId123'));
  /// ```
  ///
  /// Copied from [employeeById].
  const EmployeeByIdFamily();

  /// Provider para obtener un empleado específico por ID
  ///
  /// Parámetros:
  /// - [userId]: ID del documento en Firestore
  ///
  /// Retorna Stream<UserModel?> (null si no existe)
  ///
  /// Uso:
  /// ```dart
  /// final employeeAsync = ref.watch(employeeByIdProvider('userId123'));
  /// ```
  ///
  /// Copied from [employeeById].
  EmployeeByIdProvider call(
    String userId,
  ) {
    return EmployeeByIdProvider(
      userId,
    );
  }

  @override
  EmployeeByIdProvider getProviderOverride(
    covariant EmployeeByIdProvider provider,
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
  String? get name => r'employeeByIdProvider';
}

/// Provider para obtener un empleado específico por ID
///
/// Parámetros:
/// - [userId]: ID del documento en Firestore
///
/// Retorna Stream<UserModel?> (null si no existe)
///
/// Uso:
/// ```dart
/// final employeeAsync = ref.watch(employeeByIdProvider('userId123'));
/// ```
///
/// Copied from [employeeById].
class EmployeeByIdProvider extends AutoDisposeStreamProvider<UserModel?> {
  /// Provider para obtener un empleado específico por ID
  ///
  /// Parámetros:
  /// - [userId]: ID del documento en Firestore
  ///
  /// Retorna Stream<UserModel?> (null si no existe)
  ///
  /// Uso:
  /// ```dart
  /// final employeeAsync = ref.watch(employeeByIdProvider('userId123'));
  /// ```
  ///
  /// Copied from [employeeById].
  EmployeeByIdProvider(
    String userId,
  ) : this._internal(
          (ref) => employeeById(
            ref as EmployeeByIdRef,
            userId,
          ),
          from: employeeByIdProvider,
          name: r'employeeByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$employeeByIdHash,
          dependencies: EmployeeByIdFamily._dependencies,
          allTransitiveDependencies:
              EmployeeByIdFamily._allTransitiveDependencies,
          userId: userId,
        );

  EmployeeByIdProvider._internal(
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
    Stream<UserModel?> Function(EmployeeByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EmployeeByIdProvider._internal(
        (ref) => create(ref as EmployeeByIdRef),
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
    return _EmployeeByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EmployeeByIdProvider && other.userId == userId;
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
mixin EmployeeByIdRef on AutoDisposeStreamProviderRef<UserModel?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _EmployeeByIdProviderElement
    extends AutoDisposeStreamProviderElement<UserModel?> with EmployeeByIdRef {
  _EmployeeByIdProviderElement(super.provider);

  @override
  String get userId => (origin as EmployeeByIdProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
