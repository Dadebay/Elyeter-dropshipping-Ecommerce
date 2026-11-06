import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/edit_profile_avatar.dart';
import '../widgets/edit_profile_field.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

/// Two things a customer can change about their account: the photo and the
/// display name. The phone number identifies the account, so it is shown
/// but not editable here.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  static const nameLimit = 40;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final ProfileState _initial;
  late String? _avatarPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initial = context.read<ProfileCubit>().state;
    _name = TextEditingController(text: _initial.name);
    _avatarPath = _initial.avatarPath;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Save stays disabled until there is actually something to save.
  bool get _dirty =>
      _name.text.trim() != _initial.name || _avatarPath != _initial.avatarPath;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phone = context.select((ProfileCubit c) => c.state.phone);

    return Scaffold(
      appBar: AppPageAppBar(title: l10n.editProfileTitle),
      body: Form(
        key: _formKey,
        // The name field validates as it is typed, so the button's enabled
        // state and the error text stay in step with each other.
        onChanged: () => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xl,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          children: [
            EditProfileAvatar(
              name: _name.text.isEmpty ? _initial.name : _name.text,
              imagePath: _avatarPath,
              size: 104,
              onTap: _pickPhoto,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: _pickPhoto,
                child: Text(l10n.editProfilePhoto),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            EditProfileTextField(
              label: l10n.editProfileName,
              controller: _name,
              hint: l10n.editProfileNameHint,
              textCapitalization: TextCapitalization.words,
              maxLength: EditProfilePage.nameLimit,
              counter: l10n.editProfileNameCounter(
                _name.text.characters.length,
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? l10n.editProfileNameRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            EditProfileField(
              label: l10n.editProfilePhone,
              note: l10n.editProfilePhoneNote,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      phone,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ),
                  const AppAssetImage(
                    AppAssets.iconLock,
                    width: 18,
                    height: 18,
                    color: AppColors.iconSoft,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Pinned: a two-field form should not make anyone scroll to save.
      bottomNavigationBar: _SaveBar(
        enabled: _dirty && !_saving,
        saving: _saving,
        label: l10n.commonSave,
        onPressed: _save,
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final l10n = context.l10n;

    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.editProfilePhoto,
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const HugeIcon(icon: AppIcons.camera),
              title: Text(l10n.editProfilePhotoCamera),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.camera),
            ),
            ListTile(
              leading: const HugeIcon(icon: AppIcons.gallery),
              title: Text(l10n.editProfilePhotoGallery),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.gallery),
            ),
            if (_avatarPath != null)
              ListTile(
                leading: const AppAssetImage(
                  AppAssets.iconTrash,
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  l10n.editProfilePhotoRemove,
                  style: const TextStyle(color: AppColors.error),
                ),
                onTap: () => Navigator.pop(sheetContext, _PhotoAction.remove),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    if (action == _PhotoAction.remove) {
      setState(() => _avatarPath = null);
      return;
    }

    final picked = await ImagePicker().pickImage(
      source: action == _PhotoAction.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      // The avatar is never drawn larger than ~104pt, so the picker is asked
      // for a quarter of what a camera would hand back, at 70% quality.
      maxWidth: ImageCompressor.maxDimension.toDouble(),
      maxHeight: ImageCompressor.maxDimension.toDouble(),
      imageQuality: 70,
    );
    if (picked == null || !mounted) return;

    // The picker's own limits are advisory — a gallery photo it cannot
    // re-encode comes back untouched — so the file is measured and, if it
    // is still over a megabyte, shrunk properly before it is kept.
    final path = await ImageCompressor.shrink(picked.path);
    if (!mounted) return;
    if (path == null) {
      AppSnackBar.show(
        context,
        context.l10n.editProfilePhotoTooLarge,
        icon: AppIcons.error,
        iconColor: AppColors.error,
      );
      return;
    }
    setState(() => _avatarPath = path);
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;

    final name = _name.text.trim();
    if (name != _initial.name) {
      final auth = context.read<AuthCubit>();
      final accountId = auth.state.user?.id;
      if (accountId == null) return;
      setState(() => _saving = true);
      final result = await getIt<AuthRepository>().updateProfile(
        username: name,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      if (auth.state.user?.id != accountId) return;
      if (result.dataOrNull case final updated?) {
        auth.onUserUpdated(updated);
      } else {
        AppSnackBar.show(
          context,
          result.failureOrNull!.localize(context.l10n),
          icon: AppIcons.error,
          iconColor: AppColors.error,
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      await context.read<ProfileCubit>().save(
        name: name,
        avatarPath: _avatarPath,
      );
      if (!mounted) return;
      AppSnackBar.show(context, context.l10n.editProfileSaved);
      Navigator.of(context).pop();
    } on Exception {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        context.l10n.errorCache,
        icon: AppIcons.error,
        iconColor: AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// Bottom bar holding the save button, above the home indicator.
class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.enabled,
    required this.saving,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final bool saving;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.grey700 : AppColors.surfaceMuted,
          ),
        ),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.md,
        ),
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          child: saving
              ? const SizedBox.square(dimension: 20, child: AppLoader())
              : Text(label),
        ),
      ),
    );
  }
}

enum _PhotoAction { camera, gallery, remove }
