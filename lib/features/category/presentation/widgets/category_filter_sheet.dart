import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../model/category_filters.dart';
import 'category_sheet.dart';

/// Every facet in one place, for the customer who wants to set several at
/// once rather than opening a chip at a time.
///
/// Each facet is a section rather than a nested sheet: burying them one level
/// deeper would look tidier and cost a tap per filter.
class CategoryFilterSheet extends StatefulWidget {
  const CategoryFilterSheet({
    super.key,
    required this.facets,
    required this.filters,
  });

  static Future<CategoryFilters?> show(
    BuildContext context, {
    required List<FacetDefinition> facets,
    required CategoryFilters filters,
  }) {
    return CategorySheet.show<CategoryFilters>(
      context,
      builder: (_) => CategoryFilterSheet(facets: facets, filters: filters),
    );
  }

  final List<FacetDefinition> facets;
  final CategoryFilters filters;

  @override
  State<CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  late CategoryFilters _draft = widget.filters;

  bool get _changed =>
      _draft.totalSelected != widget.filters.totalSelected ||
      widget.facets.any(
        (facet) => !_draft
            .selected(facet.id)
            .containsAll(widget.filters.selected(facet.id)),
      );

  void _toggle(FacetDefinition facet, String value) {
    final picked = {..._draft.selected(facet.id)};
    if (!picked.remove(value)) picked.add(value);
    setState(() => _draft = _draft.withFacet(facet.id, picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CategorySheet(
      title: l10n.categoryFilters,
      onReset: _draft.isEmpty
          ? null
          : () => setState(() => _draft = _draft.cleared),
      resetLabel: l10n.categoryReset,
      footer: CategorySheetAction(
        label: l10n.categoryApply,
        onTap: _changed ? () => Navigator.of(context).pop(_draft) : null,
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          for (final facet in widget.facets)
            _Section(
              facet: facet,
              picked: _draft.selected(facet.id),
              onTap: (value) => _toggle(facet, value),
            ),
        ],
      ),
    );
  }
}

/// One facet: its name, how many of it are on, and its values as chips.
class _Section extends StatelessWidget {
  const _Section({
    required this.facet,
    required this.picked,
    required this.onTap,
  });

  final FacetDefinition facet;
  final Set<String> picked;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  facet.label,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.inkColor,
                  ),
                ),
              ),
              if (picked.isNotEmpty)
                Text(
                  context.l10n.categorySelectedCount(picked.length),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final value in facet.values)
                _ValueChip(
                  value: value,
                  selected: picked.contains(value.value),
                  onTap: () => onTap(value.value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final FacetValue value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final swatch = value.swatch;

    return Material(
      color: selected
          ? context.inkColor
          : context.adapt(AppColors.background, AppColors.categoryDark),
      clipBehavior: Clip.antiAlias,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (swatch != null) ...[
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: swatch,
                    shape: BoxShape.circle,
                    border: CategoryFacets.needsOutline(swatch)
                        ? Border.all(
                            color: context.adapt(
                              AppColors.grey300,
                              const Color(0xFF404040),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                value.value,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? context.adapt(AppColors.white, AppColors.black)
                      : context.inkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
