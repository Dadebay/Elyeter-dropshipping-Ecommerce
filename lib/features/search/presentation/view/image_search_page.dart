import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/photo_upload_compressor.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product/presentation/widgets/product_card_actions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/image_search.dart';
import '../../domain/repositories/image_search_repository.dart';

/// Results of searching the catalogue with a photo.
///
/// Uploads the (compressed) photo, then asks for the search again every few
/// seconds while the server is still adding look-alikes, showing whatever has
/// arrived so far.
class ImageSearchPage extends StatefulWidget {
  const ImageSearchPage({super.key, this.imagePath, this.searchId})
    : assert(imagePath != null || searchId != null);

  /// A photo to search with: it is uploaded first.
  final String? imagePath;

  /// An existing search to open, e.g. from a notification.
  final int? searchId;

  @override
  State<ImageSearchPage> createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  /// Photos are shrunk before upload: the server takes 5 MB, and a phone
  /// shot is far more detail than a look-alike search needs.
  static const _maxBytes = 1024 * 1024;
  static const _maxSide = 1500;

  static const _pollEvery = Duration(seconds: 5);
  static const _pollFor = Duration(minutes: 3);

  ImageSearch? _search;
  Failure? _failure;
  bool _uploading = true;
  Timer? _timer;
  DateTime? _pollStarted;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _polling => _timer != null;

  Future<void> _start() async {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _uploading = true;
      _failure = null;
      _search = null;
    });
    final photo = widget.imagePath;
    final Result<ImageSearch> result;
    if (photo != null) {
      final path = await compressImageToLimit(
        photo,
        maxBytes: _maxBytes,
        maxSide: _maxSide,
      );
      result = await getIt<ImageSearchRepository>().create(path);
    } else {
      result = await getIt<ImageSearchRepository>().byId(widget.searchId!);
    }
    if (!mounted) return;
    setState(() {
      _uploading = false;
      _search = result.dataOrNull;
      _failure = result.failureOrNull;
    });
    if (_search?.status == ImageSearchStatus.processing) _poll();
  }

  void _poll() {
    _pollStarted = DateTime.now();
    _timer = Timer.periodic(_pollEvery, (_) => _refresh());
  }

  Future<void> _refresh() async {
    final id = _search?.id;
    if (id == null) return;
    if (DateTime.now().difference(_pollStarted!) > _pollFor) {
      _stopPolling();
      return;
    }
    final result = await getIt<ImageSearchRepository>().byId(id);
    if (!mounted || !_polling) return;
    final next = result.dataOrNull;
    // A failed poll is not worth interrupting the results for; the next
    // tick tries again.
    if (next == null) return;
    setState(() => _search = next);
    if (next.status != ImageSearchStatus.processing) _stopPolling();
  }

  void _stopPolling() {
    _timer?.cancel();
    setState(() => _timer = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppPageAppBar(title: l10n.imageSearchTitle),
      body: _body(context),
    );
  }

  /// What to say about the search's state, if anything.
  String? _noteFor(AppLocalizations l10n, ImageSearch search, bool searching) =>
      switch (search.status) {
        ImageSearchStatus.processing =>
          searching ? l10n.imageSearchSearching : null,
        ImageSearchStatus.inReview => l10n.imageSearchInReview(
          search.waitingCount,
        ),
        ImageSearchStatus.failed => l10n.imageSearchFailed,
        ImageSearchStatus.done => null,
      };

  Widget _body(BuildContext context) {
    final l10n = context.l10n;
    if (_uploading) {
      return _Waiting(
        path: widget.imagePath ?? _search?.image,
        label: l10n.imageSearchSearching,
      );
    }
    final failure = _failure;
    if (failure != null) {
      return _Problem(failure: failure, onRetry: _start);
    }
    final search = _search!;
    final products = search.products;
    final photo = widget.imagePath ?? search.image;
    final searching = search.status == ImageSearchStatus.processing && _polling;
    final note = _noteFor(l10n, search, searching);

    if (products.isEmpty) {
      return searching
          ? _Waiting(path: photo, label: l10n.imageSearchSearching)
          : _Empty(photo: photo, note: note, fallback: l10n.imageSearchEmpty);
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(photo: photo, note: note, searching: searching),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            120,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.57,
            ),
            delegate: SliverChildBuilderDelegate(childCount: products.length, (
              context,
              index,
            ) {
              final data = ProductCardData.fromProduct(products[index]);
              return BlocBuilder<FavoriteCubit, Set<String>>(
                builder: (context, favorites) =>
                    BlocBuilder<CartCubit, CartState>(
                      builder: (context, cart) => ProductCard(
                        data: data,
                        isFavorite: favorites.contains(data.favoriteKey),
                        isInCart: cart.contains(data.id),
                        onTap: () => context.pushNamed(
                          AppRoutes.productDetail.name,
                          pathParameters: {'id': data.id},
                        ),
                        onFavoriteTap: () async {
                          if (!context
                              .read<AuthCubit>()
                              .state
                              .isAuthenticated) {
                            await promptSignIn(context);
                            return;
                          }
                          if (context.mounted) {
                            await context.read<FavoriteCubit>().toggle(
                              data.favoriteKey,
                            );
                          }
                        },
                        onAddToCart: () => toggleCartFromCard(context, data),
                      ),
                    ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// The photo being searched with, small, and a note on where the search
/// stands (still looking, with a moderator, failed).
class _Header extends StatelessWidget {
  const _Header({
    required this.photo,
    required this.note,
    required this.searching,
  });

  final String? photo;
  final String? note;
  final bool searching;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.page,
      AppSpacing.sm,
      AppSpacing.page,
      0,
    ),
    child: Row(
      children: [
        _Thumb(path: photo, size: 56),
        const SizedBox(width: AppSpacing.md),
        if (searching) ...[
          const SizedBox.square(dimension: 18, child: AppLoader()),
          const SizedBox(width: AppSpacing.sm),
        ],
        if (note != null)
          Expanded(
            child: Text(
              note!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.adapt(AppColors.grey700, AppColors.iconSoft),
              ),
            ),
          ),
      ],
    ),
  );
}

/// The customer's photo: a local file just taken, or the server's copy of an
/// earlier search.
class _Thumb extends StatelessWidget {
  const _Thumb({required this.path, required this.size});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final box = SizedBox.square(
      dimension: size,
      child: ColoredBox(
        color: context.adapt(AppColors.grey100, AppColors.categoryDark),
      ),
    );
    final source = path;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: source == null
          ? box
          : source.startsWith('http')
          ? Image.network(
              source,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => box,
            )
          : Image.file(
              File(source),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => box,
            ),
    );
  }
}

