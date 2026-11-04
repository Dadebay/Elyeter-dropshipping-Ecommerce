import 'package:dio/dio.dart';
import 'package:elyeter/app/router/app_routes.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/localization/fallback_localizations.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/order/presentation/widgets/order_address_dialog.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _AddressApi extends ShopApi {
  _AddressApi(this.items) : super(ApiClient(Dio()));

  final List<SavedLocation> items;

  @override
  Future<List<SavedLocation>> locations() async => items;
}

const _home = SavedLocation(
  id: 1,
  name: 'Home',
  latitude: 37.96,
  longitude: 58.32,
  isDefault: true,
  address: 'Aşgabat şäheri',
  details: 'Andalyp köçesi 541',
);

void main() {
  tearDown(() => getIt.reset());

  Future<SavedLocation?>? choice;

  Future<void> pumpPicker(
    WidgetTester tester,
    List<SavedLocation> locations,
  ) async {
    getIt.registerSingleton<ShopApi>(_AddressApi(locations));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('tk'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FallbackLocalizations.delegates,
        ],
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => choice = requestOrderLocation(context),
              child: const Text('Place order'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('uses a saved default and includes its address details', (
    tester,
  ) async {
    await pumpPicker(tester, const [_home]);
    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();

    expect((await choice)?.id, 1);
    expect(orderAddressText(_home), 'Aşgabat şäheri, Andalyp köçesi 541');
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('requires an explicit choice when there is no default', (
    tester,
  ) async {
    const work = SavedLocation(
      id: 2,
      name: 'Work',
      latitude: 37.97,
      longitude: 58.34,
      isDefault: false,
      address: 'Köpetdag etraby',
    );
    await pumpPicker(tester, const [work]);
    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();

    expect(find.text('Salgyny saýlaň'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    expect((await choice)?.id, 2);
  });

  testWidgets('cancelling with no saved address does not select one', (
    tester,
  ) async {
    await pumpPicker(tester, const []);
    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();

    expect(find.text('Salgyny saýlaň'), findsOneWidget);
    await tester.tap(find.text('Ýatyr'));
    await tester.pumpAndSettle();
    expect(await choice, isNull);
  });

  testWidgets('adding an address returns it to the pending order', (
    tester,
  ) async {
    final api = _AddressApi([]);
    getIt.registerSingleton<ShopApi>(api);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: FilledButton(
              onPressed: () => choice = requestOrderLocation(context),
              child: const Text('Place order'),
            ),
          ),
        ),
        GoRoute(
          path: '/addresses',
          name: AppRoutes.addresses.name,
          builder: (context, state) => Scaffold(
            body: FilledButton(
              onPressed: () {
                api.items.add(_home);
                context.pop();
              },
              child: const Text('Save address'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light,
        locale: const Locale('tk'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FallbackLocalizations.delegates,
        ],
      ),
    );

    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Täze salgy goş'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save address'));
    await tester.pumpAndSettle();

    expect((await choice)?.id, _home.id);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
