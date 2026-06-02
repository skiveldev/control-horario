import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/layouts/custom_app_bar.dart';
import '../../../auth/presentation/widgets/change_password_dialog.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../dashboard/presentation/widgets/profile_edit_dialog.dart';

/// Pantalla de perfil del administrador
///
/// Muestra información personal y preferencias del administrador.
/// Accesible desde el avatar en el header superior.
class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  // Estados mock de configuraciones
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _clockingReminders = false;
  String _language = 'es';

  @override
  Widget build(BuildContext context) {
    // Observar estado de logout
    final authNotifierState = ref.watch(authNotifierProvider);
    final isLoggingOut = authNotifierState.isLoading;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección: Notificaciones
                _buildSection(
                  title: 'Notificaciones',
                  icon: Icons.notifications,
                  children: [
                    _buildSwitchItem(
                      title: 'Notificaciones por correo',
                      subtitle: 'Recibir alertas y resúmenes por email',
                      value: _emailNotifications,
                      onChanged: (value) {
                        setState(() => _emailNotifications = value);
                      },
                    ),
                    _buildSwitchItem(
                      title: 'Notificaciones push',
                      subtitle: 'Recibir notificaciones en tiempo real',
                      value: _pushNotifications,
                      onChanged: (value) {
                        setState(() => _pushNotifications = value);
                      },
                    ),
                    _buildSwitchItem(
                      title: 'Recordatorios de fichaje',
                      subtitle: 'Avisos para entrada y salida',
                      value: _clockingReminders,
                      onChanged: (value) {
                        setState(() => _clockingReminders = value);
                      },
                    ),
                  ],
                ),

                AppSpacing.verticalSpaceLg,

                // Sección: Preferencias
                _buildSection(
                  title: 'Preferencias',
                  icon: Icons.tune,
                  children: [
                    // Toggle de tema oscuro
                    _buildThemeToggle(),
                    _buildDropdownItem(
                      title: 'Idioma',
                      subtitle: 'Selecciona el idioma de la interfaz',
                      value: _language,
                      options: const {'es': 'Español', 'en': 'English'},
                      onChanged: (value) {
                        setState(() => _language = value!);
                        // TODO [FASE-2]: Cambiar idioma de la app
                      },
                    ),
                  ],
                ),

                AppSpacing.verticalSpaceLg,

                // Sección: Cuenta
                _buildSection(
                  title: 'Cuenta',
                  icon: Icons.account_circle,
                  children: [
                    _buildNavigationItem(
                      title: 'Mi perfil',
                      subtitle: 'Ver y editar información personal',
                      icon: Icons.person,
                      onTap: () {
                        final userAsync =
                            ref.read(currentUserProvider).valueOrNull;
                        if (userAsync != null) {
                          showDialog(
                            context: context,
                            builder: (ctx) => ProfileEditDialog(
                              user: userAsync,
                            ),
                          );
                        }
                      },
                    ),
                    _buildNavigationItem(
                      title: 'Contraseña y Seguridad',
                      subtitle: 'Último cambio hace 3 meses',
                      icon: Icons.lock_outline,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ChangePasswordDialog(),
                        );
                      },
                    ),
                  ],
                ),

                AppSpacing.verticalSpaceLg,

                // Sección: Acerca de
                _buildSection(
                  title: 'Acerca de',
                  icon: Icons.info,
                  children: [
                    _buildInfoItem(title: 'Versión', value: '1.0.0'),
                    _buildInfoItem(
                      title: 'Última actualización',
                      value: 'Noviembre 2025',
                    ),
                  ],
                ),

                AppSpacing.verticalSpaceXxl,

                // Botón cerrar sesión
                CustomCard(
                  elevation: CardElevation.none,
                  padding: AppSpacing.cardLarge,
                  borderColor: Theme.of(context).colorScheme.error,
                  child: InkWell(
                    onTap: isLoggingOut
                        ? null
                        : () {
                            _showLogoutDialog(context);
                          },
                    child: Row(
                      children: [
                        if (isLoggingOut)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          )
                        else
                          Icon(Icons.logout,
                              color: Theme.of(context).colorScheme.error),
                        AppSpacing.horizontalSpaceMd,
                        Expanded(
                          child: Text(
                            isLoggingOut
                                ? 'Cerrando sesión...'
                                : 'Cerrar sesión',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!isLoggingOut)
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Padding(
          padding: AppSpacing.horizontalSm,
          child: Row(
            children: [
              Icon(icon,
                  size: AppSpacing.iconMd,
                  color: Theme.of(context).colorScheme.primary),
              AppSpacing.horizontalSpaceSm,
              Expanded(child: Text(title, style: AppTextStyles.h5)),
            ],
          ),
        ),

        AppSpacing.verticalSpaceMd,

        // Contenido de la sección
        CustomCard(
          elevation: CardElevation.low,
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeToggle() {
    return Consumer(
      builder: (context, ref, child) {
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: AppSpacing.iconMd,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text('Modo oscuro', style: AppTextStyles.bodyMedium),
          subtitle: Text(
            'Tema oscuro para reducir fatiga visual',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
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

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: AppSpacing.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildDropdownItem({
    required String title,
    required String subtitle,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: AppSpacing.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavigationItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: AppSpacing.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        padding: AppSpacing.allSm,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon,
            size: AppSpacing.iconMd,
            color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem({required String title, required String value}) {
    return ListTile(
      contentPadding: AppSpacing.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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

              // Ejecutar logout real con Firebase
              await ref.read(authNotifierProvider.notifier).signOut();

              // Navegar a login (el authStateChanges se encargará de esto también)
              if (context.mounted) {
                context.go(AppRouter.login);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
