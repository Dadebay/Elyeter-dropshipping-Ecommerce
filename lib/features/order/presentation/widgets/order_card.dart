import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/constants/app_icons.dart';

/// The white block the order page groups each section into. The page behind
/// is soft grey, so the blocks are what the eye separates.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.categoryDark : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        // Flat white on a soft grey page reads as a lighter patch of the
        // same surface; the shadow is what makes it a card sitting on top.
        boxShadow: context.isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}

/// A section heading inside an [OrderCard], with an optional chevron that
/// opens the fuller view of what it heads.
class OrderCardHeader extends StatelessWidget {
  const OrderCardHeader({super.key, required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.titleSmall?.copyWith(
        color: context.adapt(AppColors.grey700, AppColors.iconSoft),
      ),
    );

    if (onTap == null) return label;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(child: label),
          const HugeIcon(
            icon: AppIcons.chevronRight,
            size: 20,
            color: AppColors.grey500,
          ),
        ],
      ),
    );
  }
}
