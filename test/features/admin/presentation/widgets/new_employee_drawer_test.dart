import 'dart:async';

import 'package:control_horario/core/services/provisioning_service.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/admin/presentation/widgets/new_employee_drawer.dart';
import 'package:control_horario/features/admin/providers/calendar_management_provider.dart';
import 'package:control_horario/features/admin/providers/schedule_management_provider.dart';
import 'package:control_horario/features/admin/providers/supervisors_provider.dart';
import 'package:control_horario/features/admin/providers/user_management_provider.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthUser extends Fake implements User {}

class _FakeTransport implements CallableTransport {
  @override
  Future<Object?> call(String name, Map<String, dynamic> payload) async => null;
}

class _FakeStorage implements ProvisioningOperationStorage {
  String? operationId;

  @override
  Future<String?> readOperationId() async => operationId;

  @override
  Future<void> saveOperationId(String value) async => operationId = value;
}

class _TerminalWorkflow extends ProvisioningWorkflow {
  _TerminalWorkflow(this.result)
      : super(
          ProvisioningService(_FakeTransport()),
          storage: _FakeStorage(),
          operationIdFactory: () => '00000000-0000-4000-8000-000000000001',
        );

  final ProvisioningResult result;
  final List<ProvisioningRequest> requests = [];
  int cancelCalls = 0;

  @override
  Future<ProvisioningResult> submit(ProvisioningRequestBuilder request) async {
    requests.add(request('00000000-0000-4000-8000-000000000001'));
    return result;
  }

  @override
  void cancel() {
    cancelCalls += 1;
    super.cancel();
  }
}

class _CompleterWorkflow extends _TerminalWorkflow {
  _CompleterWorkflow(this.completer)
      : super(const PendingProvisioningStatus(
          operationId: 'pending',
          retryAfterSeconds: 1,
        ));

  final Completer<ProvisioningResult> completer;

  @override
  Future<ProvisioningResult> submit(ProvisioningRequestBuilder request) {
    requests.add(request('00000000-0000-4000-8000-000000000001'));
    return completer.future;
  }
}

final _admin = UserModel(
  userId: 'admin',
  employeeId: 'admin',
  email: 'admin@example.com',
  displayName: 'Admin',
  role: UserRole.admin,
  weeklyHours: 40,
  createdAt: DateTime(2026),
);

