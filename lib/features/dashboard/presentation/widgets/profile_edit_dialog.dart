import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';

/// Dialog para editar perfil del usuario
///
/// Permite actualizar información personal editable como nombre,
/// teléfono y preferencias de notificaciones.
///
/// MOCK UI: Solo muestra SnackBar de éxito, sin persistencia real.
/// TODO [FASE-2]: Conectar con Riverpod provider para actualizar datos
class ProfileEditDialog extends StatefulWidget {
  /// Datos actuales del usuario
  final Map<String, dynamic> user;

  /// Callback al guardar cambios
  final Function(Map<String, dynamic>)? onSave;

  const ProfileEditDialog({super.key, required this.user, this.onSave});

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _emailNotifications = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user['name'] as String,
    );
    _phoneController = TextEditingController(
      text: '+34 600 123 456',
    ); // Mock phone
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // TODO [FASE-2]: Validar y actualizar datos con Riverpod
    final updatedData = {
      ...widget.user,
      'name': _nameController.text,
      'phone': _phoneController.text,
      'emailNotifications': _emailNotifications,
    };

    widget.onSave?.call(updatedData);

    Navigator.of(context).pop();

    // Mock UI feedback
    final colors = AppColorsHelper.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Perfil actualizado correctamente'),
        backgroundColor: colors.success,
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
                  label: 'Nombre completo',
                  controller: _nameController,
                  prefixIcon: Icons.person,
                  required: true,
                ),

                AppSpacing.verticalSpaceLg,

                CustomTextField(
                  label: 'Teléfono',
                  controller: _phoneController,
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),

                AppSpacing.verticalSpaceLg,

                // Switch de notificaciones
                _buildNotificationSwitch(),

                AppSpacing.verticalSpaceXxl,

                // Campos de solo lectura
                _buildReadOnlySection(),

                AppSpacing.verticalSpaceXxl,

                // Botones de acción
                _buildActions(isMobile),
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
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary, width: 3),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: colors.primary,
              backgroundImage: widget.user['avatarUrl'] != null
                  ? NetworkImage(widget.user['avatarUrl'] as String)
                  : null,
              child: widget.user['avatarUrl'] == null
                  ? Icon(Icons.person, size: 60, color: colors.textOnPrimary)
                  : null,
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
                  // TODO [FASE-2]: Implementar subida de imagen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subida de imagen disponible en Fase 2'),
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

  Widget _buildNotificationSwitch() {
    final colors = AppColorsHelper.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: SwitchListTile(
        title: Text(
          'Recibir notificaciones por email',
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: Text(
          'Recibe alertas y resúmenes en tu correo',
          style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
        value: _emailNotifications,
        onChanged: (value) {
          setState(() {
            _emailNotifications = value;
          });
        },
        activeTrackColor: colors.primary.withValues(alpha: 0.5),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return null;
        }),
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
          value: widget.user['email'] as String,
          icon: Icons.email,
        ),

        AppSpacing.verticalSpaceSm,

        _buildReadOnlyField(
          label: 'ID Empleado',
          value: widget.user['id'] as String,
          icon: Icons.tag,
        ),

        AppSpacing.verticalSpaceSm,

        _buildReadOnlyField(
          label: 'Departamento',
          value: widget.user['department'] as String,
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

  Widget _buildActions(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomButton(
            text: 'Guardar Cambios',
            variant: ButtonVariant.primary,
            icon: Icons.save,
            onPressed: _handleSave,
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
          text: 'Guardar Cambios',
          variant: ButtonVariant.primary,
          icon: Icons.save,
          onPressed: _handleSave,
        ),
      ],
    );
  }
}
