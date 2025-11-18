import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/layouts/custom_app_bar.dart';

/// Pantalla de configuración
/// 
/// Permite al usuario ajustar preferencias de la aplicación.
/// Solo UI en Fase 1, funcionalidad real en Fase 2.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Estados mock de configuraciones
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _clockingReminders = false;
  String _language = 'es';
  String _theme = 'light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Configuración',
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
                    _buildDropdownItem(
                      title: 'Idioma',
                      subtitle: 'Selecciona el idioma de la interfaz',
                      value: _language,
                      options: const {
                        'es': 'Español',
                        'en': 'English',
                      },
                      onChanged: (value) {
                        setState(() => _language = value!);
                        // TODO [FASE-2]: Cambiar idioma de la app
                      },
                    ),
                    _buildDropdownItem(
                      title: 'Tema',
                      subtitle: 'Apariencia de la aplicación',
                      value: _theme,
                      options: const {
                        'light': 'Claro',
                        'dark': 'Oscuro',
                        'system': 'Sistema',
                      },
                      onChanged: (value) {
                        setState(() => _theme = value!);
                        // TODO [FASE-2]: Cambiar tema de la app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tema oscuro disponible en Fase 2'),
                          ),
                        );
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
                        context.push(AppRouter.profile);
                      },
                    ),
                    _buildNavigationItem(
                      title: 'Cambiar contraseña',
                      subtitle: 'Actualiza tu contraseña de acceso',
                      icon: Icons.lock,
                      onTap: () {
                        // TODO [FASE-2]: Navegar a cambio de contraseña
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cambio de contraseña en desarrollo'),
                          ),
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
                    _buildInfoItem(
                      title: 'Versión',
                      value: '1.0.0',
                    ),
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
                  borderColor: AppColors.error,
                  child: InkWell(
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          color: AppColors.error,
                        ),
                        AppSpacing.horizontalSpaceMd,
                        Expanded(
                          child: Text(
                            'Cerrar sesión',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.error,
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
        ),

        AppSpacing.verticalSpaceMd,

        // Contenido de la sección
        CustomCard(
          elevation: CardElevation.low,
          padding: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
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
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
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
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
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
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(
          icon,
          size: AppSpacing.iconMd,
          color: AppColors.primary,
        ),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: AppSpacing.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO [FASE-2]: Lógica real de logout
              context.go(AppRouter.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

