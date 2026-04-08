import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import 'auth_notifier.dart';

// Pantallas de autenticación
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

// Pantallas de dashboard
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/calendar_screen.dart';
import '../../features/dashboard/presentation/screens/my_time_control_screen.dart';
import '../../features/dashboard/presentation/screens/profile_screen.dart';
import '../../features/dashboard/presentation/screens/settings_screen.dart';

// Pantallas de admin
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_profile_screen.dart';
import '../../features/admin/presentation/screens/employees_list_screen.dart';
import '../../features/admin/presentation/screens/employee_detail_screen.dart';
import '../../features/admin/presentation/screens/schedule_management_screen.dart';
import '../../features/admin/presentation/screens/calendar_management_screen.dart';

/// Sistema de navegación de la aplicación
///
/// Usa go_router para manejar las rutas de forma declarativa.
/// Incluye protección de rutas basada en autenticación.
class AppRouter {
  // Prevenir instanciación
  AppRouter._();

  // Instancia del AuthNotifier para go_router
  static final _authNotifier = AuthNotifier(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );

  // ============================================================================
  // ROUTE NAMES (Nombres de rutas)
  // ============================================================================

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String calendar = '/calendar';
  static const String myTimeControl = '/my-time-control';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String admin = '/admin';
  static const String adminProfile = '/admin/profile';
  static const String adminEmployees = '/admin/employees';
  static const String adminEmployeeDetail = '/admin/employees/:id';
  static const String adminSchedules = '/admin/schedules';
  static const String adminCalendars = '/admin/calendars';

  // ============================================================================
  // ROUTER CONFIGURATION
  // ============================================================================

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: _authNotifier,

    // Redirect para proteger rutas
    redirect: (context, state) {
      final isAuthenticated = _authNotifier.isAuthenticated;
      final isGoingToLogin = state.matchedLocation == login;
      final isGoingToSplash = state.matchedLocation == splash;

      // Si no está autenticado y no va a login o splash, redirigir a login
      if (!isAuthenticated && !isGoingToLogin && !isGoingToSplash) {
        return login;
      }

      // Protección de rutas admin: solo usuarios con rol admin pueden acceder a /admin*
      // Si el rol aún no ha cargado (_isAdmin = false por defecto), se deniega acceso
      // hasta que Firestore confirme el rol, momento en que AuthNotifier notifica y
      // go_router re-evalúa este redirect.
      final isGoingToAdmin = state.matchedLocation.startsWith('/admin');
      if (isAuthenticated && isGoingToAdmin && !_authNotifier.isAdmin) {
        if (_authNotifier.isLoadingRole) return null;
        return dashboard;
      }

      // NOTA: Ya NO redirigimos automáticamente desde login cuando está autenticado
      // Dejamos que LoginScreen maneje la redirección basada en el rol del usuario
      // Esto permite que admin vaya a /admin y employee a /dashboard

      return null; // No redirigir
    },

    routes: [
      // ========================================================================
      // SPLASH SCREEN
      // ========================================================================
      GoRoute(
        path: splash,
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),

      // ========================================================================
      // AUTH ROUTES
      // ========================================================================
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),

      // ========================================================================
      // DASHBOARD (Empleado)
      // ========================================================================
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const DashboardScreen(),
        ),
      ),

      // ========================================================================
      // CALENDARIO LABORAL (Empleado)
      // ========================================================================
      GoRoute(
        path: calendar,
        name: 'calendar',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const CalendarScreen(),
        ),
      ),

      // ========================================================================
      // MI CONTROL HORARIO
      // ========================================================================
      GoRoute(
        path: myTimeControl,
        name: 'my-time-control',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const MyTimeControlScreen(),
        ),
      ),

      // ========================================================================
      // PROFILE
      // ========================================================================
      GoRoute(
        path: profile,
        name: 'profile',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),

      // ========================================================================
      // SETTINGS
      // ========================================================================
      GoRoute(
        path: settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),

      // ========================================================================
      // ADMIN ROUTES
      // ========================================================================
      GoRoute(
        path: admin,
        name: 'admin',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const AdminDashboardScreen(),
        ),
        routes: [
          // Perfil del administrador
          GoRoute(
            path: 'profile',
            name: 'admin-profile',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const AdminProfileScreen(),
            ),
          ),
          // Lista de empleados
          GoRoute(
            path: 'employees',
            name: 'admin-employees',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const EmployeesListScreen(),
            ),
            routes: [
              // Detalle de empleado
              GoRoute(
                path: ':id',
                name: 'admin-employee-detail',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return _buildPageWithTransition(
                    context: context,
                    state: state,
                    child: EmployeeDetailScreen(employeeId: id),
                  );
                },
              ),
            ],
          ),
          // Gestión de horarios
          GoRoute(
            path: 'schedules',
            name: 'admin-schedules',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const ScheduleManagementScreen(),
            ),
          ),
          // Gestión de calendarios laborales
          GoRoute(
            path: 'calendars',
            name: 'admin-calendars',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const CalendarManagementScreen(),
            ),
          ),
        ],
      ),
    ],

    // ========================================================================
    // ERROR HANDLING
    // ========================================================================
    errorBuilder: (context, state) =>
        _ErrorScreen(error: state.error.toString()),
  );

  // ============================================================================
  // PAGE TRANSITIONS
  // ============================================================================

  static Page<dynamic> _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade transition
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}

// ==============================================================================
// ERROR SCREEN
// ==============================================================================

class _ErrorScreen extends StatelessWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Ruta no encontrada',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                error,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.splash),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
