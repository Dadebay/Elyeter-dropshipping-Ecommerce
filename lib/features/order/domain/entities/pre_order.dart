import 'package:equatable/equatable.dart';

/// Where an order stands. Statuses only move forward along
/// `NEW -> CONFIRMED -> ORDERED -> COMPLETED`; a manager can cancel from any
/// of the first three, and the last two are terminal.
enum PreOrderStatus {
  /// Submitted, waiting for a manager to call.
  newOrder('NEW'),
  confirmed('CONFIRMED'),
  ordered('ORDERED'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const PreOrderStatus(this.value);

  final String value;

  static PreOrderStatus parse(String? value) =>
      PreOrderStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => PreOrderStatus.newOrder,
      );

  bool get isTerminal =>
      this == PreOrderStatus.completed || this == PreOrderStatus.cancelled;

  /// Whether the order is still on its way — what the "active orders" screen
  /// lists.
  bool get isActive => !isTerminal;
}

/// One line of a placed order. A snapshot taken at checkout: name and price
/// stay frozen even if the product is repriced later, so never re-fetch them
/// from the catalog to display an order.
class PreOrderItem extends Equatable {
  const PreOrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.lineTotal,
    this.productSlug,
    this.variantId,
    this.sku,
    this.variant,
    this.image,
  });

  final int id;
  final int productId;

  /// Existence flag only: null means the product was removed.
  /// Open available products using [productId], never this slug.
  final String? productSlug;

  final int? variantId;
  final String? sku;
  final String name;
  final String? variant;
  final String? image;
  final int quantity;
  final num price;
  final num lineTotal;

  @override
  List<Object?> get props => [
    id,
    productId,
    productSlug,
    variantId,
    sku,
    name,
    variant,
    image,
    quantity,
    price,
    lineTotal,
  ];
}

/// A placed pre-order. A manager calls the customer back and places the
/// order with the supplier; while it is `NEW` or `CONFIRMED` it can also be
/// paid online by card (see [canPay]).
class PreOrder extends Equatable {
  const PreOrder({
    required this.id,
    required this.number,
    required this.status,
    required this.totalPrice,
    this.currency = 'TMT',
    this.itemsCount = 0,
    this.customerName,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.comment,
    this.createdAt,
    this.statusChangedAt,
    this.canCancel = false,
    this.canPay = false,
    this.isPaid = false,
    this.paidAt,
    this.items = const [],
    this.priceChanged = false,
  });

  final int id;

  /// `PO-000001` — the reference to show and to quote on a support call.
  final String number;

  final PreOrderStatus status;
  final num totalPrice;
  final String currency;

  /// Total **units** (sum of quantity), not the number of lines.
  final int itemsCount;

  final String? customerName;
  final String? phone;
  final String? address;

  /// Snapshot of the delivery point saved when the order was placed.
  final double? latitude;
  final double? longitude;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? statusChangedAt;

  /// Whether `POST /pre-orders/:id/cancel` will currently succeed.
  /// Always false once [isPaid]: a paid order is cancelled only by a manager.
  final bool canCancel;

  /// Whether to offer the "Pay" button — `NEW` or `CONFIRMED`, not paid yet.
  final bool canPay;

  /// Paid online by card.
  final bool isPaid;
  final DateTime? paidAt;

  final List<PreOrderItem> items;

  /// Only set on the checkout response.
  final bool priceChanged;

  @override
  List<Object?> get props => [
    id,
    number,
    status,
    totalPrice,
    currency,
    itemsCount,
    customerName,
    phone,
    address,
    latitude,
    longitude,
    comment,
    createdAt,
    statusChangedAt,
    canCancel,
    canPay,
    isPaid,
    paidAt,
    items,
    priceChanged,
  ];
}
