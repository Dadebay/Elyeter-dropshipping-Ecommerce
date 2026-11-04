import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../product/presentation/widgets/product_image_view.dart';
import '../../domain/entities/pre_order.dart';

/// One order in a list: when it was placed, where it stands, what it came to
/// and a strip of what is in it.
class OrderListCard extends StatelessWidget {
  const OrderListCard({super.key, required this.order, required this.onTap});

  final PreOrder order;
  final VoidCallback onTap;

  static final _dateFormat = DateFormat('dd.MM.yyyy • HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    final locale = Localizations.localeOf(context).toString();
    final created = order.createdAt?.toLocal();
    final amount =
        '${CurrencyFormatter.amount(order.totalPrice, locale: locale)} ${order.currency}';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl - 4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    created == null
                        ? order.number
                        : _dateFormat.format(created),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleMedium?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: AppIcons.chevronRight,
                    size: 12,
                    color: AppColors.grey700,
                  ),
                ),
                const Spacer(),
                _StatusPill(status: order.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              context.l10n.orderItemsFor(order.itemsCount, amount),
              style: theme.labelMedium?.copyWith(color: AppColors.grey500),
            ),
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _ItemsStrip(items: order.items),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final PreOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color, soft) = switch (status) {
      PreOrderStatus.newOrder => (
        l10n.orderStatusNew,
        const Color(0xFF1E7B45),
        const Color(0xFFCFF3DC),
      ),
      PreOrderStatus.confirmed => (
        l10n.orderStatusConfirmed,
        const Color(0xFF1E7B45),
        const Color(0xFFCFF3DC),
      ),
      PreOrderStatus.ordered => (
        l10n.orderStatusOrdered,
        const Color(0xFF1E7B45),
        const Color(0xFFCFF3DC),
      ),
      PreOrderStatus.completed => (
        l10n.orderStatusDelivered,
        const Color(0xFF1E7B45),
        const Color(0xFFCFF3DC),
      ),
      PreOrderStatus.cancelled => (
        l10n.orderStatusCancelled,
        const Color(0xFF9C2B2B),
        const Color(0xFFF6C9CB),
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.radio_button_checked_rounded, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnails of the order's lines, as many as the card is wide enough for,
/// with the rest counted in a `+N` tile. A line bought more than once wears
/// an `x2` badge.
class _ItemsStrip extends StatelessWidget {
  const _ItemsStrip({required this.items});

  static const _width = 49.0;
  static const _height = 64.0;
  static const _gap = AppSpacing.xs;
  static const _unit = _width + _gap;

  final List<PreOrderItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final room = constraints.maxWidth + _gap;
        var fits = (room / _unit).floor().clamp(1, 12);
        if (items.length > fits) fits = ((room - _unit) / _unit).floor();
        fits = fits.clamp(1, items.length);
        final shown = items.take(fits).toList();
        final hidden = items.length - shown.length;

        return Row(
          children: [
            for (final item in shown) ...[
              _Thumb(item: item),
              const SizedBox(width: _gap),
            ],
            if (hidden > 0) _MoreTile(count: hidden),
          ],
        );
      },
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item});

  final PreOrderItem item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ItemsStrip._width,
      height: _ItemsStrip._height,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: ColoredBox(
                color: const Color(0xFFF5F5F5),
                child: item.image == null
                    ? const Center(
                        child: HugeIcon(
                          icon: AppIcons.image,
                          size: 18,
                          color: AppColors.grey500,
                        ),
                      )
                    : ProductImageView(
                        source: item.image!,
                        fit: BoxFit.cover,
                        fallbackIconSize: 18,
                      ),
              ),
            ),
          ),
          if (item.quantity > 1)
            Positioned(
              left: 3,
              bottom: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xFFE5E5E5),
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  child: Text(
                    'x${item.quantity}',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    width: _ItemsStrip._width,
    height: _ItemsStrip._height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.grey100,
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    child: Text(
      '+$count',
      style: context.textTheme.titleSmall?.copyWith(color: AppColors.grey700),
    ),
  );
}
