import 'package:equatable/equatable.dart';

enum PaymentStatus {
  /// Waiting for the customer or the bank. A bank page closed without paying
  /// stays here and turns [failed] after 3 hours.
  pending('PENDING'),

  /// Money received; the pre-order is marked paid.
  paid('PAID'),

  /// Declined by the bank, or expired.
  failed('FAILED');

  const PaymentStatus(this.value);

  final String value;

  static PaymentStatus parse(String? value) => PaymentStatus.values.firstWhere(
    (s) => s.value == value,
    orElse: () => PaymentStatus.pending,
  );
}

/// One attempt to pay a pre-order by card. The amount always comes from the
/// pre-order on the server — the app never sends one.
class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.preOrderId,
    required this.bankId,
    required this.amount,
    required this.status,
    this.invoiceUrl,
    this.returnUrl,
    this.paidAt,
    this.createdAt,
  });

  final int id;
  final int preOrderId;
  final int bankId;
  final num amount;
  final PaymentStatus status;

  /// The bank's card page. Only present while [status] is pending.
  final String? invoiceUrl;

  /// Where the bank sends the WebView when it is done — the moment this
  /// starts loading, the WebView closes.
  final String? returnUrl;
  final DateTime? paidAt;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    preOrderId,
    bankId,
    amount,
    status,
    invoiceUrl,
    returnUrl,
    paidAt,
    createdAt,
  ];
}
