import 'package:dio/dio.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/features/order/data/datasources/pre_order_remote_data_source.dart';
import 'package:elyeter/features/order/data/models/pre_order_model.dart';
import 'package:elyeter/features/order/domain/entities/pre_order.dart';
import 'package:elyeter/features/order/domain/entities/pre_order_line.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockClient extends Mock implements ApiClient {}

Map<String, dynamic> _order({bool pending = false}) => {
  'id': 101,
  'number': 'PO-000101',
  'status': 'NEW',
  'total_price': 178,
  'currency': 'TMT',
  'items_count': 2,
  'customer_name': 'Aman',
  'phone': '+99362123456',
  'address': 'Aşgabat',
  'created_at': '2026-11-07T09:01:54.574Z',
  'is_paid': false,
  'has_pending_payment': pending,
  'can_pay': true,
  'can_cancel': !pending,
  'items': <Map<String, dynamic>>[],
};

void main() {
  test('a cart line carries its price only when it has one', () {
    expect(
      const PreOrderLine(
        productId: 3,
        variantId: 12,
        quantity: 2,
        price: 84,
      ).toJson(),
      {'product_id': 3, 'variant_id': 12, 'quantity': 2, 'price': 84},
    );
    expect(const PreOrderLine(productId: 1, quantity: 1).toJson(), {
      'product_id': 1,
      'quantity': 1,
    });
  });

  test('an order reads has_pending_payment', () {
    expect(PreOrderModel.fromJson(_order()).hasPendingPayment, isFalse);
    final pending = PreOrderModel.fromJson(_order(pending: true));
    expect(pending.hasPendingPayment, isTrue);
    expect(pending.canCancel, isFalse);
  });

  group('the remote source', () {
    late _MockClient client;
    late PreOrderRemoteDataSourceImpl remote;

    setUp(() {
      client = _MockClient();
      remote = PreOrderRemoteDataSourceImpl(client);
    });

    test('create sends location_id and idempotency_key', () async {
      when(
        () => client.post(
          any(),
          data: any(named: 'data'),
          receiveTimeout: any(named: 'receiveTimeout'),
        ),
      ).thenAnswer((_) async => _order());

      await remote.create(
        lines: const [PreOrderLine(productId: 1, quantity: 2, price: 100)],
        customerName: 'Aman',
        expectedTotal: 200,
        locationId: 3,
        idempotencyKey: '7f9c1d2e-4b6a-4e1f-9a3b-2c5d8e0f1a2b',
      );

      final body =
          verify(
                () => client.post(
                  any(),
                  data: captureAny(named: 'data'),
                  receiveTimeout: any(named: 'receiveTimeout'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(body['location_id'], 3);
      expect(body['idempotency_key'], '7f9c1d2e-4b6a-4e1f-9a3b-2c5d8e0f1a2b');
      expect(body['expected_total'], 200);
      expect((body['items'] as List).single, {
        'product_id': 1,
        'quantity': 2,
        'price': 100,
      });
      // The phone comes from the account; the API rejects it in the body.
      expect(body.containsKey('phone'), isFalse);
    });

    test('the active list filters by several statuses at once', () async {
      when(
        () => client.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => {'totalCount': 0, 'page': 1, 'items': <dynamic>[]},
      );

      await remote.list(
        page: 1,
        size: 20,
        statuses: const [
          PreOrderStatus.newOrder,
          PreOrderStatus.confirmed,
          PreOrderStatus.ordered,
        ],
      );

      final query =
          verify(
                () => client.get(
                  any(),
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(query['status'], 'NEW,CONFIRMED,ORDERED');
      expect(query['page'], 1);
      expect(query['size'], 20);
    });
  });
}
