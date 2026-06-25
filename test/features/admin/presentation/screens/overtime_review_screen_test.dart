import 'package:control_horario/features/admin/presentation/screens/overtime_review_screen.dart';
import 'package:control_horario/features/dashboard/models/overtime_request_model.dart';
import 'package:control_horario/features/dashboard/providers/overtime_provider.dart';
import 'package:control_horario/features/dashboard/services/overtime_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/mock_overtime.dart';

void main() {
  group('OvertimeReviewScreen', () {
    testWidgets('muestra título y estado honesto de próxima funcionalidad',
        (tester) async {
      final container = _containerWithRequests([]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Revisión de Horas Extra'), findsOneWidget);
      expect(
        find.text('Revisión de horas extra en construcción'),
        findsOneWidget,
      );
      expect(find.text('Próxima funcionalidad'), findsOneWidget);
      expect(find.text('No hay solicitudes pendientes'), findsNothing);
    });

    testWidgets(
        'mantiene renderizado inyectado de solicitudes sin acciones activas',
        (tester) async {
      final container = _containerWithRequests(mockOvertimeRequests());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Revisión de Horas Extra'), findsOneWidget);
      expect(find.textContaining('5.5h'), findsOneWidget);
      expect(find.textContaining('2.0h'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsWidgets);
      expect(find.byIcon(Icons.close), findsWidgets);

      final actionButtons = tester.widgetList<IconButton>(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              (widget.tooltip == 'Aprobar no disponible todavía' ||
                  widget.tooltip == 'Rechazar no disponible todavía'),
        ),
      );
      expect(actionButtons, isNotEmpty);
      expect(actionButtons.every((button) => button.onPressed == null), isTrue);
    });

    testWidgets('muestra estado "Pendiente" en cada solicitud', (tester) async {
      final container = _containerWithRequests(mockOvertimeRequests());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Pendiente'), findsWidgets);
    });

    testWidgets('no afirma que no hay solicitudes si no cargó datos reales',
        (tester) async {
      final container = _containerWithRequests([]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      expect(find.text('No hay solicitudes pendientes'), findsNothing);
      expect(
        find.text('Revisión de horas extra en construcción'),
        findsOneWidget,
      );
    });

    testWidgets(
        'el control aprobar no llama al servicio mientras está planificado',
        (tester) async {
      final fakeService = _FakeOvertimeService();
      final request = mockOvertimeRequests().first;

      final container = ProviderContainer(
        overrides: [
          overtimeReviewScreenProvider.overrideWith(
            (ref) => OvertimeReviewNotifier(
              fakeService,
              OvertimeReviewScreenState(pendingRequests: [request]),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      final approveButtons = find.byIcon(Icons.check);
      expect(approveButtons, findsWidgets);

      await tester.tap(approveButtons.first);
      await tester.pumpAndSettle();

      expect(fakeService.approvedIds, isEmpty,
          reason:
              'El control visible debe estar deshabilitado hasta conectar el flujo real');
    });

    testWidgets(
        'el control rechazar no llama al servicio mientras está planificado',
        (tester) async {
      final fakeService = _FakeOvertimeService();
      final request = mockOvertimeRequests().first;

      final container = ProviderContainer(
        overrides: [
          overtimeReviewScreenProvider.overrideWith(
            (ref) => OvertimeReviewNotifier(
              fakeService,
              OvertimeReviewScreenState(pendingRequests: [request]),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      final rejectButtons = find.byIcon(Icons.close);
      expect(rejectButtons, findsWidgets);

      await tester.tap(rejectButtons.first);
      await tester.pumpAndSettle();

      expect(fakeService.rejectedIds, isEmpty,
          reason:
              'El control visible debe estar deshabilitado hasta conectar el flujo real');
    });
  });
}

ProviderContainer _containerWithRequests(List<OvertimeRequestModel> requests) {
  final fakeService = _FakeOvertimeService();
  return ProviderContainer(
    overrides: [
      overtimeServiceProvider.overrideWith((ref) => fakeService),
      overtimeReviewScreenProvider.overrideWith(
        (ref) {
          return OvertimeReviewNotifier(
            fakeService,
            OvertimeReviewScreenState(
              pendingRequests: requests,
              isProcessing: false,
            ),
          );
        },
      ),
    ],
  );
}

Widget _wrapApp({required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: OvertimeReviewScreen(),
    ),
  );
}

/// Fake OvertimeService que expone los IDs aprobados/rechazados en tests.
class _FakeOvertimeService extends OvertimeService {
  _FakeOvertimeService() : super.test();

  final List<OvertimeRequestModel> pendingRequests = [];
  final List<String> approvedIds = [];
  final List<String> rejectedIds = [];

  @override
  Future<List<OvertimeRequestModel>> getPendingRequests() async {
    return List.unmodifiable(pendingRequests);
  }

  @override
  Future<void> approveRequest(String id, {required String approvedBy}) async {
    approvedIds.add(id);
    pendingRequests.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> rejectRequest(String id, {required String rejectedBy}) async {
    rejectedIds.add(id);
    pendingRequests.removeWhere((r) => r.id == id);
  }
}
