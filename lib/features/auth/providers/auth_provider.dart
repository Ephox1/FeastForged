import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => const AuthRepository(),
);

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthActionResult {
  const AuthActionResult({required this.requiresEmailConfirmation, this.email});

  final bool requiresEmailConfirmation;
  final String? email;
}

class _AuthNotifier extends AsyncNotifier<AuthActionResult?> {
  @override
  Future<AuthActionResult?> build() async => null;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email.trim(), password: password);
      return null;
    });
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(authRepositoryProvider)
          .signUp(email: email.trim(), password: password);
      return AuthActionResult(
        requiresEmailConfirmation: response.session == null,
        email: email.trim(),
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return null;
    });
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).resetPassword(email.trim());
      return null;
    });
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<_AuthNotifier, AuthActionResult?>(_AuthNotifier.new);
