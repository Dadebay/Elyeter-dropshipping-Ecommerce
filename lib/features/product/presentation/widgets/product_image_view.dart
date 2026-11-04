import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';

/// Product artwork may be a bundled placeholder or a URL from the API.
class ProductImageView extends StatelessWidget {
  const ProductImageView({
    super.key,
    required this.source,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.wordmarkPlaceholder = false,
    this.wordmarkSize = 24,
    this.fallbackIconSize,
    this.fallbackColor = AppColors.grey100,
  });

  final String source;
  final BoxFit fit;

  /// Which part of the photo survives when [fit] has to crop.
  final Alignment alignment;

  /// Shows the sweeping brand wordmark while a remote photo loads.
  final bool wordmarkPlaceholder;

  /// Size of the wordmark in that placeholder; smaller for a small tile.
  final double wordmarkSize;

  /// Size of the glyph drawn when the photo is missing or fails to load.
  /// Null keeps the glyph filling its box.
  final double? fallbackIconSize;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) => source.startsWith('assets/')
      ? Image.asset(source, fit: fit, alignment: alignment)
      : AppNetworkImage(
          url: source,
          fit: fit,
          alignment: alignment,
          radius: 0,
          wordmarkPlaceholder: wordmarkPlaceholder,
          wordmarkSize: wordmarkSize,
          fallbackIconSize: fallbackIconSize,
          fallbackColor: fallbackColor,
        );
}
