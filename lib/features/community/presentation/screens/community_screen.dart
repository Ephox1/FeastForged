import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../recipes/domain/recipe.dart';
import '../../../../shared/widgets/recipe_cover_image.dart';
import '../../providers/community_provider.dart';

enum _CommunitySort { trending, topRated, mostSaved, newest }

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  _CommunitySort _sort = _CommunitySort.trending;
  bool _savedOnly = false;

  @override
  Widget build(BuildContext context) {
    final communityRecipes = ref.watch(communityRecipesProvider);
    final savedRecipeIds = ref.watch(savedRecipeIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(communityRecipesProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Public recipes from the live Supabase project',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse what looks strongest right now, then jump into detail to save, rate, review, or log it.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._CommunitySort.values.map(
                  (sort) => ChoiceChip(
                    label: Text(_labelFor(sort)),
                    selected: _sort == sort,
                    onSelected: (_) => setState(() => _sort = sort),
                  ),
                ),
                FilterChip(
                  label: const Text('Saved only'),
                  selected: _savedOnly,
                  onSelected: (value) => setState(() => _savedOnly = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            communityRecipes.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) =>
                  Text('Could not load community recipes: $error'),
              data: (recipes) => savedRecipeIds.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) =>
                    Text('Could not load saved recipes: $error'),
                data: (savedIds) {
                  final sorted = _sortedRecipes(recipes)
                      .where(
                        (recipe) => !_savedOnly || savedIds.contains(recipe.id),
                      )
                      .toList();
                  if (sorted.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _savedOnly
                              ? 'You have not saved any community recipes yet.'
                              : 'No public recipes available yet.',
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: sorted
                        .map(
                          (recipe) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => context.push(
                                '/recipes/${recipe.id}',
                                extra: recipe,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RecipeCoverImage(
                                    recipe: recipe,
                                    height: 180,
                                    showOverlay: true,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        if (recipe.description != null) ...[
                                          const SizedBox(height: 8),
                                          Text(recipe.description!),
                                        ],
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _RecipeBadge(
                                              label:
                                                  '${recipe.caloriesPerServing.toStringAsFixed(0)} kcal/serving',
                                            ),
                                            _RecipeBadge(
                                              label:
                                                  '${recipe.downloads} downloads',
                                            ),
                                            _RecipeBadge(
                                              label:
                                                  '${recipe.averageRating.toStringAsFixed(1)} stars',
                                            ),
                                            _RecipeBadge(
                                              label:
                                                  '${recipe.totalReviews} reviews',
                                            ),
                                            _RecipeBadge(
                                              label:
                                                  '${recipe.totalSaves} saves',
                                            ),
                                            if (savedIds.contains(recipe.id))
                                              const _RecipeBadge(
                                                label: 'Saved',
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Recipe> _sortedRecipes(List<Recipe> recipes) {
    final sorted = [...recipes];
    switch (_sort) {
      case _CommunitySort.trending:
        sorted.sort((a, b) => _trendScore(b).compareTo(_trendScore(a)));
      case _CommunitySort.topRated:
        sorted.sort((a, b) {
          final rating = b.averageRating.compareTo(a.averageRating);
          if (rating != 0) return rating;
          return b.totalRatings.compareTo(a.totalRatings);
        });
      case _CommunitySort.mostSaved:
        sorted.sort((a, b) => b.totalSaves.compareTo(a.totalSaves));
      case _CommunitySort.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return sorted;
  }

  double _trendScore(Recipe recipe) =>
      (recipe.totalSaves * 3) +
      (recipe.totalReviews * 2) +
      recipe.totalRatings +
      (recipe.averageRating * 4) +
      recipe.downloads;

  String _labelFor(_CommunitySort sort) => switch (sort) {
    _CommunitySort.trending => 'Trending',
    _CommunitySort.topRated => 'Top rated',
    _CommunitySort.mostSaved => 'Most saved',
    _CommunitySort.newest => 'Newest',
  };
}

class _RecipeBadge extends StatelessWidget {
  const _RecipeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
