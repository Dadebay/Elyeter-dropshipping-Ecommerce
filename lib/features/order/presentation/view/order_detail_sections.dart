part of 'order_detail_page.dart';

/// Title, order number and the things that can be done about it. A finished
/// order wears a green tick, a cancelled one a red cross.
class _Header extends StatelessWidget {
  const _Header({
    required this.order,
    required this.cancelling,
    required this.onRepeat,
    required this.onAsk,
    required this.onCancel,
  });

  final OrderDetailData order;
  final bool cancelling;
  final VoidCallback onRepeat;
  final VoidCallback onAsk;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = switch (order.outcome) {
      OrderOutcome.active => l10n.orderActiveTitle,
      OrderOutcome.completed => l10n.orderCompleted,
      OrderOutcome.cancelled => l10n.orderCancelled,
    };

    return OrderCard(
      padding: order.outcome == OrderOutcome.cancelled
          ? const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxxl,
              AppSpacing.lg,
              AppSpacing.lg,
            )
          : const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          if (order.outcome != OrderOutcome.active) ...[
            _OutcomeBadge(outcome: order.outcome),
            SizedBox(
              height: order.outcome == OrderOutcome.cancelled
                  ? AppSpacing.xl
                  : AppSpacing.md,
            ),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style:
                (order.outcome == OrderOutcome.cancelled
                        ? context.textTheme.headlineLarge
                        : context.textTheme.headlineSmall)
                    ?.copyWith(
                      color: context.inkColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.orderNumber(order.number),
            style:
                (order.outcome == OrderOutcome.cancelled
                        ? context.textTheme.bodySmall
                        : context.textTheme.labelSmall)
                    ?.copyWith(color: AppColors.grey500),
          ),
          SizedBox(
            height: order.outcome == OrderOutcome.cancelled
                ? AppSpacing.xxl
                : AppSpacing.lg,
          ),
          Row(
            children: [
              Expanded(
                child: _Action(
                  icon: AppAssets.iconRepeatOrder,
                  label: l10n.orderRepeat,
                  onTap: onRepeat,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Action(
                  icon: AppAssets.iconBubbleQuestion,
                  label: l10n.orderQuestions,
                  onTap: onAsk,
                ),
              ),
              // Only an order that is still on its way, and only while the
              // API says it can be cancelled.
              if (order.outcome == OrderOutcome.active && order.canCancel) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Action(
                    icon: AppAssets.iconCircleX,
                    label: l10n.orderCancel,
                    onTap: cancelling ? null : onCancel,
                    busy: cancelling,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// The big green tick or red cross over a finished order.
class _OutcomeBadge extends StatelessWidget {
  const _OutcomeBadge({required this.outcome});

  final OrderOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final done = outcome == OrderOutcome.completed;

    if (!done) {
      return Image.asset(
        AppAssets.imageOrderCancelled,
        width: 72,
        height: 72,
        filterQuality: FilterQuality.high,
        semanticLabel: context.l10n.orderCancelled,
      );
    }

    return SvgPicture.asset(
      AppAssets.iconOrderDone,
      width: 72,
      height: 72,
      semanticsLabel: context.l10n.orderStatusCompleted,
    );
  }
}

/// One of the header's buttons.
class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    this.onTap,
    this.busy = false,
  });

  /// Path to an SVG in `assets/icons`.
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.adapt(AppColors.grey100, AppColors.backgroundDark),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: busy
                    ? const Padding(
                        padding: EdgeInsets.all(2),
                        child: AppLoader(),
                      )
                    : SvgPicture.asset(icon, width: 22, height: 22),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.adapt(AppColors.grey700, AppColors.iconSoft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Online payment: the "Pay" button while the order can be paid, and a
/// "Paid" line once it has been.
class _Payment extends StatelessWidget {
  const _Payment({
    required this.order,
    required this.paying,
    required this.onPay,
  });

  final PreOrder order;
  final bool paying;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.textTheme;

    if (!order.isPaid) {
      return OrderCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.paymentPayOnlineTitle,
              style: theme.titleMedium?.copyWith(
                color: context.inkColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.paymentPayOnlineMessage,
              style: theme.bodySmall?.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: AppSpacing.md),
            // While the bank has not answered, no second Pay: the same button
            // reads "Checking payment…" and the page reads the order again.
            ProductReviewButton(
              label: order.hasPendingPayment
                  ? l10n.paymentChecking
                  : l10n.paymentPay,
              loading: paying || order.hasPendingPayment,
              onPressed: onPay,
            ),
          ],
        ),
      );
    }

    final paidAt = order.paidAt;
    return OrderCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(
                icon: AppIcons.check,
                size: 20,
                strokeWidth: 2.5,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.paymentPaid,
                  style: theme.titleSmall?.copyWith(
                    color: context.inkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (paidAt != null)
                  Text(
                    DateFormatter.dayTime(
                      paidAt,
                      locale: Localizations.localeOf(context).toString(),
                      fullMonth: true,
                    ),
                    style: theme.bodySmall?.copyWith(color: AppColors.grey500),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.order, required this.onTrack});

  final OrderDetailData order;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    return OrderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only orders still in progress or completed can open the map.
          if (order.outcome == OrderOutcome.cancelled)
            Text(
              context.l10n.orderProgress,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.inkColor,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            OrderCardHeader(title: context.l10n.orderProgress, onTap: onTrack),
          const SizedBox(height: AppSpacing.lg),
          OrderProgressTimeline(
            stages: order.stages,
            badgeEveryDone: order.outcome == OrderOutcome.completed,
            cancelled: order.outcome == OrderOutcome.cancelled,
          ),
        ],
      ),
    );
  }
}

