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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.grey100),
              ),
              child: switch (item) {
                BrandItem(:final logoAsset?) => AppAssetImage(
                  logoAsset,
                  fit: BoxFit.contain,
                ),
                BrandItem(:final logoUrl?) => AppNetworkImage(
                  url: logoUrl,
                  fit: BoxFit.contain,
                  radius: 0,
                  wordmarkPlaceholder: true,
                  wordmarkSize: 14,
                ),
                _ => Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              },
            ),
          );
        },
      ),
    );
  }
}
