import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/error_messages.dart';
import '../../../nutrition/domain/meal_log_entry.dart';
import '../../../recipes/domain/recipe.dart';
import '../../../recipes/providers/recipe_provider.dart';
import '../../domain/meal_plan.dart';
import '../../providers/meal_plan_provider.dart';

class WeeklyPlannerScreen extends ConsumerWidget {
  const WeeklyPlannerScreen({super.key, this.recipeToSeed});

  final Map<String, dynamic>? recipeToSeed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(currentWeekPlanProvider);
    final entriesAsync = ref.watch(currentWeekEntriesProvider);
    final completedPlanEntryIds = ref.watch(todayCompletedPlanEntryIdsProvider);
    final recipesAsync = ref.watch(myRecipesProvider);

    ref.listen(mealPlanEditorProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.friendly(next.error)),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly planner')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentWeekPlanProvider);
          ref.invalidate(currentWeekEntriesProvider);
          ref.invalidate(myRecipesProvider);
        },
        child: planAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Could not load plan: $error')),
          data: (plan) {
            if (plan == null) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 80),
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No plan exists for this week yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create the current week in Supabase and start assigning recipes by day.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => ref
                        .read(mealPlanEditorProvider.notifier)
                        .createCurrentWeekPlan(),
                    child: const Text('Create this week'),
                  ),
                ],
              );
            }

            return entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Could not load entries: $error')),
              data: (entries) {
                final entriesByDay = <int, List<MealPlanEntry>>{};
                for (final entry in entries) {
                  entriesByDay.putIfAbsent(entry.dayOfWeek, () => []).add(entry);
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_formatDate(plan.startDate)} - ${_formatDate(plan.endDate)}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(7, (index) {
                      final dayEntries = entriesByDay[index] ?? const [];
                      return _PlannerDayCard(
                        dayOfWeek: index,
                        entries: dayEntries,
                        completedPlanEntryIds: completedPlanEntryIds,
                        recipesAsync: recipesAsync,
                        onAdd: (recipe, mealType) => ref
                            .read(mealPlanEditorProvider.notifier)
                            .addEntry(
                              mealPlanId: plan.id,
                              recipeId: recipe.id,
                              dayOfWeek: index,
                              mealType: mealType,
                              servings: 1,
                            ),
                        onDelete: (entryId) => ref
                            .read(mealPlanEditorProvider.notifier)
                            .deleteEntry(entryId),
                      );
                    }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.month}/${date.day}/${date.year}';
}

class _PlannerDayCard extends StatelessWidget {
  const _PlannerDayCard({
    required this.dayOfWeek,
    required this.entries,
    required this.completedPlanEntryIds,
    required this.recipesAsync,
    required this.onAdd,
    required this.onDelete,
  });

  final int dayOfWeek;
  final List<MealPlanEntry> entries;
  final Set<String> completedPlanEntryIds;
  final AsyncValue<List<Recipe>> recipesAsync;
  final void Function(Recipe recipe, PlannerMealType mealType) onAdd;
  final void Function(String entryId) onDelete;

  @override
  Widget build(BuildContext context) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    days[dayOfWeek],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<PlannerMealType>(
                  onSelected: (mealType) => _showRecipePicker(
                    context,
                    mealType,
                    recipesAsync,
                    onAdd,
                  ),
                  itemBuilder: (_) => PlannerMealType.values
                      .map(
                        (mealType) => PopupMenuItem(
                          value: mealType,
                          child: Text('Add ${mealType.label}'),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              Text(
                'No meals planned yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ...entries.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.recipe?.title ?? 'Recipe'),
                subtitle: Text(
                  '${entry.mealType.label} | ${entry.servings} serving${entry.servings == 1 ? '' : 's'}',
                ),
                leading: Icon(
                  completedPlanEntryIds.contains(entry.id)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: completedPlanEntryIds.contains(entry.id)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    if (entry.recipe != null && _isToday(dayOfWeek))
                      IconButton(
                        icon: Icon(
                          completedPlanEntryIds.contains(entry.id)
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                        ),
                        tooltip: 'Log as eaten',
                        onPressed: completedPlanEntryIds.contains(entry.id)
                            ? null
                            : () => context.push(
                                  '/log-meal',
                                  extra: {
                                    'recipe': entry.recipe!.toJson(),
                                    'mealType':
                                        _mealTypeFor(entry.mealType).name,
                                    'mealPlanEntryId': entry.id,
                                    'servings': entry.servings,
                                  },
                                ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => onDelete(entry.id),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRecipePicker(
    BuildContext context,
    PlannerMealType mealType,
    AsyncValue<List<Recipe>> recipesAsync,
    void Function(Recipe recipe, PlannerMealType mealType) onAdd,
  ) async {
    final recipes = recipesAsync.valueOrNull ?? const <Recipe>[];
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a recipe first, then plan it.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: recipes
              .map(
                (recipe) => ListTile(
                  title: Text(recipe.title),
                  subtitle: Text(
                    '${recipe.caloriesPerServing.toStringAsFixed(0)} kcal/serving',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onAdd(recipe, mealType);
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }

  bool _isToday(int plannerDayOfWeek) => DateTime.now().weekday - 1 == plannerDayOfWeek;

  MealType _mealTypeFor(PlannerMealType mealType) => switch (mealType) {
    PlannerMealType.breakfast => MealType.breakfast,
    PlannerMealType.lunch => MealType.lunch,
    PlannerMealType.dinner => MealType.dinner,
    PlannerMealType.snack => MealType.snack,
  };
}
