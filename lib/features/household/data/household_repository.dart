import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/supabase/supabase_client.dart';

const _uuid = Uuid();

class HouseholdMember {
  const HouseholdMember({
    required this.id,
    required this.userId,
    required this.name,
    this.age,
    this.dietaryPreferences = const [],
    this.allergies = const [],
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final int? age;
  final List<String> dietaryPreferences;
  final List<String> allergies;
  final DateTime createdAt;

  factory HouseholdMember.fromJson(Map<String, dynamic> json) =>
      HouseholdMember(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        age: json['age'] as int?,
        dietaryPreferences: ((json['dietary_preferences'] as List?) ?? const [])
            .cast<String>(),
        allergies: ((json['allergies'] as List?) ?? const []).cast<String>(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class HouseholdRepository {
  const HouseholdRepository();

  Future<List<HouseholdMember>> fetchMembers() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('household_members')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (data as List)
        .map((item) => HouseholdMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<HouseholdMember> addMember({
    required String name,
    int? age,
    List<String> dietaryPreferences = const [],
    List<String> allergies = const [],
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final data = await supabase
        .from('household_members')
        .insert({
          'id': _uuid.v4(),
          'user_id': userId,
          'name': name.trim(),
          'age': age,
          'dietary_preferences': dietaryPreferences,
          'allergies': allergies,
        })
        .select()
        .single();

    return HouseholdMember.fromJson(data);
  }
}
