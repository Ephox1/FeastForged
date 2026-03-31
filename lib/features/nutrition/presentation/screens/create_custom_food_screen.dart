import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../../domain/meal_log_entry.dart';
import '../../providers/nutrition_provider.dart';

class CreateCustomFoodScreen extends ConsumerStatefulWidget {
  const CreateCustomFoodScreen({super.key, required this.mealType});

  final String mealType;

  @override
  ConsumerState<CreateCustomFoodScreen> createState() =>
      _CreateCustomFoodScreenState();
}

class _CreateCustomFoodScreenState
    extends ConsumerState<CreateCustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');
  final _servingController = TextEditingController(text: '100');

  MealType get _mealType => MealType.values.firstWhere(
    (value) => value.name == widget.mealType,
    orElse: () => MealType.other,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final created = await ref
        .read(customFoodProvider.notifier)
        .createCustomFood(
          name: _nameController.text,
          brand: _brandController.text,
          caloriesPer100g: double.parse(_caloriesController.text.trim()),
          proteinPer100g: double.parse(_proteinController.text.trim()),
          carbsPer100g: double.parse(_carbsController.text.trim()),
          fatPer100g: double.parse(_fatController.text.trim()),
          defaultServingGrams: double.parse(_servingController.text.trim()),
        );

    if (!mounted || created == null) return;
    context.pushReplacement(
      '/log-meal',
      extra: {'food': created.toJson(), 'mealType': _mealType.name},
    );
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(customFoodProvider);

    ref.listen(customFoodProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.friendly(next.error!))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create custom food')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add something not in the database yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter nutrition per 100g so your logs stay accurate.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Food name',
                    prefixIcon: Icon(Icons.restaurant_menu_outlined),
                  ),
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Food name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    labelText: 'Brand (optional)',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _servingController,
                  decoration: const InputDecoration(
                    labelText: 'Default serving (g)',
                    prefixIcon: Icon(Icons.scale_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => Validators.positiveNumber(
                    value,
                    fieldName: 'Default serving',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nutrition per 100g',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _MacroField(
                  controller: _caloriesController,
                  label: 'Calories',
                  suffix: 'kcal',
                ),
                const SizedBox(height: 12),
                _MacroField(
                  controller: _proteinController,
                  label: 'Protein',
                  suffix: 'g',
                ),
                const SizedBox(height: 12),
                _MacroField(
                  controller: _carbsController,
                  label: 'Carbs',
                  suffix: 'g',
                ),
                const SizedBox(height: 12),
                _MacroField(
                  controller: _fatController,
                  label: 'Fat',
                  suffix: 'g',
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  onPressed: _submit,
                  label: 'Create and log',
                  isLoading: createState is AsyncLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroField extends StatelessWidget {
  const _MacroField({
    required this.controller,
    required this.label,
    required this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) =>
          Validators.nonNegativeNumber(value, fieldName: label),
    );
  }
}
