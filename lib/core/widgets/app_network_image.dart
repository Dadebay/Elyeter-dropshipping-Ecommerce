import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../constants/app_icons.dart';
import 'elyeter_shimmer.dart';

/// Cached product image with a shimmer placeholder and a safe fallback.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.radius = AppRadius.md,
    this.fallbackIconSize,
    this.fallbackColor,
    this.onLoadFailed,
    this.wordmarkPlaceholder = false,
    this.wordmarkSize = 18,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Which part of the image survives when [fit] has to crop.
  final Alignment alignment;

  final double radius;

  /// Size of the glyph shown when there is no image. Null lets the icon
  /// take the package default.
  final double? fallbackIconSize;

  /// Defaults to the theme's muted fill (dark: #262626).
  final Color? fallbackColor;
  final VoidCallback? onLoadFailed;

  /// While the image loads, show the sweeping "elýeter" wordmark instead of a
  /// plain grey sweep. Worth it on a large photo, where an empty grey block
  /// would be the first thing on screen.
  final bool wordmarkPlaceholder;
  final double wordmarkSize;

  @override
  Widget build(BuildContext context) {
    final child = url == null || url!.isEmpty
        ? _fallback(context)
        : CachedNetworkImage(
            imageUrl: url!,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            placeholder: (_, _) => wordmarkPlaceholder
                ? ElyeterShimmerBox(radius: 0, wordmarkSize: wordmarkSize)
                : _shimmer(context),
            errorWidget: (_, _, _) {
              if (onLoadFailed != null) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => onLoadFailed!(),
                );
              }
              return _fallback(context);
            },
          );

    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }

  Widget _shimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.categoryDark : AppColors.grey100;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: isDark ? const Color(0xFF3A3A3A) : AppColors.white,
      child: Container(width: width, height: height, color: base),
    );
  }

  Widget _fallback(BuildContext context) => Container(
    width: width,
    height: height,
    color:
        fallbackColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.categoryDark
            : AppColors.grey100),
    // Without a size the glyph keeps filling its box, as it always has;
    // with one it is drawn at that size in the middle.
    child: fallbackIconSize == null
        ? const HugeIcon(icon: AppIcons.image, color: AppColors.grey500)
        : Center(
            child: HugeIcon(
              icon: AppIcons.image,
              size: fallbackIconSize!,
              color: AppColors.grey500,
            ),
          ),
  );
}
