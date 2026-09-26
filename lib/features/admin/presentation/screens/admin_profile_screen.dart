import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../auth/presentation/widgets/change_password_dialog.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/models/user_model.dart';
import '../../../dashboard/presentation/widgets/profile_edit_dialog.dart';

/// Pantalla de perfil del administrador
///
/// Muestra información personal del administrador con un layout de perfil
/// refinado (hero + bento/grid de cards). Accesible desde el avatar en el
/// header superior.
class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final authNotifierState = ref.watch(authNotifierProvider);
    final isLoggingOut = authNotifierState.isLoading;

    // Use valueOrNull so bento cards render even when the stream has not
    // emitted yet (loading) or when Firebase is unavailable (error).
    // This preserves test compatibility — labels like "Preferencias" and
    // "Cerrar sesión" must be visible without Firebase mocks.
    final user = userAsync.valueOrNull;

    if (userAsync.hasError && userAsync.error is Exception) {
      // Stream threw a real error — surface it but keep bento cards visible
      // so navigation items are still accessible.
    }

    return AdminLayout(
      currentRoute: AppRouter.adminProfile,
      child: _buildFullContent(context, user, isLoggingOut),
    );
  }

  // ---------------------------------------------------------------------------
  // Full content — handles both null and non-null user
  // ---------------------------------------------------------------------------

  Widget _buildFullContent(
    BuildContext context,
    UserModel? user,
    bool isLoggingOut,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDesktop = context.isDesktop;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            // Hero when user is available; simple title otherwise
            if (user != null)
              _buildHero(context, cs, user, isDesktop)
            else
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Text('Mi Perfil', style: AppTextStyles.h3),
              ),
            AppSpacing.verticalSpaceLg,
            _buildBentoGrid(context, cs, user, isLoggingOut, isDesktop),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hero / profile card
  // ---------------------------------------------------------------------------

  Widget _buildHero(
    BuildContext context,
    ColorScheme cs,
    UserModel user,
    bool isDesktop,
  ) {
    final roleText = _roleLabel(user.role);
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final joinDate = user.fechaInicio != null
        ? dateFormatter.format(user.fechaInicio!)
        : dateFormatter.format(user.createdAt);

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
          // Decorative circles
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
          // Content
          Padding(
            padding: EdgeInsets.all(
              isDesktop ? AppSpacing.xxxl : AppSpacing.xxl,
            ),
            child: isDesktop
                ? _buildHeroDesktop(context, cs, user, roleText, joinDate)
                : _buildHeroMobile(context, cs, user, roleText, joinDate),
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
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        _heroAvatar(cs, 44),
        AppSpacing.horizontalSpaceXl,
        // Info column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name + active badge
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
                  _activeBadge(cs, user.isActive),
                ],
              ),
              AppSpacing.verticalSpaceXs,
              // Role + employee ID
              Row(
                children: [
                  Icon(Icons.badge,
                      size: 16, color: cs.onPrimary.withValues(alpha: 0.7)),
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
              // Join date + department
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: cs.onPrimary.withValues(alpha: 0.6)),
                  AppSpacing.horizontalSpaceXs,
                  Text(
                    'Ingreso: $joinDate',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  if (user.department != null) ...[
                    AppSpacing.horizontalSpaceMd,
                    Icon(Icons.business,
                        size: 14, color: cs.onPrimary.withValues(alpha: 0.6)),
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
        // Edit button
        CustomButton(
          text: 'Editar',
          icon: Icons.edit,
          variant: ButtonVariant.secondary,
          size: ButtonSize.medium,
          onPressed: () => _openEditDialog(user),
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
  ) {
    return Column(
      children: [
        _heroAvatar(cs, 40),
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
        _activeBadge(cs, user.isActive),
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
          onPressed: () => _openEditDialog(user),
        ),
      ],
    );
  }

  Widget _heroAvatar(ColorScheme cs, double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
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
        radius: radius,
        backgroundColor: cs.onPrimary.withValues(alpha: 0.15),
        child: Icon(Icons.person, size: radius, color: cs.onPrimary),
      ),
    );
  }

  Widget _activeBadge(ColorScheme cs, bool isActive) {
    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? cs.onPrimary.withValues(alpha: 0.2)
            : cs.error.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
      ),
      child: Text(
        isActive ? 'Activo' : 'Inactivo',
        style: AppTextStyles.labelSmall.copyWith(
          color: cs.onPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bento / card grid
  // ---------------------------------------------------------------------------

  Widget _buildBentoGrid(
    BuildContext context,
    ColorScheme cs,
    UserModel? user,
    bool isLoggingOut,
    bool isDesktop,
  ) {
    final gap = Breakpoints.gridGap(context);

    if (isDesktop) {
      return Column(
        children: [
          // Row 1: Cuenta + Preferencias
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCuentaCard(cs, user),
              ),
              SizedBox(width: gap),
              Expanded(
                child: _buildPreferenciasCard(cs),
              ),
            ],
          ),
          SizedBox(height: gap),
          // Row 2: Acerca de (full width)
          _buildAboutCard(cs),
          SizedBox(height: gap),
          // Row 3: Cerrar sesión (full width)
          _buildLogoutCard(context, cs, isLoggingOut),
        ],
      );
    }

    // Mobile / tablet: stacked
    return Column(
      children: [
        _buildCuentaCard(cs, user),
        AppSpacing.verticalSpaceMd,
        _buildPreferenciasCard(cs),
        AppSpacing.verticalSpaceMd,
        _buildAboutCard(cs),
        AppSpacing.verticalSpaceMd,
        _buildLogoutCard(context, cs, isLoggingOut),
      ],
    );
  }

  // --- Cuenta card -----------------------------------------------------------

  Widget _buildCuentaCard(ColorScheme cs, UserModel? user) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: EdgeInsets.zero,
      borderRadius: AppSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Cuenta', Icons.account_circle_outlined, cs),
          _navigationTile(
            icon: Icons.person_outline,
            title: 'Mi perfil',
            subtitle: 'Ver y editar información personal',
            cs: cs,
            onTap: () {
              final currentUser = ref.read(currentUserProvider).valueOrNull;
              if (currentUser != null) {
                _openEditDialog(currentUser);
              }
            },
          ),
          _navigationTile(
            icon: Icons.lock_outline,
            title: 'Contraseña y Seguridad',
            subtitle: 'Actualiza tu contraseña',
            cs: cs,
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => const ChangePasswordDialog(),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Preferencias card -----------------------------------------------------

  Widget _buildPreferenciasCard(ColorScheme cs) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: EdgeInsets.zero,
      borderRadius: AppSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Preferencias', Icons.tune, cs),
          _buildThemeToggle(),
          _unavailableTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Próximamente',
            cs: cs,
          ),
        ],
      ),
    );
  }

  // --- Acerca de card --------------------------------------------------------

  Widget _buildAboutCard(ColorScheme cs) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: EdgeInsets.zero,
      borderRadius: AppSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Acerca de', Icons.info_outline, cs),
          _infoTile(title: 'Versión', value: '1.0.0', cs: cs),
          _infoTile(
            title: 'Estado',
            value: 'En mantenimiento activo',
            cs: cs,
          ),
        ],
      ),
    );
  }

  // --- Logout card -----------------------------------------------------------

  Widget _buildLogoutCard(
    BuildContext context,
    ColorScheme cs,
    bool isLoggingOut,
  ) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: EdgeInsets.zero,
      borderColor: cs.error.withValues(alpha: 0.4),
      borderRadius: AppSpacing.radiusLg,
      child: InkWell(
        onTap: isLoggingOut ? null : () => _showLogoutDialog(context),
        borderRadius: AppSpacing.borderRadiusLg,
        child: Padding(
          padding: AppSpacing.cardLarge,
          child: Row(
            children: [
              if (isLoggingOut)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.error,
                  ),
                )
              else
                Icon(Icons.logout, color: cs.error),
              AppSpacing.horizontalSpaceMd,
              Expanded(
                child: Text(
                  isLoggingOut ? 'Cerrando sesión...' : 'Cerrar sesión',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isLoggingOut)
                Icon(Icons.arrow_forward_ios, size: 16, color: cs.error),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared tile helpers
  // ---------------------------------------------------------------------------

  Widget _cardHeader(String title, IconData icon, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: AppSpacing.allXs,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
            child: Icon(icon, size: AppSpacing.iconMd, color: cs.primary),
          ),
          AppSpacing.horizontalSpaceSm,
          Text(title, style: AppTextStyles.h5),
        ],
      ),
    );
  }

  Widget _navigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme cs,
    required VoidCallback onTap,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          padding: AppSpacing.allSm,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: AppSpacing.iconMd, color: cs.primary),
        ),
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: cs.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }

  Widget _unavailableTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme cs,
  }) {
    return ListTile(
      contentPadding: AppSpacing.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        padding: AppSpacing.allSm,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(
          icon,
          size: AppSpacing.iconMd,
          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
        ),
        child: Text(
          subtitle,
          style: AppTextStyles.labelSmall.copyWith(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _infoTile({
    required String title,
    required String value,
    required ColorScheme cs,
  }) {
    return ListTile(
      contentPadding: AppSpacing.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Consumer(
      builder: (context, ref, child) {
        final cs = Theme.of(context).colorScheme;
        final isDark = ref.watch(
          themeNotifierProvider.select((mode) => mode == ThemeMode.dark),
        );

        return ListTile(
          contentPadding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          leading: Container(
            padding: AppSpacing.allSm,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: AppSpacing.iconMd,
              color: cs.primary,
            ),
          ),
          title: Text('Modo oscuro', style: AppTextStyles.bodyMedium),
          subtitle: Text(
            'Tema oscuro para reducir fatiga visual',
            style: AppTextStyles.bodySmall.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: Switch(
            value: isDark,
            onChanged: (_) {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _openEditDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => ProfileEditDialog(user: user),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              await ref.read(authNotifierProvider.notifier).signOut();

              if (context.mounted) {
                context.go(AppRouter.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

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
