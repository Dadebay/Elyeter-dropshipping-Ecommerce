import '../../../../core/network/api_response.dart';
import '../../domain/entities/pre_order.dart';

abstract final class PreOrderModel {
  static PreOrder fromJson(Map<String, dynamic> json) => PreOrder(
    id: json.reqInt('id'),
    number: json.reqStr('number'),
    status: PreOrderStatus.parse(json.strOrNull('status')),
    totalPrice: json.reqNum('total_price'),
    currency: json.str('currency', 'TMT'),
    itemsCount: json.intVal('items_count'),
    customerName: json.strOrNull('customer_name'),
    phone: json.strOrNull('phone'),
    address: json.strOrNull('address'),
    latitude: json.doubleOrNull('latitude'),
    longitude: json.doubleOrNull('longitude'),
    comment: json.strOrNull('comment'),
    createdAt: json.dateOrNull('created_at'),
    statusChangedAt: json.dateOrNull('status_changed_at'),
    canCancel: json.boolVal('can_cancel'),
    canPay: json.boolVal('can_pay'),
    isPaid: json.boolVal('is_paid'),
    paidAt: json.dateOrNull('paid_at'),
    hasPendingPayment: json.boolVal('has_pending_payment'),
    items: json.listOf('items').map(itemFromJson).toList(),
    priceChanged: json.boolVal('price_changed'),
  );

  static PreOrderItem itemFromJson(Map<String, dynamic> json) => PreOrderItem(
    id: json.intVal('id'),
    productId: json.intVal('product_id'),
    productSlug: json.strOrNull('product_slug'),
    variantId: json.intOrNull('variant_id'),
    sku: json.strOrNull('sku'),
    name: json.str('name'),
    variant: json.strOrNull('variant'),
    image: json.strOrNull('image'),
    quantity: json.intVal('quantity'),
    price: json.numVal('price'),
    lineTotal: json.numVal('line_total'),
  );
}
