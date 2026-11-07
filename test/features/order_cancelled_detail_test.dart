import 'package:elyeter/core/constants/app_assets.dart';
import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/localization/fallback_localizations.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/features/order/domain/entities/pre_order.dart';
import 'package:elyeter/features/order/domain/repositories/pre_order_repository.dart';
import 'package:elyeter/features/order/presentation/view/order_detail_page.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elyeter/features/auth/domain/repositories/auth_repository.dart';
import 'package:elyeter/features/auth/presentation/cubit/auth_cubit.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {}

class _CancelledOrderRepository extends Fake implements PreOrderRepository {
  @override
  Future<Result<PreOrder>> byId(int id) async => Success(
    PreOrder(
      id: id,
      number: 'PO-000005',
      status: PreOrderStatus.cancelled,
      totalPrice: 328,
      comment: 'Müşderiniň belligi',
      createdAt: DateTime(2026, 10, 20, 5, 27),
      statusChangedAt: DateTime(2026, 10, 20, 7, 56),
    ),
  );
}

void main() {
  tearDown(() => getIt.reset());

  testWidgets('cancelled order uses supplied icon and stopped timeline', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    getIt.registerSingleton<PreOrderRepository>(_CancelledOrderRepository());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('tk'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FallbackLocalizations.delegates,
        ],
        home: BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(_FakeAuthRepository()),
          child: const OrderDetailPage(orderId: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Sargyt ýatyryldy'), findsOneWidget);
    expect(find.text('Ýatyryldy'), findsOneWidget);
    expect(find.text('Togtadyldy'), findsNWidgets(3));
    expect(find.text('Hytaý ammaryna geldi'), findsOneWidget);
    expect(find.text('Müşderiniň belligi'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                AppAssets.imageOrderCancelled,
      ),
      findsOneWidget,
    );
  });
}
