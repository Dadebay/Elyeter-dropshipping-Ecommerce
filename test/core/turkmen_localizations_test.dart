import 'package:elyeter/core/localization/fallback_localizations.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/widgets/app_page_app_bar.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Exactly the delegate list `App` builds with.
Widget _app(Locale locale, Widget home) => MaterialApp(
  theme: AppTheme.light,
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    ...FallbackLocalizations.delegates,
  ],
  home: home,
);

void main() {
  // Flutter ships no Turkmen Material strings, so every locale the app
  // offers has to be proven, not assumed.
  for (final code in ['en', 'ru', 'tk']) {
    testWidgets('$code resolves MaterialLocalizations', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        _app(
          Locale(code),
          Builder(
            builder: (context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(
        Localizations.of<MaterialLocalizations>(
          captured,
          MaterialLocalizations,
        ),
        isNotNull,
        reason: '$code has no MaterialLocalizations',
      );
    });

    testWidgets('$code builds the shared header and a text field', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Locale(code),
          Scaffold(
            appBar: const AppPageAppBar(title: 'x'),
            body: const TextField(),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('$code opens a dialog', (tester) async {
      await tester.pumpWidget(
        _app(
          Locale(code),
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AlertDialog(content: Text('x')),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  }
}
