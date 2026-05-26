import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../dashboard/services/report_service.dart';

/// Provider para el servicio de reportes (sobreescribible en tests)
final reportServiceProvider = Provider<ReportService>((ref) {
  return const ReportService();
});

/// Estado de la pantalla de reportes (para testing)
class ReportsScreenState {
  final bool isGenerating;
  final bool hasPdf;
  final DateTime selectedMonth;
  final Uint8List? pdfBytes;

  ReportsScreenState({
    this.isGenerating = false,
    this.hasPdf = false,
    DateTime? selectedMonth,
    this.pdfBytes,
  }) : selectedMonth = selectedMonth ??
            DateTime(DateTime.now().year, DateTime.now().month, 1);

  ReportsScreenState copyWith({
    bool? isGenerating,
    bool? hasPdf,
    DateTime? selectedMonth,
    Uint8List? pdfBytes,
  }) {
    return ReportsScreenState(
      isGenerating: isGenerating ?? this.isGenerating,
      hasPdf: hasPdf ?? this.hasPdf,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      pdfBytes: pdfBytes ?? this.pdfBytes,
    );
  }
}

/// Notifier para la pantalla de generación de reportes.
///
/// Expone [changeMonth] para actualizar el mes seleccionado y
/// [generateReport] que invoca genuinamente a [ReportService].
class ReportsScreenNotifier extends StateNotifier<ReportsScreenState> {
  final ReportService _service;

  ReportsScreenNotifier(this._service, [ReportsScreenState? initialState])
      : super(initialState ?? ReportsScreenState());

  /// Cambia el mes seleccionado en el dropdown.
  void changeMonth(int monthIndex) {
    state = state.copyWith(
      selectedMonth: DateTime(state.selectedMonth.year, monthIndex + 1, 1),
    );
  }

  /// Genera un reporte PDF mensual usando [ReportService].
  Future<void> generateReport() async {
    state = state.copyWith(isGenerating: true, hasPdf: false);
    try {
      final monthName = _monthName(state.selectedMonth.month);
      final period = '$monthName ${state.selectedMonth.year}';

      final bytes = await _service.generateMonthlyReport(
        employeeName: 'Reporte General',
        companyName: 'Control Horario',
        period: period,
        totalHoursWorked: 0,
        totalBreakMinutes: 0,
        overtimeHours: 0,
        anomalyCountByType: const {},
        validationSummary: 'Resumen del período $period',
      );
      state = state.copyWith(
        isGenerating: false,
        hasPdf: true,
        pdfBytes: bytes,
      );
    } catch (e) {
      state = state.copyWith(isGenerating: false);
    }
  }

  static String _monthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }
}

/// Provider para el notifier de la pantalla de reportes
final reportsScreenProvider =
    StateNotifierProvider<ReportsScreenNotifier, ReportsScreenState>((ref) {
  final service = ref.watch(reportServiceProvider);
  return ReportsScreenNotifier(service);
});

/// Pantalla de generación de reportes PDF (Admin/Supervisor)
///
/// Permite seleccionar el período (mes/año) y generar un reporte
/// de asistencia mensual en formato PDF descargable.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsScreenProvider);
    final isGenerating = state.isGenerating;
    final hasPdf = state.hasPdf;
    final selectedMonth = state.selectedMonth;

    return Scaffold(
      appBar: AppBar(title: const Text('Generar Reportes')),
      body: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Período
            _buildPeriodSection(ref, context, selectedMonth),
            AppSpacing.verticalSpaceLg,

            // Botón de generar
            _buildGenerateButton(ref, isGenerating),
            AppSpacing.verticalSpaceLg,

            // Estado / resultado
            if (isGenerating)
              const Center(child: CircularProgressIndicator())
            else if (hasPdf)
              _buildPdfReadyBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSection(
    WidgetRef ref,
    BuildContext context,
    DateTime selectedMonth,
  ) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final notifier = ref.read(reportsScreenProvider.notifier);

    return Card(
      child: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Período',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
            AppSpacing.verticalSpaceSm,
            // Usamos Key con el mes para que Flutter reconstruya el widget
            // cuando cambia selectedMonth, reflejando el nuevo initialValue.
            DropdownButtonFormField<int>(
              key: ValueKey(selectedMonth.month),
              initialValue: selectedMonth.month - 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              items: List.generate(12, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text('${months[index]} ${selectedMonth.year}'),
                );
              }),
              onChanged: (int? index) {
                if (index != null) {
                  notifier.changeMonth(index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(WidgetRef ref, bool isGenerating) {
    final notifier = ref.read(reportsScreenProvider.notifier);
    return ElevatedButton.icon(
      onPressed: isGenerating ? null : () => notifier.generateReport(),
      icon: const Icon(Icons.picture_as_pdf),
      label: const Text('Generar Reporte PDF'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
      ),
    );
  }

  Widget _buildPdfReadyBanner() {
    return Card(
      color: AppColors.success.withValues(alpha: 0.1),
      child: Padding(
        padding: AppSpacing.allLg,
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: Text(
                'PDF generado correctamente',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
