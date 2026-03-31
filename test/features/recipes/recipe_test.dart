import 'package:feastforged/features/recipes/domain/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes and deserializes recipe data', () {
    final recipe = Recipe(
      id: 'recipe-1',
      ownerId: 'user-1',
      title: 'High Protein Burrito Bowls',
      mealType: RecipeMealType.lunch,
      servings: 5,
      caloriesPerServing: 520,
      proteinPerServing: 42,
      carbsPerServing: 38,
      fatPerServing: 16,
      ingredients: const [
        RecipeIngredient(
          name: 'Chicken breast',
          quantity: 2,
          unit: 'lbs',
          category: 'meat',
        ),
      ],
      instructions: const [
        RecipeInstruction(step: 1, text: 'Cook the chicken.'),
      ],
      tags: const ['high-protein', 'meal-prep'],
      createdAt: DateTime.utc(2026, 3, 31),
    );

    final json = recipe.toJson();
    final decoded = Recipe.fromJson(json);

    expect(decoded.title, recipe.title);
    expect(decoded.mealType, RecipeMealType.lunch);
    expect(decoded.ingredients.single.name, 'Chicken breast');
    expect(decoded.instructions.single.step, 1);
    expect(decoded.caloriesTotal, 2600);
    expect(decoded.source, RecipeSource.manual);
  });
}
