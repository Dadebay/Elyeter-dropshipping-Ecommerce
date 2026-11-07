import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../payment/presentation/payment_flow.dart';
import '../../../product/presentation/widgets/product_review_button.dart';
import '../../../product/presentation/widgets/product_photos.dart';
import '../../domain/entities/pre_order.dart';
import '../../domain/repositories/pre_order_repository.dart';
import '../model/order_detail_data.dart';
import '../receipt/order_receipt_pdf.dart';
import '../widgets/cancel_order_dialog.dart';
import '../widgets/order_card.dart';
import '../widgets/order_info_row.dart';
import '../widgets/order_items_sheet.dart';
import '../widgets/order_products_strip.dart';
import '../widgets/order_progress_timeline.dart';
import '../widgets/order_total_card.dart';

/// One order, end to end: where it has got to, what is in it, where it is
/// going and what it cost.
///
/// Read from `GET /pre-orders/:id`, and drawn one of three ways — still on its
/// way, delivered, or cancelled — from the order's status. Cancelling goes
/// through `POST /pre-orders/:id/cancel`.
class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<Result<PreOrder>> _future;
  bool _cancelling = false;

  /// Reads the order again while a payment is being checked by the bank.
  Timer? _pendingTimer;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void dispose() {
    _pendingTimer?.cancel();
    super.dispose();
  }

  /// `has_pending_payment` means the bank has not answered yet: look again in
  /// a few seconds until it has, rather than leaving a stale "checking".
  void _watchPendingPayment(PreOrder order) {
    if (!order.hasPendingPayment) {
      _pendingTimer?.cancel();
      _pendingTimer = null;
      return;
    }
    if (_pendingTimer?.isActive ?? false) return;
    _pendingTimer = Timer(const Duration(seconds: 7), () {
      _pendingTimer = null;
      if (mounted) unawaited(_reload());
    });
  }

  /// Product ID to the photo to show for it. The order carries a photo per
  /// line, but it is the supplier's link; the product's own photo from our
  /// file server is the one that reliably loads, so that is what is shown.
  final Map<int, String> _photos = {};

  Future<Result<PreOrder>> _fetch() async {
    final result = await getIt<PreOrderRepository>().byId(widget.orderId);
    if (result.dataOrNull case final order?) _loadPhotos(order);
    return result;
  }

  void _loadPhotos(PreOrder order) {
    for (final item in order.items) {
      final id = item.productId;
      if (item.productSlug == null || _photos.containsKey(id)) continue;
      ProductPhotos.load(id).then((urls) {
        if (mounted && urls.isNotEmpty) {
          setState(() => _photos[id] = urls.first);
        }
      });
    }
  }

  /// Back to where the order was reached from — or, when the page was opened
  /// on its own (straight after placing an order), to the home tab.
  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.home.name);
    }
  }

  Future<void> _reload() async {
    final next = _fetch();
    setState(() {
      _future = next;
    });
    await next;
  }

  Future<void> _cancel() async {
    if (_cancelling) return;
    final confirmed = await showCancelOrderDialog(context);
    if (!confirmed || !mounted) return;
    setState(() => _cancelling = true);
    final result = await getIt<PreOrderRepository>().cancel(widget.orderId);
    if (!mounted) return;
    setState(() => _cancelling = false);
    if (result.isSuccess) {
      await _reload();
    } else {
      AppSnackBar.show(
        context,
        result.failureOrNull?.localize(context.l10n) ??
            context.l10n.orderNotFound,
        icon: AppIcons.error,
        iconColor: AppColors.error,
      );
    }
  }

  /// Puts what was in the order back in the cart, and goes there.
  void _repeat(PreOrder order) {
    final cart = context.read<CartCubit>();
    for (final item in order.items) {
      final id = item.productId;
      // A product that has left the catalog has nothing to reorder.
      if (item.productSlug == null) continue;
      if (item.variantId != null) {
        cart.setVariant(id.toString(), item.variantId!);
      }
      cart.setQuantity(id.toString(), item.quantity);
    }
    AppSnackBar.show(context, context.l10n.orderRepeatDone);
    context.goNamed(AppRoutes.cart.name);
  }

  /// Rings the shop, with the number it publishes.
  Future<void> _ask() async {
    final failed = context.l10n.commonOpenFailed('tel');
    String? phone;
    try {
      phone = (await getIt<ShopApi>().contacts()).phonePrimary;
    } on Object {
      phone = null;
    }
    var opened = false;
    if (phone != null) {
      try {
        opened = await launchUrl(
          Uri.parse('tel:$phone'),
          mode: LaunchMode.externalApplication,
        );
      } on Object {
        opened = false;
      }
    }
    if (!opened && mounted) {
      AppSnackBar.show(
        context,
        failed,
        icon: AppIcons.error,
        iconColor: AppColors.error,
      );
    }
  }

  bool _paying = false;

  /// Bank, card page, status — then the order is read again, since
  /// `is_paid`, `can_pay` and `can_cancel` all move with a payment.
  Future<void> _pay(PreOrder order) async {
    if (_paying) return;
    setState(() => _paying = true);
    await PaymentFlow.pay(context, preOrderId: order.id);
    if (!mounted) return;
    setState(() => _paying = false);
    await _reload();
  }

  bool _downloading = false;

  Future<Map<int, Uint8List>> _receiptProductImages(PreOrder order) async {
    final products = <int, PreOrderItem>{
      for (final item in order.items) item.productId: item,
    };
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    try {
      final images = await Future.wait(
        products.values.map((item) async {
          final urls = <String>[
            ?_photos[item.productId],
            ...?ProductPhotos.cached(item.productId),
          ];
          if (urls.isEmpty && item.productSlug != null) {
            try {
              urls.addAll(await ProductPhotos.load(item.productId));
            } on Object {
              // The order's saved image can still be used below.
            }
          }
          if (item.image case final url?) urls.add(url);

          for (final url in urls.toSet()) {
            if (url.isEmpty) continue;
            try {
              final response = await dio.get<List<int>>(
                url,
                options: Options(responseType: ResponseType.bytes),
              );
              final bytes = response.data;
              if (bytes == null) continue;
              final decoded = img.decodeImage(Uint8List.fromList(bytes));
              if (decoded == null) continue;
              final thumbnail = decoded.width > 120
                  ? img.copyResize(decoded, width: 120)
                  : decoded;
              return MapEntry(
                item.productId,
                Uint8List.fromList(img.encodePng(thumbnail)),
              );
            } on Object {
              // Try the next available image URL.
            }
          }
          return null;
        }),
      );
      return {
        for (final image in images)
          if (image != null) image.key: image.value,
      };
    } finally {
      dio.close();
    }
  }

  /// Builds the order's receipt as a PDF and hands the file to the system
  /// share sheet — which is where a phone offers "Save to Files" / "Save to
  /// Drive" / a mail or chat app, so it is both the download and the way to
  /// send it on.
  Future<void> _downloadReceipt(PreOrder order) async {
    if (_downloading) return;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    setState(() => _downloading = true);
    try {
      final productImages = await _receiptProductImages(order);
      final bytes = await OrderReceiptPdf.build(
        order,
        ReceiptLabels(
          title: l10n.orderReceiptTitle,
          number: l10n.orderNumber,
          status: switch (order.status) {
            PreOrderStatus.newOrder => l10n.orderStatusNew,
            PreOrderStatus.confirmed => l10n.orderStatusConfirmed,
            PreOrderStatus.ordered => l10n.orderStatusOrdered,
            PreOrderStatus.completed => l10n.orderStatusCompleted,
            PreOrderStatus.cancelled => l10n.orderStatusCancelled,
          },
          customer: l10n.orderRecipient,
          address: l10n.orderPickupPoint,
          date: l10n.orderTime,
          products: l10n.orderReceiptItems,
          quantity: l10n.orderReceiptQty,
          price: l10n.orderReceiptPrice,
          amount: l10n.orderReceiptAmount,
          productsTotal: l10n.orderProductsTotal,
          cargo: l10n.orderCargo,
          discount: l10n.orderDiscount,
          total: l10n.orderTotalTitle,
          thanks: l10n.orderReceiptThanks,
        ),
        locale: locale,
        productImages: productImages,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${order.number}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              file.path,
              mimeType: 'application/pdf',
              name: '${order.number}.pdf',
            ),
          ],
          subject: order.number,
        ),
      );
    } on Object {
      if (mounted) {
        AppSnackBar.show(
          context,
          l10n.orderReceiptFailed,
          icon: AppIcons.error,
          iconColor: AppColors.error,
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.adapt(
        AppColors.background,
        AppColors.backgroundDark,
      ),
      appBar: AppBar(
        clipBehavior: Clip.none,
        backgroundColor: context.adapt(
          AppColors.background,
          AppColors.backgroundDark,
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: AppBackButton.leadingWidth,
        leading: AppBackButton.appBarLeading(onPressed: _back),
      ),
      body: FutureBuilder<Result<PreOrder>>(
        future: _future,
        builder: (context, snapshot) {
          final order = snapshot.data?.dataOrNull;
          if (order == null) {
            return Center(
              child: snapshot.connectionState != ConnectionState.done
                  ? const AppLoader()
                  : TextButton(
                      onPressed: _reload,
                      child: Text(
                        snapshot.data?.failureOrNull?.localize(context.l10n) ??
                            context.l10n.orderNotFound,
                      ),
                    ),
            );
          }
          _watchPendingPayment(order);
          final data = OrderDetailData.fromPreOrder(order, photos: _photos);

          return AppRefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSpacing.xxxl,
              ),
              children: [
                _Header(
                  order: data,
                  cancelling: _cancelling,
                  onRepeat: () => _repeat(order),
                  onAsk: _ask,
                  onCancel: _cancel,
                ),
                if (order.canPay ||
                    order.isPaid ||
                    order.hasPendingPayment) ...[
                  const SizedBox(height: AppSpacing.md),
                  _Payment(
                    order: order,
                    paying: _paying,
                    onPay: () => _pay(order),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _Progress(
                  order: data,
                  onTrack: () => context.pushNamed(
                    AppRoutes.orderTrack.name,
                    pathParameters: {'id': order.id.toString()},
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _Products(
                  order: data,
                  onShowAll: () => showOrderItemsSheet(
                    context,
                    order: order,
                    photos: _photos,
                    onOpenProduct: (id) => context.pushNamed(
                      AppRoutes.productDetail.name,
                      pathParameters: {'id': id.toString()},
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _Details(order: data),
                const SizedBox(height: AppSpacing.md),
                OrderTotalCard(
                  order: data,
                  onDownload: () => _downloadReceipt(order),
                  downloading: _downloading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
