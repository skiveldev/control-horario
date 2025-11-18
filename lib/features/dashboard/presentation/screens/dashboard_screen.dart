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
/// - Grid responsivo de cards (fichaje, resumen, registros, calendario)
/// - Acciones rápidas
/// 
/// Layout adaptativo:
/// - Mobile: 1 columna
/// - Tablet: 2 columnas
/// - Desktop: 3 columnas
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
    // Número de columnas según breakpoint
    final columns = context.columns;
    final gap = context.gridGap;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular ancho de cada card
        final totalGaps = (columns - 1) * gap;
        final availableWidth = constraints.maxWidth - totalGaps;
        final cardWidth = availableWidth / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            // Card de Fichaje (Completado)
            SizedBox(
              width: cardWidth,
              child: const TimeClockCard(),
            ),

            // Card de Resumen del Día (Completado)
            SizedBox(
              width: cardWidth,
              child: const DaySummaryCard(),
            ),

            // Card de Registros Recientes (Completado)
            SizedBox(
              width: cardWidth,
              child: const RecentRecordsCard(),
            ),

            // Card de Calendario Mensual (Completado)
            SizedBox(
              width: cardWidth,
              child: const MonthlyCalendarCard(),
            ),

            // Card de Resumen Semanal (Completado)
            SizedBox(
              width: cardWidth,
              child: const WeeklySummaryCard(),
            ),

            // Card de Acciones Rápidas (Completado)
            SizedBox(
              width: cardWidth,
              child: const QuickActionsCard(),
            ),
          ],
        );
      },
    );
  }
}

