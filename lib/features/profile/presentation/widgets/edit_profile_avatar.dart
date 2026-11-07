import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/constants/app_icons.dart';

/// Tappable avatar with a camera badge.
///
/// The circle itself is what the page centres on: the badge hangs off its
/// corner through an unclipped [Stack] rather than widening the box, which
/// is what used to push the avatar off-centre by half a badge.
///
/// With no photo it falls back to the customer's initials, and with no name
/// either — a fresh account that has only ever given a phone number — to a
/// person glyph, never to a placeholder name.
class EditProfileAvatar extends StatelessWidget {
  const EditProfileAvatar({
    super.key,
    required this.name,
    required this.onTap,
    this.imagePath,
    this.imageUrl,
    this.size = 96,
  });

  final String name;

  /// Local file of a freshly picked photo; wins over [imageUrl].
  final String? imagePath;

  /// The account's stored photo.
  final String? imageUrl;

  final VoidCallback onTap;
  final double size;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  bool get _hasPhoto => imagePath != null || imageUrl != null;

  @override
  Widget build(BuildContext context) {
    final badge = (size * 0.32).clamp(28.0, 40.0);

    return Center(
      child: Stack(
        // The badge overhangs the circle; without this it would be cut off
        // at the Stack's edge.
        clipBehavior: Clip.none,
        children: [
          _Circle(
            size: size,
            initials: _initials,
            imagePath: imagePath,
            imageUrl: imageUrl,
          ),
          Positioned(
            // Sits on the 45° diagonal, half over the edge — the same
            // offset on both axes, so it reads as deliberate at any size.
            right: -badge * 0.12,
            bottom: -badge * 0.12,
            child: _CameraBadge(
              size: badge,
              onTap: onTap,
              // A first photo is an "add"; a replacement is a retake.
              icon: _hasPhoto ? AppAssets.iconCamera : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({
    required this.size,
    required this.initials,
    this.imagePath,
    this.imageUrl,
  });

  final double size;
  final String initials;
  final String? imagePath;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final url = imageUrl;
    final hasPhoto = path != null || url != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallback = initials.isEmpty
        // No name yet: the design's orange avatar with the white figure,
        // filling the whole disc. The + badge on its corner adds the photo.
        ? AppAssetImage(AppAssets.avatarPlaceholder, width: size, height: size)
        : Text(
            initials,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF6E3A1E),
              fontWeight: FontWeight.w600,
            ),
          );

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primaryFade,
        shape: BoxShape.circle,
        boxShadow: hasPhoto
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(
                    alpha: isDark ? 0.35 : 0.16,
                  ),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      foregroundDecoration: hasPhoto
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.grey700 : AppColors.grey300,
              ),
            )
          : null,
      child: switch ((path, url)) {
        (final String file, _) => Image.file(
          File(file),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        ),
        (_, final String remote) => AppNetworkImage(
          url: remote,
          width: size,
          height: size,
          radius: 0,
        ),
        // No photo: initials, or a glyph when the account has no name yet.
        _ => fallback,
      },
    );
  }
}

/// The round button on the avatar's corner: a page-colored ring so it reads against
/// both a photo and the page, a soft shadow to lift it off the circle, and
/// its glyph optically centred.
class _CameraBadge extends StatelessWidget {
  const _CameraBadge({required this.size, required this.onTap, this.icon});

  final double size;
  final VoidCallback onTap;

  /// Null draws a `+` — nothing has been added yet.
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final glyph = icon;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            // Center rather than padding: a glyph sized in relation to the
            // badge stays centred at every avatar size.
            child: Center(
              child: glyph == null
                  ? HugeIcon(
                      icon: AppIcons.add,
                      size: size * 0.6,
                      color: AppColors.white,
                    )
                  : AppAssetImage(
                      glyph,
                      width: size * 0.48,
                      height: size * 0.48,
                      color: AppColors.white,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
