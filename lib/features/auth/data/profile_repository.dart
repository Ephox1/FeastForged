import '../../../core/models/user_profile.dart';
import '../../../core/supabase/supabase_client.dart';

class ProfileRepository {
  const ProfileRepository();

  Future<UserProfile?> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson({...data, 'email': user.email});
  }

  Future<UserProfile> upsertProfile(UserProfile profile) async {
    final user = supabase.auth.currentUser;
    final derivedUsername = _deriveUsername(
      email: profile.email,
      displayName: profile.displayName,
      existingUsername: profile.username,
    );

    final payload = {
      ...profile.toJson(),
      'username': derivedUsername,
      'email': null,
    }..remove('email');

    final data = await supabase
        .from('profiles')
        .upsert(payload, onConflict: 'id')
        .select()
        .single();

    return UserProfile.fromJson({
      ...data,
      'email': user?.email ?? profile.email,
    });
  }

  String _deriveUsername({
    required String email,
    String? displayName,
    String? existingUsername,
  }) {
    if (existingUsername != null && existingUsername.trim().isNotEmpty) {
      return existingUsername.trim();
    }
    if (displayName != null && displayName.trim().isNotEmpty) {
      return _slugify(displayName);
    }
    return _slugify(email.split('@').first);
  }

  String _slugify(String value) {
    final normalized = value.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    return normalized.replaceAll(RegExp(r'^_+|_+$'), '').padRight(3, 'x');
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
    final bmr = isMale
        ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;

    final tdee = bmr * activityLevel.multiplier;
    return (tdee + goal.calorieAdjustment).round();
  }
}
