import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_network_image.dart';

/// A brand shortcut card (Lacoste, Tissot, …).
class BrandItem {
  const BrandItem({
    required this.id,
    required this.name,
    this.logoUrl,
    this.logoAsset,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String? logoAsset;
}

/// Row of brand cards; scrolls horizontally when the list grows.
class BrandStrip extends StatelessWidget {
  const BrandStrip({
    super.key,
    required this.items,
    this.onTap,
    this.height = 56,
    this.cardWidth = 92,
  });

  final List<BrandItem> items;
  final ValueChanged<BrandItem>? onTap;
  final double height;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height + 10,
      margin: const EdgeInsets.only(top: AppSpacing.md),
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
            child: Container(
              width: cardWidth + 15,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? AppColors.categoryDark : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark ? AppColors.categoryDark : AppColors.grey100,
                ),
              ),
              // The logo fills the card and is clipped to the radius just
              // inside the 1px border (outer radius minus the border), so
              // its corners follow the border's curve exactly.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg - 1),
                child: switch (item) {
                  BrandItem(:final logoAsset?) => AppAssetImage(
                    logoAsset,
                    fit: BoxFit.contain,
                  ),
                  BrandItem(:final logoUrl?) => AppNetworkImage(
                    url: logoUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    radius: 0,
                    wordmarkPlaceholder: true,
                    wordmarkSize: 14,
                  ),
                  _ => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
