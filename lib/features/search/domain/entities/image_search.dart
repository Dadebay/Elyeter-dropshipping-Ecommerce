import 'package:equatable/equatable.dart';

import '../../../product/domain/entities/product.dart';

/// Where a photo search stands. `PROCESSING` keeps filling `products`.
enum ImageSearchStatus {
  processing,

  /// Everything automatic is done; a moderator checks the rest.
  inReview,
  done,
  failed;

  static ImageSearchStatus parse(String? raw) => switch (raw) {
    'IN_REVIEW' => inReview,
    'DONE' => done,
    'FAILED' => failed,
    _ => processing,
  };
}

/// `POST /image-search` and `GET /image-search/:id`.
class ImageSearch extends Equatable {
  const ImageSearch({
    required this.id,
    required this.status,
    required this.foundCount,
    required this.products,
    this.image,
    this.waitingCount = 0,
  });

  final int id;
  final ImageSearchStatus status;

  /// How many look-alikes the marketplace found; usually more than
  /// [products], as some are still loading or awaiting moderation.
  final int foundCount;

  /// The customer's photo, for lists of past searches. May be null.
  final String? image;

  /// Products a moderator is still checking.
  final int waitingCount;

  /// Most similar first, all already on the storefront.
  final List<Product> products;

  @override
  List<Object?> get props => [
    id,
    status,
    foundCount,
    products,
    image,
    waitingCount,
  ];
}
