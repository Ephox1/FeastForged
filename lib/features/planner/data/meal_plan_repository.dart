import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../domain/meal_plan.dart';

class MealPlanRepository {
  const MealPlanRepository();

  Future<MealPlan?> fetchPlanForWeek(DateTime weekStart) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 6));

    final data = await supabase
        .from('meal_plans')
        .select()
        .eq('user_id', userId)
        .eq('start_date', start.toIso8601String().split('T').first)
        .eq('end_date', end.toIso8601String().split('T').first)
        .maybeSingle();

    if (data == null) return null;
    return MealPlan.fromJson(data);
  }

  Future<MealPlan> createPlanForWeek(DateTime weekStart) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 6));
    final payload = {
      'user_id': userId,
      'title': 'Weekly Meal Plan',
      'start_date': start.toIso8601String().split('T').first,
      'end_date': end.toIso8601String().split('T').first,
    };

    final data = await supabase
        .from('meal_plans')
        .insert(payload)
        .select()
        .single();

    return MealPlan.fromJson(data);
  }

  Future<List<MealPlanEntry>> fetchEntries(String mealPlanId) async {
    final data = await supabase
        .from('meal_plan_entries')
        .select('*, recipes(*)')
        .eq('meal_plan_id', mealPlanId)
        .order('day_of_week')
        .order('meal_type');

    return (data as List)
        .map((item) => MealPlanEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MealPlanEntry> addEntry({
    required String mealPlanId,
    required String recipeId,
    required int dayOfWeek,
    required PlannerMealType mealType,
    required int servings,
    String? notes,
  }) async {
    final data = await supabase
        .from('meal_plan_entries')
        .insert({
          'meal_plan_id': mealPlanId,
          'recipe_id': recipeId,
          'day_of_week': dayOfWeek,
          'meal_type': mealType.name,
          'servings': servings,
          'notes': notes,
        })
        .select('*, recipes(*)')
        .single();

    return MealPlanEntry.fromJson(data);
  }

  Future<void> deleteEntry(String entryId) async {
    await supabase.from('meal_plan_entries').delete().eq('id', entryId);
  }
}
