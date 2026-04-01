import 'package:feastforged/features/recipes/domain/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes and deserializes live supabase recipe data', () {
    final recipe = Recipe(
      id: 'recipe-1',
      createdBy: 'user-1',
      title: 'High Protein Burrito Bowls',
      servings: 5,
      calories: 2600,
      proteinG: 210,
      carbsG: 190,
      fatG: 80,
      ingredients: const [
        RecipeIngredient(name: 'Chicken breast', category: 'meat'),
      ],
      instructions: const ['Cook the chicken.'],
      tags: const ['high-protein', 'meal-prep'],
      createdAt: DateTime.utc(2026, 3, 31),
    );

    final json = recipe.toJson();
    final decoded = Recipe.fromJson(json);

    expect(decoded.title, recipe.title);
    expect(decoded.createdBy, 'user-1');
    expect(decoded.ingredients.single.name, 'Chicken breast');
    expect(decoded.instructions.single, 'Cook the chicken.');
    expect(decoded.caloriesPerServing, 520);
  });

  test('parses community stats when supabase returns a single nested map', () {
    final decoded = Recipe.fromJson({
      'id': 'recipe-2',
      'created_by': 'user-1',
      'title': 'Greek Chicken Power Bowls',
      'servings': 4,
      'calories': 2480,
      'protein_g': 224,
      'carbs_g': 220,
      'fat_g': 72,
      'ingredients': const [],
      'instructions': const ['Prep and portion.'],
      'community_recipe_stats': {
        'average_rating': 4.9,
        'total_ratings': 41,
        'total_saves': 54,
        'total_reviews': 19,
      },
      'created_at': '2026-04-01T00:00:00Z',
    });

    expect(decoded.averageRating, 4.9);
    expect(decoded.totalRatings, 41);
    expect(decoded.totalSaves, 54);
    expect(decoded.totalReviews, 19);
  });
}
