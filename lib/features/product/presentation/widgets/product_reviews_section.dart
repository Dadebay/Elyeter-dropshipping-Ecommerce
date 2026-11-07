import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../domain/entities/product_reviews.dart' as api;
import '../model/product_detail_data.dart';
import '../view/product_photo_viewer_page.dart';
import 'product_review_button.dart';
import 'product_section_card.dart';

/// Score, the per-star bars and a strip of the most recent reviews.
class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({
    super.key,
    required this.reviews,
    this.onReadAll,
    this.onWrite,
  });

  /// Height of the review strip: stars, four lines of text and the author
  /// row, with the card's own padding — no more, or every card trails an
  /// empty band under its author.
  static const _stripHeight = 156.0;

  /// Extra room for the photo row (76 high plus its 8 gap) when any card in
  /// the strip has photos; the strip's cards all share one height.
  static const _photosHeight = 84.0;

  final api.ProductReviews reviews;
  final VoidCallback? onReadAll;
  final VoidCallback? onWrite;

  @override
  Widget build(BuildContext context) {
    // One block, button included: the reviews and the way into the rest of
    // them are the same thing, and a second card underneath read as a
    // separate section.
    return ProductSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.productReviews,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.inkColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (reviews.summary.count > 0) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductReviewScore(
                  rating: reviews.summary.average ?? 0,
                  ratingCount: reviews.summary.count,
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: ProductReviewDistribution(
                    shares: reviews.summary.shares,
                  ),
                ),
              ],
            ),
            if (reviews.items.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                height:
                    _stripHeight +
                    (reviews.items.any((item) => item.images.isNotEmpty)
                        ? _photosHeight
                        : 0),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: reviews.items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) => ProductReviewCard(
                    fillHeight: true,
                    review: displayReview(context, reviews.items[index]),
                  ),
                ),
              ),
            ],
          ] else
            Text(
              context.l10n.reviewEmpty,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (reviews.summary.count == 0)
            ProductReviewButton(
              label: context.l10n.reviewWrite,
              onPressed: onWrite,
            )
          else
            _ReadAllButton(
              onTap: onReadAll,
              label: context.l10n.productReadAllReviews,
            ),
        ],
      ),
    );
  }
}

/// The way through to the full list: a white bar lifted off the grey block
/// by its shadow rather than outlined against it.
class _ReadAllButton extends StatelessWidget {
  const _ReadAllButton({required this.onTap, required this.label});

  static const _height = 52.0;

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.md);

    return DecoratedBox(
      // Outside the Material, which clips its own children to the shape.
      // Kept shallow so the block's own clip does not shave it off.
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: context.adapt(AppColors.white, AppColors.categoryDark),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: _height,
            width: double.infinity,
            child: Center(
              child: Text(
                label,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.inkColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

ProductReview displayReview(
  BuildContext context,
  api.ProductReviewEntry entry,
) {
  final createdAt = entry.createdAt;
  return ProductReview(
    author: entry.author ?? '',
    date: createdAt == null
        ? ''
        : DateFormatter.day(
            createdAt.toLocal(),
            locale: Localizations.localeOf(context).languageCode,
          ),
    rating: entry.rating.toDouble(),
    text: entry.comment ?? '',
    id: entry.id,
    images: [for (final image in entry.images) image.url],
    likes: entry.likesCount,
    liked: entry.myReaction == 'like',
    isMine: entry.isMine,
  );
}

/// The headline score: the number, its stars and how many ratings it is from.
class ProductReviewScore extends StatelessWidget {
  const ProductReviewScore({
    super.key,
    required this.rating,
    required this.ratingCount,
  });

  final double rating;
  final int ratingCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: context.textTheme.displayLarge?.copyWith(
            fontSize: 36,
            height: 44 / 36,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
            color: context.inkColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ProductStars(rating: rating, size: 16),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.productRatingCount(ratingCount),
          style: context.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            height: 20 / 14,
            color: AppColors.grey500,
          ),
        ),
      ],
    );
  }
}

/// One bar per star, five first — the share of ratings that gave it.
class ProductReviewDistribution extends StatelessWidget {
  const ProductReviewDistribution({super.key, required this.shares});

  static const _barHeight = 8.0;

  final List<double> shares;

