import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/food_item.dart';
import '../../domain/meal_log_entry.dart';
import '../../providers/nutrition_provider.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key, required this.mealType});

  final String mealType;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  MealType get _mealType => MealType.values.firstWhere(
    (e) => e.name == widget.mealType,
    orElse: () => MealType.other,
  );

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(foodSearchProvider.notifier).search(query);
    });
    setState(() {});
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(foodSearchProvider.notifier).clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(foodSearchProvider);
    final recentFoods = ref.watch(recentFoodsProvider);
    final popularFoods = ref.watch(popularFoodsProvider);
    final showSuggestions = _searchController.text.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(title: Text('Add to ${_mealType.label}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                SearchBar(
                  controller: _searchController,
                  hintText: 'Search foods...',
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
                  ],
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        showSuggestions
                            ? 'Start with recents, popular foods, or add your own.'
                            : 'Tap a result to choose the amount and meal.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push(
                        '/food-search/custom?mealType=${_mealType.name}',
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Custom'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: showSuggestions
                ? RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(recentFoodsProvider);
                      ref.invalidate(popularFoodsProvider);
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        _FoodSection(
                          title: 'Recent foods',
                          subtitle: 'Quick re-logs for foods you use often.',
                          foodsAsync: recentFoods,
                          mealType: _mealType,
                          emptyMessage:
                              'Your recent foods will show up here after your first few logs.',
                        ),
                        const SizedBox(height: 20),
                        _FoodSection(
                          title: 'Popular starters',
                          subtitle:
                              'A simple list of dependable basics to help you get moving.',
                          foodsAsync: popularFoods,
                          mealType: _mealType,
                          emptyMessage:
                              'No starter foods are available yet in this environment.',
                        ),
                      ],
                    ),
                  )
                : searchState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Search error: $e')),
                    data: (foods) {
                      if (foods.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No foods found for "${_searchController.text}"',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a simpler search or add it as a custom food.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: foods.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16),
                        itemBuilder: (context, index) {
                          final food = foods[index];
                          return _FoodTile(food: food, mealType: _mealType);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FoodSection extends StatelessWidget {
  const _FoodSection({
    required this.title,
    required this.subtitle,
    required this.foodsAsync,
    required this.mealType,
    required this.emptyMessage,
  });

  final String title;
  final String subtitle;
  final AsyncValue<List<FoodItem>> foodsAsync;
  final MealType mealType;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        foodsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Could not load foods: $e'),
          ),
          data: (foods) {
            if (foods.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(emptyMessage),
              );
            }

            return Column(
              children: foods
                  .map(
                    (food) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: _FoodTile(food: food, mealType: mealType),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({required this.food, required this.mealType});

  final FoodItem food;
  final MealType mealType;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(food.name),
      subtitle: Text(
        food.brand == null
            ? food.isCustom
                  ? 'Custom food'
                  : 'Per 100g entry'
            : food.brand!,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${food.caloriesPer100g.toInt()} kcal',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '${food.proteinPer100g.toStringAsFixed(0)}p • ${food.carbsPer100g.toStringAsFixed(0)}c • ${food.fatPer100g.toStringAsFixed(0)}f',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () => context.push(
        '/log-meal',
        extra: {'food': food.toJson(), 'mealType': mealType.name},
      ),
    );
  }
}
