import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../recipes/domain/recipe.dart';
import '../../domain/meal_log_entry.dart';
import '../../providers/nutrition_provider.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key, required this.mealType});

  final String mealType;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  MealType get _mealType => MealType.values.firstWhere(
    (e) => e.name == widget.mealType,
    orElse: () => MealType.other,
  );

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(foodSearchProvider.notifier).search(query);
    });
    setState(() {});
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(foodSearchProvider.notifier).clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(foodSearchProvider);
    final recentRecipes = ref.watch(recentFoodsProvider);
    final popularRecipes = ref.watch(popularFoodsProvider);
    final showSuggestions = _searchController.text.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text('Add to ${_mealType.label}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                SearchBar(
                  controller: _searchController,
                  hintText: 'Search recipes and quick-add staples...',
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
                  ],
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        showSuggestions
                            ? 'Start with recents, planner-friendly recipes, or create a quick custom item.'
                            : 'Tap a recipe to log servings and meal type.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/food-search/custom?mealType=${_mealType.name}',
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Quick add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: showSuggestions
                ? RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(recentFoodsProvider);
                      ref.invalidate(popularFoodsProvider);
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _RecipeSection(
                          title: 'Recent recipes',
                          subtitle: 'Fast re-logs for meals you actually use.',
                          recipesAsync: recentRecipes,
                          mealType: _mealType,
                          emptyMessage:
                              'Your recent recipes will show up here after your first few logs.',
                        ),
                        const SizedBox(height: 20),
                        _RecipeSection(
                          title: 'Popular picks',
                          subtitle:
                              'Public recipes and your own staples, ordered for quick action.',
                          recipesAsync: popularRecipes,
                          mealType: _mealType,
                          emptyMessage:
                              'No recipe starters are available yet in this environment.',
                        ),
                      ],
                    ),
                  )
                : searchState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Search error: $e')),
                    data: (recipes) {
                      if (recipes.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No recipes found for "${_searchController.text}"',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a simpler search or create a quick custom item.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: recipes.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16),
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return _RecipeTile(
                            recipe: recipe,
                            mealType: _mealType,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecipeSection extends StatelessWidget {
  const _RecipeSection({
    required this.title,
    required this.subtitle,
    required this.recipesAsync,
    required this.mealType,
    required this.emptyMessage,
  });

  final String title;
  final String subtitle;
  final AsyncValue<List<Recipe>> recipesAsync;
  final MealType mealType;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        recipesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Could not load recipes: $e'),
          ),
          data: (recipes) {
            if (recipes.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(emptyMessage),
              );
            }

            return Column(
              children: recipes
                  .map(
                    (recipe) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: _RecipeTile(recipe: recipe, mealType: mealType),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({required this.recipe, required this.mealType});

  final Recipe recipe;
  final MealType mealType;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(recipe.title),
      subtitle: Text(
        recipe.description?.isNotEmpty == true
            ? recipe.description!
            : recipe.isPublic
            ? 'Public recipe'
            : 'Private recipe',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${recipe.caloriesPerServing.toInt()} kcal',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '${recipe.proteinPerServing.toStringAsFixed(0)}p | ${recipe.carbsPerServing.toStringAsFixed(0)}c | ${recipe.fatPerServing.toStringAsFixed(0)}f',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () => context.push(
        '/log-meal',
        extra: {'recipe': recipe.toJson(), 'mealType': mealType.name},
      ),
    );
  }
}
