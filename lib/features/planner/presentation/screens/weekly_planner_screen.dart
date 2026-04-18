import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/widgets/recipe_cover_image.dart';
import '../../../nutrition/domain/meal_log_entry.dart';
import '../../domain/meal_plan.dart';
import '../../providers/meal_plan_provider.dart';

class WeeklyPlannerScreen extends ConsumerStatefulWidget {
  const WeeklyPlannerScreen({super.key, this.recipeToSeed});

  final Map<String, dynamic>? recipeToSeed;

  static const _dayLabels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  ConsumerState<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends ConsumerState<WeeklyPlannerScreen> {
  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(currentWeekPlanProvider);
    final entriesAsync = ref.watch(currentWeekEntriesProvider);
    final completedPlanEntryIds = ref.watch(todayCompletedPlanEntryIdsProvider);

    ref.listen(mealPlanEditorProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.friendly(next.error))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly planner')),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _PlannerMessage(
          title: 'Could not load your plan',
          body: '$error',
        ),
        data: (plan) {
          if (plan == null) {
            return _EmptyPlannerState(
              selectedRecipeTitle: widget.recipeToSeed?['title'] as String?,
              onCreate: () =>
                  ref.read(mealPlanEditorProvider.notifier).createCurrentWeekPlan(),
            );
          }

          return entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _PlannerMessage(
              title: 'Could not load your meals',
              body: '$error',
            ),
            data: (entries) {
              final entriesByDay = <int, List<MealPlanEntry>>{};
              for (final entry in entries) {
                entriesByDay.putIfAbsent(entry.dayOfWeek, () => []).add(entry);
              }

              final completedCount = entries
                  .where((entry) => completedPlanEntryIds.contains(entry.id))
                  .length;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _PlanHeaderCard(plan: plan),
                  const SizedBox(height: 16),
                  _PlannerSummaryCard(
                    totalCount: entries.length,
                    completedCount: completedCount,
                    recipeToSeedTitle: widget.recipeToSeed?['title'] as String?,
                    onPlanSelectedRecipe: widget.recipeToSeed?['id'] == null
                        ? null
                        : () => _showPlanRecipeSheet(
                              context,
                              plan,
                              widget.recipeToSeed!,
                            ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    7,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _PlannerDaySection(
                        label: WeeklyPlannerScreen._dayLabels[index],
                        entries: entriesByDay[index] ?? const [],
                        isToday: DateTime.now().weekday - 1 == index,
                        completedPlanEntryIds: completedPlanEntryIds,
                        onDelete: (entryId) => ref
                            .read(mealPlanEditorProvider.notifier)
                            .deleteEntry(entryId),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showPlanRecipeSheet(
    BuildContext context,
    MealPlan plan,
    Map<String, dynamic> recipeToSeed,
  ) async {
    final recipeId = recipeToSeed['id'] as String?;
    final recipeTitle = recipeToSeed['title'] as String? ?? 'Recipe';
    if (recipeId == null) return;

    var selectedDay = plannerDayOfWeekFor(DateTime.now());
    var selectedMealType = PlannerMealType.dinner;
    var servings = 1;
    var isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add to this week',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipeTitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Day',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        WeeklyPlannerScreen._dayLabels.length,
                        (index) => ChoiceChip(
                          label: Text(WeeklyPlannerScreen._dayLabels[index]),
                          selected: selectedDay == index,
                          onSelected: (_) =>
                              setModalState(() => selectedDay = index),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Meal slot',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PlannerMealType.values
                          .map(
                            (mealType) => ChoiceChip(
                              label: Text(mealType.label),
                              selected: selectedMealType == mealType,
                              onSelected: (_) => setModalState(
                                () => selectedMealType = mealType,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Servings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('1')),
                        ButtonSegment(value: 2, label: Text('2')),
                        ButtonSegment(value: 3, label: Text('3')),
                        ButtonSegment(value: 4, label: Text('4')),
                      ],
                      selected: {servings},
                      onSelectionChanged: (selection) => setModalState(
                        () => servings = selection.first,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setModalState(() => isSubmitting = true);
                                await ref
                                    .read(mealPlanEditorProvider.notifier)
                                    .addEntry(
                                      mealPlanId: plan.id,
                                      recipeId: recipeId,
                                      dayOfWeek: selectedDay,
                                      mealType: selectedMealType,
                                      servings: servings,
                                    );
                                if (!context.mounted || !sheetContext.mounted) {
                                  return;
                                }
                                if (ref.read(mealPlanEditorProvider) case AsyncError()) {
                                  setModalState(() => isSubmitting = false);
                                  return;
                                }
                                Navigator.of(sheetContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$recipeTitle added to ${WeeklyPlannerScreen._dayLabels[selectedDay]} ${selectedMealType.label.toLowerCase()}.',
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(
                          isSubmitting ? 'Saving...' : 'Add to weekly plan',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PlanHeaderCard extends StatelessWidget {
  const _PlanHeaderCard({required this.plan});

  final MealPlan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${plan.startDate.month}/${plan.startDate.day}/${plan.startDate.year} - ${plan.endDate.month}/${plan.endDate.day}/${plan.endDate.year}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerSummaryCard extends StatelessWidget {
  const _PlannerSummaryCard({
    required this.totalCount,
    required this.completedCount,
    required this.recipeToSeedTitle,
    required this.onPlanSelectedRecipe,
  });

  final int totalCount;
  final int completedCount;
  final String? recipeToSeedTitle;
  final VoidCallback? onPlanSelectedRecipe;

  @override
  Widget build(BuildContext context) {
    final remaining = totalCount - completedCount;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This week at a glance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount of $totalCount planned meals have been logged.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SummaryPill(label: 'Completed', value: '$completedCount'),
                _SummaryPill(label: 'Remaining', value: '$remaining'),
              ],
            ),
            if (recipeToSeedTitle != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected from recipes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipeToSeedTitle!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: onPlanSelectedRecipe,
                      icon: const Icon(Icons.add_task),
                      label: const Text('Add this recipe to the week'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlannerDaySection extends StatelessWidget {
  const _PlannerDaySection({
    required this.label,
    required this.entries,
    required this.isToday,
    required this.completedPlanEntryIds,
    required this.onDelete,
  });

  final String label;
  final List<MealPlanEntry> entries;
  final bool isToday;
  final Set<String> completedPlanEntryIds;
  final Future<void> Function(String entryId) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (entries.isEmpty)
              Text(
                'No meals planned yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ...entries.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        RecipeTitleThumb(
                          title: entry.recipe?.title ?? 'Recipe',
                          size: 64,
                          borderRadius: 18,
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            child: Icon(
                              completedPlanEntryIds.contains(entry.id)
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 18,
                              color: completedPlanEntryIds.contains(entry.id)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.recipe?.title ?? 'Recipe',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.mealType.label} | ${entry.servings} serving${entry.servings == 1 ? '' : 's'}',
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
                    if (entry.recipe != null && isToday)
                      SizedBox(
                        width: 76,
                        child: FilledButton.tonal(
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
                          child: Text(
                            completedPlanEntryIds.contains(entry.id)
                                ? 'Done'
                                : 'Log',
                          ),
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

  MealType _mealTypeFor(PlannerMealType mealType) => switch (mealType) {
    PlannerMealType.breakfast => MealType.breakfast,
    PlannerMealType.lunch => MealType.lunch,
    PlannerMealType.dinner => MealType.dinner,
    PlannerMealType.snack => MealType.snack,
  };
}

class _EmptyPlannerState extends StatelessWidget {
  const _EmptyPlannerState({
    required this.onCreate,
    required this.selectedRecipeTitle,
  });

  final VoidCallback onCreate;
  final String? selectedRecipeTitle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),
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
          selectedRecipeTitle == null
              ? 'Create the week and start assigning recipes to your days.'
              : 'Create the week first, then you can add $selectedRecipeTitle right away.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onCreate,
          child: const Text('Create this week'),
        ),
      ],
    );
  }
}

class _PlannerMessage extends StatelessWidget {
  const _PlannerMessage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
