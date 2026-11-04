import '../../../../core/utils/result.dart';
import '../entities/bank.dart';
import '../entities/payment.dart';

/// Online card payment for a pre-order.
abstract interface class PaymentRepository {
  /// `GET /banks` — public.
  Future<Result<List<Bank>>> banks();

  /// `POST /payments` — starts a payment. Asking again for the same bank
  /// within 20 minutes returns the same payment and the same bank page, so
  /// a retry never charges twice.
  Future<Result<Payment>> start({required int preOrderId, required int bankId});

  /// `GET /payments/:id` — asks the bank when the payment is still pending.
  Future<Result<Payment>> byId(int id);
}
