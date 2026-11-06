import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // Aligns the glyph with the label's cap height rather than the
          // middle of a value that may run to three lines.
          padding: const EdgeInsets.only(top: 2),
          child: SvgPicture.asset(icon, width: 20, height: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.inkColor,
                  height: 1.4,
                ),
              ),
              if (secondary case final String line) ...[
                const SizedBox(height: 2),
                Text(
                  line,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                    height: 1.4,
                  ),
                ),
              ],
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
                  AppAssets.iconPencil,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
