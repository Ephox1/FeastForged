import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../../domain/food_item.dart';
import '../../domain/meal_log_entry.dart';
import '../../providers/nutrition_provider.dart';

class LogMealScreen extends ConsumerStatefulWidget {
  const LogMealScreen({super.key, this.foodData});

  final Map<String, dynamic>? foodData;

  @override
  ConsumerState<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends ConsumerState<LogMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  FoodItem? _food;
  MealType _mealType = MealType.other;

  @override
  void initState() {
    super.initState();
    _loadFood();
  }

  void _loadFood() {
    final data = widget.foodData;
    if (data == null) return;

    final foodJson = data['food'];
    if (foodJson is! Map<String, dynamic>) return;

    try {
      final parsedFood = FoodItem.fromJson(foodJson);
      _food = parsedFood;
      _mealType = MealType.values.firstWhere(
        (e) => e.name == (data['mealType'] as String? ?? 'other'),
        orElse: () => MealType.other,
      );
      _amountController.text = parsedFood.defaultServingGrams.toStringAsFixed(
        0,
      );
    } catch (_) {
      _food = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount =>
      double.tryParse(_amountController.text.trim()) ??
      (_food?.defaultServingGrams ?? 100);

  Future<void> _submit() async {
    final food = _food;
    if (food == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(mealLoggerProvider.notifier)
        .logFood(food: food, amountGrams: _amount, mealType: _mealType);
  }

  @override
  Widget build(BuildContext context) {
    final food = _food;
    final logState = ref.watch(mealLoggerProvider);

    ref.listen(mealLoggerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      if (next is AsyncData && logState is AsyncLoading) {
        context.pop();
      }
    });

    if (food == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Log meal')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                Text(
                  'This food entry could not be loaded.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Go back and choose a food again.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back to search'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final calories = food.caloriesForAmount(_amount);
    final protein = food.proteinForAmount(_amount);
    final carbs = food.carbsForAmount(_amount);
    final fat = food.fatForAmount(_amount);

    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (food.brand != null) ...[
                  Text(
                    food.brand!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Meal type selector
                DropdownButtonFormField<MealType>(
                  value: _mealType,
                  decoration: const InputDecoration(
                    labelText: 'Meal',
                    prefixIcon: Icon(Icons.restaurant_outlined),
                  ),
                  items: MealType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _mealType = v ?? _mealType),
                ),
                const SizedBox(height: 16),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (g)',
                    prefixIcon: Icon(Icons.scale_outlined),
                    suffixText: 'g',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      Validators.positiveNumber(v, fieldName: 'Amount'),
                ),
                const SizedBox(height: 24),

                // Nutrition preview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutrition for ${_amount.toInt()}g',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _NutritionRow(
                          label: 'Calories',
                          value: '${calories.toInt()} kcal',
                          highlight: true,
                        ),
                        _NutritionRow(
                          label: 'Protein',
                          value: '${protein.toStringAsFixed(1)}g',
                        ),
                        _NutritionRow(
                          label: 'Carbohydrates',
                          value: '${carbs.toStringAsFixed(1)}g',
                        ),
                        _NutritionRow(
                          label: 'Fat',
                          value: '${fat.toStringAsFixed(1)}g',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                LoadingButton(
                  onPressed: _submit,
                  label: 'Log to ${_mealType.label}',
                  isLoading: logState is AsyncLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: highlight ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
