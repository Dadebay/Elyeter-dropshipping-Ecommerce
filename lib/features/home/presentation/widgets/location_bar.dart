import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_icons.dart';

/// Delivery city + street line shown over the gradient.
class LocationBar extends StatelessWidget {
  const LocationBar({
    super.key,
    required this.city,
    required this.address,
    this.onTap,
  });

  final String city;
  final String address;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  AppAssets.iconMapPin,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  city,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: HugeIcon(
                    icon: AppIcons.chevronDown,
                    size: 18,
                    color: AppColors.white,
                  ),
                ),
                //  HugeIcon(icon: AppIcons.chevronDown, color: AppColors.white, size: 22),
              ],
            ),
            Text(
              address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
