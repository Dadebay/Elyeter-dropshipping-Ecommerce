import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Dims the preview except for a rounded window, and draws the corner
/// brackets that tell the customer where to hold the product.
///
/// The window is a square sitting a little above centre, so the hint text and
/// the shutter have room underneath without covering it.
class VisualSearchFrame extends StatelessWidget {
  const VisualSearchFrame({super.key});

  /// Side of the window as a share of the screen width.
  static const _widthFraction = 0.66;

  /// Where the window's own centre sits down the screen.
  static const _centerFraction = 0.42;

  static const _radius = 28.0;

  /// Window rect for a given screen, so callers can lay text out beneath it.
  static Rect frameOf(Size size) {
    final side = size.width * _widthFraction;
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height * _centerFraction),
      width: side,
      height: side,
    );
  }

  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: SizedBox.expand(child: CustomPaint(painter: _FramePainter())),
  );
}

class _FramePainter extends CustomPainter {
  const _FramePainter();

  /// How far each bracket runs along its edge, past the corner radius.
  static const _bracketLength = 26.0;
  static const _stroke = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = VisualSearchFrame.frameOf(size);
    final window = RRect.fromRectAndRadius(
      frame,
      const Radius.circular(VisualSearchFrame._radius),
    );

    // Everything but the window is dimmed.
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(window),
      ),
      Paint()..color = AppColors.black.withValues(alpha: 0.5),
    );

    final bracket = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(_brackets(frame), bracket);
  }

  /// Four L-shaped strokes, each following the window's rounded corner.
  Path _brackets(Rect frame) {
    const r = VisualSearchFrame._radius;
    const len = _bracketLength;
    final path = Path();

    // Top-left, clockwise from the left edge.
    path
      ..moveTo(frame.left, frame.top + r + len)
      ..lineTo(frame.left, frame.top + r)
      ..arcToPoint(
        Offset(frame.left + r, frame.top),
        radius: const Radius.circular(r),
      )
      ..lineTo(frame.left + r + len, frame.top);

    // Top-right.
    path
      ..moveTo(frame.right - r - len, frame.top)
      ..lineTo(frame.right - r, frame.top)
      ..arcToPoint(
        Offset(frame.right, frame.top + r),
        radius: const Radius.circular(r),
      )
      ..lineTo(frame.right, frame.top + r + len);

    // Bottom-right.
    path
      ..moveTo(frame.right, frame.bottom - r - len)
      ..lineTo(frame.right, frame.bottom - r)
      ..arcToPoint(
        Offset(frame.right - r, frame.bottom),
        radius: const Radius.circular(r),
      )
      ..lineTo(frame.right - r - len, frame.bottom);

    // Bottom-left.
    path
      ..moveTo(frame.left + r + len, frame.bottom)
      ..lineTo(frame.left + r, frame.bottom)
      ..arcToPoint(
        Offset(frame.left, frame.bottom - r),
        radius: const Radius.circular(r),
      )
      ..lineTo(frame.left, frame.bottom - r - len);

    return path;
  }

  @override
  bool shouldRepaint(_FramePainter oldDelegate) => false;
}
