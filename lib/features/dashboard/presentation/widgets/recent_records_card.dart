import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import 'records_table.dart';

/// Card de registros recientes
/// 
/// Muestra una tabla con los últimos 5 fichajes del empleado.
/// Incluye navegación para ver historial completo.
/// 
/// MOCK DATA: Usa MockData.recentRecords
class RecentRecordsCard extends StatelessWidget {
  const RecentRecordsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos mock
    final records = MockData.recentRecords;

    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: AppSpacing.iconMd,
                    color: AppColors.secondary,
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Text(
                    'Registros Recientes',
                    style: AppTextStyles.h5,
                  ),
                ],
              ),

              // Botón ver todo
              TextButton.icon(
                onPressed: () {
                  // TODO [FASE-2]: Navegar a historial completo
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
              // TODO [FASE-2]: Mostrar detalle del registro
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
              color: AppColors.info.withOpacity(0.1),
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
                    'Mostrando los últimos 5 registros. Ver historial completo para más.',
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
}

