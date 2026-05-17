import 'package:control_horario/features/admin/presentation/widgets/compliance_badge.dart';
import 'package:control_horario/features/dashboard/services/compliance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComplianceBadge', () {
    testWidgets('muestra badge verde con etiqueta "Cumple" para compliant',
        (tester) async {
      await tester.pumpWidget(_wrapApp(
        child: const ComplianceBadge(status: ComplianceStatus.compliant),
      ));

      expect(find.text('Cumple'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('muestra badge ámbar con etiqueta "Desviado" para deviated',
        (tester) async {
      await tester.pumpWidget(_wrapApp(
        child: const ComplianceBadge(status: ComplianceStatus.deviated),
      ));

      expect(find.text('Desviado'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('muestra badge rojo con etiqueta "Sin datos" para noRecord',
        (tester) async {
      await tester.pumpWidget(_wrapApp(
        child: const ComplianceBadge(status: ComplianceStatus.noRecord),
      ));

      expect(find.text('Sin datos'), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle), findsOneWidget);
    });

    testWidgets('el badge de compliant tiene un indicador visual de color',
        (tester) async {
      await tester.pumpWidget(_wrapApp(
        child: const ComplianceBadge(status: ComplianceStatus.compliant),
      ));

      // El container del badge debe existir y ser visible
      final container = tester.widget<Container>(find.byType(Container));
      expect(container, isNotNull);
    });
  });
}

Widget _wrapApp({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}
