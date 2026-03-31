import 'package:flutter_test/flutter_test.dart';
import 'package:feastforged/features/nutrition/domain/food_item.dart';

void main() {
  test('calculates macros for a custom gram amount', () {
    const food = FoodItem(
      id: 'food-1',
      name: 'Chicken Breast',
      caloriesPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
    );

    expect(food.caloriesForAmount(150), 247.5);
    expect(food.proteinForAmount(150), 46.5);
    expect(food.fatForAmount(150), 5.4);
  });
}
