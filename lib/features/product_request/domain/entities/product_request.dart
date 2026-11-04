import 'package:equatable/equatable.dart';

import '../../../product/domain/entities/product.dart';

/// Where a product sent in by link stands.
enum ProductRequestStatus {
  /// The backend is still loading it from AliExpress — usually 10–60 s.
  processing('PROCESSING'),

  /// In the catalog; [ProductRequest.product] is filled.
  available('AVAILABLE'),

  /// Waiting for a moderator. A push arrives when it becomes available.
  inReview('IN_REVIEW'),
  rejected('REJECTED'),

  /// AliExpress did not return the product (removed or unavailable).
  failed('FAILED');

  const ProductRequestStatus(this.value);

  final String value;

  static ProductRequestStatus parse(String? value) =>
      ProductRequestStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => ProductRequestStatus.processing,
      );

  /// Whether the status can still change without the customer doing
  /// anything — the cases worth polling or waiting for a push on.
  bool get isPending => this == processing || this == inReview;
}

/// An AliExpress link the customer asked us to add to the catalog.
class ProductRequest extends Equatable {
  const ProductRequest({
    required this.id,
    required this.url,
    required this.status,
    this.product,
    this.createdAt,
    this.updatedAt,
  });

  final int id;

  /// Exactly what was sent — possibly a whole share text.
  final String url;
  final ProductRequestStatus status;

  /// Only set when [status] is [ProductRequestStatus.available].
  final Product? product;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, url, status, product, createdAt, updatedAt];
}
