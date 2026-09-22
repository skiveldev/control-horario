import 'dart:convert';
import 'dart:io';

class Finding implements Comparable<Finding> {
  const Finding(this.path, this.line, this.rule);

  final String path;
  final int line;
  final String rule;

  @override
  int compareTo(Finding other) {
    final pathOrder = path.compareTo(other.path);
    if (pathOrder != 0) return pathOrder;
    final lineOrder = line.compareTo(other.line);
    if (lineOrder != 0) return lineOrder;
    return rule.compareTo(other.rule);
  }

  @override
  String toString() => '$path:$line:$rule';
}

final _apiKey = RegExp(r'AIza[\w-]{20,}');
final _machinePath = RegExp(
  r'(?:/home/[^/\s]+|/mnt/c/Users/[^/\s]+|[A-Za-z]:\\Users\\[^\\\s]+)',
  caseSensitive: false,
);
final _schoolData = RegExp(
  r'(?:escuela(?:musica)?\.com|escuela\s+de\s+m[úu]sica|\b(?:paulo|skivel)\b)',
  caseSensitive: false,
);
final _weakCredential = RegExp(r'\b(?:empleado123|admin123|rrhh123)\b');
final _liveClaim = RegExp(
  r'\b(?:this\s+(?:app|mvp)|(?:la|el)\s+(?:app|mvp))\b.*\b(?:live|production|producci[oó]n)\b|\b(?:app|mvp)\b.*\b(?:is|est[áa])\s+(?:live|in\s+production|en\s+producci[oó]n)\b|\bmvp\s+en\s+producci[oó]n\b',
  caseSensitive: false,
);

List<Finding> scanTextFiles(
  Directory root,
  Iterable<String> paths, {
  Iterable<String> excludePrefixes = const [],
  Iterable<String> excludePaths = const [],
}) {
  final normalizedPrefixes = excludePrefixes
      .map(_normalizePrefix)
      .where((prefix) => prefix.isNotEmpty)
      .toList();
  final normalizedPaths = excludePaths.map(_normalizePath).toSet();
  final findings = <Finding>[];

  for (final path in paths.map(_normalizePath).toSet().toList()..sort()) {
    if (_isProtected(path) ||
        normalizedPaths.contains(path) ||
        normalizedPrefixes.any((prefix) => path.startsWith(prefix))) {
      continue;
    }
    final file = File('${root.path}${Platform.pathSeparator}$path');
    if (!file.existsSync() || _isBinary(file)) continue;

    final lines = file.readAsLinesSync(encoding: utf8);
    final firebaseConfig = _isFirebaseConfig(path);
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final lineNumber = index + 1;
      if (_apiKey.hasMatch(line)) {
        findings.add(Finding(path, lineNumber, 'firebase-api-key'));
      }
      if (_machinePath.hasMatch(line)) {
        findings.add(Finding(path, lineNumber, 'user-machine-path'));
      }
      if (path.endsWith('mock_data.dart') && _schoolData.hasMatch(line)) {
        findings.add(Finding(path, lineNumber, 'school-specific-data'));
      }
      if (_weakCredential.hasMatch(line)) {
        findings.add(Finding(path, lineNumber, 'weak-documented-credential'));
      }
      if (_liveClaim.hasMatch(line) ||
          (path.endsWith('mock_data.dart') &&
              RegExp(r'\ben producci[oó]n\b', caseSensitive: false)
                  .hasMatch(line))) {
        findings.add(Finding(path, lineNumber, 'live-production-claim'));
      }
      if (firebaseConfig && _hasRealFirebaseIdentifier(line)) {
        findings.add(Finding(path, lineNumber, 'firebase-config-identifier'));
      }
    }
  }

  findings.sort();
  return findings;
}

bool _hasRealFirebaseIdentifier(String line) {
  return RegExp(
    r'(?:control-horario-rega|113891078966|firebaseapp\.com|firebasestorage\.app)',
    caseSensitive: false,
  ).hasMatch(line);
}

bool _isFirebaseConfig(String path) =>
    path.endsWith('firebase_options.dart') ||
    path.endsWith('google-services.json');

bool _isProtected(String path) =>
    path.startsWith('.atl/') ||
    path.startsWith('.pi/') ||
    path.startsWith('functions/lib/') ||
    path == 'tool/check_repository_sanitization.dart' ||
    path == 'test/tool/check_repository_sanitization_test.dart' ||
    path.endsWith('.lock') ||
    path.endsWith('package-lock.json');

bool _isBinary(File file) {
  final handle = file.openSync(mode: FileMode.read);
  try {
    return handle.readSync(8192).contains(0);
  } finally {
    handle.closeSync();
  }
}

String _normalizePath(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.startsWith('./') ? normalized.substring(2) : normalized;
}

String _normalizePrefix(String prefix) {
  final normalized = _normalizePath(prefix);
  return normalized.endsWith('/') ? normalized : '$normalized/';
}

String _normalizeRepoRelativePath(String path) {
  final normalized = _normalizePath(path);
  if (normalized.isEmpty ||
      normalized.startsWith('/') ||
      RegExp(r'^[A-Za-z]:/').hasMatch(normalized) ||
      normalized.split('/').any((segment) => segment == '..')) {
    throw FormatException(
      'Expected a non-empty repository-relative path inside the repository.',
    );
  }
  return normalized;
}

Directory repositoryRoot() {
  final result = Process.runSync('git', ['rev-parse', '--show-toplevel']);
  if (result.exitCode != 0) {
    throw StateError('Unable to determine repository root with Git.');
  }
  return Directory((result.stdout as String).trim());
}

List<String> repositoryTextCandidates(Directory root) {
  final result = Process.runSync(
    'git',
    ['-C', root.path, 'ls-files', '-co', '--exclude-standard'],
  );
  if (result.exitCode != 0) {
    throw StateError('Unable to enumerate repository files with Git.');
  }
  return const LineSplitter()
      .convert(result.stdout as String)
      .where((path) => path.isNotEmpty)
      .toList();
}

void main(List<String> arguments) {
  final excludePrefixes = <String>[];
  final excludePaths = <String>[];
  for (final argument in arguments) {
    const prefixOption = '--exclude-prefix=';
    const pathOption = '--exclude-path=';
    if (argument.startsWith(prefixOption) &&
        argument.length > prefixOption.length) {
      excludePrefixes.add(argument.substring(prefixOption.length));
    } else if (argument.startsWith(pathOption) &&
        argument.length > pathOption.length) {
      try {
        excludePaths.add(_normalizeRepoRelativePath(
          argument.substring(pathOption.length),
        ));
      } on FormatException catch (error) {
        stderr.writeln('Invalid --exclude-path: ${error.message}');
        exitCode = 64;
        return;
      }
    } else {
      stderr.writeln('Usage: dart run tool/check_repository_sanitization.dart '
          '[--exclude-prefix=<repo-relative-prefix>] '
          '[--exclude-path=<repo-relative-file>]');
      exitCode = 64;
      return;
    }
  }

  final root = repositoryRoot();
  final findings = scanTextFiles(
    root,
    repositoryTextCandidates(root),
    excludePrefixes: excludePrefixes,
    excludePaths: excludePaths,
  );
  for (final finding in findings) {
    stdout.writeln(finding);
  }
  if (findings.isNotEmpty) exitCode = 1;
}
