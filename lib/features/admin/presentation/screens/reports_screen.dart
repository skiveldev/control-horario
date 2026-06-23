import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/pdf_downloader.dart';
import '../../../../core/services/pdf_downloader_factory.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../auth/models/user_model.dart';
import '../../../dashboard/models/time_record_model.dart';
import '../../../dashboard/providers/time_records_provider.dart';
import '../../../dashboard/services/report_service.dart';
import '../../providers/admin_provider.dart';

/// Provider para el servicio de reportes (sobreescribible en tests)
final reportServiceProvider = Provider<ReportService>((ref) {
  return const ReportService();
});

/// Provider para el descargador de PDFs (sobreescribible en tests).
final pdfDownloaderProvider = Provider<PdfDownloader>((ref) {
  return createPlatformPdfDownloader();
});

/// Estado de la pantalla de reportes (para testing)
class ReportsScreenState {
  final bool isGenerating;
  final bool hasPdf;
  final DateTime selectedMonth;
  final Uint8List? pdfBytes;
  final UserModel? selectedUser;

  ReportsScreenState({
    this.isGenerating = false,
    this.hasPdf = false,
    DateTime? selectedMonth,
    this.pdfBytes,
    this.selectedUser,
  }) : selectedMonth = selectedMonth ??
            DateTime(DateTime.now().year, DateTime.now().month, 1);

  ReportsScreenState copyWith({
    bool? isGenerating,
    bool? hasPdf,
    DateTime? selectedMonth,
    Uint8List? pdfBytes,
    UserModel? selectedUser,
    bool clearSelectedUser = false,
  }) {
    return ReportsScreenState(
      isGenerating: isGenerating ?? this.isGenerating,
      hasPdf: hasPdf ?? this.hasPdf,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      selectedUser:
          clearSelectedUser ? null : (selectedUser ?? this.selectedUser),
    );
  }
}

/// Notifier para la pantalla de generación de reportes.
///
/// Expone [changeMonth] para actualizar el mes seleccionado,
/// [selectEmployee] para elegir el trabajador,
/// [generateReport] que invoca genuinamente a [ReportService]
/// con datos reales del empleado y registros mensuales, y
/// [downloadReport] para guardar/descargar el PDF generado.
class ReportsScreenNotifier extends StateNotifier<ReportsScreenState> {
  final ReportService _service;
  final PdfDownloader _downloader;
  int _generationToken = 0;

  ReportsScreenNotifier(
    this._service, [
    ReportsScreenState? initialState,
    PdfDownloader? downloader,
  ])  : _downloader = downloader ?? createPlatformPdfDownloader(),
        super(initialState ?? ReportsScreenState());

  /// Selecciona un empleado para el reporte individual.
  ///
  /// Al cambiar de empleado se invalida cualquier PDF generado previamente
  /// (limpia [hasPdf], [pdfBytes] e [isGenerating]) porque los datos del
  /// reporte pertenecen al empleado anterior.
  void selectEmployee(UserModel? user) {
    state = ReportsScreenState(
      selectedMonth: state.selectedMonth,
      selectedUser: user,
      isGenerating: false,
      hasPdf: false,
      pdfBytes: null,
    );
  }

  /// Cambia el mes seleccionado en el dropdown.
  ///
  /// Al cambiar de mes se invalida cualquier PDF generado previamente
  /// (limpia [hasPdf], [pdfBytes] e [isGenerating]) porque los datos del
  /// reporte pertenecen al mes anterior.
  void changeMonth(int monthIndex) {
    state = ReportsScreenState(
      selectedMonth: DateTime(state.selectedMonth.year, monthIndex + 1, 1),
      selectedUser: state.selectedUser,
      isGenerating: false,
      hasPdf: false,
      pdfBytes: null,
    );
  }

