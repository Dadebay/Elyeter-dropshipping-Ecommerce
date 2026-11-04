import 'package:elyeter/features/order/data/models/pre_order_model.dart';
import 'package:elyeter/features/order/presentation/model/order_detail_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('order keeps the checkout location snapshot for the tracking map', () {
    final order = PreOrderModel.fromJson({
      'id': 7,
      'number': 'PO-000007',
      'status': 'CONFIRMED',
      'total_price': 1392,
      'latitude': 37.960077,
      'longitude': 58.326063,
    });

    expect(order.latitude, 37.960077);
    expect(order.longitude, 58.326063);
  });

  test('older orders without coordinates do not get a guessed point', () {
    final order = PreOrderModel.fromJson({
      'id': 1,
      'number': 'PO-000001',
      'status': 'NEW',
      'total_price': 500,
    });

    expect(order.latitude, isNull);
    expect(order.longitude, isNull);
  });

  test('saved order address is shown as the pickup point', () {
    final order = PreOrderModel.fromJson({
      'id': 8,
      'number': 'PO-000008',
      'status': 'NEW',
      'total_price': 280,
      'address': 'Aşgabat şäheri, Andalyp köçesi 541',
    });

    expect(
      OrderDetailData.fromPreOrder(order).pickupPoint,
      'Aşgabat şäheri, Andalyp köçesi 541',
    );
  });
}
