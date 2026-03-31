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
}
