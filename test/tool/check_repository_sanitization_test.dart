import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_repository_sanitization.dart' as scanner;

void main() {
  group('repository sanitization scanner', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('sanitization-scanner-');
    });

    tearDown(() {
      root.deleteSync(recursive: true);
    });

    test('reports credential, PII, and live-claim findings deterministically',
        () {
      final file = File('${root.path}/mock_data.dart')..writeAsStringSync('''
key=AIzaSyB1uJzL_n5kASiR6fDbxysOYhGvWF4Cf_Y
home=/home/alice/project
email=person@escuela.com
status=This MVP is live in production
''');

      final findings = scanner.scanTextFiles(root, ['mock_data.dart']);

      expect(
        findings.map((finding) => finding.toString()),
        [
          'mock_data.dart:1:firebase-api-key',
          'mock_data.dart:2:user-machine-path',
          'mock_data.dart:3:school-specific-data',
          'mock_data.dart:4:live-production-claim',
        ],
      );
    });

    test('allows safe fixtures and generic technical discussion', () {
      final file = File('${root.path}/safe.txt')..writeAsStringSync('''
user@example.com
https://test.com/path
projectId: demo-control-horario
final value = String.fromEnvironment('FIREBASE_API_KEY');
password: password
Production deployments should use least privilege.
''');

      expect(scanner.scanTextFiles(root, ['safe.txt']), isEmpty);
    });

    test('honors exclude prefixes and sorts file paths', () {
      File('${root.path}/z.txt').writeAsStringSync('admin123');
      File('${root.path}/docs/a.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('empleado123');

      final findings = scanner.scanTextFiles(
        root,
        ['z.txt', 'docs/a.txt'],
        excludePrefixes: ['docs/'],
      );

      expect(
        findings.map((finding) => finding.toString()),
        ['z.txt:1:weak-documented-credential'],
      );
    });

    test('excludes an exact path without excluding its sibling', () {
      File('${root.path}/docs/pending.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('admin123');
      File('${root.path}/docs/quickstart.txt').writeAsStringSync('rrhh123');

      final findings = scanner.scanTextFiles(
        root,
        ['docs/pending.txt', 'docs/quickstart.txt'],
        excludePaths: ['docs/pending.txt'],
      );

      expect(
        findings.map((finding) => finding.toString()),
        ['docs/quickstart.txt:1:weak-documented-credential'],
      );
    });
  });
}
