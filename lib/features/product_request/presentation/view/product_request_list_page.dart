import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../order/presentation/widgets/order_card.dart';
import '../../../product/presentation/widgets/product_review_button.dart';
import '../../domain/entities/product_request.dart';
import '../../domain/repositories/product_request_repository.dart';
import '../widgets/product_request_sheet.dart';

/// "My requests": every AliExpress link the customer sent, newest first.
class ProductRequestListPage extends StatefulWidget {
  const ProductRequestListPage({super.key});

  @override
  State<ProductRequestListPage> createState() => _ProductRequestListPageState();
}

class _ProductRequestListPageState extends State<ProductRequestListPage> {
  static const _size = 20;

  Paginated<ProductRequest>? _page;
  bool _loading = false;
  String? _error;

  /// Rows being re-read after a tap on a pending request.
  final Set<int> _refreshing = {};

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
    final result = await getIt<ProductRequestRepository>().list(
      page: more ? (_page?.page ?? 0) + 1 : 1,
      size: _size,
    );
    if (!mounted) return;
    setState(() {
      if (result.dataOrNull case final page?) {
        _page = more && _page != null ? _page!.merge(page) : page;
      }
      _error = result.failureOrNull?.localize(context.l10n);
      _loading = false;
    });
  }

  static const _prefetch = 6;

  void _prefetchWhenVisible(int index, int count) {
    if (index < count - _prefetch || _loading || _error != null) return;
    if (!(_page?.hasMore(_size) ?? false)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_loading && _error == null) _load(more: true);
    });
  }

  Future<void> _add() async {
    await openProductRequestSheet(context, showMyRequests: false);
    if (mounted) await _load();
  }

  Future<void> _open(ProductRequest request) async {
    if (request.product case final product?
        when request.status == ProductRequestStatus.available) {
      await context.pushNamed(
        AppRoutes.productDetail.name,
        pathParameters: {'id': product.id.toString()},
      );
      return;
    }
    if (!request.status.isPending || _refreshing.contains(request.id)) return;

    // A pending request may have moved on since the list was read.
    setState(() => _refreshing.add(request.id));
    final latest = (await getIt<ProductRequestRepository>().byId(
      request.id,
    )).dataOrNull;
    if (!mounted) return;
    setState(() {
      _refreshing.remove(request.id);
      final page = _page;
      if (latest == null || page == null) return;
      _page = Paginated(
        items: [
          for (final item in page.items) item.id == latest.id ? latest : item,
        ],
        totalCount: page.totalCount,
        page: page.page,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = _page?.items ?? const <ProductRequest>[];

    return Scaffold(
      backgroundColor: context.adapt(
        AppColors.background,
        AppColors.categoryDark,
      ),
      appBar: AppPageAppBar(
        title: l10n.productRequestMine,
        actions: [
          IconButton(
            tooltip: l10n.productRequestTitle,
            onPressed: _add,
            icon: HugeIcon(icon: AppIcons.add, color: context.inkColor),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: _page == null && _loading
          ? const Center(child: AppLoader())
          : _page == null && _error != null
          ? Center(
              child: TextButton(onPressed: _load, child: Text(_error!)),
            )
          : AppRefreshIndicator(
              onRefresh: _load,
              child: items.isEmpty
                  ? LayoutBuilder(
                      builder: (context, constraints) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: constraints.maxHeight,
                            child: _Empty(onAdd: _add),
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
                          items.length +
                          ((_page?.hasMore(_size) ?? false) ? 1 : 0),
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
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
                        final request = items[index];
                        return _RequestTile(
                          request: request,
                          refreshing: _refreshing.contains(request.id),
                          onTap: () => _open(request),
                        );
                      },
                    ),
            ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.refreshing,
    required this.onTap,
  });

  final ProductRequest request;
  final bool refreshing;
  final VoidCallback onTap;

  (String, Color, Color) _status(BuildContext context) {
    final l10n = context.l10n;
    return switch (request.status) {
      ProductRequestStatus.processing => (
        l10n.productRequestStatusProcessing,
        AppColors.primary,
        AppColors.primarySoft,
      ),
      ProductRequestStatus.inReview => (
        l10n.productRequestStatusInReview,
        AppColors.warning,
        const Color(0xFFFEF5E7),
      ),
      ProductRequestStatus.available => (
        l10n.productRequestStatusAvailable,
        AppColors.success,
        const Color(0xFFE9F8F0),
      ),
      ProductRequestStatus.rejected => (
        l10n.productRequestStatusRejected,
        AppColors.error,
        AppColors.errorSoft,
      ),
      ProductRequestStatus.failed => (
        l10n.productRequestStatusFailed,
        AppColors.error,
        AppColors.errorSoft,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.textTheme;
    final (label, color, soft) = _status(context);
    final product = request.product;
    final createdAt = request.createdAt;
    final locale = Localizations.localeOf(context).toString();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: OrderCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.square(
              dimension: 56,
              child: product?.mainImage != null
                  ? AppNetworkImage(
                      url: product!.mainImage,
                      width: 56,
                      height: 56,
                      radius: AppRadius.sm,
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.adapt(
                          AppColors.grey100,
                          AppColors.categoryDark,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: AppIcons.cart,
                          size: 24,
                          color: AppColors.grey500,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.name ?? request.url,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.titleSmall?.copyWith(
                      color: context.inkColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      CurrencyFormatter.format(
                        product.price,
                        locale: context.l10n.localeName,
                        decimals: 0,
                      ),
                      style: theme.bodyMedium?.copyWith(
                        color: context.inkColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: soft,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          child: Text(
                            label,
                            style: theme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (refreshing) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const AppLoader(size: 14),
                      ],
                      const Spacer(),
                      if (createdAt != null)
                        Text(
                          DateFormatter.monthDayTime(
                            createdAt,
                            locale: locale,
                            shortMonth: true,
                          ),
                          style: theme.labelSmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: AppIcons.search, size: 48, color: AppColors.grey500),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.productRequestEmptyTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.productRequestMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ProductReviewButton(
              label: l10n.productRequestSend,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