/// No products to show yet (or at all): the photo and what is happening.
class _Empty extends StatelessWidget {
  const _Empty({
    required this.photo,
    required this.note,
    required this.fallback,
  });

  final String? photo;
  final String? note;

  /// Said when there is no state to report: simply nothing similar.
  final String fallback;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Thumb(path: photo, size: 120),
          const SizedBox(height: AppSpacing.xl),
          Text(
            note ?? fallback,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.adapt(AppColors.grey700, AppColors.iconSoft),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Upload in flight, or nothing found yet while the server keeps looking.
class _Waiting extends StatelessWidget {
  const _Waiting({required this.path, required this.label});

  final String? path;
  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Thumb(path: path, size: 120),
        const SizedBox(height: AppSpacing.xl),
        const SizedBox.square(dimension: 24, child: AppLoader()),
        const SizedBox(height: AppSpacing.md),
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.adapt(AppColors.grey700, AppColors.iconSoft),
          ),
        ),
      ],
    ),
  );
}

/// The search could not start; says why, and offers another go unless the
/// reason is the hourly limit.
class _Problem extends StatelessWidget {
  const _Problem({required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final retryAfter = failure.details?['retry_after_seconds'];
    final limited = failure.code == ApiCodes.tooManyRequests;
    final message = limited && retryAfter is num
        ? l10n.imageSearchRateLimited((retryAfter / 60).ceil().clamp(1, 60))
        : failure.localize(l10n);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.adapt(AppColors.grey700, AppColors.iconSoft),
              ),
            ),
            if (!limited) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
            ],
          ],
        ),
      ),
    );
  }
}
