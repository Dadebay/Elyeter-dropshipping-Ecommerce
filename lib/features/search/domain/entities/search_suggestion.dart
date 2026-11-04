import 'package:equatable/equatable.dart';

/// One product row of `GET /search/suggest`. Deliberately thinner than a
/// catalog [Product] — the endpoint only returns these four fields.
class ProductSuggestion extends Equatable {
  const ProductSuggestion({
    required this.id,
    required this.slug,
    required this.name,
    required this.price,
    this.mainImage,
  });

  final int id;
  final String slug;
  final String name;
  final num price;
  final String? mainImage;

  @override
  List<Object?> get props => [id, slug, name, price, mainImage];
}

/// One category row of `GET /search/suggest`.
class CategorySuggestion extends Equatable {
  const CategorySuggestion({
    required this.id,
    required this.slug,
    required this.name,
  });

  final int id;
  final String slug;
  final String name;

  @override
  List<Object?> get props => [id, slug, name];
}

/// The whole type-ahead answer.
class SearchSuggestions extends Equatable {
  const SearchSuggestions({
    this.products = const [],
    this.categories = const [],
  });

  static const empty = SearchSuggestions();

  final List<ProductSuggestion> products;
  final List<CategorySuggestion> categories;

  bool get isEmpty => products.isEmpty && categories.isEmpty;

  @override
  List<Object?> get props => [products, categories];
}
