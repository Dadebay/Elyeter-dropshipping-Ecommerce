import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../model/category_filters.dart';
import 'category_sheet.dart';
import '../../../../core/constants/app_icons.dart';

/// Picks any number of values under one facet.
///
/// Unlike the sort sheet nothing is applied until Apply: a customer ticking
/// three brands should not have the list churn under them three times.
class CategoryFacetSheet extends StatefulWidget {
  const CategoryFacetSheet({
    super.key,
    required this.facet,
    required this.selected,
  });

  /// Returns the picked values, or null when the sheet is dismissed without
  /// applying — which leaves the previous selection alone.
  static Future<Set<String>?> show(
    BuildContext context, {
    required FacetDefinition facet,
    required Set<String> selected,
  }) {
    return CategorySheet.show<Set<String>>(
      context,
      builder: (_) => CategoryFacetSheet(facet: facet, selected: selected),
    );
  }

  /// Above this many values the sheet grows a search field; below it, one is
  /// just another thing to look past.
  static const _searchThreshold = 8;

  final FacetDefinition facet;
  final Set<String> selected;

  @override
  State<CategoryFacetSheet> createState() => _CategoryFacetSheetState();
}

class _CategoryFacetSheetState extends State<CategoryFacetSheet> {
  late final Set<String> _picked = {...widget.selected};
  String _query = '';

  bool get _changed =>
      _picked.length != widget.selected.length ||
      !_picked.containsAll(widget.selected);

  List<FacetValue> get _visible {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.facet.values;
    return widget.facet.values
        .where((value) => value.value.toLowerCase().contains(query))
        .toList();
  }

  void _toggle(String value) => setState(() {
    if (!_picked.remove(value)) _picked.add(value);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final searchable =
        widget.facet.values.length >= CategoryFacetSheet._searchThreshold;

    return CategorySheet(
      title: widget.facet.label,
      // Nothing picked, nothing to clear.
      onReset: _picked.isEmpty ? null : () => setState(_picked.clear),
      resetLabel: l10n.categoryReset,
      footer: CategorySheetAction(
        label: l10n.categoryApply,
        // Greyed out until something actually differs, so Apply always means
        // a change.
        onTap: _changed ? () => Navigator.of(context).pop(_picked) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (searchable)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                0,
              ),
              child: _SearchField(
                hint: l10n.categoryFacetSearch(widget.facet.label),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
          Flexible(
            child: widget.facet.isSwatch
                ? _Swatches(values: _visible, picked: _picked, onTap: _toggle)
                : _Rows(values: _visible, picked: _picked, onTap: _toggle),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: context.textTheme.bodyMedium?.copyWith(color: context.inkColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.textTheme.bodyMedium?.copyWith(
          color: AppColors.grey500,
        ),
        prefixIcon: const HugeIcon(
          icon: AppIcons.search,
          size: 20,
          color: AppColors.grey500,
        ),
        filled: true,
        fillColor: context.adapt(AppColors.background, AppColors.categoryDark),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// A tick box, the value, and how many products carry it.
class _Rows extends StatelessWidget {
  const _Rows({
    required this.values,
    required this.picked,
    required this.onTap,
  });

  final List<FacetValue> values;
  final Set<String> picked;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final value = values[index];
        final selected = picked.contains(value.value);

        return InkWell(
          onTap: () => onTap(value.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                _Tick(value: selected),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    value.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.inkColor,
                    ),
                  ),
                ),
                Text(
                  '${value.count}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Colours as colours: a grid of swatches, the picked ones ringed.
class _Swatches extends StatelessWidget {
  const _Swatches({
    required this.values,
    required this.picked,
    required this.onTap,
  });

  static const _size = 52.0;

  final List<FacetValue> values;
  final Set<String> picked;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: [
          for (final value in values)
            _Swatch(
              value: value,
              selected: picked.contains(value.value),
              onTap: () => onTap(value.value),
            ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final FacetValue value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = value.swatch;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _Swatches._size,
              height: _Swatches._size,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // The ring sits outside the colour rather than over it, so a
                // dark swatch is not read as having a lighter rim.
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      color ??
                      context.adapt(
                        AppColors.background,
                        AppColors.categoryDark,
                      ),
                  shape: BoxShape.circle,
                  border: color != null && CategoryFacets.needsOutline(color)
                      ? Border.all(
                          color: context.adapt(
                            AppColors.grey300,
                            const Color(0xFF404040),
                          ),
                        )
                      : null,
                ),
                child: color == null
                    ? const HugeIcon(
                        icon: AppIcons.help,
                        size: 18,
                        color: AppColors.grey500,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall?.copyWith(
                color: selected
                    ? context.inkColor
                    : context.adapt(AppColors.grey700, AppColors.iconSoft),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({required this.value});

  static const _size = 22.0;

  final bool value;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    width: _size,
    height: _size,
    decoration: BoxDecoration(
      color: value ? AppColors.primary : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      border: Border.all(
        color: value
            ? AppColors.primary
            : context.adapt(AppColors.grey300, const Color(0xFF404040)),
        width: 1.5,
      ),
    ),
    child: value
        ? const HugeIcon(icon: AppIcons.check, size: 15, color: AppColors.white)
        : null,
  );
}
