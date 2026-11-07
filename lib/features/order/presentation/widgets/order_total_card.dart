import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters/currency_formatter.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../model/order_detail_data.dart';
import 'order_card.dart';

/// The order total, cargo note, and receipt action.
class OrderTotalCard extends StatelessWidget {
  const OrderTotalCard({
    super.key,
    required this.order,
    this.onDownload,
    this.downloading = false,
  });

  final OrderDetailData order;
  final VoidCallback? onDownload;

  /// The receipt is being made: the button shows a spinner and ignores taps.
  final bool downloading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = context.isDark;

    return OrderCard(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              gradient: isDark
                  ? const RadialGradient(
                      center: Alignment(0, -0.9),
                      radius: 1.4,
                      colors: [Color(0xFF315A46), AppColors.grey900],
                    )
                  : const RadialGradient(
                      center: Alignment(0, -0.9),
                      radius: 1.4,
                      colors: [
                        Color(0xFFC7ECD8),
                        Color(0xFFE3F2E9),
                        AppColors.surfaceMuted,
                      ],
                      stops: [0, 0.45, 1],
                    ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.orderTotalTitle,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.grey300 : AppColors.grey700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _Total(amount: order.total),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Figma: the note's orange (#FF8D28), the 17 px info glyph from
          // the design file, and text of 14 / 20.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1.5),
                child: AppAssetImage(
                  AppAssets.iconNoteInfo,
                  width: 17,
                  height: 17,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.orderCargoNote,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFF8D28),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _DownloadButton(
            onTap: downloading ? null : onDownload,
            busy: downloading,
          ),
        ],
      ),
    );
  }
}

/// The headline figure, with its currency set smaller beside it.
class _Total extends StatelessWidget {
  const _Total({required this.amount});

  final num amount;

  @override
  Widget build(BuildContext context) {
    final color = context.isDark ? AppColors.white : AppColors.black;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: CurrencyFormatter.amount(
                amount,
                locale: context.l10n.localeName,
                decimals: 2,
              ),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: AppConstants.currencySymbol,
              style: context.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        style: context.textTheme.displayMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.onTap, this.busy = false});

  final VoidCallback? onTap;
  final bool busy;

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
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              busy
                  ? const SizedBox(width: 18, height: 18, child: AppLoader())
                  : SvgPicture.asset(
                      AppAssets.iconReceipt,
                      width: 18,
                      height: 18,
                    ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                context.l10n.orderDownloadCheck,
                style: context.textTheme.titleSmall?.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
