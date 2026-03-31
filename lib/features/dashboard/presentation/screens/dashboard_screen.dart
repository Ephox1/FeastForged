import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayLogsProvider);
          ref.invalidate(currentProfileProvider);
        },
        child: profileAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Center(child: Text('Error loading profile: $e')),
          data: (profile) {
            if (profile == null) {
              // Hasn't completed onboarding
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => context.go('/auth/onboarding'),
              );
              return const SizedBox.shrink();
            }

            return logsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error loading logs: $e')),
              data: (logs) {
                final totals = logs.totals;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Date header
                    Text(
                      _todayLabel(),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hello! Here\'s your nutrition today.',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Calorie ring
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
                    const SizedBox(height: 24),

                    // Meal sections
                    ...MealType.values.map(
                      (mealType) => MealSection(
                        mealType: mealType,
                        entries: logs.forMealType(mealType),
                        onAddPressed: () => context.push(
                          '/food-search?mealType=${mealType.name}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
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
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
      'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
