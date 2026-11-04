import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/interceptors/language_interceptor.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../brand/domain/repositories/brand_repository.dart';
import '../../../marketplace/domain/entities/marketplace.dart';
import '../../../marketplace/domain/repositories/marketplace_repository.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../favorite/presentation/cubit/favorite_cubit.dart';
import '../../../product/domain/entities/product_query.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/entities/product_id.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product/presentation/widgets/product_card_actions.dart';
import '../../../product/presentation/widgets/product_grid_shimmer.dart';
import '../widgets/brand_strip.dart';
import '../widgets/category_strip.dart';
import '../widgets/home_header.dart';
import '../widgets/home_section_shimmer.dart';
import '../widgets/marketplace_strip.dart';
import '../widgets/promo_carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryItem> _categories = [];
  List<BrandItem> _brands = [];
  List<Marketplace> _marketplaces = [];
  // The store whose products the page shows; null until one is picked.
  int? _marketplaceId;
  List<ProductCardData> _products = [];
  Paginated<Product>? _productPage;
  List<PromoBanner> _banners = [];
  SavedLocation? _location;
  bool _loading = true;
  bool _loadingBanners = false;
  bool _loadingMore = false;
  bool _loadMoreFailed = false;
  bool _prefetchScheduled = false;
  final _scrollController = ScrollController();
  final Map<int, GlobalKey> _prefetchKeys = {};
  int _productRequest = 0;
  // Falls back to every product when none are flagged as featured.
  bool _onlyFeatured = true;
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;
  String? _bannerLanguage;
  int _bannerRequest = 0;

  @override
  void initState() {
    super.initState();
    _authSubscription = getIt<AuthCubit>().stream.listen((state) {
      if (state.isAuthenticated) {
        _loadLocation();
      } else if (mounted) {
        setState(() => _location = null);
      }
    });
    _load();
    unawaited(_loadMarketplaces());
  }

  /// Switches the store: the page reloads with that marketplace's products.
  /// Tapping the chosen one again goes back to everything.
  void _selectMarketplace(MarketplaceItem item) {
    final id = int.tryParse(item.id);
    final next = id == _marketplaceId ? null : id;
    if (next == _marketplaceId) return;
    setState(() {
      _marketplaceId = next;
      _products = [];
      _productPage = null;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    unawaited(_load());
  }

  Future<void> _loadMarketplaces() async {
    final result = await getIt<MarketplaceRepository>().list();
    if (!mounted || result.dataOrNull == null) return;
    setState(() => _marketplaces = result.dataOrNull!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = LanguageInterceptor.resolve(
      Localizations.localeOf(context).languageCode,
    );
    if (language != _bannerLanguage) {
      _bannerLanguage = language;
      _banners = [];
      _loadingBanners = true;
      unawaited(_loadBanners());
    }
  }

  @override
  void dispose() {
    _bannerRequest++;
    _productRequest++;
    _authSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    final request = ++_bannerRequest;
    try {
      final banners = await getIt<ShopApi>().banners();
      if (!mounted || request != _bannerRequest) return;
      setState(() {
        _loadingBanners = false;
        _banners = [
          for (final banner in banners)
            PromoBanner(
              id: banner.id.toString(),
              title: banner.title,
              imageUrl: banner.image,
              targetType: banner.targetType,
              target: banner.target,
              showTextOverlay: false,
            ),
        ];
      });
    } on Object {
      if (mounted && request == _bannerRequest) {
        setState(() {
          _loadingBanners = false;
          _banners = [];
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() => _loadingBanners = true);
    await Future.wait<void>([_load(forceRefresh: true), _loadBanners()]);
  }

  void _openBanner(PromoBanner banner) {
    final target = banner.target;
    if (target == null || target.isEmpty) return;
    switch (banner.targetType) {
      case 'category':
        unawaited(
          context.pushNamed(
            AppRoutes.categoryDetail.name,
            pathParameters: {'id': target},
            extra: banner.title,
          ),
        );
      case 'product':
        final productId = ProductId.tryParse(target);
        if (productId == null) return;
        unawaited(
          context.pushNamed(
            AppRoutes.productDetail.name,
            pathParameters: {'id': productId.toString()},
          ),
        );
    }
  }

  Future<void> _loadLocation() async {
    if (!HomeHeader.showLocation) return;
    if (!getIt<AuthCubit>().state.isAuthenticated) return;
    try {
      final locations = await getIt<ShopApi>().locations();
      if (mounted &&
          getIt<AuthCubit>().state.isAuthenticated &&
          locations.isNotEmpty) {
        setState(() => _location = locations.first);
      }
    } on Object {
      /* Location is optional on the home screen. */
    }
  }

  Future<void> _load({bool forceRefresh = false}) async {
    final request = ++_productRequest;
    setState(() {
      _loading = true;
      _loadingMore = false;
      _loadMoreFailed = false;
      _error = null;
    });
    final categoryRequest = getIt<CategoryRepository>().tree(
      featuredOnly: true,
      forceRefresh: forceRefresh,
    );
    final brandRequest = getIt<BrandRepository>().list(featuredOnly: true);
    final productRequest = getIt<ProductRepository>().list(
      query: ProductQuery(onlyFeatured: true, marketplaceId: _marketplaceId),
      page: 1,
      size: AppConstants.pageSize,
    );
    final categoryResult = await categoryRequest;
    final brandResult = await brandRequest;
    var productResult = await productRequest;
    var onlyFeatured = true;
    if (productResult.dataOrNull case final page? when page.items.isEmpty) {
      final all = await getIt<ProductRepository>().list(
        query: ProductQuery(marketplaceId: _marketplaceId),
        page: 1,
        size: AppConstants.pageSize,
      );
      if (all.dataOrNull != null) {
        productResult = all;
        onlyFeatured = false;
      }
    }
    _onlyFeatured = onlyFeatured;
    if (!mounted || request != _productRequest) return;
    setState(() {
      _categories = [
        for (final item in categoryResult.dataOrNull ?? [])
          CategoryItem(
            id: item.slug,
            name: item.name,
            imageUrl: item.imageSmall ?? item.imageLarge,
          ),
      ];
      _brands = [
        for (final item in brandResult.dataOrNull ?? [])
          BrandItem(
            id: item.id.toString(),
            name: item.name,
            logoUrl: item.logo,
          ),
      ];
      _productPage = productResult.dataOrNull;
      _products = [
        for (final item in productResult.dataOrNull?.items ?? [])
          ProductCardData.fromProduct(item),
      ];
      _error =
          productResult.failureOrNull?.message ??
          categoryResult.failureOrNull?.message ??
          brandResult.failureOrNull?.message;
      _loading = false;
    });
    await _loadLocation();
  }

  int get _prefetchIndex => (_products.length - AppConstants.pageSize ~/ 2 - 1)
      .clamp(0, _products.length - 1);

  void _schedulePrefetchCheck() {
    if (_prefetchScheduled ||
        _loading ||
        _products.isEmpty ||
        _loadingMore ||
        _loadMoreFailed ||
        !(_productPage?.hasMore(AppConstants.pageSize) ?? false)) {
      return;
    }
    _prefetchScheduled = true;
    final request = _productRequest;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchScheduled = false;
      if (!mounted || request != _productRequest) return;
      // A fast scroll can skip the prefetch card or dispose it. The remaining
      // scroll extent still detects the end of the currently loaded products.
      if (_scrollController.hasClients) {
        final position = _scrollController.position;
        if (position.extentAfter <= position.viewportDimension) {
          unawaited(_loadMore());
          return;
        }
      }
      final renderObject = _prefetchKeys[_prefetchIndex]?.currentContext
          ?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.attached) return;
      final top = renderObject.localToGlobal(Offset.zero).dy;
      final bottom = top + renderObject.size.height;
      final viewportBottom = MediaQuery.sizeOf(context).height - 100;
      if (top < viewportBottom && bottom > 0) unawaited(_loadMore());
    });
  }

  Future<void> _loadMore({bool retry = false}) async {
    final previous = _productPage;
    if (previous == null ||
        !previous.hasMore(AppConstants.pageSize) ||
        _loading ||
        _loadingMore ||
        (_loadMoreFailed && !retry)) {
      return;
    }
    final request = _productRequest;
    setState(() {
      _loadingMore = true;
      _loadMoreFailed = false;
    });
    final result = await getIt<ProductRepository>().list(
      query: ProductQuery(
        onlyFeatured: _onlyFeatured,
        marketplaceId: _marketplaceId,
      ),
      page: previous.page + 1,
      size: AppConstants.pageSize,
    );
    if (!mounted || request != _productRequest) return;
    setState(() {
      _loadingMore = false;
      if (result.dataOrNull case final next?) {
        _productPage = previous.merge(next);
        _products = [
          ..._products,
          for (final item in next.items) ProductCardData.fromProduct(item),
        ];
      } else {
        _loadMoreFailed = true;
      }
    });
    _schedulePrefetchCheck();
  }

  Future<void> _pickLocation() async {
    if (!context.read<AuthCubit>().state.isAuthenticated) {
      await promptSignIn(context);
      return;
    }
    final List<SavedLocation> locations;
    try {
      locations = await getIt<ShopApi>().locations();
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
      return;
    }
    if (!mounted) return;
    if (locations.isEmpty) {
      unawaited(context.pushNamed(AppRoutes.addresses.name));
      return;
    }
    final picked = await showModalBottomSheet<SavedLocation>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final location in locations)
              ListTile(
                title: Text(location.name),
                subtitle: Text(location.address ?? ''),
                onTap: () => Navigator.pop(context, location),
              ),
            ListTile(
              title: Text(context.l10n.profileSavedLocations),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(AppRoutes.addresses.name);
              },
            ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _location = picked);
  }

  Widget _buildHeaderAndBanners(BuildContext context) {
    final header = HomeHeader(
      marketplaces: [
        for (final m in _marketplaces) MarketplaceItem.fromMarketplace(m),
      ],
      // Hidden only when the API lists marketplaces and none can search.
      showCamera:
          _marketplaces.isEmpty || _marketplaces.any((m) => m.imageSearch),
      categories: _categories,
      categoriesLoading: _loading,
      city: _location?.name ?? 'Ashgabat',
      address: _location?.address ?? '',
      onCategoryTap: (item) => context.pushNamed(
        AppRoutes.categoryDetail.name,
        pathParameters: {'id': item.id},
        extra: item.name,
      ),
      onLocationTap: _pickLocation,
      selectedMarketplaceId: _marketplaceId?.toString(),
      onMarketplaceTap: _selectMarketplace,
    );
    if (_banners.isEmpty && !_loadingBanners) return header;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerHeight = PromoCarousel.heightForWidth(constraints.maxWidth);
        const overlap = AppSpacing.md + AppSpacing.xxs;
        return Stack(
          children: [
            Column(
              children: [
                header,
                SizedBox(height: bannerHeight - overlap + AppSpacing.xs),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: AppSpacing.xs,
              // The white sheet's curved lip cuts the cards peeking at the
              // sides, as in the design.
              child: ClipPath(
                clipper: const _SheetClipper(lipAbove: 0),
                child: _loadingBanners
                    ? BannerShimmer(height: bannerHeight)
                    : PromoCarousel(
                        key: ValueKey(
                          _banners.map((banner) => banner.id).join(','),
                        ),
                        banners: _banners,
                        height: bannerHeight,
                        onTap: _openBanner,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppRefreshIndicator(
      onRefresh: _refresh,
      indicatorTop: MediaQuery.viewPaddingOf(context).top + AppSpacing.md,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              notification.metrics.axis == Axis.vertical) {
            _schedulePrefetchCheck();
          }
          return false;
        },
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            scrollCacheExtent: ScrollCacheExtent.pixels(400),
            slivers: [
              SliverToBoxAdapter(
                child: RepaintBoundary(child: _buildHeaderAndBanners(context)),
              ),
              if (_loading || _brands.isNotEmpty)
                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: _loading
                        ? const BrandStripShimmer()
                        : BrandStrip(
                            items: _brands,
                            onTap: (item) => context.pushNamed(
                              AppRoutes.brand.name,
                              pathParameters: {'id': item.id},
                              extra: item.name,
                            ),
                          ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
              if (_loading)
                const SliverToBoxAdapter(
                  child: ProductGridShimmer(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  ),
                )
              else if (_error != null && _products.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: TextButton(onPressed: _load, child: Text(_error!)),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 0.57,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == _prefetchIndex) _schedulePrefetchCheck();
                      final product = _products[index];
                      final card = BlocBuilder<FavoriteCubit, Set<String>>(
                        builder: (context, favorites) =>
                            BlocBuilder<CartCubit, CartState>(
                              builder: (context, cart) => ProductCard(
                                data: product,
                                isFavorite: favorites.contains(
                                  product.favoriteKey,
                                ),
                                isInCart: cart.contains(product.id),
                                onTap: () => context.pushNamed(
                                  AppRoutes.productDetail.name,
                                  pathParameters: {'id': product.id},
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
                                      product.favoriteKey,
                                    );
                                  }
                                },
                                onAddToCart: () =>
                                    toggleCartFromCard(context, product),
                              ),
                            ),
                      );
                      if (index != _prefetchIndex) return card;
                      return KeyedSubtree(
                        key: _prefetchKeys.putIfAbsent(index, GlobalKey.new),
                        child: card,
                      );
                    }, childCount: _products.length),
                  ),
                ),
              if (_loadingMore || _loadMoreFailed)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xl),
                    child: Center(
                      child: _loadingMore
                          ? const ProductGridShimmer.more()
                          : TextButton(
                              onPressed: () => _loadMore(retry: true),
                              child: Text(context.l10n.commonRetry),
                            ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Clips to the same top-rounded shape as the header's white sheet.
/// [lipAbove] is how far the sheet's top edge sits above the clipped box.
class _SheetClipper extends CustomClipper<Path> {
  const _SheetClipper({required this.lipAbove});

  final double lipAbove;

  @override
  Path getClip(Size size) => Path()
    ..addRRect(
      RRect.fromLTRBAndCorners(
        0,
        -lipAbove,
        size.width,
        size.height,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      ),
    );

  @override
  bool shouldReclip(_SheetClipper oldClipper) =>
      oldClipper.lipAbove != lipAbove;
}
