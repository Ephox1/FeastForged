import 'package:flutter/foundation.dart';

enum RecipeMealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get label => switch (this) {
    RecipeMealType.breakfast => 'Breakfast',
    RecipeMealType.lunch => 'Lunch',
    RecipeMealType.dinner => 'Dinner',
    RecipeMealType.snack => 'Snack',
  };
}

enum RecipeDifficulty { easy, medium, hard }

enum RecipeSource {
  manual,
  aiGenerated,
  aiImported,
  community;

  String get databaseValue => switch (this) {
    RecipeSource.manual => 'manual',
    RecipeSource.aiGenerated => 'ai_generated',
    RecipeSource.aiImported => 'ai_imported',
    RecipeSource.community => 'community',
  };

  static RecipeSource fromDatabaseValue(String? value) => switch (value) {
    'ai_generated' => RecipeSource.aiGenerated,
    'ai_imported' => RecipeSource.aiImported,
    'community' => RecipeSource.community,
    _ => RecipeSource.manual,
  };
}

@immutable
class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.category,
  });

  final String name;
  final double quantity;
  final String unit;
  final String? category;

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num? ?? 0).toDouble(),
        unit: json['unit'] as String? ?? '',
        category: json['category'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    if (category != null) 'category': category,
  };
}

@immutable
class RecipeInstruction {
  const RecipeInstruction({required this.step, required this.text});

  final int step;
  final String text;

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) =>
      RecipeInstruction(
        step: json['step'] as int? ?? 0,
        text: json['text'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'step': step, 'text': text};
}

@immutable
class Recipe {
  const Recipe({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.cuisine,
    required this.mealType,
    this.difficulty = RecipeDifficulty.medium,
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.servings = 4,
    this.caloriesPerServing = 0,
    this.proteinPerServing = 0,
    this.carbsPerServing = 0,
    this.fatPerServing = 0,
    this.totalBatchWeightGrams,
    this.ingredients = const [],
    this.instructions = const [],
    this.tags = const [],
    this.imageUrl,
    this.source = RecipeSource.manual,
    this.sourceUrl,
    this.isPublished = false,
    this.publishedAt,
    this.timesCooked = 0,
    this.lastCookedAt,
    this.isFavorite = false,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String? cuisine;
  final RecipeMealType mealType;
  final RecipeDifficulty difficulty;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final double caloriesPerServing;
  final double proteinPerServing;
  final double carbsPerServing;
  final double fatPerServing;
  final double? totalBatchWeightGrams;
  final List<RecipeIngredient> ingredients;
  final List<RecipeInstruction> instructions;
  final List<String> tags;
  final String? imageUrl;
  final RecipeSource source;
  final String? sourceUrl;
  final bool isPublished;
  final DateTime? publishedAt;
  final int timesCooked;
  final DateTime? lastCookedAt;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  double get caloriesTotal => caloriesPerServing * servings;
  double get proteinTotal => proteinPerServing * servings;
  double get carbsTotal => carbsPerServing * servings;
  double get fatTotal => fatPerServing * servings;

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String,
    ownerId: json['owner_id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    cuisine: json['cuisine'] as String?,
    mealType: RecipeMealType.values.firstWhere(
      (value) => value.name == (json['meal_type'] as String? ?? 'dinner'),
      orElse: () => RecipeMealType.dinner,
    ),
    difficulty: RecipeDifficulty.values.firstWhere(
      (value) => value.name == (json['difficulty'] as String? ?? 'medium'),
      orElse: () => RecipeDifficulty.medium,
    ),
    prepTimeMinutes: json['prep_time_minutes'] as int? ?? 0,
    cookTimeMinutes: json['cook_time_minutes'] as int? ?? 0,
    servings: json['servings'] as int? ?? 4,
    caloriesPerServing: (json['calories_per_serving'] as num? ?? 0).toDouble(),
    proteinPerServing: (json['protein_per_serving'] as num? ?? 0).toDouble(),
    carbsPerServing: (json['carbs_per_serving'] as num? ?? 0).toDouble(),
    fatPerServing: (json['fat_per_serving'] as num? ?? 0).toDouble(),
    totalBatchWeightGrams: (json['total_batch_weight_grams'] as num?)
        ?.toDouble(),
    ingredients: ((json['ingredients'] as List?) ?? const [])
        .map((item) => RecipeIngredient.fromJson(item as Map<String, dynamic>))
        .toList(),
    instructions: ((json['instructions'] as List?) ?? const [])
        .map((item) => RecipeInstruction.fromJson(item as Map<String, dynamic>))
        .toList(),
    tags: ((json['tags'] as List?) ?? const []).cast<String>(),
    imageUrl: json['image_url'] as String?,
    source: RecipeSource.fromDatabaseValue(json['source'] as String?),
    sourceUrl: json['source_url'] as String?,
    isPublished: json['is_published'] as bool? ?? false,
    publishedAt: json['published_at'] != null
        ? DateTime.parse(json['published_at'] as String)
        : null,
    timesCooked: json['times_cooked'] as int? ?? 0,
    lastCookedAt: json['last_cooked_at'] != null
        ? DateTime.parse(json['last_cooked_at'] as String)
        : null,
    isFavorite: json['is_favorite'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'owner_id': ownerId,
    'title': title,
    if (description != null) 'description': description,
    if (cuisine != null) 'cuisine': cuisine,
    'meal_type': mealType.name,
    'difficulty': difficulty.name,
    'prep_time_minutes': prepTimeMinutes,
    'cook_time_minutes': cookTimeMinutes,
    'servings': servings,
    'calories_per_serving': caloriesPerServing,
    'protein_per_serving': proteinPerServing,
    'carbs_per_serving': carbsPerServing,
    'fat_per_serving': fatPerServing,
    if (totalBatchWeightGrams != null)
      'total_batch_weight_grams': totalBatchWeightGrams,
    'ingredients': ingredients.map((item) => item.toJson()).toList(),
    'instructions': instructions.map((item) => item.toJson()).toList(),
    'tags': tags,
    if (imageUrl != null) 'image_url': imageUrl,
    'source': source.databaseValue,
    if (sourceUrl != null) 'source_url': sourceUrl,
    'is_published': isPublished,
    if (publishedAt != null) 'published_at': publishedAt!.toIso8601String(),
    'times_cooked': timesCooked,
    if (lastCookedAt != null) 'last_cooked_at': lastCookedAt!.toIso8601String(),
    'is_favorite': isFavorite,
    'created_at': createdAt.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}
