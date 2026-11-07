import 'dart:async';

import 'package:elyeter/app/router/app_router.dart';
import 'package:elyeter/app/router/app_routes.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/error/failure.dart';
import 'package:elyeter/core/network/api_response.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/theme/app_typography.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/core/widgets/app_back_button.dart';
import 'package:elyeter/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elyeter/features/cart/presentation/cubit/cart_state.dart';
import 'package:elyeter/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:elyeter/features/home/presentation/widgets/home_search_field.dart';
import 'package:elyeter/features/product/domain/entities/product.dart';
import 'package:elyeter/features/product/domain/entities/product_detail.dart';
import 'package:elyeter/features/product/domain/entities/product_query.dart';
import 'package:elyeter/features/product/domain/repositories/product_repository.dart';
import 'package:elyeter/features/product/presentation/widgets/product_card.dart';
import 'package:elyeter/features/product/presentation/widgets/product_grid_shimmer.dart';
import 'package:elyeter/features/search/domain/entities/search_suggestion.dart';
import 'package:elyeter/features/search/domain/repositories/search_repository.dart';
import 'package:elyeter/features/search/presentation/view/search_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class _Cart extends MockCubit<CartState> implements CartCubit {}

class _SearchRepository implements SearchRepository {
  final queries = <String>[];
  final remembered = <String>[];
  List<String> recent = ['Recent query'];
  Result<SearchSuggestions> result = const Success(
    SearchSuggestions(
      products: [
        ProductSuggestion(
          id: 1234,
          slug: 'old-slug',
          name: 'Found product',
          price: 10,
        ),
      ],
    ),
  );
  @override
  Future<Result<SearchSuggestions>> suggest(
    String query, {
    int limit = 5,
  }) async {
    queries.add(query);
    return result;
  }

  @override
  List<String> recentSearches() => recent;
  @override
  Future<void> remember(String query) async {
    remembered.add(query);
    recent = [query, ...recent.where((term) => term != query)];
  }

  @override
  Future<void> clearRecent() async {}
}

class _Products implements ProductRepository {
  int requests = 0;
  final searches = <String?>[];
  Result<Paginated<Product>> result = const Error(NetworkFailure());
  Completer<Result<Paginated<Product>>>? pending;

  @override
  Future<Result<Paginated<Product>>> list({
    required ProductQuery query,
    int page = 1,
    int size = 20,
  }) async {
    requests++;
    searches.add(query.search);
    return pending == null ? result : await pending!.future;
  }

