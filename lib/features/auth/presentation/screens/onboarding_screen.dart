import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_profile.dart';
import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../../data/profile_repository.dart';
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

    await ref
        .read(profileNotifierProvider.notifier)
        .createProfile(
          weightKg: weight,
          heightCm: height,
          age: age,
          activityLevel: _activityLevel,
          goal: _goal,
        );
  }

  _TargetPreview _targetPreview() {
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final age = int.tryParse(_ageController.text.trim());

    if (weight == null || height == null || age == null) {
      return const _TargetPreview.empty();
    }

    final calories = ProfileRepository.calculateTDEE(
      weightKg: weight,
      heightCm: height,
      age: age,
      activityLevel: _activityLevel,
      goal: _goal,
    );

    return _TargetPreview(
      calories: calories,
      protein: ((calories * 0.30) / 4).round(),
      carbs: ((calories * 0.45) / 4).round(),
      fat: ((calories * 0.25) / 9).round(),
      goal: _goal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final preview = _targetPreview();

    ref.listen(profileNotifierProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.friendly(next.error!)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      if (next is AsyncData && next.value != null) {
        context.go('/app/dashboard');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Set your goals')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Let\'s personalize your plan',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We turn your stats, activity, and goal into calorie and macro targets you can actually use today.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
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
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
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
                  onChanged: (_) => setState(() {}),
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
                    subtitle: Text(_activityDescription(level)),
                    onChanged: (v) =>
                        setState(() => _activityLevel = v ?? _activityLevel),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Goal', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...Goal.values.map(
                  (goal) => RadioListTile<Goal>(
                    value: goal,
                    groupValue: _goal,
                    title: Text(goal.label),
                    subtitle: Text(_goalDescription(goal)),
                    onChanged: (v) => setState(() => _goal = v ?? _goal),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 20),
                _TargetPreviewCard(preview: preview),
                const SizedBox(height: 28),
                LoadingButton(
                  onPressed: _submit,
                  label: 'Calculate my targets',
                  isLoading: profileState is AsyncLoading,
                ),
                const SizedBox(height: 12),
                Text(
                  'You can edit these targets later from the dashboard.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _activityDescription(ActivityLevel level) => switch (level) {
    ActivityLevel.sedentary => 'Mostly seated work and light movement',
    ActivityLevel.light => 'A little walking or a few active sessions weekly',
    ActivityLevel.moderate => 'Regular training or active days most weeks',
    ActivityLevel.active => 'Frequent workouts or a physically active job',
    ActivityLevel.veryActive => 'High training load or intense daily movement',
  };

  String _goalDescription(Goal goal) => switch (goal) {
    Goal.lose => 'A modest calorie deficit built for consistency',
    Goal.maintain => 'Balanced targets to hold your current weight steady',
    Goal.gain => 'A small surplus to support training and muscle gain',
  };
}

class _TargetPreview {
  const _TargetPreview({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.goal,
  }) : isReady = true;

  const _TargetPreview.empty()
    : calories = 0,
      protein = 0,
      carbs = 0,
      fat = 0,
      goal = Goal.maintain,
      isReady = false;

  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final Goal goal;
  final bool isReady;
}

class _TargetPreviewCard extends StatelessWidget {
  const _TargetPreviewCard({required this.preview});

  final _TargetPreview preview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily target preview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              preview.isReady
                  ? _goalMessage(preview.goal)
                  : 'Add your stats above to preview your targets before you save them.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (preview.isReady) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _TargetChip(
                    label: 'Calories',
                    value: '${preview.calories}',
                    accentColor: colorScheme.primary,
                  ),
                  _TargetChip(
                    label: 'Protein',
                    value: '${preview.protein}g',
                    accentColor: const Color(0xFFB75D1A),
                  ),
                  _TargetChip(
                    label: 'Carbs',
                    value: '${preview.carbs}g',
                    accentColor: const Color(0xFF3D8B5D),
                  ),
                  _TargetChip(
                    label: 'Fat',
                    value: '${preview.fat}g',
                    accentColor: const Color(0xFF9D6C27),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _goalMessage(Goal goal) => switch (goal) {
    Goal.lose =>
      'This sets up a gentle deficit so you can cut without wrecking your routine.',
    Goal.maintain =>
      'This keeps your intake steady so you can build consistency first.',
    Goal.gain =>
      'This nudges intake upward to support recovery and muscle gain.',
  };
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: accentColor.withValues(alpha: 0.10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
