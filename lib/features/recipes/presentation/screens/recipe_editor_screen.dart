import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/loading_button.dart';
import '../../domain/recipe.dart';
import '../../providers/recipe_provider.dart';

class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({super.key});

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController(text: '4');
  final _prepTimeController = TextEditingController(text: '15');
  final _cookTimeController = TextEditingController(text: '20');
  final _caloriesController = TextEditingController(text: '0');
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isPublic = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  List<RecipeIngredient> _ingredients() {
    return _ingredientsController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => RecipeIngredient(name: line))
        .toList();
  }

  List<String> _instructions() {
    return _instructionsController.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<String> _tags() {
    return _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final saved = await ref
        .read(recipeEditorProvider.notifier)
        .saveRecipe(
          title: _titleController.text,
          description: _descriptionController.text,
          servings: int.parse(_servingsController.text.trim()),
          prepTimeMinutes: int.parse(_prepTimeController.text.trim()),
          cookTimeMinutes: int.parse(_cookTimeController.text.trim()),
          calories: double.parse(_caloriesController.text.trim()),
          proteinG: double.parse(_proteinController.text.trim()),
          carbsG: double.parse(_carbsController.text.trim()),
          fatG: double.parse(_fatController.text.trim()),
          ingredients: _ingredients(),
          instructions: _instructions(),
          tags: _tags(),
          isPublic: _isPublic,
        );

    if (!mounted || saved == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Recipe saved to Supabase')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(recipeEditorProvider);

    ref.listen(recipeEditorProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorMessages.friendly(next.error ?? Exception('Unknown error')),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('New recipe')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create a recipe in the live Supabase schema',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Title'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _servingsController,
                        decoration: const InputDecoration(
                          labelText: 'Servings',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => Validators.positiveNumber(
                          value,
                          fieldName: 'Servings',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _prepTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Prep minutes',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => Validators.positiveNumber(
                          value,
                          fieldName: 'Prep minutes',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cookTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Cook minutes',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => Validators.positiveNumber(
                          value,
                          fieldName: 'Cook minutes',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Batch macros',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _MacroField(controller: _caloriesController, label: 'Calories'),
                const SizedBox(height: 12),
                _MacroField(
                  controller: _proteinController,
                  label: 'Protein (g)',
                ),
                const SizedBox(height: 12),
                _MacroField(controller: _carbsController, label: 'Carbs (g)'),
                const SizedBox(height: 12),
                _MacroField(controller: _fatController, label: 'Fat (g)'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ingredientsController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Ingredients',
                    helperText: 'One ingredient per line',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _instructionsController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Instructions',
                    helperText: 'One step per line',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    helperText: 'Comma-separated',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _isPublic,
                  title: const Text('Mark as public'),
                  subtitle: const Text(
                    'This makes the recipe visible to public recipe queries.',
                  ),
                  onChanged: (value) => setState(() => _isPublic = value),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
                LoadingButton(
                  onPressed: _submit,
                  label: 'Save recipe',
                  isLoading: editorState is AsyncLoading,
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
  const _MacroField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          Validators.nonNegativeNumber(value, fieldName: label),
    );
  }
}
