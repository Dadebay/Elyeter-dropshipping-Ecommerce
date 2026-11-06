import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../model/order_detail_data.dart';
import '../../../../core/constants/app_icons.dart';

/// The stages of the order down a rail. Cancellation marks the stopped point
/// in red and labels the remaining steps as stopped.
class OrderProgressTimeline extends StatelessWidget {
  const OrderProgressTimeline({
    super.key,
    required this.stages,
    this.badgeEveryDone = false,
    this.cancelled = false,
  });

  static const _cancelledColor = Color(0xFFFF3655);
  static const _cancelledHalo = Color(0xFFFFE8EC);

  /// Width of the rail column — the ring plus the room around it.
  static const _railWidth = 28.0;

  /// Ordinary stages use rings; a cancellation uses a filled stop marker.
  static const _ringSize = 18.0;
  static const _ringStroke = 2.5;

  /// Halo around the stage the order has just reached.
  static const _haloSize = 28.0;

  static const _connectorWidth = 3.0;

  /// Leaves the rail long enough for the connector to read as a line rather
  /// than as a gap between two dots.
  static const _rowGap = AppSpacing.xl;

  final List<OrderStageEntry> stages;

  /// Puts the tick on every stage reached, not just the latest — what a
  /// finished order shows.
  final bool badgeEveryDone;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex();

    return Column(
      children: [
        for (var i = 0; i < stages.length; i++)
          _Row(
            entry: stages[i],
            cancelledOrder: cancelled,
            isCurrent: i == current,
            showBadge: i == current || (badgeEveryDone && stages[i].done),
            isLast: i == stages.length - 1,
            // The connector belongs to the gap below a dot, so the last row
            // ends the rail instead of trailing a line into nothing.
            hasConnector: i < stages.length - 1,
            // Light the connector through the reached stages, including the
            // cancellation marker, and leave later connectors grey.
            connectorDone:
                i < stages.length - 1 &&
                (stages[i + 1].done || (cancelled && stages[i + 1].cancelled)),
          ),
      ],
    );
  }

  /// The last stage the order has reached.
  int _currentIndex() {
    var current = -1;
    for (var i = 0; i < stages.length; i++) {
      if (stages[i].done) current = i;
    }
    return current;
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.entry,
    required this.cancelledOrder,
    required this.isCurrent,
    required this.showBadge,
    required this.isLast,
    required this.hasConnector,
    required this.connectorDone,
  });

  final OrderStageEntry entry;
  final bool cancelledOrder;
  final bool isCurrent;
  final bool showBadge;

  /// The end of the route carries a dot inside its ring — the destination
  /// rather than one more stop on the way.
  final bool isLast;

  final bool hasConnector;
  final bool connectorDone;

  @override
  Widget build(BuildContext context) {
    final done = entry.done;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: OrderProgressTimeline._railWidth,
            child: Column(
              children: [
                _Ring(
                  done: done,
                  isCurrent: isCurrent,
                  isLast: isLast,
                  cancelled: entry.cancelled,
                  cancelledOrder: cancelledOrder,
                ),
                if (hasConnector)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: OrderProgressTimeline._connectorWidth,
                        // Stretches to whatever the row beside it needs, so
                        // a two-line label does not break the rail.
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: connectorDone
                              ? cancelledOrder
                                    ? OrderProgressTimeline._cancelledColor
                                    : AppColors.primary
                              : context.adapt(
                                  AppColors.grey300,
                                  const Color(0xFF404040),
                                ),
                          borderRadius: BorderRadius.circular(
                            OrderProgressTimeline._connectorWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: hasConnector ? OrderProgressTimeline._rowGap : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The line above the label: the time if the API gave one,
                  // "Cancelled" in red where the order was called off, and
                  // nothing otherwise — the label keeps its place either way.
                  if (entry.cancelled)
                    Text(
                      context.l10n.orderStatusCancelled,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: OrderProgressTimeline._cancelledColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (cancelledOrder && !done)
                    Text(
                      context.l10n.orderStepStopped,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.grey500,
                      ),
                    )
                  else if (entry.at case final at?)
                    Text(
                      DateFormatter.monthDayTime(
                        at,
                        locale: Localizations.localeOf(context).toString(),
                      ),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _label(context, entry.stage),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: cancelledOrder || done
                          ? context.inkColor
                          : AppColors.grey500,
                      fontWeight: cancelledOrder || done
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The badge marks where the order stands right now. It centres on
          // the label block, not on the whole row — the row also carries the
          // gap that holds the connector, which would pull it downwards.
          if (showBadge)
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.sm,
                bottom: hasConnector ? OrderProgressTimeline._rowGap : 0,
              ),
              child: const Center(widthFactor: 1, child: _CurrentBadge()),
            ),
        ],
      ),
    );
  }

  static String _label(BuildContext context, OrderStage stage) {
    final l10n = context.l10n;
    return switch (stage) {
      OrderStage.placed => l10n.orderStepPlaced,
      OrderStage.chinaWarehouse => l10n.orderStepWarehouse,
      OrderStage.shipped => l10n.orderStepShipped,
      OrderStage.arrived => l10n.orderStepArrived,
      OrderStage.delivered => l10n.orderStepDelivered,
    };
  }
}

/// A hollow ring on the rail: brand-coloured once the stage is reached,
/// grey while it is still ahead.
class _Ring extends StatelessWidget {
  const _Ring({
    required this.done,
    required this.isCurrent,
    required this.isLast,
    this.cancelled = false,
    this.cancelledOrder = false,
  });

  final bool done;
  final bool isCurrent;
  final bool isLast;
  final bool cancelled;
  final bool cancelledOrder;

  @override
  Widget build(BuildContext context) {
    final color = cancelled || (cancelledOrder && done)
        ? OrderProgressTimeline._cancelledColor
        : done
        ? AppColors.primary
        : context.adapt(AppColors.grey300, const Color(0xFF404040));

    final ring = Container(
      width: OrderProgressTimeline._ringSize,
      height: OrderProgressTimeline._ringSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cancelled
            ? OrderProgressTimeline._cancelledColor
            : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: OrderProgressTimeline._ringStroke,
        ),
      ),
      child: isLast
          ? DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: 6),
            )
          : null,
    );

    return Container(
      // The halo keeps the rail's spacing whether or not it is drawn, so the
      // rings stay on one vertical line.
      width: OrderProgressTimeline._haloSize,
      height: OrderProgressTimeline._haloSize,
      alignment: Alignment.center,
      decoration: isCurrent
          ? BoxDecoration(
              color: cancelledOrder
                  ? OrderProgressTimeline._cancelledHalo
                  : AppColors.primarySoft,
              shape: BoxShape.circle,
            )
          : null,
      child: ring,
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
    // Centred: a HugeIcon in a tight box stretches to fill it, which
    // is what made the tick overflow its badge.
    child: const Center(
      child: HugeIcon(
        icon: AppIcons.check,
        size: 13,
        strokeWidth: 2.4,
        color: AppColors.white,
      ),
    ),
  );
}
