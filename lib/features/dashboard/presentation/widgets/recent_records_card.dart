import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../models/time_record_model.dart';
import '../../providers/dashboard_provider.dart';
import 'records_table.dart';

/// Card de registros recientes
///
/// Muestra una tabla con los últimos 5 días agrupados del empleado.
/// Incluye navegación para ver todos los días (últimos 30 días).
///
/// Conectado con Riverpod para mostrar datos reales desde Firebase.
class RecentRecordsCard extends ConsumerWidget {
  const RecentRecordsCard({super.key});

  static const int maxGroupedDays = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last30DaysAsync = ref.watch(last30DaysRecordsProvider);

    return last30DaysAsync.when(
      data: (recordsList) {
        if (recordsList.isEmpty) {
          return _buildEmptyState();
        }

        // Agrupar TODOS los registros por fecha (ordenados DESC desde Firestore)
        final groupedByDate = <String, List<TimeRecordModel>>{};
        for (final record in recordsList) {
          groupedByDate.putIfAbsent(record.date, () => []).add(record);
        }

        // Limitar a N días agrupados (ya ordenados de más nuevo a más viejo)
        final limitedDays = groupedByDate.entries.take(maxGroupedDays);

        // Mapear a estructura esperada por RecordsTable (1 fila por día)
        final mappedRecords = limitedDays.map((entry) {
          final date = entry.key;
          final dayRecords = entry.value;

          final workRecords = dayRecords
              .where((r) => r.category == RecordCategory.work)
              .toList();
          final breakRecords = dayRecords
              .where((r) => r.category == RecordCategory.breakTime)
              .toList();

          final entrance =
              workRecords.isNotEmpty ? workRecords.first.startTime : '--:--';
          final exit =
              workRecords.isNotEmpty ? workRecords.last.endTime : '--:--';

          final totalMinutes = workRecords.fold<int>(
            0,
            (sum, r) => sum + r.durationMinutes,
          );
          final totalHours = _formatDuration(totalMinutes);

          final hadBreak = breakRecords.isNotEmpty;

          return {
            'date': _formatDate(date),
            'entrance': entrance,
            'exit': exit,
            'total': totalHours,
            'hadBreak': hadBreak,
            'status': 'complete',
          };
        }).toList();

        return _buildContent(context, mappedRecords);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Map<String, dynamic>> records,
  ) {
    final colors = AppColorsHelper.of(context);

    return CustomCard(
      elevation: CardElevation.medium,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: AppSpacing.iconMd,
                      color: colors.secondary,
                    ),
                    AppSpacing.horizontalSpaceSm,
                    Flexible(
                      child: Text(
                        'Registros Recientes',
                        style: AppTextStyles.h5.copyWith(
                          color: colors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón ver todo
              TextButton.icon(
                onPressed: () {
                  context.push(AppRouter.allRecentRecords);
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Ver todo'),
                style: TextButton.styleFrom(foregroundColor: colors.primary),
              ),
            ],
          ),

          AppSpacing.verticalSpaceLg,

          // Tabla de registros
          RecordsTable(
            records: records,
            onRecordTap: (record) {
              // TODO [FASE-2-SPRINT-2]: Mostrar detalle del registro
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Detalle de ${record['date']}')),
              );
            },
          ),

          // Nota informativa
          AppSpacing.verticalSpaceLg,

          Container(
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: colors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: AppSpacing.iconSm,
                  color: colors.info,
                ),
                AppSpacing.horizontalSpaceSm,
                Expanded(
                  child: Text(
                    'Mostrando los últimos ${records.length} días con actividad. Ver todo para más.',
                    style: AppTextStyles.bodySmall.copyWith(color: colors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Builder(
      builder: (context) {
        final colors = AppColorsHelper.of(context);
        return CustomCard(
          elevation: CardElevation.medium,
          padding: AppSpacing.cardLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: AppSpacing.iconMd,
                    color: colors.secondary,
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Flexible(
                    child: Text(
                      'Registros Recientes',
                      style: AppTextStyles.h5.copyWith(
                        color: colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpaceLg,
              const Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Builder(
      builder: (context) {
        final colors = AppColorsHelper.of(context);
        return CustomCard(
          elevation: CardElevation.medium,
          padding: AppSpacing.cardLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: AppSpacing.iconMd,
                    color: colors.secondary,
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Flexible(
                    child: Text(
                      'Registros Recientes',
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
                      Icons.event_busy,
                      size: 48,
                      color: colors.textTertiary,
                    ),
                    AppSpacing.verticalSpaceMd,
                    Text(
                      'No hay registros recientes',
                      style: AppTextStyles.bodyMedium.copyWith(
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

  Widget _buildErrorState(String errorMessage) {
    return Builder(
      builder: (context) {
        final colors = AppColorsHelper.of(context);
        return CustomCard(
          elevation: CardElevation.medium,
          padding: AppSpacing.cardLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: AppSpacing.iconMd,
                    color: colors.secondary,
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Flexible(
                    child: Text(
                      'Registros Recientes',
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
                    Icon(Icons.error_outline, size: 48, color: colors.error),
                    AppSpacing.verticalSpaceMd,
                    Text(
                      errorMessage,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.error,
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

  /// Formatear fecha de YYYY-MM-DD a DD/MM/YYYY
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  /// Formatear duración en minutos a "Xh Ymin"
  String _formatDuration(int minutes) {
    if (minutes == 0) return '--:--';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    return '${hours}h ${mins}min';
  }
}
