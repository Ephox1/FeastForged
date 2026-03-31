import '../../../core/models/user_profile.dart';
import '../../../core/supabase/supabase_client.dart';

class ProfileRepository {
  const ProfileRepository();

  Future<UserProfile?> fetchProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> upsertProfile(UserProfile profile) async {
    final data = profile.toJson();
    await supabase
        .from('user_profiles')
        .upsert(data, onConflict: 'id');
    return profile;
  }

  /// Calculate daily calorie target using Mifflin-St Jeor equation.
  static int calculateTDEE({
    required double weightKg,
    required double heightCm,
    required int age,
    required ActivityLevel activityLevel,
    required Goal goal,
    bool isMale = true,
  }) {
    // Mifflin-St Jeor BMR
    final bmr = isMale
        ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;

    final tdee = bmr * activityLevel.multiplier;
    return (tdee + goal.calorieAdjustment).round();
  }
}
