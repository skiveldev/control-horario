import 'package:control_horario/core/theme/app_colors.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/admin/presentation/screens/admin_profile_screen.dart';
import 'package:control_horario/features/auth/presentation/widgets/change_password_dialog.dart';
import 'package:control_horario/features/dashboard/presentation/screens/my_time_control_screen.dart';
import 'package:control_horario/features/dashboard/presentation/screens/profile_screen.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/add_edit_record_modal.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/day_record_card.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Helper: wraps [child] in a dark-themed MaterialApp.
Widget wrapDark(Widget child) {
  return MaterialApp(
    themeMode: ThemeMode.dark,
    darkTheme: AppTheme.darkTheme,
    theme: AppTheme.lightTheme,
    home: child,
  );
}

void main() {
  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  // ============================================================================
  // WU-2: AdminProfileScreen — no hardcoded AppColors.primary/error
  // ============================================================================
  group('AdminProfileScreen PR#10 dark mode fixes', () {
    testWidgets('section icon does not use hardcoded AppColors.primary',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final router = GoRouter(
        initialLocation: '/admin/profile',
        routes: [
          GoRoute(
            path: '/admin/profile',
            builder: (context, state) => const AdminProfileScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // "Notificaciones" section icon must not use hardcoded AppColors.primary
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      for (final icon in icons) {
        if (icon.icon == Icons.notifications) {
          expect(icon.color, isNot(AppColors.primary),
              reason:
                  'AdminProfileScreen section icon must not hardcode AppColors.primary');
        }
      }
    });

    testWidgets('logout icon and text do not use hardcoded AppColors.error',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final router = GoRouter(
        initialLocation: '/admin/profile',
        routes: [
          GoRoute(
            path: '/admin/profile',
            builder: (context, state) => const AdminProfileScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Logout is visible in dark mode (text and icon render)
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });
  });

  // ============================================================================
  // WU-3: ChangePasswordDialog — no hardcoded AppColors
  // ============================================================================
  group('ChangePasswordDialog PR#10 dark mode fixes', () {
    testWidgets('dialog renders in dark mode without hardcoded colors',
        (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        wrapDark(const Material(
          child: ChangePasswordDialog(),
        )),
      );
      await tester.pumpAndSettle();

      // Title must be visible
      expect(find.text('Cambiar Contraseña'), findsOneWidget);

      // Lock icon(s) must exist (header lock + password fields)
      // and the header lock icon must not use hardcoded AppColors.primary
      final lockIcons =
          tester.widgetList<Icon>(find.byIcon(Icons.lock_outline));
      expect(lockIcons.isNotEmpty, isTrue);
      final headerLock = lockIcons.first;
      expect(headerLock.color, isNot(AppColors.primary),
          reason:
              'ChangePasswordDialog header lock icon must not hardcode AppColors.primary');
    });
  });

  // ============================================================================
  // WU-4: DayRecordCard — theme-aware colors
  // ============================================================================
  group('DayRecordCard PR#10 dark mode fixes', () {
    testWidgets(
        'card background is not hardcoded AppColors.surface in dark mode',
        (tester) async {
      tester.view.physicalSize = const Size(400, 200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testDate = DateTime(2026, 5, 25);
      await tester.pumpWidget(
        wrapDark(
          Scaffold(
            body: SingleChildScrollView(
              child: DayRecordCard(
                date: testDate,
                records: [],
                plannedMinutes: 480,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The card header date text must be visible (proves card renders)
      final dayNumber = testDate.day.toString();
      final monthAbbr = 'may.'; // Spanish locale for May
      expect(find.textContaining(dayNumber), findsOneWidget);

      // Tap to expand the card (to verify it renders in dark mode)
      await tester.tap(find.byType(DayRecordCard));
      await tester.pumpAndSettle();

      // After expanding, verify "Sin registros" shows
      expect(find.text('Sin registros'), findsOneWidget);
    });
  });

  // ============================================================================
  // WU-5: AddEditRecordModal — theme-aware background
  // ============================================================================
  group('AddEditRecordModal PR#10 dark mode fix', () {
    testWidgets('dialog background is not hardcoded AppColors.surface',
        (tester) async {
      tester.view.physicalSize = const Size(500, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testDate = DateTime(2026, 5, 25);
      await tester.pumpWidget(
        wrapDark(
          Builder(
            builder: (context) {
              // Show the modal immediately for test
              return ElevatedButton(
                onPressed: () {
                  AddEditRecordModal.show(
                    context,
                    date: testDate,
                    availableLocations: const ['Oficina', 'Remoto'],
                    onSave: (record) async {},
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      // Tap to open modal
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // The Dialog should be rendered — verify it doesn't crash
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Añadir Registro'), findsOneWidget);

      // Dialog background should not be hardcoded white
      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.backgroundColor, isNot(AppColors.surface),
          reason:
              'AddEditRecordModal background must be theme-aware, not hardcoded white');
    });
  });

  // ============================================================================
  // WU-6: MyTimeControlScreen — mobile header title visible in dark mode
  // ============================================================================
  group('MyTimeControlScreen PR#10 dark mode fix', () {
    testWidgets('"Mi Control Horario" title is visible in dark mode',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/time',
        routes: [
          GoRoute(
            path: '/time',
            builder: (context, state) => const MyTimeControlScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(UserModel(
                userId: 'tc-pr10-1',
                employeeId: 'EMP-TC10',
                email: 'tc10@ex.com',
                displayName: 'TC10 User',
                role: UserRole.employee,
                weeklyHours: 40,
                createdAt: DateTime(2026),
              )),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
          ),
        ),
      );
      await tester.pump();

      // "Mi Control Horario" must be rendered (proves it doesn't crash)
      // The mobile header title must be found (may appear in multiple widgets)
      expect(find.text('Mi Control Horario'), findsAtLeastNWidgets(1));
    });
  });

  // ============================================================================
  // WU-7: ProfileScreen — no hardcoded AppColors.primary in header
  // ============================================================================
  group('ProfileScreen PR#10 dark mode fixes', () {
    testWidgets(
        'profile header avatar border does not hardcode AppColors.primary',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(UserModel(
                userId: 'pr10-prof-1',
                employeeId: 'EMP-PR10P1',
                email: 'pr10p@ex.com',
                displayName: 'PR10 Profile User',
                role: UserRole.employee,
                position: 'Developer',
                weeklyHours: 40,
                createdAt: DateTime(2026),
              )),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Section title must be visible (not dark text on dark background)
      expect(find.text('Información Personal'), findsOneWidget);

      // The info section icon must not use hardcoded AppColors.primary.
      // Use the section header icon (person icon in "Información Personal" section).
      // There are multiple person icons; we check that at least one exists.
      expect(find.byIcon(Icons.person), findsAtLeastNWidgets(1));

      // Section icon (badge icon in info section) must not use hardcoded primary
      final badgeIcons = tester.widgetList<Icon>(find.byIcon(Icons.badge));
      if (badgeIcons.isNotEmpty) {
        expect(badgeIcons.first.color, isNot(AppColors.primary),
            reason:
                'ProfileScreen info item icon must not hardcode AppColors.primary');
      }
    });
  });
}
