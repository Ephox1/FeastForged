import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/recipe_repository.dart';
import '../domain/recipe.dart';

const _uuid = Uuid();

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (_) => const RecipeRepository(),
);

final myRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  return ref.watch(recipeRepositoryProvider).fetchMyRecipes();
});

final publicRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  return ref.watch(recipeRepositoryProvider).fetchPublicRecipes();
});

class _RecipeEditorNotifier extends AsyncNotifier<Recipe?> {
  @override
  Future<Recipe?> build() async => null;

  Future<Recipe?> saveRecipe({
    String? recipeId,
    required String title,
    String? description,
    String? imageUrl,
    required int servings,
    required int prepTimeMinutes,
    required int cookTimeMinutes,
    required double calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    required List<RecipeIngredient> ingredients,
    required List<String> instructions,
    required List<String> tags,
    bool isPublic = false,
    int downloads = 0,
    DateTime? createdAt,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recipeRepositoryProvider);
      final userId = repository.requireUserId();

      final saved = await repository.saveRecipe(
        Recipe(
          id: recipeId ?? _uuid.v4(),
          createdBy: userId,
          title: title.trim(),
          description: description?.trim().isEmpty ?? true
              ? null
              : description!.trim(),
          imageUrl: imageUrl?.trim().isEmpty ?? true ? null : imageUrl!.trim(),
          servings: servings,
          prepTimeMinutes: prepTimeMinutes,
          cookTimeMinutes: cookTimeMinutes,
          calories: calories,
          proteinG: proteinG,
          carbsG: carbsG,
          fatG: fatG,
          ingredients: ingredients,
          instructions: instructions,
          tags: tags,
          isPublic: isPublic,
          downloads: downloads,
          createdAt: createdAt ?? DateTime.now().toUtc(),
          updatedAt: createdAt != null ? DateTime.now().toUtc() : null,
        ),
      );

      ref.invalidate(myRecipesProvider);
      ref.invalidate(publicRecipesProvider);
      return saved;
    });

    return state.valueOrNull;
  }

  Future<void> deleteRecipe(String recipeId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(recipeRepositoryProvider).deleteRecipe(recipeId);
      ref.invalidate(myRecipesProvider);
      ref.invalidate(publicRecipesProvider);
      return null;
    });
  }
}

final recipeEditorProvider =
    AsyncNotifierProvider<_RecipeEditorNotifier, Recipe?>(
      _RecipeEditorNotifier.new,
    );
