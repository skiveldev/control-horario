import 'dart:io';
import 'dart:typed_data';

import 'package:control_horario/features/dashboard/services/report_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extrae el texto legible descomprimido de un PDF generado por dart_pdf.
///
/// Busca el bloque `stream\n...endstream` FlateDecode, descomprime con zlib,
/// y extrae las palabras encerradas en `[(...)]` del stream de texto PDF.
String _extractPdfText(Uint8List pdfBytes) {
  final pdfString = String.fromCharCodes(pdfBytes);
  final streamStart = pdfString.indexOf('stream\n');
  final streamEnd = pdfString.indexOf('endstream', streamStart);
  if (streamStart == -1 || streamEnd == -1) return '';

  final compressedStart = streamStart + 'stream\n'.length;
  final compressedBytes = pdfBytes.sublist(compressedStart, streamEnd);

  String decompressed;
  try {
    decompressed = String.fromCharCodes(zlib.decode(compressedBytes));
  } catch (_) {
    decompressed = String.fromCharCodes(pdfBytes);
  }

  // Extraer palabras de los corchetes PDF: [(algo)]
  final words = <String>[];
  final regex = RegExp(r'\[\((.*?)\)\]');
  for (final match in regex.allMatches(decompressed)) {
    words.add(match.group(1)!);
  }
  return words.join(' ');
}

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
      expect(
          bytesWithAnomalies.length, greaterThan(bytesWithoutAnomalies.length));
    });

    test(
        'generateMonthlyReport con anomaliesIncluded false NO dice "Sin anomalías"',
        () async {
      final bytes = await service.generateMonthlyReport(
        employeeName: 'Maria Garcia',
        companyName: 'Escuela de Musica',
        period: 'Mayo 2026',
        totalHoursWorked: 168.5,
        totalBreakMinutes: 330,
        overtimeHours: 8.0,
        anomalyCountByType: const {},
        validationSummary: '5 validados, 2 pendientes',
        anomaliesIncluded: false,
      );

      // Debe producir bytes válidos
      expect(bytes, isNotEmpty);

      // Extraer texto descomprimido del PDF
      final pdfText = _extractPdfText(bytes);

      // NO debe contener la frase engañosa
      expect(
        pdfText,
        isNot(contains('Sin anomalías detectadas en el período')),
        reason: 'Con anomaliesIncluded=false, el PDF NO debe afirmar que no '
            'hay anomalías cuando simplemente no se incluyeron',
      );

      // Debe contener el mensaje honesto
      expect(
        pdfText,
        contains('Anomalías no incluidas en este reporte'),
        reason:
            'Debe indicar honestamente que las anomalías no fueron incluidas',
      );
    });

    test(
        'generateMonthlyReport con anomaliesIncluded true (default) sí dice "Sin anomalías"',
        () async {
      final bytes = await service.generateMonthlyReport(
        employeeName: 'Maria Garcia',
        companyName: 'Escuela de Musica',
        period: 'Mayo 2026',
        totalHoursWorked: 168.5,
        totalBreakMinutes: 330,
        overtimeHours: 8.0,
        anomalyCountByType: const {},
        validationSummary: '5 validados, 2 pendientes',
        // anomaliesIncluded defaults to true
      );

      // Debe producir bytes válidos
      expect(bytes, isNotEmpty);

      // Extraer texto descomprimido del PDF
      final pdfText = _extractPdfText(bytes);

      // Debe contener la frase por defecto
      expect(
        pdfText,
        contains('Sin anomalías detectadas en el período'),
        reason: 'Con anomaliesIncluded=true (default), el PDF debe contener '
            'el mensaje estándar de sin anomalías',
      );
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

    // =======================================================================
    // Horas extra — inclusión/omisión honesta
    // =======================================================================

    test(
        'generateMonthlyReport con overtimeIncluded true (default) incluye '
        'fila Horas Extra', () async {
      final bytes = await service.generateMonthlyReport(
        employeeName: 'Maria Garcia',
        companyName: 'Escuela de Musica',
        period: 'Mayo 2026',
        totalHoursWorked: 168.5,
        totalBreakMinutes: 330,
        overtimeHours: 8.0,
        anomalyCountByType: const {},
        validationSummary: '5 validados',
        // overtimeIncluded por defecto true
      );

      final pdfText = _extractPdfText(bytes);

      // Debe contener la fila de horas extra con el valor
      expect(pdfText, contains('Horas Extra'),
          reason: 'Con overtimeIncluded=true (default), la tabla debe incluir '
              'la fila Horas Extra');
      expect(pdfText, contains('8.0h'),
          reason: 'Debe mostrar el valor de horas extra');

      // NO debe contener la nota de omisión
      expect(
          pdfText, isNot(contains('Horas extra no incluidas en este reporte')),
          reason:
              'Con overtimeIncluded=true, no debe aparecer la nota de omisión');
    });

    test(
        'generateMonthlyReport con overtimeIncluded false omite Horas Extra '
        'y muestra nota honesta', () async {
      final bytes = await service.generateMonthlyReport(
        employeeName: 'Maria Garcia',
        companyName: 'Escuela de Musica',
        period: 'Mayo 2026',
        totalHoursWorked: 168.5,
        totalBreakMinutes: 330,
        overtimeHours: 0,
        anomalyCountByType: const {},
        validationSummary: '5 validados',
        overtimeIncluded: false,
      );

      final pdfText = _extractPdfText(bytes);

      // NO debe contener la fila Horas Extra en la tabla
      expect(pdfText, isNot(contains('Horas Extra')),
          reason:
              'Con overtimeIncluded=false, la tabla resumen NO debe incluir '
              'fila Horas Extra, ni siquiera con 0.0h');

      // Debe contener la nota honesta
      expect(pdfText, contains('Horas extra no incluidas en este reporte'),
          reason:
              'Debe indicar honestamente que las horas extra no fueron incluidas');
    });
  });
}
