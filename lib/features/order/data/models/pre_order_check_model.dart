import '../../../../core/network/api_response.dart';
import '../../domain/entities/pre_order_check.dart';

abstract final class PreOrderCheckModel {
  static PreOrderCheck fromJson(Map<String, dynamic> json) => PreOrderCheck(
    available: json.boolVal('available'),
    priceChanged: json.boolVal('price_changed'),
    totalPrice: json.reqNum('total_price'),
    checkedAt: json.dateOrNull('checked_at'),
    items: json.listOf('items').map(itemFromJson).toList(),
  );

  static PreOrderCheckItem itemFromJson(Map<String, dynamic> json) =>
      PreOrderCheckItem(
        productId: json.intVal('product_id'),
        variantId: json.intOrNull('variant_id'),
        sku: json.strOrNull('sku'),
        name: json.strOrNull('name'),
        variant: json.strOrNull('variant'),
        image: json.strOrNull('image'),
        quantity: json.intVal('quantity'),
        price: json.numOrNull('price'),
        previousPrice: json.numOrNull('previous_price'),
        priceChanged: json.boolVal('price_changed'),
        lineTotal: json.numOrNull('line_total'),
        availableStock: json.intOrNull('available_stock'),
        status: PreOrderLineStatus.parse(json.strOrNull('status')),
        message: json.strOrNull('message'),
      );
}
