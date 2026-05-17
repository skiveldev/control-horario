import 'package:control_horario/features/dashboard/providers/vacation_marker_provider.dart';
import 'package:control_horario/features/dashboard/services/vacation_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VacationMarkerProvider', () {
    late _FakeVacationService fakeService;
    late ProviderContainer container;

    setUp(() {
      fakeService = _FakeVacationService();
      container = ProviderContainer(
        overrides: [
          vacationServiceProvider.overrideWith((ref) => fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('addVacation', () {
      test('adds a vacation marker for an employee on a specific date',
          () async {
        await container
            .read(vacationMarkerNotifierProvider.notifier)
            .addVacation(
              employeeId: 'user-1',
              date: '2026-06-15',
              markedBy: 'supervisor-1',
            );

        expect(fakeService.vacations.length, 1);
        expect(fakeService.vacations.first.employeeId, 'user-1');
        expect(fakeService.vacations.first.date, '2026-06-15');
        expect(fakeService.vacations.first.markedBy, 'supervisor-1');
      });

      test('adds multiple vacation days for the same employee', () async {
        final notifier =
            container.read(vacationMarkerNotifierProvider.notifier);

        await notifier.addVacation(
          employeeId: 'user-1',
          date: '2026-06-15',
          markedBy: 'supervisor-1',
        );
        await notifier.addVacation(
          employeeId: 'user-1',
          date: '2026-06-16',
          markedBy: 'supervisor-1',
        );
        await notifier.addVacation(
          employeeId: 'user-1',
          date: '2026-06-17',
          markedBy: 'supervisor-1',
        );

        expect(fakeService.vacations.length, 3);
      });
    });

    group('removeVacation', () {
      test('removes a vacation marker for a specific date', () async {
        final notifier =
            container.read(vacationMarkerNotifierProvider.notifier);

        await notifier.addVacation(
          employeeId: 'user-1',
          date: '2026-06-15',
          markedBy: 'supervisor-1',
        );
        await notifier.addVacation(
          employeeId: 'user-1',
          date: '2026-06-16',
          markedBy: 'supervisor-1',
        );

        await notifier.removeVacation(
          employeeId: 'user-1',
          date: '2026-06-15',
        );

        expect(fakeService.vacations.length, 1);
        expect(fakeService.vacations.first.date, '2026-06-16');
      });

      test('does nothing when removing a non-existent vacation marker',
          () async {
        final notifier =
            container.read(vacationMarkerNotifierProvider.notifier);

        // Should not throw
        await notifier.removeVacation(
          employeeId: 'user-1',
          date: '2026-06-15',
        );

        expect(fakeService.vacations, isEmpty);
      });
    });

    group('getVacationDates', () {
      test('returns vacation dates for an employee in a month', () async {
        final notifier =
            container.read(vacationMarkerNotifierProvider.notifier);

        await notifier.addVacation(
          employeeId: 'user-1',
          date: '2026-06-15',
          markedBy: 'supervisor-1',
        );
        await notifier.addVacation(
          employeeId: 'user-1',
          date: '2026-06-20',
          markedBy: 'supervisor-1',
        );
        // Other employee
        await notifier.addVacation(
          employeeId: 'user-2',
          date: '2026-06-10',
          markedBy: 'supervisor-1',
        );

        final dates =
            await fakeService.getVacationDates('user-1', DateTime(2026, 6));
        expect(dates, {'2026-06-15', '2026-06-20'});
      });
    });
  });
}

/// Fake VacationService for unit testing
class _FakeVacationService extends VacationService {
  _FakeVacationService() : super.test();

  final List<_VacationEntry> vacations = [];

  @override
  Future<void> addVacation({
    required String employeeId,
    required String date,
    required String markedBy,
  }) async {
    // Don't add duplicates
    if (!vacations.any((v) => v.employeeId == employeeId && v.date == date)) {
      vacations.add(_VacationEntry(
        employeeId: employeeId,
        date: date,
        markedBy: markedBy,
      ));
    }
  }

  @override
  Future<void> removeVacation({
    required String employeeId,
    required String date,
  }) async {
    vacations.removeWhere(
      (v) => v.employeeId == employeeId && v.date == date,
    );
  }

  @override
  Future<Set<String>> getVacationDates(
    String employeeId,
    DateTime month,
  ) async {
    final prefix = '${month.year}-${month.month.toString().padLeft(2, '0')}';
    return vacations
        .where((v) => v.employeeId == employeeId && v.date.startsWith(prefix))
        .map((v) => v.date)
        .toSet();
  }
}

class _VacationEntry {
  final String employeeId;
  final String date;
  final String markedBy;

  const _VacationEntry({
    required this.employeeId,
    required this.date,
    required this.markedBy,
  });
}
