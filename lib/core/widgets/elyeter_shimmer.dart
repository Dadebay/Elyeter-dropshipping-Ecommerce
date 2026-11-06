import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Placeholder tile shown while content loads: the brand wordmark, greyed
/// out and sweeping, instead of an empty grey rectangle.
class ElyeterShimmerBox extends StatelessWidget {
  const ElyeterShimmerBox({
    super.key,
    this.radius = AppRadius.lg,
    this.wordmarkSize = 18,
  });

  final double radius;
  final double wordmarkSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? AppColors.categoryDark : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ElyeterShimmerText(size: wordmarkSize),
    );
  }
}

/// The sweeping wordmark on its own, for placeholders that bring their own
/// background.
class ElyeterShimmerText extends StatelessWidget {
  const ElyeterShimmerText({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.grey700 : AppColors.textDisabled,
      highlightColor: isDark ? AppColors.grey500 : AppColors.white,
      period: const Duration(milliseconds: 1400),
      child: Text(
        'elýeter',
        // Design spec: Qurova Medium 18, letter spacing 0,
        // `text/disabled-300`.
        style: TextStyle(
          fontFamily: AppTypography.wordmarkFontFamily,
          fontSize: size,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          // Shimmer paints over this; the colour only has to be opaque.
          color: AppColors.textDisabled,
        ),
      ),
    );
  }
}
