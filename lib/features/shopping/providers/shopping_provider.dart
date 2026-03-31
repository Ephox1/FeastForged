import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../planner/domain/meal_plan.dart';
import '../data/shopping_repository.dart';

final shoppingRepositoryProvider = Provider<ShoppingRepository>(
  (_) => const ShoppingRepository(),
);

final shoppingListsProvider = FutureProvider<List<ShoppingList>>((ref) async {
  return ref.watch(shoppingRepositoryProvider).fetchShoppingLists();
});

class _ShoppingEditorNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> generateFromPlan({
    required MealPlan mealPlan,
    required List<MealPlanEntry> entries,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(shoppingRepositoryProvider)
          .generateShoppingList(mealPlan: mealPlan, entries: entries);
      ref.invalidate(shoppingListsProvider);
    });
  }

  Future<void> updateChecked({
    required String itemId,
    required bool checked,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(shoppingRepositoryProvider)
          .updateItemChecked(itemId: itemId, checked: checked);
      ref.invalidate(shoppingListsProvider);
    });
  }
}

final shoppingEditorProvider =
    AsyncNotifierProvider<_ShoppingEditorNotifier, void>(
      _ShoppingEditorNotifier.new,
    );
