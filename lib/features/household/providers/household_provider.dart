import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/household_repository.dart';

final householdRepositoryProvider = Provider<HouseholdRepository>(
  (_) => const HouseholdRepository(),
);

final householdMembersProvider = FutureProvider<List<HouseholdMember>>((
  ref,
) async {
  return ref.watch(householdRepositoryProvider).fetchMembers();
});

class _HouseholdEditorNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addMember({
    required String name,
    int? age,
    List<String> dietaryPreferences = const [],
    List<String> allergies = const [],
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(householdRepositoryProvider)
          .addMember(
            name: name,
            age: age,
            dietaryPreferences: dietaryPreferences,
            allergies: allergies,
          );
      ref.invalidate(householdMembersProvider);
    });
  }
}

final householdEditorProvider =
    AsyncNotifierProvider<_HouseholdEditorNotifier, void>(
      _HouseholdEditorNotifier.new,
    );
