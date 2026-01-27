import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/layouts/custom_app_bar.dart';
import '../widgets/profile_edit_dialog.dart';
import '../../../admin/presentation/widgets/week_schedule_viewer.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/models/user_model.dart';

/// Pantalla de perfil del empleado
///
/// Muestra la información personal y laboral del usuario.
/// Conectada con Firebase a través de currentUserProvider.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Mi Perfil',
        automaticallyImplyLeading: true,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return _buildNoUserError();
          }
          return _buildProfileContent(context, user);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _buildErrorState(error),
      ),
    );
  }

  /// Contenido del perfil cuando hay datos del usuario
  Widget _buildProfileContent(BuildContext context, UserModel user) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final joinDate = user.fechaInicio != null
        ? dateFormatter.format(user.fechaInicio!)
        : dateFormatter.format(user.createdAt);

    return SingleChildScrollView(
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
                    value: user.fullName,
                    icon: Icons.badge,
                  ),
                  _InfoItem(
                    label: 'Correo electrónico',
                    value: user.email,
                    icon: Icons.email,
                  ),
                  _InfoItem(
                    label: 'ID Empleado',
                    value: user.employeeId,
                    icon: Icons.tag,
                  ),
                  if (user.dni != null)
                    _InfoItem(
                      label: 'DNI/NIE',
                      value: user.dni!,
                      icon: Icons.credit_card,
                    ),
                  if (user.telefono != null)
                    _InfoItem(
                      label: 'Teléfono',
                      value: user.telefono!,
                      icon: Icons.phone,
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
                    value: user.position ?? 'Sin asignar',
                    icon: Icons.work_outline,
                  ),
                  _InfoItem(
                    label: 'Departamento',
                    value: user.department ?? 'Sin asignar',
                    icon: Icons.business,
                  ),
                  if (user.empresa != null)
                    _InfoItem(
                      label: 'Empresa',
                      value: user.empresa!,
                      icon: Icons.apartment,
                    ),
                  _InfoItem(
                    label: 'Fecha de ingreso',
                    value: joinDate,
                    icon: Icons.calendar_today,
                  ),
                  _InfoItem(
                    label: 'Horario asignado',
                    value: user.schedule ?? 'Consultar RRHH',
                    icon: Icons.schedule,
                  ),
                  _InfoItem(
                    label: 'Horas semanales',
                    value: '${user.weeklyHours}h/semana',
                    icon: Icons.access_time,
                  ),
                ],
              ),

              AppSpacing.verticalSpaceLg,

              // Mi Horario Laboral
              _buildInfoSection(
                title: 'Mi Horario Laboral',
                icon: Icons.schedule,
                items: [
                  _InfoItem(
                    label: 'Horario contratado',
                    value: '${user.weeklyHours}h/semana',
                    icon: Icons.access_time,
                  ),
                ],
              ),

              AppSpacing.verticalSpaceSm,

              CustomCard(
                elevation: CardElevation.low,
                padding: AppSpacing.card,
                child: Column(
                  children: [
                    WeekScheduleViewer(
                      employeeId: user.employeeId,
                      isReadOnly: true,
                    ),
                    AppSpacing.verticalSpaceMd,
                    Container(
                      padding: AppSpacing.allMd,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppColors.info,
                          ),
                          AppSpacing.horizontalSpaceSm,
                          Expanded(
                            child: Text(
                              'Para cambios en tu horario, contacta a Recursos Humanos',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.verticalSpaceXxl,

              // Botón editar
              CustomButton(
                text: 'Editar Perfil',
                icon: Icons.edit,
                variant: ButtonVariant.primary,
                fullWidth: context.isMobile,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ProfileEditDialog(
                      user: user,
                      onSave: (updatedData) {
                        // La actualización se maneja dentro del dialog
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Estado de error cuando no hay usuario autenticado
  Widget _buildNoUserError() {
    return Center(
      child: Padding(
        padding: AppSpacing.allXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            AppSpacing.verticalSpaceLg,
            Text(
              'No se encontró información del usuario',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceMd,
            Text(
              'Por favor, cierra sesión e inicia sesión nuevamente',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Estado de error general
  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            AppSpacing.verticalSpaceLg,
            Text(
              'Error al cargar el perfil',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceMd,
            Text(
              error.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    // Obtener el rol en texto
    String roleText;
    switch (user.role) {
      case UserRole.admin:
        roleText = 'Administrador';
        break;
      case UserRole.rrhh:
        roleText = 'Recursos Humanos';
        break;
      case UserRole.employee:
        roleText = 'Empleado';
        break;
    }

    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.allXxl,
      child: Column(
        children: [
          // Avatar grande
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person,
                size: 60,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),

          AppSpacing.verticalSpaceLg,

          // Nombre
          Text(
            user.fullName,
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalSpaceXs,

          // Puesto
          Text(
            user.position ?? 'Sin asignar',
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user,
                  size: 16,
                  color: AppColors.primary,
                ),
                AppSpacing.horizontalSpaceSm,
                Text(
                  roleText,
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
              Icon(icon, size: AppSpacing.iconMd, color: AppColors.primary),
              AppSpacing.horizontalSpaceSm,
              Expanded(child: Text(title, style: AppTextStyles.h5)),
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
          child: Icon(item.icon, size: 16, color: AppColors.textSecondary),
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

  _InfoItem({required this.label, required this.value, required this.icon});
}
