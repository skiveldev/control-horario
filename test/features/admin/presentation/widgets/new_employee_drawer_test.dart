import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:control_horario/core/services/firebase_service.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/admin/presentation/widgets/new_employee_drawer.dart';
import 'package:control_horario/features/admin/providers/supervisors_provider.dart';
import 'package:control_horario/features/admin/providers/schedule_management_provider.dart';
import 'package:control_horario/features/admin/providers/calendar_management_provider.dart';
import 'package:control_horario/features/admin/providers/user_management_provider.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// FAKE FIREBASE CLASSES — avoid real Firebase initialization in tests
// =============================================================================

class _FakeFirebaseFirestore extends Fake implements FirebaseFirestore {}
class _FakeFirebaseAuth extends Fake implements FirebaseAuth {}

/// Spy on [EmployeeCreationService.createEmployee] calls.
class _SpyEmployeeCreationService extends EmployeeCreationService {
  _SpyEmployeeCreationService()
      : super(
          firestore: _FakeFirebaseFirestore(),
          auth: _FakeFirebaseAuth(),
        );

  final List<_CreateCall> calls = [];
  Map<String, String>? _nextResult;

  void setNextResult(Map<String, String>? result) => _nextResult = result;

  @override
  Future<Map<String, String>> createEmployee({
    required String email,
    required String nombre,
    required String apellido1,
    String? apellido2,
    String? employeeId,
    double? weeklyHours,
    String? dni,
    String? telefono,
    String? cargo,
    String? departamento,
    String? empresa,
    String? scheduleId,
    String? calendarId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    UserRole role = UserRole.employee,
    bool isSupervisor = false,
    String? supervisorId,
    bool isActive = true,
  }) async {
    calls.add(_CreateCall(
      email: email,
      nombre: nombre,
      apellido1: apellido1,
      weeklyHours: weeklyHours,
      fechaFin: fechaFin,
    ));
    if (_nextResult != null) return _nextResult!;
    return {
      'userId': 'test-new-001',
      'temporaryPassword': 'Temp-Test-1234',
    };
  }
}

class _CreateCall {
  final String email;
  final String nombre;
  final String apellido1;
  final double? weeklyHours;
  final DateTime? fechaFin;

  _CreateCall({
    required this.email,
    required this.nombre,
    required this.apellido1,
    this.weeklyHours,
    this.fechaFin,
  });
}

// =============================================================================
// FAKE ADMIN USER
// =============================================================================

final _fakeAdmin = UserModel(
  userId: 'admin-test',
  employeeId: 'admin-test',
  email: 'admin@test.com',
  displayName: 'Admin Test',
  role: UserRole.admin,
  weeklyHours: 40,
  createdAt: DateTime(2026),
);

// =============================================================================
// HELPERS
// =============================================================================

void _setDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void _setMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Builds the drawer with all providers overridden so no real Firebase
/// or auth calls are made.
Widget _buildDrawer({
  bool isOpen = true,
  Key? drawerKey,
  VoidCallback? onClose,
  VoidCallback? onEmployeeCreated,
  _SpyEmployeeCreationService? spyService,
  Map<String, String>? createResult,
}) {
  final spy = spyService ?? _SpyEmployeeCreationService();
  spy.setNextResult(createResult ?? {
    'userId': 'test-new-001',
    'temporaryPassword': 'Temp-Test-1234',
  });

  return ProviderScope(
    overrides: [
      supervisorsProvider.overrideWith((ref) => Stream.value(const [])),
      allScheduleTemplatesProvider.overrideWith(
        (ref) => Stream.value(const []),
      ),
      allCalendarsProvider.overrideWith(
        (ref) => Stream.value(const []),
      ),
      currentUserProvider.overrideWith((ref) => Stream.value(_fakeAdmin)),
      employeeCreationServiceProvider.overrideWith((ref) => spy),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: NewEmployeeDrawer(
          key: drawerKey,
          isOpen: isOpen,
          onClose: onClose ?? () {},
          onEmployeeCreated: onEmployeeCreated,
        ),
      ),
    ),
  );
}

