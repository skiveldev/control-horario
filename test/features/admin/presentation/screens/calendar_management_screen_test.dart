import 'package:control_horario/core/router/app_router.dart';
import 'package:control_horario/features/admin/models/calendar_event_model.dart';
import 'package:control_horario/features/admin/models/holiday_type.dart';
import 'package:control_horario/features/admin/models/work_calendar_model.dart';
import 'package:control_horario/features/admin/presentation/screens/calendar_management_screen.dart';
import 'package:control_horario/features/admin/presentation/widgets/calendar_card.dart';
import 'package:control_horario/features/admin/providers/calendar_management_provider.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// =============================================================================
// FAKE DATA
// =============================================================================

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

WorkCalendarModel _fakeCalendar({
  required String id,
  required String name,
  required int year,
  bool isActive = true,
  int nationalCount = 2,
  int regionalCount = 1,
  int vacationCount = 1,
}) {
  final events = <CalendarEventModel>[
    for (int i = 0; i < nationalCount; i++)
      CalendarEventModel(
        id: '${id}_n$i',
        name: 'Festivo $i',
        date: DateTime(year, 1, 1 + i),
        type: HolidayType.national,
      ),
    for (int i = 0; i < regionalCount; i++)
      CalendarEventModel(
        id: '${id}_r$i',
        name: 'Regional $i',
        date: DateTime(year, 4, 1 + i),
        type: HolidayType.regional,
      ),
    for (int i = 0; i < vacationCount; i++)
      CalendarEventModel(
        id: '${id}_v$i',
        name: 'Vacaciones $i',
        date: DateTime(year, 8, 1 + i),
        type: HolidayType.vacation,
      ),
  ];

  return WorkCalendarModel(
    id: id,
    name: name,
    year: year,
    events: events,
    isActive: isActive,
  );
}

// =============================================================================
// FAKE CALENDAR MANAGEMENT (records calls, no Firebase)
// =============================================================================

/// Drop-in fake that extends the real notifier but replaces all Firebase-backed
/// methods with in-memory recording so widget tests are deterministic.
class FakeCalendarManagement extends CalendarManagement {
  final List<String> duplicateCalls = [];
  final List<String> deleteCalls = [];

  @override
  void build() {
    // No-op — avoids Firebase dependencies in the real build() path.
  }

  @override
  Future<String> duplicateCalendar(String calendarId) async {
    duplicateCalls.add(calendarId);
    return 'duplicated-$calendarId';
  }

  @override
  Future<void> deleteCalendar(String calendarId) async {
    deleteCalls.add(calendarId);
    // Success — no exception.
  }
}

// =============================================================================
// HELPERS
// =============================================================================

/// Sets up a tall viewport so the full calendar content (including action
/// buttons) fits on screen without scrolling.
void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

// =============================================================================
// HELPERS — static render (no GoRouter needed)
// =============================================================================

Widget _wrapApp({
  required List<WorkCalendarModel> calendars,
  List<Override>? extraOverrides,
}) {
  return ProviderScope(
    overrides: [
      allCalendarsProvider.overrideWith(
        (ref) => Stream.value(calendars),
      ),
      currentUserProvider.overrideWith(
        (ref) => Stream.value(_fakeAdminUser),
      ),
      if (extraOverrides != null) ...extraOverrides,
    ],
    child: const MaterialApp(
      home: CalendarManagementScreen(),
    ),
  );
}

Widget _wrapAppLoading() {
  return ProviderScope(
    overrides: [
      allCalendarsProvider.overrideWith(
        (ref) => const Stream<List<WorkCalendarModel>>.empty(),
      ),
      currentUserProvider.overrideWith(
        (ref) => Stream.value(_fakeAdminUser),
      ),
    ],
    child: const MaterialApp(
      home: CalendarManagementScreen(),
    ),
  );
}

Widget _wrapAppError() {
  return ProviderScope(
    overrides: [
      allCalendarsProvider.overrideWith(
        (ref) => Stream<List<WorkCalendarModel>>.error(
          'Firestore connection failed',
        ),
      ),
      currentUserProvider.overrideWith(
        (ref) => Stream.value(_fakeAdminUser),
      ),
    ],
    child: const MaterialApp(
      home: CalendarManagementScreen(),
    ),
  );
}

// =============================================================================
// HELPERS — interactive (GoRouter + fake provider)
// =============================================================================

