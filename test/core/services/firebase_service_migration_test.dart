import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _token(String first, String second) => '$first$second';

void main() {
  final firebaseService = File('lib/core/services/firebase_service.dart');
  final drawer = File(
    'lib/features/admin/presentation/widgets/new_employee_drawer.dart',
  );
  final userManagement = File(
    'lib/features/admin/providers/user_management_provider.dart',
  );

  test('retired direct employee-creation structure is absent', () {
    final migratedCreationSources = [
      firebaseService.readAsStringSync(),
      drawer.readAsStringSync(),
    ];
    final forbiddenTokens = [
      _token('EmployeeCreation', 'Service'),
      _token('employeeCreationService', 'Provider'),
      _token('_generateTemporary', 'Password'),
      _token('buildEmployeeDocument', 'Data'),
      _token('Firebase.', 'initializeApp'),
      _token('FirebaseAuth.', 'instanceFor'),
      _token('createUserWithEmail', 'AndPassword'),
      _token("collection('users').doc(userId).", 'set('),
      _token('userCredential.user!.', 'delete('),
      _token('temporary', 'Password'),
      _token('_buildEmployee', 'Data'),
      _token('_generateEmployee', 'Id'),
      _token('COMENTADO ', 'Sprint 1.3'),
    ];

    for (final source in migratedCreationSources) {
      for (final forbiddenToken in forbiddenTokens) {
        expect(source, isNot(contains(forbiddenToken)));
      }
    }
  });

  test('existing employee updates retain their direct update path', () {
    final source = userManagement.readAsStringSync();

    expect(source, contains(_token('update', 'Employee')));
    expect(
      source,
      contains(_token("collection('users').doc(userId).", 'update(updates)')),
    );
  });
}
