import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_icons.dart';

/// Label above a filled box — the shared shape of every edit-profile row.
class EditProfileField extends StatelessWidget {
  const EditProfileField({
    super.key,
    required this.label,
    required this.child,
    this.note,
    this.trailing,
  });

  final String label;
  final Widget child;

  /// Small text at the end of the label row.
  final String? trailing;

  /// Small grey line under the box, e.g. why a field cannot be edited.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.iconSoft,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark
                : context.adapt(AppColors.surfaceMuted, AppColors.categoryDark),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: child,
        ),
        if (note != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            note!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ],
      ],
    );
  }
}

/// A field the user types into.
class EditProfileTextField extends StatelessWidget {
  const EditProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.maxLength,
    this.counter,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final int? maxLength;

  /// Shown at the end of the label row, e.g. `12/40`.
  final String? counter;

  @override
  Widget build(BuildContext context) {
    return EditProfileField(
      label: label,
      trailing: counter,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        maxLength: maxLength,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          filled: false,
          isDense: true,
          // The count lives next to the label, not inside the box.
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          // The error would otherwise sit inside the filled box.
          errorStyle: const TextStyle(height: 0.8),
        ),
      ),
    );
  }
}

/// A field that opens a picker instead of a keyboard.
class EditProfilePickerField extends StatelessWidget {
  const EditProfilePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder,
  });

  final String label;
  final String? value;
  final String? placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final empty = value == null || value!.isEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: EditProfileField(
        label: label,
        child: Row(
          children: [
            Expanded(
              child: Text(
                empty ? (placeholder ?? '') : value!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: empty ? AppColors.grey500 : null,
                ),
              ),
            ),
            const HugeIcon(
              icon: AppIcons.chevronDown,
              color: AppColors.iconSoft,
            ),
          ],
        ),
      ),
    );
  }
}
