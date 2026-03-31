import 'package:feastforged/core/utils/macro_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculatePerContainer', () {
    test('splits total macros evenly', () {
      final result = calculatePerContainer(
        totalCalories: 2400,
        totalProtein: 180,
        totalCarbs: 200,
        totalFat: 80,
        containerCount: 4,
        totalBatchWeightGrams: 1600,
      );

      expect(result.calories, 600);
      expect(result.protein, 45);
      expect(result.carbs, 50);
      expect(result.fat, 20);
      expect(result.weightGrams, 400);
    });

    test('throws on invalid container count', () {
      expect(
        () => calculatePerContainer(
          totalCalories: 1000,
          totalProtein: 100,
          totalCarbs: 100,
          totalFat: 50,
          containerCount: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('suggestContainerCount', () {
    test('suggests a bounded container count from calorie target', () {
      expect(
        suggestContainerCount(totalCalories: 3200, targetCaloriesPerMeal: 800),
        4,
      );
    });

    test('clamps low values to at least one container', () {
      expect(
        suggestContainerCount(totalCalories: 100, targetCaloriesPerMeal: 500),
        1,
      );
    });
  });

  group('calculateDailyTotals', () {
    test('adds all macro entries together', () {
      final totals = calculateDailyTotals(const [
        PortionMacros(calories: 400, protein: 30, carbs: 40, fat: 10),
        PortionMacros(calories: 550, protein: 45, carbs: 35, fat: 20),
      ]);

      expect(totals.calories, 950);
      expect(totals.protein, 75);
      expect(totals.carbs, 75);
      expect(totals.fat, 30);
    });
  });
}
