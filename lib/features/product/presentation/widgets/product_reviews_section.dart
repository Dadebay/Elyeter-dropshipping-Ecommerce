import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
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
            color: context.inkColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ProductStars(rating: rating, size: 18),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.productRatingCount(ratingCount),
          style: context.textTheme.bodySmall?.copyWith(
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
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  child: Text(
                    '${shares.length - i}',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.adapt(
                        AppColors.grey700,
                        AppColors.iconSoft,
                      ),
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
              children: [ProductStars(rating: review.rating, size: 16)],
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

/// A person silhouette on a light tinted disc — no photos to load.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  static const _size = 28.0;

  /// Light pastels, picked from the name so a reviewer keeps the same colour.
  static const _tints = [
    Color(0xFFC9B8FF),
    Color(0xFFFFC9AD),
    Color(0xFFB5E6C8),
    Color(0xFFFFBDD3),
    Color(0xFFB8D9FF),
    Color(0xFFFFE08A),
    Color(0xFFA8E6E0),
  ];

  final String name;

  @override
  Widget build(BuildContext context) {
    final tint = _tints[name.hashCode.abs() % _tints.length];

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
      child: Transform(
        transform: Matrix4.translationValues(0, 5, 0),
        child: SvgPicture.asset(
          AppAssets.iconReviewUser,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}

/// Five stars, filled up to [rating].
class ProductStars extends StatelessWidget {
  const ProductStars({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 1; i <= 5; i++)
        Icon(
          Icons.star_rounded,
          size: size,
          color: i <= rating.round()
              ? AppColors.primary
              : context.adapt(AppColors.grey300, const Color(0xFF404040)),
        ),
    ],
  );
}
