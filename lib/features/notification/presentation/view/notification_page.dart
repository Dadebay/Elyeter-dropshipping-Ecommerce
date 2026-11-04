import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../services/notification_navigation.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
    required this.title,
    this.isAnnouncement = false,
  });
  final String title;
  final bool isAnnouncement;
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Paginated<ShopNotification>? _page;
  bool _loading = false;
  Failure? _error;
  int? _lastSeenId;
  bool _failedToLoadMore = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _failedToLoadMore = false;
    });
    try {
      final next = await getIt<ShopApi>().notifications(
        page: more ? (_page?.page ?? 0) + 1 : 1,
      );
      if (!mounted) return;
      setState(() => _page = more && _page != null ? _page!.merge(next) : next);
      if (next.items.isNotEmpty) {
        final storage = getIt<LocalStorage>();
        final previous =
            int.tryParse(storage.getString('notifications_last_seen') ?? '') ??
            0;
        // Keep the arrival highlight for this visit, even after the existing
        // last-seen marker is saved or another page is loaded.
        _lastSeenId ??= previous;
        final newest = next.items
            .map((n) => n.id)
            .reduce((a, b) => a > b ? a : b);
        if (newest > previous) {
          await storage.setString('notifications_last_seen', newest.toString());
        }
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _error = error is AppException
              ? error.toFailure()
              : const UnknownFailure();
          _failedToLoadMore = more;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _dateLabel(BuildContext context, DateTime? date) {
    if (date == null) return context.l10n.notificationsEarlier;
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return context.l10n.notificationsToday;
    if (day == DateTime(now.year, now.month, now.day - 1)) {
      return context.l10n.notificationsYesterday;
    }
    return DateFormatter.day(
      local,
      locale: Localizations.localeOf(context).toString(),
    );
  }

  Widget _retryNotice() => Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Column(
      children: [
        Text(
          _error!.localize(context.l10n),
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => _load(more: _failedToLoadMore),
          child: Text(context.l10n.commonRetry),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final items = _page?.items ?? const <ShopNotification>[];
    return Scaffold(
      appBar: AppPageAppBar(title: widget.title),
      body: SafeArea(
        top: false,
        child: _page == null && _loading
            ? const Center(child: AppLoader())
            : _page == null && _error != null
            ? AppErrorView(failure: _error!, onRetry: _load)
            : AppRefreshIndicator(
                onRefresh: _load,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (items.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            AppSpacing.md,
                            AppSpacing.page,
                            AppSpacing.xxl,
                          ),
                          child: _NotificationIntro(),
                        ),
                      ),
                    if (_error != null && !_failedToLoadMore)
                      SliverToBoxAdapter(child: _retryNotice()),
                    if (items.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyNotifications(
                          isAnnouncement: widget.isAnnouncement,
                          onRefresh: _loading ? null : _load,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.page,
                        ),
                        sliver: SliverList.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final label = _dateLabel(context, item.createdAt);
                            final startsGroup =
                                index == 0 ||
                                label !=
                                    _dateLabel(
                                      context,
                                      items[index - 1].createdAt,
                                    );
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (startsGroup)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: index == 0 ? 0 : AppSpacing.md,
                                      bottom: AppSpacing.md,
                                    ),
                                    child: Text(
                                      label,
                                      style: context.textTheme.labelLarge
                                          ?.copyWith(
                                            color:
                                                context.colors.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                NotificationCard(
                                  notification: item,
                                  isNew: item.id > (_lastSeenId ?? item.id),
                                  onTap: () => NotificationNavigation.open(
                                    item.targetType,
                                    item.target,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                            );
                          },
                        ),
                      ),
                    if (items.isNotEmpty && (_page?.hasMore(20) ?? false))
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: _loading
                                ? const AppLoader(size: 24)
                                : _error != null && _failedToLoadMore
                                ? _retryNotice()
                                : TextButton(
                                    onPressed: () => _load(more: true),
                                    child: Text(
                                      context.l10n.notificationsLoadMore,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    if (items.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xxl),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _NotificationIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: HugeIcon(
              icon: AppIcons.notification,
              color: colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.notificationsOverviewTitle,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.notificationsOverviewMessage,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({
    required this.isAnnouncement,
    required this.onRefresh,
  });

  final bool isAnnouncement;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        80,
      ),
      child: Column(
        key: const Key('notification-empty-content'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primary.withValues(alpha: 0.06),
            ),
            child: SizedBox(
              key: const Key('notification-empty-image'),
              width: 200,
              height: 160,
              child: OverflowBox(
                minWidth: 200,
                maxWidth: 200,
                minHeight: 200,
                maxHeight: 200,
                child: Image.asset(
                  'assets/images/notification_empty_3d.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            isAnnouncement
                ? context.l10n.announcementsEmptyTitle
                : context.l10n.notificationsEmptyTitle,
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isAnnouncement
                ? context.l10n.announcementsEmptyMessage
                : context.l10n.notificationsEmptyMessage,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton.icon(
            onPressed: onRefresh,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              foregroundColor: context.colors.onSurface,
              side: BorderSide(color: context.colors.outlineVariant),
            ),
            icon: const HugeIcon(icon: AppIcons.refresh, size: 18),
            label: Text(context.l10n.notificationsRefresh),
          ),
        ],
      ),
    ),
  );
}
