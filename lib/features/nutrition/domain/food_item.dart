import 'package:flutter/foundation.dart';

@immutable
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    this.brand,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0.0,
    this.sugarPer100g = 0.0,
    this.servingUnit,
    this.defaultServingGrams = 100.0,
    this.isCustom = false,
    this.userId,
  });

  final String id;
  final String name;
  final String? brand;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  final String? servingUnit;
  final double defaultServingGrams;
  final bool isCustom;
  final String? userId;

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'] as String,
    name: json['name'] as String,
    brand: json['brand'] as String?,
    caloriesPer100g: (json['calories_per_100g'] as num).toDouble(),
    proteinPer100g: (json['protein_per_100g'] as num? ?? 0).toDouble(),
    carbsPer100g: (json['carbs_per_100g'] as num? ?? 0).toDouble(),
    fatPer100g: (json['fat_per_100g'] as num? ?? 0).toDouble(),
    fiberPer100g: (json['fiber_per_100g'] as num? ?? 0).toDouble(),
    sugarPer100g: (json['sugar_per_100g'] as num? ?? 0).toDouble(),
    servingUnit: json['serving_unit'] as String?,
    defaultServingGrams: (json['default_serving_grams'] as num? ?? 100)
        .toDouble(),
    isCustom: json['is_custom'] as bool? ?? false,
    userId: json['user_id'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (brand != null) 'brand': brand,
    'calories_per_100g': caloriesPer100g,
    'protein_per_100g': proteinPer100g,
    'carbs_per_100g': carbsPer100g,
    'fat_per_100g': fatPer100g,
    'fiber_per_100g': fiberPer100g,
    'sugar_per_100g': sugarPer100g,
    if (servingUnit != null) 'serving_unit': servingUnit,
    'default_serving_grams': defaultServingGrams,
    'is_custom': isCustom,
    if (userId != null) 'user_id': userId,
  };

  double caloriesForAmount(double grams) => caloriesPer100g * grams / 100;
  double proteinForAmount(double grams) => proteinPer100g * grams / 100;
  double carbsForAmount(double grams) => carbsPer100g * grams / 100;
  double fatForAmount(double grams) => fatPer100g * grams / 100;
}
