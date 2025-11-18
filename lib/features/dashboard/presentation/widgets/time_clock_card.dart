import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
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
/// 
/// MOCK DATA: Simula el fichaje localmente.
/// TODO [FASE-2]: Conectar con backend real
class TimeClockCard extends StatefulWidget {
  const TimeClockCard({super.key});

  @override
  State<TimeClockCard> createState() => _TimeClockCardState();
}

class _TimeClockCardState extends State<TimeClockCard> {
  ClockingState _currentState = ClockingState.notStarted;
  bool _isLoading = false;
  String _statusMessage = 'Sin registro activo';

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      elevation: CardElevation.low,
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
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceSm,
              Text(
                'Registro de Jornada',
                style: AppTextStyles.h5,
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
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(),
                  size: AppSpacing.iconSm,
                  color: _getStatusColor(),
                ),
                AppSpacing.horizontalSpaceSm,
                Flexible(
                  child: Text(
                    _statusMessage,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _getStatusColor(),
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
            currentState: _currentState,
            isLoading: _isLoading,
            onAction: _handleClockingAction,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HANDLERS
  // ==========================================================================

  Future<void> _handleClockingAction(ClockingAction action) async {
    setState(() => _isLoading = true);

    // TODO [FASE-2]: Realizar petición al backend
    // try {
    //   await ref.read(clockingProvider).registerAction(action);
    // } catch (e) {
    //   _showErrorSnackBar(e.toString());
    // }

    // MOCK: Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Actualizar estado según la acción
    setState(() {
      switch (action) {
        case ClockingAction.entrance:
          _currentState = ClockingState.working;
          _statusMessage = '¡Entrada registrada! Trabajando...';
          _showSuccessSnackBar('Entrada registrada correctamente');
          break;

        case ClockingAction.exit:
          _currentState = ClockingState.finished;
          _statusMessage = '¡Jornada completada! Hasta mañana';
          _showSuccessSnackBar('Salida registrada correctamente');
          break;

        case ClockingAction.pause:
          _currentState = ClockingState.onPause;
          _statusMessage = 'En pausa. Recuerda registrar tu retorno';
          _showSuccessSnackBar('Pausa registrada correctamente');
          break;

        case ClockingAction.returnFromPause:
          _currentState = ClockingState.working;
          _statusMessage = '¡Retorno registrado! Trabajando...';
          _showSuccessSnackBar('Retorno registrado correctamente');
          break;
      }

      _isLoading = false;
    });
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  Color _getStatusColor() {
    switch (_currentState) {
      case ClockingState.notStarted:
        return AppColors.textSecondary;
      case ClockingState.working:
        return AppColors.success;
      case ClockingState.onPause:
        return AppColors.warning;
      case ClockingState.finished:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon() {
    switch (_currentState) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.textOnDark,
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // TODO [FASE-2]: Usar cuando se implemente manejo de errores
  // void _showErrorSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Row(
  //         children: [
  //           const Icon(
  //             Icons.error,
  //             color: AppColors.textOnDark,
  //           ),
  //           AppSpacing.horizontalSpaceMd,
  //           Expanded(
  //             child: Text(message),
  //           ),
  //         ],
  //       ),
  //       backgroundColor: AppColors.error,
  //       duration: const Duration(seconds: 3),
  //     ),
  //   );
  // }
}

