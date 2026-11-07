import 'package:elyeter/core/utils/formatters/currency_formatter.dart';
import 'package:elyeter/core/theme/app_colors.dart';
import 'package:elyeter/features/product/presentation/widgets/product_detail_sections.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  testWidgets('price card stays compact with aligned currency and grey arrow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ProductPriceCard(
                name: 'Silver Swarovski ring',
                price: 7526,
                oldPrice: 8000,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(ProductPriceCard)).height,
      lessThanOrEqualTo(52),
    );
    expect(
      tester
          .widget<Text>(find.text(CurrencyFormatter.amount(7526)))
          .style
          ?.color,
      const Color(0xFFAD1F2B),
    );
    expect(
      tester.widget<Text>(find.text('TMT')).style?.color,
      const Color(0xFFAD1F2B),
    );
    expect(
      tester.widget<HugeIcon>(find.byType(HugeIcon)).color,
      AppColors.grey700,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('price arrow opens a floating sheet with the selected price', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Center(
            child: ProductPriceCard(
              name: 'Silver Swarovski ring',
              price: 7526,
              oldPrice: 8000,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Price details'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('product-price-details-sheet')),
      findsOneWidget,
    );
    expect(find.text('Silver Swarovski ring'), findsOneWidget);
    expect(find.text('Price per item'), findsOneWidget);
    expect(find.text('Regular price'), findsOneWidget);
    expect(find.text('6% discount'), findsOneWidget);
    expect(
      find.text(CurrencyFormatter.format(474, decimals: 0)),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-price-details-sheet')), findsNothing);
  });

  testWidgets('undiscounted price stays readable on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Center(
            child: ProductPriceCard(
              name:
                  'A long product name that should fit inside the details card',
              price: 1234,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Price details'));
    await tester.pumpAndSettle();
    expect(find.text('Regular price'), findsOneWidget);
    expect(find.textContaining('% discount'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
