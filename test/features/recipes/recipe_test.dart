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
}
