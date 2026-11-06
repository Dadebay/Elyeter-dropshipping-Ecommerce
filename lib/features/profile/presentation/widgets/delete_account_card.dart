import 'package:flutter/material.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/constants/app_assets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The destructive row at the bottom of a signed-in profile — deleting the
/// account. Drawn apart from the settings groups so it never reads as one
/// more setting, and deliberately quiet: outlined rather than filled, since
/// nothing here should invite a tap.
class DeleteAccountCard extends StatelessWidget {
  const DeleteAccountCard({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.errorSoft,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppAssetImage(AppAssets.iconTrash, width: 22, height: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
