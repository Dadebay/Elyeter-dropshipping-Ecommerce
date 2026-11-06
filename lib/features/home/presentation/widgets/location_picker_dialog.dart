import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/constants/app_icons.dart';

/// One deliverable place: a street or neighbourhood inside a city district.
class DeliveryLocation {
  const DeliveryLocation({
    required this.id,
    required this.city,
    required this.district,
    required this.name,
  });

  final String id;
  final String city;

  /// District name without the word "district" — see [address].
  final String district;
  final String name;

  /// The line [LocationBar] shows under the city.
  String get address => '$district district, $name';

  /// Everything the search box matches against.
  String get _haystack => '$name $district $city'.toLowerCase();

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    return needle.isEmpty || _haystack.contains(needle);
  }
}

/// Picks a delivery address: type to filter, tap to choose, cancel to close.
///
/// Returns the chosen [DeliveryLocation], or null when dismissed. The sheet
/// stays white in both themes — it reads as a card floating over the page.
class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog({
    super.key,
    required this.locations,
    this.selectedId,
  });

  final List<DeliveryLocation> locations;
  final String? selectedId;

  static Future<DeliveryLocation?> show(
    BuildContext context, {
    required List<DeliveryLocation> locations,
    String? selectedId,
  }) {
    return showDialog<DeliveryLocation>(
      context: context,
      barrierColor: AppColors.black.withValues(
        alpha: context.isDark ? 0.7 : 0.45,
      ),
      builder: (_) =>
          LocationPickerDialog(locations: locations, selectedId: selectedId),
    );
  }

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final _query = TextEditingController();

  /// Tall enough to be worth scrolling, short enough to stay a dialog.
  static const _maxHeightFraction = 0.72;
  static const _maxWidth = 420.0;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  /// The filtered list, flattened into district headers and their places so a
  /// single [ListView] can render both.
  List<Object> get _rows {
    final rows = <Object>[];
    String? district;
    for (final location in widget.locations) {
      if (!location.matches(_query.text)) continue;
      if (location.district != district) {
        district = location.district;
        rows.add(district);
      }
      rows.add(location);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    return Dialog(
      backgroundColor: context.adapt(AppColors.white, AppColors.categoryDark),
      surfaceTintColor: AppColors.white,
      elevation: 12,
      shadowColor: AppColors.black.withValues(alpha: 0.2),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xxxl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _maxWidth,
          maxHeight: context.screenSize.height * _maxHeightFraction,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(controller: _query, onChanged: (_) => setState(() {})),
            Flexible(
              child: rows.isEmpty
                  ? const _EmptyResult()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      itemCount: rows.length,
                      itemBuilder: (context, index) => switch (rows[index]) {
                        final String district => _DistrictHeader(district),
                        final DeliveryLocation location => _LocationRow(
                          location: location,
                          selected: location.id == widget.selectedId,
                          onTap: () => Navigator.of(context).pop(location),
                        ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
            ),
            const _CancelBar(),
          ],
        ),
      ),
    );
  }
}

/// Title and search box, pinned above the scrolling list.
class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.locationTitle,
            style: AppTypography.textTheme.titleLarge?.copyWith(
              color: context.inkColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: controller,
            onChanged: onChanged,
            autofocus: true,
            textInputAction: TextInputAction.search,
            cursorColor: AppColors.primary,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: context.inkColor,
            ),
            decoration: InputDecoration(
              hintText: context.l10n.locationSearchHint,
              hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
              ),
              filled: true,
              fillColor: context.adapt(
                AppColors.grey100,
                AppColors.categoryDark,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.md,
                  0,
                ),
                child: SvgPicture.asset(
                  AppAssets.iconSearch,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.grey500,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              border: _border,
              enabledBorder: _border,
              focusedBorder: _border.copyWith(
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static final OutlineInputBorder _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.pill),
    borderSide: BorderSide.none,
  );
}

/// Groups the list by district, the way the addresses are organised.
class _DistrictHeader extends StatelessWidget {
  const _DistrictHeader(this.district);

  final String district;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        district.toUpperCase(),
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.grey500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// A single tappable address.
class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.location,
    required this.selected,
    required this.onTap,
  });

  final DeliveryLocation location;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected
        ? AppColors.primary
        : context.adapt(AppColors.grey700, AppColors.iconSoft);

    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primarySoft,
      highlightColor: AppColors.primarySoft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primarySoft
                    : context.adapt(AppColors.grey100, AppColors.categoryDark),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: SvgPicture.asset(
                AppAssets.iconMapPin,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: selected ? AppColors.primary : context.inkColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${location.district}, ${location.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const HugeIcon(
                icon: AppIcons.checkCircle,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the query matches nothing.
class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

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
          SvgPicture.asset(
            AppAssets.iconMapPin,
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              context.adapt(AppColors.grey300, const Color(0xFF404040)),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.locationEmpty,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Centred close action, separated from the list by a hairline.
class _CancelBar extends StatelessWidget {
  const _CancelBar();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.adapt(AppColors.grey300, const Color(0xFF404040)),
            width: 0.5,
          ),
        ),
      ),
      child: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: context.adapt(
              AppColors.grey700,
              AppColors.iconSoft,
            ),
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            textStyle: AppTypography.textTheme.labelLarge,
            shape: const RoundedRectangleBorder(),
          ),
          child: Text(context.l10n.commonCancel),
        ),
      ),
    );
  }
}
