/// RED integration test harness for `tool/check_staged_dart_format.dart`.
///
/// Self-contained — no test framework dependency.  Each test case creates a
/// temporary Git repo, stages files, runs the helper via `dart run`, and
/// asserts exit codes and behaviour.  A non-zero process exit means at least
/// one assertion failed.
///
/// Usage:  dart run test/tool/check_staged_dart_format_test.dart
library;

import 'dart:io';

final _worktreeRoot = Directory.current.path;
final _helperPath =
    '$_worktreeRoot${Platform.pathSeparator}tool${Platform.pathSeparator}check_staged_dart_format.dart';

int _failures = 0;
int _passed = 0;

void _assert(bool condition, String msg) {
  if (!condition) {
    stderr.writeln('  FAIL: $msg');
    _failures++;
  } else {
    _passed++;
  }
}

Future<ProcessResult> _git(Directory dir, List<String> args) =>
    Process.run('git', args, workingDirectory: dir.path);

Future<ProcessResult> _helper(Directory dir) =>
    Process.run('dart', ['run', _helperPath], workingDirectory: dir.path);

Future<File> _write(Directory dir, String relPath, String content) async {
  final f = File('${dir.path}${Platform.pathSeparator}$relPath');
  await f.parent.create(recursive: true);
  await f.writeAsString(content);
  return f;
}

const _formatted = "void main() {\n  print('hello');\n}\n";
const _unformatted = "void main() {\n  print(  'hello' ) ;\n}\n";

