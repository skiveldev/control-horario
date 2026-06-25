import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../dashboard/models/overtime_request_model.dart';
import '../../../dashboard/providers/overtime_provider.dart';
import '../../../dashboard/services/overtime_service.dart';

/// Estado de la pantalla de revisión de horas extra (para testing)
class OvertimeReviewScreenState {
  final List<OvertimeRequestModel> pendingRequests;
  final bool isProcessing;

  const OvertimeReviewScreenState({
    this.pendingRequests = const [],
    this.isProcessing = false,
  });

  OvertimeReviewScreenState copyWith({
    List<OvertimeRequestModel>? pendingRequests,
    bool? isProcessing,
  }) {
    return OvertimeReviewScreenState(
      pendingRequests: pendingRequests ?? this.pendingRequests,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

/// Notifier para la pantalla de revisión de horas extra.
///
/// La pantalla productiva está marcada como próxima funcionalidad. El estado
/// inyectado se mantiene para pruebas y para poder validar el renderizado sin
/// activar todavía flujos de aprobación/rechazo desde la UI.
class OvertimeReviewNotifier extends StateNotifier<OvertimeReviewScreenState> {
  final OvertimeService _service;

  OvertimeReviewNotifier(this._service,
      [OvertimeReviewScreenState? initialState])
      : super(initialState ?? const OvertimeReviewScreenState());

  /// Carga las solicitudes pendientes desde el servicio.
  Future<void> loadPendingRequests() async {
    state = state.copyWith(isProcessing: true);
    try {
      final requests = await _service.getPendingRequests();
      state = state.copyWith(pendingRequests: requests, isProcessing: false);
    } catch (e) {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// Aprueba una solicitud y la elimina de la lista pendiente.
  Future<void> approveRequest(String id, {required String approvedBy}) async {
    state = state.copyWith(isProcessing: true);
    try {
      await _service.approveRequest(id, approvedBy: approvedBy);
      state = state.copyWith(
        pendingRequests:
            state.pendingRequests.where((r) => r.id != id).toList(),
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// Rechaza una solicitud y la elimina de la lista pendiente.
  Future<void> rejectRequest(String id, {required String rejectedBy}) async {
    state = state.copyWith(isProcessing: true);
    try {
      await _service.rejectRequest(id, rejectedBy: rejectedBy);
      state = state.copyWith(
        pendingRequests:
            state.pendingRequests.where((r) => r.id != id).toList(),
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(isProcessing: false);
    }
  }
}

/// Provider para el notifier de la pantalla de revisión de horas extra
final overtimeReviewScreenProvider =
    StateNotifierProvider<OvertimeReviewNotifier, OvertimeReviewScreenState>(
        (ref) {
  final service = ref.watch(overtimeServiceProvider);
  return OvertimeReviewNotifier(service);
});

/// Pantalla de revisión de horas extra (Admin/Supervisor).
///
/// Esta sección está planificada y todavía no expone acciones productivas de
/// aprobación/rechazo.
class OvertimeReviewScreen extends ConsumerWidget {
  const OvertimeReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(overtimeReviewScreenProvider);
    final requests = state.pendingRequests;
    final cs = Theme.of(context).colorScheme;

    return AdminLayout(
      currentRoute: AppRouter.adminOvertime,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revisión de Horas Extra', style: AppTextStyles.h3),
          AppSpacing.verticalSpaceMd,
          if (requests.isEmpty)
            _buildPlannedState(cs)
          else
            _buildRequestList(requests, cs),
        ],
      ),
    );
  }

  Widget _buildPlannedState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 64,
            color: cs.primary.withValues(alpha: 0.55),
          ),
          AppSpacing.verticalSpaceMd,
          Text(
            'Revisión de horas extra en construcción',
            style: AppTextStyles.h5.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            'Próxima funcionalidad',
            style: AppTextStyles.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceMd,
          FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.hourglass_empty),
            label: const Text('Gestión no disponible todavía'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(
    List<OvertimeRequestModel> requests,
    ColorScheme cs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próxima funcionalidad: las acciones de aprobación y rechazo todavía no están disponibles.',
          style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurfaceVariant),
        ),
        AppSpacing.verticalSpaceMd,
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _OvertimeRequestCard(request: request, cs: cs);
          },
        ),
      ],
    );
  }
}

/// Tarjeta individual de solicitud de horas extra
class _OvertimeRequestCard extends StatelessWidget {
  final OvertimeRequestModel request;
  final ColorScheme cs;

  const _OvertimeRequestCard({
    required this.request,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final weekStartFormatted = dateFormat.format(request.weekStart);
    final weekEnd = request.weekStart.add(const Duration(days: 6));
    final weekEndFormatted = dateFormat.format(weekEnd);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: semana y horas
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semana $weekStartFormatted – $weekEndFormatted',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.verticalSpaceXs,
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: cs.onSurfaceVariant),
                          AppSpacing.horizontalSpaceXs,
                          Text(
                            '${request.requestedHours}h extra',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppSpacing.horizontalSpaceMd,
                          _StatusBadge(status: request.status),
                        ],
                      ),
                    ],
                  ),
                ),
                // Acciones planificadas: visibles como intención futura, no activas.
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.check,
                        color: AppColors.success.withValues(alpha: 0.45),
                      ),
                      onPressed: null,
                      tooltip: 'Aprobar no disponible todavía',
                    ),
                    AppSpacing.horizontalSpaceSm,
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.error.withValues(alpha: 0.45),
                      ),
                      onPressed: null,
                      tooltip: 'Rechazar no disponible todavía',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de estado de la solicitud
class _StatusBadge extends StatelessWidget {
  final OvertimeRequestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusXs,
      ),
      child: Text(
        _label,
        style: AppTextStyles.labelSmall.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _color {
    switch (status) {
      case OvertimeRequestStatus.pending:
        return AppColors.warning;
      case OvertimeRequestStatus.approved:
        return AppColors.success;
      case OvertimeRequestStatus.rejected:
        return AppColors.error;
    }
  }

  String get _label {
    switch (status) {
      case OvertimeRequestStatus.pending:
        return 'Pendiente';
      case OvertimeRequestStatus.approved:
        return 'Aprobado';
      case OvertimeRequestStatus.rejected:
        return 'Rechazado';
    }
  }
}
