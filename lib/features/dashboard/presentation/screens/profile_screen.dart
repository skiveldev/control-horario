import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/layouts/custom_app_bar.dart';

/// Pantalla de perfil del empleado
/// 
/// Muestra la información personal y laboral del usuario.
/// Incluye opción para editar (solo UI en Fase 1).
/// 
/// MOCK DATA: Usa MockData.currentUser
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Mi Perfil',
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          context.responsiveValue(
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xxl,
            desktop: AppSpacing.xxxl,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Header con avatar grande
                _buildProfileHeader(user),

                AppSpacing.verticalSpaceXxl,

                // Información personal
                _buildInfoSection(
                  title: 'Información Personal',
                  icon: Icons.person,
                  items: [
                    _InfoItem(
                      label: 'Nombre completo',
                      value: user['name'] as String,
                      icon: Icons.badge,
                    ),
                    _InfoItem(
                      label: 'Correo electrónico',
                      value: user['email'] as String,
                      icon: Icons.email,
                    ),
                    _InfoItem(
                      label: 'ID Empleado',
                      value: user['id'] as String,
                      icon: Icons.tag,
                    ),
                  ],
                ),

                AppSpacing.verticalSpaceLg,

                // Información laboral
                _buildInfoSection(
                  title: 'Información Laboral',
                  icon: Icons.work,
                  items: [
                    _InfoItem(
                      label: 'Puesto',
                      value: user['position'] as String,
                      icon: Icons.work_outline,
                    ),
                    _InfoItem(
                      label: 'Departamento',
                      value: user['department'] as String,
                      icon: Icons.business,
                    ),
                    _InfoItem(
                      label: 'Fecha de ingreso',
                      value: user['joinDate'] as String,
                      icon: Icons.calendar_today,
                    ),
                    _InfoItem(
                      label: 'Horario asignado',
                      value: user['schedule'] as String,
                      icon: Icons.schedule,
                    ),
                    _InfoItem(
                      label: 'Horas diarias',
                      value: '${user['workHoursPerDay']}h',
                      icon: Icons.access_time,
                    ),
                  ],
                ),

                AppSpacing.verticalSpaceXxl,

                // Botón editar
                CustomButton(
                  text: 'Editar Perfil',
                  icon: Icons.edit,
                  variant: ButtonVariant.primary,
                  fullWidth: context.isMobile,
                  onPressed: () {
                    // TODO [FASE-2]: Navegar a pantalla de edición
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edición de perfil en desarrollo'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.allXxl,
      child: Column(
        children: [
          // Avatar grande
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary,
              backgroundImage: user['avatarUrl'] != null
                  ? NetworkImage(user['avatarUrl'] as String)
                  : null,
              child: user['avatarUrl'] == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.textOnPrimary,
                    )
                  : null,
            ),
          ),

          AppSpacing.verticalSpaceLg,

          // Nombre
          Text(
            user['name'] as String,
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalSpaceXs,

          // Puesto
          Text(
            user['position'] as String,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalSpaceMd,

          // Badge de rol
          Container(
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user,
                  size: 16,
                  color: AppColors.primary,
                ),
                AppSpacing.horizontalSpaceSm,
                Text(
                  'Empleado',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
  }) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Row(
            children: [
              Icon(
                icon,
                size: AppSpacing.iconMd,
                color: AppColors.primary,
              ),
              AppSpacing.horizontalSpaceSm,
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h5,
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceLg,

          // Items de información
          ...items.map((item) {
            return Padding(
              padding: AppSpacing.verticalSm,
              child: _buildInfoItem(item),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoItem(_InfoItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ícono
        Container(
          padding: AppSpacing.allXs,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          ),
          child: Icon(
            item.icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),

        AppSpacing.horizontalSpaceMd,

        // Label y valor
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.verticalSpaceXs,
              Text(
                item.value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Clase helper para items de información
class _InfoItem {
  final String label;
  final String value;
  final IconData icon;

  _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

