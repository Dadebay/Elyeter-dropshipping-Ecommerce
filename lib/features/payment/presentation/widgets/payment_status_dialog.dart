import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

/// What the customer chose to do once the payment's status was known.
enum PaymentDialogResult { paid, failed, pending, retry }

/// Asks the server how the payment went, polling a few times while it is
/// still pending, and tells the customer.
///
/// [redirected] is whether the bank sent the WebView back to `return_url`:
/// only then is a pending status worth waiting on. Closed before that, one
/// look is enough — the server notices a payment that did go through on its
/// own within a few minutes.
Future<PaymentDialogResult> showPaymentStatusDialog(
  BuildContext context, {
  required int paymentId,
  required bool redirected,
}) async {
  final result = await showDialog<PaymentDialogResult>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (_) =>
        _PaymentStatusDialog(paymentId: paymentId, redirected: redirected),
  );
  return result ?? PaymentDialogResult.pending;
}

class _PaymentStatusDialog extends StatefulWidget {
  const _PaymentStatusDialog({
    required this.paymentId,
    required this.redirected,
  });

  final int paymentId;
  final bool redirected;

  @override
  State<_PaymentStatusDialog> createState() => _PaymentStatusDialogState();
}

class _PaymentStatusDialogState extends State<_PaymentStatusDialog> {
  static const _interval = Duration(seconds: 3);
  static const _attempts = 20;

  /// Null while checking.
  PaymentStatus? _status;

  @override
  void initState() {
    super.initState();
    unawaited(_poll());
  }

  Future<void> _poll() async {
    final attempts = widget.redirected ? _attempts : 1;
    var status = PaymentStatus.pending;
    for (var i = 0; i < attempts; i++) {
      if (i > 0) await Future<void>.delayed(_interval);
      if (!mounted) return;
      final result = await getIt<PaymentRepository>().byId(widget.paymentId);
      // A failed request is not a failed payment: keep it pending.
      status = result.dataOrNull?.status ?? PaymentStatus.pending;
      if (status != PaymentStatus.pending) break;
    }
    if (mounted) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.textTheme;
    final status = _status;

    final (
      AppIconData? icon,
      Color color,
      String title,
      String message,
    ) = switch (status) {
      null => (
        null,
        AppColors.primary,
        l10n.paymentChecking,
        l10n.paymentCheckingMessage,
      ),
      PaymentStatus.paid => (
        AppIcons.checkCircle,
        AppColors.success,
        l10n.paymentSuccess,
        l10n.paymentSuccessMessage,
      ),
      PaymentStatus.failed => (
        AppIcons.close,
        AppColors.error,
        l10n.paymentFailed,
        l10n.paymentFailedMessage,
      ),
      PaymentStatus.pending => (
        AppIcons.information,
        AppColors.warning,
        l10n.paymentPending,
        widget.redirected
            ? l10n.paymentPendingMessage
            : l10n.paymentNotCompletedMessage,
      ),
    };

    return AlertDialog(
      backgroundColor: context.adapt(AppColors.white, AppColors.categoryDark),
      surfaceTintColor: Colors.transparent,
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 56,
            child: icon == null
                ? const Center(child: AppLoader(size: 36))
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: HugeIcon(icon: icon, size: 30, color: color),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.titleLarge?.copyWith(
              color: context.inkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.bodyMedium?.copyWith(
              color: context.adapt(AppColors.grey700, AppColors.iconSoft),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: switch (status) {
        null => const [],
        PaymentStatus.failed => [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(PaymentDialogResult.failed),
            child: Text(l10n.commonClose),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(PaymentDialogResult.retry),
            child: Text(l10n.paymentTryAgain),
          ),
        ],
        PaymentStatus.paid || PaymentStatus.pending => [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              status == PaymentStatus.paid
                  ? PaymentDialogResult.paid
                  : PaymentDialogResult.pending,
            ),
            child: Text(l10n.commonOk),
          ),
        ],
      },
    );
  }
}