class _Products extends StatelessWidget {
  const _Products({required this.order, required this.onShowAll});

  final OrderDetailData order;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return OrderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderCardHeader(title: context.l10n.orderProgress, onTap: onShowAll),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            context.l10n.orderItemSummary(
              order.itemCount,
              CurrencyFormatter.format(
                order.productsTotal,
                locale: context.l10n.localeName,
                decimals: 0,
              ),
            ),
            style: context.textTheme.labelSmall?.copyWith(
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OrderProductsStrip(
            products: order.products,
            itemCount: order.itemCount,
          ),
        ],
      ),
    );
  }
}

/// Where it is going, who is collecting it and when it was placed.
class _Details extends StatelessWidget {
  const _Details({required this.order});

  final OrderDetailData order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    // An order placed without a name carries none; the customer's own profile
    // name (and number) stand in, so the recipient is never just a phone.
    final user = context.watch<AuthCubit>().state.user;
    final recipientName = order.recipientName.isNotEmpty
        ? order.recipientName
        : (user?.username?.trim() ?? '');
    final recipientPhone = PhoneFormatter.display(
      order.recipientPhone.isNotEmpty
          ? order.recipientPhone
          : (user?.phone ?? ''),
    );
    final rows = <Widget>[
      if (order.pickupPoint.isNotEmpty)
        OrderInfoRow(
          icon: AppAssets.iconOrderPin,
          label: l10n.orderPickupPoint,
          value: order.pickupPoint,
        ),
      if (recipientName.isNotEmpty || recipientPhone.isNotEmpty)
        OrderInfoRow(
          icon: AppAssets.iconUser,
          label: l10n.orderRecipient,
          value: recipientName.isEmpty ? recipientPhone : recipientName,
          secondary: recipientName.isEmpty || recipientPhone.isEmpty
              ? null
              : recipientPhone,
        ),
      OrderInfoRow(
        icon: AppAssets.iconCalendar,
        label: l10n.orderTime,
        value: DateFormatter.dayTime(
          order.placedAt,
          locale: locale,
          fullMonth: true,
        ),
      ),
    ];

    // Rows carry their own padding so the dividers can run edge to edge.
    return OrderCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: context.adapt(
                  const Color(0xFFF5F5F5),
                  AppColors.backgroundDark,
                ),
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}
