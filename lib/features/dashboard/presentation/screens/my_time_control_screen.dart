import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/navigation/mobile_drawer.dart';
import '../../../../shared/widgets/navigation/responsive_navigation.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/time_records_provider.dart';
import '../widgets/month_navigation_header.dart';
import '../widgets/day_record_card.dart';
import '../widgets/future_month_empty_state.dart';
import '../widgets/add_edit_record_modal.dart';
import '../widgets/blocked_record_modal.dart';
import '../../models/time_record_model.dart';
import '../../services/compliance_service.dart';
import '../../../admin/presentation/widgets/compliance_badge.dart';

/// Pantalla Mi Control Horario
///
/// Muestra vista mensual completa de registros de jornada laboral
/// con gestión avanzada (añadir, editar, copiar, eliminar).
///
/// Features:
/// - Navegación entre meses
/// - Control de mes futuro (empty state especial)
/// - Vista colapsable/expandible por día
/// - Sin restricciones de edición (solo registros bloqueados)
class MyTimeControlScreen extends ConsumerStatefulWidget {
  const MyTimeControlScreen({super.key});

  @override
  ConsumerState<MyTimeControlScreen> createState() =>
      _MyTimeControlScreenState();
}

class _MyTimeControlScreenState extends ConsumerState<MyTimeControlScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile || context.isTablet;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: isMobile ? const MobileDrawer() : null,
      body: ResponsiveNavigation(
        child: Column(
          children: [
            // Header con hamburger en mobile
            // IMPORTANTE: Usar Builder para obtener el contexto correcto del Scaffold
            if (isMobile)
              Builder(
                builder: (scaffoldContext) =>
                    _buildMobileHeader(scaffoldContext),
              ),

            // Contenido principal
            Expanded(
              child: _isFutureMonth(_selectedMonth)
                  ? _buildFutureMonthView()
                  : _buildNormalMonthView(),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el header mobile con botón hamburguesa
  ///
  /// IMPORTANTE: El parámetro scaffoldContext viene del Builder
  /// y tiene acceso al Scaffold para poder abrir el drawer
  Widget _buildMobileHeader(BuildContext scaffoldContext) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              debugPrint('🔴 DRAWER (Mi Control): Abriendo drawer...');
              Scaffold.of(scaffoldContext).openDrawer();
            },
            tooltip: 'Abrir menú',
          ),
          AppSpacing.horizontalSpaceMd,
          Flexible(
            child: Text(
              'Mi Control Horario',
              style: Theme.of(scaffoldContext).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureMonthView() {
    return Column(
      children: [
        MonthNavigationHeader(
          selectedMonth: _selectedMonth,
          onPreviousMonth: _goToPreviousMonth,
          onNextMonth: null, // Deshabilitado en mes futuro
        ),
        Expanded(
          child: FutureMonthEmptyState(
            month: _selectedMonth,
            onGoToCurrentMonth: () {
              setState(() {
                _selectedMonth = DateTime.now();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNormalMonthView() {
    // Obtener usuario actual
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(
            child: Text('Usuario no autenticado'),
          );
        }

        // Observar registros del mes
        final recordsAsync = ref.watch(
          monthTimeRecordsProvider(
            userId: user.userId,
            month: _selectedMonth,
          ),
        );

        return recordsAsync.when(
          data: (records) => _buildMonthContent(user.userId, records),
          loading: () => Column(
            children: [
              MonthNavigationHeader(
                selectedMonth: _selectedMonth,
                onPreviousMonth: _goToPreviousMonth,
                onNextMonth: _canNavigateToNextMonth() ? _goToNextMonth : null,
              ),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (error, stack) => Column(
            children: [
              MonthNavigationHeader(
                selectedMonth: _selectedMonth,
                onPreviousMonth: _goToPreviousMonth,
                onNextMonth: _canNavigateToNextMonth() ? _goToNextMonth : null,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      AppSpacing.verticalSpaceMd,
                      Text(
                        'Error al cargar registros',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      AppSpacing.verticalSpaceSm,
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildMonthContent(String userId, List<TimeRecordModel> records) {
    final daysInMonth = _getDaysInMonth(_selectedMonth);

    // Calcular totales del mes
    final totalWorkedMinutes = records.fold<int>(
      0,
      (sum, record) => sum + record.durationMinutes,
    );
    const totalPlannedMinutes = 8 * 60 * 22; // 8h/día * 22 días laborables

    return Column(
      children: [
        // Header con navegación y resumen
        MonthNavigationHeader(
          selectedMonth: _selectedMonth,
          onPreviousMonth: _goToPreviousMonth,
          onNextMonth: _canNavigateToNextMonth() ? _goToNextMonth : null,
          totalWorkedMinutes: totalWorkedMinutes,
          totalPlannedMinutes: totalPlannedMinutes,
        ),

        // Lista de días
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(
              context.isMobile ? AppSpacing.lg : AppSpacing.xxl,
            ),
            itemCount: daysInMonth.length,
            itemBuilder: (context, index) {
              final day = daysInMonth[index];
              final dayRecords =
                  records.where((r) => r.date == _formatDate(day)).toList();
              final isToday = _isToday(day);

              return DayRecordCard(
                date: day,
                records: dayRecords,
                plannedMinutes: 8 * 60, // 8h planificadas
                isToday: isToday,
                complianceStatus: _computeDayCompliance(day, dayRecords),
                onAddRecord: () =>
                    _handleAddRecord(context, day, userId, dayRecords),
                onEditRecord: (record) =>
                    _handleEditRecord(context, record, userId, dayRecords),
                onCopyRecord: (record) =>
                    _handleCopyRecord(context, record, userId),
                onDeleteRecord: (record) =>
                    _handleDeleteRecord(context, record, userId),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleAddRecord(
    BuildContext context,
    DateTime date,
    String userId,
    List<TimeRecordModel> existingRecords,
  ) {
    AddEditRecordModal.show(
      context,
      date: date,
      existingRecords: existingRecords, // ✅ Para validar solapamiento
      availableLocations: const [
        'Oficina',
        'Delegación Madrid',
        'Remoto',
        'Cliente',
      ],
      onSave: (record) async {
        // Añadir userId al registro
        final recordWithUserId = record.copyWith(
          userId: userId,
          createdBy: userId,
        );

        await ref.read(timeRecordsNotifierProvider.notifier).addRecord(
              recordWithUserId,
            );
      },
    );
  }

  void _handleEditRecord(
    BuildContext context,
    TimeRecordModel record,
    String userId,
    List<TimeRecordModel> existingRecords,
  ) {
    // Verificar si está bloqueado
    if (record.isBlocked) {
      BlockedRecordModal.show(
        context,
        record: record,
        blockedByName: 'Administrador', // TODO: Get real name
      );
      return;
    }

    // Mostrar modal de edición
    final date = DateTime.parse(record.date);
    AddEditRecordModal.show(
      context,
      date: date,
      recordToEdit: record,
      existingRecords: existingRecords, // ✅ Para validar solapamiento
      availableLocations: const [
        'Oficina',
        'Delegación Madrid',
        'Remoto',
        'Cliente',
      ],
      onSave: (updatedRecord) async {
        await ref.read(timeRecordsNotifierProvider.notifier).updateRecord(
              updatedRecord,
            );
      },
    );
  }

  void _handleCopyRecord(
    BuildContext context,
    TimeRecordModel record,
    String userId,
  ) {
    // Mostrar date picker para seleccionar día destino
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'ES'),
    ).then((selectedDate) async {
      if (selectedDate == null) return;

      try {
        await ref
            .read(timeRecordsNotifierProvider.notifier)
            .copyRecord(userId, record.id, selectedDate);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✓ Registro copiado a ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al copiar: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  void _handleDeleteRecord(
    BuildContext context,
    TimeRecordModel record,
    String userId,
  ) {
    final outerContext = context;
    // Mostrar confirmación
    showDialog(
      context: outerContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${record.categoryName} • ${record.startTime}-${record.endTime}'),
            AppSpacing.verticalSpaceXs,
            Text(record.location),
            AppSpacing.verticalSpaceMd,
            const Text(
              'Esta acción no se puede deshacer.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                if (!outerContext.mounted) return;

                await ref
                    .read(timeRecordsNotifierProvider.notifier)
                    .deleteRecord(userId, record.id);

                if (!outerContext.mounted) return;

                ScaffoldMessenger.of(outerContext).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Registro eliminado'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!outerContext.mounted) return;

                ScaffoldMessenger.of(outerContext).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  bool _isFutureMonth(DateTime month) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final selectedMonthStart = DateTime(month.year, month.month, 1);

    return selectedMonthStart.isAfter(currentMonthStart);
  }

  bool _canNavigateToNextMonth() {
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    return !_isFutureMonth(nextMonth);
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    if (_canNavigateToNextMonth()) {
      setState(() {
        _selectedMonth =
            DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      });
    }
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    return List.generate(
      lastDay.day,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calcula el cumplimiento simple para un día basado en los registros.
  ///
  /// - Si no hay registros de trabajo en día laborable → noRecord
  /// - Si hay registros → compliant
  /// - Fin de semana → noRecord
  ComplianceStatus _computeDayCompliance(
    DateTime day,
    List<TimeRecordModel> records,
  ) {
    // Fin de semana: no se esperan registros
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return ComplianceStatus.noRecord;
    }

    final hasWorkRecords =
        records.any((r) => r.category == RecordCategory.work);
    if (!hasWorkRecords) {
      return ComplianceStatus.noRecord;
    }

    return ComplianceStatus.compliant;
  }
}
