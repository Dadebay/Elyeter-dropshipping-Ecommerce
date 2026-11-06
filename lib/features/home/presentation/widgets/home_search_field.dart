import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_typography.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../search/presentation/widgets/photo_search_launcher.dart';

/// Pill search box that opens the search page.
class HomeSearchField extends StatelessWidget {
  const HomeSearchField({
    super.key,
    this.onTap,
    this.controller,
    this.showCamera = true,
  });

  /// A camera button on the right that starts a search by photo.
  final bool showCamera;

  final VoidCallback? onTap;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onTap:
          onTap ??
          () {
            final box = context.findRenderObject() as RenderBox?;
            final anchor = box == null
                ? null
                : box.localToGlobal(Offset.zero) & box.size;
            context.pushNamed(AppRoutes.search.name, extra: anchor);
          },
      readOnly: true,
      canRequestFocus: false,
      textInputAction: TextInputAction.search,
      style: context.textTheme.bodyMedium?.copyWith(
        fontFamily: AppTypography.fontFamily,
        color: context.inkColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: context.l10n.homeSearchHint,
        hintStyle: context.textTheme.bodyMedium?.copyWith(
          fontFamily: AppTypography.fontFamily,
          color: context.inkColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        fillColor: context.adapt(AppColors.white, AppColors.backgroundDark),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0).copyWith(right: 8.0),
          child: _SearchIcon(AppAssets.iconSearch, color: context.inkColor),
        ),
        suffixIcon: showCamera
            ? IconButton(
                tooltip: context.l10n.visualSearchTitle,
                onPressed: () => startPhotoSearch(context),
                padding: const EdgeInsets.only(right: 8),
                icon: HugeIcon(
                  icon: AppIcons.camera,
                  size: 24,
                  color: context.inkColor,
                ),
              )
            : null,
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,
      ),
    );
  }

  static final OutlineInputBorder _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.pill),
    borderSide: BorderSide.none,
  );
}

/// One of the field's SVG icons, tinted and sized like the [Icon]s the rest
/// of the form uses.
class _SearchIcon extends StatelessWidget {
  const _SearchIcon(this.asset, {required this.color});

  final String asset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: _size,
      height: _size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  /// Matches the default [IconThemeData.size] the icons replace.
  static const double _size = 24;
}
