import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

const _enabled = bool.fromEnvironment('FIREBASE_BOOTSTRAP_DIAGNOSTIC');
const _stageLimit = Duration(seconds: 8);

// A timeout does not cancel the underlying SDK operation. Stop on the first
// failure; the external runner also bounds the process lifetime. Never retry.
Future<T> _stage<T>(String name, Future<T> Function() operation) async {
  final clock = Stopwatch()..start();
  debugPrintSynchronously('T3_BOOTSTRAP START $name');
  try {
    final result = await operation().timeout(_stageLimit);
    debugPrintSynchronously(
        'T3_BOOTSTRAP DONE $name ${clock.elapsedMilliseconds}ms');
    return result;
  } catch (error) {
    final kind = error is FirebaseException ? error.code : error.runtimeType;
    debugPrintSynchronously(
        'T3_BOOTSTRAP FAILED $name ${clock.elapsedMilliseconds}ms $kind');
    rethrow;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (!_enabled || !kIsWeb) {
    test('isolated Firebase bootstrap diagnostic', () {},
        skip: 'Requires Chrome, local emulators and explicit diagnostic opt-in.');
    return;
  }

  test('both named clients initialize, authenticate and read the emulator',
      () async {
    const options = FirebaseOptions(
      apiKey: 'emulator-only-api-key',
      appId: '1:1234567890:web:clocking-service-test',
      messagingSenderId: '1234567890',
      projectId: 'demo-clockin-dart',
    );
    for (final name in ['clocking-service-a', 'clocking-service-b']) {
      final app = await _stage('$name.initializeApp',
          () => Firebase.initializeApp(name: name, options: options));
      addTearDown(() => _stage('$name.deleteApp', app.delete));
      final auth = FirebaseAuth.instanceFor(app: app);
      final db = FirebaseFirestore.instanceFor(app: app);
      addTearDown(() => _stage('$name.terminateFirestore', db.terminate));
      db.settings = const Settings(
        host: '127.0.0.1:8080',
        sslEnabled: false,
        persistenceEnabled: false,
      );
      await _stage('$name.useAuthEmulator',
          () => auth.useAuthEmulator('127.0.0.1', 9099));
      await _stage('$name.setPersistence',
          () => auth.setPersistence(Persistence.NONE));
      addTearDown(() => _stage('$name.signOut', auth.signOut));
      final credentials = await _stage(
        '$name.signIn',
        () => auth.signInWithEmailAndPassword(
          email: 'clocking-service@example.invalid',
          password: 'Emulator-only-1234',
        ),
      );
      expect(credentials.user?.uid, 'clocking-service-owner');
      final owner = db.doc('users/clocking-service-owner');
      const server = GetOptions(source: Source.server);
      final profile = await _stage('$name.readProfile', () => owner.get(server));
      expect(profile.exists, isTrue);
      expect(profile.data()?['userId'], 'clocking-service-owner');
      expect(profile.data()?['role'], 'employee');
      expect(profile.data()?['isActive'], isTrue);
      final records = await _stage('$name.readRecords',
          () => owner.collection('time_records').get(server));
      expect(records.docs, isEmpty);
      final guard = await _stage('$name.readGuard',
          () => owner.collection('clocking_days').doc('2026-04-12').get(server));
      expect(guard.exists, isFalse);
      debugPrintSynchronously('T3_BOOTSTRAP VERIFIED $name');
    }
    debugPrintSynchronously('T3_BOOTSTRAP VERIFIED all-clients');
  }, timeout: const Timeout(Duration(seconds: 90)));
}