  /// Genera un reporte PDF mensual individual usando [ReportService].
  ///
  /// [records] son los registros mensuales del empleado seleccionado.
  /// A partir de ellos se computan horas trabajadas, pausas y resumen
  /// de validaciones. Las horas extra y anomalías no se incluyen en este
  /// reporte (se indica explícitamente en el resumen).
  Future<void> generateReport({
    required List<TimeRecordModel> records,
  }) async {
    final user = state.selectedUser;
    if (user == null) return;

    state = state.copyWith(isGenerating: true, hasPdf: false);

    // Snapshot current selection so stale completions are discarded.
    final capturedUserId = user.userId;
    final capturedMonth = state.selectedMonth;
    final token = ++_generationToken;

    try {
      final monthName = _monthName(state.selectedMonth.month);
      final period = '$monthName ${state.selectedMonth.year}';

      // Computar horas trabajadas (categoría work)
      final totalHoursWorked = records
          .where((r) => r.category == RecordCategory.work)
          .fold<double>(0, (sum, r) => sum + r.durationMinutes / 60);

      // Computar minutos de pausa (categoría breakTime)
      final totalBreakMinutes = records
          .where((r) => r.category == RecordCategory.breakTime)
          .fold<int>(0, (sum, r) => sum + r.durationMinutes);

      // Contar registros validados y pendientes
      final validatedCount = records
          .where((r) => r.validationStatus == ValidationStatus.validated)
          .length;
      final pendingCount = records
          .where((r) => r.validationStatus == ValidationStatus.editable)
          .length;

      final validationSummary = StringBuffer();
      if (validatedCount > 0 || pendingCount > 0) {
        validationSummary.write(
          '$validatedCount registros validados, $pendingCount pendientes. ',
        );
      }
      validationSummary.write(
        'Horas extra no incluidas en este reporte mensual. '
        'Anomalías no incluidas en este reporte.',
      );

      final employeeName = user.fullName;
      final companyName = user.empresa?.isNotEmpty == true
          ? user.empresa!
          : 'Sin empresa asignada';

      final bytes = await _service.generateMonthlyReport(
        employeeName: employeeName,
        companyName: companyName,
        period: period,
        totalHoursWorked: totalHoursWorked,
        totalBreakMinutes: totalBreakMinutes,
        overtimeHours: 0,
        anomalyCountByType: const {},
        validationSummary: validationSummary.toString(),
        anomaliesIncluded: false,
        overtimeIncluded: false,
      );

      // Guard: discard stale result if user/month changed or a newer
      // generation was requested while this one was in flight.
      if (token != _generationToken ||
          state.selectedUser?.userId != capturedUserId ||
          state.selectedMonth.month != capturedMonth.month) {
        return;
      }

      state = state.copyWith(
        isGenerating: false,
        hasPdf: true,
        pdfBytes: bytes,
      );
    } catch (e) {
      if (token == _generationToken) {
        state = state.copyWith(isGenerating: false);
      }
    }
  }

  /// Descarga/guarda el PDF generado usando [PdfDownloader].
  ///
  /// El nombre de archivo se genera de forma segura:
  /// `reporte_<nombre_empleado>_<yyyy_mm>.pdf`.
  Future<void> downloadReport({BuildContext? context}) async {
    final bytes = state.pdfBytes;
    final user = state.selectedUser;
    if (bytes == null || user == null) return;

    final safeName = sanitizeFileName(user.fullName);
    final monthStr = state.selectedMonth.month.toString().padLeft(2, '0');
    final filename =
        'reporte_${safeName}_${state.selectedMonth.year}_$monthStr.pdf';

    try {
      await _downloader.download(
        bytes: bytes,
        filename: filename,
        context: context,
      );
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar: $e')),
        );
      }
    }
  }

  /// Sanitiza el nombre de empleado para usar como nombre de archivo.
  static String sanitizeFileName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâã]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
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
  final downloader = ref.watch(pdfDownloaderProvider);
  return ReportsScreenNotifier(service, null, downloader);
});

