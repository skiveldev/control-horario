import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/models/user_model.dart';

part 'admin_provider.g.dart';

// ============================================================================
// DÍA 4 - SPRINT 4.1: Provider de Todos los Empleados
// ============================================================================

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
@riverpod
Stream<List<UserModel>> allEmployees(AllEmployeesRef ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('users')
      .where('isActive', isEqualTo: true)
      // TODO [DÍA-4]: Crear índice en Firestore para .orderBy('displayName')
      // Por ahora ordenamos en memoria
      .snapshots()
      .map((snapshot) {
    final employees =
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

    // Ordenar en memoria ya que no tenemos índice en Firestore
    employees.sort((a, b) => a.displayName.compareTo(b.displayName));

    return employees;
  });
}

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
@riverpod
Stream<int> employeesCount(EmployeesCountRef ref) {
  final employeesAsync = ref.watch(allEmployeesProvider);

  return employeesAsync.when(
    data: (employees) => Stream.value(employees.length),
    loading: () => Stream.value(0),
    error: (err, stack) => Stream.value(0),
  );
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
@riverpod
Stream<List<UserModel>> filteredEmployees(
  FilteredEmployeesRef ref,
  String query,
) {
  final allEmployeesAsync = ref.watch(allEmployeesProvider);

  return allEmployeesAsync.when(
    data: (employees) {
      if (query.trim().isEmpty) {
        return Stream.value(employees);
      }

      final lowercaseQuery = query.toLowerCase().trim();

      final filtered = employees.where((employee) {
        final matchesDisplayName =
            employee.displayName.toLowerCase().contains(lowercaseQuery);
        final matchesEmail =
            employee.email.toLowerCase().contains(lowercaseQuery);
        final matchesEmployeeId =
            employee.employeeId.toLowerCase().contains(lowercaseQuery);

        return matchesDisplayName || matchesEmail || matchesEmployeeId;
      }).toList();

      return Stream.value(filtered);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
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
@riverpod
Stream<List<UserModel>> employeesByDepartment(
  EmployeesByDepartmentRef ref,
  String department,
) {
  final allEmployeesAsync = ref.watch(allEmployeesProvider);

  return allEmployeesAsync.when(
    data: (employees) {
      if (department.trim().isEmpty || department.toLowerCase() == 'todos') {
        return Stream.value(employees);
      }

      final filtered = employees.where((employee) {
        return employee.department?.toLowerCase() ==
            department.toLowerCase().trim();
      }).toList();

      return Stream.value(filtered);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
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
@riverpod
Stream<List<UserModel>> searchAndFilterEmployees(
  SearchAndFilterEmployeesRef ref,
  String query,
  String department,
) {
  final allEmployeesAsync = ref.watch(allEmployeesProvider);

  return allEmployeesAsync.when(
    data: (employees) {
      var filtered = employees;

      // Filtro 1: Departamento
      if (department.trim().isNotEmpty && department.toLowerCase() != 'todos') {
        filtered = filtered.where((employee) {
          return employee.department?.toLowerCase() ==
              department.toLowerCase().trim();
        }).toList();
      }

      // Filtro 2: Búsqueda
      if (query.trim().isNotEmpty) {
        final lowercaseQuery = query.toLowerCase().trim();
        filtered = filtered.where((employee) {
          final matchesDisplayName =
              employee.displayName.toLowerCase().contains(lowercaseQuery);
          final matchesEmail =
              employee.email.toLowerCase().contains(lowercaseQuery);
          final matchesEmployeeId =
              employee.employeeId.toLowerCase().contains(lowercaseQuery);

          return matchesDisplayName || matchesEmail || matchesEmployeeId;
        }).toList();
      }

      return Stream.value(filtered);
    },
    loading: () => Stream.value([]),
    error: (err, stack) => Stream.value([]),
  );
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
@riverpod
Stream<UserModel?> employeeById(
  EmployeeByIdRef ref,
  String userId,
) {
  final firestore = ref.watch(firestoreProvider);

  return firestore.collection('users').doc(userId).snapshots().map((doc) {
    if (!doc.exists) {
      return null;
    }
    return UserModel.fromFirestore(doc);
  });
}
