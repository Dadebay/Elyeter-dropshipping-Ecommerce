import 'dart:async';

import 'package:dio/dio.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/api_response.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:elyeter/features/brand/domain/entities/brand.dart';
import 'package:elyeter/features/brand/domain/repositories/brand_repository.dart';
import 'package:elyeter/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elyeter/features/category/domain/entities/category.dart';
import 'package:elyeter/features/category/domain/repositories/category_repository.dart';
import 'package:elyeter/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:elyeter/features/home/presentation/view/home_page.dart';
import 'package:elyeter/features/home/presentation/widgets/home_search_field.dart';
import 'package:elyeter/features/home/presentation/widgets/home_section_shimmer.dart';
import 'package:elyeter/features/marketplace/domain/entities/marketplace.dart';
import 'package:elyeter/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:elyeter/core/widgets/parcel_refresh_motion.dart';
import 'package:elyeter/features/product/domain/entities/product.dart';
import 'package:elyeter/features/product/domain/entities/product_detail.dart';
import 'package:elyeter/features/product/domain/entities/product_query.dart';
import 'package:elyeter/features/product/domain/repositories/product_repository.dart';
import 'package:elyeter/features/product/presentation/widgets/product_grid_shimmer.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _MemoryStorage implements Storage {
  final values = <String, dynamic>{};
  @override
  dynamic read(String key) => values[key];
  @override
  Future<void> write(String key, dynamic value) async => values[key] = value;
  @override
  Future<void> delete(String key) async => values.remove(key);
  @override
  Future<void> clear() async => values.clear();
  @override
  Future<void> close() async {}
}

class _EmptyApiClient extends ApiClient {
  _EmptyApiClient() : super(Dio());

  int bannerCalls = 0;
  Completer<void>? refreshBannerReady;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    if (path == '/banners') {
      bannerCalls++;
      if (bannerCalls > 1) await refreshBannerReady?.future;
    }
    return const [];
  }
}

class _Categories implements CategoryRepository {
  final featuredRequests = <bool>[];
  final forceRefreshRequests = <bool>[];

