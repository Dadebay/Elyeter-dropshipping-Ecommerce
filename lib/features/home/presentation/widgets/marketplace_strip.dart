import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../marketplace/domain/entities/marketplace.dart';

/// One partner marketplace tile (AliExpress, Taobao, …).
class MarketplaceItem {
  const MarketplaceItem({
    required this.id,
    required this.name,
    this.logoUrl,
    this.logoAsset,
  });

  /// Route slug — see `AppRoutes.marketplace`.
  final String id;

  final String name;
  final String? logoUrl;
  final String? logoAsset;

  /// A marketplace from the API; its logo is bundled by `code`, and a code
  /// without artwork shows its name.
  factory MarketplaceItem.fromMarketplace(Marketplace m) => MarketplaceItem(
    id: m.id.toString(),
    name: m.name,
    logoAsset: switch (m.code) {
      'aliexpress' => AppAssets.marketAliexpress,
      'alibaba' => AppAssets.marketAlibaba,
      'taobao' => AppAssets.marketTaobao,
      '1688' => AppAssets.market1688,
      _ => null,
    },
  );

  /// The partners the home strip shows, in the design's order.
  static const partners = [
    MarketplaceItem(
      id: 'aliexpress',
      name: 'AliExpress',
      logoAsset: AppAssets.marketAliexpress,
    ),
    MarketplaceItem(
      id: 'alibaba',
      name: 'Alibaba',
      logoAsset: AppAssets.marketAlibaba,
    ),
    MarketplaceItem(
      id: 'taobao',
      name: 'Taobao',
      logoAsset: AppAssets.marketTaobao,
    ),
    MarketplaceItem(id: '1688', name: '1688', logoAsset: AppAssets.market1688),
  ];
}

/// Horizontally scrolling row of partner marketplaces under the logo.
class MarketplaceStrip extends StatelessWidget {
  const MarketplaceStrip({
    super.key,
    required this.items,
    this.onTap,
    this.selectedId,
    this.height = 64,
  });

  final List<MarketplaceItem> items;
  final ValueChanged<MarketplaceItem>? onTap;
  final String? selectedId;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => _MarketplaceCard(
          item: items[index],
          selected: items[index].id == selectedId,
          onTap: onTap == null ? null : () => onTap!(items[index]),
        ),
      ),
    );
  }
}

class _MarketplaceCard extends StatelessWidget {
  const _MarketplaceCard({
    required this.item,
    this.onTap,
    this.selected = false,
  });

  final MarketplaceItem item;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 104,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: switch (item) {
          MarketplaceItem(:final logoAsset?) => AppAssetImage(logoAsset),
          MarketplaceItem(:final logoUrl?) => AppNetworkImage(
            url: logoUrl,
            radius: 0,
          ),
          // Until a logo asset lands, the name keeps the layout honest.
          _ => Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        },
      ),
    );
  }
}
