import 'package:flutter/material.dart';

/// Raw color palette. Never reference these directly from widgets —
/// go through `Theme.of(context).colorScheme` or [AppTheme] instead.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFFFF6B35);
  static const primaryVibrant = Color(0xFFFF6600);
  static const primaryDark = Color(0xFFE2541F);
  static const primarySoft = Color(0xFFFFF1EA);

  /// The pale end of the brand gradient — see `AppColors.primaryGradient`.
  static const primaryFade = Color(0xFFFFBE93);

  /// Runs down the surface: saturated at the top, pale at the bottom.
  static const primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryFade],
  );

  // Neutrals
  static const black = Color(0xFF1A1A1A);

  /// Design-system `ink`: label and title text.
  static const ink = Color(0xFF171717);

  /// Design-system `icon/soft-400`: the grey the row icons are drawn in.
  static const iconSoft = Color(0xFFA3A3A3);

  /// Design-system `text/disabled-300`: placeholder and disabled copy.
  static const textDisabled = Color(0xFFD4D4D4);

  /// Fill behind grouped rows and cards on a white page.
  static const surfaceMuted = Color(0xFFF5F5F5);
  static const grey900 = Color(0xFF2B2B2B);
  static const grey700 = Color(0xFF5C5C5C);
  static const grey500 = Color(0xFF8E8E93);
  static const grey300 = Color(0xFFD1D1D6);
  static const grey100 = Color(0xFFF2F2F7);
  static const background = Color(0xFFF7F7F7);
  static const surface = Color(0xFFFFFFFF);
  static const white = Color(0xFFFFFFFF);

  // Dark surfaces
  static const backgroundDark = Color(0xFF171717);
  static const surfaceDark = Color(0xFF1E1E1E);

  /// Category card fill behind the (transparent) artwork: dark / light mode.
  static const categoryDark = Color(0xFF262626);
  static const categoryLight = Color(0xFFF7F7F7);

  // Semantic — order statuses in the designs
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFF5A623);
  static const error = Color(0xFFE74C3C);

  /// Fill behind a destructive action — the swipe-to-delete panel.
  static const errorSoft = Color(0xFFFDECEC);
  static const info = Color(0xFF2F80ED);
}
