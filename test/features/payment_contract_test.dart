import 'package:elyeter/core/error/exceptions.dart';
import 'package:elyeter/features/order/data/models/pre_order_model.dart';
import 'package:elyeter/features/payment/data/models/payment_model.dart';
import 'package:elyeter/features/payment/domain/entities/payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final payment = <String, dynamic>{
    'id': 4,
    'pre_order_id': 9,
    'bank_id': 2,
    'amount': 115,
    'status': 'PENDING',
  };

  test('payment amount is required instead of silently becoming zero', () {
    expect(
      () => PaymentModel.fromJson({...payment}..remove('amount')),
      throwsA(isA<ParsingException>()),
    );
  });

  test('an unknown payment status remains pending for later checking', () {
    expect(
      PaymentModel.fromJson({...payment, 'status': 'VERIFYING'}).status,
      PaymentStatus.pending,
    );
  });

  test('order total is required instead of silently becoming zero', () {
    expect(
      () =>
          PreOrderModel.fromJson({'id': 9, 'number': 'PO-9', 'status': 'NEW'}),
      throwsA(isA<ParsingException>()),
    );
  });
}
