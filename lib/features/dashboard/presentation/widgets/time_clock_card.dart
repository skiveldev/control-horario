import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../providers/clocking_provider.dart';
import '../../providers/clocking_state_provider.dart' as state_provider;
import 'clock_display.dart';
import 'clocking_buttons.dart' as buttons;

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
  // 🔒 Debouncing: previene clicks múltiples
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // ✨ Observar el estado de fichaje desde el provider
    final currentState = ref.watch(state_provider.currentClockingStateProvider);

    // Observar el estado de las acciones de fichaje
    final clockingState = ref.watch(clockingNotifierProvider);

    final colors = AppColorsHelper.of(context);
    final statusMessage = _getStatusMessage(currentState);
    final isLoading = clockingState.isLoading || _isProcessing;

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
              color: _getStatusColor(
                context,
                currentState,
              ).withValues(alpha: 0.1),
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
          buttons.ClockingButtons(
            currentState: _mapToButtonsState(currentState),
            isLoading: isLoading,
            canPause:
                currentState != state_provider.ClockingState.backFromBreak,
            onAction: _handleClockingAction,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HANDLERS
  // ==========================================================================

  /// Mapear estado del provider a estado de botones
  buttons.ClockingState _mapToButtonsState(
      state_provider.ClockingState providerState) {
    switch (providerState) {
      case state_provider.ClockingState.notStarted:
        return buttons.ClockingState.notStarted;
      case state_provider.ClockingState.working:
      case state_provider.ClockingState.backFromBreak:
        return buttons.ClockingState.working;
      case state_provider.ClockingState.onBreak:
        return buttons.ClockingState.onPause;
      case state_provider.ClockingState.finished:
        return buttons.ClockingState.finished;
    }
  }

  Future<void> _handleClockingAction(buttons.ClockingAction action) async {
    // 🔒 Prevenir clicks múltiples
    if (_isProcessing) {
      debugPrint('⚠️ Click ignorado: operación en curso');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      switch (action) {
        case buttons.ClockingAction.entrance:
          debugPrint('🟢 [UI] ENTRADA');
          await ref.read(clockingNotifierProvider.notifier).clockIn();
          if (mounted) {
            _showSuccessSnackBar('Entrada registrada correctamente');
          }
          break;

        case buttons.ClockingAction.exit:
          debugPrint('🔴 [UI] SALIDA');
          await ref.read(clockingNotifierProvider.notifier).clockOut();
          if (mounted) {
            _showSuccessSnackBar('Salida registrada correctamente');
          }
          break;

        case buttons.ClockingAction.pause:
          debugPrint('🟠 [UI] PAUSA');
          await ref.read(clockingNotifierProvider.notifier).startBreak();
          if (mounted) {
            _showSuccessSnackBar('Pausa iniciada. ¡Disfruta tu descanso!');
          }
          break;

        case buttons.ClockingAction.returnFromPause:
          debugPrint('🟢 [UI] RETORNO');
          await ref.read(clockingNotifierProvider.notifier).endBreak();
          if (mounted) {
            _showSuccessSnackBar('¡De vuelta al trabajo!');
          }
          break;
      }

      // ✅ Ya NO necesitamos delay: el campo recordStatus es explícito
      // y las transacciones atómicas garantizan consistencia
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  String _getStatusMessage(state_provider.ClockingState state) {
    switch (state) {
      case state_provider.ClockingState.notStarted:
        return 'Sin registro activo';
      case state_provider.ClockingState.working:
        return '¡Trabajando! No olvides fichar tu salida';
      case state_provider.ClockingState.onBreak:
        return '☕ En pausa. Disfruta tu descanso';
      case state_provider.ClockingState.backFromBreak:
        return '¡De vuelta! Ya puedes fichar tu salida';
      case state_provider.ClockingState.finished:
        return '✅ Jornada completada. ¡Buen trabajo!';
    }
  }

  Color _getStatusColor(
      BuildContext context, state_provider.ClockingState state) {
    final colors = AppColorsHelper.of(context);
    switch (state) {
      case state_provider.ClockingState.notStarted:
        return colors.textSecondary;
      case state_provider.ClockingState.working:
        return colors.success;
      case state_provider.ClockingState.onBreak:
        return colors.warning;
      case state_provider.ClockingState.backFromBreak:
        return colors.success;
      case state_provider.ClockingState.finished:
        return colors.info;
    }
  }

  IconData _getStatusIcon(state_provider.ClockingState state) {
    switch (state) {
      case state_provider.ClockingState.notStarted:
        return Icons.schedule;
      case state_provider.ClockingState.working:
        return Icons.work;
      case state_provider.ClockingState.onBreak:
        return Icons.pause_circle;
      case state_provider.ClockingState.backFromBreak:
        return Icons.work;
      case state_provider.ClockingState.finished:
        return Icons.check_circle;
    }
  }

  void _showSuccessSnackBar(String message) {
    final colors = AppColorsHelper.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: colors.textOnDark),
            AppSpacing.horizontalSpaceMd,
            Expanded(child: Text(message)),
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
            Icon(Icons.error, color: colors.textOnDark),
            AppSpacing.horizontalSpaceMd,
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: colors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
