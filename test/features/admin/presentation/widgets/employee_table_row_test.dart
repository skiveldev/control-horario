import 'package:control_horario/features/admin/presentation/widgets/employee_table_row.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

UserModel _testEmployee({String userId = 'EMP-001'}) {
  return UserModel(
    userId: userId,
    employeeId: userId,
    email: '$userId@example.com',
    displayName: 'Test Employee',
    role: UserRole.employee,
    weeklyHours: 40,
    createdAt: DateTime(2026, 1, 1),
    department: 'Tecnología',
    position: 'Developer',
  );
}

void main() {
  group('EmployeeTableRow last clock-in cleanup', () {
    testWidgets('muestra "—" en lugar de MockData.getLastClockIn()', (
      tester,
    ) async {
      // Desktop viewport for full row
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeTableRow(employee: _testEmployee()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // La columna de último fichaje debe mostrar placeholder "—"
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('NO muestra valores mock como "Hoy, 08:45" o "Ayer, 18:30"', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeTableRow(employee: _testEmployee()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Valores de MockData.getLastClockIn() NO deben aparecer
      expect(find.text('Hoy, 08:45'), findsNothing);
      expect(find.text('Hoy, 09:00'), findsNothing);
      expect(find.text('Ayer, 18:30'), findsNothing);
      expect(find.textContaining('Hoy,'), findsNothing);
      expect(find.textContaining('Ayer,'), findsNothing);
    });

    testWidgets(
      'nombre, departamento y estado siguen visibles',
      (tester) async {
        tester.view.physicalSize = const Size(1920, 1080);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmployeeTableRow(employee: _testEmployee()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Otras columnas deben seguir mostrando datos reales
        expect(find.text('Test Employee'), findsOneWidget);
        expect(find.text('Tecnología'), findsOneWidget);
      },
    );
  });
}
