import 'package:flutter/foundation.dart';

import '../../recipes/domain/recipe.dart';

enum PlannerMealType { breakfast, lunch, dinner, snack }

extension PlannerMealTypeX on PlannerMealType {
  String get label => switch (this) {
    PlannerMealType.breakfast => 'Breakfast',
    PlannerMealType.lunch => 'Lunch',
    PlannerMealType.dinner => 'Dinner',
    PlannerMealType.snack => 'Snack',
  };
}

@immutable
class MealPlan {
  const MealPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String? ?? 'Weekly Meal Plan',
    startDate: DateTime.parse(json['start_date'] as String),
    endDate: DateTime.parse(json['end_date'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );
}

@immutable
class MealPlanEntry {
  const MealPlanEntry({
    required this.id,
    required this.mealPlanId,
    required this.recipeId,
    required this.dayOfWeek,
    required this.mealType,
    this.servings = 1,
    this.notes,
    this.recipe,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String mealPlanId;
  final String recipeId;
  final int dayOfWeek;
  final PlannerMealType mealType;
  final int servings;
  final String? notes;
  final Recipe? recipe;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory MealPlanEntry.fromJson(Map<String, dynamic> json) => MealPlanEntry(
    id: json['id'] as String,
    mealPlanId: json['meal_plan_id'] as String,
    recipeId: json['recipe_id'] as String,
    dayOfWeek: json['day_of_week'] as int? ?? 0,
    mealType: PlannerMealType.values.firstWhere(
      (value) => value.name == (json['meal_type'] as String? ?? 'dinner'),
      orElse: () => PlannerMealType.dinner,
    ),
    servings: json['servings'] as int? ?? 1,
    notes: json['notes'] as String?,
    recipe: json['recipes'] is Map<String, dynamic>
        ? Recipe.fromJson(json['recipes'] as Map<String, dynamic>)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );
}
