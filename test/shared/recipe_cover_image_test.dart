import 'package:flutter_test/flutter_test.dart';

import 'package:feastforged/shared/widgets/recipe_cover_image.dart';

void main() {
  test('maps seeded recipe titles to bundled assets', () {
    expect(
      seededRecipeAssetForTitle('Honey Sriracha Salmon Rice Bowls'),
      'assets/images/recipes/honey-sriracha-salmon-rice-bowls.png',
    );
    expect(
      seededRecipeAssetForTitle('Sheet Pan Steak and Sweet Potatoes'),
      'assets/images/recipes/sheet-pan-steak-and-sweet-potatoes.png',
    );
  });

  test('returns null for unknown recipe titles', () {
    expect(seededRecipeAssetForTitle('My Totally New Recipe'), isNull);
  });
}
