import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/floating_card.dart';
import '../../../../shared/widgets/navigation/mobile_drawer.dart';
import '../../../../shared/widgets/navigation/responsive_navigation.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/schedule_summary_section.dart';
import '../widgets/annual_calendar_section.dart';

/// Pantalla de Calendario Laboral del empleado
///
/// Muestra:
/// - Sección "Mi Horario" (horario semanal en modo lectura)
/// - Calendario anual con festivos y vacaciones
///
/// Sigue el mismo patrón responsivo que DashboardScreen.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Usuario no autenticado')),
          );
        }
        return _buildScreen(context, user.userId);
      },
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              AppSpacing.verticalSpaceMd,
              Text(
                'Error al cargar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppSpacing.verticalSpaceSm,
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const double _desktopFloatingHeaderReservedHeight = 88.0;

  Widget _buildScreen(BuildContext context, String userId) {
    final isMobile = context.isMobile || context.isTablet;
    final isDesktop = context.isDesktop;

    final appBar = _buildAppBar(context, isMobile);
    final content = _buildCalendarContent(context, userId);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isMobile ? const MobileDrawer() : null,
      body: ResponsiveNavigation(
        child: isDesktop
            ? Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxxl,
                      _desktopFloatingHeaderReservedHeight,
                      AppSpacing.xxxl,
                      AppSpacing.xxxl,
                    ),
                    child: content,
                  ),
                  Positioned(
                    top: 0,
                    left: AppSpacing.xxxl,
                    right: AppSpacing.xxxl,
                    child: appBar,
                  ),
                ],
              )
            : Column(
                children: [
                  appBar,
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
              ),
      ),
    );
  }

  Widget _buildCalendarContent(BuildContext context, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScheduleSummarySection(employeeId: userId),
        const SizedBox(height: AppSpacing.xxl),
        const Divider(),
        const SizedBox(height: AppSpacing.xxl),
        const AnnualCalendarSection(),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, bool isMobile) {
    final isDesktop = context.isDesktop;

    final content = SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveValue(
            mobile: AppSpacing.md,
            tablet: AppSpacing.lg,
            desktop: AppSpacing.lg,
          ),
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            if (isMobile) ...[
              Builder(
                builder: (scaffoldContext) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                  tooltip: 'Abrir menú',
                ),
              ),
              AppSpacing.horizontalSpaceMd,
            ],
            Icon(
              Icons.calendar_month_outlined,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            AppSpacing.horizontalSpaceMd,
            Flexible(
              child: Text(
                'Calendario',
                style: AppTextStyles.h4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return FloatingCard(child: content);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );
  }
}
