import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/navigation/mobile_drawer.dart';
import '../../../../shared/widgets/navigation/responsive_navigation.dart';
import '../../../../shared/widgets/floating_page_header.dart';
import '../../../../shared/widgets/floating_page_shell.dart';
import '../../../auth/presentation/widgets/change_password_dialog.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/models/user_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile || context.isTablet;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isMobile ? const MobileDrawer() : null,
      body: ResponsiveNavigation(
        child: context.isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Builder(
          builder: (scaffoldContext) =>
              _buildHeader(context, scaffoldContext, isMobile: true),
        ),
        Expanded(child: _buildScrollableContent()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return FloatingPageShell(
      header: _buildHeader(context, context, isMobile: false),
      headerTopOffset: -AppSpacing.md,
      child: _buildContent(),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    BuildContext scaffoldContext, {
    required bool isMobile,
  }) {
    return FloatingPageHeader(
      title: 'Mi cuenta',
      icon: Icons.settings,
      scaffoldContext: scaffoldContext,
      isMobile: isMobile,
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        context.responsiveValue(
          mobile: AppSpacing.lg,
          tablet: AppSpacing.xxl,
          desktop: AppSpacing.xxxl,
        ),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final cs = Theme.of(context).colorScheme;
    final authNotifierState = ref.watch(authNotifierProvider);
    final isLoggingOut = authNotifierState.isLoading;
    final userAsync = ref.watch(currentUserProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userAsync.when(
              data: (user) => _buildHeroCard(cs, user),
              loading: () => _buildHeroSkeleton(cs),
              error: (_, __) => _buildHeroCard(cs, null),
            ),
            AppSpacing.verticalSpaceLg,
            ..._buildBentoGrid(cs, isLoggingOut),
            AppSpacing.verticalSpaceXl,
            _buildFooter(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(ColorScheme cs, UserModel? user) {
    final hasUser = user != null;
    final name = user?.fullName ?? 'Mi Cuenta';
    final roleText = user != null ? _roleLabel(user.role) : null;
    final employeeId = hasUser ? user.employeeId : null;
    final isActive = hasUser ? user.isActive : true;
    final department = hasUser ? user.department : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary,
            Color.lerp(cs.primary, cs.secondary, 0.35)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.onPrimary.withValues(alpha: 0.1),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(
                context.isDesktop ? AppSpacing.xxxl : AppSpacing.xxl),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.onPrimary.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: cs.onPrimary.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                    AppSpacing.horizontalSpaceLg,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: AppSpacing.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? cs.onPrimary.withValues(alpha: 0.2)
                                  : cs.error.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusCircular,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isActive
                                        ? cs.tertiaryContainer
                                        : cs.error,
                                  ),
                                ),
                                AppSpacing.horizontalSpaceSm,
                                Text(
                                  isActive
                                      ? 'CUENTA ACTIVA'
                                      : 'CUENTA INACTIVA',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: cs.onPrimary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.verticalSpaceSm,
                          Text(
                            name,
                            style: AppTextStyles.h3.copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (roleText != null || department != null)
                            Padding(
                              padding: AppSpacing.verticalXs,
                              child: Wrap(
                                spacing: AppSpacing.md,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  if (roleText != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.badge,
                                          size: 16,
                                          color: cs.onPrimary
                                              .withValues(alpha: 0.8),
                                        ),
                                        AppSpacing.horizontalSpaceXs,
                                        Text(
                                          roleText,
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            color: cs.onPrimary
                                                .withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (department != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.business,
                                          size: 16,
                                          color: cs.onPrimary
                                              .withValues(alpha: 0.8),
                                        ),
                                        AppSpacing.horizontalSpaceXs,
                                        Text(
                                          department,
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            color: cs.onPrimary
                                                .withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          if (employeeId != null)
                            Padding(
                              padding: AppSpacing.verticalXs,
                              child: Text(
                                'ID: $employeeId',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: cs.onPrimary.withValues(alpha: 0.7),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSkeleton(ColorScheme cs) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.3),
            cs.primary.withValues(alpha: 0.15),
          ],
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  List<Widget> _buildBentoGrid(ColorScheme cs, bool isLoggingOut) {
    if (context.isDesktop) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 8, child: _buildMiPerfilCard(cs)),
            AppSpacing.horizontalSpaceLg,
            Expanded(flex: 4, child: _buildSecurityCard(cs)),
          ],
        ),
        AppSpacing.verticalSpaceLg,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 4, child: _buildPreferencesCard(cs)),
            AppSpacing.horizontalSpaceLg,
            Expanded(flex: 4, child: _buildAboutCard(cs)),
            AppSpacing.horizontalSpaceLg,
            Expanded(flex: 4, child: _buildLogoutCard(cs, isLoggingOut)),
          ],
        ),
      ];
    }

    if (context.isTablet) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _buildMiPerfilCard(cs)),
            AppSpacing.horizontalSpaceLg,
            Expanded(flex: 6, child: _buildSecurityCard(cs)),
          ],
        ),
        AppSpacing.verticalSpaceLg,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _buildPreferencesCard(cs)),
            AppSpacing.horizontalSpaceLg,
            Expanded(flex: 6, child: _buildAboutCard(cs)),
          ],
        ),
        AppSpacing.verticalSpaceLg,
        _buildLogoutCard(cs, isLoggingOut),
      ];
    }

    return [
      _buildMiPerfilCard(cs),
      AppSpacing.verticalSpaceMd,
      _buildSecurityCard(cs),
      AppSpacing.verticalSpaceMd,
      _buildPreferencesCard(cs),
      AppSpacing.verticalSpaceMd,
      _buildAboutCard(cs),
      AppSpacing.verticalSpaceMd,
      _buildLogoutCard(cs, isLoggingOut),
    ];
  }

  Widget _buildMiPerfilCard(ColorScheme cs) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.cardLarge,
      borderRadius: AppSpacing.radiusLg,
      onTap: () {
        context.push(AppRouter.profile);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.allSm,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  Icons.person,
                  size: AppSpacing.iconMd,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward,
                size: 20,
                color: cs.outline,
              ),
            ],
          ),
          AppSpacing.verticalSpaceMd,
          Text(
            'Mi perfil',
            style: AppTextStyles.h4.copyWith(color: cs.primary),
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            'Gestiona tus datos personales e información de contacto.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          AppSpacing.verticalSpaceLg,
          Container(
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              'Ver y editar información',
              style: AppTextStyles.labelSmall.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(ColorScheme cs) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.cardLarge,
      borderRadius: AppSpacing.radiusLg,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const ChangePasswordDialog(),
        );
      },
      child: Column(
        children: [
          Container(
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 32,
              color: cs.error,
            ),
          ),
          AppSpacing.verticalSpaceMd,
          Text(
            'Seguridad',
            style: AppTextStyles.h5,
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceXs,
          Text(
            'Actualiza tu contraseña y protege tu cuenta.',
            style: AppTextStyles.bodySmall.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceLg,
          Container(
            width: double.infinity,
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              'Cambiar contraseña',
              style: AppTextStyles.labelSmall.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(ColorScheme cs) {
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
                  color: cs.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Icon(
                  Icons.tune,
                  size: AppSpacing.iconMd,
                  color: cs.secondary,
                ),
              ),
              AppSpacing.horizontalSpaceSm,
              Text('Preferencias', style: AppTextStyles.h5),
            ],
          ),
          AppSpacing.verticalSpaceMd,
          _buildThemeToggle(cs),
          Container(
            height: 1,
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
          _buildUnavailablePreferenceItem(
            cs: cs,
            title: 'Idioma',
            subtitle: 'Cambio de idioma disponible próximamente',
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(ColorScheme cs) {
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
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: AppSpacing.iconMd,
                  color: cs.primary,
                ),
              ),
              AppSpacing.horizontalSpaceSm,
              Text('Acerca de', style: AppTextStyles.h5),
            ],
          ),
          AppSpacing.verticalSpaceMd,
          _buildInfoRow(cs, 'Versión', '1.0.0'),
          AppSpacing.verticalSpaceSm,
          _buildInfoRow(cs, 'Actualización', 'Noviembre 2025'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ColorScheme cs, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutCard(ColorScheme cs, bool isLoggingOut) {
    return CustomCard(
      elevation: CardElevation.none,
      padding: AppSpacing.cardLarge,
      borderRadius: AppSpacing.radiusLg,
      borderColor: cs.error.withValues(alpha: 0.2),
      child: InkWell(
        onTap: isLoggingOut
            ? null
            : () {
                _showLogoutDialog(context);
              },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: AppSpacing.allMd,
          child: Column(
            children: [
              if (isLoggingOut)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.error,
                  ),
                )
              else
                Icon(Icons.logout, size: 28, color: cs.error),
              AppSpacing.verticalSpaceSm,
              Text(
                isLoggingOut ? 'Cerrando sesión...' : 'Cerrar sesión',
                style: AppTextStyles.button.copyWith(color: cs.error),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ColorScheme cs) {
    return Container(
      padding: AppSpacing.verticalLg,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Control Horario',
            style: AppTextStyles.labelSmall.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'v1.0.0',
            style: AppTextStyles.labelSmall.copyWith(
              color: cs.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(ColorScheme cs) {
    return Consumer(
      builder: (context, ref, child) {
        final isDark = ref.watch(
          themeNotifierProvider.select((mode) => mode == ThemeMode.dark),
        );

        return Padding(
          padding: EdgeInsets.zero,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
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
              style: AppTextStyles.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: (_) {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnavailablePreferenceItem({
    required ColorScheme cs,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: AppSpacing.allSm,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(
          Icons.language,
          size: AppSpacing.iconMd,
          color: cs.primary,
        ),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
      trailing: Chip(
        label: const Text('Próximamente'),
        backgroundColor: cs.surfaceContainerHighest,
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),
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