Future<void> main() async {
  final started = DateTime.now();
  stdout.writeln(
      '=== Integration suite: check_staged_dart_format (attempt 2) ===');
  stdout.writeln('Helper path: $_helperPath');
  stdout.writeln();

  // ── 1. No staged files ─────────────────────────────────────────────
  await _case('no staged files → exit 0', () async {
    final d = await _tmpRepo();
    final r = await _helper(d);
    _assert(r.exitCode == 0, 'exit 0, got ${r.exitCode}');
    await d.delete(recursive: true);
  });

  // ── 2. Non-Dart staged only ────────────────────────────────────────
  await _case('staged non-Dart only → exit 0', () async {
    final d = await _tmpRepo();
    await _write(d, 'readme.md', '# Hello');
    await _git(d, ['add', 'readme.md']);
    final r = await _helper(d);
    _assert(r.exitCode == 0, 'exit 0, got ${r.exitCode}');
    await d.delete(recursive: true);
  });

  // ── 3. WU1-like non-Dart index ─────────────────────────────────────
  await _case('WU1-like staged non-Dart index → exit 0', () async {
    final d = await _tmpRepo();
    await _write(d, '.codegraph/.gitignore', '*.lock\n');
    await _git(d, ['add', '.codegraph/.gitignore']);
    final r = await _helper(d);
    _assert(r.exitCode == 0, 'exit 0, got ${r.exitCode}');
    await d.delete(recursive: true);
  });

  // ── 4. Formatted Dart staged ───────────────────────────────────────
  await _case('staged formatted Dart → exit 0', () async {
    final d = await _tmpRepo();
    await _write(d, 'lib/app.dart', _formatted);
    await _git(d, ['add', 'lib/app.dart']);
    await _git(d, ['commit', '-m', 'base']);
    await _write(d, 'lib/app.dart', _formatted.replaceAll('hello', 'world'));
    await _git(d, ['add', 'lib/app.dart']);
    final r = await _helper(d);
    _assert(r.exitCode == 0, 'formatted Dart should exit 0, got ${r.exitCode}');
    await d.delete(recursive: true);
  });

  // ── 5. Unformatted Dart staged → fail, no mutation ─────────────────
  await _case('staged unformatted Dart → exit non-zero, no mutation', () async {
    final d = await _tmpRepo();
    await _write(d, 'lib/bad.dart', _formatted);
    await _git(d, ['add', 'lib/bad.dart']);
    await _git(d, ['commit', '-m', 'base']);
    final file = File(
        '${d.path}${Platform.pathSeparator}lib${Platform.pathSeparator}bad.dart');
    await file.writeAsString(_unformatted);
    await _git(d, ['add', 'lib/bad.dart']);
    final before = await file.readAsString();
    final r = await _helper(d);
    _assert(r.exitCode != 0,
        'unformatted Dart should fail (non-zero), got ${r.exitCode}');
    final after = await file.readAsString();
    _assert(after == before, 'helper MUST NOT mutate worktree files');
    await d.delete(recursive: true);
  });

  // ── 6. Staged + unstaged same path → fail closed ───────────────────
  await _case('staged Dart with unstaged modifications → fail closed',
      () async {
    final d = await _tmpRepo();
    await _write(d, 'lib/mixed.dart', _formatted);
    await _git(d, ['add', 'lib/mixed.dart']);
    await _git(d, ['commit', '-m', 'base']);
    await _write(d, 'lib/mixed.dart', _formatted.replaceAll('hello', 'staged'));
    await _git(d, ['add', 'lib/mixed.dart']);
    // now dirty the working tree without staging
    await _write(
        d, 'lib/mixed.dart', _formatted.replaceAll('hello', 'unstaged'));
    final r = await _helper(d);
    _assert(
        r.exitCode != 0, 'staged+unstaged must fail closed, got ${r.exitCode}');
    final stdErr = '${r.stderr}'.toLowerCase();
    _assert(
        stdErr.contains('unstaged') ||
            stdErr.contains('modified') ||
            stdErr.contains('differ'),
        'error should mention unstaged/modified, got: ${r.stderr}');
    await d.delete(recursive: true);
  });

  // ── 7. Spaces in path ──────────────────────────────────────────────
  await _case('staged Dart in directory with spaces', () async {
    final d = await _tmpRepo();
    await _write(d, 'my lib/app.dart', _formatted);
    await _git(d, ['add', 'my lib/app.dart']);
    await _git(d, ['commit', '-m', 'base']);
    final r = await _helper(d);
    _assert(r.exitCode == 0, 'spaces path should exit 0, got ${r.exitCode}');
    await d.delete(recursive: true);
  });

  // ── 8. Unicode filename ────────────────────────────────────────────
  await _case('staged Dart with unicode filename', () async {
    final d = await _tmpRepo();
    await _write(d, 'lib/señor.dart', _formatted);
    await _git(d, ['add', 'lib/señor.dart']);
    await _git(d, ['commit', '-m', 'base']);
    final r = await _helper(d);
    _assert(r.exitCode == 0, 'unicode path should exit 0, got ${r.exitCode}');
    await d.delete(recursive: true);
  });

  // ── 9. Deleted Dart → ignored ──────────────────────────────────────
  await _case('deleted Dart (staged removal) → ignored (no-op)', () async {
    final d = await _tmpRepo();
    await _write(d, 'lib/old.dart', _formatted);
    await _git(d, ['add', 'lib/old.dart']);
    await _git(d, ['commit', '-m', 'base']);
    await File(
            '${d.path}${Platform.pathSeparator}lib${Platform.pathSeparator}old.dart')
        .delete();
    await _git(d, ['add', 'lib/old.dart']); // stages deletion
    final r = await _helper(d);
    _assert(r.exitCode == 0,
        'deleted Dart should be ignored (exit 0), got ${r.exitCode}');
    await d.delete(recursive: true);
  });

  // ── 10. Renamed Dart ───────────────────────────────────────────────
  await _case('renamed Dart (staged rename) → handles destination', () async {
    final d = await _tmpRepo();
    await _write(d, 'lib/old_name.dart', _formatted);
    await _git(d, ['add', 'lib/old_name.dart']);
    await _git(d, ['commit', '-m', 'base']);
    await File(
            '${d.path}${Platform.pathSeparator}lib${Platform.pathSeparator}old_name.dart')
        .rename(
            '${d.path}${Platform.pathSeparator}lib${Platform.pathSeparator}new_name.dart');
    await _git(d, ['add', '-A']);
    final r = await _helper(d);
    _assert(r.exitCode == 0, 'renamed Dart should exit 0, got ${r.exitCode}');
    await d.delete(recursive: true);
  });

  // ── 11. Nested cwd → discovers repo root ───────────────────────────
  await _case('nested cwd → discovers repo root', () async {
    final d = await _tmpRepo();
    await _write(d, 'lib/app.dart', _formatted);
    await _git(d, ['add', 'lib/app.dart']);
    await _git(d, ['commit', '-m', 'base']);
    final r = await Process.run(
      'dart',
      ['run', _helperPath],
      workingDirectory: '${d.path}${Platform.pathSeparator}lib',
    );
    _assert(r.exitCode == 0, 'nested cwd should exit 0, got ${r.exitCode}');
    await d.delete(recursive: true);
  });

  // ── 12. Non-repo cwd → fail ────────────────────────────────────────
  await _case('non-repo cwd → fail with actionable error', () async {
    final d = await Directory.systemTemp.createTemp('hook_nonrepo_');
    try {
      final r = await _helper(d);
      _assert(r.exitCode != 0, 'non-repo cwd should fail, got ${r.exitCode}');
      final stdErr = '${r.stderr}'.toLowerCase();
      _assert(
          stdErr.contains('not a git') ||
              stdErr.contains('repository') ||
              stdErr.contains('no git') ||
              stdErr.contains('fatal'),
          'error should mention missing repo, got: ${r.stderr}');
    } finally {
      if (await d.exists()) await d.delete(recursive: true);
    }
  });

  // ── 13. Multiple files, one unformatted → fail ─────────────────────
  await _case('multiple staged Dart, one unformatted → fail', () async {
    final d = await _tmpRepo();
    await _write(d, 'lib/good.dart', _formatted);
    await _write(d, 'lib/bad.dart', _unformatted);
    await _git(d, ['add', 'lib/good.dart', 'lib/bad.dart']);
    await _git(d, ['commit', '-m', 'base']);
    await _write(d, 'lib/good.dart', _formatted.replaceAll('hello', 'hi'));
    await _write(d, 'lib/bad.dart', _unformatted.replaceAll('hello', 'hi'));
    await _git(d, ['add', 'lib/good.dart', 'lib/bad.dart']);
    final r = await _helper(d);
    _assert(r.exitCode != 0,
        'batch with unformatted should fail, got ${r.exitCode}');
    await d.delete(recursive: true);
  });

  // ── 14. Helper never mutates index ─────────────────────────────────
  await _case('helper never mutates Git index', () async {
    final d = await _tmpRepo();
    await _write(d, 'lib/app.dart', _formatted);
    await _git(d, ['add', 'lib/app.dart']);
    await _git(d, ['commit', '-m', 'base']);
    await _write(d, 'lib/app.dart', _formatted.replaceAll('hello', 'changed'));
    await _git(d, ['add', 'lib/app.dart']);
    final idxBefore = await _git(d, ['diff', '--cached', '--name-only']);
    await _helper(d);
    final idxAfter = await _git(d, ['diff', '--cached', '--name-only']);
    _assert(idxAfter.stdout.toString() == idxBefore.stdout.toString(),
        'helper MUST NOT mutate index');
    await d.delete(recursive: true);
  });

  // ── 15. Formatter unavailable (DART_FORMAT_BIN override) ──────────
  await _case('formatter unavailable → fail with actionable error', () async {
    final d = await _tmpRepo();
    await _write(d, 'lib/app.dart', _formatted);
    await _git(d, ['add', 'lib/app.dart']);
    await _git(d, ['commit', '-m', 'base']);
    // Modify and stage so the helper has Dart to check
    await _write(d, 'lib/app.dart', _formatted.replaceAll('hello', 'world'));
    await _git(d, ['add', 'lib/app.dart']);
    // Snapshot index before
    final idxBefore = await _git(d, ['diff', '--cached', '--name-only']);
    // Invoke helper with DART_FORMAT_BIN pointing to a nonexistent binary
    final testEnv = Map<String, String>.from(Platform.environment);
    testEnv['DART_FORMAT_BIN'] = '___nonexistent_format_bin___';
    final r = await Process.run(
      'dart',
      ['run', _helperPath],
      workingDirectory: d.path,
      environment: testEnv,
    );
    _assert(r.exitCode != 0,
        'formatter-unavailable must fail non-zero, got ${r.exitCode}');
    final stdErr = '${r.stderr}'.toLowerCase();
    _assert(
        stdErr.contains('format') &&
            (stdErr.contains('unavailable') ||
                stdErr.contains('not found') ||
                stdErr.contains('failed') ||
                stdErr.contains('error')),
        'error must mention formatter unavailability, got: ${r.stderr}');
    // Verify index unchanged
    final idxAfter = await _git(d, ['diff', '--cached', '--name-only']);
    _assert(idxAfter.stdout.toString() == idxBefore.stdout.toString(),
        'formatter-unavailable must not mutate index');
    await d.delete(recursive: true);
  });

  // ── Summary ────────────────────────────────────────────────────────
  final elapsed = DateTime.now().difference(started);
  final totalCases = 15;
  stdout.writeln();
  stdout.writeln('=== RESULTS ===');
  stdout.writeln('Cases: $totalCases');
  stdout.writeln('Assertions passed: $_passed');
  stdout.writeln('Assertions failed: $_failures');
  stdout.writeln('Elapsed: ${elapsed.inMilliseconds}ms');

  if (_failures > 0) {
    stderr.writeln(
        'FAILED: $_failures assertion(s) failed across $totalCases cases.');
    exit(1);
  } else {
    stdout.writeln('All $totalCases cases passed ($_passed assertions).');
    exit(0);
  }
}

/// Creates a temporary git repo, returns its Directory.
Future<Directory> _tmpRepo() async {
  final d = await Directory.systemTemp.createTemp('hook_test_');
  await _git(d, ['init', '--initial-branch=main']);
  await _git(d, ['config', 'user.email', 'test@test.com']);
  await _git(d, ['config', 'user.name', 'Test']);
  return d;
}

/// Runs a single test case with header and timing.
Future<void> _case(String name, Future<void> Function() body) async {
  stdout.write('  $name ... ');
  final start = DateTime.now();
  try {
    await body();
    final ms = DateTime.now().difference(start).inMilliseconds;
    stdout.writeln('(${ms}ms)');
  } catch (e, st) {
    stdout.writeln('ERROR');
    stderr.writeln('  Unhandled exception: $e');
    stderr.writeln(st);
    _failures++;
  }
}
