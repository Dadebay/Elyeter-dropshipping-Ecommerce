import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/widgets/counting_number.dart';

/// The pill that floats over the list: how many products are ticked and what
/// they come to, with the undiscounted total struck out beside it.
///
/// A translucent material rather than a solid bar — the cart scrolls
/// underneath it and stays legible through the blur, so the pill reads as a
/// layer above the list instead of a strip cut out of it.
class CartSummaryBar extends StatelessWidget {
  const CartSummaryBar({
    super.key,
    required this.productCount,
    required this.total,
    required this.oldTotal,
    this.onTap,
  });

  final int productCount;
  final num total;

  /// Total before discounts; struck out when it is higher than [total].
  final num oldTotal;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Use a solid surface when extra contrast is requested.
    final opaque = MediaQuery.highContrastOf(context);

    final content = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: _Row(
            productCount: productCount,
            total: total,
            oldTotal: oldTotal,
          ),
        ),
      ),
    );

    return GlassmorphicContainer(
      borderRadius: AppRadius.pill,
      blur: opaque ? 0 : 4,
      border: opaque ? 0 : 1.3,
      // A narrow warm reflection gives the glass depth over an empty cart
      // backdrop, while the centre keeps its translucent peach tint.
      linearGradient: opaque
          ? LinearGradient(
              colors: context.isDark
                  ? const [Color(0xFF4A2A18), Color(0xFF4A2A18)]
                  : const [Color(0xFFFFD8BF), Color(0xFFFFD8BF)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.14, 0.68, 1],
              colors: [
                Color(0x66FFC395),
                Color(0x66FF9D5C),
                Color(0x66FF9D5C),
                Color(0x70F39459),
              ],
            ),
      borderGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0, 0.4, 0.65, 1],
        colors: [
          Color(0xE6FFF0E2),
          Color(0x73FFD8BB),
          Color(0x4DCE8558),
          Color(0xB3FFE2CC),
        ],
      ),
      // The package paints shadows outside the glass, so its own shadow
      // cannot darken the translucent surface or obscure the products.
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A7A4727),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
        BoxShadow(
          color: Color(0x0F573921),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
      child: content,
    );
  }
}

/// Count on the left, totals on the right.
///
/// Type over a translucent surface carries a little more weight than it
/// would on a solid one — light and flat goes muddy once the photos
/// underneath start moving.
class _Row extends StatelessWidget {
  const _Row({
    required this.productCount,
    required this.total,
    required this.oldTotal,
  });

  final int productCount;
  final num total;
  final num oldTotal;

  @override
  Widget build(BuildContext context) {
    final saved = oldTotal > total;

    return Row(
      children: [
        // Its own width and no more. As a Flexible it was handed half the free
        // space whether it used it or not, which left a gap at the right end
        // that the totals could not reach.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: Text(
            context.l10n.cartProductCount(productCount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.inkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // The totals keep their place; they shrink before the label gets
        // clipped.
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (saved) ...[
                  CountingNumber(
                    value: oldTotal,
                    builder: (shown) => Text(
                      '${CurrencyFormatter.amount(shown, locale: context.l10n.localeName)} '
                      '${AppConstants.currencySymbol}',
                      style: context.textTheme.bodySmall?.copyWith(
                        // Red would sink into the orange; a muted ink reads on it.
                        color: context.inkColor.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: context.inkColor.withValues(
                          alpha: 0.55,
                        ),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                CountingNumber(
                  value: total,
                  builder: (shown) => Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: CurrencyFormatter.amount(
                            shown,
                            locale: context.l10n.localeName,
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: AppConstants.currencySymbol,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.inkColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.inkColor,
                      fontWeight: FontWeight.w800,
                      // Large, heavy figures read too loose at their default
                      // tracking; tighten as the size goes up.
                      letterSpacing: -0.2,
                      // Digits all as wide as each other, so the figure does
                      // not shimmy sideways while it counts.
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
