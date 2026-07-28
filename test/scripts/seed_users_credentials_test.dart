/// WU2 seed credential purge integration test.
/// Usage: dart run test/scripts/seed_users_credentials_test.dart
// ignore_for_file: avoid_print
library;

import '../../scripts/shared/seed_user_definitions.dart';
import '../../scripts/shared/seed_credentials.dart';

int _f = 0, _p = 0;
void _a(bool c, String m) {
  if (c) {
    _p++;
  } else {
    print('  FAIL: $m');
    _f++;
  }
}

void main() {
  print('=== WU2 seed credential purge ===\n');
  print('-- 2.1: Data definitions --');
  final users = getSeedUserDefinitions();
  _a(users.length == 5, '5 demo users');
  for (final u in users) {
    _a(!u.containsKey('password'), '${u['email']}: no password');
    _a((u['email'] as String).endsWith('@example.com'),
        '${u['email']}: @example.com');
    _a((u['displayName'] as String).toLowerCase().contains('demo'),
        '${u['displayName']}: demo name');
    final k = u['passwordEnvKey'] as String;
    _a(
        k.startsWith('SEED_') &&
            k.endsWith('_PASSWORD') &&
            ['admin', 'rrhh', 'employee'].contains(u['role']),
        '$k / ${u['role']}: format + role');
  }

  print('\n-- 2.2: Password resolution --');
  _a(resolveSeedPassword('K', env: {'K': 'p'}) == 'p', 'resolves');
  _a(resolveSeedPassword('K1', env: {'K1': 'a', 'K2': 'b'}) == 'a',
      'correct key');
  _a(resolveSeedPassword('S', env: {'S': r'p@$$!'}) == r'p@$$!',
      'special chars');

  try {
    resolveSeedPassword('M', env: {});
    _a(false, 'throw on missing');
  } on SeedCredentialError catch (e) {
    _a(e.message.contains('M') && e.message.contains('not set'),
        'missing message');
  }

  try {
    resolveSeedPassword('E', env: {'E': ''});
    _a(false, 'throw on empty');
  } on SeedCredentialError catch (e) {
    _a(e.message.contains('E') && e.message.contains('empty'), 'empty message');
  }

  print('\n=== RESULTS: $_p passed, $_f failed ===');
  if (_f > 0) throw Exception('$_f failures');
}
