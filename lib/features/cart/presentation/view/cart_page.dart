import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../../order/domain/entities/pre_order_line.dart';
import '../../../order/domain/repositories/pre_order_repository.dart';
import '../../../order/presentation/widgets/order_address_dialog.dart';
import '../../../order/presentation/widgets/order_problem_dialog.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../product/domain/entities/product_detail.dart';
import '../../../product/domain/entities/product_id.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_empty_view.dart';
import '../widgets/cart_line_tile.dart';
import '../widgets/cart_summary_bar.dart';
import '../widgets/swipe_to_delete.dart';

/// The cart: one line per product, a running total over the list.
///
/// Stores numeric product IDs, quantities and variants. Old slug records are
/// resolved through the catalog before fetching their details.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  /// Resting height of the summary pill. Only feeds the scroll clearance, so
  /// a pixel either way just changes how much empty space trails the list.
  static const _summaryHeight = 56.0;

  /// Gap under the pill, and again under the list.
  static const _gap = AppSpacing.md;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Map<String, ProductDetail> _details = {};
  final Set<String> _requested = {};
  final Set<String> _failed = {};
  bool _legacyAttempted = false;
  bool _migratingLegacy = false;

  void _ensureLoaded(Iterable<String> ids) {
    if (!_legacyAttempted &&
        ids.any((id) => CartCubit.legacySlug(id) != null)) {
      _legacyAttempted = true;
      _migratingLegacy = true;
      _migrateLegacy();
    }
    for (final id in ids) {
      if (ProductId.tryParse(id) == null) continue;
      final known = _details.containsKey(id);
      if (known || !_requested.add(id)) continue;
      _fetch(id);
    }
  }

  Future<void> _migrateLegacy() async {
    await context.read<CartCubit>().migrateLegacyProducts(
      getIt<ProductRepository>(),
    );
    if (mounted) setState(() => _migratingLegacy = false);
  }

  Future<void> _fetch(String id) async {
    final result = await getIt<ProductRepository>().byId(
      ProductId.tryParse(id)!,
    );
    if (!mounted) return;
    final detail = result.dataOrNull;
    if (detail != null) {
      setState(() => _details[id] = detail);
      return;
    }
    if (result.failureOrNull is NotFoundFailure) {
      context.read<CartCubit>().remove(id);
    } else {
      setState(() => _failed.add(id));
    }
  }

  Future<void> _retry() async {
    setState(() {
      _requested.removeAll(_failed);
      _failed.clear();
      _legacyAttempted = false;
    });
  }

  /// The line for [id], or null while it is still being fetched.
  ProductCardData? _line(String id, CartState cart) {
    final detail = _details[id];
    if (detail == null) return null;

    final product = detail.product;
    final variant = detail.variants
        .where((v) => v.id == cart.variants[id])
        .firstOrNull;
    // The product's own photo comes from our file server. A variant's photo is
    // a supplier's link, which does not load everywhere, so it is only the
    // fallback — a blank tile in the cart is worse than a photo of the same
    // product in another colour.
    final image =
        product.mainImage ?? detail.gallery.firstOrNull ?? variant?.image;
    return ProductCardData(
      id: id,
      slug: product.slug,
      apiId: product.id,
      hasVariants: product.hasVariants,
      title: product.name,
      price: variant?.price ?? product.price,
      oldPrice: variant?.oldPrice ?? product.oldPrice,
      images: image == null ? const [] : [image],
      specs: [if (variant != null && variant.label.isNotEmpty) variant.label],
    );
  }

  @override
  Widget build(BuildContext context) {
    // The pill sits clear of the nav bar rather than a fixed distance off the
    // screen edge, so it lands right on a home-indicator phone and on one
    // without alike.
    final summaryBottom = context.navBarHeight + CartPage._gap;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cart) {
        _ensureLoaded(cart.quantities.keys);
        final lines = [for (final id in cart.quantities.keys) ?_line(id, cart)];
        final unresolved = cart.quantities.keys
            .where(
              (id) => _failed.contains(id) || ProductId.tryParse(id) == null,
            )
            .toList();
        // Still fetching: the cart is not empty, so do not say it is.
        final loading =
            lines.isEmpty &&
            unresolved.isEmpty &&
            cart.quantities.isNotEmpty &&
            _failed.length < cart.quantities.length;

        return Scaffold(
          // Stays put while the list scrolls under it, so the count and the
          // "Select All" tick are always in reach.
          appBar: _CartAppBar(
            count: cart.lineCount,
            allSelected: cart.allSelected,
          ),
          body: cart.quantities.isEmpty
              ? const CartEmptyView()
              : loading
              ? const Center(child: AppLoader())
              : Stack(
                  children: [
                    ListView.separated(
                      // The last line scrolls out from under the pill instead
                      // of stopping behind it.
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        summaryBottom + CartPage._summaryHeight + CartPage._gap,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: lines.length + unresolved.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.categoryDark
                            : context.adapt(
                                AppColors.grey100,
                                AppColors.categoryDark,
                              ),
                      ),
                      itemBuilder: (context, index) {
                        if (index < lines.length) {
                          return _Line(product: lines[index], cart: cart);
                        }
                        final key = unresolved[index - lines.length];
                        return SwipeToDelete(
                          onDelete: () => context.read<CartCubit>().remove(key),
                          child: ListTile(
                            title: Text(CartCubit.legacySlug(key) ?? '#$key'),
                            subtitle:
                                _migratingLegacy &&
                                    CartCubit.legacySlug(key) != null
                                ? null
                                : Text(context.l10n.errorServer),
                            trailing:
                                _migratingLegacy &&
                                    CartCubit.legacySlug(key) != null
                                ? const SizedBox.square(
                                    dimension: 24,
                                    child: AppLoader(),
                                  )
                                : TextButton(
                                    onPressed: _retry,
                                    child: Text(context.l10n.commonRetry),
                                  ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: AppSpacing.page,
                      right: AppSpacing.page,
                      bottom: summaryBottom,
                      child: _Summary(
                        cart: cart,
                        lines: lines,
                        summaryHeight: CartPage._summaryHeight,
                        gap: CartPage._gap,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

/// Product count on the left, "Select All" pinned to the right edge.
class _CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CartAppBar({required this.count, required this.allSelected});

  static const _height = 76.0;

  final int count;
  final bool allSelected;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      clipBehavior: Clip.none,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // The list slides under the bar without tinting it.
      scrolledUnderElevation: 0,
      toolbarHeight: _height,
      titleSpacing: AppSpacing.page,
      automaticallyImplyLeading: false,
      title: Text(
        // An empty cart has no count worth printing: just the heading.
        count == 0
            ? context.l10n.navCart
            : context.l10n.cartProductCount(count),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // Tracking is size-specific: at this size the default spacing reads
        // too loose, so it tightens as the type grows.
        style: context.textTheme.headlineLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      // An action rather than part of the title, so it ends up hard against
      // the right margin however long the count reads.
      actions: count == 0
          ? null
          : [
              _SelectAll(allSelected: allSelected),
              const SizedBox(width: AppSpacing.page),
            ],
    );
  }
}

/// The "Select All" label and its tick, as one control: tapping either ticks
/// every line, and tapping again clears them.
class _SelectAll extends StatelessWidget {
  const _SelectAll({required this.allSelected});

  final bool allSelected;

  @override
  Widget build(BuildContext context) {
    void toggle() => context.read<CartCubit>().toggleSelectAll();

    return GestureDetector(
      onTap: toggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.cartSelectAll,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.adapt(AppColors.grey700, AppColors.iconSoft),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          CartTickBox(value: allSelected, onTap: toggle),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.product, required this.cart});

  final ProductCardData product;
  final CartState cart;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    return BlocBuilder<FavoriteCubit, Set<String>>(
      buildWhen: (before, after) =>
          before.contains(product.favoriteKey) !=
          after.contains(product.favoriteKey),
      builder: (context, favorites) => SwipeToDelete(
        onDelete: () => cubit.remove(product.id),
        child: GestureDetector(
          onTap: product.apiId == null
              ? null
              : () => context.pushNamed(
                  AppRoutes.productDetail.name,
                  pathParameters: {'id': product.apiId.toString()},
                ),
          child: CartLineTile(
            product: product,
            quantity: cart.quantityOf(product.id),
            selected: cart.isSelected(product.id),
            isFavorite: favorites.contains(product.favoriteKey),
            onIncrease: () => cubit.increase(product.id),
            onDecrease: () => cubit.decrease(product.id),
            onSelectedChanged: () => cubit.toggleSelected(product.id),
            onFavoriteTap: () =>
                context.read<FavoriteCubit>().toggle(product.favoriteKey),
          ),
        ),
      ),
    );
  }
}

/// The totals pill. Nothing ticked is nothing to order, so then it slips down
/// behind the navigation bar, and it rises out from behind it again as soon
/// as something is ticked.
class _Summary extends StatefulWidget {
  const _Summary({
    required this.cart,
    required this.lines,
    required this.summaryHeight,
    required this.gap,
  });

  final CartState cart;
  final List<ProductCardData> lines;
  final double summaryHeight;
  final double gap;

  @override
  State<_Summary> createState() => _SummaryState();
}

class _SummaryState extends State<_Summary> {
  /// What the pill last showed with something ticked. It keeps showing this
  /// on its way down, rather than flashing "0 Product" as it leaves.
  ({int count, double total, double oldTotal}) _shown = (
    count: 0,
    total: 0,
    oldTotal: 0,
  );

  bool _placing = false;

  /// What pressing the pill does: places the order for what is ticked and
  /// opens it.
  ///
  /// A saved default address is used, or the customer chooses one before the
  /// order is sent. The ticked total goes along as the price they saw: if it
  /// has moved, the API refuses the order and checkout shows why.
  Future<void> _placeOrder(BuildContext context) async {
    if (_placing) return;
    setState(() => _placing = true);
    final cart = context.read<CartCubit>();
    final auth = context.read<AuthCubit>();
    final profile = context.read<ProfileCubit>().state;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (!auth.state.isAuthenticated) {
        if (!await promptSignIn(context) || !context.mounted) return;
      }

      final selected = [
        for (final line in widget.lines)
          if (widget.cart.isSelected(line.id) && line.apiId != null) line,
      ];
      if (selected.isEmpty) return;

      final orderLines = [
        for (final line in selected)
          PreOrderLine(
            productId: line.apiId!,
            quantity: widget.cart.quantityOf(line.id),
            variantId: widget.cart.variants[line.id],
          ),
      ];
      final expectedTotal = selected.fold<num>(
        0,
        (sum, line) => sum + line.price * widget.cart.quantityOf(line.id),
      );
      final name = profile.hasName ? profile.name : auth.state.user?.username;

      final location = await requestOrderLocation(context);
      if (!context.mounted || location == null) return;

      // The supplier is checked live only after an address has been chosen.
      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              const PopScope(canPop: false, child: Center(child: AppLoader())),
        ),
      );

      final result = await getIt<PreOrderRepository>().create(
        lines: orderLines,
        customerName: name,
        address: orderAddressText(location),
        expectedTotal: expectedTotal,
      );

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      final order = result.dataOrNull;
      if (order != null) {
        for (final line in selected) {
          cart.remove(line.id);
        }
        // The cart underneath, the order on top: back from the order lands on
        // the cart rather than leaving nothing to go back to.
        router.goNamed(AppRoutes.cart.name);
        unawaited(
          router.pushNamed(
            AppRoutes.orderDetail.name,
            pathParameters: {'id': order.id.toString()},
          ),
        );
        return;
      }
      final failure = result.failureOrNull;
      final check = failure?.details.asPreOrderCheck;
      // Only a price that moved is settled on the checkout page, where the
      // new total can be seen and accepted. Anything unavailable, or a
      // supplier that did not answer, is told here, on the cart.
      if (check != null && check.available) {
        messenger.showSnackBar(
          SnackBar(content: Text(failure?.localize(context.l10n) ?? '')),
        );
        unawaited(router.pushNamed(AppRoutes.checkout.name));
        return;
      }
      await showOrderProblemDialog(
        context,
        // From the error code, in the app's language: the API's own text
        // is Russian only.
        message: failure?.localize(context.l10n),
        check: check,
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var total = 0.0;
    var oldTotal = 0.0;
    var count = 0;

    for (final product in widget.lines) {
      if (!widget.cart.isSelected(product.id)) continue;
      final quantity = widget.cart.quantityOf(product.id);
      total += product.price * quantity;
      oldTotal += (product.oldPrice ?? product.price) * quantity;
      count++;
    }

    final visible = count > 0;
    if (visible) _shown = (count: count, total: total, oldTotal: oldTotal);

    // How far down it goes to be wholly out of sight: its own height, the gap
    // to the nav bar, and a little more so it sits inside the bar's capsule.
    final hiddenBy =
        (widget.summaryHeight + widget.gap + 3) / widget.summaryHeight;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 420),
        curve: visible ? Curves.easeOutCubic : Curves.easeInCubic,
        offset: Offset(0, visible ? 0 : hiddenBy),
        child: CartSummaryBar(
          productCount: _shown.count,
          total: _shown.total,
          oldTotal: _shown.oldTotal,
          onTap: visible ? () => _placeOrder(context) : null,
        ),
      ),
    );
  }
}
