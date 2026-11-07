import '../../../../core/network/api_response.dart';
import '../../domain/entities/bank.dart';
import '../../domain/entities/payment.dart';

abstract final class PaymentModel {
  static Payment fromJson(Map<String, dynamic> json) => Payment(
    id: json.reqInt('id'),
    preOrderId: json.reqInt('pre_order_id'),
    bankId: json.reqInt('bank_id'),
    amount: json.reqNum('amount'),
    status: PaymentStatus.parse(json.reqStr('status')),
    invoiceUrl: json.strOrNull('invoice_url'),
    returnUrl: json.strOrNull('return_url'),
    paidAt: json.dateOrNull('paid_at'),
    createdAt: json.dateOrNull('created_at'),
  );

  static Bank bankFromJson(Map<String, dynamic> json) => Bank(
    id: json.reqInt('id'),
    name: json.reqStr('name'),
    logo: json.strOrNull('logo'),
  );
}
