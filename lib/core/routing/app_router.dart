import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/nutrition/presentation/screens/food_search_screen.dart';
import '../../features/nutrition/presentation/screens/log_meal_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final client = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final session = client.auth.currentSession;
      final isAuth = session != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuth && !isAuthRoute) return '/auth/login';
      if (isAuth && isAuthRoute) return '/dashboard';
      return null;
    },
    refreshListenable: _AuthChangeNotifier(client),
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (_, __) => const SignupScreen(),
      ),
      GoRoute(
        path: '/auth/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/food-search',
        builder: (_, state) {
          final mealType =
              state.uri.queryParameters['mealType'] ?? 'other';
          return FoodSearchScreen(mealType: mealType);
        },
      ),
      GoRoute(
        path: '/log-meal',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return LogMealScreen(foodData: extra);
        },
      ),
    ],
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._client) {
    _client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  final SupabaseClient _client;
}
