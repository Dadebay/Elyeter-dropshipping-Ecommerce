import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/constants/app_icons.dart';

/// The two cards at the top of the profile page: who is signed in, and a
/// shortcut into the order list.
class ProfileSummaryCards extends StatelessWidget {
  const ProfileSummaryCards({
    super.key,
    required this.name,
    required this.editLabel,
    required this.ordersTitle,
    required this.ordersSubtitle,
    this.phone,
    this.avatarUrl,
    this.avatarPath,
    this.onEditProfile,
    this.onOrders,
  });

  final String name;

  /// The account's number, shown under [name]. Left out when it is already
  /// standing in as the title, which is the case for an account that has
  /// never been given a name.
  final String? phone;

  final String editLabel;
  final String ordersTitle;
  final String ordersSubtitle;
  final String? avatarUrl;

  /// Local file of a photo picked on the edit page.
  final String? avatarPath;
  final VoidCallback? onEditProfile;
  final VoidCallback? onOrders;

  /// "Myradow Maksat" -> "MM".
  ///
  /// Empty when there is nothing to take initials from — which is also the
  /// case when [name] is standing in as the account's phone number, since
  /// "+9" is not an initial. That puts a person glyph in the circle.
  String get _initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (word) =>
              word.isNotEmpty &&
              RegExp(r'^\p{L}', unicode: true).hasMatch(word),
        );
    return words
        .take(2)
        .map((word) => word.characters.first.toUpperCase())
        .join();
  }

  /// The number, unless the title is already showing it — in which case the
  /// card falls back to naming what tapping it does.
  String get _subtitle {
    final number = phone?.trim() ?? '';
    if (number.isEmpty || number == name.trim()) return editLabel;
    return number;
  }

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight so both cards match the taller one; a bare stretch Row
    // would ask for infinite height inside a scroll view.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Card(
              onTap: onEditProfile,
              leading: _Avatar(
                initials: _initials,
                imageUrl: avatarUrl,
                imagePath: avatarPath,
              ),
              title: name,
              // The number identifies the account, so it is worth more
              // under a name than a label repeating what tapping does.
              subtitle: _subtitle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _Card(
              onTap: onOrders,
              leading: const _OrdersGlyph(),
              title: ordersTitle,
              subtitle: ordersSubtitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, this.imageUrl, this.imagePath});

  final String initials;
  final String? imageUrl;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final fallback = initials.isEmpty
        ? const HugeIcon(icon: AppIcons.user, size: 24, color: AppColors.white)
        : Text(
            initials,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF6E3A1E),
              fontWeight: FontWeight.w600,
            ),
          );
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.primaryFade,
        shape: BoxShape.circle,
      ),
      child: switch ((imagePath, imageUrl)) {
        (final String path, _) => Image.file(
          File(path),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        ),
        (_, final String url) => Image.network(
          url,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        ),
        _ => fallback,
      },
    );
  }
}

class _OrdersGlyph extends StatelessWidget {
  const _OrdersGlyph();

  @override
  Widget build(BuildContext context) => const SizedBox(
    // Same height as the avatar beside it, so both titles line up.
    height: 44,
    child: Align(
      alignment: Alignment.centerLeft,
      child: AppAssetImage(AppAssets.iconCubic, width: 38, height: 38),
    ),
  );
}
