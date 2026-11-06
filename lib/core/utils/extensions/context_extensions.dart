import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/app_spacing.dart';

/// Shorthands that cut the boilerplate in every widget build method.
extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;

  MediaQueryData get mq => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Picks [light] or [dark] by the current theme, so one fixed palette
  /// colour can follow dark mode without an `isDark` ternary at every site.
  Color adapt(Color light, Color dark) => isDark ? dark : light;

  /// Primary text / icon ink: near-black on light, white on dark.
  Color get inkColor => isDark ? Colors.white : const Color(0xFF1A1A1A);

  /// A solid "on" fill (an active chip): near-black on light, white on dark.
  Color get inkFill => isDark ? Colors.white : const Color(0xFF1A1A1A);

  /// What sits on [inkFill].
  Color get onInkFill => isDark ? const Color(0xFF1A1A1A) : Colors.white;

  /// Room the floating nav bar takes at the bottom of the screen. Pages
  /// that draw over it, or scroll under it, measure their clearance here.
  double get navBarHeight =>
      AppNavBar.heightFor(MediaQuery.viewPaddingOf(this).bottom);
}
