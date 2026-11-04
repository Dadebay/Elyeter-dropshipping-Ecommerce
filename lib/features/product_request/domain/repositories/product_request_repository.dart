import '../../../../core/network/api_response.dart';
import '../../../../core/utils/result.dart';
import '../entities/product_request.dart';

/// "Didn't find a product? Send us a link". Every call is authenticated.
abstract interface class ProductRequestRepository {
  /// `POST /product-requests` — [text] is whatever the customer pasted: a
  /// full or short AliExpress link, a whole share text, or a bare product
  /// id. The server finds the link itself.
  ///
  /// Sending the same product again returns the existing request.
  Future<Result<ProductRequest>> create(String text);

  /// `GET /product-requests` — newest first.
  Future<Result<Paginated<ProductRequest>>> list({int page, int size});

  /// `GET /product-requests/:id` — what the loader polls.
  Future<Result<ProductRequest>> byId(int id);
}
