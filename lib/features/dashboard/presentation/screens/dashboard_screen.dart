import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/employee_header.dart';
import '../widgets/time_clock_card.dart';
import '../widgets/day_summary_card.dart';
import '../widgets/recent_records_card.dart';
import '../widgets/monthly_calendar_card.dart';
import '../widgets/weekly_summary_card.dart';
import '../widgets/quick_actions_card.dart';

/// Pantalla principal del Dashboard de Empleado
/// 
/// Muestra:
/// - Header con información del empleado
/// - Layout responsivo optimizado
/// - Datos en tiempo real desde Firebase + Riverpod
/// 
/// Layout adaptativo mejorado:
/// - Desktop: Multi-columna (60% + 40%)
/// - Tablet: 2 columnas balanceadas (60/40)
/// - Mobile: 1 columna vertical
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar usuario actual
    final userAsync = ref.watch(currentUserProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) {
          // No debería pasar si las rutas están protegidas
          return const Scaffold(
            body: Center(
              child: Text('Usuario no autenticado'),
            ),
          );
        }
        
        return _buildDashboard(context, ref, user);
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              AppSpacing.verticalSpaceMd,
              Text(
                'Error al cargar dashboard',
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
  
  Widget _buildDashboard(BuildContext context, WidgetRef ref, user) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header con información del empleado
          EmployeeHeader(
            employeeName: user.displayName,
            employeeId: user.employeeId,
            onAvatarTap: () => context.push(AppRouter.profile),
            onNotificationsTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificaciones en desarrollo'),
                ),
              );
            },
            onSettingsTap: () => context.push(AppRouter.settings),
          ),

          // Contenido principal con scroll
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                context.responsiveValue(
                  mobile: AppSpacing.lg,
                  tablet: AppSpacing.xxl,
                  desktop: AppSpacing.xxxl,
                ),
              ),
              child: _buildDashboardGrid(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context, WidgetRef ref) {
    // Seleccionar layout según breakpoint
    // TODO [FASE-2-SPRINT-1]: Pasar datos reales a los widgets de dashboard
    if (context.isDesktop) {
      return _buildDesktopLayout(context, ref);
    } else if (context.isMobile) {
      return _buildMobileLayout(context, ref);
    } else {
      return _buildTabletLayout(context, ref);
    }
  }

  // ==========================================================================
  // DESKTOP LAYOUT (>1024px)
  // ==========================================================================

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gap = LayoutProportions.desktopGap;

        return Column(
          children: [
            // Row 1: TimeClock 60% + Summary 40%
            _buildDesktopTopRow(context, ref, width, gap),
            
            SizedBox(height: gap),
            
            // Row 2: Recent Records 100%
            _buildDesktopRecordsRow(context, ref, width, gap),
            
            SizedBox(height: gap),
            
            // Row 3: Calendar 30% + Weekly 35% + Actions 35% (Fase 1.5.1)
            _buildDesktopBottomRow(context, width, gap),
          ],
        );
      },
    );
  }

  Widget _buildDesktopTopRow(BuildContext context, WidgetRef ref, double width, double gap) {
    // Para 2 elementos con 1 gap: (width - 1*gap) * proportion
    final availableWidth = width - gap;
    final clockWidth = availableWidth * LayoutProportions.desktopTimeClockWidth;
    final summaryWidth = availableWidth * (1 - LayoutProportions.desktopTimeClockWidth);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Clock Card (60%)
        SizedBox(
          width: clockWidth,
          child: const TimeClockCard(),
        ),
        
        SizedBox(width: gap),
        
        // Day Summary Card (40%)
        SizedBox(
          width: summaryWidth,
          child: const DaySummaryCard(),
        ),
      ],
    );
  }

  Widget _buildDesktopRecordsRow(BuildContext context, WidgetRef ref, double width, double gap) {
    // Recent Records al 100%
    return const RecentRecordsCard();
  }

  Widget _buildDesktopBottomRow(BuildContext context, double width, double gap) {
    // Para 3 elementos con 2 gaps: (width - 2*gap) * proportion
    final availableWidth = width - (2 * gap);
    final calendarWidth = availableWidth * LayoutProportions.desktopCalendarWidth;
    final weeklyWidth = availableWidth * LayoutProportions.desktopWeeklyWidth;
    final actionsWidth = availableWidth * LayoutProportions.desktopActionsWidth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Monthly Calendar (30%)
        SizedBox(
          width: calendarWidth,
          child: const MonthlyCalendarCard(),
        ),
        
        SizedBox(width: gap),
        
        // Weekly Summary (35%)
        SizedBox(
          width: weeklyWidth,
          child: const WeeklySummaryCard(),
        ),
        
        SizedBox(width: gap),
        
        // Quick Actions (35%)
        SizedBox(
          width: actionsWidth,
          child: const QuickActionsCard(),
        ),
      ],
    );
  }

  // ==========================================================================
  // MOBILE LAYOUT (<768px)
  // ==========================================================================

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    final gap = LayoutProportions.mobileGap;

    return Column(
      children: [
        const TimeClockCard(),
        SizedBox(height: gap),
        
        const DaySummaryCard(),
        SizedBox(height: gap),
        
        const RecentRecordsCard(),
        SizedBox(height: gap),
        
        const MonthlyCalendarCard(),
        SizedBox(height: gap),
        
        const WeeklySummaryCard(),
        SizedBox(height: gap),
        
        const QuickActionsCard(),
      ],
    );
  }

  // ==========================================================================
  // TABLET LAYOUT (768-1024px)
  // ==========================================================================

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gap = LayoutProportions.tabletGap;
        
        // Para 2 elementos con 1 gap: (width - 1*gap) * proportion
        final availableWidthRow1 = width - gap;
        final primaryWidth = availableWidthRow1 * LayoutProportions.tabletPrimaryWidth;
        final secondaryWidth = availableWidthRow1 * LayoutProportions.tabletSecondaryWidth;
        
        // Row 3: 50/50
        final availableWidthRow3 = width - gap;
        final calendarWidthTablet = availableWidthRow3 * 0.5;
        final weeklyWidthTablet = availableWidthRow3 * 0.5;

        return Column(
          children: [
            // Row 1: TimeClock 60% + Summary 40%
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: primaryWidth,
                  child: const TimeClockCard(),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: secondaryWidth,
                  child: const DaySummaryCard(),
                ),
              ],
            ),
            
            SizedBox(height: gap),
            
            // Row 2: Recent Records 100%
            const RecentRecordsCard(),
            
            SizedBox(height: gap),
            
            // Row 3: Calendar 50% + Weekly 50%
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: calendarWidthTablet,
                  child: const MonthlyCalendarCard(),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: weeklyWidthTablet,
                  child: const WeeklySummaryCard(),
                ),
              ],
            ),
            
            SizedBox(height: gap),
            
            // Row 4: Quick Actions 100%
            const QuickActionsCard(),
          ],
        );
      },
    );
  }
}

