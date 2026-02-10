import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/dashboard_screen.dart';
import '../../features/checklist/presentation/checklist_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/guests/presentation/guests_screen.dart';
import '../../features/timeline/presentation/timeline_screen.dart';
import '../../features/seating/presentation/seating_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/wedding/presentation/screens/create_wedding_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final isAuthRoute = state.uri.toString() == '/login' ||
          state.uri.toString() == '/register';
      final isSplash = state.uri.toString() == '/splash';
      final isOnboarding = state.uri.toString() == '/onboarding';

      if (isSplash || isOnboarding) return null;
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/checklist', builder: (_, __) => const ChecklistScreen()),
          GoRoute(path: '/budget', builder: (_, __) => const BudgetScreen()),
          GoRoute(path: '/guests', builder: (_, __) => const GuestsScreen()),
          GoRoute(path: '/timeline', builder: (_, __) => const TimelineScreen()),
        ],
      ),
      GoRoute(path: '/seating', builder: (_, __) => const SeatingScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/wedding/create', builder: (_, __) => const CreateWeddingScreen()),
    ],
  );
});
