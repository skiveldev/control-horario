/// Checks staged Dart files for correct formatting without mutating the
/// worktree or index.  Designed to be invoked from a Git pre-commit hook.
///
/// Behaviour:
/// - Discovers the repository root via `git rev-parse --show-toplevel`.
/// - Reads staged ACMR `.dart` paths (NUL-safe); ignores deletions.
/// - No staged Dart files → exits 0 (success, nothing to check).
/// - Before running the formatter, verifies that no staged Dart file also
///   has unstaged modifications.  If any does → exits non-zero with a
///   message to `stderr` (fail-closed — the index differs from the worktree).
/// - Runs `dart format --output=none --set-exit-if-changed` on the
///   verified paths via argument list (never shell interpolation).
/// - Never writes, stages, resolves, or installs anything.
/// - Propagates the formatter's exit code.
///
/// Usage:
///   dart run tool/check_staged_dart_format.dart
library;

import 'dart:io';

Future<void> main() async {
  try {
    final exitCode = await _run();
    exit(exitCode);
  } on FormatException catch (e) {
    stderr.writeln('ERROR: ${e.message}');
    exit(2);
  } catch (e) {
    stderr.writeln('ERROR: $e');
    exit(2);
  }
}

/// Core logic, separated so `main()` can handle exceptions uniformly.
Future<int> _run() async {
  // 1. Discover repository root.
  final repoRoot = await _repoRoot();

  // 2. Get staged ACMR .dart files (NUL-delimited, deletions excluded).
  final dartPaths = await _stagedDartPaths(repoRoot);

  // 3. No staged Dart → success.
  if (dartPaths.isEmpty) {
    return 0;
  }

  // 4. Guard: reject if any staged Dart has unstaged content.
  final dirtyPaths = await _pathsWithUnstagedContent(repoRoot, dartPaths);
  if (dirtyPaths.isNotEmpty) {
    stderr.writeln(
      'ERROR: The following staged Dart files also have unstaged '
      'modifications:\n'
      '  ${dirtyPaths.join('\n  ')}\n\n'
      'The pre-commit hook cannot safely verify formatting when the '
      'index differs from the worktree.  Either commit or stash your '
      'unstaged changes first.',
    );
    return 1;
  }

  // 5. Run check-only formatter.
  final formatBin =
      Platform.environment['DART_FORMAT_BIN'] ?? Platform.resolvedExecutable;

  ProcessResult formatResult;
  try {
    formatResult = await Process.run(
      formatBin,
      ['format', '--output=none', '--set-exit-if-changed', ...dartPaths],
      workingDirectory: repoRoot,
      runInShell: false,
    );
  } on ProcessException catch (e) {
    stderr.writeln(
      'ERROR: Could not run `$formatBin format`.  '
      'Is the Dart SDK installed and available?\n'
      '  $e',
    );
    return 1;
  }

  // Forward stdout/stderr from the formatter when it has content.
  if ((formatResult.stdout as String).isNotEmpty) {
    stdout.write(formatResult.stdout);
  }
  if ((formatResult.stderr as String).isNotEmpty) {
    stderr.write(formatResult.stderr);
  }

  if (formatResult.exitCode != 0) {
    stderr.writeln(
      '\nOne or more staged Dart files are not formatted '
      '(check-only — no files were modified).  Run:\n'
      '  $formatBin format ${dartPaths.join(' ')}\n'
      'then stage the result before committing.',
    );
  }

  return formatResult.exitCode;
}

/// Returns the absolute path to the repository root.
///
/// Throws [FormatException] if we are not inside a Git repository or if
/// `git` is unavailable.
Future<String> _repoRoot() async {
  final result = await Process.run(
    'git',
    ['rev-parse', '--show-toplevel'],
    runInShell: false,
  );

  if (result.exitCode != 0) {
    final err = (result.stderr as String).trim();
    throw FormatException(
      err.isNotEmpty
          ? 'git rev-parse failed: $err'
          : 'Not inside a Git repository (or git is unavailable).',
    );
  }

  return (result.stdout as String).trim();
}

/// Returns the list of staged `.dart` file paths (relative to [repoRoot])
/// that have status A, C, M, or R in the index.
///
/// Uses NUL-delimited output (`-z`) to safely handle spaces and Unicode.
/// Deleted files (D) are excluded from the ACMR filter.
Future<List<String>> _stagedDartPaths(String repoRoot) async {
  final result = await Process.run(
    'git',
    [
      'diff',
      '--cached',
      '--name-status',
      '--diff-filter=ACMR',
      '-z',
      '--',
      '*.dart',
    ],
    workingDirectory: repoRoot,
    runInShell: false,
  );

  if (result.exitCode != 0) {
    throw FormatException(
      'git diff --cached failed: ${result.stderr}',
    );
  }

  // Parse NUL-delimited output: <status>\0<path>\0<status>\0<path>\0...
  final raw = (result.stdout as String);
  // Split on NUL; drop the trailing empty entry from the final NUL.
  final parts = raw.split('\x00');
  final paths = <String>[];
  for (var i = 0; i < parts.length - 1; i += 2) {
    // parts[i]   = status letter (A/C/M/R)
    // parts[i+1] = file path  (for R it's the destination)
    final path = parts[i + 1];
    if (path.isNotEmpty) {
      paths.add(path);
    }
  }
  return paths;
}

/// Returns the subset of [paths] (relative to [repoRoot]) that have
/// unstaged modifications according to `git diff --name-only`.
Future<List<String>> _pathsWithUnstagedContent(
  String repoRoot,
  List<String> paths,
) async {
  if (paths.isEmpty) return [];

  final result = await Process.run(
    'git',
    ['diff', '--name-only', '--', ...paths],
    workingDirectory: repoRoot,
    runInShell: false,
  );

  if (result.exitCode != 0) {
    throw FormatException(
      'git diff --name-only failed: ${result.stderr}',
    );
  }

  final output = (result.stdout as String).trim();
  if (output.isEmpty) return [];

  return output.split('\n').where((p) => p.isNotEmpty).toList();
}
