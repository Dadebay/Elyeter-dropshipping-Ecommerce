import 'package:elyeter/core/di/injector.dart';
import 'package:elyeter/core/network/api_response.dart';
import 'package:elyeter/core/theme/app_theme.dart';
import 'package:elyeter/core/utils/result.dart';
import 'package:elyeter/features/order/domain/entities/pre_order.dart';
import 'package:elyeter/features/order/domain/repositories/pre_order_repository.dart';
import 'package:elyeter/features/order/presentation/widgets/paged_orders_list.dart';
import 'package:elyeter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _OrdersRepository implements PreOrderRepository {
  _OrdersRepository(this.items);

  final List<PreOrder> items;
  int requests = 0;

  @override
  Future<Result<Paginated<PreOrder>>> list({
    int page = 1,
    int size = 20,
    List<PreOrderStatus> statuses = const [],
  }) async {
    requests++;
    return Success(
      Paginated(items: items, totalCount: items.length, page: page),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(() async => getIt.reset());

  Future<void> pumpPage(
    WidgetTester tester,
    _OrdersRepository repository, {
    bool activeOnly = false,
  }) async {
    getIt.registerSingleton<PreOrderRepository>(repository);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: PagedOrdersList(
            activeOnly: activeOnly,
            status: activeOnly ? null : PreOrderStatus.completed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('order history shows 3D empty state and stays refreshable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _OrdersRepository(const []);
    await pumpPage(tester, repository);

    expect(find.text('No orders yet'), findsOneWidget);
    expect(
      find.text('Your orders will appear here after you place one.'),
      findsOneWidget,
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/order_history_empty_3d_cutout.png',
    );
    expect(image.fit, BoxFit.contain);
    expect(tester.getSize(find.byWidget(image)), const Size(160, 160));

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(repository.requests, 2);
  });

  testWidgets('active orders distinguish their empty state from history', (
    tester,
  ) async {
    final repository = _OrdersRepository(const [
      PreOrder(
        id: 1,
        number: 'PO-000001',
        status: PreOrderStatus.completed,
        totalPrice: 100,
      ),
    ]);
    await pumpPage(tester, repository, activeOnly: true);

    expect(find.text('No active orders'), findsOneWidget);
    expect(find.text('PO-000001'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('existing order is listed without empty illustration', (
    tester,
  ) async {
    final repository = _OrdersRepository(const [
      PreOrder(
        id: 1,
        number: 'PO-000001',
        status: PreOrderStatus.completed,
        totalPrice: 100,
      ),
    ]);
    await pumpPage(tester, repository);

    expect(find.text('PO-000001'), findsOneWidget);
    expect(find.text('No orders yet'), findsNothing);
    expect(find.byType(Image), findsNothing);
  });
}