  @override
  Widget build(BuildContext context) {
    if (shares.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < shares.length; i++)
          Padding(
            // Tight rows: the figures and bars sit close, as in the design.
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  child: Text(
                    '${shares.length - i}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      height: 20 / 14,
                      color: context.inkColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: shares[i],
                      minHeight: _barHeight,
                      // White track, not grey: the card underneath is already
                      // grey, so a grey track would disappear into it.
                      backgroundColor: context.adapt(
                        AppColors.white,
                        AppColors.backgroundDark,
                      ),
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A single review, as the strip and the full list both draw it.
///
/// The author sits inside the card, on its bottom row.
class ProductReviewCard extends StatelessWidget {
  const ProductReviewCard({
    super.key,
    required this.review,
    this.width = 285,
    this.maxLines = 4,
    this.color = AppColors.white,
    this.fillHeight = false,
    this.onHelpful,
  });

  final ProductReview review;

  /// White on the detail page's grey block; grey on the white reviews page.
  final Color color;

  /// Null stretches the card to whatever room it is given.
  final double? width;

  final int maxLines;

  /// Pins the footer to the bottom of a card with a fixed height.
  final bool fillHeight;

  /// Shows the "Helpful" button when set; not drawn on a customer's own review.
  final VoidCallback? onHelpful;

  @override
  Widget build(BuildContext context) {
    final body = review.text.isEmpty
        ? const SizedBox.shrink()
        : Text(
            review.text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.adapt(AppColors.grey700, AppColors.iconSoft),
              height: 1.4,
            ),
          );

    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [ProductStars(rating: review.rating, size: 12)],
            ),
          ),
          if (fillHeight)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Align(alignment: Alignment.topLeft, child: body),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: body,
            ),
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _ReviewPhotos(images: review.images, reviewId: review.id),
          ],
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                _Avatar(name: review.author),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    [
                      review.author,
                      review.date,
                    ].where((part) => part.isNotEmpty).join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onHelpful != null && !review.isMine)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  key: ValueKey('review-helpful-${review.id}'),
                  onTap: onHelpful,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          review.liked
                              ? Icons.thumb_up_alt_rounded
                              : Icons.thumb_up_off_alt_rounded,
                          size: 18,
                          color: review.liked
                              ? AppColors.primary
                              : AppColors.grey500,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          review.likes > 0
                              ? context.l10n.reviewHelpfulCount(review.likes)
                              : context.l10n.reviewHelpful,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: review.liked
                                ? AppColors.primary
                                : AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Photos attached to a review; tapping one opens the full-screen viewer.
class _ReviewPhotos extends StatelessWidget {
  const _ReviewPhotos({required this.images, required this.reviewId});

  final List<String> images;
  final int reviewId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: images.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => ProductPhotoViewerPage.open(
            context,
            images: images,
            initialIndex: index,
            heroPrefix: 'review-$reviewId',
          ),
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 0.75),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md - 0.75),
              child: Hero(
                tag: 'review-$reviewId-$index',
                child: CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppColors.white),
                  errorWidget: (_, _, _) =>
                      const ColoredBox(color: AppColors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A person silhouette on a tinted disc, one of three designs picked from the
/// reviewer's name — so a reviewer keeps the same avatar every time, and the
/// list still looks varied. No photos to load.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.size = 28});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final avatars = AppAssets.reviewerAvatars;
    final asset = avatars[_stableHash(name) % avatars.length];

    return SvgPicture.asset(asset, width: size, height: size);
  }

  /// `String.hashCode` is not guaranteed to match between runs; the avatar
  /// must not change from one launch to the next.
  static int _stableHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }
}

/// Five stars, filled up to [rating]: the design's own orange and pale grey
/// star artwork.
class ProductStars extends StatelessWidget {
  const ProductStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.gap = 2,
  });

  final double rating;
  final double size;

  /// Space between two stars.
  final double gap;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 1; i <= 5; i++)
        Padding(
          padding: EdgeInsets.only(right: i == 5 ? 0 : gap),
          child: AppAssetImage(
            i <= rating.round()
                ? AppAssets.iconStarFilled
                : AppAssets.iconStarEmpty,
            width: size,
            height: size,
            // The pale grey would glare on dark.
            color: i <= rating.round() || !context.isDark
                ? null
                : const Color(0xFF404040),
          ),
        ),
    ],
  );
}

