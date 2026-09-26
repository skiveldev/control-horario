import 'shared/seed_user_definitions.dart';

/// Lists safe demo definitions without provisioning users.
void main() {
  print('DEMO USER DEFINITIONS\n');
  for (final u in getSeedUserDefinitions()) {
    print(
        '  ${u['displayName']} | ${u['email']} | ${u['role']} | ${u['employeeId']} | ${u['weeklyHours']}h');
  }
  print(
      '\nClient demo seeding is retired. Use trusted provisioning to create users.');
}
