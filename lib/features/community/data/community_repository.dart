import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_client.dart';
import '../../recipes/domain/recipe.dart';

class CommunityRecipeStats {
  const CommunityRecipeStats({
    this.averageRating = 0,
    this.totalRatings = 0,
    this.totalSaves = 0,
    this.totalReviews = 0,
  });

  final double averageRating;
  final int totalRatings;
  final int totalSaves;
  final int totalReviews;

  factory CommunityRecipeStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CommunityRecipeStats();
    return CommunityRecipeStats(
      averageRating: (json['average_rating'] as num? ?? 0).toDouble(),
      totalRatings: json['total_ratings'] as int? ?? 0,
      totalSaves: json['total_saves'] as int? ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
    );
  }
}

class CommunityReview {
  const CommunityReview({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.authorName,
    this.helpfulCount = 0,
  });

  final String id;
  final String recipeId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? authorName;
  final int helpfulCount;

  factory CommunityReview.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return CommunityReview(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      helpfulCount: json['helpful_count'] as int? ?? 0,
      authorName:
          profile?['display_name'] as String? ??
          profile?['username'] as String? ??
          'Cook',
    );
  }
}

class CommunityRecipeDetail {
  const CommunityRecipeDetail({
    required this.recipe,
    required this.stats,
    required this.reviews,
    required this.isSaved,
    required this.myRating,
  });

  final Recipe recipe;
  final CommunityRecipeStats stats;
  final List<CommunityReview> reviews;
  final bool isSaved;
  final int? myRating;
}

class CommunityRepository {
  const CommunityRepository();

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  Future<List<Recipe>> fetchCommunityRecipes() async {
    final data = await supabase
        .from('recipes')
        .select('*, community_recipe_stats(*)')
        .eq('is_public', true)
        .order('downloads', ascending: false)
        .order('created_at', ascending: false)
        .limit(30);

    return (data as List)
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CommunityRecipeDetail> fetchRecipeDetail(String recipeId) async {
    final userId = _userId;

    final recipeData = await supabase
        .from('recipes')
        .select('*, community_recipe_stats(*)')
        .eq('id', recipeId)
        .single();

    final reviewsData = await supabase
        .from('community_reviews')
        .select('*, profiles(display_name, username)')
        .eq('recipe_id', recipeId)
        .order('created_at', ascending: false);

    bool isSaved = false;
    int? myRating;

    if (userId != null) {
      final saveData = await supabase
          .from('community_saves')
          .select('id')
          .eq('recipe_id', recipeId)
          .eq('user_id', userId)
          .maybeSingle();
      isSaved = saveData != null;

      final ratingData = await supabase
          .from('community_ratings')
          .select('rating')
          .eq('recipe_id', recipeId)
          .eq('user_id', userId)
          .maybeSingle();
      myRating = ratingData?['rating'] as int?;
    }

    return CommunityRecipeDetail(
      recipe: Recipe.fromJson(recipeData),
      stats: CommunityRecipeStats.fromJson(
        (recipeData['community_recipe_stats'] as List?)?.cast<Map>().isNotEmpty ==
                true
            ? ((recipeData['community_recipe_stats'] as List).first
                  as Map<String, dynamic>)
            : null,
      ),
      reviews: (reviewsData as List)
          .map((item) => CommunityReview.fromJson(item as Map<String, dynamic>))
          .toList(),
      isSaved: isSaved,
      myRating: myRating,
    );
  }

  Future<void> toggleSave(String recipeId, {required bool shouldSave}) async {
    final userId = _userId;
    if (userId == null) throw Exception('Not authenticated');

    final existing = await supabase
        .from('community_saves')
        .select('id')
        .eq('recipe_id', recipeId)
        .eq('user_id', userId)
        .maybeSingle();

    if (shouldSave && existing == null) {
      await supabase.from('community_saves').insert({
        'recipe_id': recipeId,
        'user_id': userId,
      });
      return;
    }

    if (!shouldSave && existing != null) {
      await supabase
          .from('community_saves')
          .delete()
          .eq('id', existing['id'] as String);
    }
  }

  Future<void> setRating(String recipeId, int rating) async {
    final userId = _userId;
    if (userId == null) throw Exception('Not authenticated');

    final existing = await supabase
        .from('community_ratings')
        .select('id')
        .eq('recipe_id', recipeId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('community_ratings').insert({
        'recipe_id': recipeId,
        'user_id': userId,
        'rating': rating,
      });
      return;
    }

    await supabase
        .from('community_ratings')
        .update({'rating': rating})
        .eq('id', existing['id'] as String);
  }

  Future<void> addReview(String recipeId, String content) async {
    final userId = _userId;
    if (userId == null) throw Exception('Not authenticated');

    await supabase.from('community_reviews').insert({
      'recipe_id': recipeId,
      'user_id': userId,
      'content': content.trim(),
    });
  }

  Future<void> updateReview({
    required String reviewId,
    required String content,
  }) async {
    await supabase
        .from('community_reviews')
        .update({'content': content.trim()})
        .eq('id', reviewId);
  }

  Future<void> deleteReview(String reviewId) async {
    await supabase.from('community_reviews').delete().eq('id', reviewId);
  }
}
