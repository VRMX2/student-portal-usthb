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

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final authService = context.read<AuthService>();
    final isLoggedIn = authService.isAuthenticated;
    final isLoggingIn = state.uri.toString() == '/login';

    if (!isLoggedIn && !isLoggingIn) return '/login';
    if (isLoggedIn && isLoggingIn) return '/';

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
      ],
    ),
  ],
);
