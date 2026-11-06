import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/constants/app_icons.dart';

/// The strip under the subcategories: the two controls that act on the whole
/// list, then one chip per facet.
///
/// Scrolls sideways, because the chips are localized and a language with
/// longer words must not push the last one off the screen.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.facets,
    this.onFilter,
    this.onSort,
    this.onFacetTap,
    this.filterActive = false,
    this.sortActive = false,
    this.loading = false,
  });

  static const height = 40.0;

  /// Widths of the placeholder chips — a short, a medium and a long label,
  /// so the strip looks like it has real chips in it.
  static const _placeholderWidths = [96.0, 84.0, 76.0];

  /// Icons in this strip are drawn heavier than the package default (1.5),
  /// which reads as thin next to the chips' text.
  static const iconStroke = 2.0;

  /// The strip's resting fill, shared by the two round controls and the
  /// inactive chips, so the row reads as one family.
  static const fill = AppColors.background;

  final List<CategoryFacet> facets;
  final VoidCallback? onFilter;
  final VoidCallback? onSort;
  final ValueChanged<CategoryFacet>? onFacetTap;

  /// A price range is narrowing the list / the order is not the default.
  /// The round control turns dark, the way an active chip does.
  final bool filterActive;
  final bool sortActive;

  /// The facets have not arrived from the API yet: sweeping placeholder
  /// chips stand in for them, so the strip does not grow a chip late.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        children: [
          _IconButton(
            icon: AppIcons.filter,
            active: filterActive,
            onTap: onFilter,
          ),
          const SizedBox(width: AppSpacing.sm),
          _IconButton(icon: AppIcons.sort, active: sortActive, onTap: onSort),
          const SizedBox(width: AppSpacing.sm),
          if (loading)
            for (final width in _placeholderWidths) ...[
              _ShimmerChip(width: width),
              const SizedBox(width: AppSpacing.sm),
            ]
          else
            for (final facet in facets) ...[
              _FacetChip(
                facet: facet,
                onTap: onFacetTap == null ? null : () => onFacetTap!(facet),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

/// One facet of the list, and how many of its values are picked.
class CategoryFacet {
  const CategoryFacet({
    required this.id,
    required this.label,
    this.selectedCount = 0,
  });

  final String id;
  final String label;

  /// Zero leaves the chip plain; anything more turns it on and is counted in
  /// a badge, so the customer can see a filter is narrowing the list.
  final int selectedCount;

  bool get isActive => selectedCount > 0;
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  /// A `HugeIcons.*` constant — the package supplies glyphs as data.
  final List<List<dynamic>> icon;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active
          ? context.inkFill
          : context.adapt(CategoryFilterBar.fill, AppColors.categoryDark),
      clipBehavior: Clip.antiAlias,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: CategoryFilterBar.height,
          height: CategoryFilterBar.height,
          child: Center(
            child: HugeIcon(
              icon: icon,
              size: 20,
              strokeWidth: CategoryFilterBar.iconStroke,
              color: active ? context.onInkFill : context.inkColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _FacetChip extends StatelessWidget {
  const _FacetChip({required this.facet, required this.onTap});

  final CategoryFacet facet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = facet.isActive;
    final foreground = active ? context.onInkFill : context.inkColor;

    return Material(
      color: active
          ? context.inkFill
          : context.adapt(CategoryFilterBar.fill, AppColors.categoryDark),
      clipBehavior: Clip.antiAlias,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                facet.label,
                // Regular while the facet is off; weight is how an active
                // filter announces itself, so spending it on every chip
                // leaves nothing to say it with.
                style: context.textTheme.bodyMedium?.copyWith(
                  color: foreground,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (active) ...[
                const SizedBox(width: AppSpacing.xs),
                _CountBadge(count: facet.selectedCount),
              ],
              const SizedBox(width: AppSpacing.xs),
              HugeIcon(
                icon: AppIcons.chevronDown,
                size: 14,
                strokeWidth: 2.5,
                color: foreground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How many values of this facet are picked.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  static const _size = 18.0;

  final int count;

  @override
  Widget build(BuildContext context) => Container(
    width: _size,
    height: _size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: context.onInkFill, shape: BoxShape.circle),
    child: Text(
      '$count',
      style: context.textTheme.labelSmall?.copyWith(
        color: context.inkFill,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// A chip-shaped placeholder that sweeps while the facets load.
class _ShimmerChip extends StatelessWidget {
  const _ShimmerChip({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.grey700 : AppColors.grey100,
      highlightColor: isDark ? AppColors.grey500 : AppColors.white,
      period: const Duration(milliseconds: 1400),
      child: Container(
        width: width,
        height: CategoryFilterBar.height,
        decoration: const BoxDecoration(
          // Opaque: the sweep paints over whatever colour this is.
          color: AppColors.grey100,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
        ),
      ),
    );
  }
}
