import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recipes/domain/recipe.dart';
import '../data/community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>(
  (_) => const CommunityRepository(),
);

final communityRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  return ref.watch(communityRepositoryProvider).fetchCommunityRecipes();
});
