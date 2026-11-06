import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../product/presentation/widgets/product_image_view.dart';
import '../../domain/entities/pre_order_check.dart';

/// Tells the customer why an order was not placed. When the API names the
/// products that cannot be ordered they are listed with their photo and the
/// reason; otherwise the failure's own message is shown.
Future<void> showOrderProblemDialog(
  BuildContext context, {
  String? message,
  PreOrderCheck? check,
}) => showDialog<void>(
  context: context,
  builder: (_) => _OrderProblemDialog(
    message: message,
    problems: check?.problems ?? const [],
  ),
);

class _OrderProblemDialog extends StatelessWidget {
  const _OrderProblemDialog({required this.message, required this.problems});

  final String? message;
  final List<PreOrderCheckItem> problems;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasProblems = problems.isNotEmpty;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      insetPadding: const EdgeInsets.all(AppSpacing.xxl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.errorSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 30,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                hasProblems
                    ? l10n.errorItemsUnavailable
                    : message ?? l10n.errorItemsUnavailable,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (hasProblems) ...[
                const SizedBox(height: AppSpacing.lg),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: problems.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) =>
                        _ProblemRow(item: problems[index]),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    backgroundColor: AppColors.primaryVibrant,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(l10n.commonOk),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProblemRow extends StatelessWidget {
  const _ProblemRow({required this.item});

  final PreOrderCheckItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = [if (item.variant != null) item.variant!].join(' · ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.adapt(AppColors.surfaceMuted, AppColors.backgroundDark),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox.square(
              dimension: 52,
              child: ColoredBox(
                color: AppColors.white,
                child: item.image == null
                    ? const Icon(Icons.image_outlined, color: AppColors.grey500)
                    : ProductImageView(
                        source: item.image!,
                        fit: BoxFit.cover,
                        fallbackIconSize: 20,
                      ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? '#${item.productId}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: context.inkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                if (item.message != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.message!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
