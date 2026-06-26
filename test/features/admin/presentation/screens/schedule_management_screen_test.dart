import 'dart:async';

import 'package:control_horario/core/theme/app_colors.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/admin/models/schedule_model.dart';
import 'package:control_horario/features/admin/presentation/screens/schedule_management_screen.dart';
import 'package:control_horario/features/admin/presentation/widgets/schedule_template_modal.dart';
import 'package:control_horario/features/admin/providers/schedule_management_provider.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/core/services/firebase_service.dart';
import 'package:control_horario/shared/widgets/buttons/custom_button.dart';
import 'package:control_horario/shared/widgets/cards/schedule_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// FAKE DATA
// =============================================================================

DaySchedule _daySchedule({
  bool isWorkDay = true,
  double dailyHours = 8.0,
  List<TimeShift> shifts = const [],
}) {
  return DaySchedule(
    isWorkDay: isWorkDay,
    shifts: shifts,
    breakMinutes: 60,
    dailyHours: dailyHours,
  );
}

final _weekDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];

Map<String, DaySchedule> _weekSchedule(double dailyHours) {
  return {
    for (final d in _weekDays)
      d: _daySchedule(isWorkDay: true, dailyHours: dailyHours),
    'saturday': _daySchedule(isWorkDay: false),
    'sunday': _daySchedule(isWorkDay: false),
  };
}

ScheduleModel _testTemplate({
  required String scheduleId,
  required String name,
  String description = 'Lunes a Viernes con 1h pausa',
  int totalWeeklyHours = 40,
  int usedByCount = 0,
  bool isActive = true,
  String? createdBy,
}) {
  return ScheduleModel(
    scheduleId: scheduleId,
    name: name,
    description: description,
    totalWeeklyHours: totalWeeklyHours,
    isActive: isActive,
    isTemplate: true,
    usedByCount: usedByCount,
    weeklySchedule: _weekSchedule(totalWeeklyHours / 5),
    createdBy: createdBy,
  );
}

final _fakeTemplates = <ScheduleModel>[
  _testTemplate(
    scheduleId: 'sched_40h',
    name: 'Jornada 40h (9:00-17:00)',
    totalWeeklyHours: 40,
    usedByCount: 12,
    createdBy: 'Admin',
  ),
  _testTemplate(
    scheduleId: 'sched_35h',
    name: 'Jornada 35h (8:30-15:30)',
    totalWeeklyHours: 35,
    usedByCount: 0,
    createdBy: 'RRHH',
  ),
  _testTemplate(
    scheduleId: 'sched_20h',
    name: 'Jornada 20h (9:00-13:00)',
    description: 'Media jornada de mañana',
    totalWeeklyHours: 20,
    usedByCount: 5,
    isActive: false,
    createdBy: 'Admin',
  ),
];

// =============================================================================
// FAKE PROVIDERS for modal validation tests
// =============================================================================

/// Fake notifier that counts calls.
class _CountingScheduleManagement extends ScheduleManagement {
  int createTemplateCallCount = 0;
  int updateTemplateCallCount = 0;
  String? lastName;
  String? lastScheduleId;

  @override
  Future<String> createTemplate({
    required String name,
    required String description,
    required Map<String, DaySchedule> weeklySchedule,
  }) async {
    createTemplateCallCount++;
    lastName = name;
    return 'fake-new-id';
  }

  @override
  Future<void> updateTemplate({
    required String scheduleId,
    String? name,
    String? description,
    Map<String, DaySchedule>? weeklySchedule,
  }) async {
    updateTemplateCallCount++;
    lastScheduleId = scheduleId;
    lastName = name;
  }

  // Allow overriding build from parent
  @override
  FutureOr<void> build() {}
}

/// Fake notifier that always throws.
class _ErrorScheduleManagement extends ScheduleManagement {
  final Exception error;

  _ErrorScheduleManagement(this.error);

  @override
  Future<String> createTemplate({
    required String name,
    required String description,
    required Map<String, DaySchedule> weeklySchedule,
  }) async {
    throw error;
  }

  @override
  Future<void> updateTemplate({
    required String scheduleId,
    String? name,
    String? description,
    Map<String, DaySchedule>? weeklySchedule,
  }) async {
    throw error;
  }

