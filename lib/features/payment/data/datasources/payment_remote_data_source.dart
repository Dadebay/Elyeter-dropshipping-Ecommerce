import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/bank.dart';
import '../../domain/entities/payment.dart';
import '../models/payment_model.dart';

abstract interface class PaymentRemoteDataSource {
  Future<List<Bank>> banks();
  Future<Payment> start({required int preOrderId, required int bankId});
  Future<Payment> byId(int id);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<Bank>> banks() async {
    final data = await _client.get(ApiEndpoints.banks);
    return parseList(data, PaymentModel.bankFromJson);
  }

  @override
  Future<Payment> start({required int preOrderId, required int bankId}) async {
    final data = await _client.post(
      ApiEndpoints.payments,
      data: {'pre_order_id': preOrderId, 'bank_id': bankId},
    );
    return PaymentModel.fromJson(asMap(data));
  }

  @override
  Future<Payment> byId(int id) async {
    final data = await _client.get(ApiEndpoints.payment(id));
    return PaymentModel.fromJson(asMap(data));
  }
}
