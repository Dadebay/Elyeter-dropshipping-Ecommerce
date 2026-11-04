import 'package:flutter/material.dart';

import '../../../product/presentation/widgets/product_card.dart';

/// How the list is ordered.
enum CategorySort { popular, priceAsc, priceDesc, discount }

/// One value a facet can take, e.g. the brand `Apple`.
class FacetValue {
  const FacetValue({required this.value, required this.count, this.swatch});

  final String value;

  /// How many products carry it — a filter that would empty the list says so
  /// before it is tapped.
  final int count;

  /// Drawn instead of a tick for a colour, where the value is the point.
  final Color? swatch;
}

/// A facet and everything it can be narrowed to.
class FacetDefinition {
  const FacetDefinition({
    required this.id,
    required this.label,
    required this.values,
    this.isSwatch = false,
  });

  final String id;
  final String label;
  final List<FacetValue> values;

  /// Lays the values out as swatches rather than as a list of rows.
  final bool isSwatch;
}

/// What the customer has narrowed the list to.
@immutable
class CategoryFilters {
  const CategoryFilters({
    this.values = const {},
    this.sort = CategorySort.popular,
  });

  /// Facet id to the values picked under it. A facet absent from the map, or
  /// present with an empty set, is not narrowing anything.
  final Map<String, Set<String>> values;

  final CategorySort sort;

  bool get isEmpty => values.values.every((set) => set.isEmpty);

  /// How many values are picked under [facetId] — what the chip's badge
  /// counts.
  int countFor(String facetId) => values[facetId]?.length ?? 0;

  Set<String> selected(String facetId) => values[facetId] ?? const {};

  /// Every picked value across every facet.
  int get totalSelected =>
      values.values.fold(0, (sum, set) => sum + set.length);

  CategoryFilters withFacet(String facetId, Set<String> picked) {
    final next = Map<String, Set<String>>.of(values);
    // Dropping an emptied facet rather than storing a blank set keeps
    // [isEmpty] honest without having to look inside every entry.
    if (picked.isEmpty) {
      next.remove(facetId);
    } else {
      next[facetId] = picked;
    }
    return CategoryFilters(values: next, sort: sort);
  }

  CategoryFilters withSort(CategorySort next) =>
      CategoryFilters(values: values, sort: next);

  /// Clears the facets and leaves the ordering alone — resetting a filter
  /// should not also throw away how the customer wanted the list arranged.
  CategoryFilters get cleared => CategoryFilters(sort: sort);

  /// The products that match, in the order asked for.
  List<ProductCardData> apply(List<ProductCardData> products) {
    final matched = products.where((product) {
      for (final entry in values.entries) {
        if (entry.value.isEmpty) continue;
        final held = product.attributes[entry.key];
        if (held == null || !entry.value.contains(held)) return false;
      }
      return true;
    }).toList();

    switch (sort) {
      case CategorySort.popular:
        // The supplied order is the merchandised one; nothing to do.
        break;
      case CategorySort.priceAsc:
        matched.sort((a, b) => a.price.compareTo(b.price));
      case CategorySort.priceDesc:
        matched.sort((a, b) => b.price.compareTo(a.price));
      case CategorySort.discount:
        matched.sort(
          (a, b) => (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0),
        );
    }

    return matched;
  }
}

/// Builds the facets out of what the products actually carry, so a filter can
/// never offer a value that would empty the list.
abstract final class CategoryFacets {
  /// Colours the app knows how to draw. A value with no entry here still
  /// appears, as a plain row rather than a swatch.
  static const _swatches = {
    'Black': Color(0xFF1A1A1A),
    'White': Color(0xFFFFFFFF),
    'Silver': Color(0xFFD9DCE1),
    'Blue': Color(0xFF3A6FF0),
    'Green': Color(0xFF3FAE6A),
    'Pink': Color(0xFFF2A0C0),
    'Orange': Color(0xFFFF6B35),
  };

  static List<FacetDefinition> of(
    List<ProductCardData> products, {
    required String brandLabel,
    required String materialLabel,
    required String colorLabel,
  }) => [
    _build('brand', brandLabel, products),
    _build('material', materialLabel, products),
    _build('color', colorLabel, products, isSwatch: true),
  ].where((facet) => facet.values.isNotEmpty).toList();

  static FacetDefinition _build(
    String id,
    String label,
    List<ProductCardData> products, {
    bool isSwatch = false,
  }) {
    final counts = <String, int>{};
    for (final product in products) {
      final value = product.attributes[id];
      if (value != null) counts[value] = (counts[value] ?? 0) + 1;
    }

    final values = counts.keys.toList()..sort();

    return FacetDefinition(
      id: id,
      label: label,
      isSwatch: isSwatch,
      values: [
        for (final value in values)
          FacetValue(
            value: value,
            count: counts[value]!,
            swatch: isSwatch ? _swatches[value] : null,
          ),
      ],
    );
  }

  /// A light colour needs an outline, or a white swatch is invisible on a
  /// white sheet.
  static bool needsOutline(Color color) => color.computeLuminance() > 0.8;
}

/// What each ordering is called.
extension CategorySortX on CategorySort {
  String labelIn({
    required String popular,
    required String priceAsc,
    required String priceDesc,
    required String discount,
  }) => switch (this) {
    CategorySort.popular => popular,
    CategorySort.priceAsc => priceAsc,
    CategorySort.priceDesc => priceDesc,
    CategorySort.discount => discount,
  };
}
