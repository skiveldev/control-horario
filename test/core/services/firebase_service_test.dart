import 'package:control_horario/core/services/firebase_service.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildEmployeeDocumentData', () {
    test('incluye supervisorId cuando admin asigna supervisor al empleado', () {
      final payload = buildEmployeeDocumentData(
        userId: 'employee-a',
        employeeId: 'EMP-employee-a',
        email: 'employee-a@example.com',
        displayName: 'Empleado A',
        role: UserRole.employee,
        isSupervisor: false,
        isActive: true,
        supervisorId: 'supervisor-1',
        weeklyHours: 37.5,
        nombre: 'Empleado',
        apellido1: 'A',
      );

      expect(payload['userId'], 'employee-a');
      expect(payload['role'], UserRole.employee.name);
      expect(payload['isSupervisor'], isFalse);
      expect(payload['supervisorId'], 'supervisor-1');
    });

    test('omite supervisorId cuando llega vacío en el alta admin', () {
      final payload = buildEmployeeDocumentData(
        userId: 'employee-b',
        employeeId: 'EMP-employee-b',
        email: 'employee-b@example.com',
        displayName: 'Empleado B',
        role: UserRole.employee,
        isSupervisor: true,
        isActive: true,
        supervisorId: '   ',
        weeklyHours: 40,
        nombre: 'Empleado',
        apellido1: 'B',
      );

      expect(payload['isSupervisor'], isTrue);
      expect(payload.containsKey('supervisorId'), isFalse);
    });

    test('persiste isActive con el valor seleccionado en el alta', () {
      final payload = buildEmployeeDocumentData(
        userId: 'employee-c',
        employeeId: 'EMP-employee-c',
        email: 'employee-c@example.com',
        displayName: 'Empleado C',
        role: UserRole.employee,
        isSupervisor: false,
        isActive: false,
        weeklyHours: 20,
        nombre: 'Empleado',
        apellido1: 'C',
      );

      expect(payload['isActive'], isFalse);
    });
  });
}
