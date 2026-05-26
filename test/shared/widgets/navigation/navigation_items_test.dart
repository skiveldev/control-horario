import 'package:control_horario/shared/widgets/navigation/navigation_items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavigationItems.items', () {
    group('empleado (canSuperviseTeam: false)', () {
      final employeeItems = NavigationItems.items(canSuperviseTeam: false);
      final employeeLabels = employeeItems.map((e) => e.label).toList();

      test('NO incluye item "Configuración"', () {
        expect(
          employeeLabels.contains('Configuración'),
          isFalse,
          reason:
              'Los empleados no supervisores no deben ver "Configuración" en la navegación',
        );
      });

      test('NO incluye item "Equipo"', () {
        expect(
          employeeLabels.contains('Equipo'),
          isFalse,
          reason:
              'Los empleados no supervisores no deben ver "Equipo" en la navegación',
        );
      });

      test('incluye items principales (Inicio, Calendario, Mi Control Horario)',
          () {
        expect(employeeLabels, contains('Inicio'));
        expect(employeeLabels, contains('Calendario'));
        expect(employeeLabels, contains('Mi Control Horario'));
      });

      test('tiene exactamente 3 items visibles (sin Equipo ni Configuración)',
          () {
        expect(employeeItems.length, equals(3));
      });
    });

    group('supervisor (canSuperviseTeam: true)', () {
      final supervisorItems = NavigationItems.items(canSuperviseTeam: true);
      final supervisorLabels = supervisorItems.map((e) => e.label).toList();

      test('incluye item "Equipo"', () {
        expect(
          supervisorLabels.contains('Equipo'),
          isTrue,
          reason:
              'Los supervisores deben ver el acceso a "Equipo" en la navegación',
        );
      });

      test('NO incluye item "Configuración"', () {
        expect(
          supervisorLabels.contains('Configuración'),
          isFalse,
          reason:
              'Los supervisores tampoco deben ver "Configuración" en sidebar; '
              'solo el header gear provee acceso a ajustes',
        );
      });

      test('incluye items principales (Inicio, Calendario, Mi Control Horario)',
          () {
        expect(supervisorLabels, contains('Inicio'));
        expect(supervisorLabels, contains('Calendario'));
        expect(supervisorLabels, contains('Mi Control Horario'));
      });

      test('tiene exactamente 4 items visibles (sin Configuración)', () {
        expect(supervisorItems.length, equals(4));
      });
    });
  });
}
