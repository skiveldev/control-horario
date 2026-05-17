import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Servicio de generación de reportes PDF
///
/// Genera reportes mensuales de asistencia por empleado en formato PDF.
/// Incluye: horas trabajadas, pausas, horas extra, anomalías y resumen
/// de validaciones.
///
/// Ejemplo:
/// ```dart
/// final service = const ReportService();
/// final bytes = await service.generateMonthlyReport(
///   employeeName: 'María García',
///   companyName: 'Escuela de Música',
///   period: 'Mayo 2026',
///   totalHoursWorked: 168.5,
///   totalBreakMinutes: 330,
///   overtimeHours: 8.0,
///   anomalyCountByType: {'missingExit': 2},
///   validationSummary: '5 registros validados, 2 pendientes',
/// );
/// ```
class ReportService {
  const ReportService();

  /// Genera un reporte mensual en PDF para un empleado.
  ///
  /// Retorna los bytes del PDF generado listos para descargar o visualizar.
  Future<Uint8List> generateMonthlyReport({
    required String employeeName,
    required String companyName,
    required String period,
    required double totalHoursWorked,
    required int totalBreakMinutes,
    required double overtimeHours,
    required Map<String, int> anomalyCountByType,
    required String validationSummary,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text('Reporte de Asistencia',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ),
            pw.SizedBox(height: 8),
            pw.Text(companyName,
                style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
            pw.SizedBox(height: 4),
            pw.Text('Período: $period',
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 4),
            pw.Text('Generado: ${_formatDate(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            pw.SizedBox(height: 20),

            // Employee info
            pw.Header(level: 1, text: 'Empleado'),
            pw.Text(employeeName, style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),

            // Resumen
            pw.Header(level: 1, text: 'Resumen del Período'),
            pw.SizedBox(height: 8),
            _buildSummaryTable(
              totalHoursWorked: totalHoursWorked,
              totalBreakMinutes: totalBreakMinutes,
              overtimeHours: overtimeHours,
            ),
            pw.SizedBox(height: 20),

            // Anomalías
            pw.Header(level: 1, text: 'Anomalías Detectadas'),
            pw.SizedBox(height: 8),
            if (anomalyCountByType.isEmpty)
              pw.Text('Sin anomalías detectadas en el período.',
                  style:
                      const pw.TextStyle(fontSize: 12, color: PdfColors.grey))
            else
              _buildAnomalyTable(anomalyCountByType),
            pw.SizedBox(height: 20),

            // Validaciones
            pw.Header(level: 1, text: 'Estado de Validaciones'),
            pw.SizedBox(height: 8),
            pw.Text(validationSummary, style: const pw.TextStyle(fontSize: 12)),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Construye la tabla de resumen de horas
  static pw.Widget _buildSummaryTable({
    required double totalHoursWorked,
    required int totalBreakMinutes,
    required double overtimeHours,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        _summaryRow('Horas Trabajadas', '${totalHoursWorked}h'),
        _summaryRow('Pausas Totales', _formatMinutes(totalBreakMinutes)),
        _summaryRow('Horas Extra', '${overtimeHours}h'),
      ],
    );
  }

  static pw.TableRow _summaryRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value,
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ),
      ],
    );
  }

  /// Construye la tabla de anomalías por tipo
  static pw.Widget _buildAnomalyTable(Map<String, int> anomalyCountByType) {
    final rows = anomalyCountByType.entries.map((entry) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(_anomalyLabel(entry.key),
                style: const pw.TextStyle(fontSize: 12)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('${entry.value}',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      );
    }).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
      },
      children: rows,
    );
  }

  /// Traduce la clave de tipo de anomalía a etiqueta legible
  static String _anomalyLabel(String key) {
    switch (key) {
      case 'missingExit':
        return 'Salida faltante';
      case 'insufficientHours':
        return 'Horas insuficientes';
      case 'unexcusedAbsence':
        return 'Ausencia no justificada';
      case 'overlap':
        return 'Solapamiento';
      case 'excessiveBreak':
        return 'Pausa excesiva';
      default:
        return key;
    }
  }

  /// Formatea minutos a "Xh Ym"
  static String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Formatea DateTime a "dd/MM/yyyy"
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
