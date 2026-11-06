import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../utils/extensions/context_extensions.dart';

/// The close button every sheet and dialog shares: a 40 x 40 round
/// `bg/weak-50` (#F7F7F7) disc with the X inside, 4px of padding around it.
class AppCloseButton extends StatelessWidget {
  const AppCloseButton({super.key, this.onPressed});

  static const size = 40.0;

  /// Defaults to closing the route the button sits on.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: context.l10n.commonClose,
      child: Material(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F7F7),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: SizedBox(
            width: size,
            height: size,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                AppAssets.iconCrossSmall,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
