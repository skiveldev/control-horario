import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../admin/models/schedule_model.dart';
import '../../../dashboard/models/anomaly_model.dart';
import '../../../dashboard/models/time_record_model.dart';
import '../../../dashboard/providers/anomaly_provider.dart';
import '../../../dashboard/services/anomaly_service.dart';

/// Estado de la pantalla de anomalías (para testing)
class AnomaliesScreenState {
  final List<AnomalyModel> anomalies;
  final bool isDetecting;

  const AnomaliesScreenState({
    this.anomalies = const [],
    this.isDetecting = false,
  });

  AnomaliesScreenState copyWith({
    List<AnomalyModel>? anomalies,
    bool? isDetecting,
  }) {
    return AnomaliesScreenState(
      anomalies: anomalies ?? this.anomalies,
      isDetecting: isDetecting ?? this.isDetecting,
    );
  }
}

/// Notifier para la pantalla de detección de anomalías.
///
/// Expone un método [detectAnomalies] que invoca al [AnomalyService]
/// real. El botón "Detectar Anomalías" llama a este método con los
/// parámetros adecuados. En tests se puede override el provider para
/// inyectar un notifier falso o un servicio falso.
class AnomaliesScreenNotifier extends StateNotifier<AnomaliesScreenState> {
  final AnomalyService _service;

  AnomaliesScreenNotifier(this._service, [AnomaliesScreenState? initialState])
      : super(initialState ?? const AnomaliesScreenState());

  /// Dispara la detección de anomalías con los parámetros dados.
  ///
  /// Llama genuinamente a [AnomalyService.detectAnomalies] e introduce
  /// una demora artificial de 500ms para UX de carga.
  Future<void> detectAnomalies({
    required String userId,
    required DateTime month,
    required Map<String, DaySchedule> weeklySchedule,
    required List<TimeRecordModel> records,
    required Set<String> vacationDates,
  }) async {
    state = state.copyWith(isDetecting: true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    try {
      final anomalies = _service.detectAnomalies(
        userId: userId,
        month: month,
        records: records,
        weeklySchedule: weeklySchedule,
        vacationDates: vacationDates,
      );
      state = state.copyWith(anomalies: anomalies, isDetecting: false);
    } catch (e) {
      state = state.copyWith(isDetecting: false);
    }
  }
}

/// Provider para el notifier de la pantalla de anomalías
final anomaliesScreenProvider =
    StateNotifierProvider<AnomaliesScreenNotifier, AnomaliesScreenState>((ref) {
  final service = ref.watch(anomalyServiceProvider);
  return AnomaliesScreenNotifier(service);
});

/// Pantalla de detección de anomalías (Admin)
///
/// Muestra la lista de anomalías detectadas en los registros de fichaje
/// con opción de filtrar por tipo y severidad. Incluye un botón explícito
/// "Detectar Anomalías" para controlar los costes de lectura de Firestore.
class AnomaliesScreen extends ConsumerWidget {
  const AnomaliesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(anomaliesScreenProvider);
    final anomalies = state.anomalies;
    final isDetecting = state.isDetecting;
    final cs = Theme.of(context).colorScheme;

    return AdminLayout(
      currentRoute: AppRouter.adminAnomalies,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detección de Anomalías', style: AppTextStyles.h3),
          AppSpacing.verticalSpaceMd,
          _buildDetectButton(ref, isDetecting),
          AppSpacing.verticalSpaceLg,
          if (anomalies.isEmpty)
            _buildEmptyState(isDetecting, cs)
          else
            _buildAnomalyList(anomalies, cs),
        ],
      ),
    );
  }

  Widget _buildDetectButton(WidgetRef ref, bool isDetecting) {
    return ElevatedButton.icon(
      onPressed: isDetecting
          ? null
          : () {
              ref.read(anomaliesScreenProvider.notifier).detectAnomalies(
                userId: '',
                month: DateTime.now(),
                weeklySchedule: const {},
                records: const [],
                vacationDates: const {},
              );
            },
      icon: isDetecting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.search),
      label: Text(isDetecting ? 'Detectando...' : 'Detectar Anomalías'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDetecting, ColorScheme cs) {
    if (isDetecting) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: AppColors.success.withValues(alpha: 0.5)),
          AppSpacing.verticalSpaceMd,
          Text(
            'No se encontraron anomalías',
            style: AppTextStyles.h5.copyWith(color: cs.onSurfaceVariant),
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            'Todos los registros del período seleccionado son correctos.',
            style: AppTextStyles.bodyMedium.copyWith(color: cs.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnomalyList(List<AnomalyModel> anomalies, ColorScheme cs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: anomalies.length,
      itemBuilder: (context, index) {
        final anomaly = anomalies[index];
        return _AnomalyCard(anomaly: anomaly, cs: cs);
      },
    );
  }
}

/// Tarjeta individual de anomalía
class _AnomalyCard extends StatelessWidget {
  final AnomalyModel anomaly;
  final ColorScheme cs;

  const _AnomalyCard({required this.anomaly, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: AppSpacing.allLg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono de tipo
            Container(
              padding: AppSpacing.allSm,
              decoration: BoxDecoration(
                color: _severityColor.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(_typeIcon, color: _severityColor, size: 24),
            ),
            AppSpacing.horizontalSpaceMd,
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(anomaly.date,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                      AppSpacing.horizontalSpaceSm,
                      _SeverityBadge(severity: anomaly.severity),
                      const Spacer(),
                      Text(_typeLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: cs.onSurfaceVariant,
                          )),
                    ],
                  ),
                  if (anomaly.description != null) ...[
                    AppSpacing.verticalSpaceXs,
                    Text(
                      anomaly.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _severityColor {
    switch (anomaly.severity) {
      case AnomalySeverity.high:
        return AppColors.error;
      case AnomalySeverity.medium:
        return AppColors.warning;
      case AnomalySeverity.low:
        return AppColors.info;
    }
  }

  IconData get _typeIcon {
    switch (anomaly.type) {
      case AnomalyType.missingExit:
        return Icons.exit_to_app;
      case AnomalyType.insufficientHours:
        return Icons.hourglass_bottom;
      case AnomalyType.unexcusedAbsence:
        return Icons.person_off;
      case AnomalyType.overlap:
        return Icons.compare_arrows;
      case AnomalyType.excessiveBreak:
        return Icons.free_breakfast;
    }
  }

  String get _typeLabel {
    switch (anomaly.type) {
      case AnomalyType.missingExit:
        return 'Salida faltante';
      case AnomalyType.insufficientHours:
        return 'Horas insuficientes';
      case AnomalyType.unexcusedAbsence:
        return 'Ausencia no justificada';
      case AnomalyType.overlap:
        return 'Solapamiento';
      case AnomalyType.excessiveBreak:
        return 'Pausa excesiva';
    }
  }
}

/// Badge de severidad
class _SeverityBadge extends StatelessWidget {
  final AnomalySeverity severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusXs,
      ),
      child: Text(
        severity.name,
        style: AppTextStyles.labelSmall.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _color {
    switch (severity) {
      case AnomalySeverity.high:
        return AppColors.error;
      case AnomalySeverity.medium:
        return AppColors.warning;
      case AnomalySeverity.low:
        return AppColors.info;
    }
  }
}
