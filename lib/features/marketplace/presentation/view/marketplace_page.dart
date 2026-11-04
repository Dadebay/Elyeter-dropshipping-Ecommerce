import 'package:flutter/material.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../product/domain/entities/product_query.dart';
import '../../../product/presentation/widgets/catalog_product_grid.dart';

/// One marketplace's storefront: its products, as the catalogue lists them.
class MarketplacePage extends StatelessWidget {
  const MarketplacePage({super.key, required this.id, this.title});

  /// The marketplace's numeric id from the route.
  final String id;

  /// Display name passed by the caller; falls back to [id].
  final String? title;

  @override
  Widget build(BuildContext context) {
    final marketplaceId = int.tryParse(id);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: AppBackButton.leadingWidth,
        leading: const AppBackButton.appBarLeading(),
        title: Text(title ?? id),
      ),
      body: marketplaceId == null
          ? const SizedBox.shrink()
          : CatalogProductGrid(
              query: ProductQuery(marketplaceId: marketplaceId),
            ),
    );
  }
}
