import 'package:dio/dio.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/error/exceptions.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/auth/domain/entities/app_user.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:elyeter/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elyeter/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:elyeter/features/product/data/datasources/product_remote_data_source.dart';
import 'package:elyeter/features/product/data/repositories/product_repository_impl.dart';
import 'package:elyeter/features/product/domain/entities/product_reviews.dart';
import 'package:elyeter/features/product/domain/repositories/product_repository.dart';
import 'package:elyeter/features/product/presentation/view/product_reviews_page.dart';
import 'package:elyeter/features/product/presentation/view/product_detail_page.dart';
import 'package:elyeter/features/product/presentation/widgets/product_reviews_section.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class _MemoryStorage implements Storage {
  @override
  dynamic read(String key) => null;
  @override
  Future<void> write(String key, dynamic value) async {}
  @override
  Future<void> delete(String key) async {}
  @override
  Future<void> clear() async {}
  @override
  Future<void> close() async {}
}

class _AuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ReviewClient extends ApiClient {
  _ReviewClient() : super(Dio());

  final calls = <String>[];
  Object? posted;
  bool empty = false;
  bool failSave = false;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    calls.add(
      'GET $path ${queryParameters?['page']} ${queryParameters?['size']}',
    );
    if (path == '/products/42') {
      return {'id': 42, 'name': 'Test product', 'price': 120, 'sku': 'EL-42'};
    }
    if (empty) {
      return {
        'items': [],
        'summary': {'count': 0},
      };
    }
    return {
      'totalCount': 1,
      'page': 1,
      'summary': {
        'average': 4.6,
        'count': 5,
        'distribution': {'5': 4, '4': 1, '3': 0, '2': 0, '1': 0},
      },
      'my_review': {
        'id': 9,
        'rating': 5,
        'comment': 'Great',
        'user': {'username': 'Me'},
      },
      'items': [
        {
          'id': 9,
          'rating': 5,
          'comment': 'Great',
          'user': {'username': 'Me'},
          'created_at': '2026-10-19T12:00:00Z',
          'is_mine': true,
        },
      ],
    };
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) async {
    calls.add('POST $path');
    posted = data;
    if (failSave) throw const NetworkException();
    empty = false;
    return {};
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    CancelToken? cancelToken,
  }) async {
    calls.add('DELETE $path');
    return {};
  }
}

