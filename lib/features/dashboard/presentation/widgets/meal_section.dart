import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/nutrition/domain/meal_log_entry.dart';
import '../../../../features/nutrition/providers/nutrition_provider.dart';

class MealSection extends ConsumerWidget {
  const MealSection({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onAddPressed,
  });

  final MealType mealType;
  final List<MealLogEntry> entries;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionCalories = entries.fold<double>(
      0,
      (sum, e) => sum + e.calories,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text(
              mealType.label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${sectionCalories.toInt()} kcal',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add food',
              onPressed: onAddPressed,
            ),
          ),
          if (entries.isNotEmpty) const Divider(height: 1),
          ...entries.map((entry) => _FoodLogTile(entry: entry)),
        ],
      ),
    );
  }
}

class _FoodLogTile extends ConsumerWidget {
  const _FoodLogTile({required this.entry});

  final MealLogEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(entry.foodName),
      subtitle: Text('${entry.amountGrams.toInt()}g'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${entry.calories.toInt()} kcal',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Remove',
            onPressed: () =>
                ref.read(mealLoggerProvider.notifier).deleteEntry(entry.id),
          ),
        ],
      ),
    );
  }
}
