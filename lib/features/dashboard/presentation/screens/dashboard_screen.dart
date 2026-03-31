import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_profile.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/profile_provider.dart';
import '../../../nutrition/domain/meal_log_entry.dart';
import '../../../nutrition/providers/nutrition_provider.dart';
import '../widgets/macro_ring.dart';
import '../widgets/meal_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final logsAsync = ref.watch(todayLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FeastForged'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Edit targets',
            onPressed: () => context.push('/profile/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/food-search?mealType=other'),
        icon: const Icon(Icons.add),
        label: const Text('Log food'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayLogsProvider);
          ref.invalidate(currentProfileProvider);
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
                final totals = logs.totals;
                final hasEntries = logs.isNotEmpty;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [
                    Text(
                      _todayLabel(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasEntries
                          ? 'You are building momentum today.'
                          : 'Let’s get today started with one easy meal log.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 18),
                    _GoalStatusCard(profile: profile, totals: totals),
                    const SizedBox(height: 20),
                    MacroRing(
                      consumed: totals.calories,
                      target: profile.dailyCalorieTarget.toDouble(),
                      protein: totals.protein,
                      proteinTarget: profile.dailyProteinTarget.toDouble(),
                      carbs: totals.carbs,
                      carbsTarget: profile.dailyCarbTarget.toDouble(),
                      fat: totals.fat,
                      fatTarget: profile.dailyFatTarget.toDouble(),
                    ),
                    const SizedBox(height: 20),
                    if (!hasEntries) ...[
                      _DashboardEmptyState(profile: profile),
                      const SizedBox(height: 20),
                    ],
                    ...MealType.values.map(
                      (mealType) => MealSection(
                        mealType: mealType,
                        entries: logs.forMealType(mealType),
                        onAddPressed: () => context.push(
                          '/food-search?mealType=${mealType.name}',
                        ),
                      ),
                    ),
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
  final DailyTotals totals;

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
            'Today\'s plan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caloriesRemaining >= 0
                ? '${caloriesRemaining.toInt()} kcal remaining to hit your target'
                : '${caloriesRemaining.abs().toInt()} kcal over target so far',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _TargetPill(
                label: 'Goal',
                value: profile.goal.label,
                icon: Icons.flag_outlined,
              ),
              _TargetPill(
                label: 'Protein',
                value: '${profile.dailyProteinTarget}g',
                icon: Icons.fitness_center_outlined,
              ),
              _TargetPill(
                label: 'Carbs',
                value: '${profile.dailyCarbTarget}g',
                icon: Icons.grain_outlined,
              ),
              _TargetPill(
                label: 'Fat',
                value: '${profile.dailyFatTarget}g',
                icon: Icons.opacity_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetPill extends StatelessWidget {
  const _TargetPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Column(
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
        ],
      ),
    );
  }
}

class _DashboardEmptyState extends StatelessWidget {
  const _DashboardEmptyState({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No meals logged yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start with one simple meal. Your target today is ${profile.dailyCalorieTarget} kcal and we’ll keep the dashboard updated as you go.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => context.push('/food-search?mealType=breakfast'),
                  icon: const Icon(Icons.breakfast_dining_outlined),
                  label: const Text('Log breakfast'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/profile/edit'),
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Adjust targets'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
