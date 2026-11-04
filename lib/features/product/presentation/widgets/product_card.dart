import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/favorite_button.dart';
import '../../../../core/constants/app_icons.dart';
import 'product_image_view.dart';
import 'product_photos.dart';
import '../../domain/entities/product.dart';

/// Minimal shape a card needs to render. Swap for the real entity once the
/// product API lands — only this type changes, not the layout.
class ProductCardData {
  const ProductCardData({
    required this.id,
    required this.title,
    required this.price,
    this.oldPrice,
    this.images = const [],
    this.specs = const [],
    this.attributes = const {},
    this.apiId,
    this.slug,
    this.hasVariants = false,
  });

  factory ProductCardData.fromProduct(Product product) => ProductCardData(
    id: product.id.toString(),
    slug: product.slug,
    apiId: product.id,
    hasVariants: product.hasVariants,
    title: product.name,
    price: product.price,
    oldPrice: product.oldPrice,
    images: product.mainImage == null ? const [] : [product.mainImage!],
  );

  final String id;
  final int? apiId;
  final String? slug;
  final bool hasVariants;
  String get favoriteKey => (apiId?.toString() ?? id);
  final String title;
  final num price;

  /// Price before the discount; drives the `-20%` badge.
  final num? oldPrice;

  /// Every photo of the product, in order. An entry is a bundled asset when
  /// it starts with `assets/`, otherwise a URL — so placeholder artwork and
  /// API images can sit in the same list.
  final List<String> images;

  /// Short attribute lines ("Material: Jewelry Alloy"). Listed on a cart
  /// line; the catalog card has no room for them.
  final List<String> specs;

  /// Facet id to value, e.g. `{'brand': 'Apple', 'color': 'Black'}`. What the
  /// category filters match on — derived facet options come from these, so a
  /// filter can never offer a value nothing carries. Empty until the API
  /// supplies them, which simply leaves the product out of every facet.
  final Map<String, String> attributes;

  /// Whole percent off, or null when the product is not discounted.
  int? get discountPercent {
    final was = oldPrice;
    if (was == null || was <= price) return null;
    return ((was - price) / was * 100).round();
  }
}

/// Catalog tile: swipeable photos, price, title, add-to-cart — the card used
/// in the home grid, category lists and search results.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.data,
    this.onTap,
    this.onAddToCart,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.isInCart = false,
    this.addToCartLabel,
    this.addedLabel,
  });

  final ProductCardData data;

  /// Whether this product is in the customer's favourites. Owned by the page,
  /// so the same product reads the same everywhere it is listed.
  final bool isFavorite;

  /// Whether this product is already in the cart; flips the button to its
  /// "Added" state.
  final bool isInCart;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavoriteTap;

  /// Both default to the localized strings; pass them only to override.
  final String? addToCartLabel;
  final String? addedLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loose Flexible: the image keeps its square shape when there is
          // room and gives some back when the grid cell is short, instead of
          // overflowing the column.
          Flexible(
            child: AspectRatio(
              aspectRatio: 1,
              child: _Gallery(
                images: data.images,
                productId: data.apiId,
                discountPercent: data.discountPercent,
                isFavorite: isFavorite,
                onFavoriteTap: onFavoriteTap,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _Price(price: data.price),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey700,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _AddToCartButton(
            label: isInCart
                ? (addedLabel ?? context.l10n.commonAdded)
                : (addToCartLabel ?? context.l10n.commonAddToCart),
            added: isInCart,
            onTap: onAddToCart,
          ),
        ],
      ),
    );
  }
}

/// The photo area: swipeable images with the favourite button, the discount
/// badge and the page dots laid over them.
class _Gallery extends StatefulWidget {
  const _Gallery({
    required this.images,
    this.productId,
    required this.discountPercent,
    required this.isFavorite,
    this.onFavoriteTap,
  });

  final List<String> images;

  /// The product's productId, for fetching its other photos. Null leaves the card
  /// with the photos it was given.
  final int? productId;
  final int? discountPercent;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  final _controller = PageController();
  int _page = 0;

  /// What the card swipes through: the photo it was given, then up to two
  /// more once the product's own photos arrive.
  late List<String> _images = _initialImages();

