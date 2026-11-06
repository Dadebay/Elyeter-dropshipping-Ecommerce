import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../brand/domain/entities/brand.dart';
import '../../../brand/domain/repositories/brand_repository.dart';
import '../../../product/domain/entities/product_query.dart';
import '../../../product/presentation/widgets/catalog_product_grid.dart';
import '../../../product/presentation/widgets/product_grid_shimmer.dart';
import '../../../search/presentation/widgets/search_reveal_transition.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../widgets/category_brand_sheet.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/category_products_empty.dart';
import '../widgets/category_price_filter_sheet.dart';
import '../widgets/category_sort_sheet.dart';
import '../widgets/category_search_button.dart';
import '../widgets/subcategory_grid.dart';
import '../widgets/subcategory_header.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key, required this.id, this.title});
  final String id;
  final String? title;

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  static const _brandFacetId = 'brand';

  Category? _category;
  Failure? _categoryFailure;
  bool _loadingCategory = true;
  ProductSort _sort = ProductSort.newest;
  num? _minPrice;
  num? _maxPrice;
  bool _onlyFeatured = false;
  List<Brand> _brands = const [];
  bool _brandsLoading = true;
  Set<String> _brandSlugs = const {};

  @override
  void initState() {
    super.initState();
    _loadCategory();
    _loadBrands();
  }

  @override
  void didUpdateWidget(CategoryDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _category = null;
      _loadingCategory = true;
      _brandSlugs = const {};
      _loadCategory();
    }
  }

  Future<void> _loadCategory() async {
    final routeId = widget.id;
    final repository = getIt<CategoryRepository>();
    setState(() {
      _loadingCategory = true;
      _categoryFailure = null;
    });
    final treeResult = await repository.tree();
    var category = _findCategory(treeResult.dataOrNull ?? const [], routeId);
    Failure? failure = treeResult.failureOrNull;
    final id = int.tryParse(routeId);
    if (category == null && id != null) {
      final detailResult = await repository.byId(id);
      category = detailResult.dataOrNull;
      failure = detailResult.failureOrNull ?? failure;
    }
    if (mounted && widget.id == routeId) {
      setState(() {
        _category = category;
        _categoryFailure = category == null
            ? failure ?? const NotFoundFailure()
            : null;
        _loadingCategory = false;
      });
    }
  }

  /// `GET /brands` is not paginated and not scoped to a category, so the
  /// list is fetched once. Without it the brand chip simply is not offered.
  Future<void> _loadBrands() async {
    final result = await getIt<BrandRepository>().list();
    if (!mounted) return;
    setState(() {
      _brands = result.dataOrNull ?? const [];
      _brandsLoading = false;
    });
  }

  ProductQuery _query() => ProductQuery(
    categoryId: _category?.id,
    sort: _sort,
    brandIds: [
      for (final brand in _brands)
        if (_brandSlugs.contains(brand.slug)) brand.id,
    ],
    minPrice: _minPrice,
    maxPrice: _maxPrice,
    onlyFeatured: _onlyFeatured,
  );

  List<CategoryFacet> _facets(BuildContext context) => [
    if (_brands.isNotEmpty)
      CategoryFacet(
        id: _brandFacetId,
        // The chosen brand names itself on the chip.
        label: _brandFacetLabel(context),
        selectedCount: _brandSlugs.length,
      ),
  ];

  /// One brand names itself on the chip; several are counted by its badge.
  String _brandFacetLabel(BuildContext context) {
    if (_brandSlugs.length == 1) {
      for (final brand in _brands) {
        if (brand.slug == _brandSlugs.single) return brand.name;
      }
    }
    return context.l10n.categoryFilterBrand;
  }

  Future<void> _chooseBrand() async {
    final picked = await CategoryBrandSheet.show(
      context,
      brands: _brands,
      selectedSlugs: _brandSlugs,
    );
    if (picked != null && mounted) setState(() => _brandSlugs = picked);
  }

  Category? _findCategory(List<Category> nodes, String routeId) {
    for (final node in nodes) {
      if (node.slug == routeId || node.id.toString() == routeId) return node;
      final child = _findCategory(node.children, routeId);
      if (child != null) return child;
    }
    return null;
  }

  bool get _filtersActive =>
      _brandSlugs.isNotEmpty ||
      _minPrice != null ||
      _maxPrice != null ||
      _onlyFeatured;

  Future<void> _chooseSort() async {
    final selected = await CategorySortSheet.show(context, current: _sort);
    if (selected != null && mounted) setState(() => _sort = selected);
  }

  Future<void> _chooseFilter() async {
    final selected = await CategoryPriceFilterSheet.show(
      context,
      min: _minPrice,
      max: _maxPrice,
      onlyFeatured: _onlyFeatured,
    );
    if (selected != null && mounted) {
      setState(() {
        _minPrice = selected.min;
        _maxPrice = selected.max;
        _onlyFeatured = selected.onlyFeatured;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _category;
    final allChildren = category?.children ?? const <Category>[];
    final children = allChildren.length == 5
        ? allChildren.sublist(0, 4)
        : allChildren;
    // The header has to know its height up front to collapse smoothly: the
    // grid's own, plus the padding around it below.
    final subcategoriesExtent =
        SubcategoryGrid.heightFor(
          context,
          width: MediaQuery.sizeOf(context).width - 2 * AppSpacing.page,
          itemCount: children.length,
        ) +
        AppSpacing.md +
        AppSpacing.lg;
    final subcategories = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.lg,
      ),
      child: SubcategoryGrid(
        items: [
          for (final child in children)
            SubcategoryItem(
              id: child.slug,
              name: child.name,
              imageUrl: child.imageLarge ?? child.imageSmall,
            ),
        ],
        onTap: (child) => context.pushNamed(
          AppRoutes.categoryDetail.name,
          pathParameters: {'id': child.id},
          extra: child.name,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        clipBehavior: Clip.none,
        leadingWidth: AppBackButton.leadingWidth,
        leading: const AppBackButton.appBarLeading(),
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          category?.name ?? widget.title ?? widget.id,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          CategorySearchButton(
            tooltip: context.l10n.categorySearch,
            onPressed: (bounds) => context.pushNamed(
              AppRoutes.search.name,
              extra: SearchButtonOrigin(bounds),
            ),
          ),
        ],
      ),
      body: _loadingCategory
          ? const ProductGridShimmer()
          : category == null
          ? AppErrorView(
              failure: _categoryFailure ?? const NotFoundFailure(),
              onRetry: _loadCategory,
            )
          // No glow, stretch or bounce on the page's own scrolling: they
          // act on the whole nested view, so every fling at the end of
          // the list made the pinned filter bar above it shudder.
          : ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                overscroll: false,
                physics: const ClampingScrollPhysics(),
              ),
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  if (children.isNotEmpty)
                    SliverPersistentHeader(
                      delegate: SubcategoryHeaderDelegate(
                        extent: subcategoriesExtent,
                        child: subcategories,
                      ),
                    ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _FilterHeaderDelegate(
                      onSort: _chooseSort,
                      onFilter: _chooseFilter,
                      sortActive: _sort != ProductSort.newest,
                      filterActive:
                          _minPrice != null ||
                          _maxPrice != null ||
                          _onlyFeatured,
                      facets: _facets(context),
                      facetsLoading: _brandsLoading,
                      onFacetTap: (_) => _chooseBrand(),
                    ),
                  ),
                ],
                body: CatalogProductGrid(
                  query: _query(),
                  pageSize: 10,
                  loadingState: const ProductGridShimmer(),
                  loadingMoreState: const ProductGridShimmer.more(),
                  emptyState: CategoryProductsEmpty(filtered: _filtersActive),
                ),
              ),
            ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate({
    required this.onSort,
    required this.onFilter,
    required this.onFacetTap,
    required this.facets,
    required this.sortActive,
    required this.filterActive,
    required this.facetsLoading,
  });

  final VoidCallback onSort;
  final VoidCallback onFilter;
  final ValueChanged<CategoryFacet> onFacetTap;
  final List<CategoryFacet> facets;
  final bool sortActive;
  final bool filterActive;
  final bool facetsLoading;

  @override
  double get minExtent => CategoryFilterBar.height + AppSpacing.xxl;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: CategoryFilterBar(
          facets: facets,
          loading: facetsLoading,
          onSort: onSort,
          onFilter: onFilter,
          onFacetTap: onFacetTap,
          sortActive: sortActive,
          filterActive: filterActive,
        ),
      ),
    );
  }

  @override
  // The chips' state lives in the page, so any rebuild of it may change them.
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => true;
}
