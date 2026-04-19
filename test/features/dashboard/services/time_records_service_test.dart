import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/services/time_records_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildValidationAuditUpdate', () {
    test('incluye validatedAt y el estado validated para auditoría', () {
      final validatedAt = Timestamp.fromDate(DateTime.utc(2026, 4, 11, 12));
      final updatedAt = Timestamp.fromDate(DateTime.utc(2026, 4, 11, 12, 5));

      final payload = buildValidationAuditUpdate(
        validatedBy: 'supervisor-1',
        validatedAt: validatedAt,
        updatedAt: updatedAt,
      );

      expect(payload['validationStatus'], ValidationStatus.validated.name);
      expect(payload['validatedBy'], 'supervisor-1');
      expect(payload['validatedAt'], same(validatedAt));
      expect(payload['updatedAt'], same(updatedAt));
    });

    test('permite auditar validaciones hechas por admin', () {
      final validatedAt = Timestamp.fromDate(DateTime.utc(2026, 4, 15, 9, 30));

      final payload = buildValidationAuditUpdate(
        validatedBy: 'admin-1',
        validatedAt: validatedAt,
        updatedAt: validatedAt,
      );

      expect(payload['validationStatus'], ValidationStatus.validated.name);
      expect(payload['validatedBy'], 'admin-1');
      expect(payload['validatedAt'], same(validatedAt));
    });
  });
}
