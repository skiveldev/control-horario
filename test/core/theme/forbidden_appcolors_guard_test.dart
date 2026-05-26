import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Permanent guard against hardcoded light-only AppColors in feature/shared UI.
///
/// Fails if any .dart file under `lib/features/` or `lib/shared/` uses
/// forbidden surface/text/border tokens that bypass Theme.of(context).colorScheme.
///
/// Allowed semantic tokens (not flagged): primary, success, error, warning, info.
///
/// ## How to run
/// ```bash
/// flutter test test/core/theme/forbidden_appcolors_guard_test.dart
/// ```
///
/// ## Expected failures
/// The test listing below documents any legitimate exceptions that have been
/// reviewed and approved. Add narrowly to this list ONLY with maintainer sign-off.
const _allowedExceptions = <String>{
  // Format: 'file_path:line_number' — documented exceptions
};

const _forbiddenPatterns = <String>[
  r'AppColors\.background\b',
  r'AppColors\.surface\b',
  r'AppColors\.surfaceVariant\b',
  r'AppColors\.textPrimary\b',
  r'AppColors\.textSecondary\b',
  r'AppColors\.textTertiary\b',
  r'AppColors\.border\b', // matches AppColors.border but NOT borderLight
  r'AppColors\.borderLight\b',
];

final _forbiddenRegex = RegExp(_forbiddenPatterns.join('|'));

void main() {
  group('Forbidden AppColors guard', () {
    final libDir = Directory('lib');

    test('has no forbidden AppColors tokens in features/', () {
      final violations = <String>[];
      _scanDirectory(Directory('${libDir.path}/features'), violations);
      _report(violations, 'features/');
    });

    test('has no forbidden AppColors tokens in shared/', () {
      final violations = <String>[];
      _scanDirectory(Directory('${libDir.path}/shared'), violations);
      _report(violations, 'shared/');
    });
  });
}

void _scanDirectory(Directory dir, List<String> violations) {
  if (!dir.existsSync()) return;

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    final content = entity.readAsStringSync();
    final relativePath = entity.path.replaceAll('\\', '/');

    for (final match in _forbiddenRegex.allMatches(content)) {
      final matched = match.group(0)!;
      // Skip AppColorsDark patterns (they end up matching AppColors.borderLight
      // but not the full dark variant). Also skip AppColorsDark.* patterns.
      final line = content.substring(0, match.start).split('\n').length;
      final exceptionKey = '$relativePath:$line';

      if (_allowedExceptions.contains(exceptionKey)) continue;

      violations.add('$exceptionKey: $matched');
    }
  }
}

void _report(List<String> violations, String scope) {
  if (violations.isNotEmpty) {
    final sb = StringBuffer();
    sb.writeln(
      'Found ${violations.length} forbidden AppColors token(s) in $scope:',
    );
    sb.writeln(
      'These tokens bypass Theme.of(context).colorScheme and break dark mode.',
    );
    sb.writeln(
      'Replace with: colorScheme.surface, onSurface, onSurfaceVariant, outline,',
    );
    sb.writeln(
        '  outlineVariant, surfaceContainerHighest, or scaffoldBackgroundColor.');
    sb.writeln('');
    for (final v in violations) {
      sb.writeln('  $v');
    }
    fail(sb.toString());
  }
}
