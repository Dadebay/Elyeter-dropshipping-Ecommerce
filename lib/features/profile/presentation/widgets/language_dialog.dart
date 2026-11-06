import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_close_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'language_flag.dart';

/// One choice in [showLanguageDialog].
class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.title,
    this.subtitle,
  });

  final String code;

  /// The language in its own words — `Türkmençe`, not `Turkmen`.
  final String title;

  /// The English name shown below the native name in the design.
  final String? subtitle;
}

const supportedLanguageOptions = <LanguageOption>[
  LanguageOption(code: 'en', title: 'English', subtitle: 'English'),
  LanguageOption(code: 'ru', title: 'Русский', subtitle: 'Russian'),
  LanguageOption(code: 'tk', title: 'Türkmençe', subtitle: 'Turkmen'),
];

/// Opens the floating language sheet. Returns the chosen code, or null when
/// the sheet is dismissed without choosing.
Future<String?> showLanguageDialog(
  BuildContext context, {
  required String? current,
}) {
  return showGeneralDialog<String>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.24),
    transitionDuration: const Duration(milliseconds: 260),
    transitionBuilder: (context, animation, secondaryAnimation, child) => child,
    pageBuilder: (sheetContext, animation, secondaryAnimation) =>
        _LanguageSheetOverlay(
          animation: animation,
          options: supportedLanguageOptions,
          current: current,
        ),
  );
}

class _LanguageSheetOverlay extends StatelessWidget {
  const _LanguageSheetOverlay({
    required this.animation,
    required this.options,
    required this.current,
  });

  static const _easeOut = Cubic(0.23, 1, 0.32, 1);

  final Animation<double> animation;
  final List<LanguageOption> options;
  final String? current;

  @override
  Widget build(BuildContext context) {
    final bottomGap = math.max(12.0, MediaQuery.viewPaddingOf(context).bottom);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedBuilder(
      animation: animation,
      child: _LanguageSheet(options: options, current: current),
      builder: (context, sheet) {
        // Apply ease-out in travel time for both directions.
        final progress = animation.status == AnimationStatus.reverse
            ? 1 - _easeOut.transform(1 - animation.value)
            : _easeOut.transform(animation.value);

        return SizedBox.expand(
          key: const Key('language-sheet-backdrop'),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: progress,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, bottomGap),
                  child: Opacity(
                    opacity: progress,
                    child: FractionalTranslation(
                      translation: Offset(
                        0,
                        reduceMotion ? 0 : (1 - progress) * 0.1,
                      ),
                      child: sheet,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.options, required this.current});

  final List<LanguageOption> options;
  final String? current;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final foreground = isDark ? AppColors.white : AppColors.ink;
    final groupColor = isDark ? AppColors.grey900 : AppColors.surfaceMuted;

    return Material(
      key: const Key('language-sheet'),
      color: isDark ? AppColors.surfaceDark : AppColors.white,
      borderRadius: BorderRadius.circular(32),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 390,
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/language_translate.svg',
                        width: 40,
                        height: 40,
                      ),
                      Positioned(
                        right: 0,
                        child: Transform.translate(
                          offset: const Offset(0, -4),
                          child: const AppCloseButton(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.settingsLanguageDialogTitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontFamily: AppTypography.fontFamily,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.settingsLanguageDialogSubtitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontFamily: AppTypography.fontFamily,
                    color: isDark ? AppColors.grey300 : AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 26),
                Material(
                  color: groupColor,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < options.length; index++) ...[
                        _LanguageRow(
                          option: options[index],
                          selected: options[index].code == current,
                          onTap: () =>
                              Navigator.of(context).pop(options[index].code),
                        ),
                        if (index < options.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.white,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = context.isDark ? AppColors.white : AppColors.ink;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 62,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              LanguageFlag(
                languageCode: option.code,
                semanticsLabel: option.title,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                    if (option.subtitle != null) ...[
                      Text(
                        option.subtitle!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontFamily: AppTypography.fontFamily,
                          color: context.isDark
                              ? AppColors.grey300
                              : AppColors.grey700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                HugeIcon(
                  icon: AppIcons.check,
                  size: 28,
                  strokeWidth: 2.5,
                  color: foreground,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
