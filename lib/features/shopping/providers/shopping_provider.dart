import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/shopping_repository.dart';

final shoppingRepositoryProvider = Provider<ShoppingRepository>(
  (_) => const ShoppingRepository(),
);

final shoppingListsProvider = FutureProvider<List<ShoppingList>>((ref) async {
  return ref.watch(shoppingRepositoryProvider).fetchShoppingLists();
});
