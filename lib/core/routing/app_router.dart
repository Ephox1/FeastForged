import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/edit_profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/providers/profile_provider.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/household/presentation/screens/household_members_screen.dart';
import '../../features/nutrition/presentation/screens/create_custom_food_screen.dart';
import '../../features/nutrition/presentation/screens/food_search_screen.dart';
import '../../features/nutrition/presentation/screens/log_meal_screen.dart';
import '../../features/planner/presentation/screens/weekly_planner_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/recipes/presentation/screens/recipe_editor_screen.dart';
import '../../features/recipes/presentation/screens/recipe_detail_screen.dart';
import '../../features/recipes/presentation/screens/recipe_list_screen.dart';
import '../../features/shopping/presentation/screens/shopping_lists_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final client = Supabase.instance.client;

  return GoRouter(
    initialLocation: '/app/dashboard',
    redirect: (context, state) {
      final session = client.auth.currentSession;
      final isAuth = session != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuth && !isAuthRoute) return '/auth/login';
      if (isAuth && isAuthRoute) return '/app/dashboard';
      return null;
    },
    refreshListenable: _AuthChangeNotifier(client),
    routes: [
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: '/auth/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/app/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/app/planner',
            builder: (_, state) {
              final extra = state.extra;
              final query = state.uri.queryParameters;
              final seedRecipeId = query['seedRecipeId'];
              final seedRecipeTitle = query['seedRecipeTitle'];
              return WeeklyPlannerScreen(
                recipeToSeed: extra is Map<String, dynamic>
                    ? extra
                    : seedRecipeId != null
                    ? {'id': seedRecipeId, 'title': seedRecipeTitle}
                    : null,
              );
            },
          ),
          GoRoute(
            path: '/app/recipes',
            builder: (_, __) => const RecipeListScreen(),
          ),
          GoRoute(
            path: '/app/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) {
          final profile = ref.read(currentProfileProvider).valueOrNull;
          if (profile == null) return const OnboardingScreen();
          return EditProfileScreen(profile: profile);
        },
      ),
      GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
      GoRoute(
        path: '/household',
        builder: (_, __) => const HouseholdMembersScreen(),
      ),
      GoRoute(
        path: '/shopping',
        builder: (_, __) => const ShoppingListsScreen(),
      ),
      GoRoute(
        path: '/recipes/new',
        builder: (_, __) => const RecipeEditorScreen(),
      ),
      GoRoute(
        path: '/recipes/:recipeId',
        builder: (_, state) => RecipeDetailScreen(
          recipeId: state.pathParameters['recipeId']!,
          initialRecipe: state.extra as dynamic,
        ),
      ),
      GoRoute(
        path: '/food-search',
        builder: (_, state) {
          final mealType = state.uri.queryParameters['mealType'] ?? 'other';
          return FoodSearchScreen(mealType: mealType);
        },
      ),
      GoRoute(
        path: '/food-search/custom',
        builder: (_, state) {
          final mealType = state.uri.queryParameters['mealType'] ?? 'other';
          return CreateCustomFoodScreen(mealType: mealType);
        },
      ),
      GoRoute(
        path: '/log-meal',
        builder: (_, state) {
          final extra = state.extra;
          return LogMealScreen(
            foodData: extra is Map<String, dynamic> ? extra : null,
          );
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