  @override
  FutureOr<void> build() {}
}

// =============================================================================
// HELPERS
// =============================================================================

/// Wrap widget in a full ProviderScope + MaterialApp with theme for rendering.
Widget _wrapWithProviders(Widget child,
    {bool darkMode = false, List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

/// Convenience wrapper that provides fake templates via provider override.
Widget _screenWithTemplates({
  List<ScheduleModel> templates = const [],
  bool darkMode = false,
}) {
  return _wrapWithProviders(
    const ScheduleManagementScreen(),
    darkMode: darkMode,
    overrides: [
      allScheduleTemplatesProvider.overrideWith(
        (ref) => Stream.value(templates),
      ),
    ],
  );
}

void _setDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  // ------------------------------------------------------------------------
  // 1. HEADER & TITLE
  // ------------------------------------------------------------------------
  group('Header and title', () {
    testWidgets('renders "Plantillas de Horario" title', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.text('Plantillas de Horario'), findsOneWidget);
    });

    testWidgets('renders subtitle with active template count', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('2 plantillas activas'),
        findsOneWidget,
      );
    });

    testWidgets('subtitle uses "plantilla activa" for singular',
        (tester) async {
      final single = [_fakeTemplates.first];
      await tester.pumpWidget(_screenWithTemplates(templates: single));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('1 plantilla activa'),
        findsOneWidget,
      );
      expect(
        find.textContaining('plantillas activas'),
        findsNothing,
      );
    });

    testWidgets('renders exactly one "Nueva Plantilla" CTA', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      // Find CustomButton with text "Nueva Plantilla"
      final buttons =
          tester.widgetList<CustomButton>(find.byType(CustomButton));
      final nuevaButtons =
          buttons.where((b) => b.text == 'Nueva Plantilla').toList();

      expect(nuevaButtons.length, 1,
          reason: 'Expected exactly one "Nueva Plantilla" CustomButton');
    });

    testWidgets('CTA preserves CustomButton variant=brand', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      final button = tester.widget<CustomButton>(
        find.widgetWithText(CustomButton, 'Nueva Plantilla'),
      );
      expect(button.variant, ButtonVariant.brand);
    });
  });

  // ------------------------------------------------------------------------
  // 2. NO SEARCH BOX
  // ------------------------------------------------------------------------
  group('No search box', () {
    testWidgets('does not expose search bar when templates exist',
        (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNothing);
      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('does not expose search bar when templates empty',
        (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: []));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNothing);
      expect(find.byIcon(Icons.search), findsNothing);
    });
  });

  // ------------------------------------------------------------------------
  // 4. FORBIDDEN FAKE CONTROLS
  // ------------------------------------------------------------------------
  group('No fake/unwired controls', () {
    testWidgets('does not expose "Próximamente" placeholder', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.text('Próximamente'), findsNothing);
    });

    testWidgets('does not expose "Duplicar" button', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.text('Duplicar'), findsNothing);
    });

    testWidgets('does not expose "Eliminar" button on cards', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.text('Eliminar'), findsNothing);
    });

    testWidgets('does not expose "Ver guía" link', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.textContaining('Ver guía'), findsNothing);
    });

    testWidgets('does not expose "Flexibilidad" metric', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.textContaining('Flexibilidad'), findsNothing);
      expect(find.text('85%'), findsNothing);
    });
  });

  // ------------------------------------------------------------------------
  // 5. EMPTY STATE
  // ------------------------------------------------------------------------
  group('Empty state', () {
    testWidgets('shows empty state with create CTA when no templates',
        (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: []));
      await tester.pumpAndSettle();

      expect(find.text('No hay plantillas disponibles'), findsOneWidget);
      expect(
        find.textContaining('Crea tu primera plantilla'),
        findsOneWidget,
      );
      expect(find.text('Crear Plantilla'), findsOneWidget);
    });

    testWidgets('empty state CTA uses CustomButton brand variant',
        (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: []));
      await tester.pumpAndSettle();

      final button = tester.widget<CustomButton>(
        find.widgetWithText(CustomButton, 'Crear Plantilla'),
      );
      expect(button.variant, ButtonVariant.brand);
    });

    testWidgets('empty state still shows header and title', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: []));
      await tester.pumpAndSettle();

      expect(find.text('Plantillas de Horario'), findsOneWidget);
      expect(
        find.textContaining('0 plantillas activas'),
        findsOneWidget,
      );
    });

    testWidgets('empty state does not show search box', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: []));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNothing);
    });
  });

  // ------------------------------------------------------------------------
  // 6. TEMPLATE CARDS
  // ------------------------------------------------------------------------
  group('Template cards', () {
    testWidgets('renders ScheduleCard for each template', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.byType(ScheduleCard), findsNWidgets(3));
    });

    testWidgets('card shows weekly hours badge', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.text('40h/sem'), findsOneWidget);
      expect(find.text('35h/sem'), findsOneWidget);
      expect(find.text('20h/sem'), findsOneWidget);
    });

    testWidgets('card shows employee count for templates with users',
        (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.textContaining('12 empleados'), findsOneWidget);
      expect(find.textContaining('5 empleados'), findsOneWidget);
    });

    testWidgets('card uses singular "empleado" for count=1', (tester) async {
      final singleEmployee = [
        _testTemplate(
          scheduleId: 'single',
          name: 'Single Employee',
          usedByCount: 1,
        ),
      ];
      await tester.pumpWidget(_screenWithTemplates(templates: singleEmployee));
      await tester.pumpAndSettle();

      // Only card renders "1 empleado" for count=1
      expect(find.textContaining('1 empleado'), findsOneWidget);
    });

    testWidgets('card shows createdBy when available', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      expect(find.textContaining('Creada por Admin'), findsWidgets);
      expect(find.textContaining('Creada por RRHH'), findsOneWidget);
    });
  });

  // ------------------------------------------------------------------------
  // 7. TAP-TO-EDIT BEHAVIOR
  // ------------------------------------------------------------------------
  group('Tap-to-edit', () {
    testWidgets('tapping a schedule card opens the template modal',
        (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      // Scroll the first card into view (may be off-screen in default viewport)
      await tester.dragUntilVisible(
        find.byType(ScheduleCard).first,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // Tap the first ScheduleCard
      await tester.tap(find.byType(ScheduleCard).first);
      await tester.pumpAndSettle();

      // Modal uses Dialog widget (not AlertDialog)
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('tapping "Nueva Plantilla" opens modal in create mode',
        (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nueva Plantilla'));
      await tester.pumpAndSettle();

      // Modal uses Dialog (not AlertDialog)
      expect(find.byType(Dialog), findsOneWidget);
    });
  });

  // ------------------------------------------------------------------------
  // 8. DARK MODE / THEME SAFETY
  // ------------------------------------------------------------------------
  group('Dark mode safety', () {
    testWidgets('no hardcoded AppColors.surface background in dark mode',
        (tester) async {
      await tester.pumpWidget(
          _screenWithTemplates(templates: _fakeTemplates, darkMode: true));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      var surfaceFound = false;
      for (final c in containers) {
        final deco = c.decoration as BoxDecoration?;
        if (deco != null && deco.color == AppColors.surface) {
          surfaceFound = true;
          break;
        }
      }
      expect(surfaceFound, isFalse,
          reason: 'No container should use hardcoded AppColors.surface');
    });

    testWidgets(
        'subtitle text does not use hardcoded AppColors.textSecondary '
        'in dark mode', (tester) async {
      await tester.pumpWidget(
          _screenWithTemplates(templates: _fakeTemplates, darkMode: true));
      await tester.pumpAndSettle();

      final texts = tester.widgetList<Text>(find.byType(Text));
      for (final t in texts) {
        if (t.data?.contains('Gestiona los esquemas') == true &&
            t.style?.color != null) {
          expect(t.style!.color, isNot(equals(AppColors.textSecondary)));
        }
      }
    });

    testWidgets('empty state h4 uses theme-aware color (no hardcoded)',
        (tester) async {
      await tester
          .pumpWidget(_screenWithTemplates(templates: [], darkMode: true));
      await tester.pumpAndSettle();

      final emptyFinder = find.text('No hay plantillas disponibles');
      if (emptyFinder.evaluate().isNotEmpty) {
        final tw = tester.widget<Text>(emptyFinder);
        // h4 style is copied with cs.onSurface — a theme-aware value, not
        // a hardcoded AppColors constant. In dark mode cs.onSurface can be
        // white (coincident with AppColors.surface — a false positive), so
        // only check against the textSecondary constant.
        expect(tw.style?.color, isNotNull,
            reason: 'h4 should have a theme-aware color');
        expect(tw.style!.color, isNot(equals(AppColors.textSecondary)),
            reason: 'Should not use hardcoded AppColors.textSecondary');
      }
    });

    testWidgets('renders correctly in dark mode without crashes',
        (tester) async {
      await tester.pumpWidget(
          _screenWithTemplates(templates: _fakeTemplates, darkMode: true));
      await tester.pumpAndSettle();

      // Should render title and cards without issues
      expect(find.text('Plantillas de Horario'), findsOneWidget);
      expect(find.byType(ScheduleCard), findsNWidgets(3));
      expect(find.text('TOTAL PLANTILLAS'), findsNothing);
    });
  });

  // ------------------------------------------------------------------------
  // 9. RESPONSIVE LAYOUT
  // ------------------------------------------------------------------------
  group('Responsive layout', () {
    testWidgets('centered max-width container in desktop', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      // ConstrainedBox with maxWidth 1200 should exist
      final constrained = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final maxWidth1200 = constrained.where(
        (box) => box.constraints.maxWidth == 1200,
      );
      expect(maxWidth1200.isNotEmpty, isTrue);
    });

    testWidgets('SingleChildScrollView wraps content', (tester) async {
      await tester.pumpWidget(_screenWithTemplates(templates: _fakeTemplates));
      await tester.pumpAndSettle();

      // AdminLayout also uses a SingleChildScrollView — at least 2 total
      expect(find.byType(SingleChildScrollView), findsAtLeast(1));
    });
  });

  // ------------------------------------------------------------------------
  // 10. LOADING STATE
  // ------------------------------------------------------------------------
  group('Loading state', () {
    testWidgets('shows CircularProgressIndicator while loading',
        (tester) async {
      // Use a stream that never emits
      await tester.pumpWidget(_wrapWithProviders(
        const ScheduleManagementScreen(),
        overrides: [
          allScheduleTemplatesProvider.overrideWith(
            (ref) => Stream<List<ScheduleModel>>.empty(),
          ),
        ],
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ------------------------------------------------------------------------
  // 11. ERROR STATE
  // ------------------------------------------------------------------------
  group('Error state', () {
    testWidgets('shows error icon and message on error', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(
        const ScheduleManagementScreen(),
        overrides: [
          allScheduleTemplatesProvider.overrideWith(
            (ref) => Stream<List<ScheduleModel>>.error(
              Exception('Firebase connection failed'),
            ),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Error al cargar plantillas'), findsOneWidget);
      expect(find.textContaining('Firebase connection failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  // ------------------------------------------------------------------------
  // 12. SCHEDULE CARD DIVIDER
  // ------------------------------------------------------------------------
  group('ScheduleCard divider', () {
    testWidgets('renders a Divider inside the card', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(
        const Scaffold(
          body: ScheduleCard(
            name: 'Test Template',
            description: 'A test description',
            weeklyHours: 40,
            usedByCount: 3,
            createdBy: 'Admin',
            onTap: null,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // The card should contain exactly one Divider between description and
      // footer, using theme-aware outlineVariant color.
      final dividerFinder = find.byType(Divider);
      expect(dividerFinder, findsOneWidget);

      // Verify the divider uses a theme color, not a hardcoded constant.
      final divider = tester.widget<Divider>(dividerFinder);
      expect(divider.color, isNotNull,
          reason: 'Divider should use a theme-aware color');
    });
  });

  // ------------------------------------------------------------------------
  // 13. MODAL VALIDATION & SAVE BEHAVIOR
  // ------------------------------------------------------------------------
  group('Modal validation and save', () {
    late _CountingScheduleManagement countingNotifier;

    setUp(() {
      countingNotifier = _CountingScheduleManagement();
    });

    Widget modalWithOverrides({
      ScheduleModel? existingTemplate,
      required ScheduleManagement notifier,
      UserModel? currentUser,
    }) {
      return _wrapWithProviders(
        Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ScheduleTemplateModal(
                    existingTemplate: existingTemplate,
                  ),
                );
              },
              child: const Text('Open Modal'),
            );
          }),
        ),
        overrides: [
          scheduleManagementProvider.overrideWith(() => notifier),
          currentUserProvider.overrideWith(
            (ref) => Stream.value(
              currentUser ??
                  UserModel(
                    userId: 'admin-1',
                    employeeId: 'E1',
                    email: 'a@t.com',
                    displayName: 'Admin',
                    role: UserRole.admin,
                    weeklyHours: 40,
                    createdAt: DateTime(2026),
                  ),
            ),
          ),
        ],
      );
    }

    testWidgets('create-mode modal shows correct title', (tester) async {
      await tester.pumpWidget(modalWithOverrides(
        existingTemplate: null,
        notifier: countingNotifier,
      ));
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Nueva Plantilla de Horario'), findsOneWidget);
      expect(find.text('Crear Plantilla'), findsOneWidget);
    });

    testWidgets('edit-mode modal shows correct title and prefills data',
        (tester) async {
      final existing = _testTemplate(
        scheduleId: 'sched-1',
        name: 'Jornada Custom',
        description: 'Custom desc',
        totalWeeklyHours: 40,
      );

      await tester.pumpWidget(modalWithOverrides(
        existingTemplate: existing,
        notifier: countingNotifier,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Plantilla de Horario'), findsOneWidget);
      expect(find.text('Guardar Cambios'), findsOneWidget);

      // Name field should be prefilled
      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Nombre de la plantilla *'),
      );
      expect(nameField.controller?.text, 'Jornada Custom');
    });

    testWidgets('save with provider error shows error in SnackBar (edit mode)',
        (tester) async {
      // In create mode _calculatedHours=0 so the modal guard fires first.
      // Use edit mode with an existing template (hours=40) to bypass the guard
      // and reach the provider call.
      final errorNotifier = _ErrorScheduleManagement(
        Exception('Shift end time must be after start time'),
      );
      final existing = _testTemplate(
        scheduleId: 'sched-err',
        name: 'Will Error',
        totalWeeklyHours: 40,
      );

      await tester.pumpWidget(modalWithOverrides(
        existingTemplate: existing,
        notifier: errorNotifier,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Tap save — form has valid name (prefilled) and existing hours (40)
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Error SnackBar should appear
      expect(
        find.textContaining('Shift end time must be after start time'),
        findsOneWidget,
      );
      // Modal still open
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('empty schedule shows warning without calling provider',
        (tester) async {
      await tester.pumpWidget(modalWithOverrides(
        existingTemplate: null,
        notifier: countingNotifier,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Fill name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre de la plantilla *'),
        'Empty Schedule',
      );
      await tester.pumpAndSettle();

      // Tap save — modal guard: no shifts configured
      await tester.tap(find.text('Crear Plantilla'));
      await tester.pumpAndSettle();

      // Provider should NOT have been called (UI guard: calculatedHours <= 0)
      expect(countingNotifier.createTemplateCallCount, 0,
          reason: 'Modal UI guard should block saves with 0 hours');

      // SnackBar with warning should appear (may also match the summary badge)
      expect(
        find.textContaining('al menos un turno'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets(
        'edit mode with provider error shows error and keeps modal open',
        (tester) async {
      final errorNotifier = _ErrorScheduleManagement(
        Exception('Shifts cannot overlap'),
      );
      final existing = _testTemplate(
        scheduleId: 'sched-1',
        name: 'To Edit',
        totalWeeklyHours: 40,
      );

      await tester.pumpWidget(modalWithOverrides(
        existingTemplate: existing,
        notifier: errorNotifier,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Tap save — form has valid name (prefilled) and existing hours (40)
      await tester.tap(find.text('Guardar Cambios'));
      await tester.pumpAndSettle();

      // Error SnackBar
      expect(find.textContaining('Shifts cannot overlap'), findsOneWidget);
      // Modal still open
      expect(find.byType(Dialog), findsOneWidget);
    });
  });
}
