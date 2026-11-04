import 'package:equatable/equatable.dart';

/// A marketplace the storefront draws products from, as `GET /marketplaces`
/// returns it.
class Marketplace extends Equatable {
  const Marketplace({
    required this.id,
    required this.code,
    required this.name,
    this.currency,
    this.productsCount = 0,
    this.productRequest = false,
    this.imageSearch = false,
  });

  /// What `GET /products?marketplace_id=` takes.
  final int id;
  final String code;
  final String name;
  final String? currency;

  /// Products on the storefront; a marketplace with none is not shown.
  final int productsCount;

  /// `features.product_request`: offer "product by link".
  final bool productRequest;

  /// `features.image_search`: offer "search by photo".
  final bool imageSearch;

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    currency,
    productsCount,
    productRequest,
    imageSearch,
  ];
}
