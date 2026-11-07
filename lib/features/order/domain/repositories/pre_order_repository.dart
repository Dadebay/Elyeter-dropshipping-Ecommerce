import '../../../../core/network/api_response.dart';
import '../../../../core/utils/result.dart';
import '../entities/pre_order.dart';
import '../entities/pre_order_check.dart';
import '../entities/pre_order_line.dart';

/// Section 5 of the API doc. Every call here is authenticated, and the two
/// that touch the supplier are slow — show a spinner.
abstract interface class PreOrderRepository {
  /// `POST /pre-orders/check` — validation only, nothing is created.
  Future<Result<PreOrderCheck>> check(List<PreOrderLine> lines);

  /// `POST /pre-orders` — creates the order, or fails whole.
  ///
  /// Pass [expectedTotal]: without it a price move goes through silently,
  /// with it the API rejects the order as `pre-order-price-changed` instead.
  ///
  /// [idempotencyKey] is one UUID per press of "Place order", reused for every
  /// retry of that press: a repeat after a timeout then returns the order
  /// already made instead of making a second. [locationId] is the saved
  /// address, so the courier gets the point on the map.
  Future<Result<PreOrder>> create({
    required List<PreOrderLine> lines,
    String? customerName,
    String? address,
    String? comment,
    num? expectedTotal,
    int? locationId,
    String? idempotencyKey,
  });

  /// `GET /pre-orders` — newest first. [statuses] filters by one or several
  /// statuses at once (sent comma-separated); empty means all.
  Future<Result<Paginated<PreOrder>>> list({
    int page,
    int size,
    List<PreOrderStatus> statuses,
  });

  /// `GET /pre-orders/:id` — 404 when it belongs to someone else.
  Future<Result<PreOrder>> byId(int id);

  /// `POST /pre-orders/:id/cancel` — only while `can_cancel` is true.
  Future<Result<PreOrder>> cancel(int id);
}

/// The `details` a pre-order 409 carries is a full `/check`-shaped result,
/// so the cart can be re-rendered straight from a rejection rather than from
/// a second round trip.
extension PreOrderFailureDetails on Map<String, dynamic>? {
  PreOrderCheck? get asPreOrderCheck {
    final details = this;
    if (details == null || details.isEmpty) return null;
    return PreOrderCheckDetails.parse(details);
  }
}

/// Parsing lives in the data layer; it registers itself here at startup so
/// the domain and presentation layers never import a model.
abstract final class PreOrderCheckDetails {
  static PreOrderCheck Function(Map<String, dynamic> json)? _parser;

  // ignore: use_setters_to_change_properties
  static void register(PreOrderCheck Function(Map<String, dynamic>) parser) {
    _parser = parser;
  }

  static PreOrderCheck? parse(Map<String, dynamic> json) {
    try {
      return _parser?.call(json);
    } on Object {
      // A malformed `details` must not hide the error it came with.
      return null;
    }
  }
}
