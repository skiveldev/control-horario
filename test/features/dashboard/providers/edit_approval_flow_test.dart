import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/providers/time_records_provider.dart';
import 'package:control_horario/features/dashboard/services/time_records_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper: build a validated work record
TimeRecordModel _validatedRecord({
  String id = 'rec-1',
  String date = '2026-05-19',
  String startTime = '09:00',
  String endTime = '18:00',
  int durationMinutes = 480,
}) {
  return TimeRecordModel(
    id: id,
    userId: 'user-1',
    date: date,
    category: RecordCategory.work,
    startTime: startTime,
    endTime: endTime,
    location: 'office',
    durationMinutes: durationMinutes,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
    createdBy: 'user-1',
    isManual: false,
    recordStatus: RecordStatus.completed,
    validationStatus: ValidationStatus.validated,
    validatedBy: 'supervisor-1',
    validatedAt: DateTime(2026, 5, 1),
  );
}

void main() {
  group('Edit-Approval Flow', () {
    late _FakeTimeRecordsService fakeService;
    late ProviderContainer container;

    setUp(() {
      fakeService = _FakeTimeRecordsService();
      container = ProviderContainer(
        overrides: [
          timeRecordsServiceProvider.overrideWith((ref) => fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('updateRecord with validated status', () {
      test('transitions validated record to modifiedAfterValidation on edit',
          () async {
        final record = _validatedRecord();

        await container
            .read(timeRecordsNotifierProvider.notifier)
            .updateRecord(record);

        expect(fakeService.updatedRecords.length, 1);
        final updated = fakeService.updatedRecords.first;
        expect(
          updated.validationStatus,
          ValidationStatus.modifiedAfterValidation,
        );
      });

      test('does NOT transition editable records on edit', () async {
        final record = _validatedRecord().copyWith(
          validationStatus: ValidationStatus.editable,
        );

        await container
            .read(timeRecordsNotifierProvider.notifier)
            .updateRecord(record);

        expect(fakeService.updatedRecords.length, 1);
        final updated = fakeService.updatedRecords.first;
        expect(
          updated.validationStatus,
          ValidationStatus.editable,
        );
      });

      test('does NOT double-transition already modified records', () async {
        final record = _validatedRecord().copyWith(
          validationStatus: ValidationStatus.modifiedAfterValidation,
        );

        await container
            .read(timeRecordsNotifierProvider.notifier)
            .updateRecord(record);

        expect(fakeService.updatedRecords.length, 1);
        final updated = fakeService.updatedRecords.first;
        expect(
          updated.validationStatus,
          ValidationStatus.modifiedAfterValidation,
        );
      });

      test('preserves other record fields after transition', () async {
        final record = _validatedRecord(
          id: 'rec-42',
          date: '2026-05-20',
          startTime: '08:00',
          endTime: '16:00',
          durationMinutes: 420,
        );

        await container
            .read(timeRecordsNotifierProvider.notifier)
            .updateRecord(record);

        final updated = fakeService.updatedRecords.first;
        expect(updated.id, 'rec-42');
        expect(updated.date, '2026-05-20');
        expect(updated.startTime, '08:00');
        expect(updated.endTime, '16:00');
        expect(updated.durationMinutes, 420);
        expect(updated.userId, 'user-1');
      });

      test('does NOT transition blocked records (they cannot be edited)',
          () async {
        final record = _validatedRecord().copyWith(
          validationStatus: ValidationStatus.blocked,
        );

        await container
            .read(timeRecordsNotifierProvider.notifier)
            .updateRecord(record);

        // Blocked records are still passed to the service
        // The UI layer should prevent editing blocked records;
        // here we just verify the provider doesn't change the status
        expect(fakeService.updatedRecords.length, 1);
        final updated = fakeService.updatedRecords.first;
        // blocked records: isValidated = false, so they pass through unchanged
        expect(updated.validationStatus, ValidationStatus.blocked);
      });
    });
  });
}

/// Fake TimeRecordsService for unit testing updateRecord
class _FakeTimeRecordsService extends TimeRecordsService {
  _FakeTimeRecordsService() : super.test();

  final List<TimeRecordModel> updatedRecords = [];

  @override
  Future<void> updateRecord(TimeRecordModel record) async {
    updatedRecords.add(record);
  }
}
