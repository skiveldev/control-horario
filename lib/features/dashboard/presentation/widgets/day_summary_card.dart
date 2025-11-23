import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/clocking_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'work_hours_progress.dart';
import 'time_info_badge.dart';

/// Card de resumen del día
/// 
/// Muestra:
/// - Progreso de horas trabajadas
/// - Hora de entrada
/// - Salida estimada
/// - Tiempo de pausa acumulado
/// 
/// Conectado con Riverpod para mostrar datos reales desde Firebase.
class DaySummaryCard extends ConsumerWidget {
  const DaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar providers
    final todayRecordAsync = ref.watch(todayRecordProvider);
    final todayMinutes = ref.watch(todayTotalMinutesProvider);
    final userAsync = ref.watch(currentUserProvider);

    return todayRecordAsync.when(
      data: (todayRecord) => userAsync.when(
        data: (user) {
          if (user == null) {
            return _buildEmptyState('Usuario no encontrado');
          }

          // Si no hay registro de hoy
          if (todayRecord == null || todayRecord.clockInTimestamp == null) {
            return _buildEmptyState('Sin registro de entrada hoy');
          }

          // Calcular datos
          final entranceTime = _formatTime(todayRecord.clockInTimestamp!);
          final totalHours = todayMinutes / 60.0;
          final expectedHours = user.weeklyHours / 5.0; // Horas diarias esperadas
          final estimatedExit = _calculateEstimatedExit(
            todayRecord.clockInTimestamp!,
            expectedHours,
          );
          final breakTime = 0; // TODO [FASE-2-SPRINT-2]: Calcular pausas reales

          return _buildContent(
            context: context,
            totalHours: totalHours,
            expectedHours: expectedHours,
            entranceTime: entranceTime,
            estimatedExit: estimatedExit,
            breakTime: breakTime,
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildEmptyState('Error al cargar usuario'),
      ),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildEmptyState('Error al cargar registro'),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required double totalHours,
    required double expectedHours,
    required String entranceTime,
    required String estimatedExit,
    required int breakTime,
  }) {

    return CustomCard(
      elevation: CardElevation.medium,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del card
          Row(
            children: [
              Icon(
                Icons.today,
                size: AppSpacing.iconMd,
                color: AppColors.info,
              ),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Resumen del Día',
                  style: AppTextStyles.h5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceLg,

          // Progreso de horas trabajadas
          WorkHoursProgress(
            workedHours: totalHours,
            expectedHours: expectedHours,
          ),

          AppSpacing.verticalSpaceXxl,

          // Badges de información
          LayoutBuilder(
            builder: (context, constraints) {
              // Si el ancho es pequeño, badges en columna
              if (constraints.maxWidth < 300 || context.isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TimeInfoBadge(
                      label: 'Hora de entrada',
                      time: entranceTime,
                      color: AppColors.success,
                      icon: Icons.login,
                    ),
                    AppSpacing.verticalSpaceMd,
                    TimeInfoBadge(
                      label: 'Salida estimada',
                      time: estimatedExit,
                      color: AppColors.warning,
                      icon: Icons.logout,
                    ),
                    AppSpacing.verticalSpaceMd,
                    _buildBreakTimeBadge(breakTime),
                  ],
                );
              }

              // Layout normal: grid 2 columnas
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TimeInfoBadge(
                          label: 'Hora de entrada',
                          time: entranceTime,
                          color: AppColors.success,
                          icon: Icons.login,
                        ),
                      ),
                      AppSpacing.horizontalSpaceMd,
                      Expanded(
                        child: TimeInfoBadge(
                          label: 'Salida estimada',
                          time: estimatedExit,
                          color: AppColors.warning,
                          icon: Icons.logout,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpaceMd,
                  _buildBreakTimeBadge(breakTime),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomCard(
      elevation: CardElevation.medium,
      padding: AppSpacing.cardLarge,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return CustomCard(
      elevation: CardElevation.medium,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del card
          Row(
            children: [
              Icon(
                Icons.today,
                size: AppSpacing.iconMd,
                color: AppColors.info,
              ),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Resumen del Día',
                  style: AppTextStyles.h5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceLg,
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.verticalSpaceMd,
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakTimeBadge(int breakMinutes) {
    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.coffee,
            size: AppSpacing.iconMd,
            color: AppColors.warning,
          ),
          AppSpacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tiempo de pausa',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  '${(breakMinutes ~/ 60)}h ${breakMinutes % 60}min acumulados hoy',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  /// Formatear DateTime a string HH:mm
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Calcular hora estimada de salida
  String _calculateEstimatedExit(DateTime clockInTime, double expectedHours) {
    final estimatedExit = clockInTime.add(
      Duration(minutes: (expectedHours * 60).round()),
    );
    return _formatTime(estimatedExit);
  }
}

