import 'dart:async';

import 'package:control_horario/core/router/app_router.dart';
import 'package:control_horario/features/admin/presentation/screens/calendar_editor_screen.dart';
import 'package:control_horario/features/admin/models/work_calendar_model.dart';
import 'package:control_horario/features/admin/models/calendar_event_model.dart';
import 'package:control_horario/features/admin/providers/calendar_management_provider.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

class _SaveCall {
  final String? calendarId;
  final String name;

  const _SaveCall({required this.calendarId, required this.name});
}

/// Simple stub implementation of WorkCalendarModel for route testing.
/// Avoids the complexity of the full Firestore-backed model.
class _FakeWorkCalendar extends WorkCalendarModel {
  _FakeWorkCalendar(
      {required super.id, required super.name, required super.year})
      : super(
          events: const [],
          isActive: true,
        );
}

/// Fake admin user for deterministic provider setup in tests.
final _fakeAdminUser = UserModel(
  userId: 'admin-001',
  employeeId: 'admin-001',
  email: 'admin@test.com',
  displayName: 'Admin Test',
  role: UserRole.admin,
  weeklyHours: 40,
  createdAt: DateTime(2026, 1, 1),
  department: 'Admin',
  position: 'Administrador',
);

class _FakeCalendarManagement extends CalendarManagement {
  final List<_SaveCall> saveCalls = [];
  final Completer<String>? saveCompleter;
  final Object? saveError;

  _FakeCalendarManagement({this.saveCompleter, this.saveError});

  @override
  void build() {}

  @override
  Future<String> saveCalendar({
    required String? calendarId,
    required String name,
    required int year,
    required List<CalendarEventModel> events,
    bool isActive = true,
  }) async {
    saveCalls.add(_SaveCall(calendarId: calendarId, name: name));
    if (saveError != null) throw saveError!;
    if (saveCompleter != null) return saveCompleter!.future;
    return calendarId ?? 'created-calendar';
  }
}

Widget _wrap(Widget child, {CalendarManagement? notifier}) {
  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWith((ref) => Stream.value(_fakeAdminUser)),
      if (notifier != null)
        calendarManagementProvider.overrideWith(() => notifier),
    ],
    child: MaterialApp(home: child),
  );
}