/// Builds a widget tree with a real GoRouter so navigation side-effects
/// (`context.go`) are exercised and observable.
Widget _wrapWithRouter({
  required List<WorkCalendarModel> calendars,
  FakeCalendarManagement? fakeNotifier,
}) {
  final router = GoRouter(
    initialLocation: AppRouter.adminCalendars,
    routes: [
      GoRoute(
        path: AppRouter.adminCalendars,
        name: 'admin-calendars',
        builder: (context, state) => ProviderScope(
          overrides: [
            allCalendarsProvider.overrideWith(
              (ref) => Stream.value(calendars),
            ),
            currentUserProvider.overrideWith(
              (ref) => Stream.value(_fakeAdminUser),
            ),
            if (fakeNotifier != null)
              calendarManagementProvider.overrideWith(
                () => fakeNotifier,
              ),
          ],
          child: const CalendarManagementScreen(),
        ),
      ),
      GoRoute(
        path: AppRouter.adminCalendarEditor,
        name: 'admin-calendar-editor',
        builder: (context, state) {
          final calendar = state.extra as WorkCalendarModel?;
          return Scaffold(
            body: Center(
              child: Text(
                calendar != null ? 'Edit: ${calendar.name}' : 'New Calendar',
              ),
            ),
          );
        },
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

// =============================================================================
// TESTS — static render states
// =============================================================================

void main() {
  group('CalendarManagementScreen', () {
    // ── Content state ───────────────────────────────────────────────────

    testWidgets('muestra título y subtítulo', (tester) async {
      _setTallViewport(tester);
      final calendars = [
        _fakeCalendar(
            id: 'c1',
            name: 'Madrid 2025',
            year: 2025,
            nationalCount: 10,
            regionalCount: 4,
            vacationCount: 22),
      ];

      await tester.pumpWidget(_wrapApp(calendars: calendars));
      await tester.pumpAndSettle();

      expect(find.text('Calendarios Laborales'), findsOneWidget);
      expect(find.text('Panel de administración'), findsOneWidget);
      expect(
        find.text(
          'Gestiona festivos nacionales, autonómicos, locales y '
          'vacaciones. 1 calendario configurado.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('el botón Nuevo Calendario está presente', (tester) async {
      _setTallViewport(tester);
      final calendars = [
        _fakeCalendar(
            id: 'c1',
            name: 'Madrid 2025',
            year: 2025,
            nationalCount: 10,
            regionalCount: 4,
            vacationCount: 22),
      ];

      await tester.pumpWidget(_wrapApp(calendars: calendars));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Calendario'), findsOneWidget);
    });

    testWidgets('muestra stats row con datos honestos', (tester) async {
      _setTallViewport(tester);
      final calendars = [
        _fakeCalendar(
          id: 'c1',
          name: 'Madrid 2025',
          year: 2025,
          nationalCount: 10,
          regionalCount: 4,
          vacationCount: 22,
        ),
        _fakeCalendar(
          id: 'c2',
          name: 'Cataluña 2025',
          year: 2025,
          isActive: false,
          nationalCount: 8,
          regionalCount: 3,
          vacationCount: 18,
        ),
      ];

      await tester.pumpWidget(_wrapApp(calendars: calendars));
      await tester.pumpAndSettle();

      // Total: 2
      expect(find.text('2'), findsWidgets);
      // Active: 1
      expect(find.text('1'), findsWidgets);
      // Total holidays: 10+4+8+3 = 25
      expect(find.text('25'), findsOneWidget);
      // Total vacation days: 22+18 = 40
      expect(find.text('40 días'), findsOneWidget);
    });

    testWidgets('renderiza CalendarCard por cada calendario', (tester) async {
      _setTallViewport(tester);
      final calendars = [
        _fakeCalendar(
            id: 'c1',
            name: 'Madrid 2025',
            year: 2025,
            nationalCount: 10,
            regionalCount: 4,
            vacationCount: 22),
        _fakeCalendar(
            id: 'c2',
            name: 'Cataluña 2025',
            year: 2025,
            nationalCount: 10,
            regionalCount: 4,
            vacationCount: 22),
        _fakeCalendar(
            id: 'c3',
            name: 'Remoto 2025',
            year: 2025,
            isActive: false,
            nationalCount: 10,
            regionalCount: 4,
            vacationCount: 22),
      ];

      await tester.pumpWidget(_wrapApp(calendars: calendars));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarCard), findsNWidgets(3));
      expect(find.text('Madrid 2025'), findsOneWidget);
      expect(find.text('Cataluña 2025'), findsOneWidget);
      expect(find.text('Remoto 2025'), findsOneWidget);
    });

    testWidgets('muestra badge Activo/Borrador según estado', (tester) async {
      _setTallViewport(tester);
      final calendars = [
        _fakeCalendar(
            id: 'c1',
            name: 'Madrid 2025',
            year: 2025,
            isActive: true,
            nationalCount: 10,
            regionalCount: 4,
            vacationCount: 22),
        _fakeCalendar(
            id: 'c2',
            name: 'Borrador 2025',
            year: 2025,
            isActive: false,
            nationalCount: 10,
            regionalCount: 4,
            vacationCount: 22),
      ];

      await tester.pumpWidget(_wrapApp(calendars: calendars));
      await tester.pumpAndSettle();

      expect(find.text('Activo'), findsOneWidget);
      expect(find.text('Borrador'), findsOneWidget);
    });

    // ── Empty state ─────────────────────────────────────────────────────

    testWidgets('muestra empty state cuando no hay calendarios',
        (tester) async {
      await tester.pumpWidget(_wrapApp(calendars: []));
      await tester.pumpAndSettle();

      expect(find.text('No hay calendarios disponibles'), findsOneWidget);
      expect(find.text('Crear Primer Calendario'), findsOneWidget);
    });

    // ── Loading state ───────────────────────────────────────────────────

    testWidgets('muestra loading indicator mientras carga', (tester) async {
      await tester.pumpWidget(_wrapAppLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ── Error state ─────────────────────────────────────────────────────

    testWidgets('muestra mensaje de error cuando falla la carga',
        (tester) async {
      await tester.pumpWidget(_wrapAppError());
      await tester.pumpAndSettle();

      expect(find.text('Error al cargar calendarios'), findsOneWidget);
      expect(find.text('Firestore connection failed'), findsOneWidget);
    });

    // ── Info card ───────────────────────────────────────────────────────

    testWidgets('muestra info card con ayuda contextual', (tester) async {
      _setTallViewport(tester);
      final calendars = [
        _fakeCalendar(
            id: 'c1',
            name: 'Madrid 2025',
            year: 2025,
            nationalCount: 10,
            regionalCount: 4,
            vacationCount: 22),
      ];

      await tester.pumpWidget(_wrapApp(calendars: calendars));
      await tester.pumpAndSettle();

      expect(
        find.text('¿Cómo funcionan los calendarios laborales?'),
        findsOneWidget,
      );
    });
  });

  // ===========================================================================
  // TESTS — interactive actions (navigation, duplication, deletion)
  // ===========================================================================

  group('CalendarManagementScreen actions', () {
    // ── Navigation: Nuevo Calendario ────────────────────────────────────

    testWidgets('tapping Nuevo Calendario navigates to new-calendar editor',
        (tester) async {
      _setTallViewport(tester);
      final calendars = [
        _fakeCalendar(id: 'c1', name: 'Madrid 2025', year: 2025),
      ];

      await tester.pumpWidget(
        _wrapWithRouter(calendars: calendars),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Calendario'), findsOneWidget);
      await tester.tap(find.text('Nuevo Calendario'));
      await tester.pumpAndSettle();

      expect(find.text('New Calendar'), findsOneWidget);
    });

    // ── Navigation: Edit calendar ───────────────────────────────────────

    testWidgets(
        'tapping Editar on a calendar navigates to edit-calendar editor',
        (tester) async {
      _setTallViewport(tester);
      final calendars = [
        _fakeCalendar(id: 'c1', name: 'Madrid 2025', year: 2025),
      ];

      await tester.pumpWidget(
        _wrapWithRouter(calendars: calendars),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsOneWidget);
      await tester.ensureVisible(find.text('Editar'));
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      expect(find.text('Edit: Madrid 2025'), findsOneWidget);
      expect(find.text('New Calendar'), findsNothing);
    });

    // ── Duplicate action ────────────────────────────────────────────────

    testWidgets(
      'tapping Duplicar invokes duplicateCalendar and shows success snackbar',
      (tester) async {
        _setTallViewport(tester);
        final fake = FakeCalendarManagement();
        final calendars = [
          _fakeCalendar(id: 'c1', name: 'Madrid 2025', year: 2025),
        ];

        await tester.pumpWidget(
          _wrapWithRouter(calendars: calendars, fakeNotifier: fake),
        );
        await tester.pumpAndSettle();

        expect(find.text('Duplicar'), findsOneWidget);
        await tester.ensureVisible(find.text('Duplicar'));
        await tester.tap(find.text('Duplicar'));
        await tester.pumpAndSettle();

        expect(fake.duplicateCalls, contains('c1'));
        expect(fake.duplicateCalls.length, 1);

        expect(
          find.text('Calendario "Madrid 2025" duplicado'),
          findsOneWidget,
        );
      },
    );

    // ── Delete: confirmation dialog opens ───────────────────────────────

    testWidgets('tapping Eliminar opens confirmation dialog', (tester) async {
      _setTallViewport(tester);
      final fake = FakeCalendarManagement();
      final calendars = [
        _fakeCalendar(id: 'c1', name: 'Madrid 2025', year: 2025),
      ];

      await tester.pumpWidget(
        _wrapWithRouter(calendars: calendars, fakeNotifier: fake),
      );
      await tester.pumpAndSettle();

      expect(find.text('Eliminar'), findsOneWidget);
      await tester.ensureVisible(find.text('Eliminar'));
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Eliminar calendario'), findsOneWidget);
      // Use exact match to avoid ambiguity with the card title
      expect(
        find.text('¿Estás seguro de que quieres eliminar "Madrid 2025"?\n\n'
            'Los empleados asignados a este calendario quedarán sin calendario.'),
        findsOneWidget,
      );
      expect(find.text('Cancelar'), findsOneWidget);
      // Delete has not been called yet
      expect(fake.deleteCalls, isEmpty);
    });

    // ── Delete: confirming the dialog ───────────────────────────────────

    testWidgets(
      'confirming delete in dialog invokes deleteCalendar on provider',
      (tester) async {
        _setTallViewport(tester);
        final fake = FakeCalendarManagement();
        final calendars = [
          _fakeCalendar(id: 'c1', name: 'Madrid 2025', year: 2025),
        ];

        await tester.pumpWidget(
          _wrapWithRouter(calendars: calendars, fakeNotifier: fake),
        );
        await tester.pumpAndSettle();

        // Open the confirmation dialog
        await tester.ensureVisible(find.text('Eliminar'));
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // The dialog's confirm button is a FilledButton with text "Eliminar".
        // There are now TWO "Eliminar" widgets: the card action + the dialog
        // button. Tap the last one (the dialog's FilledButton).
        final eliminarButtons = find.text('Eliminar');
        expect(eliminarButtons, findsNWidgets(2));
        await tester.tap(eliminarButtons.last);
        await tester.pumpAndSettle();

        expect(fake.deleteCalls, contains('c1'));
        expect(fake.deleteCalls.length, 1);

        expect(
          find.text('Calendario "Madrid 2025" eliminado'),
          findsOneWidget,
        );
      },
    );

    // ── Constrained-width: header does not overflow ─────────────────────

    testWidgets(
      'header does not overflow on mobile width (360px)',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final calendars = [
          _fakeCalendar(
              id: 'c1', name: 'Madrid Metropolitano Norte 2025', year: 2025),
        ];

        await tester.pumpWidget(_wrapApp(calendars: calendars));
        await tester.pumpAndSettle();

        expect(find.text('Calendarios Laborales'), findsOneWidget);
        expect(find.text('Nuevo Calendario'), findsOneWidget);

        final overflowErrors = tester.takeException();
        expect(overflowErrors, isNull,
            reason: 'No RenderFlex overflow should occur at 360px width');
      },
    );

    testWidgets(
      'header does not overflow on tablet width (768px)',
      (tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final calendars = [
          _fakeCalendar(id: 'c1', name: 'Madrid 2025', year: 2025),
          _fakeCalendar(
              id: 'c2',
              name: 'Cataluña Barcelona 2025',
              year: 2025,
              isActive: false),
        ];

        await tester.pumpWidget(_wrapApp(calendars: calendars));
        await tester.pumpAndSettle();

        expect(find.text('Calendarios Laborales'), findsOneWidget);
        expect(find.text('Nuevo Calendario'), findsOneWidget);

        final overflowErrors = tester.takeException();
        expect(overflowErrors, isNull,
            reason: 'No RenderFlex overflow should occur at 768px width');
      },
    );

    // ── Cancelar delete: does not call deleteCalendar ───────────────────

    testWidgets(
      'cancelling delete dialog does not call deleteCalendar',
      (tester) async {
        _setTallViewport(tester);
        final fake = FakeCalendarManagement();
        final calendars = [
          _fakeCalendar(id: 'c1', name: 'Madrid 2025', year: 2025),
        ];

        await tester.pumpWidget(
          _wrapWithRouter(calendars: calendars, fakeNotifier: fake),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Eliminar'));
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        // Cancel the dialog
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(fake.deleteCalls, isEmpty);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    // ── Empty state: Crear Primer Calendario navigates ─────────────────

    testWidgets(
      'tapping Crear Primer Calendario in empty state navigates to editor',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithRouter(calendars: []),
        );
        await tester.pumpAndSettle();

        expect(find.text('Crear Primer Calendario'), findsOneWidget);
        await tester.tap(find.text('Crear Primer Calendario'));
        await tester.pumpAndSettle();

        expect(find.text('New Calendar'), findsOneWidget);
      },
    );
  });
}
