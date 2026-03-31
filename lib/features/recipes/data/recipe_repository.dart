import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../domain/recipe.dart';

class RecipeRepository {
  const RecipeRepository();

  Future<List<Recipe>> fetchMyRecipes() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('recipes')
        .select()
        .eq('created_by', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Recipe>> fetchPublicRecipes() async {
    final data = await supabase
        .from('recipes')
        .select()
        .eq('is_public', true)
        .order('created_at', ascending: false)
        .limit(20);

    return (data as List)
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Recipe> saveRecipe(Recipe recipe) async {
    final data = await supabase
        .from('recipes')
        .upsert(recipe.toJson(), onConflict: 'id')
        .select()
        .single();

    return Recipe.fromJson(data);
  }

  Future<void> deleteRecipe(String recipeId) async {
    await supabase.from('recipes').delete().eq('id', recipeId);
  }

  String requireUserId() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    return userId;
  }
}
