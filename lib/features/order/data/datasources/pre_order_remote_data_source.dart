import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/pre_order.dart';
import '../../domain/entities/pre_order_check.dart';
import '../../domain/entities/pre_order_line.dart';
import '../models/pre_order_check_model.dart';
import '../models/pre_order_model.dart';

abstract interface class PreOrderRemoteDataSource {
  Future<PreOrderCheck> check(List<PreOrderLine> lines);
  Future<PreOrder> create({
    required List<PreOrderLine> lines,
    String? customerName,
    String? address,
    String? comment,
    num? expectedTotal,
    int? locationId,
    String? idempotencyKey,
  });
  Future<Paginated<PreOrder>> list({
    required int page,
    required int size,
    List<PreOrderStatus> statuses,
  });
  Future<PreOrder> byId(int id);
  Future<PreOrder> cancel(int id);
}

class PreOrderRemoteDataSourceImpl implements PreOrderRemoteDataSource {
  PreOrderRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<PreOrderCheck> check(List<PreOrderLine> lines) async {
    final data = await _client.post(
      ApiEndpoints.preOrderCheck,
      data: {'items': lines.map((line) => line.toJson()).toList()},
      // The backend calls AliExpress live on this one.
      receiveTimeout: AppConstants.preOrderTimeout,
    );
    return PreOrderCheckModel.fromJson(asMap(data));
  }

  @override
  Future<PreOrder> create({
    required List<PreOrderLine> lines,
    String? customerName,
    String? address,
    String? comment,
    num? expectedTotal,
    int? locationId,
    String? idempotencyKey,
  }) async {
    final data = await _client.post(
      ApiEndpoints.preOrders,
      // The phone number is taken from the authenticated account — the API
      // rejects the body field.
      data: {
        'items': lines.map((line) => line.toJson()).toList(),
        if (customerName != null && customerName.isNotEmpty)
          'customer_name': customerName,
        if (address != null && address.isNotEmpty) 'address': address,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        'expected_total': ?expectedTotal,
        'location_id': ?locationId,
        if (idempotencyKey != null && idempotencyKey.isNotEmpty)
          'idempotency_key': idempotencyKey,
      },
      receiveTimeout: AppConstants.preOrderTimeout,
    );
    return PreOrderModel.fromJson(asMap(data));
  }

  @override
  Future<Paginated<PreOrder>> list({
    required int page,
    required int size,
    List<PreOrderStatus> statuses = const [],
  }) async {
    final data = await _client.get(
      ApiEndpoints.preOrders,
      queryParameters: {
        'page': page,
        'size': size,
        if (statuses.isNotEmpty)
          'status': statuses.map((s) => s.value).join(','),
      },
    );
    return Paginated.fromJson(data, PreOrderModel.fromJson);
  }

  @override
  Future<PreOrder> byId(int id) async {
    final data = await _client.get(ApiEndpoints.preOrder(id));
    return PreOrderModel.fromJson(asMap(data));
  }

  @override
  Future<PreOrder> cancel(int id) async {
    final data = await _client.post(ApiEndpoints.cancelPreOrder(id));
    return PreOrderModel.fromJson(asMap(data));
  }
}
