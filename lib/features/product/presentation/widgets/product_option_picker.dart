import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'product_image_view.dart';

/// The colourway strip: the product's own photos as selectable swatches.
class ProductColorPicker extends StatelessWidget {
  const ProductColorPicker({
    super.key,
    required this.images,
    required this.selected,
    required this.onSelected,
    this.unavailable = const {},
  });

  static const _size = 72.0;

  final List<String> images;
  final int selected;
  final ValueChanged<int> onSelected;

  /// Indices that cannot be bought: dimmed, and they ignore taps.
  final Set<int> unavailable;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // The page margin lives inside the list, so the strip itself can run
        // to both screen edges.
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final active = index == selected;
          final sold = unavailable.contains(index);
          return GestureDetector(
            onTap: sold ? null : () => onSelected(index),
            behavior: HitTestBehavior.opaque,
            child: Opacity(
              opacity: sold ? 0.4 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: _size,
                height: _size,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  // Black, not the brand orange: the swatch's own colour is
                  // what the customer is choosing, so the marker stays neutral.
                  border: Border.all(
                    color: active
                        ? context.inkColor
                        : context.adapt(
                            const Color(0xFFE5E5E5),
                            const Color(0xFF404040),
                          ),
                    width: active ? 1.5 : 0.75,
                  ),
                ),
                // A swatch whose photo is missing keeps a small glyph in its tile,
                // not one stretched to fill it.
                child: ProductImageView(
                  source: images[index],
                  fit: BoxFit.cover,
                  // Portrait shots keep the head, not the middle of the body.
                  alignment: Alignment.topCenter,
                  fallbackIconSize: 22,
                  fallbackColor: Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Size chips. One is always selected, as a size must be chosen to order.
class ProductSizePicker extends StatelessWidget {
  const ProductSizePicker({
    super.key,
    required this.sizes,
    required this.selected,
    required this.onSelected,
    this.unavailable = const {},
  });

  final List<String> sizes;
  final String selected;
  final ValueChanged<String> onSelected;

  /// Values that cannot be bought: dimmed and struck through, and they ignore
  /// taps.
  final Set<String> unavailable;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final size in sizes)
          GestureDetector(
            onTap: unavailable.contains(size) ? null : () => onSelected(size),
            behavior: HitTestBehavior.opaque,
            child: Opacity(
              opacity: unavailable.contains(size) ? 0.4 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                constraints: const BoxConstraints(minWidth: 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: size == selected
                        ? context.inkColor
                        : context.adapt(
                            const Color(0xFFE5E5E5),
                            const Color(0xFF404040),
                          ),
                    width: size == selected ? 1.5 : 0.75,
                  ),
                ),
                child: Text(
                  size,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.inkColor,
                    decoration: unavailable.contains(size)
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
