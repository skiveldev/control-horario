import 'package:control_horario/features/admin/presentation/widgets/supervisor_assignment_field.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('availableSupervisorsForAssignment', () {
    test('filtra solo supervisores activos, ordena y excluye el usuario actual',
        () {
      final supervisors = availableSupervisorsForAssignment(
        [
          _employee(
            userId: 'bea',
            displayName: 'Bea Campos',
            nombre: 'Bea',
            apellido1: 'Campos',
            isSupervisor: true,
          ),
          _employee(
            userId: 'ana',
            displayName: 'Ana Bravo',
            nombre: 'Ana',
            apellido1: 'Bravo',
            isSupervisor: true,
          ),
          _employee(
            userId: 'carlos',
            displayName: 'Carlos Díaz',
            nombre: 'Carlos',
            apellido1: 'Díaz',
            isSupervisor: false,
          ),
        ],
        excludedUserId: 'bea',
      );

      expect(
        supervisors.map((item) => item.fullName),
        orderedEquals(['Ana Bravo']),
      );
    });

    test('retorna vacío cuando no hay supervisores asignables', () {
      final supervisors = availableSupervisorsForAssignment(
        [
          _employee(
            userId: 'carlos',
            displayName: 'Carlos Díaz',
            nombre: 'Carlos',
            apellido1: 'Díaz',
            isSupervisor: false,
          ),
        ],
      );

      expect(supervisors, isEmpty);
    });
  });

  group('SupervisorAssignmentField', () {
    testWidgets('muestra opciones ordenadas y mantiene selección no disponible',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          child: SupervisorAssignmentField(
            supervisorsAsync: AsyncValue.data([
              _employee(
                userId: 'bea',
                displayName: 'Bea Campos',
                nombre: 'Bea',
                apellido1: 'Campos',
                isSupervisor: true,
              ),
              _employee(
                userId: 'ana',
                displayName: 'Ana Bravo',
                nombre: 'Ana',
                apellido1: 'Bravo',
                isSupervisor: true,
              ),
            ]),
            selectedSupervisorId: 'legacy',
            excludedUserId: 'bea',
            onChanged: (_) {},
            unavailableSelectionLabel: 'Supervisor actual no disponible',
            helperText:
                'Puedes asignar o quitar el supervisor responsable de este empleado.',
            emptyText: 'No hay supervisores activos disponibles todavía.',
          ),
        ),
      );

      expect(find.text('Supervisor actual no disponible'), findsOneWidget);
      expect(
          find.text(
              'Puedes asignar o quitar el supervisor responsable de este empleado.'),
          findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Sin asignar'), findsOneWidget);
      expect(find.text('Ana Bravo'), findsWidgets);
      expect(find.text('Bea Campos'), findsNothing);
    });

    testWidgets('deshabilita el selector y muestra el mensaje de admin',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          child: SupervisorAssignmentField(
            supervisorsAsync: AsyncValue.data([
              _employee(
                userId: 'ana',
                displayName: 'Ana Bravo',
                nombre: 'Ana',
                apellido1: 'Bravo',
                isSupervisor: true,
              ),
            ]),
            selectedSupervisorId: null,
            enabled: false,
            onChanged: null,
            helperText: 'Los administradores no se asignan a un supervisor.',
            emptyText: 'No hay supervisores activos disponibles todavía.',
          ),
        ),
      );

      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );

      expect(dropdown.onChanged, isNull);
      expect(find.text('Los administradores no se asignan a un supervisor.'),
          findsOneWidget);
    });
  });
}

Widget _wrap({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

UserModel _employee({
  required String userId,
  required String displayName,
  required String nombre,
  required String apellido1,
  required bool isSupervisor,
}) {
  return UserModel(
    userId: userId,
    employeeId: 'EMP-$userId',
    email: '$userId@example.com',
    displayName: displayName,
    role: UserRole.employee,
    isSupervisor: isSupervisor,
    weeklyHours: 40,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    nombre: nombre,
    apellido1: apellido1,
  );
}
