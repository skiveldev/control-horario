import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';

/// Tipo de acción de fichaje
enum ClockingAction {
  entrance,
  exit,
  pause,
  returnFromPause,
}

/// Estado actual del fichaje
enum ClockingState {
  notStarted,
  working,
  onPause,
  finished,
}

/// Botones de fichaje (Entrada, Salida, Pausa, Retorno)
/// 
/// Los 4 botones principales para gestionar el fichaje diario.
/// Maneja los estados visuales de cada botón según el flujo.
/// 
/// Flujo de fichaje:
/// 1. Sin fichar → Solo Entrada habilitado
/// 2. Trabajando → Salida y Pausa habilitados
/// 3. En pausa → Solo Retorno habilitado
/// 4. Completo → Todos deshabilitados
/// 
/// Ejemplo de uso:
/// ```dart
/// ClockingButtons(
///   currentState: ClockingState.notStarted,
///   onAction: (action) {
///     print('Acción: $action');
///   },
/// )
/// ```
class ClockingButtons extends StatelessWidget {
  /// Estado actual del fichaje
  final ClockingState currentState;

  /// Callback al presionar cualquier botón
  final void Function(ClockingAction) onAction;

  /// Si está procesando una acción
  final bool isLoading;

  const ClockingButtons({
    super.key,
    required this.currentState,
    required this.onAction,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el ancho es pequeño, poner botones en 2 filas
        final useCompactLayout = constraints.maxWidth < 400;

        if (useCompactLayout) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRow([
                _buildEntranceButton(),
                _buildExitButton(),
              ]),
              AppSpacing.verticalSpaceMd,
              _buildRow([
                _buildPauseButton(),
                _buildReturnButton(),
              ]),
            ],
          );
        }

        // Layout normal: 4 botones en una fila
        return Row(
          children: [
            Expanded(child: _buildEntranceButton()),
            AppSpacing.horizontalSpaceMd,
            Expanded(child: _buildExitButton()),
            AppSpacing.horizontalSpaceMd,
            Expanded(child: _buildPauseButton()),
            AppSpacing.horizontalSpaceMd,
            Expanded(child: _buildReturnButton()),
          ],
        );
      },
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: [
        Expanded(child: children[0]),
        AppSpacing.horizontalSpaceMd,
        Expanded(child: children[1]),
      ],
    );
  }

  // ==========================================================================
  // BOTÓN DE ENTRADA
  // ==========================================================================

  Widget _buildEntranceButton() {
    final isEnabled = currentState == ClockingState.notStarted && !isLoading;

    return CustomButton(
      text: 'Entrada',
      icon: Icons.login,
      variant: isEnabled ? ButtonVariant.success : ButtonVariant.secondary,
      size: ButtonSize.large,
      fullWidth: true,
      onPressed: isEnabled
          ? () => onAction(ClockingAction.entrance)
          : null,
      isLoading: isLoading && currentState == ClockingState.notStarted,
    );
  }

  // ==========================================================================
  // BOTÓN DE SALIDA
  // ==========================================================================

  Widget _buildExitButton() {
    final isEnabled = currentState == ClockingState.working && !isLoading;

    return CustomButton(
      text: 'Salida',
      icon: Icons.logout,
      variant: ButtonVariant.primary,
      size: ButtonSize.large,
      fullWidth: true,
      onPressed: isEnabled
          ? () => onAction(ClockingAction.exit)
          : null,
      isLoading: isLoading && currentState == ClockingState.working,
    );
  }

  // ==========================================================================
  // BOTÓN DE PAUSA
  // ==========================================================================

  Widget _buildPauseButton() {
    final isEnabled = currentState == ClockingState.working && !isLoading;

    return CustomButton(
      text: 'Pausa',
      icon: Icons.pause,
      variant: ButtonVariant.outline,
      size: ButtonSize.large,
      fullWidth: true,
      onPressed: isEnabled
          ? () => onAction(ClockingAction.pause)
          : null,
    );
  }

  // ==========================================================================
  // BOTÓN DE RETORNO
  // ==========================================================================

  Widget _buildReturnButton() {
    final isEnabled = currentState == ClockingState.onPause && !isLoading;

    return CustomButton(
      text: 'Retorno',
      icon: Icons.play_arrow,
      variant: isEnabled ? ButtonVariant.success : ButtonVariant.secondary,
      size: ButtonSize.large,
      fullWidth: true,
      onPressed: isEnabled
          ? () => onAction(ClockingAction.returnFromPause)
          : null,
      isLoading: isLoading && currentState == ClockingState.onPause,
    );
  }
}

