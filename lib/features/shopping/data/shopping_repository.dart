import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_client.dart';

class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.mealPlanId,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  final String id;
  final String mealPlanId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ShoppingListItem> items;

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
    id: json['id'] as String,
    mealPlanId: json['meal_plan_id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    items: ((json['shopping_list_items'] as List?) ?? const [])
        .map((item) => ShoppingListItem.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class ShoppingListItem {
  const ShoppingListItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
    this.section = 'Other',
    this.checked = false,
  });

  final String id;
  final String name;
  final double quantity;
  final String? unit;
  final String section;
  final bool checked;

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) =>
      ShoppingListItem(
        id: json['id'] as String,
        name: json['name'] as String,
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        unit: json['unit'] as String?,
        section: json['section'] as String? ?? 'Other',
        checked: json['checked'] as bool? ?? false,
      );
}

class ShoppingRepository {
  const ShoppingRepository();

  Future<List<ShoppingList>> fetchShoppingLists() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('shopping_lists')
        .select('*, meal_plans!inner(user_id), shopping_list_items(*)')
        .eq('meal_plans.user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((item) => ShoppingList.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
