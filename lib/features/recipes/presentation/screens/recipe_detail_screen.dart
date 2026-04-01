import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/utils/validators.dart';
import '../../../community/providers/community_provider.dart';
import '../../../nutrition/domain/meal_log_entry.dart';
import '../../domain/recipe.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    this.initialRecipe,
  });

  final String recipeId;
  final Recipe? initialRecipe;

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  final _reviewController = TextEditingController();
  final _reviewFormKey = GlobalKey<FormState>();

  void _openPlannerForRecipe(Recipe recipe) {
    final title = Uri.encodeComponent(recipe.title);
    context.go('/app/planner?seedRecipeId=${recipe.id}&seedRecipeTitle=$title');
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(recipeDetailProvider(widget.recipeId));
    final actionState = ref.watch(communityActionProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    ref.listen(communityActionProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.friendly(next.error))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Recipe detail')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load recipe: $error')),
        data: (detail) {
          final recipe = detail.recipe;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                recipe.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (recipe.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  recipe.description!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _Badge(label: '${recipe.servings} servings'),
                  _Badge(
                    label:
                        '${recipe.caloriesPerServing.toStringAsFixed(0)} kcal/serving',
                  ),
                  _Badge(
                    label:
                        '${detail.stats.averageRating.toStringAsFixed(1)} avg rating',
                  ),
                  _Badge(label: '${detail.stats.totalRatings} ratings'),
                  _Badge(label: '${detail.stats.totalReviews} reviews'),
                  _Badge(label: '${detail.stats.totalSaves} saves'),
                  if (recipe.isPublic) const _Badge(label: 'Public'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push(
                        '/log-meal',
                        extra: {
                          'recipe': recipe.toJson(),
                          'mealType': MealType.other.name,
                        },
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Log now'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openPlannerForRecipe(recipe),
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Plan it'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(5, (index) {
                          final rating = index + 1;
                          final selected = detail.myRating == rating;
                          return ChoiceChip(
                            label: Text('$rating star${rating == 1 ? '' : 's'}'),
                            selected: selected,
                            onSelected: (_) => ref
                                .read(communityActionProvider.notifier)
                                .setRating(recipeId: recipe.id, rating: rating),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: () => ref
                            .read(communityActionProvider.notifier)
                            .toggleSave(
                              recipeId: recipe.id,
                              shouldSave: !detail.isSaved,
                            ),
                        icon: Icon(
                          detail.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border_outlined,
                        ),
                        label: Text(detail.isSaved ? 'Saved' : 'Save recipe'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _reviewFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leave a review',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _reviewController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'What worked well? What would you change?',
                          ),
                          validator: (value) =>
                              Validators.required(value, fieldName: 'Review'),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: actionState is AsyncLoading
                              ? null
                              : () async {
                                  if (!(_reviewFormKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  await ref
                                      .read(communityActionProvider.notifier)
                                      .addReview(
                                        recipeId: recipe.id,
                                        content: _reviewController.text,
                                      );
                                  _reviewController.clear();
                                },
                          child: const Text('Post review'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _RecipeSection(
                title: 'Ingredients',
                child: Column(
                  children: recipe.ingredients
                      .map(
                        (ingredient) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(ingredient.name),
                          subtitle: Text(
                            [
                              if (ingredient.quantity != null)
                                ingredient.quantity!.toStringAsFixed(
                                  ingredient.quantity! % 1 == 0 ? 0 : 1,
                                ),
                              if (ingredient.unit != null) ingredient.unit!,
                              ingredient.category ?? 'Other',
                            ].join(' | '),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              _RecipeSection(
                title: 'Instructions',
                child: Column(
                  children: recipe.instructions
                      .asMap()
                      .entries
                      .map(
                        (entry) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 14,
                            child: Text('${entry.key + 1}'),
                          ),
                          title: Text(entry.value),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              _RecipeSection(
                title: 'Reviews',
                child: detail.reviews.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('No reviews yet. Be the first one.'),
                      )
                    : Column(
                        children: detail.reviews
                            .map(
                              (review) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(review.authorName ?? 'Cook'),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(review.content),
                                ),
                                trailing: review.userId == currentUserId
                                    ? PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            await _showEditReviewDialog(
                                              context,
                                              recipe.id,
                                              review.id,
                                              review.content,
                                            );
                                          } else if (value == 'delete') {
                                            await ref
                                                .read(
                                                  communityActionProvider
                                                      .notifier,
                                                )
                                                .deleteReview(
                                                  recipeId: recipe.id,
                                                  reviewId: review.id,
                                                );
                                          }
                                        },
                                        itemBuilder: (_) => const [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit'),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        '${review.createdAt.month}/${review.createdAt.day}',
                                      ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditReviewDialog(
    BuildContext context,
    String recipeId,
    String reviewId,
    String initialContent,
  ) async {
    final controller = TextEditingController(text: initialContent);
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit review'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            validator: (value) =>
                Validators.required(value, fieldName: 'Review'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await ref.read(communityActionProvider.notifier).updateReview(
                recipeId: recipeId,
                reviewId: reviewId,
                content: controller.text,
              );
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
  }
}

class _RecipeSection extends StatelessWidget {
  const _RecipeSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label),
    );
  }
}
