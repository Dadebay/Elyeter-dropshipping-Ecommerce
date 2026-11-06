import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The soft grey block the detail page groups each section into. The page
/// behind it is white, so the blocks are what carry the tint.
class ProductSectionCard extends StatelessWidget {
  const ProductSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.bordered = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// The block's fill. Defaults to the page's soft grey; pass white for a
  /// control that has to read as raised against it.
  /// Defaults to the soft grey block (dark: #262626).
  final Color? color;

  /// Outlines the block. A white block on the white page needs it to read as
  /// a control rather than as empty space.
  final bool bordered;

  /// Makes the whole card tappable, as the price block is.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          color ?? context.adapt(AppColors.background, AppColors.categoryDark),
      clipBehavior: Clip.antiAlias,
      // Shape only: [Material] rejects `shape` and `borderRadius` together.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: bordered
            ? BorderSide(
                color: context.adapt(
                  AppColors.grey300,
                  const Color(0xFF404040),
                ),
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// The leader between a label and its value, as a spec sheet draws it.
class ProductDottedLine extends StatelessWidget {
  const ProductDottedLine({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 1,
    child: CustomPaint(
      painter: _DotsPainter(
        context.adapt(AppColors.grey300, const Color(0xFF404040)),
      ),
    ),
  );
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter(this.color);

  final Color color;

  static const _radius = 0.7;
  static const _step = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 0.0; x < size.width; x += _step) {
      canvas.drawCircle(Offset(x, size.height / 2), _radius, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) => oldDelegate.color != color;
}
