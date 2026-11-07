import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// One fact about the order: what it is, then what it says.
///
/// The label sits above the value rather than beside it, so an address or a
/// long payment method has the full width to wrap into.
class OrderInfoRow extends StatelessWidget {
  const OrderInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.secondary,
    this.onEdit,
  });

  /// Path to an SVG in `assets/icons`. The artwork carries the design's own
  /// grey, so it is drawn untinted.
  final String icon;

  final String label;

  /// The fact itself — set in the heavier weight, since it is what the row
  /// exists to say.
  final String value;

  /// An aside under the value, such as a phone number under a name. Grey, so
  /// the value keeps the emphasis.
  final String? secondary;

  /// Adds a pencil at the end — only the rows the customer may still change
  /// carry one.
  final VoidCallback? onEdit;

  /// Figma: rows of 14 px above and below, 16 px in from the card edge, a
  /// 24 px glyph, 12 px to the text. Label Inter Medium 14 / 20 (-2%) in
  /// #A3A3A3, value Inter Display SemiBold 16 / 24 in #14151A, aside Inter
  /// Display SemiBold 14 / 20 in #5C5C5C.
  static const _vertical = 14.0;
  static const _horizontal = AppSpacing.lg;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final theme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _vertical,
        horizontal: _horizontal,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // The glyph sits centred on the label and the first line of the
            // value together (20 + 2 + 24 px), however long the value runs.
            padding: const EdgeInsets.only(top: 8),
            child: SvgPicture.asset(icon, width: _iconSize, height: _iconSize),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  // Inter Medium, -2% spacing, #A3A3A3. Figma sets it at 14; a
                  // touch smaller here, on the same 20 px line so the row's
                  // spacing and the icon alignment do not move.
                  style: theme.bodyMedium?.copyWith(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    height: 20 / 12.5,
                    fontWeight: FontWeight.w500,
                    fontVariations: const [FontVariation('wght', 500)],
                    letterSpacing: -12.5 * 0.02,
                    color: AppColors.iconSoft,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  // Figma: Inter Display SemiBold 16 / 24, spacing 0, #14151A.
                  style: theme.bodyMedium?.copyWith(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    color: isDark ? AppColors.white : const Color(0xFF14151A),
                  ),
                ),
                if (secondary case final String line)
                  Text(
                    line,
                    // Figma: Inter Display SemiBold 14 / 20, spacing 0, #5C5C5C.
                    style: theme.bodyMedium?.copyWith(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      color: isDark
                          ? AppColors.grey300
                          : const Color(0xFF5C5C5C),
                    ),
                  ),
              ],
            ),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: AppSpacing.sm),
            // Centred on the row rather than pinned to its first line, so it
            // does not ride high beside a two-line address.
            Center(
              widthFactor: 1,
              child: GestureDetector(
                onTap: onEdit,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: SvgPicture.asset(
                    AppAssets.iconEdit,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
