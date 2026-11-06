import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_asset_image.dart';

/// The address snapshot sent with an order and shown on its detail page.
String orderAddressText(SavedLocation location) => [
  location.address?.trim(),
  location.details?.trim(),
].whereType<String>().where((part) => part.isNotEmpty).join(', ');

/// Uses a saved default when there is one; otherwise asks the customer to
/// choose or create an address before an order can be submitted. Pass
/// [alwaysAsk] when the customer explicitly opens the picker to change it.
Future<SavedLocation?> requestOrderLocation(
  BuildContext context, {
  bool alwaysAsk = false,
}) async {
  while (context.mounted) {
    List<SavedLocation> locations;
    try {
      locations = (await getIt<ShopApi>().locations())
          .where((location) => orderAddressText(location).isNotEmpty)
          .toList();
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.orderAddressLoadFailed)),
        );
      }
      return null;
    }
    if (!context.mounted) return null;

    if (!alwaysAsk) {
      for (final location in locations) {
        if (location.isDefault) return location;
      }
    }

    final choice = await showDialog<Object>(
      context: context,
      builder: (_) => _AddressPickerDialog(locations: locations),
    );
    if (!context.mounted) return null;
    if (choice is SavedLocation) return choice;
    if (choice != _addAddress) return null;

    await context.pushNamed(AppRoutes.addresses.name);
  }
  return null;
}

const _addAddress = 'add-address';

/// A pin badge, the reason in two lines, the saved addresses as tappable
/// cards, then a full-width "add new" button with a quiet Cancel under it.
class _AddressPickerDialog extends StatelessWidget {
  const _AddressPickerDialog({required this.locations});

  final List<SavedLocation> locations;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = context.isDark;

    return Dialog(
      backgroundColor: isDark ? AppColors.categoryDark : AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.xxl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: AppAssetImage(
                  AppAssets.iconAddressMapPin,
                  width: 30,
                  height: 30,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.orderSelectAddressTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.orderSelectAddressMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
                height: 1.4,
              ),
            ),
            if (locations.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: locations.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) =>
                        _AddressTile(location: locations[index]),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_addAddress),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  l10n.addressAddNew,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  foregroundColor: AppColors.grey500,
                ),
                child: Text(l10n.commonCancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.location});

  final SavedLocation location;

  static String _icon(String type) => switch (type) {
    'home' => AppAssets.iconAddressHome,
    'work' => AppAssets.iconAddressWork,
    _ => AppAssets.iconAddressLocation,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDark;

    return Material(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: location.isDefault
              ? AppColors.primary
              : (isDark ? const Color(0xFF3A3A3A) : Colors.transparent),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(location),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.categoryDark : AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppAssetImage(
                    _icon(location.type),
                    width: 22,
                    height: 22,
                    color: context.inkColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      orderAddressText(location),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey500,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
