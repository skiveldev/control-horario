import 'package:control_horario/core/theme/app_text_styles.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Returns all text styles that must not have a hardcoded color.
  Map<String, TextStyle> allBaseStyles() => {
        // Headings
        'h1': AppTextStyles.h1,
        'h2': AppTextStyles.h2,
        'h3': AppTextStyles.h3,
        'h4': AppTextStyles.h4,
        'h5': AppTextStyles.h5,
        'h6': AppTextStyles.h6,
        // Body
        'bodyLarge': AppTextStyles.bodyLarge,
        'bodyMedium': AppTextStyles.bodyMedium,
        'bodySmall': AppTextStyles.bodySmall,
        // Labels
        'labelLarge': AppTextStyles.labelLarge,
        'labelMedium': AppTextStyles.labelMedium,
        'labelSmall': AppTextStyles.labelSmall,
        // Display
        'displayLarge': AppTextStyles.displayLarge,
        'displayMedium': AppTextStyles.displayMedium,
        'displaySmall': AppTextStyles.displaySmall,
      };

  group('AppTextStyles — no hardcoded color', () {
    testWidgets('all base styles have null color', (tester) async {
      final styles = allBaseStyles();
      final failures = <String>[];

      for (final entry in styles.entries) {
        if (entry.value.color != null) {
          failures.add(entry.key);
        }
      }

      expect(
        failures,
        isEmpty,
        reason: 'These styles still hardcode color: $failures. '
            'ThemeData.textTheme must supply color per brightness.',
      );
    });

    testWidgets('button style has no hardcoded color', (tester) async {
      expect(AppTextStyles.button.color, isNull,
          reason: 'button color should come from theme');
    });

    testWidgets('caption style has no hardcoded color', (tester) async {
      expect(AppTextStyles.caption.color, isNull,
          reason: 'caption color should come from theme');
    });

    testWidgets('overline style has no hardcoded color', (tester) async {
      expect(AppTextStyles.overline.color, isNull,
          reason: 'overline color should come from theme');
    });

    testWidgets('link style has no hardcoded color', (tester) async {
      expect(AppTextStyles.link.color, isNull,
          reason: 'link color should come from theme');
    });

    testWidgets('linkSmall style has no hardcoded color', (tester) async {
      expect(AppTextStyles.linkSmall.color, isNull,
          reason: 'linkSmall color should come from theme');
    });
  });

  group('Light theme TextTheme fills all colors', () {
    late TextTheme lt;

    setUp(() {
      lt = AppTheme.lightTheme.textTheme;
    });

    testWidgets('headlineLarge (h1) has explicit color', (tester) async {
      expect(lt.headlineLarge?.color, isNotNull);
    });

    testWidgets('bodyMedium has explicit color', (tester) async {
      expect(lt.bodyMedium?.color, isNotNull);
    });

    testWidgets('bodySmall has explicit color', (tester) async {
      expect(lt.bodySmall?.color, isNotNull);
    });

    testWidgets('displayLarge has explicit color', (tester) async {
      expect(lt.displayLarge?.color, isNotNull);
    });

    testWidgets('labelLarge has explicit color', (tester) async {
      expect(lt.labelLarge?.color, isNotNull);
    });

    testWidgets('titleMedium (h5) has explicit color', (tester) async {
      expect(lt.titleMedium?.color, isNotNull);
    });
  });

  group('Dark theme TextTheme fills all colors', () {
    late TextTheme dt;

    setUp(() {
      dt = AppTheme.darkTheme.textTheme;
    });

    testWidgets('headlineLarge is bright text', (tester) async {
      expect(dt.headlineLarge?.color, isNotNull);
      expect(dt.headlineLarge!.color!.computeLuminance(), greaterThan(0.5),
          reason: 'dark theme headlineLarge should be bright');
    });

    testWidgets('bodyMedium is bright text', (tester) async {
      expect(dt.bodyMedium?.color, isNotNull);
      expect(dt.bodyMedium!.color!.computeLuminance(), greaterThan(0.5));
    });

    testWidgets('bodySmall has explicit color', (tester) async {
      expect(dt.bodySmall?.color, isNotNull);
    });

    testWidgets('labelLarge is bright text', (tester) async {
      expect(dt.labelLarge?.color, isNotNull);
      expect(dt.labelLarge!.color!.computeLuminance(), greaterThan(0.5));
    });

    testWidgets('displayLarge is bright text', (tester) async {
      expect(dt.displayLarge?.color, isNotNull);
      expect(dt.displayLarge!.color!.computeLuminance(), greaterThan(0.5));
    });
  });
}
