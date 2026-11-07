import 'package:equatable/equatable.dart';

/// One cart line as the two pre-order endpoints take it. Identical for
/// `/check` and checkout.
class PreOrderLine extends Equatable {
  const PreOrderLine({
    required this.productId,
    required this.quantity,
    this.variantId,
    this.price,
  });

  final int productId;

  /// Required when the product has `has_variants: true`, and must belong to
  /// that product — otherwise the API answers 400 `variant-required`.
  final int? variantId;

  /// 1 to 99.
  final int quantity;

  /// Unit price the customer sees in the cart. Sent so the server can show an
  /// honest "was / now" when the supplier's price has moved. Optional.
  final num? price;

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    if (variantId != null) 'variant_id': variantId,
    'quantity': quantity,
    'price': ?price,
  };

  @override
  List<Object?> get props => [productId, variantId, quantity, price];
}
