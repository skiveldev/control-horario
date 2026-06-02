import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
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
/// con validaciones de fortaleza, coincidencia y Firebase Auth real.
class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';
  bool _isLoading = false;

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
    if (_currentPassword.isEmpty ||
        _newPassword.isEmpty ||
        _confirmPassword.isEmpty) {
      return false;
    }

    if (calculatePasswordStrength(_newPassword, minLength: 8) < 2) {
      return false;
    }

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

  Future<void> _handleSave() async {
    if (!_isFormValid || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.changePassword(
        currentPassword: _currentPassword,
        newPassword: _newPassword,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final message = _mapFirebaseError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar la contraseña: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'La contraseña actual es incorrecta';
      case 'weak-password':
        return 'La nueva contraseña es demasiado débil. Usa al menos 6 caracteres';
      case 'requires-recent-login':
        return 'Por seguridad, inicia sesión nuevamente antes de cambiar la contraseña';
      default:
        return 'Error al cambiar la contraseña. Inténtalo de nuevo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final canSubmit = _isFormValid && !_isLoading;

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
                  _buildHeader(),
                  AppSpacing.verticalSpaceXxl,
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
                  _buildSecurityNote(),
                  AppSpacing.verticalSpaceXxl,
                  _buildActions(isMobile, canSubmit),
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

  Widget _buildActions(bool isMobile, bool canSubmit) {
    final buttonText = _isLoading ? 'Actualizando...' : 'Actualizar Contraseña';

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomButton(
            text: buttonText,
            variant: ButtonVariant.primary,
            icon: _isLoading ? null : Icons.check,
            onPressed: canSubmit ? _handleSave : null,
          ),
          AppSpacing.verticalSpaceMd,
          CustomButton(
            text: 'Cancelar',
            variant: ButtonVariant.outline,
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        AppSpacing.horizontalSpaceMd,
        CustomButton(
          text: buttonText,
          variant: ButtonVariant.primary,
          icon: _isLoading ? null : Icons.check,
          onPressed: canSubmit ? _handleSave : null,
        ),
      ],
    );
  }
}
