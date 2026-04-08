import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../auth/models/user_model.dart';
import '../../../../core/services/auth_service.dart';

/// Dialog para editar perfil del usuario
///
/// Permite actualizar información personal editable como nombre,
/// apellidos, teléfono y DNI. Conectado con Firebase.
class ProfileEditDialog extends ConsumerStatefulWidget {
  /// Datos actuales del usuario
  final UserModel user;

  /// Callback al guardar cambios
  final Function(Map<String, dynamic>)? onSave;

  const ProfileEditDialog({super.key, required this.user, this.onSave});

  @override
  ConsumerState<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends ConsumerState<ProfileEditDialog> {
  late TextEditingController _nombreController;
  late TextEditingController _apellido1Controller;
  late TextEditingController _apellido2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _dniController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.user.nombre ?? '',
    );
    _apellido1Controller = TextEditingController(
      text: widget.user.apellido1 ?? '',
    );
    _apellido2Controller = TextEditingController(
      text: widget.user.apellido2 ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.user.telefono ?? '',
    );
    _dniController = TextEditingController(
      text: widget.user.dni ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellido1Controller.dispose();
    _apellido2Controller.dispose();
    _phoneController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // Validar campos obligatorios
    if (_nombreController.text.trim().isEmpty ||
        _apellido1Controller.text.trim().isEmpty) {
      final colors = AppColorsHelper.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nombre y primer apellido son obligatorios'),
          backgroundColor: colors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);

    // Construir displayName desde nombre + apellidos
    final nombre = _nombreController.text.trim();
    final apellido1 = _apellido1Controller.text.trim();
    final apellido2 = _apellido2Controller.text.trim();

    final displayName = apellido2.isNotEmpty
        ? '$nombre $apellido1 $apellido2'
        : '$nombre $apellido1';

    try {
      // TODO: Move to authNotifierProvider.notifier.updateProfile()
      await authService.updateUserData(
        widget.user.userId,
        {
          'nombre': nombre,
          'apellido1': apellido1,
          'apellido2': apellido2.isEmpty ? null : apellido2,
          'displayName': displayName, // Auto-calculado
          'telefono': _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          'dni': _dniController.text.trim().isEmpty
              ? null
              : _dniController.text.trim(),
        },
      );

      if (mounted) {
        Navigator.of(context).pop();

        final colors = AppColorsHelper.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil actualizado correctamente'),
            backgroundColor: colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        final colors = AppColorsHelper.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),

                AppSpacing.verticalSpaceXxl,

                // Avatar con botón de edición
                _buildAvatarSection(),

                AppSpacing.verticalSpaceXxl,

                // Campos editables
                CustomTextField(
                  label: 'Nombre',
                  controller: _nombreController,
                  prefixIcon: Icons.person,
                  required: true,
                ),

                AppSpacing.verticalSpaceLg,

                CustomTextField(
                  label: 'Primer apellido',
                  controller: _apellido1Controller,
                  prefixIcon: Icons.person_outline,
                  required: true,
                ),

                AppSpacing.verticalSpaceLg,

                CustomTextField(
                  label: 'Segundo apellido',
                  controller: _apellido2Controller,
                  prefixIcon: Icons.person_outline,
                ),

                AppSpacing.verticalSpaceLg,

                CustomTextField(
                  label: 'DNI/NIE',
                  controller: _dniController,
                  prefixIcon: Icons.credit_card,
                ),

                AppSpacing.verticalSpaceLg,

                CustomTextField(
                  label: 'Teléfono',
                  controller: _phoneController,
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),

                AppSpacing.verticalSpaceXxl,

                // Campos de solo lectura
                _buildReadOnlySection(),

                AppSpacing.verticalSpaceXxl,

                // Botones de acción
                _buildActions(isMobile, _isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(child: Text('Editar Perfil', style: AppTextStyles.h4)),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Cerrar',
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    final colors = AppColorsHelper.of(context);

    return Center(
      child: Stack(
        children: [
          // Avatar (por ahora genérico, no hay avatarUrl en UserModel)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary, width: 3),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: colors.primary,
              child: Icon(Icons.person, size: 60, color: colors.textOnPrimary),
            ),
          ),

          // Botón de cámara
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: colors.textOnPrimary,
                  size: 20,
                ),
                onPressed: () {
                  // TODO: Implementar subida de imagen cuando se agregue avatarUrl a UserModel
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función de avatar en desarrollo'),
                    ),
                  );
                },
                tooltip: 'Cambiar foto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlySection() {
    final colors = AppColorsHelper.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de solo lectura',
          style: AppTextStyles.labelLarge.copyWith(color: colors.textSecondary),
        ),
        AppSpacing.verticalSpaceMd,
        _buildReadOnlyField(
          label: 'Correo electrónico',
          value: widget.user.email,
          icon: Icons.email,
        ),
        AppSpacing.verticalSpaceSm,
        _buildReadOnlyField(
          label: 'ID Empleado',
          value: widget.user.employeeId,
          icon: Icons.tag,
        ),
        AppSpacing.verticalSpaceSm,
        _buildReadOnlyField(
          label: 'Departamento',
          value: widget.user.department ?? 'Sin asignar',
          icon: Icons.business,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colors = AppColorsHelper.of(context);

    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: colors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: colors.textSecondary),
          AppSpacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isMobile, bool isLoading) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomButton(
            text: isLoading ? 'Guardando...' : 'Guardar Cambios',
            variant: ButtonVariant.primary,
            icon: isLoading ? null : Icons.save,
            onPressed: isLoading ? null : _handleSave,
          ),
          AppSpacing.verticalSpaceMd,
          CustomButton(
            text: 'Cancelar',
            variant: ButtonVariant.outline,
            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
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
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        ),
        AppSpacing.horizontalSpaceMd,
        CustomButton(
          text: isLoading ? 'Guardando...' : 'Guardar Cambios',
          variant: ButtonVariant.primary,
          icon: isLoading ? null : Icons.save,
          onPressed: isLoading ? null : _handleSave,
        ),
      ],
    );
  }
}
