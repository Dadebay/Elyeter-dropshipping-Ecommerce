import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/media_url.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/bank.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';

/// Lets the customer choose a bank and starts the payment with it.
///
/// Returns the started [Payment], or null when the sheet was dismissed. A
/// bank that refuses (502) leaves the sheet open so another can be tried.
Future<Payment?> showBankPickerSheet(
  BuildContext context, {
  required int preOrderId,
}) => showModalBottomSheet<Payment>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: AppColors.white,
  barrierColor: AppColors.black.withValues(alpha: 0.45),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
  ),
  constraints: BoxConstraints(
    maxHeight: MediaQuery.sizeOf(context).height * 0.75,
  ),
  builder: (_) => _BankPickerSheet(preOrderId: preOrderId),
);

class _BankPickerSheet extends StatefulWidget {
  const _BankPickerSheet({required this.preOrderId});

  final int preOrderId;

  @override
  State<_BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<_BankPickerSheet> {
  late Future<Result<List<Bank>>> _banks = getIt<PaymentRepository>().banks();

  /// The bank a payment is being started with; every row is locked meanwhile.
  int? _starting;
  String? _error;

  Future<void> _start(Bank bank) async {
    if (_starting != null) return;
    setState(() {
      _starting = bank.id;
      _error = null;
    });
    final result = await getIt<PaymentRepository>().start(
      preOrderId: widget.preOrderId,
      bankId: bank.id,
    );
    if (!mounted) return;
    switch (result) {
      case Success(:final data):
        Navigator.of(context).pop(data);
      case Error(:final failure):
        setState(() {
          _starting = null;
          _error = failure.localize(context.l10n);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.textTheme;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xs,
              AppSpacing.xl,
              AppSpacing.xs,
            ),
            child: Text(
              l10n.paymentChooseBank,
              style: theme.titleLarge?.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              l10n.paymentChooseBankHint,
              style: theme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
          ),
          if (_error case final error?)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HugeIcon(
                    icon: AppIcons.information,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      error,
                      style: theme.bodyMedium?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Flexible(
            child: FutureBuilder<Result<List<Bank>>>(
              future: _banks,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxxl),
                    child: Center(child: AppLoader()),
                  );
                }
                final result = snapshot.data;
                final banks = result?.dataOrNull ?? const <Bank>[];
                if (banks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          result?.failureOrNull?.localize(l10n) ??
                              l10n.paymentNoBanks,
                          textAlign: TextAlign.center,
                          style: theme.bodyMedium?.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: () => setState(() {
                            _banks = getIt<PaymentRepository>().banks();
                          }),
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  itemCount: banks.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    return _BankTile(
                      bank: bank,
                      busy: _starting == bank.id,
                      onTap: _starting == null ? () => _start(bank) : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BankTile extends StatelessWidget {
  const _BankTile({required this.bank, required this.busy, this.onTap});

  final Bank bank;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey100,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              AppNetworkImage(
                url: MediaUrl.resolve(bank.logo),
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                radius: AppRadius.sm,
                fallbackColor: AppColors.white,
                fallbackIconSize: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  bank.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox.square(
                dimension: 22,
                child: busy
                    ? const AppLoader(size: 20)
                    : HugeIcon(
                        icon: AppIcons.chevronRight,
                        size: 20,
                        color: AppColors.grey500,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
