import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/nutrition_repository.dart';
import '../domain/food_item.dart';
import '../domain/meal_log_entry.dart';

const _uuid = Uuid();
const _recentFoodsStorageKey = 'recent_foods';

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (_) => const NutritionRepository(),
);

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  _,
) async {
  return SharedPreferences.getInstance();
});

// Food search

class _FoodSearchNotifier extends AsyncNotifier<List<FoodItem>> {
  @override
  Future<List<FoodItem>> build() async => [];

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(nutritionRepositoryProvider).searchFoods(query.trim()),
    );
  }

  void clear() => state = const AsyncData([]);
}

final foodSearchProvider =
    AsyncNotifierProvider<_FoodSearchNotifier, List<FoodItem>>(
      _FoodSearchNotifier.new,
    );

final popularFoodsProvider = FutureProvider<List<FoodItem>>((ref) async {
  return ref.watch(nutritionRepositoryProvider).fetchPopularFoods();
});

class _RecentFoodsNotifier extends AsyncNotifier<List<FoodItem>> {
  @override
  Future<List<FoodItem>> build() async {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    final storedFoods =
        preferences.getStringList(_recentFoodsStorageKey) ?? const [];

    return storedFoods
        .map(
          (foodJson) => FoodItem.fromJson(
            jsonDecode(foodJson) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> addFood(FoodItem food) async {
    final preferences = await ref.read(sharedPreferencesProvider.future);
    final current = [...state.valueOrNull ?? []];

    current.removeWhere((item) => item.id == food.id);
    current.insert(0, food);

    final trimmed = current.take(8).toList(growable: false);
    await preferences.setStringList(
      _recentFoodsStorageKey,
      trimmed.map((item) => jsonEncode(item.toJson())).toList(),
    );

    state = AsyncData(trimmed);
  }
}

final recentFoodsProvider =
    AsyncNotifierProvider<_RecentFoodsNotifier, List<FoodItem>>(
      _RecentFoodsNotifier.new,
    );

// Today's logs

final todayLogsProvider = FutureProvider<List<MealLogEntry>>((ref) async {
  return ref.watch(nutritionRepositoryProvider).fetchLogsForDate(DateTime.now());
});

// Meal logger

class _MealLoggerNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> logFood({
    required FoodItem food,
    required double amountGrams,
    required MealType mealType,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final entry = MealLogEntry(
        id: _uuid.v4(),
        userId: userId,
        foodItemId: food.id,
        foodName: food.name,
        mealType: mealType,
        amountGrams: amountGrams,
        calories: food.caloriesForAmount(amountGrams),
        protein: food.proteinForAmount(amountGrams),
        carbs: food.carbsForAmount(amountGrams),
        fat: food.fatForAmount(amountGrams),
        loggedAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
      );

      await ref.read(nutritionRepositoryProvider).addLogEntry(entry);
      await ref.read(recentFoodsProvider.notifier).addFood(food);
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

class _CustomFoodNotifier extends AsyncNotifier<FoodItem?> {
  @override
  Future<FoodItem?> build() async => null;

  Future<FoodItem?> createCustomFood({
    required String name,
    String? brand,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    required double defaultServingGrams,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final food = FoodItem(
        id: _uuid.v4(),
        name: name.trim(),
        brand: brand?.trim().isEmpty ?? true ? null : brand!.trim(),
        caloriesPer100g: caloriesPer100g,
        proteinPer100g: proteinPer100g,
        carbsPer100g: carbsPer100g,
        fatPer100g: fatPer100g,
        defaultServingGrams: defaultServingGrams,
        isCustom: true,
        userId: userId,
      );

      final created = await ref
          .read(nutritionRepositoryProvider)
          .createCustomFood(food);
      await ref.read(recentFoodsProvider.notifier).addFood(created);
      ref.invalidate(popularFoodsProvider);
      return created;
    });
    return state.valueOrNull;
  }
}

final customFoodProvider =
    AsyncNotifierProvider<_CustomFoodNotifier, FoodItem?>(
      _CustomFoodNotifier.new,
    );

// Aggregation helpers

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