/// Pantalla de generación de reportes PDF (Admin/Supervisor)
///
/// Permite seleccionar un empleado, período (mes/año) y generar un reporte
/// de asistencia mensual individual en formato PDF descargable.
///
/// Layout (desktop): header intro → [filter card | preview card] → security card.
/// Layout (mobile/tablet): everything stacks vertically.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsScreenProvider);
    final isGenerating = state.isGenerating;
    final hasPdf = state.hasPdf;
    final pdfBytes = state.pdfBytes;
    final selectedMonth = state.selectedMonth;
    final selectedUser = state.selectedUser;
    final cs = Theme.of(context).colorScheme;
    final isDesktop = context.isDesktop;

    // Empleados disponibles para el selector
    final employeesAsync = ref.watch(allEmployeesProvider);
    final employees = employeesAsync.valueOrNull ?? [];

    // Registros mensuales del empleado seleccionado
    List<TimeRecordModel> records = [];
    bool recordsReady = false;
    if (selectedUser != null) {
      final recordsAsync = ref.watch(
        monthTimeRecordsProvider(
          userId: selectedUser.userId,
          month: selectedMonth,
        ),
      );
      records = recordsAsync.valueOrNull ?? [];
      recordsReady = recordsAsync.hasValue;
    }

    final workerSelected = selectedUser != null;
    final canGenerate = workerSelected && recordsReady && !isGenerating;

    return AdminLayout(
      currentRoute: AppRouter.adminReports,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1 — Header / intro block
          _HeaderIntro(cs: cs),
          AppSpacing.verticalSpaceXl,

          // 2 — Main cards row (responsive)
          if (isDesktop)
            _DesktopCardsRow(
              cs: cs,
              ref: ref,
              isGenerating: isGenerating,
              hasPdf: hasPdf,
              pdfBytes: pdfBytes,
              selectedMonth: selectedMonth,
              employees: employees,
              selectedUser: selectedUser,
              records: records,
              workerSelected: workerSelected,
              canGenerate: canGenerate,
              recordsReady: recordsReady,
            )
          else
            _MobileCardsColumn(
              cs: cs,
              ref: ref,
              isGenerating: isGenerating,
              hasPdf: hasPdf,
              pdfBytes: pdfBytes,
              selectedMonth: selectedMonth,
              employees: employees,
              selectedUser: selectedUser,
              records: records,
              workerSelected: workerSelected,
              canGenerate: canGenerate,
              recordsReady: recordsReady,
            ),

          AppSpacing.verticalSpaceXl,

          // 3 — Security / info card
          _SecurityCard(cs: cs),
        ],
      ),
    );
  }
}

// =============================================================================
// HEADER INTRO
// =============================================================================

