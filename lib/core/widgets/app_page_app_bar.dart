import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';

import '../theme/app_colors.dart';
import 'app_back_button.dart';

/// The app bar every pushed sub-page uses: centred bold title and the
/// shared back button, so pages do not each re-invent the header.
class AppPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppPageAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBack,
  });

  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      clipBehavior: Clip.none,
      centerTitle: true,
      leadingWidth: AppBackButton.leadingWidth,
      leading: AppBackButton.appBarLeading(onPressed: onBack),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.white : context.inkColor,
        ),
      ),
      actions: actions,
    );
  }
}
