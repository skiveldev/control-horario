import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/user_model.dart';
import 'admin_provider.dart';

List<UserModel> availableSupervisorsForAssignment(
  Iterable<UserModel> employees, {
  String? excludedUserId,
}) {
  final seenIds = <String>{};
  final supervisors = employees.where((employee) {
    if (!employee.isSupervisor) return false;
    if (excludedUserId != null && employee.userId == excludedUserId) {
      return false;
    }
    return seenIds.add(employee.userId);
  }).toList()
    ..sort((a, b) => a.fullName.compareTo(b.fullName));

  return supervisors;
}

/// Lista reutilizable de supervisores activos.
///
/// Se deriva desde `allEmployeesProvider` para mantener un único stream de
/// usuarios y filtrar solo quienes tienen capacidad real de supervisión.
final supervisorsProvider = StreamProvider<List<UserModel>>((ref) {
  final employeesAsync = ref.watch(allEmployeesProvider);

  return employeesAsync.when(
    data: (employees) {
      final supervisors = availableSupervisorsForAssignment(employees);
      return Stream.value(supervisors);
    },
    loading: () => Stream.value(const <UserModel>[]),
    error: (error, stackTrace) => Stream.error(error, stackTrace),
  );
});
