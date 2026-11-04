import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_network_image.dart';

/// One card in the categories grid.
class CategoryGridItem {
  const CategoryGridItem({
    required this.id,
    required this.name,
    this.imageAsset,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? imageAsset;
  final String? imageUrl;
}

/// Square card: the artwork fills the whole card and the name sits over it
/// at the top-left.
class CategoryGridTile extends StatefulWidget {
  const CategoryGridTile({super.key, required this.item, this.onTap});

  final CategoryGridItem item;
  final VoidCallback? onTap;

  @override
  State<CategoryGridTile> createState() => _CategoryGridTileState();
}

class _CategoryGridTileState extends State<CategoryGridTile> {
  bool _imageFailed = false;

  @override
  void didUpdateWidget(CategoryGridTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.imageUrl != widget.item.imageUrl ||
        oldWidget.item.imageAsset != widget.item.imageAsset) {
      _imageFailed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;
    final hasImage =
        (item.imageAsset?.isNotEmpty ?? false) ||
        (item.imageUrl?.isNotEmpty ?? false);

    return Material(
      color: isDark
          ? AppColors.surfaceDark
          : !hasImage || _imageFailed
          ? AppColors.background
          : AppColors.white,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The artwork covers the whole card; the title sits on top of it.
            Positioned.fill(
              child: switch (item) {
                CategoryGridItem(:final imageAsset?)
                    when imageAsset.isNotEmpty =>
                  AppAssetImage(imageAsset, fit: BoxFit.cover),
                CategoryGridItem(:final imageUrl?) when imageUrl.isNotEmpty =>
                  AppNetworkImage(
                    url: imageUrl,
                    radius: 0,
                    fallbackColor: isDark
                        ? AppColors.surfaceDark
                        : AppColors.background,
                    onLoadFailed: () {
                      if (mounted &&
                          widget.item.imageUrl == imageUrl &&
                          !_imageFailed) {
                        setState(() => _imageFailed = true);
                      }
                    },
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.sm,
              top: AppSpacing.md,
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  letterSpacing: -0.28,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _radius = 24.0;
}
