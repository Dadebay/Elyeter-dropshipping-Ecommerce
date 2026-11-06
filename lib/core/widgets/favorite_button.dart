import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../theme/app_spacing.dart';

/// The heart that sits over a product photo, filled once the product is in
/// the customer's favourites.
///
/// Shared so the catalog card and the cart line draw the same control — the
/// same product reads the same wherever it is listed.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.active, this.onTap});

  static const _size = 26.0;

  /// Transparent padding around the artwork, so the tap target stays finger
  /// sized without a visible chip behind the icon.
  static const _target = 36.0;

  /// Inset a photo should give the button when positioning it in a corner.
  static const cornerInset = AppSpacing.xs;

  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark
        ? (active
              ? AppAssets.iconFavoriteFullDark
              : AppAssets.iconFavoriteEmptyDark)
        : (active ? AppAssets.iconFavoriteFull : AppAssets.iconFavoriteEmpty);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _target,
        height: _target,
        child: Center(
          child: SvgPicture.asset(asset, width: _size, height: _size),
        ),
      ),
    );
  }
}
