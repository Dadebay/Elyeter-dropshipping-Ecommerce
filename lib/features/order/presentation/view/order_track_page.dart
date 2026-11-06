import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/elyeter_map.dart';
import '../../domain/entities/pre_order.dart';
import '../../domain/repositories/pre_order_repository.dart';

/// An order-status map. The API has the saved delivery point and status, but
/// no courier position, route, or ETA. Do not invent those on this screen.
class OrderTrackPage extends StatefulWidget {
  const OrderTrackPage({super.key, required this.orderId});
  final int orderId;

  @override
  State<OrderTrackPage> createState() => _OrderTrackPageState();
}

class _OrderTrackPageState extends State<OrderTrackPage>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;
  PreOrder? _order;
  String? _error;
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startPolling();
  }

  void _startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _load(silent: true),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load(silent: true);
      _startPolling();
    } else {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (_refreshing) return;
    _refreshing = true;
    if (!silent && mounted) setState(() => _loading = true);
    final result = await getIt<PreOrderRepository>().byId(widget.orderId);
    _refreshing = false;
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.dataOrNull case final order?) {
        _order = order;
        _error = null;
        if (order.status.isTerminal) _refreshTimer?.cancel();
      } else {
        _error = result.failureOrNull?.message ?? '';
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _statusText(PreOrderStatus status) {
    final l10n = context.l10n;
    return switch (status) {
      PreOrderStatus.newOrder => l10n.orderStatusNew,
      PreOrderStatus.confirmed => l10n.orderStatusConfirmed,
      PreOrderStatus.ordered => l10n.orderStatusOrdered,
      PreOrderStatus.completed => l10n.orderStatusCompleted,
      PreOrderStatus.cancelled => l10n.orderStatusCancelled,
    };
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order == null && _loading) {
      return const Scaffold(body: Center(child: AppLoader()));
    }
    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          clipBehavior: Clip.none,
          leadingWidth: AppBackButton.leadingWidth,
          leading: const AppBackButton.appBarLeading(),
        ),
        body: Center(
          child: TextButton(
            onPressed: _load,
            child: Text(
              _error?.isNotEmpty == true ? _error! : context.l10n.orderNotFound,
            ),
          ),
        ),
      );
    }

    final hasPoint = order.latitude != null && order.longitude != null;
    final point = hasPoint
        ? LatLng(order.latitude!, order.longitude!)
        : ElyeterMap.defaultCenter;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ElyeterMap(
              center: point,
              zoom: hasPoint ? 15 : 12,
              attributionTopInset: 72,
              markers: hasPoint
                  ? [
                      Marker(
                        point: point,
                        width: 64,
                        height: 64,
                        child: const _DeliveryMarker(),
                      ),
                    ]
                  : const [],
            ),
          ),
          Positioned(
            left: AppSpacing.page,
            right: AppSpacing.page,
            top: MediaQuery.paddingOf(context).top + AppSpacing.md,
            child: Row(
              children: [
                const AppBackButton(),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _NumberPill(number: order.number)),
                const SizedBox(width: AppSpacing.md),
                _RefreshPill(refreshing: _refreshing, onTap: () => _load()),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _StatusSheet(
              order: order,
              statusText: _statusText(order.status),
              hasPoint: hasPoint,
              error: _error,
            ),
          ),
        ],
      ),
    );
  }
}

