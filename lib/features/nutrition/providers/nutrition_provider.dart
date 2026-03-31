import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/nutrition_repository.dart';
import '../domain/food_item.dart';
import '../domain/meal_log_entry.dart';

const _uuid = Uuid();

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (_) => const NutritionRepository(),
);

// ── Food search ───────────────────────────────────────────────────────────────

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
      () => ref.read(nutritionRepositoryProvider).searchFoods(query),
    );
  }

  void clear() => state = const AsyncData([]);
}

final foodSearchProvider =
    AsyncNotifierProvider<_FoodSearchNotifier, List<FoodItem>>(
      _FoodSearchNotifier.new,
    );

// ── Today's logs ──────────────────────────────────────────────────────────────

final todayLogsProvider = FutureProvider<List<MealLogEntry>>((ref) async {
  return ref
      .watch(nutritionRepositoryProvider)
      .fetchLogsForDate(DateTime.now());
});

// ── Meal logger ───────────────────────────────────────────────────────────────

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

// ── Aggregation helpers ───────────────────────────────────────────────────────

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