  @override
  Future<Result<ProductDetail>> byId(int id) async => Success(
    ProductDetail(
      product: result.dataOrNull!.items.firstWhere(
        (product) => product.id == id,
      ),
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(() async => getIt.reset());

  Future<_SearchRepository> pumpHome(
    WidgetTester tester, {
    bool reduceMotion = false,
    bool dark = false,
    double homeTop = 100,
    double topInset = 0,
    bool directSearch = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = FakeViewPadding(top: topInset);
    tester.view.viewPadding = FakeViewPadding(top: topInset);
    addTearDown(tester.view.reset);
    final repository = _SearchRepository();
    final cart = _Cart();
    when(() => cart.state).thenReturn(const CartState());
    final favorites = FavoriteCubit();
    addTearDown(cart.close);
    addTearDown(favorites.close);
    getIt.registerSingleton<SearchRepository>(repository);
    final searchRoute = AppRouter.router.configuration.routes
        .whereType<GoRoute>()
        .firstWhere((route) => route.name == AppRoutes.search.name);
    final router = GoRouter(
      initialLocation: directSearch ? AppRoutes.search.path : '/',
      routes: [
        GoRoute(
          path: '/',
          name: AppRoutes.home.name,
          builder: (_, _) => Scaffold(
            body: Padding(
              padding: EdgeInsets.fromLTRB(16, homeTop, 16, 0),
              child: const HomeSearchField(),
            ),
          ),
        ),
        GoRoute(
          path: searchRoute.path,
          name: searchRoute.name,
          pageBuilder: searchRoute.pageBuilder,
        ),
        GoRoute(
          path: '/product/:id',
          name: AppRoutes.productDetail.name,
          builder: (_, state) =>
              Scaffold(body: Text('Product ID ${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: dark ? AppTheme.dark : AppTheme.light,
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider<CartCubit>.value(value: cart),
            BlocProvider<FavoriteCubit>.value(value: favorites),
          ],
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: reduceMotion),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repository;
  }

  testWidgets('search fades in, focuses and closes', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byType(HomeSearchField));
    await tester.pump();
    await tester.pump();
    expect(find.byType(SearchPage), findsOneWidget);
    expect(find.byKey(const Key('search-reveal-clip')), findsNothing);
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(
      find.byKey(const Key('search-input')),
    );
    expect(field.focusNode!.hasFocus, isTrue);
    expect(field.style?.fontFamily, AppTypography.fontFamily);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing during entrance does not open a delayed keyboard', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.byType(HomeSearchField));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.testTextInput.isVisible, isFalse);
    // System back can interrupt the reveal before its toolbar is exposed.
    GoRouter.of(tester.element(find.byType(SearchPage))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(tester.takeException(), isNull);

    // Start a fresh tap, outside TextField's double-tap recognition window.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byType(HomeSearchField));
    await tester.pumpAndSettle();
    expect(tester.testTextInput.isVisible, isTrue);
  });

  for (final directSearch in [false, true]) {
    testWidgets(
      'search uses the app bar below the status bar (direct: $directSearch)',
      (tester) async {
        final topInset = directSearch ? 44.0 : 24.0;
        await pumpHome(
          tester,
          homeTop: 180,
          topInset: topInset,
          directSearch: directSearch,
        );
        if (!directSearch) {
          await tester.tap(find.byType(HomeSearchField));
          await tester.pumpAndSettle();
        }
        final field = find.byKey(const Key('search-input'));
        expect(tester.getTopLeft(field).dy, closeTo(topInset + 12, 1));
        expect(
          find.ancestor(of: field, matching: find.byType(AppBar)),
          findsOneWidget,
        );
        expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
        final pageScaffold = tester.widget<Scaffold>(
          find.descendant(
            of: find.byType(SearchPage),
            matching: find.byType(Scaffold),
          ),
        );
        expect(
          pageScaffold.backgroundColor,
          AppTheme.light.scaffoldBackgroundColor,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('typing searches products and opens a numeric product ID', (
    tester,
  ) async {
    final products = _Products()
      ..result = const Success(
        Paginated<Product>(
          items: [
            Product(
              id: 1234,
              slug: 'old-slug',
              sku: 'sku',
              name: 'Found product',
              price: 10,
            ),
            Product(
              id: 1235,
              slug: 'other-slug',
              sku: 'sku-2',
              name: 'Second product',
              price: 20,
            ),
          ],
          totalCount: 2,
          page: 1,
        ),
      );
    getIt.registerSingleton<ProductRepository>(products);
    await pumpHome(tester);
    await tester.tap(find.byType(HomeSearchField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), 'ring');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(products.searches, ['ring']);
    expect(find.byType(ProductCard), findsNWidgets(2));
    await tester.tap(find.text('Found product'));
    await tester.pumpAndSettle();
    expect(find.text('Product ID 1234'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recent history filters before a live product search', (
    tester,
  ) async {
    final products = _Products()
      ..result = const Success(
        Paginated<Product>(items: [], totalCount: 0, page: 1),
      );
    getIt.registerSingleton<ProductRepository>(products);
    final repository = await pumpHome(tester);
    repository.recent = ['IPHONE 17', 'iphone 16', 'Unrelated query'];
    await tester.tap(find.byType(HomeSearchField));
    await tester.pumpAndSettle();
    expect(find.text('IPHONE 17'), findsWidgets);
    expect(find.text('Unrelated query'), findsOneWidget);
    final field = find.byKey(const Key('search-input'));
    await tester.enterText(field, 'i');
    await tester.pump();
    expect(find.text('IPHONE 17'), findsWidgets);
    expect(find.text('Unrelated query'), findsNothing);
    await tester.enterText(field, 'ip');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(products.searches, ['ip']);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(repository.remembered, ['ip']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search pill keeps its height and alignment when cleared', (
    tester,
  ) async {
    await pumpHome(tester, homeTop: 32);
    await tester.tap(find.byType(HomeSearchField));
    await tester.pumpAndSettle();
    final field = find.byKey(const Key('search-input'));

    Rect paintedFieldRect() {
      final editable = find.descendant(
        of: field,
        matching: find.byType(EditableText),
      );
      final container = InputDecorator.containerOf(tester.element(editable))!;
      return container.localToGlobal(Offset.zero) & container.size;
    }

    final emptyRect = paintedFieldRect();
    expect(emptyRect.height, 48);
    expect(
      emptyRect.center.dy,
      closeTo(tester.getCenter(find.byTooltip('Close')).dy, 1),
    );
    await tester.enterText(field, 'ip');
    await tester.pumpAndSettle();
    expect(paintedFieldRect(), emptyRect);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(paintedFieldRect(), emptyRect);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search switches from camera to clear and remembers a query', (
    tester,
  ) async {
    final products = _Products()
      ..result = const Success(
        Paginated<Product>(items: [], totalCount: 0, page: 1),
      );
    getIt.registerSingleton<ProductRepository>(products);
    final repository = await pumpHome(tester);
    await tester.tap(find.byType(HomeSearchField));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Search by photo'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('search-input')), 'unknown');
    await tester.pump();
    expect(find.byTooltip('Clear search'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Not found'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Not found'), findsNothing);
    expect(find.text('unknown'), findsOneWidget);
    expect(repository.remembered, ['unknown']);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'search shows branded cards until an empty response arrives (dark: $dark)',
      (tester) async {
        final pending = Completer<Result<Paginated<Product>>>();
        getIt.registerSingleton<ProductRepository>(
          _Products()..pending = pending,
        );
        await pumpHome(tester, dark: dark, reduceMotion: dark);
        await tester.tap(find.byType(HomeSearchField));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('search-input')),
          'iphoneee',
        );
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        expect(find.byType(ProductGridShimmer), findsOneWidget);
        expect(find.text('elýeter'), findsWidgets);
        expect(find.text('Not found'), findsNothing);
        if (dark) {
          // Reduced motion can settle even while the HTTP response is pending.
          await tester.pumpAndSettle();
        } else {
          await tester.pump(const Duration(milliseconds: 600));
        }
        expect(find.byType(ProductGridShimmer), findsOneWidget);
        pending.complete(
          const Success(Paginated<Product>(items: [], totalCount: 0, page: 1)),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ProductGridShimmer), findsNothing);
        expect(find.text('elýeter'), findsNothing);
        expect(find.text('Not found'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('server failure shows the general error state', (tester) async {
    final products = _Products()..result = const Error(ServerFailure());
    getIt.registerSingleton<ProductRepository>(products);
    await pumpHome(tester);
    await tester.tap(find.byType(HomeSearchField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), 'ring');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Error'), findsOneWidget);
    expect(find.text('An error occurred. Please try again.'), findsOneWidget);
    expect(find.byType(AppBackButton), findsOneWidget);
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(SearchPage), findsNothing);
  });

  testWidgets('submitted search retries a product connection error', (
    tester,
  ) async {
    final products = _Products();
    getIt.registerSingleton<ProductRepository>(products);
    await pumpHome(tester);
    await tester.tap(find.byType(HomeSearchField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('search-input')), 'ring');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Connection Error'), findsOneWidget);
    products.result = const Success(
      Paginated<Product>(items: [], totalCount: 0, page: 1),
    );
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(products.requests, 2);
    expect(find.text('Not found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reduced motion fades without unfolding and fits above keyboard in dark mode',
    (tester) async {
      await pumpHome(tester, reduceMotion: true, dark: true);
      await tester.tap(find.byType(HomeSearchField));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('search-reveal-clip')), findsNothing);
      final start = tester.getTopLeft(find.byKey(const Key('search-panel'))).dy;
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(const Key('search-panel'))).dy,
        start,
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 340);
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(
        find.byKey(const Key('search-input')),
      );
      expect(field.style!.color, AppTheme.dark.textTheme.bodyLarge!.color);
      expect(
        tester.getBottomLeft(find.byKey(const Key('search-panel'))).dy,
        lessThanOrEqualTo(504),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsNothing);
    },
  );
}