Widget _drawer({
  required _TerminalWorkflow workflow,
  VoidCallback? onClose,
  VoidCallback? onEmployeeCreated,
  Key? drawerKey,
  bool isOpen = true,
  Stream<User?>? authStates,
  ValueNotifier<int>? workflowProviderReads,
}) {
  return ProviderScope(
    overrides: [
      provisioningWorkflowProvider.overrideWith((ref) {
        workflowProviderReads?.value += 1;
        return workflow;
      }),
      currentUserProvider.overrideWith((ref) => Stream.value(_admin)),
      authStateProvider.overrideWith(
        (ref) => authStates ?? Stream.value(_FakeAuthUser()),
      ),
      supervisorsProvider.overrideWith((ref) => Stream.value(const [])),
      allScheduleTemplatesProvider
          .overrideWith((ref) => Stream.value(const [])),
      allCalendarsProvider.overrideWith((ref) => Stream.value(const [])),
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

void _setDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void _setMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> _fillRequiredFields(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'María');
  await tester.enterText(fields.at(1), 'García');
  await tester.enterText(fields.at(5), 'maria@example.com');
}

void _setWeeklyHours(WidgetTester tester, String value) {
  tester
      .widget<TextFormField>(find.byKey(const Key('weeklyHoursField')))
      .controller!
      .text = value;
}

Finder _errorText(String text) => find.byWidgetPredicate(
      (widget) => widget is Text && widget.data == text,
    );

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  // Baseline contracts.
  testWidgets('baseline reset-link replaces temporary-credentials helper',
      (tester) async {
    final workflow = _TerminalWorkflow(
      const CompletedProvisioningStatus(
        operationId: 'operation-1',
        userId: 'user-1',
        passwordResetLink: 'https://reset.example/link',
      ),
    );
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Alta completada'), findsOneWidget);
    expect(find.text('https://reset.example/link'), findsOneWidget);
    expect(find.textContaining('Contraseña temporal'), findsNothing);
  });

  testWidgets('baseline invalid weekly-hours text blocks provisioning',
      (tester) async {
    final workflow = _TerminalWorkflow(const ProvisioningFailure.unknown());
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    _setWeeklyHours(tester, 'abc');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(_errorText('Ingrese un número válido'), findsOneWidget);
    expect(workflow.requests, isEmpty);
  });

  testWidgets('baseline zero weekly hours shows positive-hours error',
      (tester) async {
    final workflow = _TerminalWorkflow(const ProvisioningFailure.unknown());
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    _setWeeklyHours(tester, '0');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(_errorText('Debe ser mayor que 0'), findsOneWidget);
    expect(workflow.requests, isEmpty);
  });

  testWidgets('baseline negative weekly hours shows positive-hours error',
      (tester) async {
    final workflow = _TerminalWorkflow(const ProvisioningFailure.unknown());
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    _setWeeklyHours(tester, '-5');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(_errorText('Debe ser mayor que 0'), findsOneWidget);
    expect(workflow.requests, isEmpty);
  });

  testWidgets('baseline empty weekly hours has no validation error',
      (tester) async {
    await tester.pumpWidget(
      _drawer(workflow: _TerminalWorkflow(const ProvisioningFailure.unknown())),
    );
    await tester.pumpAndSettle();

    expect(_errorText('Ingrese un número válido'), findsNothing);
    expect(_errorText('Debe ser mayor que 0'), findsNothing);
  });

  testWidgets('baseline valid decimal weekly hours has no validation error',
      (tester) async {
    final workflow = _TerminalWorkflow(const ProvisioningFailure.unknown());
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    _setWeeklyHours(tester, '37.5');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(_errorText('Ingrese un número válido'), findsNothing);
    expect(_errorText('Debe ser mayor que 0'), findsNothing);
  });

  testWidgets('baseline default 40-hour payload reaches typed request',
      (tester) async {
    final workflow = _TerminalWorkflow(const ProvisioningFailure.unknown());
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(workflow.requests, hasLength(1));
    expect(workflow.requests.single.weeklyHours, 40.0);
  });

  testWidgets('baseline decimal weekly-hours payload reaches typed request',
      (tester) async {
    final workflow = _TerminalWorkflow(const ProvisioningFailure.unknown());
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    _setWeeklyHours(tester, '37.5');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(workflow.requests, hasLength(1));
    expect(workflow.requests.single.weeklyHours, 37.5);
  });

  testWidgets('baseline invalid payload blocks provisioning', (tester) async {
    final workflow = _TerminalWorkflow(const ProvisioningFailure.unknown());
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    _setWeeklyHours(tester, 'abc');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(workflow.requests, isEmpty);
  });

  testWidgets('baseline same-button double submit makes one completed request',
      (tester) async {
    final completer = Completer<ProvisioningResult>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(const ProvisioningFailure.unknown());
      }
    });
    final workflow = _CompleterWorkflow(completer);
    var closes = 0;
    await tester.pumpWidget(_drawer(
      workflow: workflow,
      onClose: () => closes += 1,
    ));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(workflow.requests, hasLength(1));
    completer.complete(const CompletedProvisioningStatus(
      operationId: 'operation-completed',
      userId: 'user-completed',
      passwordResetLink: 'https://reset.example/completed',
    ));
    await tester.pumpAndSettle();

    expect(workflow.requests, hasLength(1));
    expect(find.text('Alta completada'), findsOneWidget);
    await tester.tap(find.text('CERRAR'));
    await tester.pumpAndSettle();
    expect(closes, 1);
  });

  testWidgets('baseline cross-button guard blocks concurrent submission',
      (tester) async {
    final completer = Completer<ProvisioningResult>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(const ProvisioningFailure.unknown());
      }
    });
    final workflow = _CompleterWorkflow(completer);
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.tap(find.text('Guardar y Añadir'));
    await tester.pump();

    expect(workflow.requests, hasLength(1));
    completer.complete(const ProvisioningFailure.unavailable());
    await tester.pumpAndSettle();
    expect(workflow.requests, hasLength(1));
  });

  testWidgets('baseline loading UI keeps one request through completion',
      (tester) async {
    final completer = Completer<ProvisioningResult>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(const ProvisioningFailure.unknown());
      }
    });
    final workflow = _CompleterWorkflow(completer);
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(workflow.requests, hasLength(1));
    expect(find.text('Guardar'), findsNothing);
    expect(find.text('Guardar y Añadir'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    completer.complete(const ProvisioningFailure.unavailable());
    await tester.pumpAndSettle();
    expect(workflow.requests, hasLength(1));
  });

  testWidgets('baseline null end date displays undefined state',
      (tester) async {
    await tester.pumpWidget(
      _drawer(workflow: _TerminalWorkflow(const ProvisioningFailure.unknown())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin definir'), findsOneWidget);
  });

  testWidgets('baseline clear end date returns to undefined state',
      (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(_drawer(
      workflow: _TerminalWorkflow(const ProvisioningFailure.unknown()),
      drawerKey: key,
    ));
    await tester.pumpAndSettle();
    final state = key.currentState! as dynamic;
    state.debugSetFechaFin(DateTime(2026, 12, 31));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('fechaFinDisplay')));
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();

    expect(find.text('Sin definir'), findsOneWidget);
  });

  testWidgets('baseline later start date resets end date', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(_drawer(
      workflow: _TerminalWorkflow(const ProvisioningFailure.unknown()),
      drawerKey: key,
    ));
    await tester.pumpAndSettle();
    final state = key.currentState! as dynamic;
    state.debugSetFechaFin(DateTime(2026, 12, 31));
    state.debugSetFechaInicio(DateTime(2027, 3, 15));
    await tester.pumpAndSettle();

    expect(find.text('Sin definir'), findsOneWidget);
    expect(find.text('31/12/2026'), findsNothing);
  });

  testWidgets('baseline mobile footer retains responsive actions',
      (tester) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(
      _drawer(workflow: _TerminalWorkflow(const ProvisioningFailure.unknown())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Wrap), findsWidgets);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Guardar y Añadir'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('baseline desktop footer retains responsive actions',
      (tester) async {
    _setDesktopViewport(tester);
    await tester.pumpWidget(
      _drawer(workflow: _TerminalWorkflow(const ProvisioningFailure.unknown())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Row), findsWidgets);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Guardar y Añadir'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('baseline helper copy remains clear', (tester) async {
    await tester.pumpWidget(
      _drawer(workflow: _TerminalWorkflow(const ProvisioningFailure.unknown())),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('calculan automáticamente'), findsNothing);
    expect(find.textContaining('40h/semana por defecto'), findsOneWidget);
    expect(find.textContaining('contrato indefinido'), findsOneWidget);
  });

  testWidgets('baseline structural render includes header sections and footer',
      (tester) async {
    await tester.pumpWidget(
      _drawer(workflow: _TerminalWorkflow(const ProvisioningFailure.unknown())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Trabajador'), findsOneWidget);
    expect(find.text('Información Personal'), findsOneWidget);
    expect(find.text('Información Laboral'), findsOneWidget);
    expect(find.text('Control Horario'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Guardar y Añadir'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('baseline hidden drawer does not render content', (tester) async {
    await tester.pumpWidget(_drawer(
      isOpen: false,
      workflow: _TerminalWorkflow(const ProvisioningFailure.unknown()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo Trabajador'), findsNothing);
    expect(find.byType(SizedBox), findsOneWidget);
  });

  // P4.15-P4.16 operation and recovery contracts.
  testWidgets('P4 completed reset-link instructs administrator delivery',
      (tester) async {
    final workflow = _TerminalWorkflow(
      const CompletedProvisioningStatus(
        operationId: 'operation-1',
        userId: 'user-1',
        passwordResetLink: 'https://reset.example/link',
      ),
    );
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Copiá este enlace y entregáselo de forma segura al empleado.'),
      findsOneWidget,
    );
  });

  testWidgets('P4 completed reset-link copies to the clipboard',
      (tester) async {
    final workflow = _TerminalWorkflow(
      const CompletedProvisioningStatus(
        operationId: 'operation-1',
        userId: 'user-1',
        passwordResetLink: 'https://reset.example/link',
      ),
    );
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText =
              (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COPIAR ENLACE'));
    await tester.pump();

    expect(copiedText, 'https://reset.example/link');
    expect(find.text('Enlace copiado'), findsOneWidget);
  });

  testWidgets('P4 active operationId state presents operation ID',
      (tester) async {
    final workflow = _TerminalWorkflow(
      const ActiveProvisioningStatus(
        operationId: 'operation-active',
        phase: ProvisioningPhase.profileCommit,
        retryAfterSeconds: 1,
      ),
    );
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar y Añadir'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Alta en curso'), findsOneWidget);
    expect(find.textContaining('operation-active'), findsOneWidget);
  });

  testWidgets('P4 pending operationId state presents operation ID',
      (tester) async {
    final workflow = _TerminalWorkflow(
      const PendingProvisioningStatus(
        operationId: 'operation-pending',
        retryAfterSeconds: 1,
      ),
    );
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('operation-pending'), findsOneWidget);
  });

  testWidgets('P4 failed state presents terminal code and operationId',
      (tester) async {
    final workflow = _TerminalWorkflow(
      const FailedProvisioningStatus(
        operationId: 'operation-failed',
        terminalCode: 'profile-commit-failed',
      ),
    );
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Alta fallida'), findsOneWidget);
    expect(find.textContaining('profile-commit-failed'), findsOneWidget);
    expect(find.textContaining('operation-failed'), findsOneWidget);
  });

  testWidgets('P4 manual recovery presents codes and operationId',
      (tester) async {
    final workflow = _TerminalWorkflow(
      const ManualRecoveryProvisioningStatus(
        operationId: 'operation-recovery',
        terminalCode: 'manual-review-required',
        recoveryCode: 'auth-created-profile-missing',
      ),
    );
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('Recuperación manual requerida'), findsOneWidget);
    expect(find.textContaining('manual-review-required'), findsOneWidget);
    expect(find.textContaining('auth-created-profile-missing'), findsOneWidget);
    expect(find.textContaining('operation-recovery'), findsOneWidget);
  });

  testWidgets('P4 callable failure presents unavailable code', (tester) async {
    final workflow = _TerminalWorkflow(const ProvisioningFailure.unavailable());
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No se pudo completar el alta'), findsOneWidget);
    expect(find.textContaining('unavailable'), findsOneWidget);
  });

  testWidgets('P4 malformed failure presents malformed-response code',
      (tester) async {
    final workflow =
        _TerminalWorkflow(const ProvisioningFailure.malformedResponse());
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No se pudo completar el alta'), findsOneWidget);
    expect(find.textContaining('malformed-response'), findsOneWidget);
  });

  testWidgets('P4 passive mount and dispose do not construct workflow',
      (tester) async {
    final workflow = _TerminalWorkflow(
      const PendingProvisioningStatus(
        operationId: 'operation-pending',
        retryAfterSeconds: 1,
      ),
    );
    final workflowProviderReads = ValueNotifier(0);
    await tester.pumpWidget(_drawer(
      workflow: workflow,
      isOpen: false,
      authStates: Stream<User?>.empty(),
      workflowProviderReads: workflowProviderReads,
    ));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());

    expect(workflowProviderReads.value, 0);
    expect(workflow.cancelCalls, 0);
  });

  testWidgets('P4 initialized workflow cancels on close and dispose',
      (tester) async {
    final workflow = _TerminalWorkflow(
      const PendingProvisioningStatus(
        operationId: 'operation-pending',
        retryAfterSeconds: 1,
      ),
    );
    final workflowProviderReads = ValueNotifier(0);
    var closes = 0;
    await tester.pumpWidget(_drawer(
      workflow: workflow,
      onClose: () => closes += 1,
      workflowProviderReads: workflowProviderReads,
    ));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.tapAt(const Offset(10, 10));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpWidget(const SizedBox());

    expect(closes, 3);
    expect(workflowProviderReads.value, 1);
    expect(workflow.cancelCalls, 4);
  });

  testWidgets('P4 logout cancellation cancels local observation',
      (tester) async {
    final authStates = StreamController<User?>();
    addTearDown(authStates.close);
    final workflow = _TerminalWorkflow(
      const PendingProvisioningStatus(
        operationId: 'operation-pending',
        retryAfterSeconds: 1,
      ),
    );
    await tester.pumpWidget(_drawer(
      workflow: workflow,
      authStates: authStates.stream,
    ));
    await tester.pumpAndSettle();
    authStates
      ..add(_FakeAuthUser())
      ..add(null);
    await tester.pumpAndSettle();

    expect(workflow.cancelCalls, 1);
  });

  testWidgets('P4 operationId support copy remains visible', (tester) async {
    final workflow = _TerminalWorkflow(
      const FailedProvisioningStatus(
        operationId: 'operation-support',
        terminalCode: 'profile-commit-failed',
      ),
    );
    await tester.pumpWidget(_drawer(workflow: workflow));
    await tester.pumpAndSettle();
    await _fillRequiredFields(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('operation-support'), findsOneWidget);
  });
}
