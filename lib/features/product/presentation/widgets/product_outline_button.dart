import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// The quiet full-width action the detail page repeats: a white card lifted
/// off the grey block by soft shadows rather than outlined.
///
/// Figma: height 40, radius 12, padding 10 / 12, two drop shadows in
/// #0E121B (3.14% blur 4, and 5.88% y 6 blur 10).
class ProductOutlineButton extends StatelessWidget {
  const ProductOutlineButton({
    super.key,
    required this.label,
    this.onTap,
    this.height = 40,
  });

  final String label;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        // Dark mode: a faint white glow, so the edge still reads on the card.
        boxShadow: context.isDark
            ? const [
                BoxShadow(color: Color(0x14FFFFFF), blurRadius: 4),
                BoxShadow(
                  color: Color(0x1FFFFFFF),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ]
            : const [
                BoxShadow(color: Color(0x080E121B), blurRadius: 4),
                BoxShadow(
                  color: Color(0x0F0E121B),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: context.adapt(AppColors.white, AppColors.categoryDark),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: context.inkColor,
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
