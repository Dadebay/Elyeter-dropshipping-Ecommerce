import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_asset_image.dart';

/// Drags [child] aside to uncover a Delete panel, the way the design draws a
/// swiped cart line.
///
/// Tracks the finger one-to-one rather than waiting for the gesture to end,
/// resists past the fully open position instead of stopping dead, and lands
/// where the flick was heading rather than where the finger happened to lift.
class SwipeToDelete extends StatefulWidget {
  const SwipeToDelete({super.key, required this.child, required this.onDelete});

  /// Width of the uncovered panel, and so how far the row travels.
  static const _actionWidth = 96.0;

  /// A flick shorter than this is read as a drag and lands on whichever side
  /// it is nearer.
  static const _flickVelocity = 320.0;

  /// Gap between the row's trailing edge and the panel it uncovers, so the
  /// two read as separate cards rather than one butted against the other.
  static const _margin = AppSpacing.md;

  /// Inset at the top and bottom, so the panel stops just short of the row's
  /// full height. Off the 4pt scale on purpose — half a step reads as a
  /// seam, a whole one as a gap.
  static const _verticalMargin = 6.0;

  final Widget child;
  final VoidCallback onDelete;

  @override
  State<SwipeToDelete> createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<SwipeToDelete>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
  );

  /// How far the row is pulled left, in logical pixels.
  double get _offset => _controller.value;

  bool get _isOpen => _offset > SwipeToDelete._actionWidth / 2;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // Cancelling first means a drag can grab the row mid-animation and carry
    // straight on from where it is, rather than fighting the settle.
    _controller.stop();

    // Hard stop at fully open: no stretching further left, only back right.
    _controller.value = (_offset - details.primaryDelta!).clamp(
      0.0,
      SwipeToDelete._actionWidth,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = -details.primaryVelocity!;

    // A decisive flick decides the direction on its own; anything slower
    // falls to whichever side the row is already nearer.
    final open = velocity.abs() > SwipeToDelete._flickVelocity
        ? velocity > 0
        : _isOpen;

    _settle(open ? SwipeToDelete._actionWidth : 0, velocity: velocity);
  }

  /// Springs to [target], carrying the finger's speed into the animation so
  /// there is no seam between dragging and settling.
  void _settle(double target, {double velocity = 0}) {
    _controller.animateWith(
      SpringSimulation(
        // Critically damped: this is a panel landing, not a thrown object.
        const SpringDescription(mass: 1, stiffness: 420, damping: 40),
        _offset,
        target,
        velocity,
      ),
    );
  }

  void close() => _settle(0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final travel = _offset.clamp(0.0, double.infinity);

          return Stack(
            children: [
              // Only built once the row has actually started to move, so a
              // still list is not carrying a panel behind every line.
              if (travel > 0)
                // Top and bottom pinned, so the panel stands as tall as the
                // row it belongs to.
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: _DeletePanel(
                    // Grows with the drag instead of sitting at full width
                    // from the first pixel.
                    width: travel,
                    onTap: () {
                      close();
                      widget.onDelete();
                    },
                  ),
                ),
              Transform.translate(
                offset: Offset(-travel, 0),
                // An open row taps shut rather than needing a swipe back.
                // Same widget tree at every offset: swapping the wrapper in and
                // out at 0 would remount the row mid-drag and make it jump.
                child: GestureDetector(
                  onTap: travel > 0 ? close : null,
                  behavior: HitTestBehavior.deferToChild,
                  child: child,
                ),
              ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// The uncovered panel: a trash can over a soft red field.
class _DeletePanel extends StatelessWidget {
  const _DeletePanel({required this.width, required this.onTap});

  /// Total width the drag uncovers, margin included.
  final double width;

  final VoidCallback onTap;

  static const _contentWidth =
      SwipeToDelete._actionWidth - SwipeToDelete._margin;

  @override
  Widget build(BuildContext context) {
    // The margin is taken out of the uncovered width rather than added to
    // it, so the row still travels exactly as far as the panel is wide.
    final panelWidth = (width - SwipeToDelete._margin).clamp(0.0, width);

    return Container(
      width: panelWidth,
      margin: const EdgeInsets.only(
        left: SwipeToDelete._margin,
        top: SwipeToDelete._verticalMargin,
        bottom: SwipeToDelete._verticalMargin,
      ),
      child: Material(
        // Dark mode: a red tint instead of the pale pink.
        color: context.adapt(
          AppColors.errorSoft,
          AppColors.error.withValues(alpha: 0.16),
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          // The label fades in behind the icon as the panel widens, instead
          // of being clipped in half on the way out.
          // Content keeps its natural size and is centred inside the growing
          // panel (clipped by the Material), so nothing rescales mid-drag.
          child: OverflowBox(
            minWidth: _contentWidth,
            maxWidth: _contentWidth,
            // Loose height, or the column is stretched to the full panel
            // and its content sits at the top instead of the middle.
            minHeight: 0,
            alignment: Alignment.center,
            child: Opacity(
              opacity: (panelWidth / _contentWidth).clamp(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppAssetImage(
                    AppAssets.iconTrash,
                    width: 26,
                    height: 26,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.cartDelete,
                    maxLines: 1,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: context.inkColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
