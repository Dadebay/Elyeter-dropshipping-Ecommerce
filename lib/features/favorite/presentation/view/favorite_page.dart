import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/catalog_empty_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product/presentation/widgets/product_card_actions.dart';
import '../../../product/presentation/widgets/product_grid_shimmer.dart';
import '../cubit/favorite_cubit.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Paginated<Product>? _page;
  Object? _error;
  bool _loading = false;

  /// A heart was tapped elsewhere while a load was in flight; fetch again
  /// once it lands, or the list would miss it.
  bool _reloadQueued = false;
  StreamSubscription<void>? _favoriteSync;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    // The shell keeps this tab alive, so a heart tapped on another tab has to
    // refresh the list on its own, without a pull to refresh.
    _favoriteSync = context.read<FavoriteCubit>().synced.listen(
      (_) => unawaited(_load()),
    );
  }

  @override
  void dispose() {
    _favoriteSync?.cancel();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    if (!mounted || !context.read<AuthCubit>().state.isAuthenticated) return;
    if (_loading) {
      if (!more) _reloadQueued = true;
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final next = await getIt<ShopApi>().favorites(
        page: more ? (_page?.page ?? 0) + 1 : 1,
      );
      if (mounted) {
        setState(
          () => _page = more && _page != null ? _page!.merge(next) : next,
        );
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
      if (mounted && _reloadQueued) {
        _reloadQueued = false;
        unawaited(_load());
      }
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthCubit, AuthState>(
    listener: (context, auth) {
      setState(() => _page = null);
      if (auth.isAuthenticated) _load();
    },
    child: Scaffold(
      appBar: AppBar(
        clipBehavior: Clip.none,
        titleSpacing: AppSpacing.page,
        toolbarHeight: 76,
        title: Text(
          context.l10n.navFavorite,
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          final l10n = context.l10n;
          Widget emptyState() => CatalogEmptyView(
            illustration: AppAssets.favoriteEmptyIllustration,
            title: l10n.favoriteEmptyTitle,
            message: l10n.favoriteEmptyMessage,
            actionLabel: l10n.favoriteEmptyAction,
            onAction: () => context.goNamed(AppRoutes.home.name),
          );

          if (!context.watch<AuthCubit>().state.isAuthenticated) {
            return emptyState();
          }
          if (_page == null && _loading) {
            return const ProductGridShimmer();
          }
          if (_page == null && _error != null) {
            return Center(
              child: TextButton(
                onPressed: _load,
                child: Text('Retry: $_error'),
              ),
            );
          }
          final items = _page?.items ?? const <Product>[];
          if (items.isEmpty) {
            return AppRefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: emptyState(),
                  ),
                ],
              ),
            );
          }
          return AppRefreshIndicator(
            onRefresh: _load,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.lg,
                AppSpacing.page,
                120,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.57,
              ),
              itemCount: items.length + ((_page?.hasMore(20) ?? false) ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  return Center(
                    child: TextButton(
                      onPressed: _loading ? null : () => _load(more: true),
                      child: Text(_loading ? '…' : 'More'),
                    ),
                  );
                }
                final data = ProductCardData.fromProduct(items[index]);
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
                          // The list reloads itself once the server confirms.
                          onFavoriteTap: () => context
                              .read<FavoriteCubit>()
                              .toggle(data.favoriteKey),
                          onAddToCart: () => toggleCartFromCard(context, data),
                        ),
                      ),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}
