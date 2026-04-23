import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/error_messages.dart';
import '../../../planner/providers/meal_plan_provider.dart';
import '../../providers/shopping_provider.dart';

class ShoppingListsScreen extends ConsumerWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists = ref.watch(shoppingListsProvider);
    final shoppingEditor = ref.watch(shoppingEditorProvider);
    final currentPlan = ref.watch(currentWeekPlanProvider).valueOrNull;
    final currentEntries =
        ref.watch(currentWeekEntriesProvider).valueOrNull ?? [];

    ref.listen(shoppingEditorProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.friendly(next.error))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping lists')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(shoppingListsProvider);
          ref.invalidate(currentWeekPlanProvider);
          ref.invalidate(currentWeekEntriesProvider);
        },
        child: shoppingLists.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              Center(child: Text('Could not load lists: $error')),
          data: (lists) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan-driven shopping',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentPlan == null
                              ? 'Create a weekly plan first, then generate a shopping list from the recipes scheduled this week.'
                              : 'Generate or refresh a shopping list from your current weekly plan.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed:
                              currentPlan == null ||
                                  shoppingEditor is AsyncLoading
                              ? null
                              : () => ref
                                    .read(shoppingEditorProvider.notifier)
                                    .generateFromPlan(
                                      mealPlan: currentPlan,
                                      entries: currentEntries,
                                    ),
                          icon: const Icon(Icons.auto_awesome_outlined),
                          label: const Text('Generate from current week'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (lists.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No shopping lists yet. Generate one from the weekly planner and it will appear here.',
                      ),
                    ),
                  ),
                ...lists.map(
                  (list) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Text('Shopping list ${list.id.substring(0, 8)}'),
                      subtitle: Text('${list.items.length} items'),
                      children: list.items
                          .map(
                            (item) => CheckboxListTile(
                              value: item.checked,
                              onChanged: (value) {
                                if (value == null) return;
                                ref
                                    .read(shoppingEditorProvider.notifier)
                                    .updateChecked(
                                      itemId: item.id,
                                      checked: value,
                                    );
                              },
                              title: Text(item.name),
                              subtitle: Text(
                                '${item.quantity}${item.unit == null ? '' : ' ${item.unit}'} | ${item.section}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
