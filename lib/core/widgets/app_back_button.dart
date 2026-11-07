import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_asset_image.dart';

/// The app's back affordance: a button with the chevron from
/// `assets/icons/back.svg`, outlined in dark mode and lifted by a faint
/// shadow in light mode.
///
/// Use [AppBackButton.appBarLeading] inside an [AppBar] together with
/// [AppBackButton.leadingWidth]; the bare constructor suits a [Stack] over
/// artwork.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.width = defaultWidth,
    this.buttonHeight = height,
    this.tint,
    this.icon,
    this.asset,
    this.semanticLabel,
  });

  /// Wrapped in the page inset, for `AppBar.leading`. Uses a wide pill by default.
  const factory AppBackButton.appBarLeading({
    Key? key,
    VoidCallback? onPressed,
    Color? tint,
    AppIconData? icon,
    double? width,
    double? buttonHeight,
  }) = _AppBarBackButton;

  /// The control's resting diameter. Exposed so a page drawing its own
  /// counterpart at the other end of the bar can match it — the category
  /// page's search button does.
  static const double defaultWidth = 44;
  static const double height = 44;
  static const double appBarWidth = 50;
  static const double appBarHeight = 36;
  static const double iconSize = 22;

  /// What `AppBar.leadingWidth` must be for the button to sit at the page
  /// inset without being squeezed by the toolbar's default 56pt slot.
  static const double leadingWidth =
      appBarWidth + AppSpacing.page + AppSpacing.sm;

  /// Figma: two drop shadows, #000000 at 8% — a wide soft one below
  /// (y 8, blur 30, spread -4) and a tight halo (blur 15, spread -6).
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 30,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
    BoxShadow(color: Color(0x14000000), blurRadius: 15, spreadRadius: -6),
  ];

  final VoidCallback? onPressed;
  final double width;
  final double buttonHeight;

  /// Chevron colour; defaults to the theme's ink.
  final Color? tint;
  final AppIconData? icon;

  /// An SVG from `assets/icons/` to draw instead of the chevron, so a
  /// counterpart at the other end of the bar (an "add" button) is the same
  /// pill, shadow and size as the back button.
  final String? asset;

  /// Read out by screen readers; defaults to the back-button label.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label:
          semanticLabel ?? MaterialLocalizations.of(context).backButtonTooltip,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey900 : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: isDark ? Border.all(color: AppColors.grey700) : null,
          boxShadow: isDark ? null : shadow,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed ?? () => Navigator.of(context).maybePop(),
            child: SizedBox(
              width: width,
              height: buttonHeight,
              child: Center(
                child: icon == null
                    ? AppAssetImage(
                        asset ?? AppAssets.iconBack,
                        width: iconSize,
                        height: iconSize,
                        color:
                            tint ?? (isDark ? AppColors.white : AppColors.ink),
                      )
                    : HugeIcon(
                        icon: icon!,
                        size: iconSize,
                        color:
                            tint ?? (isDark ? AppColors.white : AppColors.ink),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarBackButton extends AppBackButton {
  const _AppBarBackButton({
    super.key,
    super.onPressed,
    super.tint,
    super.icon,
    double? width,
    double? buttonHeight,
  }) : super(
         width: width ?? AppBackButton.appBarWidth,
         buttonHeight: buttonHeight ?? AppBackButton.appBarHeight,
       );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: AppSpacing.page),
    child: Align(
      alignment: Alignment.centerLeft,
      child: AppBackButton(
        onPressed: onPressed,
        tint: tint,
        icon: icon,
        width: width,
        buttonHeight: buttonHeight,
      ),
    ),
  );
}
