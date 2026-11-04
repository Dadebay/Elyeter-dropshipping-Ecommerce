import 'package:flutter/material.dart';

import '../domain/entities/payment.dart';
import 'view/payment_web_view_page.dart';
import 'widgets/bank_picker_sheet.dart';
import 'widgets/payment_status_dialog.dart';

/// Paying a pre-order by card, start to finish: pick a bank, fill in the
/// card on the bank's page, then ask the server how it went.
abstract final class PaymentFlow {
  /// Returns true when the order ended up paid. Either way the caller should
  /// reload the order — `is_paid` and `can_pay` may have changed.
  static Future<bool> pay(
    BuildContext context, {
    required int preOrderId,
  }) async {
    while (true) {
      if (!context.mounted) return false;
      final payment = await showBankPickerSheet(
        context,
        preOrderId: preOrderId,
      );
      if (payment == null || !context.mounted) return false;

      // A payment returned again within its 20 minutes may already be done.
      if (payment.status == PaymentStatus.paid) return true;
      if (payment.invoiceUrl == null) {
        final result = await showPaymentStatusDialog(
          context,
          paymentId: payment.id,
          redirected: false,
        );
        if (result == PaymentDialogResult.retry) continue;
        return result == PaymentDialogResult.paid;
      }

      final redirected = await Navigator.of(context, rootNavigator: true)
          .push<bool>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => PaymentWebViewPage(payment: payment),
            ),
          );
      if (!context.mounted) return false;

      final result = await showPaymentStatusDialog(
        context,
        paymentId: payment.id,
        redirected: redirected ?? false,
      );
      if (result == PaymentDialogResult.retry) continue;
      return result == PaymentDialogResult.paid;
    }
  }
}
