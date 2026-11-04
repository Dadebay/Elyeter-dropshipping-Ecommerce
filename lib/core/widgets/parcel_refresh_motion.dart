import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_icons.dart';

/// The shared package motion shown while a page is pulled to refresh.
class ParcelRefreshMotion extends StatefulWidget {
  const ParcelRefreshMotion({super.key, this.size = 24});

  final double size;

  @override
  State<ParcelRefreshMotion> createState() => _ParcelRefreshMotionState();
}

class _ParcelRefreshMotionState extends State<ParcelRefreshMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = MediaQuery.disableAnimationsOf(context)
              ? 0.25
              : _controller.value;
          final oscillation = math.sin(2 * math.pi * progress);
          return Center(
            child: Transform.translate(
              offset: Offset(0, -widget.size * 0.17 * oscillation),
              child: Transform.rotate(
                angle: 0.22 * oscillation,
                child: HugeIcon(
                  icon: AppIcons.parcel,
                  color: Theme.of(context).colorScheme.primary,
                  size: widget.size * 0.75,
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