/// Bloque superior con título, subtítulo y texto explicativo.
class _HeaderIntro extends StatelessWidget {
  final ColorScheme cs;
  const _HeaderIntro({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Generar Reportes',
            style: AppTextStyles.h1.copyWith(color: cs.onSurface)),
        AppSpacing.verticalSpaceSm,
        Text(
          'Panel de generación',
          style: AppTextStyles.h4.copyWith(color: cs.primary),
        ),
        AppSpacing.verticalSpaceXs,
        Text(
          'Selecciona un empleado y período para generar su reporte '
          'individual de asistencia.',
          style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

// =============================================================================
// DESKTOP LAYOUT
// =============================================================================

/// Row con filter card a la izquierda (⅓) y preview card a la derecha (⅔).
class _DesktopCardsRow extends StatelessWidget {
  final ColorScheme cs;
  final WidgetRef ref;
  final bool isGenerating;
  final bool hasPdf;
  final Uint8List? pdfBytes;
  final DateTime selectedMonth;
  final List<UserModel> employees;
  final UserModel? selectedUser;
  final List<TimeRecordModel> records;
  final bool workerSelected;
  final bool canGenerate;
  final bool recordsReady;

  const _DesktopCardsRow({
    required this.cs,
    required this.ref,
    required this.isGenerating,
    required this.hasPdf,
    required this.pdfBytes,
    required this.selectedMonth,
    required this.employees,
    required this.selectedUser,
    required this.records,
    required this.workerSelected,
    required this.canGenerate,
    required this.recordsReady,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: _FilterCard(
            cs: cs,
            ref: ref,
            isGenerating: isGenerating,
            selectedMonth: selectedMonth,
            employees: employees,
            selectedUser: selectedUser,
            records: records,
            workerSelected: workerSelected,
            canGenerate: canGenerate,
            recordsReady: recordsReady,
          ),
        ),
        AppSpacing.horizontalSpaceXxl,
        Expanded(
          flex: 8,
          child: _PreviewCard(
            cs: cs,
            ref: ref,
            isGenerating: isGenerating,
            hasPdf: hasPdf,
            pdfBytes: pdfBytes,
            selectedUser: selectedUser,
            selectedMonth: selectedMonth,
            records: records,
            workerSelected: workerSelected,
            recordsReady: recordsReady,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MOBILE / TABLET LAYOUT
// =============================================================================

/// Columna apilada: filter card arriba, preview card debajo.
class _MobileCardsColumn extends StatelessWidget {
  final ColorScheme cs;
  final WidgetRef ref;
  final bool isGenerating;
  final bool hasPdf;
  final Uint8List? pdfBytes;
  final DateTime selectedMonth;
  final List<UserModel> employees;
  final UserModel? selectedUser;
  final List<TimeRecordModel> records;
  final bool workerSelected;
  final bool canGenerate;
  final bool recordsReady;

  const _MobileCardsColumn({
    required this.cs,
    required this.ref,
    required this.isGenerating,
    required this.hasPdf,
    required this.pdfBytes,
    required this.selectedMonth,
    required this.employees,
    required this.selectedUser,
    required this.records,
    required this.workerSelected,
    required this.canGenerate,
    required this.recordsReady,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterCard(
          cs: cs,
          ref: ref,
          isGenerating: isGenerating,
          selectedMonth: selectedMonth,
          employees: employees,
          selectedUser: selectedUser,
          records: records,
          workerSelected: workerSelected,
          canGenerate: canGenerate,
          recordsReady: recordsReady,
        ),
        AppSpacing.verticalSpaceXxl,
        _PreviewCard(
          cs: cs,
          ref: ref,
          isGenerating: isGenerating,
          hasPdf: hasPdf,
          pdfBytes: pdfBytes,
          selectedUser: selectedUser,
          selectedMonth: selectedMonth,
          records: records,
          workerSelected: workerSelected,
          recordsReady: recordsReady,
        ),
      ],
    );
  }
}

// =============================================================================
// FILTER CARD
// =============================================================================

/// Tarjeta con selector de empleado, período y botón de generación.
class _FilterCard extends StatelessWidget {
  final ColorScheme cs;
  final WidgetRef ref;
  final bool isGenerating;
  final DateTime selectedMonth;
  final List<UserModel> employees;
  final UserModel? selectedUser;
  final List<TimeRecordModel> records;
  final bool workerSelected;
  final bool canGenerate;
  final bool recordsReady;

  const _FilterCard({
    required this.cs,
    required this.ref,
    required this.isGenerating,
    required this.selectedMonth,
    required this.employees,
    required this.selectedUser,
    required this.records,
    required this.workerSelected,
    required this.canGenerate,
    required this.recordsReady,
  });

  @override
  Widget build(BuildContext context) {
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusLg,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      color: cs.surfaceContainerLowest,
      child: Padding(
        padding: AppSpacing.allXxl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card header
            Row(
              children: [
                Icon(Icons.tune, size: AppSpacing.iconMd, color: cs.primary),
                AppSpacing.horizontalSpaceSm,
                Text(
                  'Filtros de Reporte',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceLg,

            // Empleado selector
            Text(
              'Empleado',
              style: AppTextStyles.labelLarge.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.verticalSpaceSm,

            DropdownButtonFormField<String>(
              key: ValueKey(selectedUser?.userId ?? 'no-user'),
              initialValue: selectedUser?.userId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                filled: true,
                fillColor: cs.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                hintText: 'Seleccionar empleado',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              items: employees.map((user) {
                String label = user.fullName;
                if (user.department != null && user.department!.isNotEmpty) {
                  label += ' — ${user.department}';
                }
                return DropdownMenuItem<String>(
                  value: user.userId,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (String? userId) {
                if (userId == null) {
                  notifier.selectEmployee(null);
                  return;
                }
                final user =
                    employees.where((e) => e.userId == userId).firstOrNull;
                notifier.selectEmployee(user);
              },
            ),

            AppSpacing.verticalSpaceLg,

            // Período label
            Text(
              'Período',
              style: AppTextStyles.labelLarge.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.verticalSpaceSm,

            // Dropdown de mes
            DropdownButtonFormField<int>(
              key: ValueKey(selectedMonth.month),
              initialValue: selectedMonth.month - 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                filled: true,
                fillColor: cs.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(
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

            // Records status indicator (loading / error)
            if (workerSelected && !recordsReady && !isGenerating) ...[
              AppSpacing.verticalSpaceMd,
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Expanded(
                    child: Text(
                      'Cargando registros del mes...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            AppSpacing.verticalSpaceXl,
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 220,
                child: CustomButton(
                  text: 'Generar Reporte PDF',
                  icon: Icons.picture_as_pdf,
                  variant: ButtonVariant.brand,
                  size: ButtonSize.medium,
                  isLoading: isGenerating,
                  onPressed: canGenerate
                      ? () => notifier.generateReport(records: records)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PREVIEW / STATUS CARD
// =============================================================================

/// Muestra el estado actual: vacío, vista previa de datos reales, carga,
/// o PDF listo con opción de descarga.
class _PreviewCard extends StatelessWidget {
  final ColorScheme cs;
  final WidgetRef ref;
  final bool isGenerating;
  final bool hasPdf;
  final Uint8List? pdfBytes;
  final UserModel? selectedUser;
  final DateTime selectedMonth;
  final List<TimeRecordModel> records;
  final bool workerSelected;
  final bool recordsReady;

  const _PreviewCard({
    required this.cs,
    required this.ref,
    required this.isGenerating,
    required this.hasPdf,
    required this.pdfBytes,
    required this.selectedUser,
    required this.selectedMonth,
    required this.records,
    required this.workerSelected,
    required this.recordsReady,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusLg,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      color: cs.surfaceContainerLowest,
      child: Padding(
        padding: AppSpacing.allXxl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card header
            Row(
              children: [
                Icon(Icons.preview,
                    size: AppSpacing.iconMd, color: cs.onSurface),
                AppSpacing.horizontalSpaceSm,
                Text(
                  'Vista Previa',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                // Decorative dots (browser-window style)
                _Dot(color: cs.error.withValues(alpha: 0.4)),
                AppSpacing.horizontalSpaceXs,
                _Dot(color: cs.tertiary.withValues(alpha: 0.5)),
                AppSpacing.horizontalSpaceXs,
                _Dot(color: cs.primary.withValues(alpha: 0.4)),
              ],
            ),
            AppSpacing.verticalSpaceXl,

            // Content area based on state
            if (isGenerating)
              _PreviewLoading(cs: cs)
            else if (hasPdf)
              _PdfReadyBanner(cs: cs, ref: ref)
            else if (!workerSelected)
              _PreviewEmpty(cs: cs)
            else if (!recordsReady)
              _PreviewLoadingRecords(cs: cs)
            else
              _PreviewData(
                cs: cs,
                selectedUser: selectedUser!,
                selectedMonth: selectedMonth,
                records: records,
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PREVIEW SUB-WIDGETS
// =============================================================================

/// Empty state — no worker selected.
class _PreviewEmpty extends StatelessWidget {
  final ColorScheme cs;
  const _PreviewEmpty({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.analytics_outlined,
            size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
        AppSpacing.verticalSpaceMd,
        Text(
          'Selecciona un empleado y un período para previsualizar '
          'el reporte mensual.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Loading while records are being fetched.
class _PreviewLoadingRecords extends StatelessWidget {
  final ColorScheme cs;
  const _PreviewLoadingRecords({required this.cs});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Real data preview — shows employee name, period, hours, breaks, validations.
class _PreviewData extends StatelessWidget {
  final ColorScheme cs;
  final UserModel selectedUser;
  final DateTime selectedMonth;
  final List<TimeRecordModel> records;

  const _PreviewData({
    required this.cs,
    required this.selectedUser,
    required this.selectedMonth,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final monthNames = [
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

    // Computar métricas
    final totalHoursWorked = records
        .where((r) => r.category == RecordCategory.work)
        .fold<double>(0, (sum, r) => sum + r.durationMinutes / 60);

    final totalBreakMinutes = records
        .where((r) => r.category == RecordCategory.breakTime)
        .fold<int>(0, (sum, r) => sum + r.durationMinutes);

    final validatedCount = records
        .where((r) => r.validationStatus == ValidationStatus.validated)
        .length;
    final pendingCount = records
        .where((r) => r.validationStatus == ValidationStatus.editable)
        .length;

    final period =
        '${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Employee name & period
        _DataRow(
          icon: Icons.person_outline,
          label: 'Empleado',
          value: selectedUser.fullName,
          cs: cs,
        ),
        AppSpacing.verticalSpaceSm,
        _DataRow(
          icon: Icons.calendar_today,
          label: 'Período',
          value: period,
          cs: cs,
        ),
        AppSpacing.verticalSpaceMd,
        Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
        AppSpacing.verticalSpaceMd,

        // Metrics
        _DataRow(
          icon: Icons.work_outline,
          label: 'Horas trabajadas',
          value: '${totalHoursWorked.toStringAsFixed(1)}h',
          cs: cs,
        ),
        AppSpacing.verticalSpaceSm,
        _DataRow(
          icon: Icons.free_breakfast,
          label: 'Pausas totales',
          value: _formatBreakMinutes(totalBreakMinutes),
          cs: cs,
        ),

        if (validatedCount > 0 || pendingCount > 0) ...[
          AppSpacing.verticalSpaceSm,
          _DataRow(
            icon: Icons.verified_outlined,
            label: 'Validaciones',
            value: '$validatedCount validados, $pendingCount pendientes',
            cs: cs,
          ),
        ],

        AppSpacing.verticalSpaceMd,
        Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
        AppSpacing.verticalSpaceMd,

        // Honest notes
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NoteRow(
                icon: Icons.info_outline,
                text: 'Horas extra no incluidas en este reporte mensual.',
                cs: cs,
              ),
              AppSpacing.verticalSpaceXs,
              _NoteRow(
                icon: Icons.info_outline,
                text: 'Anomalías no incluidas en este reporte.',
                cs: cs,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatBreakMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// Data row for the preview panel.
class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;

  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        AppSpacing.horizontalSpaceSm,
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Note row for the honesty panel.
class _NoteRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme cs;

  const _NoteRow({
    required this.icon,
    required this.text,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
        AppSpacing.horizontalSpaceXs,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

/// Loading state inside preview card during generation.
class _PreviewLoading extends StatelessWidget {
  final ColorScheme cs;
  const _PreviewLoading({required this.cs});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// PDF success banner + download button inside preview card.
class _PdfReadyBanner extends StatelessWidget {
  final ColorScheme cs;
  final WidgetRef ref;

  const _PdfReadyBanner({
    required this.cs,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(reportsScreenProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: AppSpacing.allXxl,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.15),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: cs.primaryContainer.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle,
                  color: cs.primary, size: AppSpacing.iconXl),
              AppSpacing.horizontalSpaceMd,
              Expanded(
                child: Text(
                  'PDF generado correctamente',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.verticalSpaceLg,
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 180,
            child: CustomButton(
              text: 'Descargar PDF',
              icon: Icons.download,
              variant: ButtonVariant.brand,
              size: ButtonSize.medium,
              onPressed: () => notifier.downloadReport(context: context),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// DECORATIVE WIDGETS
// =============================================================================

/// Decorative dot (browser-window header dots).
class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// =============================================================================
// SECURITY / INFO CARD
// =============================================================================

/// Tarjeta informativa con recomendación de seguridad.
class _SecurityCard extends StatelessWidget {
  final ColorScheme cs;
  const _SecurityCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusLg,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: AppSpacing.allXxl,
        child: Row(
          children: [
            // Shield icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(
                Icons.shield_outlined,
                color: cs.primary,
                size: AppSpacing.iconLg,
              ),
            ),
            AppSpacing.horizontalSpaceLg,
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recomendación de seguridad',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalSpaceXs,
                  Text(
                    'Los reportes contienen datos sensibles de asistencia y '
                    'jornada laboral. Compártelos únicamente por canales '
                    'internos seguros y respeta las políticas de privacidad '
                    'de tu organización.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
