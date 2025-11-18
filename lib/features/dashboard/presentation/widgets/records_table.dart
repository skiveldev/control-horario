import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import 'record_status_badge.dart';

/// Tabla responsiva de registros de fichaje
/// 
/// Muestra una lista de registros con fecha, entrada, salida, total y estado.
/// Se adapta a mobile con cards en lugar de tabla.
/// 
/// Ejemplo de uso:
/// ```dart
/// RecordsTable(
///   records: [
///     {
///       'date': '07/12/2023',
///       'entrance': '09:00',
///       'exit': '18:00',
///       'total': '8.3h',
///       'status': 'completo',
///     },
///     ...
///   ],
/// )
/// ```
class RecordsTable extends StatelessWidget {
  /// Lista de registros a mostrar
  final List<Map<String, dynamic>> records;

  /// Callback al hacer tap en un registro
  final void Function(Map<String, dynamic>)? onRecordTap;

  const RecordsTable({
    super.key,
    required this.records,
    this.onRecordTap,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return _buildMobileView();
    }

    return _buildTableView();
  }

  // ==========================================================================
  // MOBILE VIEW (Cards)
  // ==========================================================================

  Widget _buildMobileView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (context, index) => AppSpacing.verticalSpaceMd,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildMobileRecordCard(record);
      },
    );
  }

  Widget _buildMobileRecordCard(Map<String, dynamic> record) {
    return InkWell(
      onTap: onRecordTap != null ? () => onRecordTap!(record) : null,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha + Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record['date'] as String,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                RecordStatusBadge(status: record['status'] as String),
              ],
            ),

            AppSpacing.verticalSpaceSm,

            // Entrada - Salida
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Entrada',
                    record['entrance'] as String,
                    Icons.login,
                  ),
                ),
                AppSpacing.horizontalSpaceMd,
                Expanded(
                  child: _buildInfoItem(
                    'Salida',
                    record['exit'] as String,
                    Icons.logout,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpaceSm,

            // Total
            _buildInfoItem(
              'Total',
              record['total'] as String,
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TABLE VIEW (Desktop/Tablet)
  // ==========================================================================

  Widget _buildTableView() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Fecha
        1: FlexColumnWidth(1.5), // Entrada
        2: FlexColumnWidth(1.5), // Salida
        3: FlexColumnWidth(1.5), // Total
        4: FlexColumnWidth(2), // Estado
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      children: [
        // Header
        _buildTableHeader(),

        // Rows
        ...records.map((record) => _buildTableRow(record)),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusSm),
          topRight: Radius.circular(AppSpacing.radiusSm),
        ),
      ),
      children: [
        _buildHeaderCell('FECHA'),
        _buildHeaderCell('ENTRADA'),
        _buildHeaderCell('SALIDA'),
        _buildHeaderCell('TOTAL'),
        _buildHeaderCell('ESTADO'),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> record) {
    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.surface,
      ),
      children: [
        _buildTableCell(record['date'] as String),
        _buildTableCell(record['entrance'] as String),
        _buildTableCell(record['exit'] as String),
        _buildTableCell(record['total'] as String, bold: true),
        Padding(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: RecordStatusBadge(status: record['status'] as String),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool bold = false}) {
    return Padding(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

