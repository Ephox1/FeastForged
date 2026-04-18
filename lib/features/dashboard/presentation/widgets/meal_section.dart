import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/nutrition/domain/meal_log_entry.dart';
import '../../../../features/nutrition/providers/nutrition_provider.dart';
import '../../../../shared/widgets/recipe_cover_image.dart';

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType.label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sectionCalories.toInt()} kcal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add recipe',
                  onPressed: onAddPressed,
                ),
              ],
            ),
          ),
          if (entries.isNotEmpty) const Divider(height: 1),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      'Nothing logged yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onAddPressed,
                      icon: const Icon(Icons.add),
                      label: const Text('Add recipe'),
                    ),
                  ],
                ),
              ),
            ),
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
      leading: RecipeTitleThumb(title: entry.recipeTitle),
      title: Text(
        entry.recipeTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${entry.servings.toStringAsFixed(entry.servings % 1 == 0 ? 0 : 1)} servings',
      ),
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
