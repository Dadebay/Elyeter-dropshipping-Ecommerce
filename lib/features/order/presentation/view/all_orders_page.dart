import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../domain/entities/pre_order.dart';
import '../widgets/paged_orders_list.dart';

/// Finished orders, split into delivered and cancelled. Each tab asks the API
/// for its own status, so neither has to page through the other's orders.
class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({super.key});

  @override
  State<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  int _tab = 0;

  /// The cancelled list is only fetched once its tab has been opened.
  bool _cancelledOpened = false;

  void _select(int tab) {
    setState(() {
      _tab = tab;
      if (tab == 1) _cancelledOpened = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _SheetAppBar(title: l10n.profileOrderHistory),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.lg,
              AppSpacing.page,
              AppSpacing.xs,
            ),
            child: _Tabs(
              labels: [l10n.orderStatusDelivered, l10n.orderStatusCancelled],
              selected: _tab,
              onSelected: _select,
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                const PagedOrdersList(status: PreOrderStatus.completed),
                if (_cancelledOpened)
                  const PagedOrdersList(status: PreOrderStatus.cancelled)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// iOS-style segmented switch: a black thumb slides under the labels on a
/// spring, and can also be dragged from one side to the other.
class _Tabs extends StatefulWidget {
  const _Tabs({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  State<_Tabs> createState() => _TabsState();
}

class _TabsState extends State<_Tabs> with SingleTickerProviderStateMixin {
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 420,
    damping: 30,
  );

  /// Thumb position in segments: 0 is the first label, 1 the second.
  late final AnimationController _position = AnimationController(
    vsync: this,
    lowerBound: 0,
    upperBound: (widget.labels.length - 1).toDouble(),
    value: widget.selected.toDouble(),
  );

  bool _dragging = false;

  @override
  void didUpdateWidget(_Tabs old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected && !_dragging) _settle();
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  void _settle() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _position.value = widget.selected.toDouble();
      return;
    }
    _position.animateWith(
      SpringSimulation(
        _spring,
        _position.value,
        widget.selected.toDouble(),
        _position.velocity,
      ),
    );
  }

  void _drag(DragUpdateDetails details, double segmentWidth) {
    _position.value += details.delta.dx / segmentWidth;
  }

  void _dragEnd() {
    _dragging = false;
    final target = _position.value.round().clamp(0, widget.labels.length - 1);
    if (target != widget.selected) {
      widget.onSelected(target);
    } else {
      _settle();
    }
  }

  @override
  Widget build(BuildContext context) {
    const inset = 4.0;
    final count = widget.labels.length;
    return Container(
      height: 60,
      padding: const EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl - 4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segment = constraints.maxWidth / count;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (_) {
              _dragging = true;
              _position.stop();
            },
            onHorizontalDragUpdate: (d) => _drag(d, segment),
            onHorizontalDragEnd: (_) => _dragEnd(),
            onHorizontalDragCancel: _dragEnd,
            child: AnimatedBuilder(
              animation: _position,
              builder: (context, _) => Stack(
                children: [
                  Positioned(
                    left: _position.value * segment,
                    top: 0,
                    bottom: 0,
                    width: segment,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < count; i++)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.onSelected(i),
                            child: Center(
                              child: Text(
                                widget.labels[i],
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  // Fades with the thumb: white while it is
                                  // under the label, grey as it leaves.
                                  color: Color.lerp(
                                    AppColors.grey500,
                                    AppColors.white,
                                    (1 - (_position.value - i).abs()).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The app bar sits on a white sheet whose bottom corners are rounded, over
/// the grey page.
class _SheetAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SheetAppBar({required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppPageAppBar(title: title),
    ),
  );
}
