import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/error_messages.dart';
import '../../../nutrition/domain/meal_log_entry.dart';
import '../../domain/meal_plan.dart';
import '../../providers/meal_plan_provider.dart';

class WeeklyPlannerScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                    recipeToSeedTitle: recipeToSeed?['title'] as String?,
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    7,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _PlannerDaySection(
                        label: _dayLabels[index],
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
  });

  final int totalCount;
  final int completedCount;
  final String? recipeToSeedTitle;

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
            LinearProgressIndicator(value: progress),
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
              const SizedBox(height: 14),
              Text(
                'Selected from recipes: $recipeToSeedTitle',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  const _EmptyPlannerState({required this.onCreate});

  final VoidCallback onCreate;

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
          'Create the week and start assigning recipes to your days.',
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
