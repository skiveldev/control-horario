import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/navigation/mobile_drawer.dart';
import '../../../../shared/widgets/navigation/responsive_navigation.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/time_record_model.dart';
import '../helpers/team_validation_feedback.dart';
import '../../providers/team_month_closure_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/time_records_provider.dart';
import '../widgets/team_member_month_card.dart';
import '../widgets/team_month_summary_card.dart';
import '../widgets/team_pending_breakdown_card.dart';
import '../widgets/team_screen_header.dart';

/// Pantalla de equipo para supervisores.
///
/// Se monta dentro del mismo panel de empleado y muestra miembros asignados.
class TeamScreen extends ConsumerStatefulWidget {
  const TeamScreen({super.key});

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  late DateTime _selectedMonth;
  final Set<String> _validatingRecordKeys = <String>{};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < Breakpoints.desktop;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!currentUser.canSuperviseTeam) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: AppSpacing.allXl,
            child: const Text(
              'No tienes permisos para ver el modulo de equipo.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final teamMembersAsync = ref.watch(supervisedTeamMembersProvider);
    final monthClosureAsync =
        ref.watch(teamMonthClosureProvider(_selectedMonth));
    final monthlyOverviewAsync =
        ref.watch(teamMonthlyOverviewProvider(_selectedMonth));

    return Scaffold(
      drawer: isMobile ? const MobileDrawer() : null,
      body: ResponsiveNavigation(
        child: Column(
          children: [
            TeamScreenHeader(
              isMobile: isMobile,
              selectedMonth: _selectedMonth,
              isClosed: monthClosureAsync.valueOrNull?.isClosed ?? false,
              pendingCount:
                  monthlyOverviewAsync.valueOrNull?.pendingRecords ?? 0,
              onCloseMonth: () => _handleCloseMonth(
                monthlyOverviewAsync.valueOrNull,
              ),
              onPreviousMonth: _goToPreviousMonth,
              onNextMonth: _goToNextMonth,
            ),
            Expanded(
              child: teamMembersAsync.when(
                data: (members) {
                  if (members.isEmpty) {
                    return const Center(
                      child:
                          Text('No tienes empleados asignados en tu equipo.'),
                    );
                  }

                  return monthlyOverviewAsync.when(
                    data: (overview) => ListView(
                      padding: AppSpacing.allXl,
                      children: [
                        TeamMonthSummaryCard(
                          overview: overview,
                          isClosed:
                              monthClosureAsync.valueOrNull?.isClosed ?? false,
                        ),
                        if (overview.pendingBreakdown.isNotEmpty) ...[
                          AppSpacing.verticalSpaceLg,
                          TeamPendingBreakdownCard(
                            items: overview.pendingBreakdown,
                          ),
                        ],
                        AppSpacing.verticalSpaceLg,
                        ...overview.memberSummaries.map((summary) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TeamMemberMonthCard(
                              summary: summary,
                              isMonthClosed:
                                  monthClosureAsync.valueOrNull?.isClosed ??
                                      false,
                              validatingRecordKeys: _validatingRecordKeys,
                              onValidateRecord: (record) =>
                                  _handleValidateRecord(summary.member, record),
                            ),
                          );
                        }),
                      ],
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text('Error al cargar resumen mensual: $error'),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Error al cargar equipo: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  Future<void> _handleValidateRecord(
    UserModel member,
    TimeRecordModel record,
  ) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final recordKey = '${member.userId}::${record.id}';

    setState(() {
      _validatingRecordKeys.add(recordKey);
    });

    try {
      await ref.read(timeRecordsNotifierProvider.notifier).validateRecord(
            member.userId,
            record.id,
            currentUser.userId,
          );

      ref.invalidate(teamMonthlyOverviewProvider(_selectedMonth));
      ref.invalidate(teamMonthlySummaryProvider(_selectedMonth));
      ref.invalidate(teamMonthClosureProvider(_selectedMonth));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(buildTeamValidationSuccessMessage(
            memberName: member.fullName,
            record: record,
          )),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(buildTeamValidationFeedbackMessage(error)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _validatingRecordKeys.remove(recordKey);
        });
      }
    }
  }

  Future<void> _handleCloseMonth(TeamMonthlyOverview? overview) async {
    if (overview == null) return;

    if (overview.pendingBreakdown.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No se puede cerrar el mes'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Antes de cerrar el mes debes validar todos los registros pendientes.',
                ),
                AppSpacing.verticalSpaceMd,
                ...overview.pendingBreakdown.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.member.fullName)),
                        Text('${item.pendingRecords} pendiente(s)'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar mes del equipo'),
        content: const Text(
          'Esta acción cerrará el mes seleccionado si no existen pendientes. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar mes'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(teamMonthClosureControllerProvider)
          .closeMonth(_selectedMonth);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mes cerrado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cerrar el mes: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
