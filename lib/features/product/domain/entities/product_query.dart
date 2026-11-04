import 'package:equatable/equatable.dart';

/// How `GET /products` may be ordered.
enum ProductSort {
  newest('new'),
  priceAsc('price_asc'),
  priceDesc('price_desc'),
  popular('popular');

  const ProductSort(this.value);

  final String value;
}

/// Every query parameter `GET /products` accepts.
///
/// Only the fields that are set are sent: the API rejects unknown or empty
/// query params rather than ignoring them.
class ProductQuery extends Equatable {
  const ProductQuery({
    this.categoryId,
    this.brandId,
    this.brandIds = const [],
    this.marketplaceId,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.onlyFeatured = false,
    this.sort = ProductSort.newest,
  });

  /// A category id matches that category **and all descendants**.
  final int? categoryId;

  final int? brandId;

  /// The API accepts one `brand_id` per request. The data source splits a
  /// selection of several brands into separate requests and merges them.
  final List<int> brandIds;

  /// Only products from this marketplace (`marketplace_id`).
  final int? marketplaceId;

  /// Every selected brand id, without repeats.
  List<int> get allBrandIds => {?brandId, ...brandIds}.toList();

  /// This query narrowed to the one brand [id] — what a single request
  /// can actually say.
  ProductQuery forBrand(int id) => ProductQuery(
    categoryId: categoryId,
    brandId: id,
    marketplaceId: marketplaceId,
    search: search,
    minPrice: minPrice,
    maxPrice: maxPrice,
    onlyFeatured: onlyFeatured,
    sort: sort,
  );

  /// Matches product name (both languages) and SKU.
  final String? search;

  final num? minPrice;
  final num? maxPrice;

  /// Featured products only — what the home screen shows.
  final bool onlyFeatured;

  final ProductSort sort;

  Map<String, dynamic> toQueryParameters({
    required int page,
    required int size,
  }) => {
    'page': page,
    'size': size,
    'sort': sort.value,
    if (categoryId != null) 'category_id': categoryId,
    if (marketplaceId != null) 'marketplace_id': marketplaceId,
    if (allBrandIds.length == 1) 'brand_id': allBrandIds.single,
    if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
    if (minPrice != null) 'min_price': minPrice,
    if (maxPrice != null) 'max_price': maxPrice,
    // Only ever sent as `true`; the API has no "false" case for it.
    if (onlyFeatured) 'only_featured': true,
  };

  ProductQuery copyWith({
    int? categoryId,
    int? brandId,
    List<int>? brandIds,
    int? marketplaceId,
    String? search,
    num? minPrice,
    num? maxPrice,
    bool? onlyFeatured,
    ProductSort? sort,
    bool clearPrices = false,
    bool clearSearch = false,
  }) => ProductQuery(
    categoryId: categoryId ?? this.categoryId,
    brandId: brandId ?? this.brandId,
    brandIds: brandIds ?? this.brandIds,
    marketplaceId: marketplaceId ?? this.marketplaceId,
    search: clearSearch ? null : (search ?? this.search),
    minPrice: clearPrices ? null : (minPrice ?? this.minPrice),
    maxPrice: clearPrices ? null : (maxPrice ?? this.maxPrice),
    onlyFeatured: onlyFeatured ?? this.onlyFeatured,
    sort: sort ?? this.sort,
  );

  @override
  List<Object?> get props => [
    categoryId,
    brandId,
    brandIds,
    marketplaceId,
    search,
    minPrice,
    maxPrice,
    onlyFeatured,
    sort,
  ];
}
