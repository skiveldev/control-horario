import 'package:control_horario/features/dashboard/presentation/widgets/quick_actions_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuickActionsCard verification fixes', () {
    testWidgets(
      'las 3 acciones muestran badge "Próximo" (todas deshabilitadas)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: QuickActionsCard())),
        );
        await tester.pumpAndSettle();

        // Las 3 acciones deben existir
        expect(find.text('Solicitar vacaciones'), findsOneWidget);
        expect(find.text('Editar registro'), findsOneWidget);
        expect(find.text('Ver reportes'), findsOneWidget);

        // Las 3 deben estar deshabilitadas: exactamente 3 badges "Próximo"
        expect(find.text('Próximo'), findsNWidgets(3));
      },
    );

    testWidgets(
      '"Editar registro" NO abre diálogo mock (deshabilitado)',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: QuickActionsCard())),
        );
        await tester.pumpAndSettle();

        // Al hacer tap en "Editar registro", NO debe aparecer diálogo
        await tester.tap(find.text('Editar registro'));
        await tester.pumpAndSettle();

        // El diálogo EditEntranceDialog NO debe aparecer
        expect(find.text('Editar Hora de Entrada'), findsNothing);
      },
    );

    testWidgets(
      'ninguna acción muestra SnackBar "En desarrollo" al tap (todas disabled)',
      (tester) async {
        // Use a tall viewport so all 3 actions are visible and tappable
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: QuickActionsCard())),
        );
        await tester.pumpAndSettle();

        // Tap en cada acción — ninguna debe mostrar SnackBar
        await tester.tap(find.text('Solicitar vacaciones'));
        await tester.pumpAndSettle();
        expect(find.textContaining('En desarrollo'), findsNothing);

        await tester.tap(find.text('Editar registro'));
        await tester.pumpAndSettle();
        expect(find.textContaining('En desarrollo'), findsNothing);

        await tester.tap(find.text('Ver reportes'));
        await tester.pumpAndSettle();
        expect(find.textContaining('En desarrollo'), findsNothing);
      },
    );

    testWidgets(
      'el widget no depende de MockData.quickActions',
      (tester) async {
        // Verificar que el widget renderiza sin depender de MockData
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: QuickActionsCard())),
        );
        await tester.pumpAndSettle();

        // Las acciones deben renderizarse correctamente con títulos correctos
        expect(find.text('Solicitar vacaciones'), findsOneWidget);
        expect(find.text('Editar registro'), findsOneWidget);
        expect(find.text('Ver reportes'), findsOneWidget);
        // No debe haber otros textos mock
        expect(find.text('request_vacation'), findsNothing);
      },
    );
  });
}
