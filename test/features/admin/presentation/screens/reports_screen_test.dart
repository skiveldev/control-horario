import 'dart:async';
import 'dart:typed_data';

import 'package:control_horario/core/services/pdf_downloader.dart';
import 'package:control_horario/features/admin/presentation/screens/reports_screen.dart';
import 'package:control_horario/features/admin/providers/admin_provider.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/providers/time_records_provider.dart';
import 'package:control_horario/features/dashboard/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// Helpers de fixture
// =============================================================================

const _testUserId = 'user-1';

UserModel _fixtureUser() => UserModel(
      userId: _testUserId,
      employeeId: 'EMP001',
      email: 'maria@test.com',
      displayName: 'María García López',
      role: UserRole.employee,
      weeklyHours: 40,
      createdAt: DateTime(2025, 1, 1),
      nombre: 'María',
      apellido1: 'García',
      apellido2: 'López',
      empresa: 'Escuela de Música',
    );

UserModel _fixtureUserWithoutCompany() => UserModel(
      userId: _testUserId,
      employeeId: 'EMP002',
      email: 'juan@test.com',
      displayName: 'Juan Pérez',
      role: UserRole.employee,
      weeklyHours: 40,
      createdAt: DateTime(2025, 1, 1),
      nombre: 'Juan',
      apellido1: 'Pérez',
    );

List<TimeRecordModel> _fixtureRecords() {
  final now = DateTime(2026, 5, 15);
  return [
    // Work records — total 1680 minutes = 28h
    TimeRecordModel(
      id: 'rec-1',
      userId: _testUserId,
      date: '2026-05-02',
      category: RecordCategory.work,
      startTime: '09:00',
      endTime: '18:00',
      location: 'Oficina',
      durationMinutes: 480,
      createdAt: now,
      updatedAt: now,
      createdBy: _testUserId,
      isManual: false,
      validationStatus: ValidationStatus.validated,
    ),
    TimeRecordModel(
      id: 'rec-2',
      userId: _testUserId,
      date: '2026-05-03',
      category: RecordCategory.work,
      startTime: '09:00',
      endTime: '18:00',
      location: 'Oficina',
      durationMinutes: 480,
      createdAt: now,
      updatedAt: now,
      createdBy: _testUserId,
      isManual: false,
      validationStatus: ValidationStatus.validated,
    ),
    TimeRecordModel(
      id: 'rec-3',
      userId: _testUserId,
      date: '2026-05-04',
      category: RecordCategory.work,
      startTime: '09:00',
      endTime: '18:00',
      location: 'Oficina',
      durationMinutes: 480,
      createdAt: now,
      updatedAt: now,
      createdBy: _testUserId,
      isManual: false,
      validationStatus: ValidationStatus.editable,
    ),
    TimeRecordModel(
      id: 'rec-4',
      userId: _testUserId,
      date: '2026-05-05',
      category: RecordCategory.work,
      startTime: '09:00',
      endTime: '14:00',
      location: 'Oficina',
      durationMinutes: 240,
      createdAt: now,
      updatedAt: now,
      createdBy: _testUserId,
      isManual: false,
      validationStatus: ValidationStatus.editable,
    ),
    // Break records — total 90 minutos
    TimeRecordModel(
      id: 'rec-5',
      userId: _testUserId,
      date: '2026-05-02',
      category: RecordCategory.breakTime,
      startTime: '12:00',
      endTime: '12:30',
      location: 'Oficina',
      durationMinutes: 30,
      createdAt: now,
      updatedAt: now,
      createdBy: _testUserId,
      isManual: false,
      validationStatus: ValidationStatus.editable,
    ),
    TimeRecordModel(
      id: 'rec-6',
      userId: _testUserId,
      date: '2026-05-03',
      category: RecordCategory.breakTime,
      startTime: '12:00',
      endTime: '12:30',
      location: 'Oficina',
      durationMinutes: 30,
      createdAt: now,
      updatedAt: now,
      createdBy: _testUserId,
      isManual: false,
      validationStatus: ValidationStatus.editable,
    ),
    TimeRecordModel(
      id: 'rec-7',
      userId: _testUserId,
      date: '2026-05-04',
      category: RecordCategory.breakTime,
      startTime: '12:00',
      endTime: '12:30',
      location: 'Oficina',
      durationMinutes: 30,
      createdAt: now,
      updatedAt: now,
      createdBy: _testUserId,
      isManual: false,
      validationStatus: ValidationStatus.editable,
    ),
  ];
}

// =============================================================================
// Fake ReportService que captura argumentos
// =============================================================================

class _FakeReportService extends ReportService {
  _FakeReportService() : super();

  bool generateCalled = false;
  String? lastEmployeeName;
  String? lastCompanyName;
  String? lastPeriod;
  double? lastTotalHoursWorked;
  int? lastTotalBreakMinutes;
  double? lastOvertimeHours;
  Map<String, int>? lastAnomalyCountByType;
  String? lastValidationSummary;
  bool? lastAnomaliesIncluded;
  bool? lastOvertimeIncluded;

