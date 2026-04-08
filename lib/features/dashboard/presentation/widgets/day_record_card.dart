import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../models/time_record_model.dart';

/// Card de un día con registros colapsable/expandible
///
/// Vista colapsada: Muestra resumen del día
/// Vista expandida: Muestra tabla de registros con acciones
class DayRecordCard extends StatefulWidget {
  final DateTime date;
  final List<TimeRecordModel> records;
  final int plannedMinutes;
  final bool isToday;
  final VoidCallback? onAddRecord;
  final Function(TimeRecordModel)? onEditRecord;
  final Function(TimeRecordModel)? onCopyRecord;
  final Function(TimeRecordModel)? onDeleteRecord;

  const DayRecordCard({
    super.key,
    required this.date,
    required this.records,
    this.plannedMinutes = 0,
    this.isToday = false,
    this.onAddRecord,
    this.onEditRecord,
    this.onCopyRecord,
    this.onDeleteRecord,
  });

  @override
  State<DayRecordCard> createState() => _DayRecordCardState();
}

class _DayRecordCardState extends State<DayRecordCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final totalMinutes = widget.records.fold<int>(
      0,
      (sum, record) => sum + record.durationMinutes,
    );
    final differenceMinutes = totalMinutes - widget.plannedMinutes;

    return Container(
      margin: EdgeInsets.only(
        bottom: AppSpacing.md,
        left: isMobile ? 0 : AppSpacing.sm,
        right: isMobile ? 0 : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: widget.isToday
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.borderLight,
          width: widget.isToday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header colapsable
          _buildHeader(context, totalMinutes, differenceMinutes, isMobile),

          // Contenido expandido
          if (_isExpanded) _buildExpandedContent(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int totalMinutes,
    int differenceMinutes,
    bool isMobile,
  ) {
    final dayNumber = widget.date.day;
    // ✨ Obtener mes abreviado dinámicamente
    final monthAbbr = DateFormat('MMM', 'es_ES').format(widget.date);
    final weekDay = DateFormat('EEEE', 'es_ES').format(widget.date);
    final weekDayCapitalized = weekDay[0].toUpperCase() + weekDay.substring(1);

    final workedHours = totalMinutes / 60;
    final plannedHours = widget.plannedMinutes / 60;
    final differenceColor = _getDifferenceColor(differenceMinutes);

    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Padding(
        padding: AppSpacing.allLg,
        child: Row(
          children: [
            // Día y nombre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: AppSpacing.borderRadiusXs,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: AppSpacing.iconXs,
                                color: AppColors.primary,
                              ),
                              AppSpacing.horizontalSpaceXs,
                              Text(
                                'HOY',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.isToday) AppSpacing.horizontalSpaceSm,
                      // ✨ Usar mes dinámico en lugar de hardcoded "dic."
                      Text(
                        '$dayNumber $monthAbbr.',
                        style: AppTextStyles.h5.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalSpaceXs,
                  Text(
                    weekDayCapitalized,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.horizontalSpaceLg,

            // Resumen de horas
            if (!isMobile) ...[
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: AppSpacing.iconMd,
                    color: AppColors.textSecondary,
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Flexible(
                    child: Text(
                      '${workedHours.toStringAsFixed(1)}h / ${plannedHours.toStringAsFixed(1)}h',
                      style: AppTextStyles.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpacing.horizontalSpaceMd,
                  Flexible(
                    child: Text(
                      '${differenceMinutes >= 0 ? '+' : ''}${(differenceMinutes / 60).toStringAsFixed(1)}h',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: differenceColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              AppSpacing.horizontalSpaceLg,
            ],

            // Iconos de acción
            IconButton(
              icon: const Icon(Icons.more_vert),
              iconSize: AppSpacing.iconMd,
              onPressed: null, // Sin acciones por ahora
              tooltip: 'Próximamente',
              color: AppColors.textTertiary,
            ),

            AppSpacing.horizontalSpaceSm,

            // Icono expandir/colapsar
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: const Icon(Icons.expand_more),
                iconSize: AppSpacing.iconLg,
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                tooltip: _isExpanded ? 'Contraer' : 'Expandir',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, bool isMobile) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            if (widget.records.isEmpty)
              _buildEmptyState()
            else
              _buildRecordsTable(isMobile),

            // Botón añadir
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: AppSpacing.allXxl,
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: AppSpacing.iconXxl,
            color: AppColors.textTertiary,
          ),
          AppSpacing.verticalSpaceMd,
          Text(
            'Sin registros',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsTable(bool isMobile) {
    return Padding(
      padding: AppSpacing.allLg,
      child: Column(
        children: [
          // Encabezados de tabla
          if (!isMobile) _buildTableHeader(),

          // Filas de registros
          ...widget.records.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            return _buildRecordRow(
              record,
              index % 2 == 0,
              isMobile,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusSm),
          topRight: Radius.circular(AppSpacing.radiusSm),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 22,
            child: Text(
              'TIEMPO',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 22,
            child: Text(
              'CATEGORÍA',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 26,
            child: Text(
              'UBICACIÓN',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 18,
            child: Text(
              'ESTADO',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 120), // Espacio para acciones
        ],
      ),
    );
  }

  Widget _buildRecordRow(
    TimeRecordModel record,
    bool isEven,
    bool isMobile,
  ) {
    final categoryColor = record.category == RecordCategory.work
        ? AppColors.info
        : AppColors.warning;

    if (isMobile) {
      return _buildRecordRowMobile(record, categoryColor);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isEven ? AppColors.surface : AppColors.surfaceVariant,
        border: const Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Tiempo
          Expanded(
            flex: 22,
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: AppSpacing.iconSm,
                  color: AppColors.textSecondary,
                ),
                AppSpacing.horizontalSpaceXs,
                // ✨ Mostrar --:-- si es registro activo
                Flexible(
                  child: Text(
                    record.isActive
                        ? '${record.startTime} - --:--'
                        : '${record.startTime} - ${record.endTime}',
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Categoría
          Expanded(
            flex: 22,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.horizontalSpaceXs,
                // ✨ Mostrar "En curso..." si es registro activo
                Flexible(
                  child: Text(
                    record.isActive
                        ? '${record.categoryName} (En curso...)'
                        : '${record.categoryName} (${(record.durationMinutes / 60).toStringAsFixed(1)}h)',
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Ubicación
          Expanded(
            flex: 26,
            child: Row(
              children: [
                Icon(
                  Icons.place,
                  size: AppSpacing.iconSm,
                  color: AppColors.textSecondary,
                ),
                AppSpacing.horizontalSpaceXs,
                Expanded(
                  child: Text(
                    record.location,
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Estado
          Expanded(
            flex: 18,
            child: _buildStatusBadge(record),
          ),

          // Acciones
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  iconSize: AppSpacing.iconMd,
                  onPressed: record.canEdit && widget.onEditRecord != null
                      ? () => widget.onEditRecord!(record)
                      : null,
                  tooltip: 'Editar',
                  color: record.canEdit
                      ? AppColors.textSecondary
                      : AppColors.textTertiary,
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy),
                  iconSize: AppSpacing.iconMd,
                  onPressed: widget.onCopyRecord != null
                      ? () => widget.onCopyRecord!(record)
                      : null,
                  tooltip: 'Copiar',
                  color: AppColors.textSecondary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: AppSpacing.iconMd,
                  onPressed: record.canDelete && widget.onDeleteRecord != null
                      ? () => widget.onDeleteRecord!(record)
                      : null,
                  tooltip: 'Eliminar',
                  color: record.canDelete
                      ? AppColors.error
                      : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordRowMobile(
    TimeRecordModel record,
    Color categoryColor,
  ) {
    return Container(
      padding: AppSpacing.allMd,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: categoryColor,
                  shape: BoxShape.circle,
                ),
              ),
              AppSpacing.horizontalSpaceXs,
              Flexible(
                child: Text(
                  record.categoryName,
                  style: AppTextStyles.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(record),
            ],
          ),
          AppSpacing.verticalSpaceSm,
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: AppSpacing.iconSm,
                color: AppColors.textSecondary,
              ),
              AppSpacing.horizontalSpaceXs,
              // ✨ Mostrar --:-- si es registro activo
              Flexible(
                child: Text(
                  record.isActive
                      ? '${record.startTime} - --:--'
                      : '${record.startTime} - ${record.endTime}',
                  style: AppTextStyles.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSpacing.horizontalSpaceMd,
              // ✨ Mostrar "En curso..." si es registro activo
              Flexible(
                child: Text(
                  record.isActive
                      ? '(En curso...)'
                      : '(${(record.durationMinutes / 60).toStringAsFixed(1)}h)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSm,
          Row(
            children: [
              Icon(
                Icons.place,
                size: AppSpacing.iconSm,
                color: AppColors.textSecondary,
              ),
              AppSpacing.horizontalSpaceXs,
              Expanded(
                child: Text(
                  record.location,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: record.canEdit && widget.onEditRecord != null
                    ? () => widget.onEditRecord!(record)
                    : null,
                icon: const Icon(Icons.edit, size: AppSpacing.iconSm),
                label: const Text('Editar'),
              ),
              TextButton.icon(
                onPressed: widget.onCopyRecord != null
                    ? () => widget.onCopyRecord!(record)
                    : null,
                icon: const Icon(Icons.content_copy, size: AppSpacing.iconSm),
                label: const Text('Copiar'),
              ),
              TextButton.icon(
                onPressed: record.canDelete && widget.onDeleteRecord != null
                    ? () => widget.onDeleteRecord!(record)
                    : null,
                icon: const Icon(Icons.delete, size: AppSpacing.iconSm),
                label: const Text('Eliminar'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TimeRecordModel record) {
    if (record.validationStatus == ValidationStatus.editable) {
      return const SizedBox.shrink();
    }

    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    switch (record.validationStatus) {
      case ValidationStatus.validated:
        badgeColor = AppColors.success;
        badgeIcon = Icons.check_circle;
        badgeText = 'Validado';
        break;
      case ValidationStatus.blocked:
        badgeColor = AppColors.error;
        badgeIcon = Icons.lock;
        badgeText = 'Bloqueado';
        break;
      case ValidationStatus.modifiedAfterValidation:
        badgeColor = AppColors.warning;
        badgeIcon = Icons.edit;
        badgeText = 'Modificado';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusXs,
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: AppSpacing.iconXs,
            color: badgeColor,
          ),
          AppSpacing.horizontalSpaceXs,
          Text(
            badgeText,
            style: AppTextStyles.labelSmall.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: widget.onAddRecord,
      child: Container(
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppSpacing.radiusMd),
            bottomRight: Radius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: AppSpacing.iconMd,
              color: AppColors.primary,
            ),
            AppSpacing.horizontalSpaceSm,
            Text(
              'Añadir',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifferenceColor(int differenceMinutes) {
    if (differenceMinutes >= 120) return AppColors.success;
    if (differenceMinutes >= -60) return AppColors.textSecondary;
    return AppColors.error;
  }
}
