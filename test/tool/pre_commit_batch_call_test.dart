/// RED/GREEN harness for `.githooks/pre-commit.bat` batch `call` semantics.
///
/// On this machine `dart` resolves to `dart.bat`; batch-to-batch calls
/// WITHOUT `call` transfer control and never return, silently skipping
/// the analyzer step.  This suite uses mock shims to prove the fix.
///
/// Usage:  dart run test/tool/pre_commit_batch_call_test.dart
library;

import 'dart:io';

final _hookPath =
    '${Directory.current.path}${Platform.pathSeparator}.githooks${Platform.pathSeparator}pre-commit.bat';

int _failures = 0;
int _passed = 0;

void _assert(bool condition, String msg) {
  if (condition) {
    _passed++;
  } else {
    stderr.writeln('  FAIL: $msg');
    _failures++;
  }
}

/// Creates a temp dir with mock `dart.bat` (exit [de]) and `flutter.bat`
/// (exit [fe], optionally creates a marker file).
Future<({Directory tmp, Directory bin})> _setup(int de, int fe,
    {bool marker = true}) async {
  final tmp = await Directory.systemTemp.createTemp('bht_');
  final bin = Directory('${tmp.path}${Platform.pathSeparator}bin');
  await bin.create();
  final mp = '${tmp.path}${Platform.pathSeparator}flutter_reached.txt';
  await File('${bin.path}${Platform.pathSeparator}dart.bat').writeAsString(
    '@echo off\r\necho OK\r\nexit /b $de\r\n',
  );
  await File('${bin.path}${Platform.pathSeparator}flutter.bat').writeAsString(
    '@echo off\r\n${marker ? 'echo A > "$mp"\r\n' : ''}exit /b $fe\r\n',
  );
  return (tmp: tmp, bin: bin);
}

/// Runs the production hook inside [tmp] with [bin] prepended to PATH.
Future<ProcessResult> _run(Directory tmp, Directory bin) async {
  final env = Map<String, String>.from(Platform.environment);
  env['PATH'] = '${bin.path};${env['PATH']}';
  return Process.run(
    'cmd',
    ['/c', _hookPath],
    workingDirectory: tmp.path,
    environment: env,
  );
}

Future<void> main() async {
  final started = DateTime.now();
  stdout.writeln('=== pre-commit.bat batch call semantics ===');
  stdout.writeln('Hook: $_hookPath\n');

  // 1. Happy-path: formatting OK → analyzer reached, exit 0
  await _case('formatting OK → analyzer reached (exit 0)', () async {
    final (:tmp, :bin) = await _setup(0, 0);
    final r = await _run(tmp, bin);
    _assert(
      File('${tmp.path}${Platform.pathSeparator}flutter_reached.txt')
          .existsSync(),
      'analyzer must be reached after formatting passes, exit ${r.exitCode}',
    );
    _assert(r.exitCode == 0, 'exit 0, got ${r.exitCode}');
    await tmp.delete(recursive: true);
  });

  // 2. Triangulate: dart fails → analyzer NOT reached, fail closed
  await _case('formatting fails → analyzer NOT reached, fail closed', () async {
    final (:tmp, :bin) = await _setup(1, 0);
    final r = await _run(tmp, bin);
    _assert(
      !(File('${tmp.path}${Platform.pathSeparator}flutter_reached.txt')
          .existsSync()),
      'analyzer must NOT be reached when formatting fails',
    );
    _assert(r.exitCode != 0, 'must fail non-zero, got ${r.exitCode}');
    await tmp.delete(recursive: true);
  });

  // 3. Triangulate: analyzer fails → fail closed
  await _case('formatting OK, analyzer fails → fail closed', () async {
    final (:tmp, :bin) = await _setup(0, 1, marker: false);
    final r = await _run(tmp, bin);
    _assert(r.exitCode != 0, 'must fail non-zero, got ${r.exitCode}');
    await tmp.delete(recursive: true);
  });

  // Summary
  final elapsed = DateTime.now().difference(started);
  stdout.writeln('\n=== RESULTS ===');
  stdout.writeln('Cases: 3  Passed: $_passed  Failed: $_failures');
  stdout.writeln('Elapsed: ${elapsed.inMilliseconds}ms');
  exit(_failures > 0 ? 1 : 0);
}

Future<void> _case(String name, Future<void> Function() body) async {
  stdout.write('  $name ... ');
  final s = DateTime.now();
  try {
    await body();
    stdout.writeln('(${DateTime.now().difference(s).inMilliseconds}ms)');
  } catch (e, st) {
    stdout.writeln('ERROR');
    stderr.writeln('  $e\n$st');
    _failures++;
  }
}