Future<void> _mountDetail(
  WidgetTester tester,
  _ReviewClient client, {
  bool signedIn = true,
}) async {
  HydratedBloc.storage = _MemoryStorage();
  getIt.registerSingleton<ProductRepository>(
    ProductRepositoryImpl(ProductRemoteDataSourceImpl(client)),
  );
  final auth = AuthCubit(_AuthRepository());
  if (signedIn) auth.onSignedIn(const AppUser(id: 1, phone: '+99365000000'));
  final cart = CartCubit();
  final favorites = FavoriteCubit();
  addTearDown(auth.close);
  addTearDown(cart.close);
  addTearDown(favorites.close);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: auth),
        BlocProvider<CartCubit>.value(value: cart),
        BlocProvider<FavoriteCubit>.value(value: favorites),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProductDetailPage(productId: 42),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('Write a review'), 250);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() async => getIt.reset());

  test(
    'reviews use paginated public API and authenticated write endpoints',
    () async {
      final client = _ReviewClient();
      final repo = ProductRepositoryImpl(ProductRemoteDataSourceImpl(client));

      final reviews = (await repo.reviews(42, page: 1, size: 5)).dataOrNull!;
      expect(client.calls.first, 'GET /products/42/reviews 1 5');
      expect(reviews.summary.average, 4.6);
      expect(reviews.summary.shares, [0.8, 0.2, 0, 0, 0]);
      expect(reviews.items.single.author, 'Me');
      expect(reviews.items.single.isMine, isTrue);
      expect(reviews.myReview?.rating, 5);

      expect(
        (await repo.saveReview(42, rating: 4, comment: 'Nice')).isSuccess,
        isTrue,
      );
      expect(client.posted, {'rating': 4, 'comment': 'Nice'});
      expect((await repo.deleteMyReview(42)).isSuccess, isTrue);
      expect(
        client.calls,
        containsAllInOrder([
          'POST /products/42/reviews',
          'DELETE /products/42/reviews/me',
        ]),
      );
    },
  );

  testWidgets('detail review card renders API summary and review text', (
    tester,
  ) async {
    final data = ProductReviews.fromJson({
      'totalCount': 1,
      'page': 1,
      'summary': {
        'average': 5,
        'count': 1,
        'distribution': {'5': 1},
      },
      'items': [
        {
          'id': 1,
          'rating': 5,
          'comment': 'Excellent quality ' * 16,
          'user': {'username': 'Ayna'},
        },
      ],
    });
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductReviewsSection(reviews: data),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reviews'), findsOneWidget);
    expect(find.text('Excellent quality ' * 16), findsOneWidget);
    expect(find.text('Ayna'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signed-in customer can update and delete their review', (
    tester,
  ) async {
    final client = _ReviewClient();
    getIt.registerSingleton<ProductRepository>(
      ProductRepositoryImpl(ProductRemoteDataSourceImpl(client)),
    );
    final auth = AuthCubit(_AuthRepository())
      ..onSignedIn(const AppUser(id: 1, phone: '+99365000000'));
    addTearDown(auth.close);
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProductReviewsPage(productId: '42'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Great'), findsOneWidget);
    await tester.tap(find.text('Edit my review'));
    await tester.pumpAndSettle();
    // The writer is a full page over the reviews now, not a Dialog.
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(client.calls, contains('POST /products/42/reviews'));
    // Delete lives in the "..." menu of the customer's own review.
    await tester.tap(find.byKey(const Key('review-own-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete my review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete my review').last);
    await tester.pumpAndSettle();
    expect(client.calls, contains('DELETE /products/42/reviews/me'));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'write review opens directly over the product and refreshes on save',
    (tester) async {
      final client = _ReviewClient()..empty = true;
      await _mountDetail(tester, client);
      await tester.tap(find.text('Write a review'));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ProductReviewsPage), findsNothing);
      expect(find.byType(ProductDetailPage), findsOneWidget);
      final save = find.widgetWithText(FilledButton, 'Submit');
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      await tester.tap(find.byKey(const ValueKey('review-star-4')));
      await tester.pumpAndSettle();
      expect(find.text('Very good · 4/5'), findsNothing);
      await tester.enterText(find.byType(TextFormField), '  Nice product  ');
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(client.posted, {
        'rating': 4,
        'comment': 'Nice product',
        'images': <String>[],
      });
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Great'), findsOneWidget);
      expect(
        client.calls.where((call) => call == 'GET /products/42/reviews 1 5'),
        hasLength(2),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'review dialog fits a narrow keyboard viewport and keeps failed input',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });
      final client = _ReviewClient()
        ..empty = true
        ..failSave = true;
      await _mountDetail(tester, client);
      await tester.tap(find.text('Write a review'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('review-star-5')));
      await tester.enterText(find.byType(TextFormField), 'Keep this comment');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final save = find.widgetWithText(FilledButton, 'Submit');
      expect(tester.getRect(save).bottom, lessThanOrEqualTo(340));
      expect(save.hitTestable(), findsOneWidget);
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Keep this comment'), findsOneWidget);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(TextFormField)),
      );
      expect(find.text(l10n.reviewActionError), findsOneWidget);
      client.failSave = false;
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(client.posted, {
        'rating': 5,
        'comment': 'Keep this comment',
        'images': <String>[],
      });
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'signed-out customer sees sign-in prompt and can cancel without saving',
    (tester) async {
      final client = _ReviewClient()..empty = true;
      await _mountDetail(tester, client, signedIn: false);
      await tester.tap(find.text('Write a review'));
      await tester.pumpAndSettle();
      // The sign-in prompt is a designed Dialog now, not an AlertDialog.
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Sign in required'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(client.posted, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
