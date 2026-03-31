import '../../../core/supabase/supabase_client.dart';
import '../domain/food_item.dart';
import '../domain/meal_log_entry.dart';

class NutritionRepository {
  const NutritionRepository();

  // ── Food items ──────────────────────────────────────────────────────────────

  Future<List<FoodItem>> searchFoods(String query) async {
    if (query.trim().isEmpty) return [];

    final userId = supabase.auth.currentUser?.id;

    final data = await supabase
        .from('food_items')
        .select()
        .or('name.ilike.%$query%,brand.ilike.%$query%')
        .or('is_custom.eq.false,user_id.eq.$userId')
        .limit(30);

    return (data as List)
        .map((json) => FoodItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<FoodItem> createCustomFood(FoodItem food) async {
    final data = await supabase
        .from('food_items')
        .insert(food.toJson())
        .select()
        .single();
    return FoodItem.fromJson(data);
  }

  // ── Meal log entries ─────────────────────────────────────────────────────────

  Future<List<MealLogEntry>> fetchLogsForDate(DateTime date) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final dayStart = DateTime(date.year, date.month, date.day).toUtc();
    final dayEnd = dayStart.add(const Duration(days: 1));

    final data = await supabase
        .from('meal_log_entries')
        .select()
        .eq('user_id', userId)
        .gte('logged_at', dayStart.toIso8601String())
        .lt('logged_at', dayEnd.toIso8601String())
        .order('logged_at');

    return (data as List)
        .map((json) => MealLogEntry.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<MealLogEntry> addLogEntry(MealLogEntry entry) async {
    final data = await supabase
        .from('meal_log_entries')
        .insert(entry.toJson())
        .select()
        .single();
    return MealLogEntry.fromJson(data);
  }

  Future<void> deleteLogEntry(String entryId) async {
    await supabase
        .from('meal_log_entries')
        .delete()
        .eq('id', entryId);
  }
}
