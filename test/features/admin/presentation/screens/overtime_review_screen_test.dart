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
    testWidgets('muestra título y lista de solicitudes pendientes',
        (tester) async {
      final container = _containerWithRequests(mockOvertimeRequests());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe mostrar el título
      expect(find.text('Revisión de Horas Extra'), findsOneWidget);
      // Debe mostrar las horas de al menos una solicitud
      expect(find.textContaining('5.5h'), findsOneWidget);
      expect(find.textContaining('2.0h'), findsOneWidget);
    });

    testWidgets('muestra botones aprobar y rechazar para cada solicitud',
        (tester) async {
      final container = _containerWithRequests(mockOvertimeRequests());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Botones de aprobar
      expect(find.byIcon(Icons.check), findsWidgets);
      // Botones de rechazar
      expect(find.byIcon(Icons.close), findsWidgets);
    });

    testWidgets('muestra estado "Pendiente" en cada solicitud',
        (tester) async {
      final container = _containerWithRequests(mockOvertimeRequests());
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      expect(find.text('Pendiente'), findsWidgets);
    });

    testWidgets('muestra mensaje cuando no hay solicitudes', (tester) async {
      final container = _containerWithRequests([]);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      expect(find.text('No hay solicitudes pendientes'), findsOneWidget);
    });

    testWidgets('el botón aprobar llama al notifier con approveRequest',
        (tester) async {
      final fakeService = _FakeOvertimeService();
      final fakeNotifier = OvertimeReviewNotifier(fakeService);
      // Precargar una solicitud pendiente
      fakeService.pendingRequests.add(mockOvertimeRequests().first);

      final container = ProviderContainer(
        overrides: [
          overtimeReviewScreenProvider.overrideWith((ref) => fakeNotifier),
        ],
      );
      addTearDown(container.dispose);

      // Cargar las solicitudes
      await fakeNotifier.loadPendingRequests();
      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Tap the approve button (primer IconButton con icono check)
      final approveButtons = find.byIcon(Icons.check);
      expect(approveButtons, findsWidgets);

      await tester.tap(approveButtons.first);
      await tester.pumpAndSettle();

      expect(fakeService.approvedIds, isNotEmpty,
          reason:
              'El botón aprobar debe llamar al servicio approveRequest');
      expect(fakeService.approvedIds.first, 'ot-1');
    });

    testWidgets('el botón rechazar llama al notifier con rejectRequest',
        (tester) async {
      final fakeService = _FakeOvertimeService();
      final fakeNotifier = OvertimeReviewNotifier(fakeService);
      // Precargar una solicitud pendiente
      fakeService.pendingRequests.add(mockOvertimeRequests().first);

      final container = ProviderContainer(
        overrides: [
          overtimeReviewScreenProvider.overrideWith((ref) => fakeNotifier),
        ],
      );
      addTearDown(container.dispose);

      // Cargar las solicitudes
      await fakeNotifier.loadPendingRequests();
      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Tap the reject button (primer IconButton con icono close)
      final rejectButtons = find.byIcon(Icons.close);
      expect(rejectButtons, findsWidgets);

      await tester.tap(rejectButtons.first);
      await tester.pumpAndSettle();

      expect(fakeService.rejectedIds, isNotEmpty,
          reason:
              'El botón rechazar debe llamar al servicio rejectRequest');
      expect(fakeService.rejectedIds.first, 'ot-1');
    });
  });
}

ProviderContainer _containerWithRequests(
    List<OvertimeRequestModel> requests) {
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
