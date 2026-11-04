import '../../../../core/network/api_response.dart';
import '../../../product/data/models/product_model.dart';
import '../../domain/entities/product_request.dart';

abstract final class ProductRequestModel {
  static ProductRequest fromJson(Map<String, dynamic> json) {
    final product = json.mapOrNull('product');
    return ProductRequest(
      id: json.intVal('id'),
      url: json.str('url'),
      status: ProductRequestStatus.parse(json.strOrNull('status')),
      product: product == null ? null : ProductModel.fromJson(product),
      createdAt: json.dateOrNull('created_at'),
      updatedAt: json.dateOrNull('updated_at'),
    );
  }
}
