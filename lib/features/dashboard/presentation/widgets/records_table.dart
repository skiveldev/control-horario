import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/cards/clocking_status_badge.dart';

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

  /// Convierte el estado string (datos mock) al enum ClockingStatus
  ClockingStatus _mapStatusToEnum(String status) {
    switch (status.toLowerCase()) {
      case 'completo':
        return ClockingStatus.complete;
      case 'incompleto':
        return ClockingStatus.incomplete;
      case 'sin_fichar':
        return ClockingStatus.incomplete;
      case 'auto_cerrado':
      case 'auto-cerrado':
        return ClockingStatus.autoClosed;
      case 'editado':
        return ClockingStatus.edited;
      case 'activo':
      case 'en_curso':
        return ClockingStatus.ongoing;
      default:
        return ClockingStatus.complete;
    }
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
    return Builder(
      builder: (context) {
        final colors = AppColorsHelper.of(context);
        return InkWell(
          onTap: onRecordTap != null ? () => onRecordTap!(record) : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Container(
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: colors.border,
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
                        color: colors.textPrimary,
                      ),
                    ),
                    ClockingStatusBadge(
                      status: _mapStatusToEnum(record['status'] as String),
                    ),
                  ],
                ),

                AppSpacing.verticalSpaceSm,

                // Entrada - Salida
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Entrada',
                        record['entrance'] as String,
                        Icons.login,
                      ),
                    ),
                    AppSpacing.horizontalSpaceMd,
                    Expanded(
                      child: _buildInfoItem(
                        context,
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
                  context,
                  'Total',
                  record['total'] as String,
                  Icons.schedule,
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    final colors = AppColorsHelper.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: colors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
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
    return Builder(
      builder: (context) {
        final colors = AppColorsHelper.of(context);
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
              color: colors.border,
              width: 1,
            ),
          ),
          children: [
            // Header
            _buildTableHeader(context),

            // Rows
            ...records.map((record) => _buildTableRow(context, record)),
          ],
        );
      }
    );
  }

  TableRow _buildTableHeader(BuildContext context) {
    final colors = AppColorsHelper.of(context);
    return TableRow(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusSm),
          topRight: Radius.circular(AppSpacing.radiusSm),
        ),
      ),
      children: [
        _buildHeaderCell(context, 'FECHA'),
        _buildHeaderCell(context, 'ENTRADA'),
        _buildHeaderCell(context, 'SALIDA'),
        _buildHeaderCell(context, 'TOTAL'),
        _buildHeaderCell(context, 'ESTADO'),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    final colors = AppColorsHelper.of(context);
    return Padding(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  TableRow _buildTableRow(BuildContext context, Map<String, dynamic> record) {
    final colors = AppColorsHelper.of(context);
    return TableRow(
      decoration: BoxDecoration(
        color: colors.surface,
      ),
      children: [
        _buildTableCell(context, record['date'] as String),
        _buildTableCell(context, record['entrance'] as String),
        _buildTableCell(context, record['exit'] as String),
        _buildTableCell(context, record['total'] as String, bold: true),
        Padding(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: ClockingStatusBadge(
            status: _mapStatusToEnum(record['status'] as String),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(BuildContext context, String text, {bool bold = false}) {
    final colors = AppColorsHelper.of(context);
    return Padding(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

