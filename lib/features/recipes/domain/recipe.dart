import 'package:flutter/foundation.dart';

@immutable
class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    this.quantity,
    this.unit,
    this.category,
  });

  final String name;
  final double? quantity;
  final String? unit;
  final String? category;

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
        category: json['category'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    if (quantity != null) 'quantity': quantity,
    if (unit != null) 'unit': unit,
    if (category != null) 'category': category,
  };
}

@immutable
class Recipe {
  const Recipe({
    required this.id,
    required this.createdBy,
    required this.title,
    this.description,
    this.imageUrl,
    this.prepTimeMinutes = 0,
    this.cookTimeMinutes = 0,
    this.servings = 1,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.ingredients = const [],
    this.instructions = const [],
    this.tags = const [],
    this.isCommunity = false,
    this.isPublic = false,
    this.downloads = 0,
    this.averageRating = 0,
    this.totalRatings = 0,
    this.totalSaves = 0,
    this.totalReviews = 0,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String createdBy;
  final String title;
  final String? description;
  final String? imageUrl;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final List<RecipeIngredient> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final bool isCommunity;
  final bool isPublic;
  final int downloads;
  final double averageRating;
  final int totalRatings;
  final int totalSaves;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime? updatedAt;

  double get caloriesPerServing => servings == 0 ? 0 : calories / servings;
  double get proteinPerServing => servings == 0 ? 0 : proteinG / servings;
  double get carbsPerServing => servings == 0 ? 0 : carbsG / servings;
  double get fatPerServing => servings == 0 ? 0 : fatG / servings;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final instructionsValue = json['instructions'];
    final ingredientsValue = json['ingredients'];
    final communityStatsValue = json['community_recipe_stats'];
    final communityStats = switch (communityStatsValue) {
      final List list when list.isNotEmpty =>
        list.first as Map<String, dynamic>,
      final Map<String, dynamic> map => map,
      _ => null,
    };
    final recipeAverageRating = (json['average_rating'] as num?)?.toDouble() ?? 0;
    final statsAverageRating =
        (communityStats?['average_rating'] as num?)?.toDouble() ?? 0;
    final recipeTotalRatings = json['total_ratings'] as int? ?? 0;
    final statsTotalRatings = communityStats?['total_ratings'] as int? ?? 0;
    final recipeTotalSaves = json['total_saves'] as int? ?? 0;
    final statsTotalSaves = communityStats?['total_saves'] as int? ?? 0;
    final recipeTotalReviews = json['total_reviews'] as int? ?? 0;
    final statsTotalReviews = communityStats?['total_reviews'] as int? ?? 0;

    return Recipe(
      id: json['id'] as String,
      createdBy:
          json['created_by'] as String? ??
          json['owner_id'] as String? ??
          '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      prepTimeMinutes: json['prep_time_minutes'] as int? ?? 0,
      cookTimeMinutes: json['cook_time_minutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      calories:
          (json['calories'] as num?)?.toDouble() ??
          ((json['calories_per_serving'] as num?)?.toDouble() ?? 0) *
              (json['servings'] as int? ?? 1),
      proteinG:
          (json['protein_g'] as num?)?.toDouble() ??
          ((json['protein_per_serving'] as num?)?.toDouble() ?? 0) *
              (json['servings'] as int? ?? 1),
      carbsG:
          (json['carbs_g'] as num?)?.toDouble() ??
          ((json['carbs_per_serving'] as num?)?.toDouble() ?? 0) *
              (json['servings'] as int? ?? 1),
      fatG:
          (json['fat_g'] as num?)?.toDouble() ??
          ((json['fat_per_serving'] as num?)?.toDouble() ?? 0) *
              (json['servings'] as int? ?? 1),
      ingredients: ingredientsValue is List
          ? ingredientsValue
                .map(
                  (item) => RecipeIngredient.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList()
          : const [],
      instructions: instructionsValue is List
          ? instructionsValue.map((item) => item.toString()).toList()
          : const [],
      tags: ((json['tags'] as List?) ?? const []).cast<String>(),
      isCommunity:
          json['is_community'] as bool? ??
          ((json['source'] as String?) == 'community'),
      isPublic:
          json['is_public'] as bool? ?? json['is_published'] as bool? ?? false,
      downloads:
          json['downloads'] as int? ?? json['times_cooked'] as int? ?? 0,
      averageRating: statsTotalRatings > 0
          ? statsAverageRating
          : recipeAverageRating,
      totalRatings: recipeTotalRatings > statsTotalRatings
          ? recipeTotalRatings
          : statsTotalRatings,
      totalSaves: recipeTotalSaves > statsTotalSaves
          ? recipeTotalSaves
          : statsTotalSaves,
      totalReviews: recipeTotalReviews > statsTotalReviews
          ? recipeTotalReviews
          : statsTotalReviews,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now().toUtc(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_by': createdBy,
    'title': title,
    if (description != null) 'description': description,
    if (imageUrl != null) 'image_url': imageUrl,
    'prep_time_minutes': prepTimeMinutes,
    'cook_time_minutes': cookTimeMinutes,
    'servings': servings,
    'calories': calories,
    'protein_g': proteinG,
    'carbs_g': carbsG,
    'fat_g': fatG,
    'ingredients': ingredients.map((item) => item.toJson()).toList(),
    'instructions': instructions,
    'tags': tags,
    'is_community': isCommunity,
    'is_public': isPublic,
    'downloads': downloads,
    'average_rating': averageRating,
    'total_ratings': totalRatings,
    'total_saves': totalSaves,
    'total_reviews': totalReviews,
    'created_at': createdAt.toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };
}
