/// RED/GREEN harness for `.githooks/pre-commit.bat` batch `call` semantics.
///
/// A batch-to-batch invocation without `call` transfers control and never
/// returns, silently skipping the analyzer step. Windows exercises the hook
/// through `cmd`; other platforms parse the checked-in batch contract.
///
/// Usage:  dart run test/tool/pre_commit_batch_call_test.dart
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

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

Future<void> _windowsCases() async {
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

  await _case('formatting OK, analyzer fails → fail closed', () async {
    final (:tmp, :bin) = await _setup(0, 1, marker: false);
    final r = await _run(tmp, bin);
    _assert(r.exitCode != 0, 'must fail non-zero, got ${r.exitCode}');
    await tmp.delete(recursive: true);
  });
}

Future<void> _portableContractCases() async {
  final hook = await File(_hookPath).readAsString();

  await _case('delegates formatter with batch call', () async {
    _assert(
      RegExp(r'^call dart run tool\\check_staged_dart_format\.dart\s*$',
              multiLine: true)
          .hasMatch(hook),
      'hook must call the staged-format helper with its exact argument',
    );
  });

  await _case('formatter failure preserves its exit code', () async {
    _assert(
      RegExp(
        r'if errorlevel 1 \([\s\S]*?exit /b %errorlevel%[\s\S]*?\)',
        caseSensitive: false,
      ).hasMatch(hook),
      'formatter failure must propagate the helper exit code',
    );
  });

  await _case('analyzer invocation and failure are fail closed', () async {
    _assert(
      hook.contains('flutter analyze --no-pub --fatal-infos --fatal-warnings'),
      'hook must invoke the exact fatal analyzer command',
    );
    _assert(
      RegExp(
        r'flutter analyze --no-pub --fatal-infos --fatal-warnings[\s\S]*?'
        r'if errorlevel 1 \([\s\S]*?exit /b 1[\s\S]*?\)',
        caseSensitive: false,
      ).hasMatch(hook),
      'analyzer failure must fail the hook',
    );
  });
}

void main() {
  test('pre-commit batch hook contract', () async {
    final started = DateTime.now();
    stdout.writeln('=== pre-commit.bat batch call semantics ===');
    stdout.writeln('Hook: $_hookPath\n');

    if (Platform.isWindows) {
      await _windowsCases();
    } else {
      await _portableContractCases();
    }

    // Summary
    final elapsed = DateTime.now().difference(started);
    stdout.writeln('\n=== RESULTS ===');
    stdout.writeln('Cases: 3  Passed: $_passed  Failed: $_failures');
    stdout.writeln('Elapsed: ${elapsed.inMilliseconds}ms');
    if (_failures > 0) {
      throw StateError('$_failures batch-hook contract assertion(s) failed.');
    }
  });
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
