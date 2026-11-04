import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../domain/entities/product_reviews.dart';
import '../../domain/repositories/product_repository.dart';
import '../widgets/product_review_button.dart';
import '../widgets/product_review_dialog.dart';
import '../widgets/product_reviews_section.dart';
import '../widgets/product_section_card.dart';

class ProductReviewsPage extends StatefulWidget {
  const ProductReviewsPage({super.key, required this.productId});
  final String productId;

  @override
  State<ProductReviewsPage> createState() => _ProductReviewsPageState();
}

class _ProductReviewsPageState extends State<ProductReviewsPage> {
  static const _pageSize = 20;
  ProductReviews? _reviews;
  List<ProductReviewEntry> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _saving = false;
  int _request = 0;
  int? _ratingFilter;
  ReviewSortOption _sort = ReviewSortOption.newest;
  final _reacting = <int>{};

  int get _id => int.parse(widget.productId);
  ProductRepository get _repo => getIt<ProductRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ProductReviewsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _loadingMore = false;
    });
    final result = await _repo.reviews(
      _id,
      page: 1,
      size: _pageSize,
      rating: _ratingFilter,
      sort: _sort,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _loading = false;
      _reviews = result.dataOrNull;
      _items = _reviews?.items ?? [];
    });
  }

  Future<void> _loadMore() async {
    final current = _reviews;
    if (current == null ||
        _loadingMore ||
        _items.length >= current.totalCount) {
      return;
    }
    final request = _request;
    setState(() => _loadingMore = true);
    final result = await _repo.reviews(
      _id,
      page: current.page + 1,
      size: _pageSize,
      rating: _ratingFilter,
      sort: _sort,
    );
    if (!mounted || request != _request) return;
    setState(() {
      _loadingMore = false;
      if (result.dataOrNull case final next?) {
        _reviews = next;
        _items = [..._items, ...next.items];
      }
    });
    if (result.isError) _message(context.l10n.reviewLoadError);
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickSort() async {
    final l10n = context.l10n;
    final labels = {
      ReviewSortOption.newest: l10n.reviewSortNewest,
      ReviewSortOption.oldest: l10n.reviewSortOldest,
      ReviewSortOption.mostLiked: l10n.reviewSortMostLiked,
      ReviewSortOption.mostDisliked: l10n.reviewSortMostDisliked,
      ReviewSortOption.withPhotos: l10n.reviewSortWithPhotos,
      ReviewSortOption.withoutPhotos: l10n.reviewSortWithoutPhotos,
    };
    final picked = await _pickOption<ReviewSortOption>(
      title: l10n.reviewSortBy,
      current: _sort,
      options: [for (final e in labels.entries) (e.key, e.value)],
    );
    if (picked == null || picked.$1 == _sort) return;
    setState(() => _sort = picked.$1);
    await _load();
  }

  Future<void> _pickRating() async {
    final l10n = context.l10n;
    final picked = await _pickOption<int?>(
      title: l10n.reviewRatingFilter,
      current: _ratingFilter,
      options: [
        (null, l10n.reviewAllRatings),
        for (var s = 5; s >= 1; s--) (s, '$s'),
      ],
      content: (value, label, color) => value == null
          ? Text(
              label,
              style: context.textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: _ratingFilter == null
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            )
          : Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  Icon(
                    Icons.star_rounded,
                    size: 22,
                    color: i <= value
                        ? AppColors.primaryVibrant
                        : const Color(0xFFE4E4E7),
                  ),
              ],
            ),
      count: (value) =>
          value == null ? null : _reviews?.summary.distribution[value],
    );
    if (picked == null || picked.$1 == _ratingFilter) return;
    setState(() => _ratingFilter = picked.$1);
    await _load();
  }

  /// Returns a record so that picking the null option ("all") is told apart
  /// from dismissing the sheet.
  ///
  /// [content] draws what is inside a row in place of the plain label, and
  /// [count] adds a small figure at its end.
  Future<(T,)?> _pickOption<T>({
    required String title,
    required T current,
    required List<(T, String)> options,
    Widget Function(T value, String label, Color color)? content,
    int? Function(T value)? count,
  }) {
    return showModalBottomSheet<(T,)>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            0,
            AppSpacing.page,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: sheetContext.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    tooltip: sheetContext.l10n.commonClose,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceMuted,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (final option in options) ...[
                _SheetOption(
                  selected: option.$1 == current,
                  onTap: () => Navigator.pop(sheetContext, (option.$1,)),
                  count: count?.call(option.$1),
                  builder: (color) =>
                      content?.call(option.$1, option.$2, color) ??
                      Text(
                        option.$2,
                        style: sheetContext.textTheme.bodyLarge?.copyWith(
                          color: color,
                          fontWeight: option.$1 == current
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleHelpful(ProductReviewEntry review) async {
    if (_reacting.contains(review.id)) return;
    if (!context.read<AuthCubit>().state.isAuthenticated &&
        (!await promptSignIn(context) || !mounted)) {
      return;
    }
    setState(() => _reacting.add(review.id));
    final liked = review.myReaction == 'like';
    final result = liked
        ? await _repo.removeReviewReaction(_id, review.id)
        : await _repo.reactToReview(_id, review.id, 'like');
    if (!mounted) return;
    setState(() {
      _reacting.remove(review.id);
      if (result.dataOrNull case final reaction?) {
        _items = [
          for (final item in _items)
            item.id == review.id ? item.withReaction(reaction) : item,
        ];
      }
    });
    if (result.isError) _message(context.l10n.reviewActionError);
  }

  Future<void> _write() async {
    final saved = await showProductReviewDialog(
      context,
      productId: _id,
      review: _reviews?.myReview,
    );
    if (saved && mounted) await _load();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.reviewDeleteConfirm),
        content: Text(context.l10n.reviewDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.reviewDelete),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() => _saving = true);
    final result = await _repo.deleteMyReview(_id);
    if (!mounted) return;
    setState(() => _saving = false);
    _message(
      result.isSuccess
          ? context.l10n.reviewDeleted
          : context.l10n.reviewActionError,
    );
    if (result.isSuccess) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviews;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppPageAppBar(title: context.l10n.productReviews),
      body: _loading && reviews == null
          ? const Center(child: AppLoader())
          : reviews == null
          ? Center(
              child: TextButton(
                onPressed: _load,
                child: Text(context.l10n.reviewLoadError),
              ),
            )
          : AppRefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.xxl,
                ),
                children: [
                  ProductSectionCard(
                    child: reviews.summary.count == 0
                        ? Text(context.l10n.reviewEmpty)
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductReviewScore(
                                rating: reviews.summary.average ?? 0,
                                ratingCount: reviews.summary.count,
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: ProductReviewDistribution(
                                  shares: reviews.summary.shares,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProductReviewButton(
                    onPressed: _saving || _loading ? null : _write,
                    label: reviews.myReview == null
                        ? context.l10n.reviewWrite
                        : context.l10n.reviewEdit,
                  ),
                  if (reviews.myReview != null)
                    TextButton(
                      onPressed: _saving || _loading ? null : _delete,
                      child: Text(context.l10n.reviewDelete),
                    ),
                  if (reviews.myReview?.isHidden ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        context.l10n.reviewHiddenNotice,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _FilterChip(
                        key: const Key('reviews-sort'),
                        label: context.l10n.reviewSortBy,
                        active: _sort != ReviewSortOption.newest,
                        onTap: _pickSort,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _FilterChip(
                        key: const Key('reviews-rating'),
                        label: _ratingFilter == null
                            ? context.l10n.reviewRatingFilter
                            : '$_ratingFilter ★',
                        active: _ratingFilter != null,
                        onTap: _pickRating,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_items.isEmpty && !_loading)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                      ),
                      child: Text(
                        context.l10n.reviewNoMatches,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Center(child: AppLoader()),
                    ),
                  if (!_loading)
                    for (final review in _items) ...[
                      ProductReviewCard(
                        review: displayReview(context, review),
                        width: null,
                        maxLines: 100,
                        color: AppColors.background,
                        onHelpful: () => _toggleHelpful(review),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  if (_items.length < reviews.totalCount)
                    TextButton(
                      onPressed: _loadingMore ? null : _loadMore,
                      child: _loadingMore
                          ? const AppLoader()
                          : Text(context.l10n.reviewLoadMore),
                    ),
                ],
              ),
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primarySoft : AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: active ? AppColors.primary : AppColors.black,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: active ? AppColors.primary : AppColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One choice in a filter sheet: a rounded row that turns orange when it is
/// the current pick, with a round marker at its end.
class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.selected,
    required this.onTap,
    required this.builder,
    this.count,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget Function(Color color) builder;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryVibrant : AppColors.black;
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? AppColors.primaryVibrant : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: builder(color),
                ),
              ),
              if (count != null) ...[
                Text(
                  '$count',
                  style: context.textTheme.labelLarge?.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.primaryVibrant : AppColors.white,
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryVibrant
                        : const Color(0xFFCFCFD4),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: AppColors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
