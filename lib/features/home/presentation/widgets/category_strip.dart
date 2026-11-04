import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/elyeter_shimmer.dart';
import '../../../../core/widgets/app_network_image.dart';

/// One category tile's data. [imageUrl]/[imageAsset] stay optional so the
/// layout works before the real artwork arrives.
class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.imageAsset,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final String? imageAsset;
}

/// Horizontally scrolling category shortcuts under the header.
class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    super.key,
    required this.items,
    this.onTap,
    this.tileSize = 72,
    this.labelColor,
  });

  final List<CategoryItem> items;
  final ValueChanged<CategoryItem>? onTap;
  final double tileSize;

  /// Defaults to the theme's body color; pass white when the strip sits on
  /// the gradient header.
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: tileSize + 26,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: onTap == null ? null : () => onTap!(item),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: tileSize,
              child: Column(
                children: [
                  _CategoryTile(item: item, size: tileSize),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: labelColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.item, required this.size});

  final CategoryItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (item.imageAsset != null) {
      return Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.only(top: size * 0.2),
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: AppAssetImage(item.imageAsset!, width: size, height: size),
      );
    }
    if (item.imageUrl != null) {
      return AppNetworkImage(
        url: item.imageUrl,
        width: size,
        height: size,
        radius: AppRadius.lg,
      );
    }
    // No artwork yet: the brand wordmark reads better than a blank square.
    return SizedBox(
      width: size,
      height: size,
      child: const ElyeterShimmerBox(wordmarkSize: 11),
    );
  }
}
