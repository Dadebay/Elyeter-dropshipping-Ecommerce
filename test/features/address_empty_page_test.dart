import 'package:dio/dio.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/address/presentation/view/address_list_page.dart';
import 'package:elyeter/features/address/presentation/view/address_map_picker_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _AddressApi extends ShopApi {
  _AddressApi(List<SavedLocation> items)
    : items = List.of(items),
      super(ApiClient(Dio()));

  final List<SavedLocation> items;
  int requests = 0;

  @override
  Future<List<SavedLocation>> locations() async {
    requests++;
    return items;
  }

  @override
  Future<void> deleteLocation(int id) async {
    items.removeWhere((item) => item.id == id);
  }
}

void main() {
  setUpAll(() => AddressMapPickerPage.autoLocateByDefault = false);
  tearDownAll(() => AddressMapPickerPage.autoLocateByDefault = true);

  tearDown(() async => getIt.reset());

  Future<void> pumpPage(WidgetTester tester, _AddressApi api) async {
    getIt.registerSingleton<ShopApi>(api);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const AddressListPage(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty address list shows add choices and can refresh', (
    tester,
  ) async {
    final api = _AddressApi(const []);
    await pumpPage(tester, api);

    expect(api.requests, 1);
    expect(find.text('Addresses'), findsOneWidget);
    expect(find.text('Add Work Address'), findsOneWidget);
    expect(find.text('Add Home Address'), findsOneWidget);
    expect(find.text('Add New Address'), findsOneWidget);
    expect(find.byTooltip('Add New Address'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(api.requests, 2);
  });

  testWidgets('saved addresses show the list instead of the empty state', (
    tester,
  ) async {
    final api = _AddressApi(const [
      SavedLocation(
        id: 3,
        name: 'Home',
        type: 'home',
        latitude: 37.96,
        longitude: 58.32,
        isDefault: true,
      ),
    ]);
    await pumpPage(tester, api);

    expect(find.text('Home'), findsOneWidget);
    // Home exists, so only the missing types are offered.
    expect(find.text('Add Home Address'), findsNothing);
    expect(find.text('Add Work Address'), findsOneWidget);
    expect(find.text('Add New Address'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  for (final (label, type, name) in [
    ('Add Work Address', 'work', 'Work'),
    ('Add Home Address', 'home', 'Home'),
    ('Add New Address', 'other', null),
  ]) {
    testWidgets('$label opens the matching address form', (tester) async {
      await pumpPage(tester, _AddressApi(const []));

      await tester.tap(find.text(label));
      await tester.pumpAndSettle();

      expect(find.byType(AddressMapPickerPage), findsOneWidget);

      final picker = tester.widget<AddressMapPickerPage>(
        find.byType(AddressMapPickerPage),
      );
      expect(picker.initialType, type);
      expect(picker.initialName, name);
    });
  }

  testWidgets('header plus opens a new address form', (tester) async {
    await pumpPage(tester, _AddressApi(const []));

    await tester.tap(find.byTooltip('Add New Address'));
    await tester.pumpAndSettle();

    final picker = tester.widget<AddressMapPickerPage>(
      find.byType(AddressMapPickerPage),
    );
    expect(picker.initialType, 'other');
    expect(picker.initialName, isNull);
  });

  testWidgets('deleting an address shows the styled success snackbar', (
    tester,
  ) async {
    final api = _AddressApi(const [
      SavedLocation(
        id: 3,
        name: 'Home',
        latitude: 37.96,
        longitude: 58.32,
        isDefault: true,
      ),
    ]);
    await pumpPage(tester, api);

    await tester.longPress(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(api.items, isEmpty);
    expect(find.text('Address deleted.'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
