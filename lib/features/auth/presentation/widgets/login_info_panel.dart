import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Panel lateral informativo del login
///
/// Visible solo en pantallas desktop (> 1024px).
/// Muestra características y valor del sistema Time Rega.
/// Usa gradiente moderno de 3 colores con iconos animados.
class LoginInfoPanel extends StatelessWidget {
  const LoginInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Gradiente moderno de 3 colores: Turquesa → Azul → Violeta
        gradient: LinearGradient(
          colors: [
            Color(0xFF00BCD4), // Turquesa
            Color(0xFF2196F3), // Azul
            Color(0xFF7C3AED), // Violeta
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Padding(
        padding: AppSpacing.symmetric(
          horizontal: AppSpacing.massive,
          vertical: AppSpacing.giant,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + Branding
            Row(
              children: [
                Container(
                  padding: AppSpacing.allMd,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                  child: const Icon(
                    Icons.access_time,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                AppSpacing.horizontalSpaceLg,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Rega',
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.verticalSpaceXs,
                    Text(
                      'Sistema de Control Horario',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            AppSpacing.verticalSpaceHuge,
            AppSpacing.verticalSpaceMd,

            // Título principal MUY GRANDE (multilinea) - letras más chatas
            Transform.scale(
              scaleY: 0.85, // Comprime verticalmente las letras (más chatas)
              child: Text(
                'Gestiona tu\ntiempo de forma\ninteligente',
                style: AppTextStyles.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700, // Bold normal
                  height: 1.15, // Ajustado para compensar el scale
                  fontSize: 52,
                  letterSpacing: 2.5,
                ),
              ),
            ),

            AppSpacing.verticalSpaceXl,

            // Subtítulo descriptivo más grande
            Text(
              'Accede al sistema de control horario más avanzado para empresas modernas.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                height: 1.6,
                fontSize: 16, // Aumentado
              ),
            ),

            AppSpacing.verticalSpaceHuge,
            AppSpacing.verticalSpaceLg,

            // Lista de características
            _buildFeature(
              icon: Icons.shield_outlined,
              title: 'Seguridad y privacidad garantizada',
              description:
                  'Tus datos están protegidos con los más altos estándares de seguridad',
            ),

            AppSpacing.verticalSpaceXxl,
            AppSpacing.verticalSpaceMd,

            _buildFeature(
              icon: Icons.groups_outlined,
              title: 'Gestión de equipos multiempresa',
              description:
                  'Administra múltiples equipos y departamentos desde un solo lugar',
            ),

            AppSpacing.verticalSpaceXxl,
            AppSpacing.verticalSpaceMd,

            _buildFeature(
              icon: Icons.schedule,
              title: 'Control horario en tiempo real',
              description:
                  'Visualiza fichajes y reportes actualizados al instante',
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de característica con ícono y texto
  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return _AnimatedFeature(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono con fondo semi-transparente (más grande)
          Container(
            padding: AppSpacing.allLg,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(
              icon,
              size: 28, // Aumentado
              color: Colors.white,
            ),
          ),

          AppSpacing.horizontalSpaceLg,

          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    // Aumentado de h5 a h4
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.verticalSpaceSm,
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    // Aumentado de bodySmall a bodyMedium
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.6,
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

/// Widget con animación de hover para características
class _AnimatedFeature extends StatefulWidget {
  final Widget child;

  const _AnimatedFeature({required this.child});

  @override
  State<_AnimatedFeature> createState() => _AnimatedFeatureState();
}

class _AnimatedFeatureState extends State<_AnimatedFeature> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isHovered ? 1.0 : 0.9,
          child: widget.child,
        ),
      ),
    );
  }
}
