import '../../../core/supabase/supabase_client.dart';
import '../../recipes/domain/recipe.dart';
import '../domain/meal_log_entry.dart';

class NutritionRepository {
  const NutritionRepository();

  Future<List<Recipe>> searchRecipes(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final userId = supabase.auth.currentUser?.id;
    final escapedQuery = trimmed.replaceAll(',', ' ');

    final data = await (userId != null
        ? supabase
        .from('recipes')
        .select()
        .or('title.ilike.%$escapedQuery%,description.ilike.%$escapedQuery%')
        .or('created_by.eq.$userId,is_public.eq.true')
        .order('is_public', ascending: false)
        .order('downloads', ascending: false)
        .limit(30)
        : supabase
              .from('recipes')
              .select()
              .or('title.ilike.%$escapedQuery%,description.ilike.%$escapedQuery%')
              .eq('is_public', true)
              .order('downloads', ascending: false)
              .limit(30));
    return (data as List)
        .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Recipe>> fetchPopularRecipes() async {
    final userId = supabase.auth.currentUser?.id;
    final data = await (userId != null
        ? supabase
              .from('recipes')
              .select()
              .or('created_by.eq.$userId,is_public.eq.true')
              .order('downloads', ascending: false)
              .order('created_at', ascending: false)
              .limit(12)
        : supabase
              .from('recipes')
              .select()
              .eq('is_public', true)
              .order('downloads', ascending: false)
              .order('created_at', ascending: false)
              .limit(12));
    return (data as List)
        .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Recipe> createQuickRecipe(Recipe recipe) async {
    final data = await supabase
        .from('recipes')
        .insert(recipe.toJson())
        .select()
        .single();
    return Recipe.fromJson(data);
  }

  Future<List<MealLogEntry>> fetchLogsForDate(DateTime date) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final dayStart = DateTime(date.year, date.month, date.day).toUtc();
    final dayEnd = dayStart.add(const Duration(days: 1));

    final data = await supabase
        .from('recipe_log_entries')
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
        .from('recipe_log_entries')
        .insert(entry.toJson())
        .select()
        .single();
    return MealLogEntry.fromJson(data);
  }

  Future<void> deleteLogEntry(String entryId) async {
    await supabase.from('recipe_log_entries').delete().eq('id', entryId);
  }
}
