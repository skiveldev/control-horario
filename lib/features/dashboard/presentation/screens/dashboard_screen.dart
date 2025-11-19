import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/breakpoints.dart';
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
/// - Layout responsivo optimizado (Fase 1.5)
/// - Acciones rápidas
/// 
/// Layout adaptativo mejorado:
/// - Desktop: Multi-columna con sidebar sticky (60% + 25% + 15%)
/// - Tablet: 2 columnas balanceadas (60/40)
/// - Mobile: 1 columna vertical
/// 
/// MOCK DATA: Usa datos de MockData para simular la información
/// TODO [FASE-2]: Conectar con providers reales de Riverpod
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header con información del empleado
          EmployeeHeader(
            onAvatarTap: () {
              context.push(AppRouter.profile);
            },
            onNotificationsTap: () {
              // TODO [FASE-2]: Mostrar panel de notificaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificaciones en desarrollo'),
                ),
              );
            },
            onSettingsTap: () {
              context.push(AppRouter.settings);
            },
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
              child: _buildDashboardGrid(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    // Seleccionar layout según breakpoint (Fase 1.5)
    if (context.isDesktop) {
      return _buildDesktopLayout(context);
    } else if (context.isMobile) {
      return _buildMobileLayout(context);
    } else {
      return _buildTabletLayout(context);
    }
  }

  // ==========================================================================
  // DESKTOP LAYOUT (>1024px) - Fase 1.5
  // ==========================================================================

  Widget _buildDesktopLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gap = LayoutProportions.desktopGap;

        return Column(
          children: [
            // Row 1: TimeClock 60% + Summary 40%
            _buildDesktopTopRow(context, width, gap),
            
            SizedBox(height: gap),
            
            // Row 2: Recent Records 100%
            _buildDesktopRecordsRow(context, width, gap),
            
            SizedBox(height: gap),
            
            // Row 3: Calendar 30% + Weekly 35% + Actions 35% (Fase 1.5.1)
            _buildDesktopBottomRow(context, width, gap),
          ],
        );
      },
    );
  }

  Widget _buildDesktopTopRow(BuildContext context, double width, double gap) {
    final clockWidth = width * LayoutProportions.desktopTimeClockWidth - gap / 2;
    final summaryWidth = width * (1 - LayoutProportions.desktopTimeClockWidth) - gap / 2;

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

  Widget _buildDesktopRecordsRow(BuildContext context, double width, double gap) {
    // Recent Records al 100%
    return const RecentRecordsCard();
  }

  Widget _buildDesktopBottomRow(BuildContext context, double width, double gap) {
    // Calcular anchos para 3 cards: 30% + 35% + 35% (Fase 1.5.1)
    final calendarWidth = width * LayoutProportions.desktopCalendarWidth - gap * 2 / 3;
    final weeklyWidth = width * LayoutProportions.desktopWeeklyWidth - gap * 2 / 3;
    final actionsWidth = width * LayoutProportions.desktopActionsWidth - gap * 2 / 3;

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
  // MOBILE LAYOUT (<768px) - Fase 1.5
  // ==========================================================================

  Widget _buildMobileLayout(BuildContext context) {
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
  // TABLET LAYOUT (768-1024px) - Fase 1.5
  // ==========================================================================

  Widget _buildTabletLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final gap = LayoutProportions.tabletGap;
        final primaryWidth = width * LayoutProportions.tabletPrimaryWidth - gap / 2;
        final secondaryWidth = width * LayoutProportions.tabletSecondaryWidth - gap / 2;

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
                  width: width * 0.5 - gap / 2,
                  child: const MonthlyCalendarCard(),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: width * 0.5 - gap / 2,
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

