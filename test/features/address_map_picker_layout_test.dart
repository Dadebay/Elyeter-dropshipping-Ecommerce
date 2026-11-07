import 'dart:async';

import 'package:elyeter/core/constants/app_assets.dart';
import 'package:elyeter/core/constants/app_icons.dart';
import 'package:elyeter/core/network/shop_api.dart';
import 'package:elyeter/core/services/address_lookup_service.dart';
import 'package:elyeter/core/services/device_location_service.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/theme/app_typography.dart';
import 'package:elyeter/core/widgets/elyeter_map.dart';
import 'package:elyeter/features/address/presentation/view/address_map_picker_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

class _FixedLocation extends DeviceLocationService {
  @override
  Future<LatLng> locate() async => const LatLng(37.96, 58.32);
}

class _FixedAddressLookup implements AddressLookupService {
  _FixedAddressLookup(this.result);
  final String? result;

  @override
  Future<String?> reverse(LatLng point, Locale locale) async => result;
}

class _PendingAddressLookup implements AddressLookupService {
  final completer = Completer<String?>();

  @override
  Future<String?> reverse(LatLng point, Locale locale) => completer.future;
}

void main() {
  testWidgets('address fields fit the sheet beside the map', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const AddressMapPickerPage(autoLocate: false),
      ),
    );

    final map = tester.getRect(find.byType(ElyeterMap));
    final sheet = tester.getRect(find.byType(SingleChildScrollView));
    expect(map.height, greaterThan(300));
    expect(sheet.height, greaterThan(400));
    expect(map.bottom, greaterThan(sheet.top - 40));
    expect(find.text('© OpenStreetMap'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('© OpenStreetMap'),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    expect(find.textContaining('contributors'), findsNothing);
    expect(find.textContaining('flutter_map'), findsNothing);
    expect(
      tester
          .widget<SvgPicture>(find.byKey(const Key('address-map-pin')))
          .bytesLoader,
      isA<SvgAssetLoader>().having(
        (loader) => loader.assetName,
        'assetName',
        AppAssets.iconAddressMapPin,
      ),
    );
    expect(find.text('Apartment / Flat'), findsOneWidget);
    expect(find.text('Floor'), findsOneWidget);
    expect(find.text('Address name'), findsOneWidget);
    expect(find.text('Save address'), findsOneWidget);
    final fields = find.byType(TextField);
    expect(
      tester.widget<TextField>(fields.at(1)).decoration?.hintText,
      'e.g. 35/1',
    );
    expect(
      tester.widget<TextField>(fields.at(2)).decoration?.hintText,
      'e.g. 3',
    );
    expect(tester.getRect(find.text('Floor')).bottom, lessThan(sheet.bottom));
    expect(
      tester.getRect(find.text('Save address')).bottom,
      lessThan(sheet.bottom),
    );
    expect(
      tester.getRect(find.text('Save address')).top -
          tester.getRect(fields.at(3)).bottom,
      lessThan(64),
    );
    expect(
      tester.widget<Text>(find.text('Apartment / Flat')).style?.fontFamily,
      AppTypography.fontFamily,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).first).style?.fontFamily,
      AppTypography.fontFamily,
    );
    expect(
      tester.widget<Text>(find.text('Save address')).style?.fontFamily,
      AppTypography.fontFamily,
    );

    await tester.pump(const Duration(seconds: 5));
    expect(find.text('© OpenStreetMap'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is HugeIcon && widget.icon == AppIcons.information,
      ),
      findsNothing,
    );
  });

  testWidgets('short screens scroll the whole form without overflow', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 300)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const AddressMapPickerPage(autoLocate: false),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('address-current-location')), findsOneWidget);
    await tester.ensureVisible(find.text('Save address'));
    await tester.pumpAndSettle();
    expect(find.text('Save address'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('locate fills the address field with the resolved street', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: AddressMapPickerPage(
          autoLocate: false,
          locationService: _FixedLocation(),
          addressLookupService: _FixedAddressLookup(
            'Ahal street, Annau, Turkmenistan',
          ),
        ),
      ),
    );

    final locateIcon = find.byKey(const Key('address-current-location'));
    await tester.tap(
      find.ancestor(of: locateIcon, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(
      tester.widget<TextField>(fields.first).controller!.text,
      'Ahal street, Annau, Turkmenistan',
    );
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, isEmpty);
    expect(tester.widget<TextField>(fields.at(2)).controller!.text, isEmpty);
  });

  testWidgets('locate leaves the address empty to type when none resolves', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: AddressMapPickerPage(
          autoLocate: false,
          locationService: _FixedLocation(),
          addressLookupService: _FixedAddressLookup(null),
        ),
      ),
    );

    final locateIcon = find.byKey(const Key('address-current-location'));
    await tester.tap(
      find.ancestor(of: locateIcon, matching: find.byType(InkWell)).first,
    );
    await tester.pumpAndSettle();

    // Raw coordinates are never shown: the field stays empty for typing.
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
    expect(
      find.text('Street address unavailable. Type the address manually.'),
      findsOneWidget,
    );
  });

  testWidgets('moving the map pin refreshes the address field', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: AddressMapPickerPage(
          autoLocate: false,
          addressLookupService: _FixedAddressLookup('Ahal street, Annau'),
        ),
      ),
    );

    await tester.drag(find.byType(ElyeterMap), const Offset(60, 0));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Ahal street, Annau',
    );
  });

  testWidgets('moving the pin clears the old address until lookup finishes', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final lookup = _PendingAddressLookup();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: AddressMapPickerPage(
          autoLocate: false,
          current: const SavedLocation(
            id: 1,
            name: 'Home',
            type: 'home',
            address: 'Old street',
            latitude: 37.96,
            longitude: 58.32,
            isDefault: false,
          ),
          addressLookupService: lookup,
        ),
      ),
    );

    await tester.drag(find.byType(ElyeterMap), const Offset(60, 0));
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
    expect(find.text('Finding address…'), findsOneWidget);
    lookup.completer.complete('New street, Annau');
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'New street, Annau',
    );
    expect(find.text('Save address'), findsOneWidget);
  });

  testWidgets('editing keeps apartment and floor in the saved details', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Map<String, dynamic>? saved;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                saved = await Navigator.of(context).push<Map<String, dynamic>>(
                  MaterialPageRoute(
                    builder: (_) => const AddressMapPickerPage(
                      autoLocate: false,
                      current: SavedLocation(
                        id: 1,
                        name: 'Sister’s House',
                        type: 'other',
                        address: 'Ahal street',
                        details: '35/1 · Floor: 3',
                        latitude: 37.96,
                        longitude: 58.32,
                        isDefault: false,
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, '35/1');
    expect(tester.widget<TextField>(fields.at(2)).controller!.text, '3');
    expect(
      tester.getRect(fields.at(3)).bottom,
      lessThanOrEqualTo(
        tester.getRect(find.byType(SingleChildScrollView)).bottom,
      ),
    );

    await tester.enterText(fields.at(2), '4');
    await tester.tap(find.text('Save address'));
    await tester.pumpAndSettle();

    expect(saved?['details'], '35/1 · Floor: 4');
    expect(saved?['type'], 'other');
  });

  testWidgets('opening the keyboard keeps the focused field', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetViewInsets();
      tester.view.reset();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const AddressMapPickerPage(autoLocate: false),
      ),
    );

    final floor = find.byType(TextField).at(2);
    await tester.tap(floor);
    await tester.pump();
    final focusBefore = tester.widget<TextField>(floor).focusNode;

    // The keyboard rises in steps, as it does on a phone.
    for (final inset in [80.0, 180.0, 300.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pump(const Duration(milliseconds: 40));
    }
    await tester.pumpAndSettle();

    final editable = tester.state<EditableTextState>(
      find.descendant(of: floor, matching: find.byType(EditableText)),
    );
    expect(editable.widget.focusNode.hasFocus, isTrue);
    expect(focusBefore == null || focusBefore.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });
}
