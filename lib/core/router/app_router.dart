import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/checklist/presentation/checklist_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/guests/presentation/guests_screen.dart';
import '../../features/timeline/presentation/timeline_screen.dart';
import '../../features/seating/presentation/seating_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/wedding/presentation/screens/create_wedding_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuth = session != null;
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      if (!isAuth && !isOnAuthPage) return '/login';
      if (isAuth && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const _DashboardTab(),
          ),
          GoRoute(
            path: '/checklist',
            builder: (context, state) => const ChecklistScreen(),
          ),
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/guests',
            builder: (context, state) => const GuestsScreen(),
          ),
          GoRoute(
            path: '/timeline',
            builder: (context, state) => const TimelineScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/seating',
        builder: (context, state) => const SeatingScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/wedding/create',
        builder: (context, state) => const CreateWeddingScreen(),
      ),
    ],
  );
});

/// The dashboard tab content (home)
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    // Imported separately to keep route file clean
    return const _DashboardContent();
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink(); // Replaced by HomeScreen body
  }
}
