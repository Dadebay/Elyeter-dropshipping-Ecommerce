import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../brand/domain/entities/brand.dart';
import 'category_sheet.dart';

/// Picks the brands to narrow the list to.
///
/// Brands are recognised by their logo before their name, so they are laid
/// out as a grid of logo cards rather than a list of rows. Any number can be
/// picked; nothing is applied until Apply, so ticking three brands does not
/// reload the list three times. Reset clears the picks in the sheet.
class CategoryBrandSheet extends StatefulWidget {
  const CategoryBrandSheet({
    super.key,
    required this.brands,
    required this.selectedSlugs,
  });

  /// Returns the slugs picked (empty for "any brand"), or null when the
  /// sheet is dismissed without applying — which leaves the selection alone.
  static Future<Set<String>?> show(
    BuildContext context, {
    required List<Brand> brands,
    required Set<String> selectedSlugs,
  }) {
    return CategorySheet.show<Set<String>>(
      context,
      builder: (_) =>
          CategoryBrandSheet(brands: brands, selectedSlugs: selectedSlugs),
    );
  }

  /// Below this many brands the grid is short enough to scan without a
  /// search field.
  static const _searchThreshold = 6;

  /// Share of the screen the list area takes when it is fixed.
  static const _heightFactor = 0.8;

  /// The tallest `CategorySheet.show` lets any sheet grow.
  static const _sheetMaxFactor = 0.85;

  /// What the sheet spends on its handle, header and Apply button, which the
  /// list's own height has to leave room for.
  static const _chrome = 160.0;

  final List<Brand> brands;
  final Set<String> selectedSlugs;

  @override
  State<CategoryBrandSheet> createState() => _CategoryBrandSheetState();
}

class _CategoryBrandSheetState extends State<CategoryBrandSheet> {
  late final Set<String> _picked = {...widget.selectedSlugs};
  String _query = '';

  bool get _changed =>
      _picked.length != widget.selectedSlugs.length ||
      !_picked.containsAll(widget.selectedSlugs);

  void _toggle(String slug) => setState(() {
    if (!_picked.remove(slug)) _picked.add(slug);
  });

  /// The picked brand leads the grid, so it is never lost off-screen in a
  /// long list; the rest keep the order the API gave.
  List<Brand> get _visible {
    final query = _query.trim().toLowerCase();
    final matched = query.isEmpty
        ? [...widget.brands]
        : widget.brands
              .where((brand) => brand.name.toLowerCase().contains(query))
              .toList();
    // Brands already picked when the sheet opened lead the grid. Ordered
    // from the opening selection, so ticking a card never makes it jump.
    return [
      ...matched.where((b) => widget.selectedSlugs.contains(b.slug)),
      ...matched.where((b) => !widget.selectedSlugs.contains(b.slug)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visible = _visible;
    final searchable =
        widget.brands.length >= CategoryBrandSheet._searchThreshold;

    // A long list gets a fixed-height body, so the sheet does not shrink
    // around a search that matched only a few brands. A short list has no
    // search to shrink it and keeps hugging its content.
    final media = MediaQuery.of(context);
    final fixedHeight = searchable
        ? math.min(
            math.min(
              media.size.height * CategoryBrandSheet._heightFactor,
              // The sheet itself stops at 85% of the screen, header included.
              media.size.height * CategoryBrandSheet._sheetMaxFactor -
                  CategoryBrandSheet._chrome,
            ),
            // Never taller than what the keyboard leaves, less the sheet's
            // own handle and header.
            media.size.height -
                media.viewInsets.bottom -
                media.padding.top -
                CategoryBrandSheet._chrome,
          )
        : null;

    // The keyboard is not accounted for by the sheet itself.
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: CategorySheet(
        title: l10n.categoryFilterBrand,
        // Nothing picked, nothing to clear.
        onReset: _picked.isEmpty ? null : () => setState(_picked.clear),
        resetLabel: l10n.categoryReset,
        footer: CategorySheetAction(
          label: _picked.isEmpty
              ? l10n.categoryApply
              : '${l10n.categoryApply} (${_picked.length})',
          // Greyed out until something differs, so Apply always means a
          // change.
          onTap: _changed ? () => Navigator.of(context).pop(_picked) : null,
        ),
        child: SizedBox(
          height: fixedHeight,
          child: Column(
            mainAxisSize: fixedHeight == null
                ? MainAxisSize.min
                : MainAxisSize.max,
            children: [
              if (searchable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.xs,
                  ),
                  child: _SearchField(
                    hint: l10n.categoryFacetSearch(l10n.categoryFilterBrand),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
              Flexible(
                fit: fixedHeight == null ? FlexFit.loose : FlexFit.tight,
                child: visible.isEmpty
                    ? (fixedHeight == null
                          ? const _NoMatches()
                          : const Center(child: _NoMatches()))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          const padding = AppSpacing.xl;
                          const gap = AppSpacing.sm;
                          const columns = 3;
                          // Square plate plus its label, so the row height falls
                          // out of the width instead of being guessed at.
                          final cell =
                              (constraints.maxWidth -
                                  2 * padding -
                                  (columns - 1) * gap) /
                              columns;

                          return GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.fromLTRB(
                              padding,
                              AppSpacing.lg,
                              padding,
                              AppSpacing.xl,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: AppSpacing.xs,
                                  crossAxisSpacing: gap,
                                  mainAxisExtent: cell + _BrandCard.labelBlock,
                                ),
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              final brand = visible[index];
                              return _BrandCard(
                                brand: brand,
                                selected: _picked.contains(brand.slug),
                                onTap: () => _toggle(brand.slug),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
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
      cursorColor: AppColors.primary,
      style: context.textTheme.bodyMedium?.copyWith(color: context.inkColor),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: HugeIcon(
            icon: AppIcons.search,
            size: 20,
            strokeWidth: 2,
            color: AppColors.grey500,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: context.adapt(AppColors.background, AppColors.categoryDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md + 2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// A brand as the app's other tiles do it: a square plate with the logo on
/// it and the name underneath. Picking one rings the plate in orange and
/// pins a tick to its corner.
class _BrandCard extends StatelessWidget {
  const _BrandCard({
    required this.brand,
    required this.selected,
    required this.onTap,
  });

  /// Height of the name line and the gap above it.
  static const labelBlock = 26.0;

  final Brand brand;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: selected,
      label: brand.name,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        // No edge until picked. The width is constant so
                        // picking one recolours it instead of moving the
                        // logo.
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: AppNetworkImage(
                        url: brand.logo,
                        fit: BoxFit.contain,
                        radius: AppRadius.md,
                        fallbackIconSize: 22,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: AnimatedScale(
                      scale: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: AppColors.white, width: 2),
                          ),
                        ),
                        child: SizedBox.square(
                          dimension: 22,
                          child: Center(
                            child: HugeIcon(
                              icon: AppIcons.check,
                              size: 12,
                              strokeWidth: 3,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              brand.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected ? AppColors.primary : context.inkColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: AppIcons.searchEmpty,
            size: 36,
            color: context.adapt(AppColors.grey300, const Color(0xFF404040)),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.categoryNoResults,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}
