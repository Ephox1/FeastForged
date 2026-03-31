import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/meal_plan_repository.dart';
import '../domain/meal_plan.dart';

final mealPlanRepositoryProvider = Provider<MealPlanRepository>(
  (_) => const MealPlanRepository(),
);

DateTime startOfCurrentWeek() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).subtract(
    Duration(days: now.weekday - 1),
  );
}

final currentWeekPlanProvider = FutureProvider<MealPlan?>((ref) async {
  return ref.watch(mealPlanRepositoryProvider).fetchPlanForWeek(
        startOfCurrentWeek(),
      );
});

final currentWeekEntriesProvider = FutureProvider<List<MealPlanEntry>>((
  ref,
) async {
  final plan = await ref.watch(currentWeekPlanProvider.future);
  if (plan == null) return [];
  return ref.watch(mealPlanRepositoryProvider).fetchEntries(plan.id);
});

class _MealPlanEditorNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createCurrentWeekPlan() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(mealPlanRepositoryProvider)
          .createPlanForWeek(startOfCurrentWeek());
      ref.invalidate(currentWeekPlanProvider);
      ref.invalidate(currentWeekEntriesProvider);
    });
  }

  Future<void> addEntry({
    required String mealPlanId,
    required String recipeId,
    required int dayOfWeek,
    required PlannerMealType mealType,
    required int servings,
    String? notes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(mealPlanRepositoryProvider)
          .addEntry(
            mealPlanId: mealPlanId,
            recipeId: recipeId,
            dayOfWeek: dayOfWeek,
            mealType: mealType,
            servings: servings,
            notes: notes,
          );
      ref.invalidate(currentWeekEntriesProvider);
    });
  }

  Future<void> deleteEntry(String entryId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(mealPlanRepositoryProvider).deleteEntry(entryId);
      ref.invalidate(currentWeekEntriesProvider);
    });
  }
}

final mealPlanEditorProvider = AsyncNotifierProvider<_MealPlanEditorNotifier, void>(
  _MealPlanEditorNotifier.new,
);
