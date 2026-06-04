import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/navigation/mobile_drawer.dart';
import '../../../../shared/widgets/navigation/responsive_navigation.dart';
import '../../../../shared/widgets/floating_page_header.dart';
import '../../../../shared/widgets/floating_page_shell.dart';
import '../widgets/profile_edit_dialog.dart';
import '../../../admin/presentation/widgets/week_schedule_viewer.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = context.isMobile || context.isTablet;
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isMobile ? const MobileDrawer() : null,
      body: ResponsiveNavigation(
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return _buildScaffoldBody(
                context,
                isMobile,
                _buildNoUserError(context),
              );
            }
            return _buildScaffoldBody(
              context,
              isMobile,
              _buildProfileContent(context, ref, user),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => _buildScaffoldBody(
            context,
            isMobile,
            _buildErrorState(context, error),
          ),
        ),
      ),
    );
  }

  Widget _buildScaffoldBody(
    BuildContext context,
    bool isMobile,
    Widget content,
  ) {
    if (context.isDesktop) {
      return FloatingPageShell(
        header: _buildHeader(context, context, isMobile: false),
        child: content,
      );
    }

    return Column(
      children: [
        Builder(
          builder: (scaffoldContext) =>
              _buildHeader(context, scaffoldContext, isMobile: true),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              context.responsiveValue(
                mobile: AppSpacing.lg,
                tablet: AppSpacing.xxl,
                desktop: AppSpacing.xxxl,
              ),
            ),
            child: content,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    BuildContext scaffoldContext, {
    required bool isMobile,
  }) {
    return FloatingPageHeader(
      title: 'Mi Perfil',
      icon: Icons.person,
      scaffoldContext: scaffoldContext,
      isMobile: isMobile,
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    final cs = Theme.of(context).colorScheme;
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final joinDate = user.fechaInicio != null
        ? dateFormatter.format(user.fechaInicio!)
        : dateFormatter.format(user.createdAt);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            _buildProfileHero(context, cs, user, joinDate, ref),
            AppSpacing.verticalSpaceLg,
            ..._buildInfoGrid(cs, user, joinDate, context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHero(
    BuildContext context,
    ColorScheme cs,
    UserModel user,
    String joinDate,
    WidgetRef ref,
  ) {
    final roleText = _roleLabel(user.role);
    final isDesktop = context.isDesktop;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            Color.lerp(cs.primary, cs.secondary, 0.3)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.onPrimary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.secondary.withValues(alpha: 0.15),
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.all(isDesktop ? AppSpacing.xxxl : AppSpacing.xxl),
            child: isDesktop
                ? _buildHeroDesktop(context, cs, user, roleText, joinDate, ref)
                : _buildHeroMobile(context, cs, user, roleText, joinDate, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroDesktop(
    BuildContext context,
    ColorScheme cs,
    UserModel user,
    String roleText,
    String joinDate,
    WidgetRef ref,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: cs.onPrimary.withValues(alpha: 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 44,
            backgroundColor: cs.onPrimary.withValues(alpha: 0.15),
            child: Icon(Icons.person, size: 44, color: cs.onPrimary),
          ),
        ),
        AppSpacing.horizontalSpaceXl,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user.fullName,
                      style: AppTextStyles.h2.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Container(
                    padding: AppSpacing.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: user.isActive
                          ? cs.onPrimary.withValues(alpha: 0.2)
                          : cs.error.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCircular,
                      ),
                    ),
                    child: Text(
                      user.isActive ? 'Activo' : 'Inactivo',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpaceXs,
              Row(
                children: [
                  Icon(
                    Icons.badge,
                    size: 16,
                    color: cs.onPrimary.withValues(alpha: 0.7),
                  ),
                  AppSpacing.horizontalSpaceXs,
                  Text(
                    '$roleText · #${user.employeeId}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpaceXs,
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: cs.onPrimary.withValues(alpha: 0.6),
                  ),
                  AppSpacing.horizontalSpaceXs,
                  Text(
                    'Ingreso: $joinDate',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  if (user.department != null) ...[
                    AppSpacing.horizontalSpaceMd,
                    Icon(
                      Icons.business,
                      size: 14,
                      color: cs.onPrimary.withValues(alpha: 0.6),
                    ),
                    AppSpacing.horizontalSpaceXs,
                    Flexible(
                      child: Text(
                        user.department!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: cs.onPrimary.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        AppSpacing.horizontalSpaceLg,
        CustomButton(
          text: 'Editar',
          icon: Icons.edit,
          variant: ButtonVariant.secondary,
          size: ButtonSize.medium,
          onPressed: () => _openEditDialog(context, ref, user),
        ),
      ],
    );
  }

  Widget _buildHeroMobile(
    BuildContext context,
    ColorScheme cs,
    UserModel user,
    String roleText,
    String joinDate,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: cs.onPrimary.withValues(alpha: 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: cs.onPrimary.withValues(alpha: 0.15),
            child: Icon(Icons.person, size: 40, color: cs.onPrimary),
          ),
        ),
        AppSpacing.verticalSpaceMd,
        Text(
          user.fullName,
          style: AppTextStyles.h3.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        AppSpacing.verticalSpaceXs,
        Container(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: user.isActive
                ? cs.onPrimary.withValues(alpha: 0.2)
                : cs.error.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
          ),
          child: Text(
            user.isActive ? 'Activo' : 'Inactivo',
            style: AppTextStyles.labelSmall.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        AppSpacing.verticalSpaceXs,
        Text(
          '$roleText · #${user.employeeId}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: cs.onPrimary.withValues(alpha: 0.85),
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.verticalSpaceXs,
        Text(
          'Ingreso: $joinDate',
          style: AppTextStyles.bodySmall.copyWith(
            color: cs.onPrimary.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        if (user.department != null)
          Text(
            user.department!,
            style: AppTextStyles.bodySmall.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        AppSpacing.verticalSpaceLg,
        CustomButton(
          text: 'Editar Perfil',
          icon: Icons.edit,
          variant: ButtonVariant.secondary,
          size: ButtonSize.medium,
          fullWidth: true,
          onPressed: () => _openEditDialog(context, ref, user),
        ),
      ],
    );
  }

  List<Widget> _buildInfoGrid(
    ColorScheme cs,
    UserModel user,
    String joinDate,
    BuildContext context,
    WidgetRef ref,
  ) {
    final personalItems = _buildPersonalItems(user);
    final laboralItems = _buildLaboralItems(user, joinDate);

    if (context.isDesktop) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInfoSectionCard(
                cs,
                title: 'Información Personal',
                icon: Icons.person,
                iconColor: cs.primary,
                items: personalItems,
              ),
            ),
            AppSpacing.horizontalSpaceLg,
            Expanded(
              child: _buildInfoSectionCard(
                cs,
                title: 'Información Laboral',
                icon: Icons.work,
                iconColor: cs.secondary,
                items: laboralItems,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceLg,
        _buildScheduleCard(cs, user),
      ];
    }

    return [
      _buildInfoSectionCard(
        cs,
        title: 'Información Personal',
        icon: Icons.person,
        iconColor: cs.primary,
        items: personalItems,
      ),
      AppSpacing.verticalSpaceMd,
      _buildInfoSectionCard(
        cs,
        title: 'Información Laboral',
        icon: Icons.work,
        iconColor: cs.secondary,
        items: laboralItems,
      ),
      AppSpacing.verticalSpaceMd,
      _buildScheduleCard(cs, user),
    ];
  }

  Widget _buildInfoSectionCard(
    ColorScheme cs, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> items,
  }) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.cardLarge,
      borderRadius: AppSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.allXs,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Icon(icon, size: AppSpacing.iconMd, color: iconColor),
              ),
              AppSpacing.horizontalSpaceSm,
              Text(title, style: AppTextStyles.h5),
            ],
          ),
          AppSpacing.verticalSpaceLg,
          ...items,
          if (items.isNotEmpty) AppSpacing.verticalSpaceSm,
        ],
      ),
    );
  }

  List<Widget> _buildPersonalItems(UserModel user) {
    final items = <Widget>[
      _InfoTile(
        icon: Icons.badge,
        label: 'Nombre completo',
        value: user.fullName,
      ),
      _InfoTile(
        icon: Icons.email,
        label: 'Correo electrónico',
        value: user.email,
      ),
      _InfoTile(
        icon: Icons.tag,
        label: 'ID Empleado',
        value: user.employeeId,
      ),
    ];

    if (user.dni != null) {
      items.add(_InfoTile(
        icon: Icons.credit_card,
        label: 'DNI/NIE',
        value: user.dni!,
      ));
    }

    if (user.telefono != null) {
      items.add(_InfoTile(
        icon: Icons.phone,
        label: 'Teléfono',
        value: user.telefono!,
      ));
    }

    return items;
  }

  List<Widget> _buildLaboralItems(UserModel user, String joinDate) {
    return [
      _InfoTile(
        icon: Icons.work_outline,
        label: 'Puesto',
        value: user.position ?? 'Sin asignar',
      ),
      _InfoTile(
        icon: Icons.business,
        label: 'Departamento',
        value: user.department ?? 'Sin asignar',
      ),
      if (user.empresa != null)
        _InfoTile(
          icon: Icons.apartment,
          label: 'Empresa',
          value: user.empresa!,
        ),
      _InfoTile(
        icon: Icons.calendar_today,
        label: 'Fecha de ingreso',
        value: joinDate,
      ),
      _InfoTile(
        icon: Icons.schedule,
        label: 'Horario asignado',
        value: user.schedule ?? 'Consultar RRHH',
      ),
      _InfoTile(
        icon: Icons.access_time,
        label: 'Horas semanales',
        value: '${user.weeklyHours}h/semana',
      ),
    ];
  }

  Widget _buildScheduleCard(ColorScheme cs, UserModel user) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.cardLarge,
      borderRadius: AppSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.allXs,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: const Icon(
                  Icons.schedule,
                  size: 20,
                  color: AppColors.info,
                ),
              ),
              AppSpacing.horizontalSpaceSm,
              Text('Mi Horario Laboral', style: AppTextStyles.h5),
            ],
          ),
          AppSpacing.verticalSpaceMd,
          WeekScheduleViewer(
            employeeId: user.employeeId,
            isReadOnly: true,
          ),
          AppSpacing.verticalSpaceMd,
          Container(
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
    );
  }

  void _openEditDialog(BuildContext context, WidgetRef ref, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(
        user: user,
        onSave: (updatedData) {},
      ),
    );
  }

  Widget _buildNoUserError(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: AppSpacing.allXxl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.rrhh:
        return 'Recursos Humanos';
      case UserRole.employee:
        return 'Empleado';
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: AppSpacing.verticalSm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              icon,
              size: 20,
              color: cs.primary,
            ),
          ),
          AppSpacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
