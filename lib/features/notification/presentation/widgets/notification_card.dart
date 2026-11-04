import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../product/domain/entities/product_id.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.isNew,
    required this.onTap,
  });

  final ShopNotification notification;
  final bool isNew;
  final VoidCallback onTap;

  bool get _hasDestination {
    final target = notification.target;
    if (target == null || target.trim().isEmpty) return false;
    return switch (notification.targetType) {
      'product' => ProductId.tryParse(target) != null,
      'category' => true,
      'url' => const ['http', 'https'].contains(Uri.tryParse(target)?.scheme),
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = notification.createdAt?.toLocal();
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: BorderSide(
        color: isNew
            ? colors.primary.withValues(alpha: 0.2)
            : colors.outlineVariant.withValues(alpha: 0.4),
      ),
    );
    final icon = switch (notification.targetType) {
      'product' => AppIcons.cart,
      'category' => AppIcons.parcel,
      'url' => AppIcons.external,
      _ => AppIcons.notification,
    };

    return Material(
      color: isNew
          ? Color.alphaBlend(
              colors.primary.withValues(alpha: 0.045),
              colors.surface,
            )
          : colors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _hasDestination ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isNew
                      ? colors.primary.withValues(alpha: 0.1)
                      : colors.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: icon,
                    size: 22,
                    color: isNew ? colors.primary : colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                    if (date != null || isNew || _hasDestination) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.xs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (isNew)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.xs,
                                      ),
                                    ),
                                    child: Text(
                                      context.l10n.notificationsNew,
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colors.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                if (date != null)
                                  Text(
                                    DateFormatter.time(
                                      date,
                                      locale: Localizations.localeOf(
                                        context,
                                      ).toString(),
                                    ),
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          if (_hasDestination)
                            HugeIcon(
                              icon: AppIcons.chevronRight,
                              size: 18,
                              color: colors.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
