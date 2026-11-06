import 'package:flutter/material.dart';

import '../../../../core/widgets/app_close_button.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// The chrome every filter sheet shares: a grab handle, a titled header with
/// a way out, a scrolling body and a footer that stays put.
///
/// The footer does not scroll with the body — on a long list of brands the
/// way to confirm must never be something the customer has to scroll to find.
class CategorySheet extends StatelessWidget {
  const CategorySheet({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.onReset,
    this.resetLabel,
  });

  /// Opens [builder] as a modal sheet, sized to its content but never taller
  /// than most of the screen.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: context.adapt(AppColors.white, AppColors.backgroundDark),
      barrierColor: AppColors.black.withValues(
        alpha: context.isDark ? 0.7 : 0.45,
      ),
      // A tall facet list scrolls inside the sheet rather than growing past
      // the top of the screen.
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      builder: builder,
    );
  }

  final String title;
  final Widget child;

  /// The confirming control. Absent on a sheet whose choices apply as they
  /// are made.
  final Widget? footer;

  /// Clears this sheet's own choices; hidden when there is nothing to clear.
  final VoidCallback? onReset;
  final String? resetLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Handle(),
          _Header(title: title, onReset: onReset, resetLabel: resetLabel),
          Divider(
            height: 1,
            color: context.adapt(AppColors.grey100, AppColors.categoryDark),
          ),
          Flexible(child: child),
          if (footer != null) ...[
            Divider(
              height: 1,
              color: context.adapt(AppColors.grey100, AppColors.categoryDark),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: footer,
            ),
          ],
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 4,
    margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    decoration: BoxDecoration(
      color: context.adapt(AppColors.grey300, const Color(0xFF404040)),
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
  );
}

/// Title in the middle, Reset on one side, close on the other.
class _Header extends StatelessWidget {
  const _Header({required this.title, this.onReset, this.resetLabel});

  final String title;
  final VoidCallback? onReset;
  final String? resetLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // A fixed-width slot each side keeps the title optically centred
          // whether or not Reset is showing.
          SizedBox(
            width: 72,
            child: onReset == null
                ? null
                : GestureDetector(
                    onTap: onReset,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      resetLabel ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleLarge?.copyWith(
                color: context.inkColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Align(
              alignment: Alignment.centerRight,
              child: const AppCloseButton(),
            ),
          ),
        ],
      ),
    );
  }
}

/// The wide confirming button at the foot of a sheet.
class CategorySheetAction extends StatelessWidget {
  const CategorySheetAction({super.key, required this.label, this.onTap});

  final String label;

  /// Null greys the button out — nothing to apply, nothing to press.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: enabled
          ? AppColors.primary
          : context.adapt(AppColors.grey100, AppColors.categoryDark),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: context.textTheme.bodyLarge?.copyWith(
                color: enabled ? AppColors.white : AppColors.grey500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
