import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'parcel_refresh_motion.dart';

/// Pull-to-refresh with the shared package motion.
class AppRefreshIndicator extends StatefulWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.indicatorTop = AppSpacing.md,
  });

  final RefreshCallback onRefresh;
  final Widget child;

  /// Position of the loader within the scroll area. Pages that draw behind
  /// the status bar can include their top system inset here.
  final double indicatorTop;

  @override
  State<AppRefreshIndicator> createState() => _AppRefreshIndicatorState();
}

class _AppRefreshIndicatorState extends State<AppRefreshIndicator> {
  RefreshIndicatorStatus? _status;
  bool _atTop = true;
  bool _pulledDown = false;

  bool get _visible =>
      _atTop &&
      switch (_status) {
        RefreshIndicatorStatus.drag => _pulledDown,
        RefreshIndicatorStatus.armed ||
        RefreshIndicatorStatus.snap ||
        RefreshIndicatorStatus.refresh => true,
        _ => false,
      };

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final atTop =
        notification.metrics.pixels <= notification.metrics.minScrollExtent + 1;
    var pulledDown = _pulledDown;
    if (notification is ScrollStartNotification) {
      pulledDown = false;
    } else if (notification is OverscrollNotification &&
        notification.dragDetails != null) {
      // Clamped lists report the downward pull without moving their content.
      pulledDown = atTop && notification.overscroll < 0;
    } else if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      // Bouncing lists move past the top. An inner list at offset zero while
      // its NestedScrollView header collapses is not a pull to refresh.
      pulledDown =
          notification.metrics.pixels < notification.metrics.minScrollExtent &&
          (notification.scrollDelta ?? 0) < 0;
    }
    if (atTop != _atTop || pulledDown != _pulledDown) {
      setState(() {
        _atTop = atTop;
        _pulledDown = pulledDown;
      });
    }
    return false;
  }

  void _onStatusChange(RefreshIndicatorStatus? status) {
    if (status != _status) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: RefreshIndicator.noSpinner(
            onRefresh: widget.onRefresh,
            onStatusChange: _onStatusChange,
            child: widget.child,
          ),
        ),
        if (_visible)
          Positioned(
            top: widget.indicatorTop,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  elevation: 2,
                  shape: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: ParcelRefreshMotion(size: 30),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
