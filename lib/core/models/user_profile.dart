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
    this.username,
    this.displayName,
    this.bio,
    this.avatarUrl,
    this.age,
    this.weightKg,
    this.heightCm,
    this.activityLevel = ActivityLevel.moderate,
    this.goal = Goal.maintain,
    required this.dailyCalorieTarget,
    this.dailyProteinTarget = 150,
    this.dailyCarbTarget = 250,
    this.dailyFatTarget = 65,
    this.dietaryPreferences = const [],
    this.unitSystem = 'imperial',
    this.isPremium = false,
    this.premiumExpiresAt,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final ActivityLevel activityLevel;
  final Goal goal;
  final int dailyCalorieTarget;
  final int dailyProteinTarget;
  final int dailyCarbTarget;
  final int dailyFatTarget;
  final List<String> dietaryPreferences;
  final String unitSystem;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  String get effectiveDisplayName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    final trimmedUsername = username?.trim();
    final isGeneratedUsername =
        trimmedUsername != null &&
        RegExp(
          r'^user_[a-f0-9]+$',
          caseSensitive: false,
        ).hasMatch(trimmedUsername);
    if (trimmedUsername != null &&
        trimmedUsername.isNotEmpty &&
        !isGeneratedUsername) {
      return trimmedUsername;
    }
    final emailName = email.split('@').first.trim();
    return emailName.isEmpty ? 'FeastForged user' : emailName;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    username: json['username'] as String?,
    displayName: json['display_name'] as String?,
    bio: json['bio'] as String?,
    avatarUrl: json['avatar_url'] as String?,
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
    dailyCalorieTarget:
        (json['daily_calorie_target'] as int?) ??
        (json['calorie_target'] as int?) ??
        2000,
    dailyProteinTarget:
        (json['daily_protein_target'] as int?) ??
        (json['protein_target'] as int?) ??
        150,
    dailyCarbTarget:
        (json['daily_carb_target'] as int?) ??
        (json['carbs_target'] as int?) ??
        250,
    dailyFatTarget:
        (json['daily_fat_target'] as int?) ??
        (json['fat_target'] as int?) ??
        65,
    dietaryPreferences: ((json['dietary_preferences'] as List?) ?? const [])
        .cast<String>(),
    unitSystem: json['unit_system'] as String? ?? 'imperial',
    isPremium: json['is_premium'] as bool? ?? false,
    premiumExpiresAt: json['premium_expires_at'] != null
        ? DateTime.parse(json['premium_expires_at'] as String)
        : null,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now().toUtc(),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'display_name': displayName ?? username ?? email.split('@').first,
    'bio': bio,
    'avatar_url': avatarUrl,
    'age': age,
    'weight_kg': weightKg,
    'height_cm': heightCm,
    'activity_level': activityLevel.name,
    'goal': goal.name,
    'calorie_target': dailyCalorieTarget,
    'protein_target': dailyProteinTarget,
    'carbs_target': dailyCarbTarget,
    'fat_target': dailyFatTarget,
    'dietary_preferences': dietaryPreferences,
    'unit_system': unitSystem,
    'is_premium': isPremium,
    'premium_expires_at': premiumExpiresAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  }..removeWhere((_, value) => value == null);

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    int? age,
    double? weightKg,
    double? heightCm,
    ActivityLevel? activityLevel,
    Goal? goal,
    int? dailyCalorieTarget,
    int? dailyProteinTarget,
    int? dailyCarbTarget,
    int? dailyFatTarget,
    List<String>? dietaryPreferences,
    String? unitSystem,
    bool? isPremium,
    DateTime? premiumExpiresAt,
  }) => UserProfile(
    id: id,
    email: email,
    username: username ?? this.username,
    displayName: displayName ?? this.displayName,
    bio: bio ?? this.bio,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    age: age ?? this.age,
    weightKg: weightKg ?? this.weightKg,
    heightCm: heightCm ?? this.heightCm,
    activityLevel: activityLevel ?? this.activityLevel,
    goal: goal ?? this.goal,
    dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
    dailyProteinTarget: dailyProteinTarget ?? this.dailyProteinTarget,
    dailyCarbTarget: dailyCarbTarget ?? this.dailyCarbTarget,
    dailyFatTarget: dailyFatTarget ?? this.dailyFatTarget,
    dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
    unitSystem: unitSystem ?? this.unitSystem,
    isPremium: isPremium ?? this.isPremium,
    premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
    createdAt: createdAt,
    updatedAt: DateTime.now().toUtc(),
  );
}
