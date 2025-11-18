import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Pantallas de autenticación
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

// Pantallas de dashboard
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/profile_screen.dart';
import '../../features/dashboard/presentation/screens/settings_screen.dart';

// Pantallas de admin
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/employees_list_screen.dart';
import '../../features/admin/presentation/screens/employee_detail_screen.dart';

/// Sistema de navegación de la aplicación
/// 
/// Usa go_router para manejar las rutas de forma declarativa.
/// En Fase 2 se añadirán guards de autenticación y rutas protegidas.
class AppRouter {
  // Prevenir instanciación
  AppRouter._();

  // ============================================================================
  // ROUTE NAMES (Nombres de rutas)
  // ============================================================================

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String admin = '/admin';
  static const String adminEmployees = '/admin/employees';
  static const String adminEmployeeDetail = '/admin/employees/:id';

  // ============================================================================
  // ROUTER CONFIGURATION
  // ============================================================================

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    
    // TODO [FASE-2]: Implementar redirect para auth
    // redirect: (context, state) {
    //   final isAuthenticated = ref.read(authProvider).isAuthenticated;
    //   final isGoingToLogin = state.location == login;
    //   
    //   if (!isAuthenticated && !isGoingToLogin) {
    //     return login;
    //   }
    //   if (isAuthenticated && isGoingToLogin) {
    //     return dashboard;
    //   }
    //   return null;
    // },
    
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
        ],
      ),
    ],

    // ========================================================================
    // ERROR HANDLING
    // ========================================================================
    errorBuilder: (context, state) => _ErrorScreen(
      error: state.error.toString(),
    ),
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
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ruta no encontrada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                error,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
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

