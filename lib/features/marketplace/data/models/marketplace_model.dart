import '../../../../core/network/api_response.dart';
import '../../domain/entities/marketplace.dart';

abstract final class MarketplaceModel {
  static Marketplace fromJson(Map<String, dynamic> json) {
    final features = json.mapOrNull('features');
    return Marketplace(
      id: json.intVal('id'),
      code: json.str('code'),
      name: json.str('name'),
      currency: json.strOrNull('currency'),
      productsCount: json.intVal('products_count'),
      productRequest: features?.boolVal('product_request') ?? false,
      imageSearch: features?.boolVal('image_search') ?? false,
    );
  }
}
