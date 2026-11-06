import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';

import '../theme/app_colors.dart';
import '../constants/app_icons.dart';

/// Plays a "flies into the cart" flourish from wherever a product was added,
/// arcing up to the cart tab's real on-screen position.
///
/// Purely visual — adding to the cart happens at the call site; this only
/// gives it a finish the customer can follow.
abstract final class CartFlyAnimation {
  /// Attach to whatever marks the cart tab's on-screen position (see
  /// `AppBottomNavBar`'s cart item) — the target is read from its RenderBox.
  static final GlobalKey cartIconKey = GlobalKey();

  /// [image] follows the same convention as `ProductCardData.images`: a
  /// bundled asset when it starts with `assets/`, otherwise a URL. Null or
  /// empty falls back to a bag glyph.
  static ImageProvider? imageFor(String? image) {
    if (image == null || image.isEmpty) return null;
    return image.startsWith('assets/')
        ? AssetImage(image)
        : CachedNetworkImageProvider(image);
  }

  /// Flies from [fromContext]'s own centre — pass the tapped button's
  /// context and no position maths is needed at the call site.
  static void runFrom({required BuildContext fromContext, String? image}) {
    final box = fromContext.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    run(
      context: fromContext,
      startCenter: box.localToGlobal(box.size.center(Offset.zero)),
      image: image,
    );
  }

  static void run({
    required BuildContext context,
    required Offset startCenter,
    String? image,
  }) {
    // No cart tab on screen (a full-screen page, a test) — nothing to fly to.
    final cartContext = cartIconKey.currentContext;
    if (cartContext == null) return;
    final box = cartContext.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyingItem(
        start: startCenter,
        end: box.localToGlobal(box.size.center(Offset.zero)),
        onCompleted: entry.remove,
        child: _FlyingThumb(image: imageFor(image)),
      ),
    );
    overlay.insert(entry);
  }
}

/// The thing that flies: the product's own photo in a brand-ringed disc.
class _FlyingThumb extends StatelessWidget {
  const _FlyingThumb({this.image});

  static const size = 42.0;

  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.adapt(AppColors.white, AppColors.categoryDark),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.25),
            blurRadius: 8,
          ),
        ],
        image: image == null
            ? null
            : DecorationImage(image: image!, fit: BoxFit.cover),
      ),
      child: image == null
          ? const HugeIcon(
              icon: AppIcons.cart,
              color: AppColors.primary,
              size: 18,
            )
          : null,
    );
  }
}

class _FlyingItem extends StatefulWidget {
  const _FlyingItem({
    required this.start,
    required this.end,
    required this.child,
    required this.onCompleted,
  });

  final Offset start;
  final Offset end;
  final Widget child;
  final VoidCallback onCompleted;

  @override
  State<_FlyingItem> createState() => _FlyingItemState();
}

class _FlyingItemState extends State<_FlyingItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  /// How far the flight bulges above the straight line, at its midpoint.
  static const _arcHeight = 130.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInCubic);
    _controller.forward().whenComplete(widget.onCompleted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        final t = _curve.value;
        final dx = ui.lerpDouble(widget.start.dx, widget.end.dx, t)!;
        // Parabola: the flight bulges upwards instead of cutting a straight
        // line down to the cart tab.
        final dy =
            ui.lerpDouble(widget.start.dy, widget.end.dy, t)! -
            _arcHeight * t * (1 - t);
        final scale = ui.lerpDouble(1, 0.25, t)!;
        final opacity = t < 0.8 ? 1.0 : (1 - (t - 0.8) / 0.2).clamp(0.0, 1.0);

        return Positioned(
          left: dx - _FlyingThumb.size / 2,
          top: dy - _FlyingThumb.size / 2,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
