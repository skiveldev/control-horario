import 'dart:typed_data';

import 'package:control_horario/features/dashboard/services/report_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportService', () {
    late ReportService service;

    setUp(() {
      service = const ReportService();
    });

    test('generateMonthlyReport produce bytes PDF válidos', () async {
      final bytes = await service.generateMonthlyReport(
        employeeName: 'Maria Garcia',
        companyName: 'Escuela de Musica',
        period: 'Mayo 2026',
        totalHoursWorked: 168.5,
        totalBreakMinutes: 330,
        overtimeHours: 8.0,
        anomalyCountByType: const {
          'missingExit': 2,
          'insufficientHours': 1,
        },
        validationSummary: '5 registros validados, 2 pendientes',
      );

      // Debe producir bytes no vacíos
      expect(bytes, isNotNull);
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(100));

      // Debe comenzar con el magic number de PDF
      final pdfHeader = String.fromCharCodes(bytes.take(4));
      expect(pdfHeader, equals('%PDF'));

      // Debe terminar con %%EOF
      final tail = String.fromCharCodes(bytes.skip(bytes.length - 10));
      expect(tail.contains('%%EOF'), isTrue);
    });

    test('generateMonthlyReport genera PDF de tamaño razonable', () async {
      final bytes = await service.generateMonthlyReport(
        employeeName: 'Juan Perez',
        companyName: 'Escuela de Musica',
        period: 'Abril 2026',
        totalHoursWorked: 160.0,
        totalBreakMinutes: 300,
        overtimeHours: 2.5,
        anomalyCountByType: const {},
        validationSummary: 'Todos validados',
      );

      // Un PDF simple con metadata debe ser mayor a 500 bytes
      expect(bytes.length, greaterThan(500));
    });

    test('generateMonthlyReport con anomalías genera más contenido que sin',
        () async {
      final bytesWithAnomalies = await service.generateMonthlyReport(
        employeeName: 'Ana Bravo',
        companyName: 'Escuela de Musica',
        period: 'Marzo 2026',
        totalHoursWorked: 172.0,
        totalBreakMinutes: 240,
        overtimeHours: 12.0,
        anomalyCountByType: const {
          'unexcusedAbsence': 1,
          'overlap': 3,
        },
        validationSummary: '4 validados, 1 pendiente',
      );

      final bytesWithoutAnomalies = await service.generateMonthlyReport(
        employeeName: 'Ana Bravo',
        companyName: 'Escuela de Musica',
        period: 'Marzo 2026',
        totalHoursWorked: 172.0,
        totalBreakMinutes: 240,
        overtimeHours: 12.0,
        anomalyCountByType: const {},
        validationSummary: '4 validados, 1 pendiente',
      );

      // El PDF con anomalías debe ser más grande (contiene tabla adicional)
      expect(bytesWithAnomalies.length,
          greaterThan(bytesWithoutAnomalies.length));
    });

    test('generateMonthlyReport maneja cero anomalías sin error', () async {
      final bytes = await service.generateMonthlyReport(
        employeeName: 'Carlos Diaz',
        companyName: 'Escuela de Musica',
        period: 'Febrero 2026',
        totalHoursWorked: 160.0,
        totalBreakMinutes: 0,
        overtimeHours: 0,
        anomalyCountByType: const {},
        validationSummary: 'Sin registros',
      );

      // No debe lanzar error con mapa vacío de anomalías
      expect(bytes, isNotEmpty);
      final pdfHeader = String.fromCharCodes(bytes.take(4));
      expect(pdfHeader, equals('%PDF'));
    });
  });
}
