import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../recipes/domain/recipe.dart';
import '../../recipes/providers/recipe_provider.dart';
import '../data/nutrition_repository.dart';
import '../domain/meal_log_entry.dart';

const _uuid = Uuid();
const _recentRecipesStorageKey = 'recent_recipes';

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (_) => const NutritionRepository(),
);

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((_) async {
  return SharedPreferences.getInstance();
});

class _FoodSearchNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async => [];

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(nutritionRepositoryProvider).searchRecipes(query.trim()),
    );
  }

  void clear() => state = const AsyncData([]);
}

final foodSearchProvider =
    AsyncNotifierProvider<_FoodSearchNotifier, List<Recipe>>(
      _FoodSearchNotifier.new,
    );

final popularFoodsProvider = FutureProvider<List<Recipe>>((ref) async {
  return ref.watch(nutritionRepositoryProvider).fetchPopularRecipes();
});

class _RecentFoodsNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    final storedRecipes =
        preferences.getStringList(_recentRecipesStorageKey) ?? const [];

    return storedRecipes
        .map(
          (recipeJson) => Recipe.fromJson(
            jsonDecode(recipeJson) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> addRecipe(Recipe recipe) async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    final current = List<Recipe>.from(state.valueOrNull ?? const <Recipe>[]);

    current.removeWhere((item) => item.id == recipe.id);
    current.insert(0, recipe);

    final trimmed = current.take(8).toList(growable: false);
    await preferences.setStringList(
      _recentRecipesStorageKey,
      trimmed.map((item) => jsonEncode(item.toJson())).toList(),
    );

    state = AsyncData(trimmed);
  }
}

final recentFoodsProvider =
    AsyncNotifierProvider<_RecentFoodsNotifier, List<Recipe>>(
      _RecentFoodsNotifier.new,
    );

final todayLogsProvider = FutureProvider<List<MealLogEntry>>((ref) async {
  return ref.watch(nutritionRepositoryProvider).fetchLogsForDate(DateTime.now());
});

class _MealLoggerNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> logRecipe({
    required Recipe recipe,
    required double servings,
    required MealType mealType,
    String? mealPlanEntryId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final entry = MealLogEntry(
        id: _uuid.v4(),
        userId: userId,
        recipeId: recipe.id,
        recipeTitle: recipe.title,
        mealPlanEntryId: mealPlanEntryId,
        mealType: mealType,
        servings: servings,
        calories: recipe.caloriesPerServing * servings,
        protein: recipe.proteinPerServing * servings,
        carbs: recipe.carbsPerServing * servings,
        fat: recipe.fatPerServing * servings,
        loggedAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
      );

      await ref.read(nutritionRepositoryProvider).addLogEntry(entry);
      await ref.read(recentFoodsProvider.notifier).addRecipe(recipe);
      ref.invalidate(todayLogsProvider);
    });
  }

  Future<void> deleteEntry(String entryId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(nutritionRepositoryProvider).deleteLogEntry(entryId);
      ref.invalidate(todayLogsProvider);
    });
  }
}

final mealLoggerProvider = AsyncNotifierProvider<_MealLoggerNotifier, void>(
  _MealLoggerNotifier.new,
);

class _CustomFoodNotifier extends AsyncNotifier<Recipe?> {
  @override
  Future<Recipe?> build() async => null;

  Future<Recipe?> createCustomFood({
    required String name,
    String? brand,
    required double caloriesPerServing,
    required double proteinPerServing,
    required double carbsPerServing,
    required double fatPerServing,
    required double defaultServings,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final recipe = Recipe(
        id: _uuid.v4(),
        createdBy: userId,
        title: name.trim(),
        description: brand?.trim().isEmpty ?? true ? null : 'Brand: ${brand!.trim()}',
        servings: defaultServings <= 0 ? 1 : defaultServings.round(),
        prepTimeMinutes: 0,
        cookTimeMinutes: 0,
        calories: caloriesPerServing * (defaultServings <= 0 ? 1 : defaultServings),
        proteinG: proteinPerServing * (defaultServings <= 0 ? 1 : defaultServings),
        carbsG: carbsPerServing * (defaultServings <= 0 ? 1 : defaultServings),
        fatG: fatPerServing * (defaultServings <= 0 ? 1 : defaultServings),
        ingredients: [RecipeIngredient(name: name.trim(), quantity: 1)],
        instructions: const ['Quick add item'],
        tags: const ['quick-add'],
        isCommunity: false,
        isPublic: false,
        downloads: 0,
        createdAt: DateTime.now().toUtc(),
      );

      final created = await ref
          .read(nutritionRepositoryProvider)
          .createQuickRecipe(recipe);
      await ref.read(recentFoodsProvider.notifier).addRecipe(created);
      ref.invalidate(popularFoodsProvider);
      ref.invalidate(myRecipesProvider);
      return created;
    });
    return state.valueOrNull;
  }
}

final customFoodProvider =
    AsyncNotifierProvider<_CustomFoodNotifier, Recipe?>(
      _CustomFoodNotifier.new,
    );

class DailyTotals {
  const DailyTotals({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  DailyTotals operator +(MealLogEntry entry) => DailyTotals(
    calories: calories + entry.calories,
    protein: protein + entry.protein,
    carbs: carbs + entry.carbs,
    fat: fat + entry.fat,
  );
}

extension MealLogListX on List<MealLogEntry> {
  DailyTotals get totals =>
      fold(const DailyTotals(), (acc, entry) => acc + entry);

  List<MealLogEntry> forMealType(MealType type) =>
      where((e) => e.mealType == type).toList();
}
