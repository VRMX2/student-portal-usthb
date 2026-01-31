import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/main_screen.dart';
import '../screens/modules_screen.dart';
import '../screens/announcements_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/create_announcement_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/user_management_screen.dart';
import '../screens/academic_history_screen.dart';
import '../models/student_model.dart';

GoRouter createRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authService,
    redirect: (context, state) {
      final isLoggedIn = authService.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';
      final isForgotPassword = state.uri.toString() == '/forgot-password';

      // Allow access to auth-related pages when not logged in
      if (!isLoggedIn && (isLoggingIn || isRegistering || isForgotPassword)) {
        return null;
      }

      // Redirect to login if not authenticated
      if (!isLoggedIn) return '/login';
      
      // Redirect to home if already logged in and trying to access login
      if (isLoggedIn && (isLoggingIn || isRegistering)) return '/';

      return null;
    },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
      routes: [
         GoRoute(
          path: 'modules',
          builder: (context, state) => const ModulesScreen(),
        ),
        GoRoute(
          path: 'announcements',
          builder: (context, state) => const AnnouncementsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(
          path: 'create-announcement',
          builder: (context, state) => const CreateAnnouncementScreen(),
        ),
        GoRoute(
          path: 'user-management',
          builder: (context, state) => const UserManagementScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/academic-history',
      builder: (context, state) => const AcademicHistoryScreen(),
    ),
  ],
  );
}