  @override
  Future<Uint8List> generateMonthlyReport({
    required String employeeName,
    required String companyName,
    required String period,
    required double totalHoursWorked,
    required int totalBreakMinutes,
    required double overtimeHours,
    required Map<String, int> anomalyCountByType,
    required String validationSummary,
    bool anomaliesIncluded = true,
    bool overtimeIncluded = true,
  }) async {
    generateCalled = true;
    lastEmployeeName = employeeName;
    lastCompanyName = companyName;
    lastPeriod = period;
    lastTotalHoursWorked = totalHoursWorked;
    lastTotalBreakMinutes = totalBreakMinutes;
    lastOvertimeHours = overtimeHours;
    lastAnomalyCountByType = anomalyCountByType;
    lastValidationSummary = validationSummary;
    lastAnomaliesIncluded = anomaliesIncluded;
    lastOvertimeIncluded = overtimeIncluded;
    return Uint8List(0);
  }
}

/// ReportService controlable que espera un [Completer] antes de resolver.
///
/// Permite simular generación en vuelo para testear la guarda de token contra
/// resultados obsoletos al cambiar empleado o mes durante la generación.
class _DelayedReportService extends ReportService {
  final Completer<Uint8List> completer;
  bool generateCalled = false;

  _DelayedReportService(this.completer) : super();

  @override
  Future<Uint8List> generateMonthlyReport({
    required String employeeName,
    required String companyName,
    required String period,
    required double totalHoursWorked,
    required int totalBreakMinutes,
    required double overtimeHours,
    required Map<String, int> anomalyCountByType,
    required String validationSummary,
    bool anomaliesIncluded = true,
    bool overtimeIncluded = true,
  }) async {
    generateCalled = true;
    return completer.future;
  }
}

// =============================================================================
// Test helpers
// =============================================================================

/// Overrides base que toda pantalla necesita (allEmployees vacío por defecto).
List<Override> _baseOverrides({List<UserModel> employees = const []}) {
  return [
    allEmployeesProvider.overrideWith((ref) => Stream.value(employees)),
  ];
}

ProviderContainer _containerWithState({
  bool isGenerating = false,
  bool hasPdf = false,
  Uint8List? pdfBytes,
  UserModel? selectedUser,
  List<UserModel> employees = const [],
  List<TimeRecordModel> records = const [],
  FakePdfDownloader? fakeDownloader,
}) {
  final overrides = <Override>[
    ..._baseOverrides(employees: employees),
    if (fakeDownloader != null)
      pdfDownloaderProvider.overrideWith((ref) => fakeDownloader),
    reportsScreenProvider.overrideWith(
      (ref) {
        final service = ref.watch(reportServiceProvider);
        final downloader = ref.watch(pdfDownloaderProvider);
        return ReportsScreenNotifier(
          service,
          ReportsScreenState(
            isGenerating: isGenerating,
            hasPdf: hasPdf,
            pdfBytes: pdfBytes,
            selectedMonth: DateTime(2026, 5, 1),
            selectedUser: selectedUser,
          ),
          downloader,
        );
      },
    ),
  ];

  // Override monthTimeRecordsProvider when a user is selected
  if (selectedUser != null) {
    overrides.add(
      monthTimeRecordsProvider(
        userId: selectedUser.userId,
        month: DateTime(2026, 5, 1),
      ).overrideWith((ref) => Stream.value(records)),
    );
  }

  return ProviderContainer(overrides: overrides);
}

Widget _wrapApp({required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: ReportsScreen(),
    ),
  );
}

/// Construye un container con worker, registros y fake service para tests de
/// generación vía widget.
ProviderContainer _containerForGenerateTest({
  required _FakeReportService fakeService,
  required UserModel selectedUser,
  required List<TimeRecordModel> records,
}) {
  return ProviderContainer(
    overrides: [
      reportServiceProvider.overrideWith((ref) => fakeService),
      allEmployeesProvider.overrideWith((ref) => Stream.value([selectedUser])),
      monthTimeRecordsProvider(
        userId: selectedUser.userId,
        month: DateTime(2026, 5, 1),
      ).overrideWith((ref) => Stream.value(records)),
      reportsScreenProvider.overrideWith(
        (ref) {
          final service = ref.watch(reportServiceProvider);
          final downloader = ref.watch(pdfDownloaderProvider);
          return ReportsScreenNotifier(
            service,
            ReportsScreenState(
              selectedMonth: DateTime(2026, 5, 1),
              selectedUser: selectedUser,
            ),
            downloader,
          );
        },
      ),
    ],
  );
}

