import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_back_button.dart';

/// The category page's search control: the back button's twin at the other
/// end of the bar — same wide pill, size and faint lift — with
/// a magnifier in place of the chevron.
class CategorySearchButton extends StatelessWidget {
  const CategorySearchButton({
    super.key,
    required this.onPressed,
    this.tooltip,
  });

  final ValueChanged<Rect> onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.page),
      child: Align(
        alignment: Alignment.centerRight,
        child: Semantics(
          button: true,
          label: tooltip,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: isDark ? Border.all(color: AppColors.grey700) : null,
              boxShadow: isDark ? null : AppBackButton.shadow,
            ),
            child: Material(
              color: Colors.transparent,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: Builder(
                builder: (buttonContext) => InkWell(
                  onTap: () {
                    final box = buttonContext.findRenderObject() as RenderBox;
                    onPressed(box.localToGlobal(Offset.zero) & box.size);
                  },
                  child: SizedBox(
                    width: AppBackButton.appBarWidth,
                    height: AppBackButton.appBarHeight,
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.iconSearchMagnifier,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          isDark ? AppColors.white : AppColors.ink,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
