import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../domain/entities/pre_order.dart';
import '../../domain/repositories/pre_order_repository.dart';
import 'order_list_card.dart';

/// A self-paging list of the customer's orders.
///
/// [status] asks the API for one status. The "active" list spans three
/// statuses, which the API cannot filter by in one call, so [activeOnly]
/// fetches everything and keeps the unfinished ones.
class PagedOrdersList extends StatefulWidget {
  const PagedOrdersList({super.key, this.status, this.activeOnly = false});

  final PreOrderStatus? status;
  final bool activeOnly;

  @override
  State<PagedOrdersList> createState() => _PagedOrdersListState();
}

class _PagedOrdersListState extends State<PagedOrdersList>
    with AutomaticKeepAliveClientMixin {
  static const _pageSize = 20;

  /// Half a page from the end, the next one is asked for.
  static const _prefetch = 6;

  Paginated<PreOrder>? _page;
  bool _loading = false;
  String? _error;

  @override
  bool get wantKeepAlive => true;

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
    });
    final result = await getIt<PreOrderRepository>().list(
      page: more ? (_page?.page ?? 0) + 1 : 1,
      size: _pageSize,
      status: widget.status,
    );
    if (!mounted) return;
    setState(() {
      if (result.dataOrNull case final page?) {
        _page = more && _page != null ? _page!.merge(page) : page;
      }
      _error = result.failureOrNull?.message;
      _loading = false;
    });
  }

  void _prefetchWhenVisible(int index, int count) {
    if (index < count - _prefetch || _loading || _error != null) return;
    if (!(_page?.hasMore(_pageSize) ?? false)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_loading && _error == null) _load(more: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = (_page?.items ?? const <PreOrder>[])
        .where((o) => !widget.activeOnly || o.status.isActive)
        .toList();
    if (_page == null && _loading) return const Center(child: AppLoader());
    if (_page == null && _error != null) {
      return Center(
        child: TextButton(onPressed: _load, child: Text(_error!)),
      );
    }
    return AppRefreshIndicator(
      onRefresh: _load,
      child: items.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: _EmptyOrders(activeOnly: widget.activeOnly),
                  ),
                ],
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.xxxl,
              ),
              itemCount:
                  items.length + ((_page?.hasMore(_pageSize) ?? false) ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Center(
                      child: _error == null
                          ? const SizedBox.square(
                              dimension: 24,
                              child: AppLoader(),
                            )
                          : TextButton(
                              onPressed: () => _load(more: true),
                              child: Text(_error!),
                            ),
                    ),
                  );
                }
                _prefetchWhenVisible(index, items.length);
                final order = items[index];
                return OrderListCard(
                  order: order,
                  onTap: () => context.pushNamed(
                    AppRoutes.orderDetail.name,
                    pathParameters: {'id': order.id.toString()},
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.activeOnly});

  final bool activeOnly;

  @override
  Widget build(BuildContext context) => Center(
    child: Transform.translate(
      offset: const Offset(0, -kToolbarHeight / 2 - AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 160,
              child: Image.asset(
                'assets/images/order_history_empty_3d_cutout.png',
                fit: BoxFit.contain,
                semanticLabel: activeOnly
                    ? context.l10n.activeOrdersEmptyTitle
                    : context.l10n.orderHistoryEmptyTitle,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              activeOnly
                  ? context.l10n.activeOrdersEmptyTitle
                  : context.l10n.orderHistoryEmptyTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontFamily: AppTypography.fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              activeOnly
                  ? context.l10n.activeOrdersEmptyMessage
                  : context.l10n.orderHistoryEmptyMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                fontFamily: AppTypography.fontFamily,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
