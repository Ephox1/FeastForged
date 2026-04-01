import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/error_messages.dart';
import '../../domain/recipe.dart';
import '../../providers/recipe_provider.dart';

class RecipeListScreen extends ConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRecipes = ref.watch(myRecipesProvider);
    final publicRecipes = ref.watch(publicRecipesProvider);

    ref.listen(recipeEditorProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorMessages.friendly(next.error ?? Exception('Unknown error')),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            onPressed: () => context.push('/app/planner'),
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Planner',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/recipes/new'),
        icon: const Icon(Icons.add),
        label: const Text('New recipe'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myRecipesProvider);
          ref.invalidate(publicRecipesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _RecipeSection(
              title: 'My recipes',
              subtitle: 'Saved to the live Supabase recipes table.',
              asyncRecipes: myRecipes,
              onDelete: (recipeId) =>
                  ref.read(recipeEditorProvider.notifier).deleteRecipe(recipeId),
              trailing: TextButton(
                onPressed: () => context.push('/recipes/new'),
                child: const Text('Create'),
              ),
            ),
            const SizedBox(height: 20),
            _RecipeSection(
              title: 'Community-ready public recipes',
              subtitle: 'Any recipes already marked public in Supabase.',
              asyncRecipes: publicRecipes,
              onDelete: null,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeSection extends StatelessWidget {
  const _RecipeSection({
    required this.title,
    required this.subtitle,
    required this.asyncRecipes,
    required this.onDelete,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final AsyncValue<List<Recipe>> asyncRecipes;
  final Future<void> Function(String recipeId)? onDelete;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        asyncRecipes.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Could not load recipes: $error'),
          ),
          data: (recipes) {
            if (recipes.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'No recipes here yet. Create one and it will be saved to Supabase.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            return Column(
              children: recipes
                  .map(
                    (recipe) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        onTap: () =>
                            context.push('/recipes/${recipe.id}', extra: recipe),
                        title: Text(
                          recipe.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (recipe.description != null)
                                Text(recipe.description!),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _RecipeBadge(
                                    label: '${recipe.servings} servings',
                                  ),
                                  _RecipeBadge(
                                    label:
                                        '${recipe.caloriesPerServing.toStringAsFixed(0)} kcal/serving',
                                  ),
                                  _RecipeBadge(
                                    label:
                                        '${recipe.proteinPerServing.toStringAsFixed(0)}p / ${recipe.carbsPerServing.toStringAsFixed(0)}c / ${recipe.fatPerServing.toStringAsFixed(0)}f',
                                  ),
                                  if (recipe.isPublic)
                                    const _RecipeBadge(label: 'Public'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.tonal(
                                    onPressed: () => context.push(
                                      '/log-meal',
                                      extra: {
                                        'recipe': recipe.toJson(),
                                        'mealType': 'other',
                                      },
                                    ),
                                    child: const Text('Log'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      final title = Uri.encodeComponent(
                                        recipe.title,
                                      );
                                      context.go(
                                        '/app/planner?seedRecipeId=${recipe.id}&seedRecipeTitle=$title',
                                      );
                                    },
                                    child: const Text('Plan'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'delete' && onDelete != null) {
                              await onDelete!(recipe.id);
                            }
                          },
                          itemBuilder: (_) => [
                            if (onDelete != null)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
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
      ],
    );
  }
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
