import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/shared/widgets/layouts/admin_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AdminLayout notification bell triage', () {
    testWidgets('notification bell is disabled and shows no fake SnackBar',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testUser = UserModel(
        userId: 'admin-1',
        employeeId: 'EMP-admin-1',
        email: 'admin@example.com',
        displayName: 'Carlos Admin',
        role: UserRole.admin,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
        nombre: 'Carlos',
        apellido1: 'Admin',
      );

      final router = GoRouter(
        initialLocation: '/admin',
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminLayout(
              child: Text('Dashboard'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(testUser),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // The notification bell should exist but be disabled.
      final bellIcon = find.byIcon(Icons.notifications_outlined);
      expect(bellIcon, findsOneWidget);

      final bellIconButton = find.ancestor(
        of: bellIcon,
        matching: find.byType(IconButton),
      );
      expect(
        (bellIconButton.evaluate().single.widget as IconButton).onPressed,
        isNull,
      );

      // Tapping a disabled planned-feature control must not show fake feedback.
      await tester.tap(bellIcon);
      await tester.pumpAndSettle();

      expect(find.text('Próximamente'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('notification bell has no badge', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testUser = UserModel(
        userId: 'admin-1',
        employeeId: 'EMP-admin-1',
        email: 'admin@example.com',
        displayName: 'Carlos Admin',
        role: UserRole.admin,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
        nombre: 'Carlos',
        apellido1: 'Admin',
      );

      final router = GoRouter(
        initialLocation: '/admin',
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminLayout(
              child: Text('Dashboard'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(testUser),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Notification bell exists
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      // The notification bell icon should be grey/disabled
      final iconWidget = tester.widget<Icon>(
        find.byIcon(Icons.notifications_outlined),
      );
      // Disabled icon should have a grey-ish color (not full opacity primary)
      expect(iconWidget.color, isNotNull);
      // The color should NOT be the default (which would be unset/null for
      // an explicitly themed IconButton). A color set to grey confirms disabled.
      final disabledColor = Theme.of(
        tester.element(find.byType(MaterialApp)),
      ).disabledColor;
      expect(iconWidget.color, disabledColor);

      // The old badge was a Positioned Container with error-color
      // BoxDecoration.circle inside the notification Stack.
      // After triage, either the Stack is gone or the badge is removed.
      // Find all Stacks containing the notification icon
      final stacks = find.byType(Stack).evaluate().toList();
      var hasNotificationBadge = false;
      for (final stack in stacks) {
        final stackWidget = stack.widget as Stack;
        final hasIcon = find
            .descendant(
              of: find.byWidget(stackWidget),
              matching: find.byIcon(Icons.notifications_outlined),
            )
            .evaluate()
            .isNotEmpty;
        if (!hasIcon) continue;

        // This Stack contains the notification icon.
        // Count direct children: icon + old badge = 2 children
        // After triage: only icon = 1 child (or the Stack is gone entirely)
        final stackChildren = stackWidget.children;
        if (stackChildren.length > 1) {
          // Check if any extra child is a Positioned with a Container badge
          for (final child in stackChildren) {
            if (child is Positioned &&
                child.child is Container &&
                (child.child as Container).decoration is BoxDecoration &&
                ((child.child as Container).decoration as BoxDecoration)
                        .shape ==
                    BoxShape.circle) {
              hasNotificationBadge = true;
              break;
            }
          }
        }
      }
      expect(hasNotificationBadge, isFalse,
          reason: 'Notification badge should not exist');
    });

    testWidgets('notification bell tooltip indicates unavailability',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testUser = UserModel(
        userId: 'admin-1',
        employeeId: 'EMP-admin-1',
        email: 'admin@example.com',
        displayName: 'Carlos Admin',
        role: UserRole.admin,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
        nombre: 'Carlos',
        apellido1: 'Admin',
      );

      final router = GoRouter(
        initialLocation: '/admin',
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminLayout(
              child: Text('Dashboard'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(testUser),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // The notification bell should have a tooltip indicating planned status.
      final bellIconButton = find.ancestor(
        of: find.byIcon(Icons.notifications_outlined),
        matching: find.byType(IconButton),
      );
      final tooltip =
          (bellIconButton.evaluate().single.widget as IconButton).tooltip;
      expect(tooltip, equals('Notificaciones en construcción'));
    });
  });
}
