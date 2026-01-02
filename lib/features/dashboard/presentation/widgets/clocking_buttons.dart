import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';

/// Tipo de acción de fichaje
enum ClockingAction { entrance, exit, pause, returnFromPause }

/// Estado actual del fichaje
enum ClockingState { notStarted, working, onPause, finished }

/// Botones de fichaje (Entrada, Salida, Pausa, Retorno)
///
/// Los 4 botones principales para gestionar el fichaje diario.
/// Maneja los estados visuales de cada botón según el flujo.
///
/// Flujo de fichaje:
/// 1. Sin fichar → Solo Entrada habilitado
/// 2. Trabajando (primera vez) → Salida y Pausa habilitados
/// 3. En pausa → Solo Retorno habilitado
/// 4. De vuelta de pausa → Solo Salida habilitado (Pausa deshabilitado)
/// 5. Completo → Entrada habilitado (permite múltiples ciclos en el día)
///
/// ⚠️ IMPORTANTE: Solo se permite UNA pausa por día para optimizar costos de Firebase.
/// Después del primer retorno, el botón Pausa queda permanentemente deshabilitado.
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

  /// Si se puede pausar (false después del primer retorno)
  /// ⚠️ Usado para limitar a 1 pausa por día y optimizar costos Firebase
  final bool canPause;

  const ClockingButtons({
    super.key,
    required this.currentState,
    required this.onAction,
    this.isLoading = false,
    this.canPause = true, // Por defecto permitido
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
              _buildRow([_buildEntranceButton(), _buildExitButton()]),
              AppSpacing.verticalSpaceMd,
              _buildRow([_buildPauseButton(), _buildReturnButton()]),
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
    // Habilitar en estado inicial O después de fichar salida (permitir múltiples ciclos)
    final isEnabled = (currentState == ClockingState.notStarted ||
            currentState == ClockingState.finished) &&
        !isLoading;

    return CustomButton(
      text: 'Entrada',
      icon: Icons.login,
      variant: isEnabled
          ? ButtonVariant.primary
          : ButtonVariant.secondary, // ← GRADIENTE VERDE
      size: ButtonSize.large,
      fullWidth: true,
      onPressed: isEnabled ? () => onAction(ClockingAction.entrance) : null,
      isLoading: isLoading &&
          (currentState == ClockingState.notStarted ||
              currentState == ClockingState.finished),
    );
  }

  // ==========================================================================
  // BOTÓN DE SALIDA
  // ==========================================================================

  Widget _buildExitButton() {
    // ✨ Permitir salida cuando está trabajando (incluye después de pausas)
    final isEnabled = currentState == ClockingState.working && !isLoading;

    return CustomButton(
      text: 'Salida',
      icon: Icons.logout,
      variant: isEnabled
          ? ButtonVariant.danger
          : ButtonVariant.secondary, // ← ROJO para salir
      size: ButtonSize.large,
      fullWidth: true,
      onPressed: isEnabled ? () => onAction(ClockingAction.exit) : null,
      isLoading: isLoading && currentState == ClockingState.working,
    );
  }

  // ==========================================================================
  // BOTÓN DE PAUSA
  // ==========================================================================

  Widget _buildPauseButton() {
    // ✨ Solo permitir pausar UNA VEZ por día (antes del primer retorno)
    // - currentState debe ser "working"
    // - canPause debe ser true (se vuelve false después del primer retorno)
    //
    // RAZÓN: Limitar a 1 pausa por día para optimizar costos de Firebase
    final isEnabled =
        currentState == ClockingState.working && canPause && !isLoading;

    return CustomButton(
      text: 'Pausa',
      icon: Icons.pause,
      variant: isEnabled
          ? ButtonVariant.warning
          : ButtonVariant.secondary, // ← GRADIENTE NARANJA (solo si habilitado)
      size: ButtonSize.large,
      fullWidth: true,
      onPressed: isEnabled ? () => onAction(ClockingAction.pause) : null,
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
      onPressed:
          isEnabled ? () => onAction(ClockingAction.returnFromPause) : null,
      isLoading: isLoading && currentState == ClockingState.onPause,
    );
  }
}
