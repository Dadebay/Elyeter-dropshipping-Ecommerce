import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product/presentation/widgets/product_image_view.dart';
import '../../../../core/constants/app_icons.dart';

/// A row of thumbnails for what is in the order, with the overflow counted
/// in a chip at the end rather than scrolled to.
class OrderProductsStrip extends StatelessWidget {
  const OrderProductsStrip({
    super.key,
    required this.products,
    required this.itemCount,
  });

  static const _thumbSize = 56.0;

  /// Ceiling on the thumbnails, however wide the row gets.
  static const _maxThumbs = 5;

  /// One thumbnail plus the gap after it.
  static const _unit = _thumbSize + AppSpacing.sm;

  final List<ProductCardData> products;

  /// Everything in the order, thumbnails or not — what the chip counts up to.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    // How many actually fit, not how many we would like to show: five
    // thumbnails plus the chip are wider than a phone's card.
    return LayoutBuilder(
      builder: (context, constraints) {
        final room = constraints.maxWidth + AppSpacing.sm;
        var fits = _thumbsIn(room);
        if (itemCount > fits) fits = _thumbsIn(room - _unit);

        final shown = products.take(fits).toList();
        final hidden = itemCount - shown.length;

        return Row(
          children: [
            for (final product in shown) ...[
              _Thumb(product: product),
              const SizedBox(width: AppSpacing.sm),
            ],
            if (hidden > 0) _More(count: hidden),
          ],
        );
      },
    );
  }

  int _thumbsIn(double room) => (room / _unit).floor().clamp(1, _maxThumbs);
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.product});

  final ProductCardData product;

  @override
  Widget build(BuildContext context) {
    final image = product.images.isEmpty ? null : product.images.first;

    // Edge to edge: the photo covers its whole tile, rounded with it, with
    // no grey showing round it.
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox.square(
        dimension: OrderProductsStrip._thumbSize,
        child: ColoredBox(
          color: context.adapt(AppColors.grey100, AppColors.backgroundDark),
          child: image == null
              ? const Center(
                  child: HugeIcon(
                    icon: AppIcons.image,
                    color: AppColors.grey500,
                    size: 20,
                  ),
                )
              : ProductImageView(
                  source: image,
                  fit: BoxFit.cover,
                  fallbackIconSize: 20,
                ),
        ),
      ),
    );
  }
}

/// `+5` — what the strip has no room for.
class _More extends StatelessWidget {
  const _More({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    width: OrderProductsStrip._thumbSize,
    height: OrderProductsStrip._thumbSize,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.adapt(AppColors.grey100, AppColors.backgroundDark),
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: Text(
      '+$count',
      style: context.textTheme.titleSmall?.copyWith(
        color: context.adapt(AppColors.grey700, AppColors.iconSoft),
      ),
    ),
  );
}
