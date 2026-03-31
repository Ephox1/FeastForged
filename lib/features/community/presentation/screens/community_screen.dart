import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/community_provider.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityRecipes = ref.watch(communityRecipesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(communityRecipesProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Public recipes from the live Supabase project',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This is the first community foundation pass. Publishing, reviews, and saves can build on top of this.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            communityRecipes.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('Could not load community recipes: $error'),
              data: (recipes) {
                if (recipes.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No public recipes available yet.'),
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
                            onTap: () => context.push(
                              '/recipes/${recipe.id}',
                              extra: recipe,
                            ),
                            title: Text(recipe.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (recipe.description != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(recipe.description!),
                                  ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _RecipeBadge(
                                      label:
                                          '${recipe.caloriesPerServing.toStringAsFixed(0)} kcal/serving',
                                    ),
                                    _RecipeBadge(
                                      label: '${recipe.downloads} downloads',
                                    ),
                                  ],
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
        ),
      ),
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
