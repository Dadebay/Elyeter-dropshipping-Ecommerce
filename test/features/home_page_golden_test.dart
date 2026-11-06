@Tags(['golden'])
library;

import 'package:elyeter/core/constants/app_assets.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:elyeter/features/favorite/presentation/cubit/favorite_cubit.dart';
import 'package:elyeter/features/home/presentation/view/home_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Keeps the hydrated cubits happy without touching the disk.
class _MemoryStorage implements Storage {
  final Map<String, dynamic> _values = {};

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clear() async => _values.clear();

  @override
  Future<void> close() async {}
}

Future<void> _loadFonts() async {
  for (final e in {
    'InterDisplay': 'assets/fonts/InterDisplay-Medium.ttf',
  }.entries) {
    final loader = FontLoader(e.key)..addFont(rootBundle.load(e.value));
    await loader.load();

    final wordmark = FontLoader('Qurova')
      ..addFont(rootBundle.load('assets/fonts/QurovaDEMO-Medium.otf'));
    await wordmark.load();
  }
}

void main() {
  setUp(() => HydratedBloc.storage = _MemoryStorage());

  // (label, top inset): a Dynamic Island iPhone and a plain Android bar.
  const devices = [('ios', 59.0), ('android', 24.0)];

  for (final (name, topInset) in devices) {
    testWidgets('home page golden - $name', (tester) async {
      await _loadFonts();
      tester.view
        ..physicalSize = const Size(1170, 2532)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => FavoriteCubit()),
            BlocProvider(create: (_) => CartCubit()),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              // copyWith, not a bare MediaQueryData: a fresh one has size
              // zero, and the header sizes itself from the screen height.
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  viewPadding: EdgeInsets.only(top: topInset, bottom: 34),
                  padding: EdgeInsets.only(top: topInset, bottom: 34),
                ),
                child: const HomePage(),
              ),
            ),
          ),
        ),
      );
      // Real asset decoding needs the async zone; without it neither the
      // background nor the SVG logo paints and the golden lies.
      await tester.runAsync(() async {
        await precacheImage(
          const AssetImage(AppAssets.homeBackground),
          tester.element(find.byType(HomePage)),
        );
        for (final path in const [
          AppAssets.logoWhite,
          AppAssets.marketAliexpress,
          AppAssets.marketAlibaba,
          AppAssets.marketTaobao,
          AppAssets.market1688,
        ]) {
          final loader = SvgAssetLoader(path);
          await svg.cache.putIfAbsent(
            loader.cacheKey(null),
            () => loader.loadBytes(null),
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump(const Duration(milliseconds: 100));

      // Asset decoding needs the real event loop; pumping a fixed amount
      // rather than settling, because the shimmer placeholders never stop.
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 600)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }

      await expectLater(
        find.byType(HomePage),
        matchesGoldenFile('goldens/home_page_$name.png'),
      );
    });
  }
}
