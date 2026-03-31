import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_profile.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../../providers/profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  ActivityLevel _activityLevel = ActivityLevel.moderate;
  Goal _goal = Goal.maintain;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final weight = double.parse(_weightController.text.trim());
    final height = double.parse(_heightController.text.trim());
    final age = int.parse(_ageController.text.trim());

    await ref.read(profileNotifierProvider.notifier).createProfile(
          weightKg: weight,
          heightCm: height,
          age: age,
          activityLevel: _activityLevel,
          goal: _goal,
        );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    ref.listen(profileNotifierProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      if (next is AsyncData && next.value != null) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Set your goals')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  "Let's personalize your plan",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We use this to calculate your daily calorie and macro targets.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            Validators.positiveNumber(v, fieldName: 'Weight'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          prefixIcon: Icon(Icons.height),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            Validators.positiveNumber(v, fieldName: 'Height'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      Validators.positiveNumber(v, fieldName: 'Age'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Activity level',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...ActivityLevel.values.map(
                  (level) => RadioListTile<ActivityLevel>(
                    value: level,
                    groupValue: _activityLevel,
                    title: Text(level.label),
                    onChanged: (v) =>
                        setState(() => _activityLevel = v ?? _activityLevel),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Goal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...Goal.values.map(
                  (goal) => RadioListTile<Goal>(
                    value: goal,
                    groupValue: _goal,
                    title: Text(goal.label),
                    onChanged: (v) => setState(() => _goal = v ?? _goal),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 32),
                LoadingButton(
                  onPressed: _submit,
                  label: 'Calculate my targets',
                  isLoading: profileState is AsyncLoading,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
