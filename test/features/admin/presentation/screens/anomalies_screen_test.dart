import 'package:control_horario/features/admin/presentation/screens/anomalies_screen.dart';
import 'package:control_horario/features/dashboard/models/anomaly_model.dart';
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

    testWidgets('muestra estado planificado inicial y CTA deshabilitado',
        (tester) async {
      await tester.pumpWidget(_wrapApp(container: container));

      // Debe mostrar el título
      expect(find.text('Detección de Anomalías'), findsOneWidget);
      // Debe comunicar que la detección real aún no está activa.
      expect(
          find.text('Detección de anomalías en construcción'), findsOneWidget);
      expect(find.text('Próxima funcionalidad'), findsOneWidget);
      final button =
          tester.widget<ElevatedButton>(find.bySubtype<ElevatedButton>());
      expect(button.onPressed, isNull);
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

    testWidgets('muestra mensaje planificado cuando no hay anomalías',
        (tester) async {
      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // No debe afirmar que un escaneo real terminó correctamente.
      expect(
          find.text('Detección de anomalías en construcción'), findsOneWidget);
      expect(find.text('No se encontraron anomalías'), findsNothing);
      expect(
        find.text(
            'Todos los registros del período seleccionado son correctos.'),
        findsNothing,
      );
    });

    testWidgets('el CTA planificado permanece deshabilitado', (tester) async {
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

      expect(find.text('Próxima funcionalidad'), findsOneWidget);
      final button =
          tester.widget<ElevatedButton>(find.bySubtype<ElevatedButton>());
      expect(button.onPressed, isNull);
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