/// A review on the full reviews page, as the design draws it: the author and
/// date on top with a menu for the customer's own review, then the stars, the
/// text, the photos in a row of equal squares, and "Helpful" underneath.
class ProductReviewListCard extends StatelessWidget {
  const ProductReviewListCard({
    super.key,
    required this.review,
    this.onHelpful,
    this.onEdit,
    this.onDelete,
  });

  final ProductReview review;
  final VoidCallback? onHelpful;

  /// Edit / delete, offered in the menu of the customer's own review only.
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static const _photoGap = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    final meta = [
      review.author,
      review.date,
    ].where((part) => part.isNotEmpty).join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.adapt(AppColors.background, AppColors.categoryDark),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Figma: the avatar, then the name and date with the stars right
          // under them, all centred against the avatar; the dots stand at the
          // far end of the same row.
          Row(
            children: [
              _Avatar(name: review.author, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // Figma: Inter Display Regular 12 / 16, spacing 0,
                      // #5C5C5C.
                      style: theme.bodyMedium?.copyWith(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                        color: context.adapt(
                          const Color(0xFF5C5C5C),
                          AppColors.grey300,
                        ),
                      ),
                    ),
                    // Figma: 12 px stars, 2 px apart.
                    ProductStars(rating: review.rating, size: 12),
                  ],
                ),
              ),
              if (review.isMine && (onEdit != null || onDelete != null))
                _OwnReviewMenu(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              review.text,
              // Figma: Inter Display Regular 12 / 16, spacing 0, #0D0D0D.
              style: theme.bodyMedium?.copyWith(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                color: context.adapt(const Color(0xFF0D0D0D), AppColors.white),
              ),
            ),
          ],
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                // Three to a row, however wide the card is.
                final side = (constraints.maxWidth - _photoGap * 2) / 3;
                return Wrap(
                  spacing: _photoGap,
                  runSpacing: _photoGap,
                  children: [
                    for (var i = 0; i < review.images.length; i++)
                      GestureDetector(
                        onTap: () => ProductPhotoViewerPage.open(
                          context,
                          images: review.images,
                          initialIndex: i,
                          heroPrefix: 'review-${review.id}',
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: SizedBox(
                            width: side,
                            height: side,
                            child: Hero(
                              tag: 'review-${review.id}-$i',
                              child: CachedNetworkImage(
                                imageUrl: review.images[i],
                                fit: BoxFit.cover,
                                placeholder: (_, _) => ColoredBox(
                                  color: context.adapt(
                                    AppColors.white,
                                    AppColors.backgroundDark,
                                  ),
                                ),
                                errorWidget: (_, _, _) => ColoredBox(
                                  color: context.adapt(
                                    AppColors.white,
                                    AppColors.backgroundDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
          if (onHelpful != null && !review.isMine) ...[
            const SizedBox(height: AppSpacing.md),
            InkWell(
              key: ValueKey('review-helpful-${review.id}'),
              onTap: onHelpful,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      review.liked
                          ? Icons.thumb_up_alt_rounded
                          : Icons.thumb_up_off_alt_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      review.likes > 0
                          ? context.l10n.reviewHelpfulCount(review.likes)
                          : context.l10n.reviewHelpful,
                      style: theme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _OwnReviewAction { edit, delete }

/// The "..." at the card's top right: edit or delete the customer's own
/// review.
class _OwnReviewMenu extends StatelessWidget {
  const _OwnReviewMenu({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_OwnReviewAction>(
    key: const Key('review-own-menu'),
    padding: EdgeInsets.zero,
    tooltip: MaterialLocalizations.of(context).showMenuTooltip,
    onSelected: (action) => switch (action) {
      _OwnReviewAction.edit => onEdit?.call(),
      _OwnReviewAction.delete => onDelete?.call(),
    },
    itemBuilder: (context) => [
      if (onEdit != null)
        PopupMenuItem(
          value: _OwnReviewAction.edit,
          child: Text(context.l10n.reviewEdit),
        ),
      if (onDelete != null)
        PopupMenuItem(
          value: _OwnReviewAction.delete,
          child: Text(context.l10n.reviewDelete),
        ),
    ],
    // Three solid dots, as the design draws them, not the hollow glyph.
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.inkColor,
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: 5),
            ),
          ],
        ],
      ),
    ),
  );
}
