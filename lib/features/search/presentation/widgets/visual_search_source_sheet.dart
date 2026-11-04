import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/constants/app_icons.dart';

/// hugeicons 1.x hands an icon over as JSON path data rather than [IconData].
typedef HugeIconData = List<List<dynamic>>;

/// Where the photo for a visual search comes from.
enum VisualSearchSource { camera, gallery }

/// Asks camera or gallery before anything is opened.
///
/// Two equal cards rather than a list: there are only two ways in, and giving
/// them the same weight makes the choice read at a glance.
class VisualSearchSourceSheet extends StatelessWidget {
  const VisualSearchSourceSheet({super.key});

  static Future<VisualSearchSource?> show(BuildContext context) {
    return showModalBottomSheet<VisualSearchSource>(
      context: context,
      backgroundColor: AppColors.white,
      barrierColor: AppColors.black.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => const VisualSearchSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Handle(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.l10n.visualSearchTitle,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.titleLarge?.copyWith(
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _SourceCard(
                      icon: AppIcons.camera,
                      label: context.l10n.visualSearchCamera,
                      onTap: () =>
                          Navigator.of(context).pop(VisualSearchSource.camera),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SourceCard(
                      icon: AppIcons.image,
                      label: context.l10n.visualSearchGallery,
                      onTap: () =>
                          Navigator.of(context).pop(VisualSearchSource.gallery),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grab handle: the sheet reads as draggable even though it is short.
class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final HugeIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.grey100,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primarySoft,
        highlightColor: AppColors.primarySoft,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: HugeIcon(icon: icon, size: 26, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
