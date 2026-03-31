import 'package:flutter/foundation.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  other;

  String get label => switch (this) {
    MealType.breakfast => 'Breakfast',
    MealType.lunch => 'Lunch',
    MealType.dinner => 'Dinner',
    MealType.snack => 'Snack',
    MealType.other => 'Other',
  };
}

@immutable
class MealLogEntry {
  const MealLogEntry({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.recipeTitle,
    required this.mealType,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
    this.mealPlanEntryId,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String recipeId;
  final String recipeTitle;
  final MealType mealType;
  final double servings;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime loggedAt;
  final String? mealPlanEntryId;
  final DateTime? createdAt;

  factory MealLogEntry.fromJson(Map<String, dynamic> json) => MealLogEntry(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    recipeId: json['recipe_id'] as String,
    recipeTitle: json['recipe_title'] as String,
    mealType: MealType.values.firstWhere(
      (e) => e.name == (json['meal_type'] as String? ?? 'other'),
      orElse: () => MealType.other,
    ),
    servings: (json['servings'] as num? ?? 1).toDouble(),
    calories: (json['calories'] as num? ?? 0).toDouble(),
    protein: ((json['protein_g'] ?? json['protein']) as num? ?? 0).toDouble(),
    carbs: ((json['carbs_g'] ?? json['carbs']) as num? ?? 0).toDouble(),
    fat: ((json['fat_g'] ?? json['fat']) as num? ?? 0).toDouble(),
    loggedAt: DateTime.parse(json['logged_at'] as String),
    mealPlanEntryId: json['meal_plan_entry_id'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'recipe_id': recipeId,
    'recipe_title': recipeTitle,
    if (mealPlanEntryId != null) 'meal_plan_entry_id': mealPlanEntryId,
    'meal_type': mealType.name,
    'servings': servings,
    'calories': calories,
    'protein_g': protein,
    'carbs_g': carbs,
    'fat_g': fat,
    'logged_at': loggedAt.toIso8601String(),
    'created_at': (createdAt ?? DateTime.now().toUtc()).toIso8601String(),
  };
}
