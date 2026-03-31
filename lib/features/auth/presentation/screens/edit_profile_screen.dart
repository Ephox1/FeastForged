import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_profile.dart';
import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _ageController;

  late ActivityLevel _activityLevel;
  late Goal _goal;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.profile.weightKg?.toStringAsFixed(1) ?? '',
    );
    _heightController = TextEditingController(
      text: widget.profile.heightCm?.toStringAsFixed(0) ?? '',
    );
    _ageController = TextEditingController(
      text: widget.profile.age?.toString() ?? '',
    );
    _activityLevel = widget.profile.activityLevel;
    _goal = widget.profile.goal;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(
          existingProfile: widget.profile,
          weightKg: double.parse(_weightController.text.trim()),
          heightCm: double.parse(_heightController.text.trim()),
          age: int.parse(_ageController.text.trim()),
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
          SnackBar(content: Text(ErrorMessages.friendly(next.error!))),
        );
      }
      if (next is AsyncData && next.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Targets updated')),
        );
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Edit targets')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Update your daily targets',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adjust your stats whenever your routine or goal changes.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                        validator: (value) =>
                            Validators.positiveNumber(value, fieldName: 'Weight'),
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
                        validator: (value) =>
                            Validators.positiveNumber(value, fieldName: 'Height'),
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
                  validator: (value) =>
                      Validators.positiveNumber(value, fieldName: 'Age'),
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
                    onChanged: (value) =>
                        setState(() => _activityLevel = value ?? _activityLevel),
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
                    onChanged: (value) =>
                        setState(() => _goal = value ?? _goal),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  onPressed: _submit,
                  label: 'Save targets',
                  isLoading: profileState is AsyncLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
