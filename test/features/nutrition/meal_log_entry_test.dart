import 'package:feastforged/features/nutrition/domain/meal_log_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes and deserializes recipe-backed meal log entries', () {
    final entry = MealLogEntry(
      id: 'log-1',
      userId: 'user-1',
      recipeId: 'recipe-1',
      recipeTitle: 'Chicken Burrito Bowl',
      mealPlanEntryId: 'plan-entry-1',
      mealType: MealType.lunch,
      servings: 1.5,
      calories: 780,
      protein: 54,
      carbs: 72,
      fat: 24,
      loggedAt: DateTime.utc(2026, 3, 31, 12),
      createdAt: DateTime.utc(2026, 3, 31, 12),
    );

    final decoded = MealLogEntry.fromJson(entry.toJson());

    expect(decoded.recipeId, 'recipe-1');
    expect(decoded.recipeTitle, 'Chicken Burrito Bowl');
    expect(decoded.mealPlanEntryId, 'plan-entry-1');
    expect(decoded.servings, 1.5);
    expect(decoded.mealType, MealType.lunch);
  });
}