/// The delivery point: an orange pin in a soft halo.
class _DeliveryMarker extends StatelessWidget {
  const _DeliveryMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: context.adapt(AppColors.white, AppColors.categoryDark),
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: HugeIcon(
              icon: AppIcons.mapPin,
              size: 18,
              strokeWidth: 2,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// The back button's neighbours across the top of the map: the order number
/// in the same white lifted pill.
class _NumberPill extends StatelessWidget {
  const _NumberPill({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppBackButton.height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.adapt(AppColors.white, AppColors.categoryDark),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppBackButton.shadow,
      ),
      child: Text(
        context.l10n.orderNumber(number),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.inkColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RefreshPill extends StatelessWidget {
  const _RefreshPill({required this.refreshing, required this.onTap});

  final bool refreshing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.adapt(AppColors.white, AppColors.categoryDark),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppBackButton.shadow,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: refreshing ? null : onTap,
          child: SizedBox(
            width: AppBackButton.height + 8,
            height: AppBackButton.height,
            child: Center(
              child: refreshing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: AppLoader(color: AppColors.primary),
                    )
                  : HugeIcon(
                      icon: AppIcons.refresh,
                      size: 20,
                      strokeWidth: 2,
                      color: context.inkColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The card over the bottom of the map: where the order stands, as a stepper
/// of the four statuses the API has, and where it is going.
class _StatusSheet extends StatelessWidget {
  const _StatusSheet({
    required this.order,
    required this.statusText,
    required this.hasPoint,
    required this.error,
  });

  final PreOrder order;
  final String statusText;
  final bool hasPoint;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.textTheme;
    final cancelled = order.status == PreOrderStatus.cancelled;
    final accent = cancelled ? AppColors.error : AppColors.primary;
    final softAccent = cancelled ? AppColors.errorSoft : AppColors.primarySoft;
    final address = order.address?.isNotEmpty == true
        ? order.address!
        : hasPoint
        ? l10n.orderTrackMapPoint
        : l10n.orderTrackNoPoint;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.adapt(AppColors.white, AppColors.categoryDark),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.adapt(
                    AppColors.grey300,
                    const Color(0xFF404040),
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    statusText,
                    style: theme.titleLarge?.copyWith(
                      color: context.inkColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: softAccent,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: 36,
                    child: Center(
                      child: HugeIcon(
                        icon: cancelled ? AppIcons.close : AppIcons.truck,
                        size: 20,
                        strokeWidth: 2,
                        color: accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (cancelled) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.orderTrackCancelled,
                style: theme.bodySmall?.copyWith(color: AppColors.grey500),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            _Stepper(status: order.status),
            const SizedBox(height: AppSpacing.xl),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.adapt(
                  AppColors.background,
                  AppColors.categoryDark,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox.square(
                        dimension: 38,
                        child: Center(
                          child: HugeIcon(
                            icon: AppIcons.mapPin,
                            size: 20,
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodyMedium?.copyWith(
                          color: context.inkColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (error != null && error!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                error!,
                style: theme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              '${l10n.orderTrackRefresh}. ${l10n.orderTrackNoCourier}',
              style: theme.labelSmall?.copyWith(
                color: AppColors.grey500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placed, confirmed, ordered, delivered: a dot for each, joined by a line
/// that is lit as far as the order has got. A cancelled order lights only the
/// first.
class _Stepper extends StatelessWidget {
  const _Stepper({required this.status});

  static const _steps = [
    PreOrderStatus.newOrder,
    PreOrderStatus.confirmed,
    PreOrderStatus.ordered,
    PreOrderStatus.completed,
  ];
  static const _icons = [
    AppIcons.receipt,
    AppIcons.checkCircle,
    AppIcons.parcel,
    AppIcons.truck,
  ];
  static const _circle = 40.0;

  final PreOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.orderStepPlaced,
      l10n.orderStatusConfirmed,
      l10n.orderStatusOrdered,
      l10n.orderStepDelivered,
    ];
    final cancelled = status == PreOrderStatus.cancelled;
    // Index of the last step reached; a cancelled order got no further than
    // being placed.
    final reached = cancelled ? 0 : _steps.indexOf(status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _steps.length; i++)
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: _circle,
                  child: Row(
                    children: [
                      Expanded(
                        child: _Line(
                          lit: i > 0 && reached >= i,
                          visible: i > 0,
                        ),
                      ),
                      _Dot(
                        icon: _icons[i],
                        done: i <= reached,
                        current: i == reached && !cancelled,
                      ),
                      Expanded(
                        child: _Line(
                          lit: i < _steps.length - 1 && reached > i,
                          visible: i < _steps.length - 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: i <= reached ? context.inkColor : AppColors.grey500,
                    fontWeight: i <= reached
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.lit, required this.visible});

  final bool lit;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: lit
            ? AppColors.primary
            : context.adapt(AppColors.grey300, const Color(0xFF404040)),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.icon, required this.done, required this.current});

  final AppIconData icon;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _Stepper._circle,
      height: _Stepper._circle,
      decoration: BoxDecoration(
        color: done
            ? AppColors.primary
            : context.adapt(AppColors.grey100, AppColors.backgroundDark),
        shape: BoxShape.circle,
        // The step the order is on now carries a soft halo.
        boxShadow: current
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 0,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: Center(
        child: HugeIcon(
          icon: icon,
          size: 20,
          strokeWidth: 2,
          color: done ? AppColors.white : AppColors.grey500,
        ),
      ),
    );
  }
}
