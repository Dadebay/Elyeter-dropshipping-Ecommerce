import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/marketplace.dart';
import '../models/marketplace_model.dart';

abstract interface class MarketplaceRemoteDataSource {
  Future<List<Marketplace>> list();
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  MarketplaceRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<Marketplace>> list() async {
    final data = await _client.get(ApiEndpoints.marketplaces);
    return [
      for (final item in data as List? ?? const [])
        if (item is Map<String, dynamic>) MarketplaceModel.fromJson(item),
    ];
  }
}