  @override
  Future<Result<List<Category>>> tree({
    bool featuredOnly = false,
    bool forceRefresh = false,
  }) async {
    featuredRequests.add(featuredOnly);
    forceRefreshRequests.add(forceRefresh);
    return const Success([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Brands implements BrandRepository {
  final featuredRequests = <bool>[];

  @override
  Future<Result<List<Brand>>> list({
    String? search,
    bool featuredOnly = false,
  }) async {
    featuredRequests.add(featuredOnly);
    return const Success([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MarketplaceRepository implements MarketplaceRepository {
  @override
  Future<Result<List<Marketplace>>> list() async => const Success([]);
}

class _FeaturedProducts implements ProductRepository {
  final requests = <(ProductQuery, int, int)>[];
  final firstPageReady = Completer<void>();
  final secondPageReady = Completer<void>();
  Completer<void>? refreshReady;
  final items = [
    for (var id = 1; id <= 45; id++)
      Product(
        id: id,
        slug: 'product-$id',
        sku: 'P$id',
        name: 'Product $id',
        price: id,
      ),
  ];

  @override
  Future<Result<Paginated<Product>>> list({
    required ProductQuery query,
    int page = 1,
    int size = 20,
  }) async {
    requests.add((query, page, size));
    if (page == 1) {
      await firstPageReady.future;
      await refreshReady?.future;
    }
    if (page == 2) await secondPageReady.future;
    return Success(
      Paginated(
        items: items.skip((page - 1) * size).take(size).toList(),
        totalCount: items.length,
        page: page,
      ),
    );
  }

  @override
  Future<Result<ProductDetail>> byId(int id) async => Success(
    ProductDetail(product: items.firstWhere((item) => item.id == id)),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpHome(
  WidgetTester tester,
  _FeaturedProducts products, {
  TargetPlatform platform = TargetPlatform.android,
  _EmptyApiClient? api,
  _Categories? categories,
  _Brands? brands,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = AuthCubit(_AuthRepository());
  addTearDown(auth.close);
  getIt
    ..registerSingleton<AuthCubit>(auth)
    ..registerSingleton<ShopApi>(ShopApi(api ?? _EmptyApiClient()))
    ..registerSingleton<CategoryRepository>(categories ?? _Categories())
    ..registerSingleton<BrandRepository>(brands ?? _Brands())
    ..registerSingleton<MarketplaceRepository>(_MarketplaceRepository())
    ..registerSingleton<ProductRepository>(products);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FavoriteCubit()),
        BlocProvider(create: (_) => CartCubit()),
      ],
      child: MaterialApp(
        theme: AppTheme.light.copyWith(platform: platform),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());
  tearDown(() async => getIt.reset());

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('home stays fixed during pull to refresh on $platform', (
      tester,
    ) async {
      final products = _FeaturedProducts()..firstPageReady.complete();
      await _pumpHome(tester, products, platform: platform);
      final before = tester.getTopLeft(find.byType(HomeSearchField));
      final refresh = Completer<void>();
      products.refreshReady = refresh;
      addTearDown(() {
        if (!refresh.isCompleted) refresh.complete();
      });

      final gesture = await tester.startGesture(const Offset(195, 250));
      await gesture.moveBy(const Offset(0, 400));
      await tester.pump();
      expect(tester.getTopLeft(find.byType(HomeSearchField)), before);
      expect(find.byType(ParcelRefreshMotion), findsOneWidget);
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(products.requests.map((request) => request.$2), [1, 1]);
      expect(tester.getTopLeft(find.byType(HomeSearchField)), before);

      refresh.complete();
      await tester.pumpAndSettle();
      expect(find.byType(ParcelRefreshMotion), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('refresh requests every home section and shows shimmer', (
    tester,
  ) async {
    final products = _FeaturedProducts()..firstPageReady.complete();
    final categories = _Categories();
    final brands = _Brands();
    final api = _EmptyApiClient();
    await _pumpHome(
      tester,
      products,
      api: api,
      categories: categories,
      brands: brands,
    );
    expect(api.bannerCalls, 1);

    final productRefresh = Completer<void>();
    final bannerRefresh = Completer<void>();
    products.refreshReady = productRefresh;
    api.refreshBannerReady = bannerRefresh;
    addTearDown(() {
      if (!productRefresh.isCompleted) productRefresh.complete();
      if (!bannerRefresh.isCompleted) bannerRefresh.complete();
    });

    unawaited(
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show(),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(categories.featuredRequests, [true, true]);
    expect(categories.forceRefreshRequests, [false, true]);
    expect(brands.featuredRequests, [true, true]);
    expect(products.requests.map((request) => request.$2), [1, 1]);
    expect(api.bannerCalls, 2);
    expect(find.byType(CategoryStripShimmer), findsOneWidget);
    expect(find.byType(BrandStripShimmer), findsOneWidget);
    expect(find.byType(BannerShimmer), findsOneWidget);
    expect(find.byType(ProductGridShimmer), findsOneWidget);

    productRefresh.complete();
    bannerRefresh.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CategoryStripShimmer), findsNothing);
    expect(find.byType(BrandStripShimmer), findsNothing);
    expect(find.byType(BannerShimmer), findsNothing);
    expect(find.byType(ProductGridShimmer), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'home loads pages two and three after skipping the prefetch card',
    (tester) async {
      final products = _FeaturedProducts()..firstPageReady.complete();
      await _pumpHome(tester, products);
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;

      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(products.requests.map((request) => request.$2), [1, 2]);
      expect(find.byType(ProductGridShimmer), findsOneWidget);

      products.secondPageReady.complete();
      await tester.pumpAndSettle();
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(products.requests.map((request) => request.$2), [1, 2, 3]);

      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(products.requests.map((request) => request.$2), [1, 2, 3]);
      expect(find.text('Product 45'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('home prefetches the next featured page near item ten', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final products = _FeaturedProducts();
    final categories = _Categories();
    final brands = _Brands();
    final auth = AuthCubit(_AuthRepository());
    addTearDown(auth.close);
    getIt
      ..registerSingleton<AuthCubit>(auth)
      ..registerSingleton<ShopApi>(ShopApi(_EmptyApiClient()))
      ..registerSingleton<CategoryRepository>(categories)
      ..registerSingleton<BrandRepository>(brands)
      ..registerSingleton<MarketplaceRepository>(_MarketplaceRepository())
      ..registerSingleton<ProductRepository>(products);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => FavoriteCubit()),
          BlocProvider(create: (_) => CartCubit()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomePage(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(ProductGridShimmer), findsOneWidget);
    expect(tester.takeException(), isNull);
    products.firstPageReady.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ProductGridShimmer), findsNothing);
    expect(categories.featuredRequests, [true]);
    expect(brands.featuredRequests, [true]);
    expect(products.requests.map((request) => request.$2), [1]);

    final scrollable = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Product 4'),
      250,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(products.requests.map((request) => request.$2), [1]);

    await tester.scrollUntilVisible(
      find.text('Product 10'),
      250,
      scrollable: scrollable,
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(products.requests.map((request) => request.$2), [1, 2]);
    await tester.scrollUntilVisible(
      find.byType(ProductGridShimmer),
      300,
      scrollable: scrollable,
    );
    final offsetBeforeAppend = tester
        .state<ScrollableState>(scrollable)
        .position
        .pixels;
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(ProductGridShimmer), findsOneWidget);
    products.secondPageReady.complete();
    await tester.pumpAndSettle();
    expect(find.byType(ProductGridShimmer), findsNothing);
    expect(products.requests.map((request) => request.$2), [1, 2]);
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      offsetBeforeAppend,
    );

    await tester.scrollUntilVisible(
      find.text('Product 30'),
      250,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(products.requests.map((request) => request.$2), [1, 2, 3]);
    expect(
      products.requests.every((request) => request.$1.onlyFeatured),
      isTrue,
    );
    expect(products.requests.every((request) => request.$3 == 20), isTrue);
    expect(tester.takeException(), isNull);
  });
}
