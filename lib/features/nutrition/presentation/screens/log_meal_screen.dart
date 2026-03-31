import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../../../recipes/domain/recipe.dart';
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
  final _servingsController = TextEditingController(text: '1');
  Recipe? _recipe;
  String? _mealPlanEntryId;
  MealType _mealType = MealType.other;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  void _loadRecipe() {
    final data = widget.foodData;
    if (data == null) return;

    final recipeJson = data['recipe'];
    if (recipeJson is! Map<String, dynamic>) return;

    try {
      _recipe = Recipe.fromJson(recipeJson);
      _mealPlanEntryId = data['mealPlanEntryId'] as String?;
      _mealType = MealType.values.firstWhere(
        (e) => e.name == (data['mealType'] as String? ?? 'other'),
        orElse: () => MealType.other,
      );
    } catch (_) {
      _recipe = null;
    }
  }

  @override
  void dispose() {
    _servingsController.dispose();
    super.dispose();
  }

  double get _servings =>
      double.tryParse(_servingsController.text.trim()) ?? 1;

  List<double> get _servingShortcuts => const [0.5, 1, 1.5, 2, 3];

  Future<void> _submit() async {
    final recipe = _recipe;
    if (recipe == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(mealLoggerProvider.notifier).logRecipe(
      recipe: recipe,
      servings: _servings,
      mealType: _mealType,
      mealPlanEntryId: _mealPlanEntryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = _recipe;
    final logState = ref.watch(mealLoggerProvider);

    ref.listen(mealLoggerProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMessages.friendly(next.error)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      if (next is AsyncData && logState is AsyncLoading) {
        context.pop();
      }
    });

    if (recipe == null) {
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
                  'This recipe could not be loaded.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Go back and choose it again.',
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

    final calories = recipe.caloriesPerServing * _servings;
    final protein = recipe.proteinPerServing * _servings;
    final carbs = recipe.carbsPerServing * _servings;
    final fat = recipe.fatPerServing * _servings;

    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (recipe.description != null) ...[
                  Text(
                    recipe.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick servings',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _servingShortcuts
                              .map(
                                (servings) => ChoiceChip(
                                  label: Text('${servings}x'),
                                  selected:
                                      _servingsController.text.trim() ==
                                      servings.toString(),
                                  onSelected: (_) {
                                    _servingsController.text =
                                        servings.toString();
                                    setState(() {});
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                TextFormField(
                  controller: _servingsController,
                  decoration: const InputDecoration(
                    labelText: 'Servings',
                    prefixIcon: Icon(Icons.scale_outlined),
                    suffixText: 'x',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) =>
                      Validators.positiveNumber(v, fieldName: 'Servings'),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutrition for ${_servings.toStringAsFixed(_servings % 1 == 0 ? 0 : 1)} servings',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Based on the per-serving macros saved on this recipe.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
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
