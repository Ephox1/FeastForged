import 'package:flutter_test/flutter_test.dart';
import 'package:feastforged/core/models/user_profile.dart';
import 'package:feastforged/features/auth/data/profile_repository.dart';

void main() {
  group('ProfileRepository.calculateTDEE', () {
    test('applies activity multiplier and goal adjustment', () {
      final calories = ProfileRepository.calculateTDEE(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        activityLevel: ActivityLevel.moderate,
        goal: Goal.lose,
      );

      expect(calories, 2259);
    });
  });

  group('UserProfile.effectiveDisplayName', () {
    test('ignores generated usernames and falls back to email name', () {
      final profile = UserProfile(
        id: 'user-1',
        email: 'nevin@example.com',
        username: 'user_1a9404e6',
        dailyCalorieTarget: 2000,
        createdAt: DateTime.utc(2026, 4, 1),
      );

      expect(profile.effectiveDisplayName, 'nevin');
    });
  });
}