/// Enter mandatory fields so form validation passes the required-field checks.
/// Field index: 0=Nombre, 1=Apellido1, 5=Email
Future<void> fillRequiredFields(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'María');
  await tester.enterText(fields.at(1), 'García');
  await tester.enterText(fields.at(5), 'test@test.com');
}

/// Finds a Text widget whose `data` matches exactly.
Finder errorTextFinder(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data == text,
  );
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  // ===========================================================================
  // 1. FORMAT CREDENTIALS (existing — pure function, no Firebase)
  // ===========================================================================
  group('formatTemporaryCredentialsForClipboard', () {
    test('formats email and temporary password for clipboard', () {
      final credentials = formatTemporaryCredentialsForClipboard(
        email: 'employee@example.com',
        temporaryPassword: 'Temp-1234',
      );

      expect(
        credentials,
        'Email: employee@example.com\nContraseña temporal: Temp-1234',
      );
    });
  });

  // ===========================================================================
  // 2. WEEKLY HOURS — VALIDATION (error display on invalid input)
  // ===========================================================================
  group('Weekly hours validation errors', () {
    testWidgets('invalid text "abc" shows error on submit', (tester) async {
      _setDesktopViewport(tester);
      final spy = _SpyEmployeeCreationService();

      await tester.pumpWidget(_buildDrawer(spyService: spy));
      await tester.pumpAndSettle();

      await fillRequiredFields(tester);

      final whField = tester.widget<TextFormField>(
        find.byKey(const Key('weeklyHoursField')),
      );
      whField.controller!.text = 'abc';

      await tester.tap(find.text('Guardar'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(errorTextFinder('Ingrese un número válido'), findsOneWidget);
      // Must NOT have called createEmployee
      expect(spy.calls.length, 0);
    });

    testWidgets('zero value shows error on submit', (tester) async {
      _setDesktopViewport(tester);
      final spy = _SpyEmployeeCreationService();

      await tester.pumpWidget(_buildDrawer(spyService: spy));
      await tester.pumpAndSettle();

      await fillRequiredFields(tester);

      final whField = tester.widget<TextFormField>(
        find.byKey(const Key('weeklyHoursField')),
      );
      whField.controller!.text = '0';

      await tester.tap(find.text('Guardar'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(errorTextFinder('Debe ser mayor que 0'), findsOneWidget);
      expect(spy.calls.length, 0);
    });

    testWidgets('negative value shows error on submit', (tester) async {
      _setDesktopViewport(tester);
      final spy = _SpyEmployeeCreationService();

      await tester.pumpWidget(_buildDrawer(spyService: spy));
      await tester.pumpAndSettle();

      await fillRequiredFields(tester);

      final whField = tester.widget<TextFormField>(
        find.byKey(const Key('weeklyHoursField')),
      );
      whField.controller!.text = '-5';

      await tester.tap(find.text('Guardar'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(errorTextFinder('Debe ser mayor que 0'), findsOneWidget);
      expect(spy.calls.length, 0);
    });

    testWidgets('empty field does not show error', (tester) async {
      _setDesktopViewport(tester);

      await tester.pumpWidget(_buildDrawer());
      await tester.pumpAndSettle();

      expect(errorTextFinder('Ingrese un número válido'), findsNothing);
      expect(errorTextFinder('Debe ser mayor que 0'), findsNothing);
    });

    testWidgets('valid decimal value does not show weekly hours error', (
      tester,
    ) async {
      _setDesktopViewport(tester);

      await tester.pumpWidget(_buildDrawer());
      await tester.pumpAndSettle();

      await fillRequiredFields(tester);

      final whField = tester.widget<TextFormField>(
        find.byKey(const Key('weeklyHoursField')),
      );
      whField.controller!.text = '37.5';

      // Just verify no error appears — don't submit (that would trigger create)
      await tester.tap(find.text('Guardar'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(errorTextFinder('Ingrese un número válido'), findsNothing);
      expect(errorTextFinder('Debe ser mayor que 0'), findsNothing);
    });
  });

  // ===========================================================================
  // 3. WEEKLY HOURS — PAYLOAD CONTRACT (assert value passed to service)
  // ===========================================================================
  group('Weekly hours payload contract', () {
    testWidgets('empty field submits with default 40.0', (tester) async {
      _setDesktopViewport(tester);
      final spy = _SpyEmployeeCreationService();
      var closed = false;

      await tester.pumpWidget(_buildDrawer(
        spyService: spy,
        onClose: () => closed = true,
      ));
      await tester.pumpAndSettle();

      await fillRequiredFields(tester);

      // Submit — service should receive weeklyHours = 40.0
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(spy.calls.length, 1);
      expect(spy.calls.first.weeklyHours, 40.0);
    });

    testWidgets('valid decimal submits the parsed value', (tester) async {
      _setDesktopViewport(tester);
      final spy = _SpyEmployeeCreationService();
      var closed = false;

      await tester.pumpWidget(_buildDrawer(
        spyService: spy,
        onClose: () => closed = true,
      ));
      await tester.pumpAndSettle();

      await fillRequiredFields(tester);

      final whField = tester.widget<TextFormField>(
        find.byKey(const Key('weeklyHoursField')),
      );
      whField.controller!.text = '37.5';

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(spy.calls.length, 1);
      expect(spy.calls.first.weeklyHours, 37.5);
    });

    testWidgets('invalid value blocks createEmployee call entirely', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      final spy = _SpyEmployeeCreationService();

      await tester.pumpWidget(_buildDrawer(spyService: spy));
      await tester.pumpAndSettle();

      await fillRequiredFields(tester);

      final whField = tester.widget<TextFormField>(
        find.byKey(const Key('weeklyHoursField')),
      );
      whField.controller!.text = 'abc';

      await tester.tap(find.text('Guardar'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Validation blocked submission — spy must have zero calls
      expect(spy.calls.length, 0);
    });
  });

  // ===========================================================================
  // 4. DOUBLE-SUBMIT PREVENTION
  // ===========================================================================
  group('Double-submit prevention', () {
    // -------------------------------------------------------------------------
    // 4a. PENDING REQUEST: second tap blocked, loading UI visible, clean finish
    // -------------------------------------------------------------------------
    testWidgets('second tap blocked while request is pending, completes cleanly',
        (tester) async {
      _setDesktopViewport(tester);
      final completer = Completer<Map<String, String>>();
      addTearDown(() {
        if (!completer.isCompleted) {
          completer.complete({'userId': 'cleanup', 'temporaryPassword': 'cleanup'});
        }
      });

      final spy = _CompleterService(completer);
      var closed = false;

      await tester.pumpWidget(_buildDrawer(
        spyService: spy,
        onClose: () => closed = true,
      ));
      await tester.pumpAndSettle();
      await fillRequiredFields(tester);

      // ---- first tap starts creation, request stays pending ----
      await tester.tap(find.text('Guardar'));

      // ---- second tap BEFORE pump: widget still shows 'Guardar' text,
      //      but _isSubmitting is already true so the handler short-circuits ----
      await tester.tap(find.text('Guardar'));

      // ---- pump to process state changes and render loading UI ----
      await tester.pump();

      // Only one call — second tap was blocked by _isSubmitting guard
      expect(spy.calls.length, 1);

      // Buttons show loading state: text replaced by spinners
      expect(find.text('Guardar'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // ---- complete the pending request ----
      completer.complete({
        'userId': 'test-001',
        'temporaryPassword': 'Temp-1234',
      });
      await tester.pumpAndSettle();

      // Still only one call — no extras leaked through
      expect(spy.calls.length, 1);
      // Drawer signaled to close
      expect(closed, true);
    });

    // -------------------------------------------------------------------------
    // 4b. CROSS-BUTTON GUARD: Guardar blocks Guardar y Añadir while pending
    // -------------------------------------------------------------------------
    testWidgets('Guardar and Guardar y Añadir block each other while pending',
        (tester) async {
      _setDesktopViewport(tester);
      final completer = Completer<Map<String, String>>();
      addTearDown(() {
        if (!completer.isCompleted) {
          completer.complete({'userId': 'cleanup', 'temporaryPassword': 'cleanup'});
        }
      });

      final spy = _CompleterService(completer);

      await tester.pumpWidget(_buildDrawer(spyService: spy));
      await tester.pumpAndSettle();
      await fillRequiredFields(tester);

      // Tap Guardar → request stays pending (_isSubmitting = true)
      await tester.tap(find.text('Guardar'));

      // Tap Guardar y Añadir BEFORE pump → _saveAndAddAnother checks _isSubmitting → returns
      await tester.tap(find.text('Guardar y Añadir'));

      await tester.pump();

      // Only the first tap created a call
      expect(spy.calls.length, 1);

      // Clean up
      completer.complete({
        'userId': 'test-002',
        'temporaryPassword': 'Temp-5678',
      });
      await tester.pumpAndSettle();
    });

    // -------------------------------------------------------------------------
    // 4c. LOADING UI: buttons disabled, spinners visible, no text
    // -------------------------------------------------------------------------
    testWidgets('buttons show loading spinners and are disabled during submission',
        (tester) async {
      _setDesktopViewport(tester);
      final completer = Completer<Map<String, String>>();
      addTearDown(() {
        if (!completer.isCompleted) {
          completer.complete({'userId': 'cleanup', 'temporaryPassword': 'cleanup'});
        }
      });

      final spy = _CompleterService(completer);

      await tester.pumpWidget(_buildDrawer(spyService: spy));
      await tester.pumpAndSettle();
      await fillRequiredFields(tester);

      // Tap Guardar to trigger submission
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // Button text is replaced by CircularProgressIndicator while loading
      expect(find.text('Guardar'), findsNothing);
      expect(find.text('Guardar y Añadir'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Only one call was made
      expect(spy.calls.length, 1);

      // Complete request to let test finish without timer leaks
      completer.complete({
        'userId': 'test-003',
        'temporaryPassword': 'Temp-9012',
      });
      await tester.pumpAndSettle();

      // Still exactly one call
      expect(spy.calls.length, 1);
    });
  });

  // ===========================================================================
  // 5. FECHA FIN RESET BEHAVIOR
  // ===========================================================================
  group('fechaFin reset behavior', () {
    testWidgets('fechaFin displays "Sin definir" when null', (tester) async {
      _setDesktopViewport(tester);

      await tester.pumpWidget(_buildDrawer());
      await tester.pumpAndSettle();

      // Initial state has fechaFin = null
      expect(find.text('Sin definir'), findsOneWidget);
    });

    testWidgets('fechaFin clear icon resets to null', (tester) async {
      _setDesktopViewport(tester);

      await tester.pumpWidget(_buildDrawer());
      await tester.pumpAndSettle();

      // Scroll the SingleChildScrollView so the fechaFin row is visible
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -800),
      );
      await tester.pumpAndSettle();

      // Tap fechaFin date picker area (the InkWell containing calendar icon)
      await tester.tap(find.byIcon(Icons.event_busy));
      await tester.pumpAndSettle();

      // The Material 3 date picker dialog has a confirm button.
      // Flutter 3.x uses a TextButton with "OK" for the confirm action.
      final okButton = find.widgetWithText(TextButton, 'OK');
      final cancelButton = find.widgetWithText(TextButton, 'Cancel');
      final confirmButton = okButton.evaluate().isNotEmpty
          ? okButton
          : find.text('OK');

      if (confirmButton.evaluate().isNotEmpty) {
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();
      }

      // fechaFin should now show a date (not "Sin definir")
      // NOTE: after picking a date, the footer might be off-screen again
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sin definir'), findsNothing);

      // Tap the clear icon next to fechaFin
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // fechaFin should be reset to null, showing "Sin definir"
      expect(find.text('Sin definir'), findsOneWidget);
    });

    testWidgets(
        'changing fechaInicio after fechaFin clears fechaFin when '
        'end is before new start', (tester) async {
      _setDesktopViewport(tester);

      final drawerKey = GlobalKey();
      await tester.pumpWidget(_buildDrawer(drawerKey: drawerKey));
      await tester.pumpAndSettle();

      // ---- Step 1: Set a valid fechaFin via test-only setter ----
      final state = drawerKey.currentState! as dynamic;
      state.debugSetFechaFin(DateTime(2026, 12, 31));
      await tester.pumpAndSettle();

      // Scroll to fechaFin area and verify it shows the date (not "Sin definir")
      await tester.ensureVisible(find.byKey(const Key('fechaFinDisplay')));
      await tester.pumpAndSettle();
      expect(find.text('Sin definir'), findsNothing);
      expect(find.text('31/12/2026'), findsOneWidget);

      // ---- Step 2: Change fechaInicio to AFTER fechaFin ----
      // This MUST clear fechaFin (production contract from date picker callback)
      state.debugSetFechaInicio(DateTime(2027, 3, 15));
      await tester.pumpAndSettle();

      // ---- Step 3: Verify fechaFin was auto-cleared ----
      await tester.ensureVisible(find.byKey(const Key('fechaFinDisplay')));
      await tester.pumpAndSettle();

      // fechaFin is now null → UI shows "Sin definir"
      expect(find.text('Sin definir'), findsOneWidget);
      // The old date text must NOT appear
      expect(find.text('31/12/2026'), findsNothing);
    });
  });

  // ===========================================================================
  // 6. MOBILE FOOTER RESPONSIVENESS
  // ===========================================================================
  group('Mobile footer responsiveness', () {
    testWidgets('footer uses Wrap on narrow widths', (tester) async {
      _setMobileViewport(tester);

      await tester.pumpWidget(_buildDrawer());
      await tester.pumpAndSettle();

      // All three buttons present on mobile
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Guardar y Añadir'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);

      // Wrap used for responsive footer (not Row on mobile)
      expect(find.byType(Wrap), findsWidgets);
    });

    testWidgets('footer uses Row on desktop widths', (tester) async {
      _setDesktopViewport(tester);

      await tester.pumpWidget(_buildDrawer());
      await tester.pumpAndSettle();

      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Guardar y Añadir'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);

      expect(find.byType(Row), findsWidgets);
    });
  });

  // ===========================================================================
  // 7. HELPER TEXT CLARITY
  // ===========================================================================
  group('Helper text clarity', () {
    testWidgets('does not imply automatic calculation', (tester) async {
      _setDesktopViewport(tester);

      await tester.pumpWidget(_buildDrawer());
      await tester.pumpAndSettle();

      // Old misleading text should NOT appear
      expect(
        find.textContaining('calculan automáticamente'),
        findsNothing,
      );

      // New clear helper should be present
      expect(
        find.textContaining('40h/semana por defecto'),
        findsOneWidget,
      );
      expect(
        find.textContaining('contrato indefinido'),
        findsOneWidget,
      );
    });
  });

  // ===========================================================================
  // 8. STRUCTURAL INTEGRITY
  // ===========================================================================
  group('Structural integrity', () {
    testWidgets('drawer renders header, sections, and footer', (tester) async {
      _setDesktopViewport(tester);

      await tester.pumpWidget(_buildDrawer());
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Trabajador'), findsOneWidget);
      expect(find.text('Información Personal'), findsOneWidget);
      expect(find.text('Información Laboral'), findsOneWidget);
      expect(find.text('Control Horario'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
      expect(find.text('Guardar y Añadir'), findsOneWidget);
    });

    testWidgets('drawer is hidden when isOpen is false', (tester) async {
      await tester.pumpWidget(_buildDrawer(isOpen: false));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Trabajador'), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}

// =============================================================================
// COMPLETER-BASED SERVICE — stays pending until explicitly resolved (no timer leak)
// =============================================================================

class _CompleterService extends _SpyEmployeeCreationService {
  _CompleterService(this._completer);
  final Completer<Map<String, String>> _completer;

  @override
  Future<Map<String, String>> createEmployee({
    required String email,
    required String nombre,
    required String apellido1,
    String? apellido2,
    String? employeeId,
    double? weeklyHours,
    String? dni,
    String? telefono,
    String? cargo,
    String? departamento,
    String? empresa,
    String? scheduleId,
    String? calendarId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    UserRole role = UserRole.employee,
    bool isSupervisor = false,
    String? supervisorId,
    bool isActive = true,
  }) async {
    calls.add(_CreateCall(
      email: email,
      nombre: nombre,
      apellido1: apellido1,
      weeklyHours: weeklyHours,
      fechaFin: fechaFin,
    ));
    // Wait for external resolution — no timer leak
    return _completer.future;
  }
}
