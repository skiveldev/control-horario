import 'package:control_horario/features/admin/models/schedule_model.dart';
import 'package:control_horario/features/admin/presentation/screens/anomalies_screen.dart';
import 'package:control_horario/features/dashboard/models/anomaly_model.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/providers/anomaly_provider.dart';
import 'package:control_horario/features/dashboard/services/anomaly_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/mock_anomalies.dart';

void main() {
  group('AnomaliesScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          anomaliesScreenProvider.overrideWith(
            (ref) {
              final service = ref.watch(anomalyServiceProvider);
              return AnomaliesScreenNotifier(service);
            },
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('muestra mensaje de estado inicial y botón Detectar',
        (tester) async {
      await tester.pumpWidget(_wrapApp(container: container));

      // Debe mostrar el título
      expect(find.text('Detección de Anomalías'), findsOneWidget);
      // Debe mostrar el botón de detectar
      expect(find.text('Detectar Anomalías'), findsOneWidget);
    });

    testWidgets('muestra lista de anomalías cuando hay datos', (tester) async {
      final stateContainer = ProviderContainer(
        overrides: [
          anomaliesScreenProvider.overrideWith(
            (ref) {
              final service = ref.watch(anomalyServiceProvider);
              return AnomaliesScreenNotifier(
                service,
                AnomaliesScreenState(
                  anomalies: mockAnomalies(),
                  isDetecting: false,
                ),
              );
            },
          ),
        ],
      );
      addTearDown(stateContainer.dispose);

      await tester.pumpWidget(_wrapApp(container: stateContainer));
      await tester.pumpAndSettle();

      // Verificar que se muestran anomalías con su fecha
      expect(find.text('2026-05-12'), findsOneWidget);
      expect(find.text('2026-05-13'), findsOneWidget);

      // Verificar que se muestra un tipo de anomalía
      expect(find.text('Salida faltante'), findsOneWidget);
    });

    testWidgets('muestra severidad de cada anomalía', (tester) async {
      final containerWithData = ProviderContainer(
        overrides: [
          anomaliesScreenProvider.overrideWith(
            (ref) {
              final service = ref.watch(anomalyServiceProvider);
              return AnomaliesScreenNotifier(
                service,
                AnomaliesScreenState(
                  anomalies: mockAnomalies(),
                  isDetecting: false,
                ),
              );
            },
          ),
        ],
      );
      addTearDown(containerWithData.dispose);

      await tester.pumpWidget(_wrapApp(container: containerWithData));
      await tester.pumpAndSettle();

      // La severidad alta se muestra
      expect(find.text('high'), findsWidgets);
    });

    testWidgets('muestra mensaje cuando no hay anomalías', (tester) async {
      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe mostrar un mensaje indicando que no hay anomalías
      expect(find.text('No se encontraron anomalías'), findsOneWidget);
    });

    testWidgets('el botón Detectar llama al notifier con parámetros',
        (tester) async {
      bool detectCalled = false;
      final fakeNotifier = _FakeAnomaliesScreenNotifier();
      fakeNotifier.onDetectCalled = () => detectCalled = true;

      final containerWithFake = ProviderContainer(
        overrides: [
          anomaliesScreenProvider.overrideWith((ref) => fakeNotifier),
        ],
      );
      addTearDown(containerWithFake.dispose);

      await tester.pumpWidget(_wrapApp(container: containerWithFake));
      await tester.pumpAndSettle();

      // Tap the detect button
      await tester.tap(find.text('Detectar Anomalías'));
      await tester.pump();

      expect(detectCalled, isTrue,
          reason:
              'El botón Detectar debe llamar al método detectAnomalies del notifier');
    });

    testWidgets('el botón se deshabilita durante la detección', (tester) async {
      final containerDetecting = ProviderContainer(
        overrides: [
          anomaliesScreenProvider.overrideWith(
            (ref) {
              final service = ref.watch(anomalyServiceProvider);
              return AnomaliesScreenNotifier(
                service,
                const AnomaliesScreenState(isDetecting: true),
              );
            },
          ),
        ],
      );
      addTearDown(containerDetecting.dispose);

      await tester.pumpWidget(_wrapApp(container: containerDetecting));
      await tester.pump();

      // Debe mostrar "Detectando..."
      expect(find.text('Detectando...'), findsOneWidget);
    });
  });
}

Widget _wrapApp({required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/admin/anomalies',
        routes: [
          GoRoute(
            path: '/admin/anomalies',
            builder: (context, state) => const AnomaliesScreen(),
          ),
        ],
      ),
    ),
  );
}

/// Fake notifier que registra si se llamó a detectAnomalies
class _FakeAnomaliesScreenNotifier extends AnomaliesScreenNotifier {
  _FakeAnomaliesScreenNotifier() : super(const AnomalyService());

  VoidCallback? onDetectCalled;

  @override
  Future<void> detectAnomalies({
    required String userId,
    required DateTime month,
    required Map<String, DaySchedule> weeklySchedule,
    required List<TimeRecordModel> records,
    required Set<String> vacationDates,
  }) async {
    onDetectCalled?.call();
  }
}
