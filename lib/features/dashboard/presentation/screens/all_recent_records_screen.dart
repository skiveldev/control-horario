import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/navigation/mobile_drawer.dart';
import '../../../../shared/widgets/navigation/responsive_navigation.dart';
import '../../models/time_record_model.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/records_table.dart';

class AllRecentRecordsScreen extends ConsumerWidget {
  const AllRecentRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = context.isMobile || context.isTablet;
    final colors = AppColorsHelper.of(context);

    final last30DaysAsync = ref.watch(last30DaysRecordsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isMobile ? const MobileDrawer() : null,
      body: ResponsiveNavigation(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile)
              Builder(
                builder: (scaffoldContext) => _buildMobileHeader(
                  scaffoldContext,
                  colors,
                ),
              )
            else
              _buildDesktopHeader(context, colors),
            Expanded(
              child: last30DaysAsync.when(
                data: (records) => _buildContent(context, records, colors),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    'Error al cargar registros: $error',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader(
    BuildContext scaffoldContext,
    AppColorsHelper colors,
  ) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: Theme.of(scaffoldContext).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(scaffoldContext).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(scaffoldContext).openDrawer();
            },
            tooltip: 'Abrir menú',
          ),
          AppSpacing.horizontalSpaceMd,
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => scaffoldContext.pop(),
            tooltip: 'Volver',
          ),
          AppSpacing.horizontalSpaceMd,
          Flexible(
            child: Text(
              'Últimos 30 días',
              style: Theme.of(scaffoldContext).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, AppColorsHelper colors) {
    return Container(
      padding: AppSpacing.allXl,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Volver',
          ),
          AppSpacing.horizontalSpaceMd,
          Icon(Icons.history, size: AppSpacing.iconMd, color: colors.secondary),
          AppSpacing.horizontalSpaceSm,
          Text(
            'Últimos 30 días',
            style: AppTextStyles.h4.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<TimeRecordModel> records,
    AppColorsHelper colors,
  ) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 64, color: colors.textTertiary),
            AppSpacing.verticalSpaceMd,
            Text(
              'No hay registros en los últimos 30 días',
              style: AppTextStyles.bodyLarge.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final groupedByDate = <String, List<TimeRecordModel>>{};
    for (final record in records) {
      groupedByDate.putIfAbsent(record.date, () => []).add(record);
    }

    final mappedRecords = groupedByDate.entries.map((entry) {
      final date = entry.key;
      final dayRecords = entry.value;

      final workRecords =
          dayRecords.where((r) => r.category == RecordCategory.work).toList();
      final breakRecords = dayRecords
          .where((r) => r.category == RecordCategory.breakTime)
          .toList();

      final entrance =
          workRecords.isNotEmpty ? workRecords.first.startTime : '--:--';
      final exit = workRecords.isNotEmpty ? workRecords.last.endTime : '--:--';

      final totalMinutes = workRecords.fold<int>(
        0,
        (sum, r) => sum + r.durationMinutes,
      );

      final hadBreak = breakRecords.isNotEmpty;

      return {
        'date': _formatDate(date),
        'entrance': entrance,
        'exit': exit,
        'total': _formatDuration(totalMinutes),
        'hadBreak': hadBreak,
        'status': 'complete',
      };
    }).toList();

    return ListView.separated(
      padding: EdgeInsets.all(
        context.isMobile ? AppSpacing.lg : AppSpacing.xxl,
      ),
      itemCount: mappedRecords.length,
      separatorBuilder: (_, __) => AppSpacing.verticalSpaceMd,
      itemBuilder: (context, index) {
        final record = mappedRecords[index];
        final date = record['date'] as String;

        return CustomCard(
          elevation: CardElevation.medium,
          padding: AppSpacing.cardLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  date,
                  style: AppTextStyles.h6.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              RecordsTable(
                records: [record],
                onRecordTap: (_) {},
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDuration(int minutes) {
    if (minutes == 0) return '--:--';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}min';
  }
}
