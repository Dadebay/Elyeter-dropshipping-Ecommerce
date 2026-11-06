import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// A single destination of [AppBottomNavBar].
class AppNavItem {
  const AppNavItem({
    required this.asset,
    required this.label,
    this.iconKey,
    this.badgeCount = 0,
  });

  /// Path to an SVG in `assets/icons`.
  final String asset;
  final String label;

  /// Attached to this tab's icon so its on-screen position can be found
  /// later — the cart tab uses `CartFlyAnimation.cartIconKey` as the target
  /// for the add-to-cart flourish.
  final Key? iconKey;

  /// Drawn over the icon's top-right corner; 0 hides the badge.
  final int badgeCount;
}

/// Floating pill-shaped navigation bar: the active tab sits in a soft orange
/// capsule with its icon and label tinted to the brand color.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.accentColor = AppColors.primary,
  });

  /// Tab icons in navigation order. Labels come from the caller so they can be
  /// localized — see `HomeShell`.
  static const List<String> assets = [
    AppAssets.iconHome,
    AppAssets.iconCategory,
    AppAssets.iconCart,
    AppAssets.iconFavorite,
    AppAssets.iconProfile,
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Sit above the home indicator instead of running underneath it: the
    // system inset is added as outside padding, not consumed by the bar.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        (bottomInset > 0 ? bottomInset : AppNavBar.fallbackInset) +
            AppNavBar.bottomGap,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(34),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppNavBar.verticalPadding,
            vertical: AppNavBar.verticalPadding,
          ),
          // A fixed height is what lets the highlight below size itself as a
          // fraction of the row instead of hugging one tab's content.
          child: SizedBox(
            height: AppNavBar.rowHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The highlight is a single layer that slides between tabs
                // rather than one background per tab fading in and out.
                AnimatedAlign(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  alignment: _highlightAlignment(currentIndex, items.length),
                  child: FractionallySizedBox(
                    widthFactor: 1 / items.length,
                    heightFactor: 1,
                    // Re-keying on the index restarts the pop-in every time
                    // the highlight lands on a new tab.
                    child: _Highlight(
                      key: ValueKey(currentIndex),
                      accentColor: accentColor,
                      isDark: isDark,
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavButton(
                          item: items[i],
                          selected: i == currentIndex,
                          accentColor: accentColor,
                          onTap: () => onTap(i),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Alignment _highlightAlignment(int index, int itemCount) {
    if (itemCount <= 1) return Alignment.center;
    return Alignment(-1 + (2 * index / (itemCount - 1)), 0);
  }
}

/// The moving background behind the active tab. Pops in with a slight
/// overshoot each time it arrives.
class _Highlight extends StatelessWidget {
  const _Highlight({
    super.key,
    required this.accentColor,
    required this.isDark,
  });

  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      // Glass: a light-catching gradient of the accent (#FF6600 at ~16%),
      // a hairline lit edge, and a faint highlight along the top.
      child: DecoratedBox(
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: isDark ? 0.26 : 0.20),
              accentColor.withValues(alpha: isDark ? 0.16 : 0.10),
            ],
          ),
          shape: StadiumBorder(
            side: BorderSide(
              color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.55),
              width: 0.75,
            ),
          ),
        ),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Colors.white.withValues(alpha: isDark ? 0.06 : 0.35),
                Colors.white.withValues(alpha: 0),
              ],
            ),
            shape: const StadiumBorder(),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idleColor = isDark ? AppColors.white : const Color(0xFF171717);
    final color = selected ? accentColor : idleColor;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Keyed on `selected` so the tween restarts on every selection:
            // the icon springs from 0.7 to full size.
            // The outer key marks this icon's position for the add-to-cart
            // flourish; the inner one restarts the spring on every selection.
            // The outer key marks this icon's position for the add-to-cart
            // flourish; the inner one restarts the spring on every selection.
            KeyedSubtree(
              key: item.iconKey,
              child: Stack(
                // The badge overhangs the icon's box on purpose.
                clipBehavior: Clip.none,
                children: [
                  TweenAnimationBuilder<double>(
                    key: ValueKey(selected),
                    tween: Tween(begin: selected ? 0.7 : 1, end: 1),
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: color),
                      duration: const Duration(milliseconds: 250),
                      builder: (context, tint, _) => SvgPicture.asset(
                        item.asset,
                        width: 26,
                        height: 26,
                        colorFilter: ColorFilter.mode(
                          tint ?? color,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  if (item.badgeCount > 0)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: _Badge(count: item.badgeCount),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              // Design spec: Inter Display 10px / Medium 500 /
              // line height 100% / letter spacing 0 / centered.
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1,
                letterSpacing: 0,
                leadingDistribution: TextLeadingDistribution.even,
                color: color,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item count over a tab's icon. Springs in whenever the number changes, so
/// an add lands visibly at the end of the fly-to-cart flight.
class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  /// Past this the badge would grow wider than the icon.
  static const _max = 99;

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      key: ValueKey(count),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        constraints: const BoxConstraints(minWidth: 17),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          // A ring in the bar's own colour lifts the badge off the icon.
          border: Border.all(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            width: 1.5,
          ),
        ),
        child: Text(
          count > _max ? '$_max+' : '$count',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
