import 'package:flutter/foundation.dart';

@immutable
class PortionMacros {
  const PortionMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fat;
}

@immutable
class MacrosPerContainer extends PortionMacros {
  const MacrosPerContainer({
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    this.weightGrams,
  });

  final double? weightGrams;
}

@immutable
class DailyMacros extends PortionMacros {
  const DailyMacros({
    super.calories = 0,
    super.protein = 0,
    super.carbs = 0,
    super.fat = 0,
  });

  DailyMacros operator +(PortionMacros other) => DailyMacros(
    calories: calories + other.calories,
    protein: protein + other.protein,
    carbs: carbs + other.carbs,
    fat: fat + other.fat,
  );
}

MacrosPerContainer calculatePerContainer({
  required double totalCalories,
  required double totalProtein,
  required double totalCarbs,
  required double totalFat,
  required int containerCount,
  double? totalBatchWeightGrams,
}) {
  if (containerCount <= 0) {
    throw ArgumentError.value(
      containerCount,
      'containerCount',
      'Container count must be greater than 0.',
    );
  }

  return MacrosPerContainer(
    calories: totalCalories / containerCount,
    protein: totalProtein / containerCount,
    carbs: totalCarbs / containerCount,
    fat: totalFat / containerCount,
    weightGrams: totalBatchWeightGrams != null
        ? totalBatchWeightGrams / containerCount
        : null,
  );
}

int suggestContainerCount({
  required double totalCalories,
  required double targetCaloriesPerMeal,
}) {
  if (targetCaloriesPerMeal <= 0) {
    throw ArgumentError.value(
      targetCaloriesPerMeal,
      'targetCaloriesPerMeal',
      'Target calories must be greater than 0.',
    );
  }

  return (totalCalories / targetCaloriesPerMeal).round().clamp(1, 20);
}

DailyMacros calculateDailyTotals(Iterable<PortionMacros> entries) {
  return entries.fold(
    const DailyMacros(),
    (runningTotal, entry) => runningTotal + entry,
  );
}
