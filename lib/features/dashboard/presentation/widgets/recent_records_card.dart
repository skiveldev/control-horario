import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../providers/dashboard_provider.dart';
import 'records_table.dart';

/// Card de registros recientes
/// 
/// Muestra una tabla con los últimos 5 fichajes del empleado.
/// Incluye navegación para ver historial completo.
/// 
/// Conectado con Riverpod para mostrar datos reales desde Firebase.
class RecentRecordsCard extends ConsumerWidget {
  const RecentRecordsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyRecordsAsync = ref.watch(monthlyRecordsProvider);

    return monthlyRecordsAsync.when(
      data: (recordsList) {
        // Limitar según breakpoint
        final maxRecords = context.isMobile ? 3 : 5;
        final records = recordsList.take(maxRecords).toList();

        // Si no hay registros
        if (records.isEmpty) {
          return _buildEmptyState();
        }

        // Mapear DailyRecordModel a estructura esperada por RecordsTable
        final mappedRecords = records.map((record) {
          final totalHours = _calculateTotalHours(record);
          return {
            'date': _formatDate(record.date),
            'entrance': record.clocks.clockIn ?? '--:--',
            'exit': record.clocks.clockOut ?? '--:--',
            'total': totalHours,
            'status': record.status.toString().split('.').last,
          };
        }).toList();

        return _buildContent(context, mappedRecords);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildContent(BuildContext context, List<Map<String, dynamic>> records) {

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
                      color: AppColors.secondary,
                    ),
                    AppSpacing.horizontalSpaceSm,
                    Flexible(
                      child: Text(
                        'Registros Recientes',
                        style: AppTextStyles.h5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón ver todo
              TextButton.icon(
                onPressed: () {
                  // TODO [FASE-2-SPRINT-2]: Navegar a historial completo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Historial completo en desarrollo'),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Ver todo'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
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
                SnackBar(
                  content: Text('Detalle de ${record['date']}'),
                ),
              );
            },
          ),

          // Nota informativa
          AppSpacing.verticalSpaceLg,

          Container(
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: AppSpacing.iconSm,
                  color: AppColors.info,
                ),
                AppSpacing.horizontalSpaceSm,
                Expanded(
                  child: Text(
                    'Mostrando los últimos ${records.length} registros. Ver historial completo para más.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                    ),
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
                color: AppColors.secondary,
              ),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Registros Recientes',
                  style: AppTextStyles.h5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceLg,
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
                color: AppColors.secondary,
              ),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Registros Recientes',
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
                  Icons.event_busy,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.verticalSpaceMd,
                Text(
                  'No hay registros este mes',
                  style: AppTextStyles.bodyMedium.copyWith(
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

  Widget _buildErrorState(String errorMessage) {
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
                color: AppColors.secondary,
              ),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Registros Recientes',
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
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                AppSpacing.verticalSpaceMd,
                Text(
                  'Error al cargar registros',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
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

  /// Formatear fecha de YYYY-MM-DD a formato legible
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy', 'es');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Calcular total de horas trabajadas
  String _calculateTotalHours(dynamic record) {
    if (record.clockInTimestamp == null || record.clockOutTimestamp == null) {
      return '--:--';
    }

    final duration = record.clockOutTimestamp!
        .difference(record.clockInTimestamp!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours}h ${minutes}min';
  }
}

