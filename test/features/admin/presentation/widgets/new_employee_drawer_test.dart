import 'package:control_horario/features/admin/presentation/widgets/new_employee_drawer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatTemporaryCredentialsForClipboard', () {
    test('formats email and temporary password for clipboard', () {
      final credentials = formatTemporaryCredentialsForClipboard(
        email: 'employee@example.com',
        temporaryPassword: 'Temp-1234',
      );

      expect(
        credentials,
        'Email: employee@example.com\nContraseña temporal: Temp-1234',
      );
    });
  });
}