// =============================================================================
// Tests
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // Notifier unit tests
  // ---------------------------------------------------------------------------
  group('ReportsScreenNotifier', () {
    test('generateReport pasa datos reales del empleado al ReportService',
        () async {
      final fakeService = _FakeReportService();
      final user = _fixtureUser();
      final records = _fixtureRecords();

      final notifier = ReportsScreenNotifier(
        fakeService,
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: user,
        ),
      );

      await notifier.generateReport(records: records);

      // Verificar que se llamó al servicio
      expect(fakeService.generateCalled, isTrue);

      // employeeName debe ser el fullName real, no 'Reporte General'
      expect(fakeService.lastEmployeeName, user.fullName);
      expect(fakeService.lastEmployeeName, isNot('Reporte General'));

      // companyName debe ser la empresa real
      expect(fakeService.lastCompanyName, 'Escuela de Música');

      // period debe contener el mes y año
      expect(fakeService.lastPeriod, 'Mayo 2026');

      // totalHoursWorked = (480+480+480+240) / 60 = 28.0
      expect(fakeService.lastTotalHoursWorked, closeTo(28.0, 0.01));

      // totalBreakMinutes = 30+30+30 = 90
      expect(fakeService.lastTotalBreakMinutes, 90);

      // overtimeHours siempre 0
      expect(fakeService.lastOvertimeHours, 0);

      // anomalyCountByType vacío
      expect(fakeService.lastAnomalyCountByType, isEmpty);

      // anomaliesIncluded debe ser false (el reporte no computa anomalías)
      expect(fakeService.lastAnomaliesIncluded, isFalse,
          reason: 'ReportsScreen debe indicar que las anomalías no se incluyen');

      // overtimeIncluded debe ser false (horas extra no se incluyen)
      expect(fakeService.lastOvertimeIncluded, isFalse,
          reason: 'ReportsScreen debe indicar que las horas extra no se incluyen');

      // validationSummary debe incluir la nota de horas extra
      expect(
        fakeService.lastValidationSummary,
        contains('Horas extra no incluidas en este reporte mensual'),
      );
      expect(
        fakeService.lastValidationSummary,
        contains('Anomalías no incluidas en este reporte'),
      );
      // Debe mencionar conteos de validados/pendientes
      expect(
        fakeService.lastValidationSummary,
        contains('2 registros validados'),
      );
      expect(
        fakeService.lastValidationSummary,
        contains('5 pendientes'),
      );
    });

    test('generateReport usa fallback cuando empresa es null', () async {
      final fakeService = _FakeReportService();
      final user = _fixtureUserWithoutCompany();
      final records = _fixtureRecords();

      final notifier = ReportsScreenNotifier(
        fakeService,
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: user,
        ),
      );

      await notifier.generateReport(records: records);

      expect(fakeService.lastCompanyName, 'Sin empresa asignada');
      expect(fakeService.lastEmployeeName, 'Juan Pérez');
    });

    test('generateReport no genera sin empleado seleccionado', () async {
      final fakeService = _FakeReportService();
      final records = _fixtureRecords();

      final notifier = ReportsScreenNotifier(
        fakeService,
        ReportsScreenState(selectedMonth: DateTime(2026, 5, 1)),
      );

      await notifier.generateReport(records: records);

      expect(fakeService.generateCalled, isFalse);
    });

    test('generateReport computa correctamente sin registros', () async {
      final fakeService = _FakeReportService();
      final user = _fixtureUser();

      final notifier = ReportsScreenNotifier(
        fakeService,
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: user,
        ),
      );

      await notifier.generateReport(records: []);

      expect(fakeService.lastTotalHoursWorked, 0);
      expect(fakeService.lastTotalBreakMinutes, 0);
      // Sin registros no hay conteos de validados/pendientes
      expect(
        fakeService.lastValidationSummary,
        isNot(contains('registros validados')),
      );
      // Pero sí debe incluir la nota de horas extra
      expect(
        fakeService.lastValidationSummary,
        contains('Horas extra no incluidas en este reporte mensual'),
      );
    });

    test('downloadReport llama a PdfDownloader con bytes y filename esperado',
        () async {
      final user = _fixtureUser();
      final fakeDownloader = FakePdfDownloader();
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4]);

      final notifier = ReportsScreenNotifier(
        const ReportService(),
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: user,
          pdfBytes: fakeBytes,
          hasPdf: true,
        ),
        fakeDownloader,
      );

      await notifier.downloadReport();

      expect(fakeDownloader.downloadCalled, isTrue,
          reason: 'downloadReport debe delegar en PdfDownloader');
      expect(fakeDownloader.lastBytes, same(fakeBytes));
      expect(
        fakeDownloader.lastFilename,
        contains('reporte_maria_garcia_lopez_2026_05'),
        reason: 'El nombre de archivo debe ser seguro y contener '
            'empleado + año_mes',
      );
      expect(fakeDownloader.lastFilename, endsWith('.pdf'));
    });

    test('downloadReport no hace nada sin pdfBytes', () async {
      final fakeDownloader = FakePdfDownloader();

      final notifier = ReportsScreenNotifier(
        const ReportService(),
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: _fixtureUser(),
          hasPdf: false,
        ),
        fakeDownloader,
      );

      await notifier.downloadReport();

      expect(fakeDownloader.downloadCalled, isFalse,
          reason: 'Sin pdfBytes no debe intentar descargar');
    });

    test('downloadReport no hace nada sin empleado seleccionado', () async {
      final fakeDownloader = FakePdfDownloader();

      final notifier = ReportsScreenNotifier(
        const ReportService(),
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          hasPdf: true,
          pdfBytes: Uint8List.fromList([1]),
        ),
        fakeDownloader,
      );

      await notifier.downloadReport();

      expect(fakeDownloader.downloadCalled, isFalse,
          reason: 'Sin empleado seleccionado no debe intentar descargar');
    });

    test('sanitizeFileName genera nombres de archivo seguros', () {
      expect(
        ReportsScreenNotifier.sanitizeFileName('María García López'),
        'maria_garcia_lopez',
      );
      expect(
        ReportsScreenNotifier.sanitizeFileName('José Ángel Núñez'),
        'jose_angel_nunez',
      );
      expect(
        ReportsScreenNotifier.sanitizeFileName('Ana-Maria'),
        'ana_maria',
      );
    });

    // =======================================================================
    // Invalidez de estado PDF al cambiar filtros
    // =======================================================================

    test('cambiar empleado después de generar PDF limpia hasPdf y pdfBytes',
        () async {
      final fakeService = _FakeReportService();
      final userA = _fixtureUser();
      final records = _fixtureRecords();

      final notifier = ReportsScreenNotifier(
        fakeService,
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: userA,
        ),
      );

      // Generar PDF para userA
      await notifier.generateReport(records: records);
      expect(notifier.state.hasPdf, isTrue);
      expect(notifier.state.pdfBytes, isNotNull);

      // Cambiar a otro empleado
      final userB = _fixtureUserWithoutCompany();
      notifier.selectEmployee(userB);

      // Estado PDF debe limpiarse
      expect(notifier.state.hasPdf, isFalse,
          reason: 'hasPdf debe ser false al cambiar de empleado');
      expect(notifier.state.pdfBytes, isNull,
          reason: 'pdfBytes debe ser null al cambiar de empleado');
      expect(notifier.state.isGenerating, isFalse);
      expect(notifier.state.selectedUser, userB);
    });

    test('cambiar mes después de generar PDF limpia hasPdf y pdfBytes',
        () async {
      final fakeService = _FakeReportService();
      final user = _fixtureUser();
      final records = _fixtureRecords();

      final notifier = ReportsScreenNotifier(
        fakeService,
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: user,
        ),
      );

      // Generar PDF para Mayo
      await notifier.generateReport(records: records);
      expect(notifier.state.hasPdf, isTrue);

      // Cambiar a Junio (índice 5)
      notifier.changeMonth(5);

      // Estado PDF debe limpiarse
      expect(notifier.state.hasPdf, isFalse,
          reason: 'hasPdf debe ser false al cambiar de mes');
      expect(notifier.state.pdfBytes, isNull,
          reason: 'pdfBytes debe ser null al cambiar de mes');
      expect(notifier.state.isGenerating, isFalse);
      expect(notifier.state.selectedMonth.month, 6);
    });

    test('download no puede usar bytes obsoletos después de cambiar empleado',
        () async {
      final fakeService = _FakeReportService();
      final userA = _fixtureUser();
      final records = _fixtureRecords();
      final fakeDownloader = FakePdfDownloader();

      final notifier = ReportsScreenNotifier(
        fakeService,
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: userA,
        ),
        fakeDownloader,
      );

      // Generar PDF para userA
      await notifier.generateReport(records: records);
      expect(notifier.state.hasPdf, isTrue);

      // Cambiar empleado — bytes deben invalidarse
      notifier.selectEmployee(_fixtureUserWithoutCompany());

      // Intentar descargar — no debe usar los bytes obsoletos
      await notifier.downloadReport();
      expect(fakeDownloader.downloadCalled, isFalse,
          reason: 'Después de cambiar empleado, pdfBytes es null '
              'y downloadReport no debe ejecutarse');
    });

    // =======================================================================
    // Guarda de token — resultado obsoleto no corrompe estado tras cambio
    // =======================================================================

    test('resultado obsoleto no se aplica si se cambió de empleado '
        'durante la generación', () async {
      final completer = Completer<Uint8List>();
      final delayedService = _DelayedReportService(completer);
      final userA = _fixtureUser();
      final records = _fixtureRecords();

      final notifier = ReportsScreenNotifier(
        delayedService,
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: userA,
        ),
      );

      // Disparar generación (no se completa hasta que resolvamos el completer)
      final generationFuture = notifier.generateReport(records: records);

      // Debe estar en estado "generando"
      expect(notifier.state.isGenerating, isTrue);
      expect(delayedService.generateCalled, isTrue);

      // Cambiar empleado mientras la generación está en vuelo
      final userB = UserModel(
        userId: 'user-2',
        employeeId: 'EMP002',
        email: 'juan@test.com',
        displayName: 'Juan Pérez',
        role: UserRole.employee,
        weeklyHours: 40,
        createdAt: DateTime(2025, 1, 1),
        nombre: 'Juan',
        apellido1: 'Pérez',
      );
      notifier.selectEmployee(userB);

      // Ahora completar la generación anterior con bytes obsoletos
      completer.complete(Uint8List.fromList([1, 2, 3, 4]));
      await generationFuture;

      // El estado NO debe tener PDF listo porque el empleado cambió
      expect(notifier.state.hasPdf, isFalse,
          reason: 'La generación completada después de cambiar empleado '
              'no debe dejar hasPdf=true con bytes del empleado anterior');
      expect(notifier.state.pdfBytes, isNull,
          reason: 'Los bytes obsoletos deben ser descartados');
    });

    test('resultado obsoleto no se aplica si se cambió de mes '
        'durante la generación', () async {
      final completer = Completer<Uint8List>();
      final delayedService = _DelayedReportService(completer);
      final user = _fixtureUser();
      final records = _fixtureRecords();

      final notifier = ReportsScreenNotifier(
        delayedService,
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: user,
        ),
      );

      // Disparar generación (no se completa hasta que resolvamos el completer)
      final generationFuture = notifier.generateReport(records: records);

      // Debe estar en estado "generando"
      expect(notifier.state.isGenerating, isTrue);

      // Cambiar mes mientras la generación está en vuelo
      notifier.changeMonth(5); // índice 5 = Junio

      // Ahora completar la generación anterior con bytes obsoletos
      completer.complete(Uint8List.fromList([1, 2, 3, 4]));
      await generationFuture;

      // El estado NO debe tener PDF listo porque el mes cambió
      expect(notifier.state.hasPdf, isFalse,
          reason: 'La generación completada después de cambiar mes '
              'no debe dejar hasPdf=true con bytes del mes anterior');
      expect(notifier.state.pdfBytes, isNull,
          reason: 'Los bytes obsoletos deben ser descartados');
    });

    test('el resultado de la última generación sí se aplica normalmente',
        () async {
      // Sanity check: sin cambios durante la generación, el resultado sí se aplica
      final completer = Completer<Uint8List>();
      final delayedService = _DelayedReportService(completer);
      final user = _fixtureUser();
      final records = _fixtureRecords();

      final notifier = ReportsScreenNotifier(
        delayedService,
        ReportsScreenState(
          selectedMonth: DateTime(2026, 5, 1),
          selectedUser: user,
        ),
      );

      final generationFuture = notifier.generateReport(records: records);
      expect(notifier.state.isGenerating, isTrue);

      // Completar sin haber cambiado nada
      completer.complete(Uint8List.fromList([1, 2, 3, 4]));
      await generationFuture;

      // El resultado sí debe aplicarse
      expect(notifier.state.hasPdf, isTrue,
          reason: 'Sin cambios de filtro, la generación debe aplicar el PDF');
      expect(notifier.state.pdfBytes, isNotNull);
      expect(notifier.state.isGenerating, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Widget tests
  // ---------------------------------------------------------------------------
  group('ReportsScreen widget', () {
    testWidgets('muestra título y selector de mes', (tester) async {
      final container = _containerWithState();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe mostrar el título
      expect(find.text('Generar Reportes'), findsOneWidget);
    });

    testWidgets('muestra botón de generar reporte (deshabilitado sin empleado)',
        (tester) async {
      final container = _containerWithState();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // El texto del botón existe
      expect(find.text('Generar Reporte PDF'), findsOneWidget);

      // Al hacer tap no debe generar nada (botón deshabilitado sin empleado)
      await tester.tap(find.text('Generar Reporte PDF'));
      await tester.pump();

      // No debería aparecer loading (no se generó)
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('botón se habilita al seleccionar un empleado', (tester) async {
      final user = _fixtureUser();
      final container = _containerWithState(
        selectedUser: user,
        employees: [user],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // El texto del botón existe
      expect(find.text('Generar Reporte PDF'), findsOneWidget);

      // Al hacer tap debe ejecutar la generación (aunque sea instantánea)
      await tester.tap(find.text('Generar Reporte PDF'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Después de generar, aparece el banner de éxito
      expect(find.text('PDF generado correctamente'), findsOneWidget);
    });

    testWidgets('muestra selector de período', (tester) async {
      final container = _containerWithState();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe haber un selector de empleado y período
      expect(find.text('Empleado'), findsOneWidget);
      expect(find.text('Período'), findsOneWidget);
    });

    testWidgets('muestra estado de generación cuando se genera el PDF',
        (tester) async {
      final container = _containerWithState(isGenerating: true);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      // Usar pump() en vez de pumpAndSettle() porque CircularProgressIndicator
      // es una animación infinita que nunca "settlea"
      await tester.pump();

      // Durante la generación, muestra estado de carga. Puede haber más de un
      // indicador porque el botón reutilizable también muestra su propio loader.
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('muestra indicador cuando el PDF está listo para descargar',
        (tester) async {
      final container = _containerWithState(hasPdf: true);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe mostrar mensaje de PDF listo
      expect(find.text('PDF generado correctamente'), findsOneWidget);
    });

    testWidgets(
        'al generar se pasan datos reales del empleado al ReportService',
        (tester) async {
      final fakeService = _FakeReportService();
      final user = _fixtureUser();
      final records = _fixtureRecords();

      final container = _containerForGenerateTest(
        fakeService: fakeService,
        selectedUser: user,
        records: records,
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Verificar que el texto del botón existe
      expect(find.text('Generar Reporte PDF'), findsOneWidget);

      // Tap the generate button
      await tester.tap(find.text('Generar Reporte PDF'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verificar que se llamó al servicio
      expect(fakeService.generateCalled, isTrue,
          reason: 'El botón Generar debe llamar a generateReport');

      // Verificar datos pasados al servicio
      expect(fakeService.lastEmployeeName, user.fullName);
      expect(fakeService.lastEmployeeName, isNot('Reporte General'));
      expect(fakeService.lastCompanyName, 'Escuela de Música');
      expect(fakeService.lastPeriod, 'Mayo 2026');
      expect(fakeService.lastTotalHoursWorked, closeTo(28.0, 0.01));
      expect(fakeService.lastTotalBreakMinutes, 90);
      expect(fakeService.lastOvertimeHours, 0);
      expect(
        fakeService.lastValidationSummary,
        contains('Horas extra no incluidas en este reporte mensual'),
      );
    });

    testWidgets('botón inhabilitado mientras los registros están cargando',
        (tester) async {
      final user = _fixtureUser();
      final container = ProviderContainer(
        overrides: [
          allEmployeesProvider.overrideWith((ref) => Stream.value([user])),
          reportsScreenProvider.overrideWith(
            (ref) {
              final service = ref.watch(reportServiceProvider);
              final downloader = ref.watch(pdfDownloaderProvider);
              return ReportsScreenNotifier(
                service,
                ReportsScreenState(
                  selectedMonth: DateTime(2026, 5, 1),
                  selectedUser: user,
                ),
                downloader,
              );
            },
          ),
          // Registros del mes: stream que nunca emite (simula carga infinita)
          monthTimeRecordsProvider(
            userId: user.userId,
            month: DateTime(2026, 5, 1),
          ).overrideWith((ref) => const Stream.empty()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pump();

      // El botón existe pero debe estar deshabilitado
      final button = find.text('Generar Reporte PDF');
      expect(button, findsOneWidget);

      // Intentar generar no debe producir PDF
      await tester.tap(button);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('PDF generado correctamente'), findsNothing,
          reason: 'No se debe generar PDF mientras los registros están cargando');
    });

    testWidgets('muestra indicador de carga de registros', (tester) async {
      final user = _fixtureUser();
      final container = ProviderContainer(
        overrides: [
          allEmployeesProvider.overrideWith((ref) => Stream.value([user])),
          reportsScreenProvider.overrideWith(
            (ref) {
              final service = ref.watch(reportServiceProvider);
              final downloader = ref.watch(pdfDownloaderProvider);
              return ReportsScreenNotifier(
                service,
                ReportsScreenState(
                  selectedMonth: DateTime(2026, 5, 1),
                  selectedUser: user,
                ),
                downloader,
              );
            },
          ),
          monthTimeRecordsProvider(
            userId: user.userId,
            month: DateTime(2026, 5, 1),
          ).overrideWith((ref) => const Stream.empty()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pump();

      // Debe mostrar el indicador de carga de registros
      expect(find.text('Cargando registros del mes...'), findsOneWidget,
          reason: 'Debe indicar al usuario que los registros se están cargando');
    });

    // =========================================================================
    // NUEVOS TESTS — Vista previa de datos reales
    // =========================================================================

    testWidgets('Vista Previa muestra mensaje honesto sin empleado seleccionado',
        (tester) async {
      final container = _containerWithState();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe mostrar el encabezado de Vista Previa
      expect(find.text('Vista Previa'), findsOneWidget);

      // Scopear al Card que contiene "Vista Previa" (la preview card)
      final previewCard = find.ancestor(
        of: find.text('Vista Previa'),
        matching: find.byType(Card),
      );

      // Dentro de la preview card, buscar el mensaje de estado vacío
      expect(
        find.descendant(
          of: previewCard,
          matching: find.byWidgetPredicate(
            (w) => w is Text && (w.data ?? '').contains('previsualizar'),
          ),
        ),
        findsOneWidget,
        reason: 'Sin empleado seleccionado debe pedir al usuario que '
            'seleccione empleado y período',
      );
    });

    testWidgets(
        'Vista Previa muestra datos reales del empleado antes de generar',
        (tester) async {
      final user = _fixtureUser();
      final records = _fixtureRecords();
      final container = _containerWithState(
        selectedUser: user,
        employees: [user],
        records: records,
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Scopear al Card que contiene "Vista Previa"
      final previewCard = find.ancestor(
        of: find.text('Vista Previa'),
        matching: find.byType(Card),
      );

      // Dentro de la preview card, buscar el nombre del empleado
      expect(
        find.descendant(
          of: previewCard,
          matching: find.byWidgetPredicate(
            (w) => w is Text && (w.data ?? '').contains('María García López'),
          ),
        ),
        findsOneWidget,
      );

      // Dentro de la preview card, buscar el período
      expect(
        find.descendant(
          of: previewCard,
          matching: find.byWidgetPredicate(
            (w) => w is Text && (w.data ?? '') == 'Mayo 2026',
          ),
        ),
        findsOneWidget,
      );

      // La preview card debe mostrar horas trabajadas (28.0h) — string exacto
      expect(
        find.descendant(
          of: previewCard,
          matching: find.text('28.0h'),
        ),
        findsOneWidget,
      );

      // Debe mostrar pausas (1h 30m) — string exacto
      expect(
        find.descendant(
          of: previewCard,
          matching: find.text('1h 30m'),
        ),
        findsOneWidget,
      );

      // Debe mostrar conteo de validaciones
      expect(
        find.descendant(
          of: previewCard,
          matching: find.byWidgetPredicate(
            (w) => w is Text && (w.data ?? '').contains('2 validados'),
          ),
        ),
        findsOneWidget,
      );

      // Notas honestas: horas extra no incluidas
      expect(
        find.descendant(
          of: previewCard,
          matching: find.text('Horas extra no incluidas en este reporte mensual.'),
        ),
        findsOneWidget,
      );

      // Notas honestas: anomalías no incluidas
      expect(
        find.descendant(
          of: previewCard,
          matching: find.text('Anomalías no incluidas en este reporte.'),
        ),
        findsOneWidget,
      );

      // NO debe afirmar que se incluyen horas extra
      expect(
        find.descendant(
          of: previewCard,
          matching: find.byWidgetPredicate(
            (w) => w is Text && (w.data ?? '').contains('Horas Extra'),
          ),
        ),
        findsNothing,
        reason: 'El reporte no incluye horas extra; no debe mostrarlas como '
            'si estuvieran incluidas',
      );
    });

    testWidgets('Vista Previa muestra loading mientras se cargan registros',
        (tester) async {
      final user = _fixtureUser();
      final container = ProviderContainer(
        overrides: [
          allEmployeesProvider.overrideWith((ref) => Stream.value([user])),
          reportsScreenProvider.overrideWith(
            (ref) {
              final service = ref.watch(reportServiceProvider);
              final downloader = ref.watch(pdfDownloaderProvider);
              return ReportsScreenNotifier(
                service,
                ReportsScreenState(
                  selectedMonth: DateTime(2026, 5, 1),
                  selectedUser: user,
                ),
                downloader,
              );
            },
          ),
          monthTimeRecordsProvider(
            userId: user.userId,
            month: DateTime(2026, 5, 1),
          ).overrideWith((ref) => const Stream.empty()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pump();

      // La Vista Previa debe mostrar un indicador de carga
      // Mientras se cargan los registros, debe haber al menos un
      // CircularProgressIndicator en la preview card (no solo en la filter card)
      // En este estado hay 2: uno en filter card y otro en preview card
      expect(
        find.byType(CircularProgressIndicator),
        findsWidgets,
        reason: 'Debe haber indicador de carga en la vista previa mientras '
            'se cargan los registros',
      );
    });

    // =========================================================================
    // NUEVOS TESTS — Descargar PDF
    // =========================================================================

    testWidgets('PDF listo muestra botón Descargar PDF', (tester) async {
      final user = _fixtureUser();
      final container = _containerWithState(
        hasPdf: true,
        pdfBytes: Uint8List.fromList([1, 2, 3]),
        selectedUser: user,
        employees: [user],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe mostrar el mensaje de PDF generado
      expect(find.text('PDF generado correctamente'), findsOneWidget);

      // Debe mostrar el botón de descarga
      expect(find.text('Descargar PDF'), findsOneWidget,
          reason: 'Con PDF listo, debe aparecer el botón Descargar PDF');
    });

    testWidgets('tapping Descargar PDF llama al fake downloader con datos esperados',
        (tester) async {
      final user = _fixtureUser();
      final fakeDownloader = FakePdfDownloader();
      final fakeBytes = Uint8List.fromList([1, 2, 3, 4]);
      final container = _containerWithState(
        hasPdf: true,
        pdfBytes: fakeBytes,
        selectedUser: user,
        employees: [user],
        fakeDownloader: fakeDownloader,
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Verificar que el botón Descargar PDF está presente
      final downloadButton = find.text('Descargar PDF');
      expect(downloadButton, findsOneWidget);

      // Asegurar que el botón es visible antes de tocar
      await tester.ensureVisible(downloadButton);
      await tester.pumpAndSettle();

      // Tocar el botón de descarga
      await tester.tap(downloadButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verificar que se llamó al downloader
      expect(fakeDownloader.downloadCalled, isTrue,
          reason: 'Al tocar Descargar PDF debe llamarse a PdfDownloader.download');

      // Verificar bytes pasados
      expect(fakeDownloader.lastBytes, same(fakeBytes));

      // Verificar nombre de archivo seguro
      expect(
        fakeDownloader.lastFilename,
        contains('reporte_'),
        reason: 'El nombre del archivo debe empezar con "reporte_"',
      );
      expect(
        fakeDownloader.lastFilename,
        contains('maria_garcia_lopez'),
        reason: 'El nombre del archivo debe contener el nombre del empleado',
      );
      expect(
        fakeDownloader.lastFilename,
        contains('2026_05'),
        reason: 'El nombre del archivo debe contener año_mes',
      );
      expect(
        fakeDownloader.lastFilename,
        endsWith('.pdf'),
        reason: 'El nombre del archivo debe terminar en .pdf',
      );
    });

    testWidgets('Descargar PDF no aparece sin pdfBytes', (tester) async {
      final user = _fixtureUser();
      final container = _containerWithState(
        selectedUser: user,
        employees: [user],
        records: _fixtureRecords(),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // NO debe aparecer el botón de descarga antes de generar
      expect(find.text('Descargar PDF'), findsNothing,
          reason: 'Antes de generar el PDF no debe mostrarse el botón de descarga');
    });

    // =======================================================================
    // Invalidez de estado PDF en UI al cambiar filtros
    // =======================================================================

    testWidgets('cambiar empleado después de generar PDF oculta Descargar PDF',
        (tester) async {
      final userA = _fixtureUser(); // userId: 'user-1'
      final userB = UserModel(
        userId: 'user-2',
        employeeId: 'EMP002',
        email: 'juan@test.com',
        displayName: 'Juan Pérez',
        role: UserRole.employee,
        weeklyHours: 40,
        createdAt: DateTime(2025, 1, 1),
        nombre: 'Juan',
        apellido1: 'Pérez',
      );

      // Inicia con userA seleccionado y PDF ya generado
      final container = ProviderContainer(
        overrides: [
          allEmployeesProvider.overrideWith(
              (ref) => Stream.value([userA, userB])),
          reportsScreenProvider.overrideWith(
            (ref) {
              final service = ref.watch(reportServiceProvider);
              final downloader = ref.watch(pdfDownloaderProvider);
              return ReportsScreenNotifier(
                service,
                ReportsScreenState(
                  selectedMonth: DateTime(2026, 5, 1),
                  selectedUser: userA,
                  hasPdf: true,
                  pdfBytes: Uint8List.fromList([1, 2, 3]),
                ),
                downloader,
              );
            },
          ),
          monthTimeRecordsProvider(
            userId: userA.userId,
            month: DateTime(2026, 5, 1),
          ).overrideWith((ref) => Stream.value(_fixtureRecords())),
          // userB records override — necesario cuando cambie el dropdown
          monthTimeRecordsProvider(
            userId: userB.userId,
            month: DateTime(2026, 5, 1),
          ).overrideWith((ref) => const Stream.empty()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Estado inicial: Descargar PDF visible, banner de PDF visible
      expect(find.text('Descargar PDF'), findsOneWidget,
          reason: 'Con PDF generado, debe mostrarse el botón de descarga');
      expect(find.text('PDF generado correctamente'), findsOneWidget);
      expect(find.text('María García López'), findsWidgets,
          reason: 'El empleado seleccionado debe mostrarse en la preview');

      // Abrir el dropdown de empleado (filtrado por key)
      final employeeDropdown =
          find.byKey(const ValueKey('user-1'));
      await tester.ensureVisible(employeeDropdown);
      await tester.tap(employeeDropdown);
      await tester.pumpAndSettle();

      // Seleccionar userB del menú desplegable
      await tester.tap(find.text('Juan Pérez').last);
      // usar pump() en vez de pumpAndSettle() porque los registros de userB
      // están en Stream.empty() y el CircularProgressIndicator nunca settlea
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Assert: Descargar PDF DEBE desaparecer
      expect(find.text('Descargar PDF'), findsNothing,
          reason: 'Al cambiar de empleado, el botón Descargar PDF debe '
              'ocultarse porque el PDF generado pertenece al empleado anterior');
      expect(find.text('PDF generado correctamente'), findsNothing,
          reason: 'El banner de PDF listo debe desaparecer al cambiar empleado');
    });
  });
}
