import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// The empty product area below a category's filter strip.
class CategoryProductsEmpty extends StatelessWidget {
  const CategoryProductsEmpty({super.key, this.filtered = false});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = filtered
        ? l10n.categoryNoResults
        : l10n.categoryProductsEmptyTitle;
    final message = filtered
        ? l10n.categoryNoResultsHint
        : l10n.categoryProductsEmptyMessage;

    return Align(
      alignment: const Alignment(0, -0.35),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filters that match nothing show a magnifier; a category with
              // no products at all keeps the shopping bag.
              if (filtered)
                // The search page's own "not found" magnifier (with the minus).
                SvgPicture.asset(
                  AppAssets.iconSearchNotFound,
                  width: 72,
                  height: 72,
                  semanticsLabel: title,
                )
              else
                SizedBox.square(
                  dimension: 156,
                  child: Image.asset(
                    AppAssets.emptyShoppingBag,
                    fit: BoxFit.contain,
                    semanticLabel: title,
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
