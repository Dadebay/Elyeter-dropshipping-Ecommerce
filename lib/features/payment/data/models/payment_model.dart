import '../../../../core/network/api_response.dart';
import '../../domain/entities/bank.dart';
import '../../domain/entities/payment.dart';

abstract final class PaymentModel {
  static Payment fromJson(Map<String, dynamic> json) => Payment(
    id: json.intVal('id'),
    preOrderId: json.intVal('pre_order_id'),
    bankId: json.intVal('bank_id'),
    amount: json.numVal('amount'),
    status: PaymentStatus.parse(json.strOrNull('status')),
    invoiceUrl: json.strOrNull('invoice_url'),
    returnUrl: json.strOrNull('return_url'),
    paidAt: json.dateOrNull('paid_at'),
    createdAt: json.dateOrNull('created_at'),
  );

  static Bank bankFromJson(Map<String, dynamic> json) => Bank(
    id: json.intVal('id'),
    name: json.str('name'),
    logo: json.strOrNull('logo'),
  );
}
