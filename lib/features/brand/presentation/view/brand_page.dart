import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/elyeter_shimmer.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../category/presentation/widgets/category_filter_bar.dart';
import '../../../category/presentation/widgets/category_price_filter_sheet.dart';
import '../../../category/presentation/widgets/category_products_empty.dart';
import '../../../category/presentation/widgets/category_search_button.dart';
import '../../../category/presentation/widgets/category_sort_sheet.dart';
import '../../../product/presentation/widgets/product_grid_shimmer.dart';
import '../../../product/domain/entities/product_query.dart';
import '../../../product/presentation/widgets/catalog_product_grid.dart';
import '../../../search/presentation/widgets/search_reveal_transition.dart';
import '../../domain/repositories/brand_repository.dart';

class BrandPage extends StatefulWidget {
  const BrandPage({super.key, required this.id, this.title});
  final String id;
  final String? title;

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  String? _name;
  ProductSort _sort = ProductSort.newest;
  num? _minPrice;
  num? _maxPrice;
  bool _onlyFeatured = false;

  bool get _filtersActive =>
      _minPrice != null || _maxPrice != null || _onlyFeatured;

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

  int? get _brandId => int.tryParse(widget.id);

  @override
  void initState() {
    super.initState();
    final id = _brandId;
    if (id != null) {
      getIt<BrandRepository>().byId(id).then((result) {
        if (mounted &&
            widget.id == id.toString() &&
            result.dataOrNull != null) {
          setState(() => _name = result.dataOrNull!.name);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      clipBehavior: Clip.none,
      leadingWidth: AppBackButton.leadingWidth,
      leading: const AppBackButton.appBarLeading(),
      titleSpacing: 0,
      centerTitle: true,
      // Until the brand's name arrives, the sweeping wordmark stands in
      // rather than the raw id.
      title: (_name ?? widget.title) == null
          ? const ElyeterShimmerText(size: 20)
          : Text(
              _name ?? widget.title!,
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
    body: _brandId != null
        ? Column(
            children: [
              // The brand is fixed by the page, so there is no brand chip:
              // just the price filter and the sort order.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: CategoryFilterBar(
                  facets: const [],
                  onFilter: _chooseFilter,
                  onSort: _chooseSort,
                  filterActive: _filtersActive,
                  sortActive: _sort != ProductSort.newest,
                ),
              ),
              Expanded(
                child: CatalogProductGrid(
                  query: ProductQuery(
                    brandId: _brandId!,
                    sort: _sort,
                    minPrice: _minPrice,
                    maxPrice: _maxPrice,
                    onlyFeatured: _onlyFeatured,
                  ),
                  pageSize: 10,
                  loadingState: const ProductGridShimmer(),
                  loadingMoreState: const ProductGridShimmer.more(),
                  emptyState: CategoryProductsEmpty(filtered: _filtersActive),
                ),
              ),
            ],
          )
        : const AppErrorView(failure: NotFoundFailure()),
  );
}
