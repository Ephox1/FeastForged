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

      final profile = _buildProfile(
        id: user.id,
        email: user.email ?? '',
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        activityLevel: activityLevel,
        goal: goal,
      );

      final saved = await ref
          .read(profileRepositoryProvider)
          .upsertProfile(profile);
      ref.invalidate(currentProfileProvider);
      return saved;
    });
  }

  Future<void> updateProfile({
    required UserProfile existingProfile,
    required double weightKg,
    required double heightCm,
    required int age,
    required ActivityLevel activityLevel,
    required Goal goal,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final profile = _buildProfile(
        id: existingProfile.id,
        email: existingProfile.email,
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        activityLevel: activityLevel,
        goal: goal,
        createdAt: existingProfile.createdAt,
        displayName: existingProfile.displayName,
      );

      final saved = await ref
          .read(profileRepositoryProvider)
          .upsertProfile(profile);
      ref.invalidate(currentProfileProvider);
      return saved;
    });
  }

  UserProfile _buildProfile({
    required String id,
    required String email,
    String? displayName,
    required double weightKg,
    required double heightCm,
    required int age,
    required ActivityLevel activityLevel,
    required Goal goal,
    DateTime? createdAt,
  }) {
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

    return UserProfile(
      id: id,
      email: email,
      displayName: displayName,
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      activityLevel: activityLevel,
      goal: goal,
      dailyCalorieTarget: calories,
      dailyProteinTarget: protein,
      dailyCarbTarget: carbs,
      dailyFatTarget: fat,
      createdAt: createdAt ?? DateTime.now().toUtc(),
      updatedAt: createdAt != null ? DateTime.now().toUtc() : null,
    );
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<_ProfileNotifier, UserProfile?>(_ProfileNotifier.new);
