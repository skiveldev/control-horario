import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'shared/seed_user_definitions.dart';
import 'shared/seed_credentials.dart';

/// Populates Firebase with demo users. Passwords from env vars only.
///
/// Usage: set SEED_*_PASSWORD vars, then `dart run scripts/seed_users.dart`.
void main() async {
  // Resolve passwords before touching Firebase (fail-closed).
  final defs = getSeedUserDefinitions();
  final resolved = <Map<String, Object>>[];
  try {
    for (final d in defs) {
      resolved.add({
        ...d,
        'password': resolveSeedPassword(d['passwordEnvKey'] as String)
      });
    }
  } on SeedCredentialError catch (e) {
    print('Error: $e\nSet all SEED_*_PASSWORD env vars and retry.');
    return;
  }

  print('Starting demo user seeding...\n');
  try {
    await Firebase.initializeApp();
    print('Firebase initialized\n');
  } catch (e) {
    print(
        'Error initializing Firebase: $e\nRun "flutterfire configure" first.\n');
    return;
  }

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  var created = 0, errors = 0;

  for (final u in resolved) {
    try {
      print('Creating user: ${u['email']}...');
      final uc = await auth.createUserWithEmailAndPassword(
        email: u['email'] as String,
        password: u['password'] as String,
      );
      await firestore.collection('users').doc(uc.user!.uid).set({
        'userId': uc.user!.uid,
        'employeeId': u['employeeId'],
        'email': u['email'],
        'displayName': u['displayName'],
        'role': u['role'],
        'weeklyHours': u['weeklyHours'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('   Created — ${u['email']} (${u['role']})\n');
      created++;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('   ${u['email']} already exists (skipping)\n');
      } else {
        print('   Error: ${e.message}\n');
        errors++;
      }
    } catch (e) {
      print('   Unexpected error: $e\n');
      errors++;
    }
  }

  print('=' * 40);
  print('Seeding complete! Created: $created  Errors: $errors');
  print('=' * 40);
  print('\nDemo users:');
  for (final u in resolved) {
    print('   ${u['email']} (${u['role']})');
  }
  print('');
}
