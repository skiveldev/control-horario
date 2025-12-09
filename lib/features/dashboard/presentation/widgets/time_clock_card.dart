import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../providers/clocking_provider.dart';
import 'clock_display.dart';
import 'clocking_buttons.dart';

/// Card principal de fichaje
/// 
/// Contiene:
/// - Reloj digital con hora actual
/// - 4 botones de acción (Entrada, Salida, Pausa, Retorno)
/// - Mensaje de estado actual
/// 
/// Maneja el flujo de fichaje diario con estados visuales.
/// Conectado con Riverpod para fichaje real en Firebase.
class TimeClockCard extends ConsumerStatefulWidget {
  const TimeClockCard({super.key});

  @override
  ConsumerState<TimeClockCard> createState() => _TimeClockCardState();
}

class _TimeClockCardState extends ConsumerState<TimeClockCard> {

  @override
  Widget build(BuildContext context) {
    // Observar el registro de hoy
    final todayRecordAsync = ref.watch(todayRecordProvider);
    
    // Observar el estado de las acciones de fichaje
    final clockingState = ref.watch(clockingNotifierProvider);

    return todayRecordAsync.when(
      data: (todayRecord) {
        // Determinar estado actual basado en datos de Firestore
        final colors = AppColorsHelper.of(context);
        final currentState = _determineClockingState(todayRecord);
        final statusMessage = _getStatusMessage(currentState);
        final isLoading = clockingState.isLoading;

        return CustomCard(
          elevation: CardElevation.medium,
          padding: AppSpacing.cardLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título del card
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: AppSpacing.iconMd,
                    color: colors.primary,
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Flexible(
                    child: Text(
                      'Registro de Jornada',
                      style: AppTextStyles.h5.copyWith(
                        color: colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              AppSpacing.verticalSpaceXxl,

              // Reloj digital
              const ClockDisplay(),

              AppSpacing.verticalSpaceXxl,

              // Mensaje de estado
              Container(
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(context, currentState).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getStatusIcon(currentState),
                      size: AppSpacing.iconSm,
                      color: _getStatusColor(context, currentState),
                    ),
                    AppSpacing.horizontalSpaceSm,
                    Flexible(
                      child: Text(
                        statusMessage,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _getStatusColor(context, currentState),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalSpaceXxl,

              // Botones de acción
              ClockingButtons(
                currentState: currentState,
                isLoading: isLoading,
                onAction: _handleClockingAction,
              ),
            ],
          ),
        );
      },
      loading: () => CustomCard(
        elevation: CardElevation.medium,
        padding: AppSpacing.cardLarge,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        final colors = AppColorsHelper.of(context);
        return CustomCard(
          elevation: CardElevation.medium,
          padding: AppSpacing.cardLarge,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: colors.error,
                ),
                AppSpacing.verticalSpaceMd,
                Text(
                  'Error al cargar el registro',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.error,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // HANDLERS
  // ==========================================================================

  Future<void> _handleClockingAction(ClockingAction action) async {
    try {
      switch (action) {
        case ClockingAction.entrance:
          await ref.read(clockingNotifierProvider.notifier).clockIn();
          if (mounted) {
            _showSuccessSnackBar('Entrada registrada correctamente');
          }
          break;

        case ClockingAction.exit:
          await ref.read(clockingNotifierProvider.notifier).clockOut();
          if (mounted) {
            _showSuccessSnackBar('Salida registrada correctamente');
          }
          break;

        case ClockingAction.pause:
          // TODO [FASE-2-SPRINT-2]: Implementar pausas
          if (mounted) {
            _showInfoSnackBar('Pausas disponibles en próxima versión');
          }
          break;

        case ClockingAction.returnFromPause:
          // TODO [FASE-2-SPRINT-2]: Implementar retornos
          if (mounted) {
            _showInfoSnackBar('Retornos disponibles en próxima versión');
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error al registrar: ${e.toString()}');
      }
    }
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  /// Determinar estado de fichaje basado en datos de Firestore
  ClockingState _determineClockingState(dynamic todayRecord) {
    if (todayRecord == null) {
      return ClockingState.notStarted;
    }

    final hasClockIn = todayRecord.clockInTimestamp != null;
    final hasClockOut = todayRecord.clockOutTimestamp != null;

    if (hasClockIn && hasClockOut) {
      return ClockingState.finished;
    } else if (hasClockIn && !hasClockOut) {
      return ClockingState.working;
    } else {
      return ClockingState.notStarted;
    }
  }

  /// Obtener mensaje de estado basado en ClockingState
  String _getStatusMessage(ClockingState state) {
    switch (state) {
      case ClockingState.notStarted:
        return 'Sin registro activo';
      case ClockingState.working:
        return '¡Trabajando! No olvides fichar tu salida';
      case ClockingState.onPause:
        return 'En pausa. Recuerda registrar tu retorno';
      case ClockingState.finished:
        return 'Jornada completada. Buen trabajo!';
    }
  }

  Color _getStatusColor(BuildContext context, ClockingState state) {
    final colors = AppColorsHelper.of(context);
    switch (state) {
      case ClockingState.notStarted:
        return colors.textSecondary;
      case ClockingState.working:
        return colors.success;
      case ClockingState.onPause:
        return colors.warning;
      case ClockingState.finished:
        return colors.info;
    }
  }

  IconData _getStatusIcon(ClockingState state) {
    switch (state) {
      case ClockingState.notStarted:
        return Icons.schedule;
      case ClockingState.working:
        return Icons.work;
      case ClockingState.onPause:
        return Icons.pause_circle;
      case ClockingState.finished:
        return Icons.check_circle;
    }
  }

  void _showSuccessSnackBar(String message) {
    final colors = AppColorsHelper.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: colors.textOnDark,
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: colors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final colors = AppColorsHelper.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error,
              color: colors.textOnDark,
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: colors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    final colors = AppColorsHelper.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info,
              color: colors.textOnDark,
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: colors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

