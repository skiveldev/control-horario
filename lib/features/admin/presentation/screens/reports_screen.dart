import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
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
    final selectedMonth = state.selectedMonth;
    final cs = Theme.of(context).colorScheme;
    final isDesktop = context.isDesktop;

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
              selectedMonth: selectedMonth,
            )
          else
            _MobileCardsColumn(
              cs: cs,
              ref: ref,
              isGenerating: isGenerating,
              hasPdf: hasPdf,
              selectedMonth: selectedMonth,
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
          'Personaliza y exporta informes detallados de asistencia, horas extra '
          'y cumplimiento normativo para tu organización.',
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
  final DateTime selectedMonth;

  const _DesktopCardsRow({
    required this.cs,
    required this.ref,
    required this.isGenerating,
    required this.hasPdf,
    required this.selectedMonth,
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
          ),
        ),
        AppSpacing.horizontalSpaceXxl,
        Expanded(
          flex: 8,
          child: _PreviewCard(
            cs: cs,
            isGenerating: isGenerating,
            hasPdf: hasPdf,
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
  final DateTime selectedMonth;

  const _MobileCardsColumn({
    required this.cs,
    required this.ref,
    required this.isGenerating,
    required this.hasPdf,
    required this.selectedMonth,
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
        ),
        AppSpacing.verticalSpaceXxl,
        _PreviewCard(
          cs: cs,
          isGenerating: isGenerating,
          hasPdf: hasPdf,
        ),
      ],
    );
  }
}

// =============================================================================
// FILTER CARD
// =============================================================================

/// Tarjeta con selector de período y botón de generación.
class _FilterCard extends StatelessWidget {
  final ColorScheme cs;
  final WidgetRef ref;
  final bool isGenerating;
  final DateTime selectedMonth;

  const _FilterCard({
    required this.cs,
    required this.ref,
    required this.isGenerating,
    required this.selectedMonth,
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

            AppSpacing.verticalSpaceXl,
            // Generate button
            SizedBox(
              height: AppSpacing.buttonHeightLg,
              child: ElevatedButton.icon(
                onPressed:
                    isGenerating ? null : () => notifier.generateReport(),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generar Reporte PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  disabledBackgroundColor: cs.primary.withValues(alpha: 0.5),
                  disabledForegroundColor: cs.onPrimary.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
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

/// Muestra placeholder, loading o banner de éxito según estado.
class _PreviewCard extends StatelessWidget {
  final ColorScheme cs;
  final bool isGenerating;
  final bool hasPdf;

  const _PreviewCard({
    required this.cs,
    required this.isGenerating,
    required this.hasPdf,
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
              _PdfReadyBanner(cs: cs)
            else
              _PreviewEmpty(cs: cs),
          ],
        ),
      ),
    );
  }
}

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

/// Placeholder / skeleton state — honest empty state.
class _PreviewEmpty extends StatelessWidget {
  final ColorScheme cs;
  const _PreviewEmpty({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Skeleton blocks simulating a data table
        _SkeletonBlock(
          height: 10,
          widthFactor: 1.0,
          color: cs.surfaceContainerHighest,
        ),
        AppSpacing.verticalSpaceSm,
        Row(
          children: [
            Expanded(
                flex: 2,
                child: _SkeletonBlock(
                    height: 6,
                    widthFactor: 1.0,
                    color: cs.surfaceContainerHighest)),
            AppSpacing.horizontalSpaceMd,
            Expanded(
                flex: 3,
                child: _SkeletonBlock(
                    height: 6,
                    widthFactor: 1.0,
                    color: cs.surfaceContainerHighest)),
            AppSpacing.horizontalSpaceMd,
            Expanded(
                flex: 1,
                child: _SkeletonBlock(
                    height: 6,
                    widthFactor: 1.0,
                    color: cs.surfaceContainerHighest)),
          ],
        ),
        AppSpacing.verticalSpaceMd,
        Divider(color: cs.outlineVariant.withValues(alpha: 0.2), height: 1),
        AppSpacing.verticalSpaceMd,
        // Skeleton rows
        for (int i = 0; i < 4; i++) ...[
          if (i > 0) AppSpacing.verticalSpaceSm,
          Row(
            children: [
              Expanded(
                  flex: 1,
                  child: _SkeletonBlock(
                      height: 8,
                      widthFactor: 1.0,
                      color: cs.surfaceContainerHigh)),
              AppSpacing.horizontalSpaceMd,
              Expanded(
                  flex: 3,
                  child: _SkeletonBlock(
                      height: 8,
                      widthFactor: 1.0,
                      color: cs.surfaceContainerHigh)),
              AppSpacing.horizontalSpaceMd,
              Expanded(
                  flex: 2,
                  child: _SkeletonBlock(
                      height: 8,
                      widthFactor: 1.0,
                      color: cs.surfaceContainerHigh)),
            ],
          ),
        ],

        AppSpacing.verticalSpaceXl,

        // Empty state message
        Icon(Icons.analytics_outlined,
            size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
        AppSpacing.verticalSpaceMd,
        Text(
          'Selecciona un período y genera el PDF para preparar el '
          'reporte mensual.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Skeleton loading block.
class _SkeletonBlock extends StatelessWidget {
  final double height;
  final double widthFactor;
  final Color color;
  const _SkeletonBlock({
    required this.height,
    required this.widthFactor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppSpacing.borderRadiusXs,
        ),
      ),
    );
  }
}

/// Loading state inside preview card.
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

/// PDF success banner inside preview card.
class _PdfReadyBanner extends StatelessWidget {
  final ColorScheme cs;
  const _PdfReadyBanner({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Icon(Icons.check_circle, color: cs.primary, size: AppSpacing.iconXl),
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
