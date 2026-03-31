import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recipes/domain/recipe.dart';
import '../data/community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>(
  (_) => const CommunityRepository(),
);

final communityRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  return ref.watch(communityRepositoryProvider).fetchCommunityRecipes();
});

final recipeDetailProvider = FutureProvider.family<CommunityRecipeDetail, String>((
  ref,
  recipeId,
) async {
  return ref.watch(communityRepositoryProvider).fetchRecipeDetail(recipeId);
});

class _CommunityActionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggleSave({
    required String recipeId,
    required bool shouldSave,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(communityRepositoryProvider)
          .toggleSave(recipeId, shouldSave: shouldSave);
      ref.invalidate(communityRecipesProvider);
      ref.invalidate(recipeDetailProvider(recipeId));
    });
  }

  Future<void> setRating({
    required String recipeId,
    required int rating,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(communityRepositoryProvider).setRating(recipeId, rating);
      ref.invalidate(communityRecipesProvider);
      ref.invalidate(recipeDetailProvider(recipeId));
    });
  }

  Future<void> addReview({
    required String recipeId,
    required String content,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(communityRepositoryProvider).addReview(recipeId, content);
      ref.invalidate(communityRecipesProvider);
      ref.invalidate(recipeDetailProvider(recipeId));
    });
  }
}

final communityActionProvider =
    AsyncNotifierProvider<_CommunityActionNotifier, void>(
      _CommunityActionNotifier.new,
    );
