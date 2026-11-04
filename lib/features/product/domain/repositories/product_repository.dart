import '../../../../core/network/api_response.dart';
import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../entities/product_detail.dart';
import '../entities/product_query.dart';
import '../entities/product_reviews.dart';
import '../entities/product_variant.dart';

abstract interface class ProductRepository {
  /// `GET /products` — both `page` and `size` are required by the API.
  Future<Result<Paginated<Product>>> list({
    required ProductQuery query,
    int page,
    int size,
  });

  /// `GET /products/:id`
  Future<Result<ProductDetail>> byId(int id);

  /// `GET /products/:id/variants` — numeric product ID.
  Future<Result<List<ProductVariant>>> variants(int productId);

  /// Public summary and paged reviews. With a session, includes my review.
  Future<Result<ProductReviews>> reviews(
    int productId, {
    int page,
    int size,
    int? rating,
    ReviewSortOption sort,
  });

  /// Authenticated customer creates or replaces their one review.
  Future<Result<bool>> saveReview(
    int productId, {
    required int rating,
    String? comment,
    List<String>? images,
  });

  Future<Result<bool>> deleteMyReview(int productId);

  /// `POST /reviews/images` — uploads one photo from [path].
  Future<Result<ProductReviewImage>> uploadReviewImage(String path);

  /// Likes or dislikes another customer's review; [reaction] is
  /// `like` or `dislike`.
  Future<Result<ReviewReactionResult>> reactToReview(
    int productId,
    int reviewId,
    String reaction,
  );

  Future<Result<ReviewReactionResult>> removeReviewReaction(
    int productId,
    int reviewId,
  );
}
