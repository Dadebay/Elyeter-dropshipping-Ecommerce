import '../../../../core/network/api_response.dart';
import '../../../product/data/models/product_model.dart';
import '../../domain/entities/image_search.dart';

abstract final class ImageSearchModel {
  static ImageSearch fromJson(Map<String, dynamic> json) => ImageSearch(
    id: json.intVal('id'),
    status: ImageSearchStatus.parse(json.strOrNull('status')),
    foundCount: json.intVal('found_count'),
    image: json.strOrNull('image'),
    waitingCount: json.intVal('waiting_count'),
    products: json.listOf('products').map(ProductModel.fromJson).toList(),
  );
}
