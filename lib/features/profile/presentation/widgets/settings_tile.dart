import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/constants/app_icons.dart';
import 'language_flag.dart';

/// What sits at the end of a settings row.
sealed class TileTrailing {
  const TileTrailing();
}

/// A plain chevron — the row opens another page.
class TileChevron extends TileTrailing {
  const TileChevron();
}

/// Current value plus the chevron, e.g. the selected language.
class TileValue extends TileTrailing {
  const TileValue(this.value);
  final String value;
}

/// A selected language flag at the far end of the row.
class TileFlag extends TileTrailing {
  const TileFlag({required this.languageCode, required this.label});

  final String languageCode;
  final String label;
}

/// An inline switch, e.g. dark mode.
class TileSwitch extends TileTrailing {
  const TileSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
}

/// Leaves the app — shown with an outward arrow.
class TileExternal extends TileTrailing {
  const TileExternal();
}

/// One row of a settings group.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    this.icon,
    this.hugeIcon,
    this.hugeIconStrokeWidth,
    this.verticalPadding,
    this.labelWeight,
    required this.label,
    this.trailing = const TileChevron(),
    this.onTap,
  }) : assert((icon == null) != (hugeIcon == null));

  /// Path to an SVG in `assets/icons`.
  final String? icon;
  final AppIconData? hugeIcon;
  final double? hugeIconStrokeWidth;
  final double? verticalPadding;
  final FontWeight? labelWeight;
  final String label;
  final TileTrailing trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Design system: icons are `icon/soft-400`, labels are `ink`.
    final iconColor = isDark ? AppColors.grey500 : AppColors.iconSoft;
    final chevronColor = iconColor;
    final labelColor = isDark ? AppColors.white : AppColors.ink;

    return Ink(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceMuted,
      child: InkWell(
        onTap: switch (trailing) {
          TileSwitch(:final value, :final onChanged) => () => onChanged(!value),
          _ => onTap,
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            // The 34pt flag needs less inset than a 24pt chevron so both
            // settings rows keep the same overall height.
            vertical:
                verticalPadding ?? (trailing is TileFlag ? 7 : AppSpacing.md),
          ),
          child: Row(
            children: [
              if (hugeIcon case final data?)
                HugeIcon(
                  icon: data,
                  size: 22,
                  color: iconColor,
                  strokeWidth: hugeIconStrokeWidth,
                )
              else
                AppAssetImage(icon!, width: 22, height: 22, color: iconColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: labelWeight ?? FontWeight.w600,
                  ),
                ),
              ),
              switch (trailing) {
                TileChevron() => AppAssetImage(
                  AppAssets.iconChevronRight,
                  width: 20,
                  height: 20,
                  color: chevronColor,
                ),
                TileExternal() => AppAssetImage(
                  AppAssets.iconExternalLink,
                  width: 20,
                  height: 20,
                  color: chevronColor,
                ),
                TileValue(:final value) => Row(
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    AppAssetImage(
                      AppAssets.iconChevronGrabberVertical,
                      width: 22,
                      height: 22,
                      color: chevronColor,
                    ),
                  ],
                ),
                TileFlag(:final languageCode, :final label) => LanguageFlag(
                  languageCode: languageCode,
                  semanticsLabel: label,
                ),
                // iOS-style on every platform, as the design shows it.
                TileSwitch(:final value, :final onChanged) => Transform.scale(
                  scale: 0.8,
                  alignment: Alignment.centerRight,
                  transformHitTests: false,
                  child: CupertinoSwitch(
                    value: value,
                    onChanged: onChanged,
                    activeTrackColor: AppColors.primary,
                  ),
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}
