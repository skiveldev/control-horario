import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../core/theme/app_colors_helper.dart';
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
    final todayRecordsAsync = ref.watch(todayRecordsProvider);
    final todayMinutes = ref.watch(todayTotalMinutesProvider);
    final todayClockIn = ref.watch(todayClockInTimeProvider);
    final todayBreakMinutes = ref.watch(todayBreakMinutesProvider);
    final userAsync = ref.watch(currentUserProvider);

    return todayRecordsAsync.when(
      data: (todayRecords) => userAsync.when(
        data: (user) {
          if (user == null) {
            return _buildEmptyState('Usuario no encontrado');
          }

          // Si no hay registros de hoy
          if (todayRecords.isEmpty || todayClockIn == null) {
            return _buildEmptyState('Sin registro de entrada hoy');
          }

          // Calcular datos
          final entranceTime = todayClockIn;
          final totalHours = todayMinutes / 60.0;
          final expectedHours =
              user.weeklyHours / 5.0; // Horas diarias esperadas
          final estimatedExit = _calculateEstimatedExit(
            entranceTime,
            expectedHours,
          );
          // ✨ Tiempo de pausa desde provider
          final breakTime = todayBreakMinutes;

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
    final colors = AppColorsHelper.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomCard(
      elevation: CardElevation.medium,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del card
          Row(
            children: [
              Icon(Icons.today, size: AppSpacing.iconMd, color: colors.info),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Resumen del Día',
                  style: AppTextStyles.h5.copyWith(color: colors.textPrimary),
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
                      color: colors.success,
                      icon: Icons.login,
                    ),
                    AppSpacing.verticalSpaceMd,
                    TimeInfoBadge(
                      label: 'Salida estimada',
                      time: estimatedExit,
                      color:
                          isDark ? AppColorsDark.purple : AppColors.secondary,
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
                          color: colors.success,
                          icon: Icons.login,
                        ),
                      ),
                      AppSpacing.horizontalSpaceMd,
                      Expanded(
                        child: TimeInfoBadge(
                          label: 'Salida estimada',
                          time: estimatedExit,
                          color: isDark
                              ? AppColorsDark.purple
                              : AppColors.secondary,
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
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState(String message) {
    return Builder(
      builder: (context) {
        final colors = AppColorsHelper.of(context);
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
                    color: colors.info,
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Flexible(
                    child: Text(
                      'Resumen del Día',
                      style: AppTextStyles.h5.copyWith(
                        color: colors.textPrimary,
                      ),
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
                      color: colors.textTertiary,
                    ),
                    AppSpacing.verticalSpaceMd,
                    Text(
                      message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakTimeBadge(int breakMinutes) {
    return Builder(
      builder: (context) {
        final colors = AppColorsHelper.of(context);
        final hours = breakMinutes ~/ 60;
        final minutes = breakMinutes % 60;

        // ✨ Mostrar mensaje diferente si no hay pausa
        final subtitle = breakMinutes == 0
            ? 'No has tomado pausas hoy'
            : '${hours}h ${minutes}min acumulados (cuenta como trabajo)';

        return Container(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: colors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: colors.warning.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                breakMinutes == 0 ? Icons.coffee_outlined : Icons.coffee,
                size: AppSpacing.iconMd,
                color: colors.warning,
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
                        color: colors.warning,
                      ),
                    ),
                    AppSpacing.verticalSpaceXs,
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
  String _calculateEstimatedExit(String clockInTime, double expectedHours) {
    try {
      // Parsear hora de entrada "HH:mm"
      final parts = clockInTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      final clockInDateTime =
          DateTime(now.year, now.month, now.day, hour, minute);

      final estimatedExit = clockInDateTime.add(
        Duration(minutes: (expectedHours * 60).round()),
      );

      return _formatTime(estimatedExit);
    } catch (e) {
      return '--:--';
    }
  }
}
