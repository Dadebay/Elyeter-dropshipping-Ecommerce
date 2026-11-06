import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_back_button.dart';

/// The floating controls over a product's photo: a round back button on one
/// side, share and favourite together in a pill on the other.
///
/// White on white needs a shadow rather than a border to read, which is what
/// the design does.
abstract final class ProductDetailActions {
  /// Height of every floating control, and the width of a square one.
  static const buttonSize = 44.0;

  static const iconSize = 22.0;

  /// Shared with [AppBackButton] so both sides of the photo lift the same.
  static const _shadow = AppBackButton.shadow;
}

/// Two actions sharing one white pill, as the design groups them.
class ProductActionPill extends StatelessWidget {
  const ProductActionPill({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ProductDetailActions.buttonSize,
      decoration: BoxDecoration(
        color: context.adapt(AppColors.white, AppColors.categoryDark),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: ProductDetailActions._shadow,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// One action inside [ProductActionPill].
class ProductPillButton extends StatelessWidget {
  const ProductPillButton({
    super.key,
    required this.asset,
    required this.onTap,
    this.tint,
    this.horizontalPadding = 0,
  });

  final String asset;
  final VoidCallback onTap;
  final Color? tint;

  /// Extra room on each side of the glyph, widening this half of the pill.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: ProductDetailActions.buttonSize + horizontalPadding * 2,
          height: ProductDetailActions.buttonSize,
          child: Center(
            child: _Icon(asset: asset, tint: tint),
          ),
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.asset, this.tint});

  final String asset;
  final Color? tint;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    asset,
    width: ProductDetailActions.iconSize,
    height: ProductDetailActions.iconSize,
    colorFilter: tint == null ? null : ColorFilter.mode(tint!, BlendMode.srcIn),
  );
}
