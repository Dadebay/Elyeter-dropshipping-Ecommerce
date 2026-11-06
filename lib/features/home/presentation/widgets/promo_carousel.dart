import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'promo_banner_card.dart';

export 'promo_banner_card.dart' show PromoBanner, PromoBannerCard;

/// Swipeable banner deck. The page dots sit on the artwork itself, near the
/// bottom edge of the card.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    super.key,
    required this.banners,
    this.height = 150,
    this.onTap,
    this.margin = EdgeInsets.zero,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.centerLeft,
  });

  final List<PromoBanner> banners;
  final double height;
  final ValueChanged<PromoBanner>? onTap;

  /// Spacing around the whole deck; the caller owns it.
  final EdgeInsetsGeometry margin;

  /// How each banner's artwork fills its card.
  final BoxFit fit;

  /// Which edge of the artwork is kept when [fit] crops.
  final Alignment alignment;

  /// Share of the viewport one card takes, leaving the next one peeking.
  static const _viewportFraction = 0.92;

  /// Half the gap between two cards.
  static const _cardGap = AppSpacing.xs;

  /// The reference artwork is roughly 2.4 times wider than it is tall.
  static double heightForWidth(double width) =>
      (width * _viewportFraction - 2 * _cardGap) / 2.4;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final _controller = PageController(
    viewportFraction: PromoCarousel._viewportFraction,
  );
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: widget.margin,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              padEnds: false,
              itemCount: widget.banners.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? AppSpacing.page : PromoCarousel._cardGap,
                    right: PromoCarousel._cardGap,
                  ),
                  child: PromoBannerCard(
                    banner: banner,
                    fit: widget.fit,
                    alignment: widget.alignment,
                    onTap: widget.onTap == null
                        ? null
                        : () => widget.onTap!(banner),
                  ),
                );
              },
            ),
            // On the artwork rather than under it, so the deck is one block.
            if (widget.banners.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.sm,
                child: IgnorePointer(
                  child: Center(
                    child: _Dots(count: widget.banners.length, index: _page),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small white circles directly on the artwork, with no pill or shadow.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < count; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          height: i == index ? 7 : 5,
          width: i == index ? 7 : 5,
          decoration: BoxDecoration(
            color: context.adapt(AppColors.white, AppColors.categoryDark),
            shape: BoxShape.circle,
          ),
        ),
    ],
  );
}
