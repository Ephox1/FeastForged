import 'package:flutter/material.dart';

import '../../features/recipes/domain/recipe.dart';

String? seededRecipeAssetForTitle(String title) {
  const assetMap = {
    'honey-sriracha-salmon-rice-bowls':
        'assets/images/recipes/honey-sriracha-salmon-rice-bowls.png',
    'slow-cooker-turkey-chili':
        'assets/images/recipes/slow-cooker-turkey-chili.png',
    'turkey-egg-white-breakfast-burritos':
        'assets/images/recipes/turkey-egg-white-breakfast-burritos.png',
    'lemon-blueberry-overnight-oats':
        'assets/images/recipes/lemon-blueberry-overnight-oats.png',
    'greek-chicken-power-bowls':
        'assets/images/recipes/greek-chicken-power-bowls.png',
    'buffalo-chicken-crunch-wrap':
        'assets/images/recipes/buffalo-chicken-crunch-wrap.png',
    'sheet-pan-steak-and-sweet-potatoes':
        'assets/images/recipes/sheet-pan-steak-and-sweet-potatoes.png',
    'cottage-cheese-berry-crunch-bowl':
        'assets/images/recipes/cottage-cheese-berry-crunch-bowl.png',
  };

  final normalized = title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return assetMap[normalized];
}

class RecipeCoverImage extends StatelessWidget {
  const RecipeCoverImage({
    super.key,
    required this.recipe,
    this.height = 180,
    this.borderRadius,
    this.showOverlay = false,
  });

  final Recipe recipe;
  final double height;
  final BorderRadius? borderRadius;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    final assetPath = seededRecipeAssetForTitle(recipe.title);
    final imageUrl = recipe.imageUrl;

    Widget image;
    if (imageUrl != null && imageUrl.startsWith('http')) {
      image = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackRecipeArt(title: recipe.title),
      );
    } else if (assetPath != null) {
      image = Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackRecipeArt(title: recipe.title),
      );
    } else {
      image = _FallbackRecipeArt(title: recipe.title);
    }

    final content = SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          if (showOverlay)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    if (borderRadius == null) return content;
    return ClipRRect(borderRadius: borderRadius!, child: content);
  }
}

class RecipeTitleThumb extends StatelessWidget {
  const RecipeTitleThumb({
    super.key,
    required this.title,
    this.size = 56,
    this.borderRadius = 16,
  });

  final String title;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final assetPath = seededRecipeAssetForTitle(title);
    final fallback = _FallbackRecipeArt(title: title);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: assetPath == null
            ? fallback
            : Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

class _FallbackRecipeArt extends StatelessWidget {
  const _FallbackRecipeArt({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.surfaceContainerHighest],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 32,
              color: colors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
