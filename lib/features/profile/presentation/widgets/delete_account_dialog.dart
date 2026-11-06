import 'package:flutter/material.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/constants/app_assets.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

/// Asks before `DELETE /auth/me`, and runs it.
///
/// Deleting an account is the one action in the app that cannot be undone,
/// so the dialog is built to be *hard to do by accident* rather than quick:
///
/// - it says plainly that this cannot be undone, and shows which account is
///   about to go, since a phone can have had more than one;
/// - keeping the account is the prominent, filled button and sits where the
///   thumb lands; deleting is the quiet one, and never the default action of
///   a stray Enter or an accidental tap outside;
/// - it owns the request, so the wait and any failure are shown in place
///   rather than as a toast over a dialog that has already closed.
///
/// Returns `true` once the account is gone.
Future<bool> showDeleteAccountDialog(
  BuildContext context, {
  required AuthCubit auth,
  String? phone,
}) async {
  final deleted = await showDialog<bool>(
    context: context,
    // The request is in flight for a second or two; a tap on the scrim must
    // not abandon it half-way.
    barrierDismissible: false,
    builder: (_) => _DeleteAccountDialog(auth: auth, phone: phone),
  );
  return deleted ?? false;
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.auth, this.phone});

  final AuthCubit auth;
  final String? phone;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _busy = false;
  Failure? _failure;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _failure = null;
    });

    final failure = await widget.auth.deleteAccount();
    if (!mounted) return;

    if (failure == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _busy = false;
      _failure = failure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final phone = widget.phone;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xxl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // Centred, not stretched: the buttons below size to their labels,
          // and the text above is centre-aligned anyway.
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _WarningGlyph(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.profileDeleteTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.profileDeleteMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
                height: 1.4,
              ),
            ),
            if (phone != null && phone.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.profileDeleteAccountOn(phone),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ],
            if (_failure != null) ...[
              const SizedBox(height: AppSpacing.md),
              // In place, not as a snackbar: the dialog is still open and
              // the customer has to decide whether to try again.
              Text(
                _failure!.localize(l10n),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            // Centred and only as wide as its label. The app's
            // `filledButtonTheme` stretches a button across the page and
            // stands it 52pt tall, which is right for a form's primary
            // action and far too heavy inside a dialog this size.
            FilledButton(
              // Keeping the account is still the obvious one. It goes dead
              // with everything else once the request is out: a delete
              // already sent cannot be called back by closing the dialog.
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                textStyle: theme.textTheme.labelLarge,
              ),
              child: Text(l10n.profileDeleteKeep),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: _busy ? null : _delete,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                textStyle: theme.textTheme.bodyMedium,
              ),
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: AppLoader(color: AppColors.error),
                    )
                  : Text(l10n.profileDeleteConfirm),
            ),
          ],
        ),
      ),
    );
  }
}

/// The red disc at the top. Carries the tone before a word is read.
class _WarningGlyph extends StatelessWidget {
  const _WarningGlyph();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: AppColors.errorSoft,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: AppAssetImage(AppAssets.iconTrash, width: 24, height: 24),
        ),
      ),
    );
  }
}
