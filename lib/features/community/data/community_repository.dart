import '../../../../core/supabase/supabase_client.dart';
import '../../recipes/domain/recipe.dart';

class CommunityRepository {
  const CommunityRepository();

  Future<List<Recipe>> fetchCommunityRecipes() async {
    final data = await supabase
        .from('recipes')
        .select('*, community_recipe_stats(*)')
        .eq('is_public', true)
        .order('created_at', ascending: false)
        .limit(30);

    return (data as List)
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
