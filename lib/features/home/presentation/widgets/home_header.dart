import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'category_strip.dart';
import 'home_section_shimmer.dart';
import 'home_search_field.dart';
import 'location_bar.dart';
import 'marketplace_strip.dart';

/// Gradient hero at the top of the home page: logo, partner marketplaces,
/// delivery address, search and the category shortcuts.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.marketplaces,
    required this.categories,
    this.categoriesLoading = false,
    required this.city,
    required this.address,
    this.onCategoryTap,
    this.onLocationTap,
    this.onMarketplaceTap,
    this.showCamera = true,
    this.backgroundUrl,
    this.selectedMarketplaceId,
  });

  /// Smallest share of the screen the gradient covers (two sixths). It grows
  /// past this when the content needs more room — on a short screen the
  /// category row must still sit inside the gradient, as in the design.
  static const minHeightFraction = 2 / 6;

  // Temporarily hidden on Home; enable these to restore the existing controls.
  static const showLocation = false;

  static const _logoHeight = 24.0;

  /// Below this the status bar cannot hold the logo (no inset at all, or a
  /// desktop/tablet window), so it moves into the content column.
  static const _minStatusBar = 20.0;

  final List<MarketplaceItem> marketplaces;
  final List<CategoryItem> categories;
  final bool categoriesLoading;
  final String city;
  final String address;
  final ValueChanged<CategoryItem>? onCategoryTap;

  /// Opens the delivery-address picker; see `LocationPickerDialog`.
  final VoidCallback? onLocationTap;

  /// Opens a partner marketplace; see `MarketplacePage`.
  final ValueChanged<MarketplaceItem>? onMarketplaceTap;

  /// Id of the marketplace whose products are showing, if one was picked.
  final String? selectedMarketplaceId;

  /// Background picture set from the admin; null keeps the bundled one.
  final String? backgroundUrl;

  /// The photo-search button in the search field.
  final bool showCamera;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    // A single store needs no switcher.
    final showMarketplaces = marketplaces.length > 1;
    final minHeight = showMarketplaces || showLocation
        ? MediaQuery.sizeOf(context).height * minHeightFraction
        : 0.0;

    return ConstrainedBox(
      // Content decides the height; the fraction is only a floor.
      constraints: BoxConstraints(minHeight: minHeight + topInset),
      child: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // The bundled artwork stays underneath: it shows while the
                // picture from the server loads, and if it never does.
                Image.asset(
                  AppAssets.homeBackground,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                if (backgroundUrl != null)
                  CachedNetworkImage(
                    imageUrl: backgroundUrl!,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    fadeInDuration: const Duration(milliseconds: 250),
                    placeholder: (_, _) => const SizedBox.shrink(),
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
              ],
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Room for the logo when the status bar is too short to hold it.
                if (topInset < _minStatusBar)
                  const SizedBox(height: _logoHeight + 8),
                const SizedBox(height: AppSpacing.lg),
                if (showMarketplaces) ...[
                  MarketplaceStrip(
                    items: marketplaces,
                    onTap: onMarketplaceTap,
                    selectedId: selectedMarketplaceId,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (showLocation) ...[
                  LocationBar(
                    city: city,
                    address: address,
                    onTap: onLocationTap,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: HomeSearchField(showCamera: showCamera),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Categories live on the gradient, so their labels are white.
                categoriesLoading
                    ? const CategoryStripShimmer()
                    : CategoryStrip(
                        items: categories,
                        onTap: onCategoryTap,
                        labelColor: AppColors.white,
                      ),
                // Clearance for the sheet lip that overlaps the gradient.
                const SizedBox(height: _SheetTop.height),
              ],
            ),
          ),
          // The page's content sheet starts here, curving over the gradient.
          const Positioned(left: 0, right: 0, bottom: 0, child: _SheetTop()),
        ],
      ),
    );
  }
}

/// The rounded lip of the scrolling content, drawn on top of the gradient so
/// its corners reveal the artwork rather than a flat background.
class _SheetTop extends StatelessWidget {
  const _SheetTop();

  static const height = AppRadius.xl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height - 4,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
      ),
    );
  }
}

/// Fallback tint shown while the background image decodes.
class HeaderGradientFallback extends StatelessWidget {
  const HeaderGradientFallback({super.key});

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
    ),
  );
}
