import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_profile.dart';
import '../../../../core/utils/macro_calculator.dart';
import '../../../auth/providers/profile_provider.dart';
import '../../../nutrition/domain/meal_log_entry.dart';
import '../../../nutrition/providers/nutrition_provider.dart';
import '../../../planner/domain/meal_plan.dart';
import '../../../planner/providers/meal_plan_provider.dart';
import '../widgets/macro_ring.dart';
import '../widgets/meal_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final logsAsync = ref.watch(todayLogsProvider);
    final plannedEntries = ref.watch(todayPlannedEntriesProvider);
    final plannedMacros = ref.watch(todayPlannedMacrosProvider);
    final completedPlanEntryIds = ref.watch(todayCompletedPlanEntryIdsProvider);
    final completionCount = ref.watch(todayCompletionCountProvider);
    final weeklyPlan = ref.watch(currentWeekPlanProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/food-search?mealType=other'),
        icon: const Icon(Icons.add),
        label: const Text('Log recipe'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayLogsProvider);
          ref.invalidate(currentProfileProvider);
          ref.invalidate(currentWeekPlanProvider);
          ref.invalidate(currentWeekEntriesProvider);
          ref.invalidate(popularFoodsProvider);
          ref.invalidate(recentFoodsProvider);
        },
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading profile: $e')),
          data: (profile) {
            if (profile == null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => context.go('/auth/onboarding'),
              );
              return const SizedBox.shrink();
            }

            return logsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading logs: $e')),
              data: (logs) {
                final loggedTotals = logs.totals;
                final hasPlannedMeals = plannedEntries.isNotEmpty;
                final combinedMacros = DailyMacros(
                  calories: plannedMacros.calories + loggedTotals.calories,
                  protein: plannedMacros.protein + loggedTotals.protein,
                  carbs: plannedMacros.carbs + loggedTotals.carbs,
                  fat: plannedMacros.fat + loggedTotals.fat,
                );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
                  children: [
                    Text(
                      _todayLabel(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasPlannedMeals
                          ? 'Today is anchored by your weekly plan.'
                          : 'Start today with a plan or a quick recipe log.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 18),
                    _GoalStatusCard(profile: profile, totals: combinedMacros),
                    const SizedBox(height: 20),
                    MacroRing(
                      consumed: combinedMacros.calories,
                      target: profile.dailyCalorieTarget.toDouble(),
                      protein: combinedMacros.protein,
                      proteinTarget: profile.dailyProteinTarget.toDouble(),
                      carbs: combinedMacros.carbs,
                      carbsTarget: profile.dailyCarbTarget.toDouble(),
                      fat: combinedMacros.fat,
                      fatTarget: profile.dailyFatTarget.toDouble(),
                    ),
                    const SizedBox(height: 20),
                    _PlannerSummaryCard(
                      profile: profile,
                      plannedEntries: plannedEntries,
                      completedPlanEntryIds: completedPlanEntryIds,
                      completionCount: completionCount,
                      planExists: weeklyPlan.valueOrNull != null,
                    ),
                    const SizedBox(height: 20),
                    _LoggedFoodsCard(logs: logs),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

class _GoalStatusCard extends StatelessWidget {
  const _GoalStatusCard({required this.profile, required this.totals});

  final UserProfile profile;
  final DailyMacros totals;

  @override
  Widget build(BuildContext context) {
    final caloriesRemaining = profile.dailyCalorieTarget - totals.calories;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s target',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caloriesRemaining >= 0
                ? '${caloriesRemaining.toInt()} kcal remaining across planned and logged meals'
                : '${caloriesRemaining.abs().toInt()} kcal over target so far',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _TargetPill(label: 'Goal', value: profile.goal.label),
              _TargetPill(
                label: 'Protein',
                value: '${profile.dailyProteinTarget}g',
              ),
              _TargetPill(
                label: 'Carbs',
                value: '${profile.dailyCarbTarget}g',
              ),
              _TargetPill(label: 'Fat', value: '${profile.dailyFatTarget}g'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlannerSummaryCard extends StatelessWidget {
  const _PlannerSummaryCard({
    required this.profile,
    required this.plannedEntries,
    required this.completedPlanEntryIds,
    required this.completionCount,
    required this.planExists,
  });

  final UserProfile profile;
  final List<MealPlanEntry> plannedEntries;
  final Set<String> completedPlanEntryIds;
  final int completionCount;
  final bool planExists;

  @override
  Widget build(BuildContext context) {
    if (!planExists) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly planner',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have a weekly meal plan yet. Create one and the dashboard will use it as the main source for today.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go('/app/planner'),
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Open planner'),
              ),
            ],
          ),
        ),
      );
    }

    if (plannedEntries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s planned meals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No recipes are planned for today yet. Add recipes in the planner to turn this into your main dashboard feed.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.go('/app/planner'),
                icon: const Icon(Icons.add),
                label: const Text('Plan today'),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = <PlannerMealType, List<MealPlanEntry>>{};
    for (final entry in plannedEntries) {
      grouped.putIfAbsent(entry.mealType, () => []).add(entry);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Today\'s planned meals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/app/planner'),
                  child: const Text('Planner'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$completionCount of ${plannedEntries.length} planned meals logged today',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ...PlannerMealType.values
                .where((mealType) => grouped.containsKey(mealType))
                .map(
                  (mealType) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealType.label,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        ...grouped[mealType]!.map(
                          (entry) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(entry.recipe?.title ?? 'Recipe'),
                            subtitle: Text(
                              '${entry.servings} serving${entry.servings == 1 ? '' : 's'} | ${((entry.recipe?.caloriesPerServing ?? 0) * entry.servings).toStringAsFixed(0)} kcal',
                            ),
                            leading: Icon(
                              completedPlanEntryIds.contains(entry.id)
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: completedPlanEntryIds.contains(entry.id)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            trailing: entry.recipe == null
                                ? null
                                : SizedBox(
                                    width: 76,
                                    child: FilledButton.tonal(
                                      onPressed: completedPlanEntryIds.contains(
                                        entry.id,
                                      )
                                          ? null
                                          : () => context.push(
                                              '/log-meal',
                                              extra: {
                                                'recipe':
                                                    entry.recipe!.toJson(),
                                                'mealType':
                                                    _mealTypeFor(entry.mealType)
                                                        .name,
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
                          ),
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

class _LoggedFoodsCard extends StatelessWidget {
  const _LoggedFoodsCard({required this.logs});

  final List<MealLogEntry> logs;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Logged recipes today',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/food-search?mealType=other'),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (logs.isEmpty)
              Text(
                'No manual recipe logs yet today.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ...MealType.values.map(
              (mealType) => MealSection(
                mealType: mealType,
                entries: logs.forMealType(mealType),
                onAddPressed: () =>
                    context.push('/food-search?mealType=${mealType.name}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetPill extends StatelessWidget {
  const _TargetPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
