import '../../../../core/utils/result.dart';
import '../entities/image_search.dart';

/// Search the catalogue by photo. Every call needs a signed-in customer.
abstract interface class ImageSearchRepository {
  /// `POST /image-search` — a JPEG, PNG or WebP up to 5 MB.
  Future<Result<ImageSearch>> create(String path);

  /// `GET /image-search/:id` — polled while the status is processing.
  Future<Result<ImageSearch>> byId(int id);
}
