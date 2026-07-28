import 'shared/seed_user_definitions.dart';

/// Lists demo users and required env vars. No passwords printed.
void main() {
  print('DEMO USER DEFINITIONS\n');
  for (final u in getSeedUserDefinitions()) {
    print(
        '  ${u['displayName']} | ${u['email']} | ${u['role']} | ${u['employeeId']} | ${u['weeklyHours']}h');
  }
  print('\nREQUIRED ENV VARS:');
  for (final u in getSeedUserDefinitions()) {
    print('  ${u['passwordEnvKey']}=<password>');
  }
  print('\nSet them, then: dart run scripts/seed_users.dart');
}
