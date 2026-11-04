import 'package:dio/dio.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/error/exceptions.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/api_response.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/storage/local_storage.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/notification/presentation/view/notification_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NotificationApi extends ShopApi {
  _NotificationApi({this.items = const []}) : super(ApiClient(Dio()));

  final List<ShopNotification> items;
  int requests = 0;
  int? failedPage;
  final requestedPages = <int>[];

  @override
  Future<Paginated<ShopNotification>> notifications({
    int page = 1,
    int size = 20,
  }) async {
    requests++;
    requestedPages.add(page);
    if (page == failedPage) throw const NetworkException('Internal error');
    return Paginated(
      items: items.skip((page - 1) * size).take(size).toList(),
      totalCount: items.length,
      page: page,
    );
  }
}

Widget _app({
  Widget? home,
  ThemeData? theme,
  Locale locale = const Locale('en'),
  double textScale = 1,
}) => MaterialApp(
  theme: theme ?? AppTheme.light,
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home ?? const NotificationPage(title: 'Notifications'),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'notifications_last_seen': '20'});
    getIt.registerSingleton<LocalStorage>(
      LocalStorageImpl(await SharedPreferences.getInstance()),
    );
  });
  tearDown(() async => getIt.reset());

  testWidgets('empty notification history shows illustration and refreshes', (
    tester,
  ) async {
    final api = _NotificationApi();
    getIt.registerSingleton<ShopApi>(api);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const NotificationPage(title: 'Notifications'),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.requests, 1);
    expect(find.text('No notifications yet'), findsOneWidget);
    expect(find.text('New updates will appear here.'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/notification_empty_3d.png',
    );

    final content = tester.getRect(
      find.byKey(const Key('notification-empty-content')),
    );
    final viewport = tester.getRect(find.byType(CustomScrollView));
    expect(content.center.dy, lessThan(viewport.center.dy));
    expect((content.center.dy - viewport.center.dy).abs(), lessThan(70));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(api.requests, 2);

    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(api.requests, 3);
  });

  testWidgets('empty announcements use the same centered layout', (
    tester,
  ) async {
    getIt.registerSingleton<ShopApi>(_NotificationApi());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const NotificationPage(
          title: 'Announcements',
          isAnnouncement: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No announcements yet'), findsOneWidget);
    expect(find.text('New announcements will appear here.'), findsOneWidget);
    expect(find.text('No notifications yet'), findsNothing);
    final imageBox = find.byKey(const Key('notification-empty-image'));
    expect(tester.getSize(imageBox).width, 200);
    expect(tester.getSize(imageBox).height, 160);
    expect(
      find.descendant(of: imageBox, matching: find.byType(ClipRect)),
      findsNothing,
    );
    final content = tester.getRect(
      find.byKey(const Key('notification-empty-content')),
    );
    final viewport = tester.getRect(find.byType(CustomScrollView));
    expect(content.center.dy, lessThan(viewport.center.dy));
    expect((content.center.dy - viewport.center.dy).abs(), lessThan(70));
  });

  testWidgets(
    'arrival highlights survive refresh and clear on the next visit',
    (tester) async {
      final now = DateTime.now();
      getIt.registerSingleton<ShopApi>(
        _NotificationApi(
          items: [
            ShopNotification(
              id: 21,
              title: 'Latest update',
              body: 'A new offer.',
              targetType: 'none',
              createdAt: now,
            ),
            ShopNotification(
              id: 20,
              title: 'Previous update',
              body: 'Earlier news.',
              targetType: 'none',
              createdAt: DateTime(now.year, now.month, now.day - 1),
            ),
          ],
        ),
      );
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(getIt<LocalStorage>().getString('notifications_last_seen'), '21');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(find.text('New'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(find.text('Latest update'), findsOneWidget);
      expect(find.text('New'), findsNothing);
    },
  );

  testWidgets(
    'pagination retries in place and preserves the last-seen marker',
    (tester) async {
      final api = _NotificationApi(
        items: List.generate(
          21,
          (index) => ShopNotification(
            id: 21 - index,
            title: 'Update ${21 - index}',
            body: 'News from Elyeter.',
            targetType: 'none',
          ),
        ),
      );
      getIt.registerSingleton<ShopApi>(api);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      api.failedPage = 2;
      await tester.scrollUntilVisible(
        find.text('Load more'),
        400,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Retry'));
      expect(find.text('No internet connection.'), findsOneWidget);
      expect(find.text('Internal error'), findsNothing);

      api.failedPage = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Update 1'),
        300,
        scrollable: find.byType(Scrollable),
      );
      expect(api.requestedPages, [1, 2, 2]);
      expect(find.text('Load more'), findsNothing);
      expect(getIt<LocalStorage>().getString('notifications_last_seen'), '21');
    },
  );

  testWidgets('initial failure has a localized retry', (tester) async {
    final api = _NotificationApi()..failedPage = 1;
    getIt.registerSingleton<ShopApi>(api);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    expect(find.text('No internet connection.'), findsOneWidget);
    expect(find.text('Internal error'), findsNothing);
    api.failedPage = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('empty state fits a small dark screen with large Russian text', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 568)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = _NotificationApi();
    getIt.registerSingleton<ShopApi>(api);
    await tester.pumpWidget(
      _app(
        theme: AppTheme.dark,
        locale: const Locale('ru'),
        textScale: 1.6,
        home: const NotificationPage(title: 'Уведомления'),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Обновить'));
    await tester.tap(find.text('Обновить'));
    await tester.pumpAndSettle();
    expect(api.requests, 2);
  });
}
