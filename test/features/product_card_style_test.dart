import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/utils/formatters/currency_formatter.dart';
import 'package:elyeter/core/widgets/app_network_image.dart';
import 'package:elyeter/features/product/presentation/widgets/product_card.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('catalog card matches the price and action styling', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 316,
              child: ProductCard(
                data: const ProductCardData(
                  id: 'apple-tv',
                  title: 'Apple TV Model 7 4K 2022 Edition HD Set-Top Box',
                  price: 22329,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final amount = tester.widget<Text>(
      find.text(CurrencyFormatter.amount(22329)),
    );
    final currency = tester.widget<Text>(find.text('man'));
    final title = tester.widget<Text>(find.textContaining('Apple TV Model'));
    final action = tester.widget<Text>(find.text('Add to Card'));

    expect(amount.style?.fontSize, 18);
    expect(amount.style?.fontWeight, FontWeight.w700);
    expect(amount.style?.color, const Color(0xFFFF6600));
    expect(currency.style?.fontSize, 14);
    expect(currency.style?.fontWeight, FontWeight.w400);
    expect(currency.style?.color, const Color(0xFFFF6600));
    expect(title.style?.fontSize, 12);
    expect(title.style?.fontWeight, FontWeight.w500);
    expect(title.style?.color, const Color(0xFF5C5C5C));
    expect(action.style?.fontSize, 14);
    expect(action.style?.fontWeight, FontWeight.w500);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == const Color(0xFFF3F5F7),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == const Color(0xFFF7F7F7),
      ),
      findsWidgets,
    );
    expect(
      tester
          .widget<AppNetworkImage>(find.byType(AppNetworkImage))
          .fallbackColor,
      const Color(0xFFF7F7F7),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            ((widget.decoration as BoxDecoration).boxShadow?.isNotEmpty ??
                false),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
