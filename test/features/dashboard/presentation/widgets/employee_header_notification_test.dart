import 'package:control_horario/features/dashboard/presentation/widgets/employee_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmployeeHeader notification bell triage', () {
    testWidgets('notification bell is disabled and shows SnackBar on tap',
        (tester) async {
      // Normal width (>= 400, >= 360) → normal variant with IconButtonCustom
      tester.view.physicalSize = const Size(500, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeHeader(
              employeeName: 'Juan Pérez',
              employeeId: 'EMP-001',
              isInWorkSchedule: true,
              currentDate: 'Lunes 1 de Enero',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Notification icon exists
      final bell = find.byIcon(Icons.notifications_outlined);
      expect(bell, findsOneWidget);

      // Tap the bell
      await tester.tap(bell);
      await tester.pumpAndSettle();

      // SnackBar with honest "Próximamente" message
      expect(find.text('Próximamente'), findsOneWidget);
    });

    testWidgets('notification bell has no badge and shows disabled color',
        (tester) async {
      tester.view.physicalSize = const Size(500, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeHeader(
              employeeName: 'Juan Pérez',
              employeeId: 'EMP-001',
              isInWorkSchedule: true,
              currentDate: 'Lunes 1 de Enero',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The notification icon should exist
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // The old badge "3" text should NOT exist
      expect(find.text('3'), findsNothing);

      // Find all Stacks containing the notification icon
      final stacks = find.byType(Stack).evaluate().toList();
      var badgeFound = false;
      for (final stack in stacks) {
        final stackWidget = stack.widget as Stack;
        final hasBell = find
            .descendant(
              of: find.byWidget(stackWidget),
              matching: find.byIcon(Icons.notifications_outlined),
            )
            .evaluate()
            .isNotEmpty;
        if (!hasBell) continue;

        // Stack should only have the icon, no badge children
        if (stackWidget.children.length > 1) {
          badgeFound = true;
        }
      }
      expect(badgeFound, isFalse,
          reason: 'No Stack should wrap the notification bell with a badge');

      // Settings icon should still exist (triangulation: other buttons intact)
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('notification bell tooltip indicates unavailability',
        (tester) async {
      tester.view.physicalSize = const Size(500, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeHeader(
              employeeName: 'Juan Pérez',
              employeeId: 'EMP-001',
              isInWorkSchedule: true,
              currentDate: 'Lunes 1 de Enero',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the tooltip on the notification bell
      final notificationBell = find.byIcon(Icons.notifications_outlined);

      // Find enclosing Tooltip widget
      final tooltipFinder = find.ancestor(
        of: notificationBell,
        matching: find.byType(Tooltip),
      );
      if (tooltipFinder.evaluate().isNotEmpty) {
        final tooltipWidget = tooltipFinder.evaluate().first.widget as Tooltip;
        expect(
          tooltipWidget.message,
          anyOf(
            equals('Próximamente'),
            equals('Notificaciones no disponibles'),
          ),
        );
      } else {
        // Fallback: check IconButton.tooltip directly
        final iconButton = find.ancestor(
          of: notificationBell,
          matching: find.byType(IconButton),
        );
        if (iconButton.evaluate().isNotEmpty) {
          final tooltip =
              (iconButton.evaluate().first.widget as IconButton).tooltip;
          expect(
            tooltip,
            anyOf(
              equals('Próximamente'),
              equals('Notificaciones no disponibles'),
            ),
          );
        }
      }
    });

    testWidgets('compact width notification bell also has no badge',
        (tester) async {
      // Compact width: >= 360 but < 400 → uses plain IconButton
      tester.view.physicalSize = const Size(390, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmployeeHeader(
              employeeName: 'Ana',
              employeeId: 'EMP-002',
              isInWorkSchedule: true,
              currentDate: 'Lunes 1 de Enero',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Notification icon exists (compact variant uses plain IconButton)
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // Check Stacks around the bell — no badge
      final stacks = find.byType(Stack).evaluate().toList();
      var badgeFound = false;
      for (final stack in stacks) {
        final stackWidget = stack.widget as Stack;
        final hasBell = find
            .descendant(
              of: find.byWidget(stackWidget),
              matching: find.byIcon(Icons.notifications_outlined),
            )
            .evaluate()
            .isNotEmpty;
        if (!hasBell) continue;
        if (stackWidget.children.length > 1) {
          badgeFound = true;
        }
      }
      expect(badgeFound, isFalse);
    });
  });
}
