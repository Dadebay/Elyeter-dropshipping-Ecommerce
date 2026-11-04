import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/product_request.dart';
import '../models/product_request_model.dart';

abstract interface class ProductRequestRemoteDataSource {
  Future<ProductRequest> create(String text);
  Future<Paginated<ProductRequest>> list({
    required int page,
    required int size,
  });
  Future<ProductRequest> byId(int id);
}

class ProductRequestRemoteDataSourceImpl
    implements ProductRequestRemoteDataSource {
  ProductRequestRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<ProductRequest> create(String text) async {
    final data = await _client.post(
      ApiEndpoints.productRequests,
      data: {'url': text},
      // The backend may start loading from AliExpress before it answers.
      receiveTimeout: AppConstants.preOrderTimeout,
    );
    return ProductRequestModel.fromJson(asMap(data));
  }

  @override
  Future<Paginated<ProductRequest>> list({
    required int page,
    required int size,
  }) async {
    final data = await _client.get(
      ApiEndpoints.productRequests,
      queryParameters: {'page': page, 'size': size},
    );
    return Paginated.fromJson(data, ProductRequestModel.fromJson);
  }

  @override
  Future<ProductRequest> byId(int id) async {
    final data = await _client.get(ApiEndpoints.productRequest(id));
    return ProductRequestModel.fromJson(asMap(data));
  }
}