  List<String> _initialImages() {
    final productId = widget.productId;
    final extra = productId == null ? null : ProductPhotos.cached(productId);
    return ProductPhotos.merge(widget.images, extra ?? const []);
  }

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  @override
  void didUpdateWidget(_Gallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId ||
        oldWidget.images != widget.images) {
      _images = _initialImages();
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final productId = widget.productId;
    if (productId == null || ProductPhotos.cached(productId) != null) return;
    final extra = await ProductPhotos.load(productId);
    if (!mounted || widget.productId != productId || extra.isEmpty) return;
    setState(() => _images = ProductPhotos.merge(widget.images, extra));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = _images.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: ColoredBox(
        color: AppColors.background,
        child: Stack(
          children: [
            Positioned.fill(
              child: count == 0
                  ? const AppNetworkImage(
                      url: null,
                      radius: 0,
                      fallbackColor: AppColors.background,
                    )
                  : PageView.builder(
                      controller: _controller,
                      itemCount: count,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (context, index) => _SwipeEffect(
                        index: index,
                        fallbackPage: _page,
                        child: _Photo(_images[index]),
                      ),
                    ),
            ),
            // Hairline frame (Figma: 0.65px #EBEBEB, inner) so photos with a
            // white backdrop don't dissolve into the page.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: const Color(0xFFEBEBEB),
                      width: 0.65,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              // The button carries its own transparent padding, so it sits
              // closer to the corner than the badges do.
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: FavoriteButton(
                active: widget.isFavorite,
                onTap: widget.onFavoriteTap,
              ),
            ),
            if (widget.discountPercent != null)
              Positioned(
                // Nearly flush: the artwork brings most of the inset itself.
                left: 2,
                bottom: 2,
                child: _DiscountBadge(percent: widget.discountPercent!),
              ),
            if (count > 1)
              Positioned(
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: IgnorePointer(
                  child: _Dots(count: count, index: _page),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One photo, from the bundle or the network depending on the path.
/// How a photo behaves while the pager moves it: it eases out of the frame
/// slower than the swipe (a touch of parallax), shrinks a little and fades,
/// and does the reverse as it arrives — so the photos hand over to each
/// other instead of just sliding past.
class _SwipeEffect extends StatelessWidget {
  const _SwipeEffect({
    required this.index,
    required this.fallbackPage,
    required this.child,
  });

  /// How much of its own width a photo trails the swipe by.
  static const _parallax = 0.25;
  static const _minScale = 0.88;
  static const _minOpacity = 0.35;

  final int index;

  /// Where the pager is before it has been laid out and has no position yet.
  final int fallbackPage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Use the position of this photo's PageView. A controller can briefly be
    // attached to more than one scroll view during a widget transition.
    final position = Scrollable.of(context).position;
    return AnimatedBuilder(
      animation: position,
      child: child,
      builder: (context, child) {
        final page = position is PageMetrics && position.haveDimensions
            ? (position as PageMetrics).page ?? fallbackPage.toDouble()
            : fallbackPage.toDouble();
        // -1 .. 1: negative while the photo is arriving from the right,
        // positive while it is leaving to the left; 0 when it is centred.
        final offset = (page - index).clamp(-1.0, 1.0);
        final distance = offset.abs();

        return LayoutBuilder(
          builder: (context, constraints) => Opacity(
            opacity: 1 - (1 - _minOpacity) * distance,
            child: Transform.translate(
              offset: Offset(offset * constraints.maxWidth * _parallax, 0),
              child: Transform.scale(
                scale: 1 - (1 - _minScale) * distance,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo(this.source);

  final String source;

  @override
  Widget build(BuildContext context) => ProductImageView(
    source: source,
    // Edge to edge: the photo covers the whole tile, cropped to fit, with no
    // grey showing round it.
    fit: BoxFit.cover,
    fallbackColor: AppColors.background,
    // Each photo that has not arrived yet — the second and third are fetched
    // as the customer swipes to them — shows the sweeping wordmark rather
    // than an empty grey tile.
    wordmarkPlaceholder: true,
    wordmarkSize: 22,
  );
}

/// `-20%`, bottom left of the photo: the supplied ticket artwork with the
/// live percentage drawn over it.
class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});

  /// The artwork is drawn smaller than its natural 70x40; at card size the
  /// full-size ticket crowds the photo. It keeps its aspect ratio, and with
  /// it the 8px of transparent shadow padding that scales to ~6px.
  static const _width = 56.0;
  static const _height = 32.0;

  /// Room the number has inside the ticket, clear of the two notches.
  static const _textInset = 13.0;

  final int percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.iconDiscountBanner,
            width: _width,
            height: _height,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _textInset),
            child: FittedBox(
              // -5% and -100% both have to sit inside a fixed-width ticket.
              child: Text(
                '-$percent%',
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Which photo is showing, bottom right of the photo.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  /// Beyond this the dots stop being readable at card size.
  static const _maxDots = 5;

  @override
  Widget build(BuildContext context) {
    final shown = count.clamp(0, _maxDots);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < shown; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: i == index ? 10 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: i == index ? AppColors.grey900 : AppColors.grey300,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `7 526 man` — the amount and the currency are styled separately.
class _Price extends StatelessWidget {
  const _Price({required this.price});

  static const _color = AppColors.primaryVibrant;
  static const _currencyLabel = 'man';

  final num price;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          CurrencyFormatter.amount(price, locale: context.l10n.localeName),
          style: context.textTheme.titleLarge?.copyWith(
            color: _color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          _currencyLabel,
          style: context.textTheme.bodyMedium?.copyWith(
            color: _color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// Grey while the product can still be added, brand-orange with a tick once
/// it is in the cart. Tapping it again takes the product back out.
class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.label,
    required this.added,
    this.onTap,
  });

  /// The glyph box, sized so both states lay out identically.
  static const _iconSlot = 24.0;
  static const _iconSize = 18.0;
  static const _height = 40.0;

  /// How far the glyph sits from the button's left edge.
  static const _edgeInset = AppSpacing.md;

  final String label;
  final bool added;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = added ? AppColors.white : Colors.black;
    final radius = BorderRadius.circular(AppRadius.md);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      // Always the cell's full width. The Column above hands its children
      // loose width, and a Stack would otherwise shrink to its label — so
      // "Added" came out narrower than "Add to Card".
      width: double.infinity,
      height: _height,
      decoration: BoxDecoration(
        color: added ? AppColors.primary : const Color(0xFFF3F5F7),
        borderRadius: radius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The glyph holds the left edge and the label the middle, as
              // the design draws it, rather than the two huddled together.
              Positioned(
                left: _edgeInset,
                child: SizedBox(
                  width: _iconSlot,
                  height: _iconSlot,
                  child: Center(
                    child: added
                        ? HugeIcon(
                            icon: AppIcons.check,
                            size: _iconSize,
                            color: foreground,
                          )
                        : SvgPicture.asset(
                            AppAssets.iconShoppingBagOutline,
                            width: _iconSize,
                            height: _iconSize,
                            colorFilter: ColorFilter.mode(
                              foreground,
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                ),
              ),
              // Clear of the glyph on both sides, so the label stays centred
              // and never runs under it. Scaled down rather than cut if the
              // cell is too narrow for it: the whole label always shows.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _iconSlot + _edgeInset + AppSpacing.xs,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
