import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/utils/password_utils.dart';
import '../../../../shared/widgets/inputs/custom_password_field.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';

/// Dialog para cambiar contraseña
///
/// Permite al usuario actualizar su contraseña de forma segura,
/// con validaciones de fortaleza y coincidencia.
///
/// MOCK UI: Solo muestra SnackBar de éxito, sin persistencia real.
/// TODO [FASE-2]: Conectar con Firebase Auth para cambio real de contraseña
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Verifica si el formulario es válido para enviar
  bool get _isFormValid {
    // Campos no vacíos
    if (_currentPassword.isEmpty ||
        _newPassword.isEmpty ||
        _confirmPassword.isEmpty) {
      return false;
    }

    // Fortaleza mínima (al menos media = 2)
    if (calculatePasswordStrength(_newPassword, minLength: 8) < 2) {
      return false;
    }

    // Contraseñas coinciden
    if (_newPassword != _confirmPassword) {
      return false;
    }

    return true;
  }

  /// Obtiene el mensaje de error para el campo de confirmación
  String? get _confirmPasswordError {
    if (_confirmPassword.isEmpty) {
      return null;
    }

    if (_newPassword != _confirmPassword) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  void _handleSave() {
    if (!_isFormValid) return;

    // TODO [FASE-2]: Cambiar contraseña con Firebase Auth
    Navigator.of(context).pop();

    // Mock UI feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contraseña actualizada correctamente'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header con ícono y título
                  _buildHeader(),

                  AppSpacing.verticalSpaceXxl,

                  // Campo: Contraseña actual
                  CustomPasswordField(
                    label: 'Contraseña actual',
                    controller: _currentPasswordController,
                    required: true,
                    helperText: 'Introduce tu contraseña actual',
                    onChanged: (value) {
                      setState(() {
                        _currentPassword = value;
                      });
                    },
                  ),

                  AppSpacing.verticalSpaceLg,

                  // Campo: Nueva contraseña (con indicador de fortaleza)
                  CustomPasswordField(
                    label: 'Nueva contraseña',
                    controller: _newPasswordController,
                    required: true,
                    showStrengthIndicator: true,
                    minLength: 8,
                    helperText: 'Mínimo 8 caracteres',
                    onChanged: (value) {
                      setState(() {
                        _newPassword = value;
                      });
                    },
                  ),

                  AppSpacing.verticalSpaceLg,

                  // Campo: Confirmar contraseña
                  CustomPasswordField(
                    label: 'Confirmar nueva contraseña',
                    controller: _confirmPasswordController,
                    required: true,
                    errorText: _confirmPasswordError,
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value;
                      });
                    },
                  ),

                  AppSpacing.verticalSpaceXxl,

                  // Mensaje de ayuda
                  _buildSecurityNote(),

                  AppSpacing.verticalSpaceXxl,

                  // Botones de acción
                  _buildActions(isMobile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Ícono de seguridad
        Container(
          padding: AppSpacing.allMd,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            Icons.lock_outline,
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        AppSpacing.horizontalSpaceMd,

        // Título
        Expanded(child: Text('Cambiar Contraseña', style: AppTextStyles.h4)),

        // Botón cerrar
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Cerrar',
        ),
      ],
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: AppSpacing.iconSm,
            color: Theme.of(context).colorScheme.primary,
          ),
          AppSpacing.horizontalSpaceSm,
          Expanded(
            child: Text(
              'Tu contraseña debe tener al menos 8 caracteres y combinar mayúsculas, minúsculas, números y símbolos para mayor seguridad.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomButton(
            text: 'Actualizar Contraseña',
            variant: ButtonVariant.primary,
            icon: Icons.check,
            onPressed: _isFormValid ? _handleSave : null,
          ),
          AppSpacing.verticalSpaceMd,
          CustomButton(
            text: 'Cancelar',
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          text: 'Cancelar',
          variant: ButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppSpacing.horizontalSpaceMd,
        CustomButton(
          text: 'Actualizar Contraseña',
          variant: ButtonVariant.primary,
          icon: Icons.check,
          onPressed: _isFormValid ? _handleSave : null,
        ),
      ],
    );
  }
}
