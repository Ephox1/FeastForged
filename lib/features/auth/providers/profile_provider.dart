import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/user_profile.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (_) => const ProfileRepository(),
);

final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  return ref.watch(profileRepositoryProvider).fetchProfile();
});

class _ProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async => null;

  Future<void> createProfile({
    required double weightKg,
    required double heightCm,
    required int age,
    required ActivityLevel activityLevel,
    required Goal goal,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final calories = ProfileRepository.calculateTDEE(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        activityLevel: activityLevel,
        goal: goal,
      );

      // Macro split: 30% protein, 45% carbs, 25% fat
      final protein = ((calories * 0.30) / 4).round();
      final carbs = ((calories * 0.45) / 4).round();
      final fat = ((calories * 0.25) / 9).round();

      final profile = UserProfile(
        id: user.id,
        email: user.email ?? '',
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        activityLevel: activityLevel,
        goal: goal,
        dailyCalorieTarget: calories,
        dailyProteinTarget: protein,
        dailyCarbTarget: carbs,
        dailyFatTarget: fat,
        createdAt: DateTime.now().toUtc(),
      );

      final saved = await ref
          .read(profileRepositoryProvider)
          .upsertProfile(profile);
      ref.invalidate(currentProfileProvider);
      return saved;
    });
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<_ProfileNotifier, UserProfile?>(_ProfileNotifier.new);
