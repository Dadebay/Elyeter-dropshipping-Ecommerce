import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'category_sheet.dart';

typedef CategoryProductFilters = ({num? min, num? max, bool onlyFeatured});

/// Price and featured-product filters using the same sheet as brand selection.
class CategoryPriceFilterSheet extends StatefulWidget {
  const CategoryPriceFilterSheet({
    super.key,
    this.min,
    this.max,
    this.onlyFeatured = false,
  });

  static Future<CategoryProductFilters?> show(
    BuildContext context, {
    num? min,
    num? max,
    bool onlyFeatured = false,
  }) => CategorySheet.show<CategoryProductFilters>(
    context,
    builder: (_) => CategoryPriceFilterSheet(
      min: min,
      max: max,
      onlyFeatured: onlyFeatured,
    ),
  );

  final num? min;
  final num? max;
  final bool onlyFeatured;

  @override
  State<CategoryPriceFilterSheet> createState() =>
      _CategoryPriceFilterSheetState();
}

class _CategoryPriceFilterSheetState extends State<CategoryPriceFilterSheet> {
  bool _submitted = false;
  late bool _onlyFeatured = widget.onlyFeatured;
  late final _minController = TextEditingController(
    text: widget.min?.toString() ?? '',
  );
  late final _maxController = TextEditingController(
    text: widget.max?.toString() ?? '',
  );

  num? _parse(String text) => num.tryParse(text.trim().replaceAll(',', '.'));

  bool get _hasInput =>
      _minController.text.isNotEmpty ||
      _maxController.text.isNotEmpty ||
      _onlyFeatured;

  bool get _changed =>
      _minController.text.trim() != (widget.min?.toString() ?? '') ||
      _maxController.text.trim() != (widget.max?.toString() ?? '') ||
      _onlyFeatured != widget.onlyFeatured;

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _reset() {
    _minController.clear();
    _maxController.clear();
    _onlyFeatured = false;
    setState(() {});
  }

  /// Empty is fine — it means "no limit". Anything typed has to be a
  /// number that is not negative, and the top of the range cannot sit below
  /// the bottom.
  bool get _minInvalid {
    final text = _minController.text.trim();
    if (text.isEmpty) return false;
    final min = _parse(text);
    return min == null || min < 0;
  }

  bool get _maxInvalid {
    final text = _maxController.text.trim();
    if (text.isEmpty) return false;
    final max = _parse(text);
    if (max == null || max < 0) return true;
    final min = _parse(_minController.text);
    return min != null && max < min;
  }

  void _apply() {
    setState(() => _submitted = true);
    if (_minInvalid || _maxInvalid) return;
    Navigator.of(context).pop((
      min: _parse(_minController.text),
      max: _parse(_maxController.text),
      onlyFeatured: _onlyFeatured,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    // Only after a failed Apply: red while the customer is still typing a
    // number would shout at a half-written one.
    final minError = _submitted && _minInvalid;
    final maxError = _submitted && _maxInvalid;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: CategorySheet(
        title: l10n.categoryFilters,
        onReset: _hasInput ? _reset : null,
        resetLabel: l10n.categoryReset,
        footer: CategorySheetAction(
          label: l10n.categoryApply,
          onTap: _changed ? _apply : null,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.categoryPriceRange,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: context.inkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Side by side: a range reads as one thing, from here to there.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _PriceField(
                      hint: l10n.categoryPriceMin,
                      controller: _minController,
                      invalid: minError,
                      action: TextInputAction.next,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: SizedBox(
                      width: 10,
                      child: Divider(
                        height: 1,
                        thickness: 2,
                        color: context.adapt(
                          AppColors.grey300,
                          const Color(0xFF404040),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _PriceField(
                      hint: l10n.categoryPriceMax,
                      controller: _maxController,
                      invalid: maxError,
                      action: TextInputAction.done,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                ],
              ),
              if (minError || maxError) ...[
                const SizedBox(height: AppSpacing.md),
                _Notice(
                  minError ? l10n.categoryPriceMin : l10n.categoryPriceMax,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              _FeaturedTile(
                label: l10n.categoryOnlyFeatured,
                value: _onlyFeatured,
                onChanged: (value) => setState(() => _onlyFeatured = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A number field that names itself in its hint and carries the currency.
class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.hint,
    required this.controller,
    required this.invalid,
    required this.action,
    required this.onChanged,
  });

  final String hint;
  final TextEditingController controller;
  final bool invalid;
  final TextInputAction action;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dark mode: a thin grey edge, or the field melts into the sheet.
    final idleBorder = context.isDark ? const Color(0xFF4A4A4A) : null;

    OutlineInputBorder border([Color? color]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: color == null
          ? BorderSide.none
          : BorderSide(color: color, width: 1.5),
    );

    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      cursorColor: AppColors.primary,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: action,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
      style: theme.textTheme.titleSmall?.copyWith(
        color: context.inkColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintMaxLines: 1,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.grey500,
        ),
        suffixText: AppConstants.currencySymbol,
        suffixStyle: theme.textTheme.labelMedium?.copyWith(
          color: AppColors.grey500,
        ),
        filled: true,
        fillColor: context.adapt(AppColors.background, AppColors.categoryDark),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        // No coloured edge on focus; only a wrong value gets one.
        border: border(invalid ? AppColors.error : idleBorder),
        enabledBorder: border(invalid ? AppColors.error : idleBorder),
        focusedBorder: border(
          invalid
              ? AppColors.error
              : (context.isDark ? AppColors.grey500 : null),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.error),
      ),
    );
  }
}

/// "Featured products only", as a row with a switch on it rather than a
/// bare checkbox: the whole row is the control.
class _FeaturedTile extends StatelessWidget {
  const _FeaturedTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: context.adapt(AppColors.background, AppColors.categoryDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: context.isDark
            ? const BorderSide(color: Color(0xFF4A4A4A))
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.md,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: context.inkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // The same iOS-style switch as the profile page's dark mode.
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
