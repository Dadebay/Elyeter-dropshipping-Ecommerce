import '../widgets/product_card.dart';

/// One customer review, as the detail page's review strip shows it.
class ProductReview {
  const ProductReview({
    required this.author,
    required this.date,
    required this.rating,
    required this.text,
    this.id = 0,
    this.images = const [],
    this.likes = 0,
    this.liked = false,
    this.isMine = false,
  });

  final int id;
  final String author;
  final String date;
  final double rating;
  final String text;
  final List<String> images;
  final int likes;

  /// Whether the signed-in customer marked it helpful.
  final bool liked;
  final bool isMine;
}

/// Everything the detail page shows beyond what a catalog card carries.
///
/// Swap for the real entity once the product API lands — only this type
/// changes, not the layout.
class ProductDetailData {
  const ProductDetailData({
    required this.product,
    required this.rating,
    required this.reviewCount,
    required this.orderCount,
    required this.ratingCount,
    required this.colorName,
    required this.sizes,
    required this.article,
    required this.description,
    required this.characteristics,
    required this.reviews,
    this.ratingBreakdown = const [],
  });

  final ProductCardData product;

  final double rating;
  final int reviewCount;
  final int orderCount;
  final int ratingCount;

  /// The colourway on offer; the swatches are [ProductCardData.images].
  final String colorName;

  /// Sizes, in the order the chips run. The first is preselected.
  final List<String> sizes;

  final String article;
  final String description;

  /// Label -> value, in the order the design lists them.
  final Map<String, String> characteristics;

  final List<ProductReview> reviews;

  /// Share of ratings per star, 5 first. Empty means no bars are drawn.
  final List<double> ratingBreakdown;
}