Widget _wrapPushedEditor(Widget editor, {CalendarManagement? notifier}) {
  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWith((ref) => Stream.value(_fakeAdminUser)),
      if (notifier != null)
        calendarManagementProvider.overrideWith(() => notifier),
    ],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => editor),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    // Required by table_calendar package used in CalendarEditorScreen
    initializeDateFormatting('es', null);
  });

  group('AppRouter.adminCalendarEditor', () {
    test('existe y equivale a "/admin/calendars/:id/edit"', () {
      // RED: AppRouter.adminCalendarEditor no existe aún — esta prueba fallará en compilación.
      expect(
          AppRouter.adminCalendarEditor, equals('/admin/calendars/:id/edit'));
    });

    test('es distinta de la ruta padre adminCalendars', () {
      expect(AppRouter.adminCalendarEditor,
          isNot(equals(AppRouter.adminCalendars)));
    });

    testWidgets(
        'CalendarEditorScreen acepta existingCalendar y renderiza modo nuevo', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CalendarEditorScreen(existingCalendar: null)),
      );

      // Title for new calendar mode is "Nuevo Calendario"
      expect(find.text('Nuevo Calendario'), findsOneWidget);
    });

    testWidgets(
        'CalendarEditorScreen muestra nombre del calendario en modo edición', (
      tester,
    ) async {
      final calendar = _FakeWorkCalendar(
        id: 'cal-001',
        name: 'Festivos Nacionales',
        year: 2025,
      );

      await tester.pumpWidget(
        _wrap(CalendarEditorScreen(existingCalendar: calendar)),
      );

      // In edit mode, the calendar name should be visible as editable text
      expect(find.text('Festivos Nacionales'), findsOneWidget);
    });

    testWidgets('CalendarEditorRouteScreen trata "new" como modo creación', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const CalendarEditorRouteScreen(calendarId: 'new')),
      );

      expect(find.text('Nuevo Calendario'), findsOneWidget);
    });

    testWidgets('CalendarEditorRouteScreen resuelve edición sin extra', (
      tester,
    ) async {
      final calendar = _FakeWorkCalendar(
        id: 'cal-001',
        name: 'Festivos Madrid',
        year: 2026,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarByIdProvider('cal-001')
                .overrideWith((ref) => Stream.value(calendar)),
          ],
          child: const MaterialApp(
            home: CalendarEditorRouteScreen(calendarId: 'cal-001'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Editar Calendario'), findsOneWidget);
      expect(find.text('Festivos Madrid'), findsOneWidget);
      expect(find.text('Nuevo Calendario'), findsNothing);
    });

    testWidgets('CalendarEditorRouteScreen no crea si el id no existe', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarByIdProvider('missing')
                .overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(
            home: CalendarEditorRouteScreen(calendarId: 'missing'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Calendario no encontrado'), findsOneWidget);
      expect(find.text('Nuevo Calendario'), findsNothing);
    });

    testWidgets(
        'CalendarEditorRouteScreen muestra error seguro si falla el provider', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/admin/calendars/broken/edit',
        routes: [
          GoRoute(
            path: '/admin/calendars',
            builder: (context, state) => const Scaffold(
              body: Text('Listado de calendarios'),
            ),
            routes: [
              GoRoute(
                path: ':id/edit',
                builder: (context, state) => CalendarEditorRouteScreen(
                  calendarId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarByIdProvider('broken').overrideWith(
              (ref) => Stream.error(Exception('boom')),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();

      expect(
          find.textContaining('Error al cargar el calendario'), findsOneWidget);
      expect(find.text('Nuevo Calendario'), findsNothing);

      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();

      expect(find.text('Listado de calendarios'), findsOneWidget);
    });

    testWidgets('valida nombre obligatorio antes de guardar', (tester) async {
      final notifier = _FakeCalendarManagement();

      await tester.pumpWidget(
        _wrap(const CalendarEditorScreen(), notifier: notifier),
      );

      await tester.tap(find.text('Guardar Calendario'));
      await tester.pump();

      expect(
          find.text('El nombre del calendario es obligatorio'), findsOneWidget);
      expect(notifier.saveCalls, isEmpty);
    });

    testWidgets('guarda correctamente y vuelve atrás', (tester) async {
      final notifier = _FakeCalendarManagement();

      await tester.pumpWidget(
        _wrapPushedEditor(const CalendarEditorScreen(), notifier: notifier),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Calendario 2026');
      await tester.tap(find.text('Guardar Calendario'));
      await tester.pumpAndSettle();

      expect(notifier.saveCalls, hasLength(1));
      expect(notifier.saveCalls.single.name, 'Calendario 2026');
      expect(find.text('Abrir'), findsOneWidget);
    });

    testWidgets('muestra error del provider sin cerrar la pantalla',
        (tester) async {
      final notifier = _FakeCalendarManagement(saveError: Exception('boom'));

      await tester.pumpWidget(
        _wrap(const CalendarEditorScreen(), notifier: notifier),
      );
      await tester.enterText(find.byType(TextField).first, 'Calendario 2026');

      await tester.tap(find.text('Guardar Calendario'));
      await tester.pump();

      expect(find.textContaining('Error al guardar:'), findsOneWidget);
      expect(find.text('Nuevo Calendario'), findsOneWidget);
    });

    testWidgets('cancelar vuelve atrás', (tester) async {
      await tester.pumpWidget(
        _wrapPushedEditor(const CalendarEditorScreen()),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Abrir'), findsOneWidget);
    });

    testWidgets('evita doble submit mientras guarda', (tester) async {
      final saveCompleter = Completer<String>();
      final notifier = _FakeCalendarManagement(saveCompleter: saveCompleter);

      await tester.pumpWidget(
        _wrap(const CalendarEditorScreen(), notifier: notifier),
      );
      await tester.enterText(find.byType(TextField).first, 'Calendario 2026');

      await tester.tap(find.text('Guardar Calendario'));
      await tester.tap(find.text('Guardar Calendario'), warnIfMissed: false);
      await tester.pump();

      expect(notifier.saveCalls, hasLength(1));
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      saveCompleter.complete('created-calendar');
      await tester.pumpAndSettle();
    });
  });
}
