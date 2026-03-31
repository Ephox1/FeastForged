import 'package:flutter/foundation.dart';

enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive;

  String get label => switch (this) {
        ActivityLevel.sedentary => 'Sedentary',
        ActivityLevel.light => 'Lightly active',
        ActivityLevel.moderate => 'Moderately active',
        ActivityLevel.active => 'Very active',
        ActivityLevel.veryActive => 'Extra active',
      };

  double get multiplier => switch (this) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.light => 1.375,
        ActivityLevel.moderate => 1.55,
        ActivityLevel.active => 1.725,
        ActivityLevel.veryActive => 1.9,
      };
}

enum Goal {
  lose,
  maintain,
  gain;

  String get label => switch (this) {
        Goal.lose => 'Lose weight',
        Goal.maintain => 'Maintain weight',
        Goal.gain => 'Gain muscle',
      };

  int get calorieAdjustment => switch (this) {
        Goal.lose => -500,
        Goal.maintain => 0,
        Goal.gain => 300,
      };
}

@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.age,
    this.weightKg,
    this.heightCm,
    this.activityLevel = ActivityLevel.moderate,
    this.goal = Goal.maintain,
    required this.dailyCalorieTarget,
    this.dailyProteinTarget = 150,
    this.dailyCarbTarget = 250,
    this.dailyFatTarget = 65,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final ActivityLevel activityLevel;
  final Goal goal;
  final int dailyCalorieTarget;
  final int dailyProteinTarget;
  final int dailyCarbTarget;
  final int dailyFatTarget;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['display_name'] as String?,
        age: json['age'] as int?,
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        activityLevel: ActivityLevel.values.firstWhere(
          (e) => e.name == (json['activity_level'] as String? ?? 'moderate'),
          orElse: () => ActivityLevel.moderate,
        ),
        goal: Goal.values.firstWhere(
          (e) => e.name == (json['goal'] as String? ?? 'maintain'),
          orElse: () => Goal.maintain,
        ),
        dailyCalorieTarget: json['daily_calorie_target'] as int,
        dailyProteinTarget: (json['daily_protein_target'] as int?) ?? 150,
        dailyCarbTarget: (json['daily_carb_target'] as int?) ?? 250,
        dailyFatTarget: (json['daily_fat_target'] as int?) ?? 65,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (displayName != null) 'display_name': displayName,
        if (age != null) 'age': age,
        if (weightKg != null) 'weight_kg': weightKg,
        if (heightCm != null) 'height_cm': heightCm,
        'activity_level': activityLevel.name,
        'goal': goal.name,
        'daily_calorie_target': dailyCalorieTarget,
        'daily_protein_target': dailyProteinTarget,
        'daily_carb_target': dailyCarbTarget,
        'daily_fat_target': dailyFatTarget,
        'created_at': createdAt.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  UserProfile copyWith({
    String? displayName,
    int? age,
    double? weightKg,
    double? heightCm,
    ActivityLevel? activityLevel,
    Goal? goal,
    int? dailyCalorieTarget,
    int? dailyProteinTarget,
    int? dailyCarbTarget,
    int? dailyFatTarget,
  }) =>
      UserProfile(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        age: age ?? this.age,
        weightKg: weightKg ?? this.weightKg,
        heightCm: heightCm ?? this.heightCm,
        activityLevel: activityLevel ?? this.activityLevel,
        goal: goal ?? this.goal,
        dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
        dailyProteinTarget: dailyProteinTarget ?? this.dailyProteinTarget,
        dailyCarbTarget: dailyCarbTarget ?? this.dailyCarbTarget,
        dailyFatTarget: dailyFatTarget ?? this.dailyFatTarget,
        createdAt: createdAt,
        updatedAt: DateTime.now().toUtc(),
      );
}
