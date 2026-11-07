import 'package:dio/dio.dart';
import 'package:elyeter/app/router/app_routes.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/localization/fallback_localizations.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/api_response.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:elyeter/features/brand/domain/entities/brand.dart';
import 'package:elyeter/features/brand/domain/repositories/brand_repository.dart';
import 'package:elyeter/features/category/domain/entities/category.dart';
import 'package:elyeter/features/category/domain/repositories/category_repository.dart';
import 'package:elyeter/features/home/presentation/view/home_page.dart';
import 'package:elyeter/features/home/presentation/widgets/home_header.dart';
import 'package:elyeter/features/home/presentation/widgets/promo_carousel.dart';
import 'package:elyeter/features/marketplace/domain/entities/marketplace.dart';
import 'package:elyeter/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:elyeter/features/product/domain/entities/product.dart';
import 'package:elyeter/features/product/domain/entities/product_query.dart';
import 'package:elyeter/features/product/domain/repositories/product_repository.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _BannerClient extends ApiClient {
  _BannerClient() : super(Dio());

  int calls = 0;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    expect(path, '/banners');
    calls++;
    return [
      {
        'id': 3,
        'title': calls == 1 ? 'Arzanladyşlar' : 'Скидки',
        'image': '',
        'target_type': 'category',
        'target': 'elektronika',
      },
      {
        'id': 5,
        'title': null,
        'image': '',
        'target_type': 'product',
        'target': '1234',
      },
    ];
  }
}

class _CategoryRepository implements CategoryRepository {
  @override
  Future<Result<List<Category>>> tree({
    bool featuredOnly = false,
    bool forceRefresh = false,
  }) async => const Success([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BrandRepository implements BrandRepository {
  @override
  Future<Result<List<Brand>>> list({
    String? search,
    bool featuredOnly = false,
  }) async => const Success([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProductRepository implements ProductRepository {
  @override
  Future<Result<Paginated<Product>>> list({
    required ProductQuery query,
    int page = 1,
    int size = 20,
  }) async => Success(Paginated(items: const [], totalCount: 0, page: page));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MarketplaceRepository implements MarketplaceRepository {
  @override
  Future<Result<List<Marketplace>>> list() async => const Success([]);
}

class _IdleAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(() async => getIt.reset());

  testWidgets(
    'legacy null overlay flag renders safely and explicit false hides text',
    (tester) async {
      for (final enabled in <bool?>[null, true, false]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 360,
                height: 160,
                child: PromoBannerCard(
                  banner: PromoBanner(
                    id: 'legacy',
                    title: 'Banner heading',
                    showTextOverlay: enabled,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.text('Banner heading'),
          enabled == false ? findsNothing : findsOneWidget,
        );
      }
    },
  );

  testWidgets('home shows API banners in order and refreshes their language', (
    tester,
  ) async {
    final client = _BannerClient();
    final auth = AuthCubit(_IdleAuthRepository());
    final locale = ValueNotifier(const Locale('tk'));
    getIt
      ..registerSingleton<ShopApi>(ShopApi(client))
      ..registerSingleton<AuthCubit>(auth)
      ..registerSingleton<CategoryRepository>(_CategoryRepository())
      ..registerSingleton<BrandRepository>(_BrandRepository())
      ..registerSingleton<MarketplaceRepository>(_MarketplaceRepository())
      ..registerSingleton<ProductRepository>(_ProductRepository());
    addTearDown(auth.close);
    addTearDown(locale.dispose);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: AppRoutes.home.name,
          builder: (_, _) => const HomePage(),
          routes: [
            GoRoute(
              path: AppRoutes.categoryDetail.path,
              name: AppRoutes.categoryDetail.name,
              builder: (_, state) =>
                  Scaffold(body: Text('Opened ${state.pathParameters['id']}')),
            ),
            GoRoute(
              path: AppRoutes.productDetail.path,
              name: AppRoutes.productDetail.name,
              builder: (_, state) =>
                  Scaffold(body: Text('Product ${state.pathParameters['id']}')),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (_, language, _) => MaterialApp.router(
          locale: language,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            ...FallbackLocalizations.delegates,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final carousel = tester.widget<PromoCarousel>(find.byType(PromoCarousel));
    expect(carousel.banners.map((banner) => banner.id), ['3', '5']);
    expect(carousel.banners.last.title, isNull);
    expect(carousel.banners.first.title, 'Arzanladyşlar');
    expect(carousel.banners.first.hasOverlay, isFalse);
    expect(
      tester.getSize(find.byType(PromoCarousel)).height,
      closeTo(
        PromoCarousel.heightForWidth(
          tester.getSize(find.byType(CustomScrollView)).width,
        ),
        0.1,
      ),
    );
    expect(
      tester.getBottomLeft(find.byType(HomeHeader)).dy -
          tester.getTopLeft(find.byType(PromoBannerCard).first).dy,
      closeTo(14, 0.1),
    );
    final dots = find.descendant(
      of: find.byType(PromoCarousel),
      matching: find.byType(AnimatedContainer),
    );
    expect(dots, findsNWidgets(2));
    expect(tester.getSize(dots.first), const Size(9, 7));
    expect(tester.getSize(dots.last), const Size(7, 5));
    expect(
      tester.getBottomLeft(find.byType(PromoBannerCard).first).dy -
          tester.getBottomLeft(dots.first).dy,
      closeTo(8, 0.1),
    );
    for (final dot in tester.widgetList<AnimatedContainer>(dots)) {
      final decoration = dot.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.boxShadow, isNull);
      expect(decoration.border, isNull);
    }

    locale.value = const Locale('ru');
    await tester.pumpAndSettle();
    expect(client.calls, 2);
    expect(
      tester
          .widget<PromoCarousel>(find.byType(PromoCarousel))
          .banners
          .first
          .title,
      'Скидки',
    );

    await tester.tap(find.byType(PromoBannerCard).first);
    await tester.pumpAndSettle();
    expect(find.text('Opened elektronika'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();
    expect(tester.getSize(dots.first), const Size(7, 5));
    expect(tester.getSize(dots.last), const Size(9, 7));
    await tester.tap(find.byType(PromoBannerCard).last);
    await tester.pumpAndSettle();
    expect(find.text('Product 1234'), findsOneWidget);
  });
}
