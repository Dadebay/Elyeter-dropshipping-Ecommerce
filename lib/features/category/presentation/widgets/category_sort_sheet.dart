import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../product/domain/entities/product_query.dart';
import 'category_sheet.dart';

/// Sorts the category's server-backed product list.
class CategorySortSheet extends StatelessWidget {
  const CategorySortSheet({super.key, required this.current});

  static Future<ProductSort?> show(
    BuildContext context, {
    required ProductSort current,
  }) => CategorySheet.show<ProductSort>(
    context,
    builder: (_) => CategorySortSheet(current: current),
  );

  final ProductSort current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    String labelOf(ProductSort sort) => switch (sort) {
      ProductSort.newest => l10n.categorySortNewest,
      ProductSort.popular => l10n.categorySortPopular,
      ProductSort.priceAsc => l10n.categorySortPriceAsc,
      ProductSort.priceDesc => l10n.categorySortPriceDesc,
    };

    return CategorySheet(
      title: l10n.categorySortTitle,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        children: [
          for (final sort in ProductSort.values) ...[
            _SortOption(
              label: labelOf(sort),
              selected: sort == current,
              onTap: () => Navigator.of(context).pop(sort),
            ),
            if (sort != ProductSort.values.last)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: selected
          // Dark mode: a warm tint of the brand colour, not the pale peach.
          ? context.adapt(
              AppColors.primarySoft,
              AppColors.primary.withValues(alpha: 0.16),
            )
          : context.adapt(AppColors.background, AppColors.categoryDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : context.adapt(Colors.transparent, const Color(0xFF3A3A3A)),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontFamily: AppTypography.fontFamily,
                      color: selected && context.isDark
                          ? AppColors.white
                          : context.inkColor,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : context.adapt(
                              AppColors.grey300,
                              const Color(0xFF6B6B6B),
                            ),
                      width: selected ? 2 : 1.5,
                    ),
                  ),
                  child: selected
                      ? const DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(width: 10, height: 10),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
