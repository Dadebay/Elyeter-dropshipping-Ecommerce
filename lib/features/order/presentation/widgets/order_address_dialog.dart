import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

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
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.orderSelectAddressTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dialogContext.l10n.orderSelectAddressMessage),
              if (locations.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: (locations.length * 72.0).clamp(72.0, 288.0),
                  child: ListView.builder(
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(location.name),
                        subtitle: Text(
                          orderAddressText(location),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.of(dialogContext).pop(location),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(dialogContext.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(_addAddress),
            child: Text(dialogContext.l10n.addressAddNew),
          ),
        ],
      ),
    );
    if (!context.mounted) return null;
    if (choice is SavedLocation) return choice;
    if (choice != _addAddress) return null;

    await context.pushNamed(AppRoutes.addresses.name);
  }
  return null;
}

const _addAddress = 'add-address';
