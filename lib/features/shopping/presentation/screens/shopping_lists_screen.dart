import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shopping_provider.dart';

class ShoppingListsScreen extends ConsumerWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingLists = ref.watch(shoppingListsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping lists')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(shoppingListsProvider),
        child: shoppingLists.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Could not load lists: $error')),
          data: (lists) {
            if (lists.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No shopping lists yet. Once lists are generated in Supabase, they will appear here.',
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: lists
                  .map(
                    (list) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text('Shopping list ${list.id.substring(0, 8)}'),
                        subtitle: Text('${list.items.length} items'),
                        children: list.items
                            .map(
                              (item) => CheckboxListTile(
                                value: item.checked,
                                onChanged: null,
                                title: Text(item.name),
                                subtitle: Text(
                                  '${item.quantity}${item.unit == null ? '' : ' ${item.unit}'} | ${item.section}',
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

