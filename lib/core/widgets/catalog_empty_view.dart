import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_asset_image.dart';

/// Shared layout for the empty cart and favorites screens.
class CatalogEmptyView extends StatelessWidget {
  const CatalogEmptyView({
    super.key,
    required this.illustration,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String illustration;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Transform.translate(
        offset: const Offset(0, -kToolbarHeight / 2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: title,
                image: true,
                child: AppAssetImage(illustration, width: 160, height: 160),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? context.adapt(
                            AppColors.grey300,
                            const Color(0xFF404040),
                          )
                        : context.adapt(AppColors.grey700, AppColors.iconSoft),
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                height: 46,
                child: FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE6D6),
                    foregroundColor: AppColors.primaryVibrant,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    elevation: 0,
                  ),
                  child: Text(
                    actionLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryVibrant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
