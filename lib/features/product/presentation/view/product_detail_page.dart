import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../domain/entities/product_detail.dart';
import '../../domain/entities/product_reviews.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/product_repository.dart';
import '../model/variant_options.dart';
import '../model/product_share_content.dart';
import '../widgets/product_app_bar_actions.dart';
import '../widgets/product_detail_sections.dart';
import '../widgets/product_gallery.dart';
import '../widgets/product_option_picker.dart';
import '../widgets/product_review_dialog.dart';
import '../widgets/product_reviews_section.dart';

/// A product's own page: photos, options, price, article, description and
/// specification, with a sticky add-to-cart button.
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.initialVariantId,
  });

  /// Numeric product identifier from the catalog.
  final int productId;
  final int? initialVariantId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  /// Clearance for the sticky button at the foot of the page.
  static const _bottomInset = 112.0;

  late Future<Result<ProductDetail>> _future;
  late Future<Result<ProductReviews>> _reviewsFuture;

  /// The variant the customer is looking at. Set once the product arrives:
  /// the one already in their cart if there is one, else the first in stock.
  ProductVariant? _variant;
  bool _variantChosen = false;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _future = getIt<ProductRepository>().byId(widget.productId);
    _reviewsFuture = getIt<ProductRepository>().reviews(
      widget.productId,
      page: 1,
      size: 5,
    );
  }

  @override
  void didUpdateWidget(ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId ||
        oldWidget.initialVariantId != widget.initialVariantId) {
      _variantChosen = false;
      _variant = null;
      _future = getIt<ProductRepository>().byId(widget.productId);
      _reviewsFuture = getIt<ProductRepository>().reviews(
        widget.productId,
        page: 1,
        size: 5,
      );
    }
  }

  void _retry() => setState(() {
    _variantChosen = false;
    _future = getIt<ProductRepository>().byId(widget.productId);
    _reviewsFuture = getIt<ProductRepository>().reviews(
      widget.productId,
      page: 1,
      size: 5,
    );
  });

  void _refreshReviews() => setState(() {
    _reviewsFuture = getIt<ProductRepository>().reviews(
      widget.productId,
      page: 1,
      size: 5,
    );
  });

  void _pick(VariantOptions options, String name, String value) {
    final next = options.pick(name, value, _variant);
    if (next == null) return;
    setState(() => _variant = next);
    // A product already in the cart follows the choice; one that is not has
    // nothing to update, and must not leave a variant behind for later.
    final cart = context.read<CartCubit>();
    if (cart.contains(widget.productId.toString())) {
      cart.setVariant(widget.productId.toString(), next.id);
    }
  }

  void _toggleCart() {
    final cart = context.read<CartCubit>();
    final variant = _variant;
    if (variant != null && !cart.contains(widget.productId.toString())) {
      cart.setVariant(widget.productId.toString(), variant.id);
    }
    cart.toggle(widget.productId.toString());
  }

  Future<void> _shareProduct(
    BuildContext actionContext,
    ProductDetail detail,
    ProductVariant? variant,
  ) async {
    if (_sharing) return;
    final l10n = context.l10n;
    final box = actionContext.findRenderObject();
    final origin = box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    _sharing = true;
    try {
      await SharePlus.instance.share(
        productShareContent(
          product: detail.product,
          variant: variant,
          imageUrl: detail.gallery.firstOrNull,
          l10n: l10n,
          origin: origin,
        ),
      );
    } on PlatformException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.productShareFailed)));
      }
    } finally {
      _sharing = false;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Result<ProductDetail>>(
    key: ValueKey(widget.productId),
    future: _future,
    builder: (context, snapshot) {
      final detail = snapshot.data?.dataOrNull;
      if (detail == null) {
        return _Placeholder(snapshot: snapshot, onRetry: _retry);
      }

      final options = VariantOptions(detail.variants);
      if (!_variantChosen) {
        _variantChosen = true;
        _variant = options.initial(
          preferredId:
              widget.initialVariantId ??
              context.read<CartCubit>().state.variants[widget.productId
                  .toString()],
        );
      }

      final product = detail.product;
      final variant = _variant;
      final id = product.id.toString();

      return Scaffold(
        // White page, tinted blocks — the inverse of the app's other
        // screens, which is what the design does here.
        backgroundColor: context.adapt(
          AppColors.white,
          AppColors.backgroundDark,
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          // The buttons' soft shadow reaches below the bar; clipping it
          // left a hard edge under them.
          clipBehavior: Clip.none,
          leadingWidth: AppBackButton.leadingWidth,
          leading: const AppBackButton.appBarLeading(icon: AppIcons.back),
          actions: [
            BlocBuilder<FavoriteCubit, Set<String>>(
              builder: (context, favorites) => ProductAppBarActions(
                favorite: favorites.contains(product.id.toString()),
                onShare: () => _shareProduct(context, detail, variant),
                onFavorite: () async {
                  if (!context.read<AuthCubit>().state.isAuthenticated) {
                    await promptSignIn(context);
                    return;
                  }
                  if (context.mounted) {
                    await context.read<FavoriteCubit>().toggle(
                      product.id.toString(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              // No horizontal padding: the gallery runs edge to edge and
              // carries its own card margin. Everything after it is padded
              // as a block.
              padding: const EdgeInsets.only(top: 16, bottom: _bottomInset),
              children: [
                ProductGallery(
                  images: detail.gallery,
                  focusImage: variant?.image,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: context.inkColor),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ProductRatingRow(
                        rating: product.rating,
                        orderCount: product.ordersCount,
                      ),
                    ],
                  ),
                ),
                // Outside the padded block: the colour strip runs edge to
                // edge like the gallery, and each row pads its own text.
                for (final name in options.names)
                  if (options.valuesOf(name).length > 1) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _OptionRow(
                      name: name,
                      options: options,
                      variant: variant,
                      onPick: (value) => _pick(options, name, value),
                    ),
                  ],
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      // From here down the page is a stack of grey cards on
                      // the white background, so the gaps are card spacing.
                      ProductPriceCard(
                        name: product.name,
                        price: variant?.price ?? product.price,
                        oldPrice: variant == null
                            ? product.oldPrice
                            : variant.oldPrice,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ProductArticleCard(article: variant?.sku ?? product.sku),
                      if (ProductDescriptionCard.plainText(
                        detail.description ?? '',
                      ).isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        ProductDescriptionCard(
                          description: detail.description!,
                        ),
                      ],
                      if (detail.attributes.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        ProductCharacteristicsCard(
                          attributes: detail.attributes,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      FutureBuilder<Result<ProductReviews>>(
                        future: _reviewsFuture,
                        builder: (context, snapshot) {
                          final reviews = snapshot.data?.dataOrNull;
                          if (reviews != null) {
                            return ProductReviewsSection(
                              reviews: reviews,
                              onWrite: () async {
                                final saved = await showProductReviewDialog(
                                  context,
                                  productId: product.id,
                                  review: reviews.myReview,
                                );
                                if (saved && mounted) _refreshReviews();
                              },
                              onReadAll: () async {
                                await context.pushNamed(
                                  AppRoutes.productReviews.name,
                                  pathParameters: {'id': id},
                                );
                                if (mounted) _refreshReviews();
                              },
                            );
                          }
                          if (snapshot.hasData) {
                            return TextButton(
                              onPressed: _refreshReviews,
                              child: Text(context.l10n.reviewLoadError),
                            );
                          }
                          return const Center(child: AppLoader());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: AppSpacing.page,
              right: AppSpacing.page,
              bottom: AppSpacing.xxl,
              child: BlocBuilder<CartCubit, CartState>(
                buildWhen: (before, after) =>
                    before.contains(id) != after.contains(id),
                builder: (context, cart) => ProductStickyAddToCart(
                  added: cart.contains(id),
                  // A sold-out variant cannot be added, only taken out again.
                  enabled:
                      variant == null || variant.inStock || cart.contains(id),
                  onTap: _toggleCart,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// One row of options — colour as photos, anything else as chips — with the
/// chosen value named underneath.
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.name,
    required this.options,
    required this.variant,
    required this.onPick,
  });

  final String name;
  final VariantOptions options;
  final ProductVariant? variant;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final values = options.valuesOf(name);
    final selected = options.valueOf(variant, name);
    final unavailable = {
      for (var i = 0; i < values.length; i++)
        if (!options.isAvailable(name, values[i])) i,
    };

    const pad = EdgeInsets.symmetric(horizontal: AppSpacing.page);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (options.isVisual(name))
          // Edge to edge: the list pads its own ends, so the swatches scroll
          // under the screen edge instead of being cut at the page margin.
          ProductColorPicker(
            images: [for (final v in values) options.imageOf(name, v)!],
            selected: values.indexOf(selected ?? ''),
            unavailable: unavailable,
            onSelected: (index) => onPick(values[index]),
          )
        else
          Padding(
            padding: pad,
            child: ProductSizePicker(
              sizes: values,
              selected: selected ?? '',
              unavailable: {for (final i in unavailable) values[i]},
              onSelected: onPick,
            ),
          ),
        if (selected != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(padding: pad, child: ProductOptionLabel('$name: $selected')),
        ],
      ],
    );
  }
}

/// Loading, or the error with a way to retry, before there is a product.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.snapshot, required this.onRetry});

  final AsyncSnapshot<Result<ProductDetail>> snapshot;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.adapt(AppColors.white, AppColors.backgroundDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: AppBackButton.leadingWidth,
        leading: const AppBackButton.appBarLeading(icon: AppIcons.back),
      ),
      body: Center(
        child: snapshot.connectionState != ConnectionState.done
            ? const AppLoader()
            : TextButton(
                onPressed: onRetry,
                child: Text(snapshot.data?.failureOrNull?.message ?? 'Retry'),
              ),
      ),
    );
  }
}
