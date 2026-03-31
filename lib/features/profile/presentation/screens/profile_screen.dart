import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_profile.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load profile: $error')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Complete onboarding first.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileHeader(profile: profile),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.tune_outlined),
                      title: const Text('Edit targets'),
                      subtitle: const Text('Calories, macros, and stats'),
                      onTap: () => context.push('/profile/edit'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.people_alt_outlined),
                      title: const Text('Household members'),
                      subtitle: const Text('Multi-person planning foundation'),
                      onTap: () => context.push('/household'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.public_outlined),
                      title: const Text('Community'),
                      subtitle: const Text('Browse public recipes'),
                      onTap: () => context.push('/community'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.shopping_basket_outlined),
                      title: const Text('Shopping lists'),
                      subtitle: const Text('Lists tied to meal plans'),
                      onTap: () => context.push('/shopping'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.effectiveDisplayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Pill(label: '${profile.dailyCalorieTarget} kcal'),
                _Pill(label: '${profile.dailyProteinTarget}g protein'),
                _Pill(label: '${profile.dailyCarbTarget}g carbs'),
                _Pill(label: '${profile.dailyFatTarget}g fat'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label),
    );
  }
}
