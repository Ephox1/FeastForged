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
    required this.foodItemId,
    required this.foodName,
    required this.mealType,
    required this.amountGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String foodItemId;
  final String foodName;
  final MealType mealType;
  final double amountGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime loggedAt;
  final DateTime? createdAt;

  factory MealLogEntry.fromJson(Map<String, dynamic> json) => MealLogEntry(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    foodItemId: json['food_item_id'] as String? ?? '',
    foodName: json['food_name'] as String,
    mealType: MealType.values.firstWhere(
      (e) => e.name == (json['meal_type'] as String),
      orElse: () => MealType.other,
    ),
    amountGrams: (json['amount_grams'] as num).toDouble(),
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num? ?? 0).toDouble(),
    carbs: (json['carbs'] as num? ?? 0).toDouble(),
    fat: (json['fat'] as num? ?? 0).toDouble(),
    loggedAt: DateTime.parse(json['logged_at'] as String),
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'food_item_id': foodItemId.isNotEmpty ? foodItemId : null,
    'food_name': foodName,
    'meal_type': mealType.name,
    'amount_grams': amountGrams,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'logged_at': loggedAt.toIso8601String(),
    'created_at': (createdAt ?? DateTime.now().toUtc()).toIso8601String(),
  };
}
