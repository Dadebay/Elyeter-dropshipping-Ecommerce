import 'package:flutter/material.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_back_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_page_app_bar.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../widgets/delete_address_dialog.dart';
import 'address_map_picker_page.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  /// The most addresses the app lets a customer keep: Home, Work and one
  /// more. The backend itself would accept up to 10.
  static const _maxAddresses = 3;

  List<SavedLocation> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await getIt<ShopApi>().locations();
      if (mounted) setState(() => _items = items);
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit({
    SavedLocation? current,
    String initialType = 'home',
    String? initialName,
  }) async {
    final values = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddressMapPickerPage(
          current: current,
          initialType: initialType,
          initialName: initialName,
        ),
      ),
    );
    if (values == null || !mounted) return;
    try {
      if (current == null) {
        await getIt<ShopApi>().createLocation(values);
      } else {
        await getIt<ShopApi>().updateLocation(current.id, values);
      }
      await _load();
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _confirmRemove(SavedLocation item) async {
    final confirmed = await showDeleteAddressDialog(context, name: item.name);
    if (confirmed && mounted) await _remove(item);
  }

  Future<void> _remove(SavedLocation item) async {
    try {
      await getIt<ShopApi>().deleteLocation(item.id);
      await _load();
      if (mounted) AppSnackBar.show(context, context.l10n.addressDeleteDone);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _makeDefault(SavedLocation item) async {
    try {
      await getIt<ShopApi>().setDefaultLocation(item.id);
      await _load();
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _showActions(SavedLocation item) async {
    final action = await showModalBottomSheet<_AddressAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const AppAssetImage(
                AppAssets.iconEdit,
                width: 24,
                height: 24,
              ),
              title: Text(context.l10n.addressEdit),
              onTap: () => Navigator.of(sheetContext).pop(_AddressAction.edit),
            ),
            if (!item.isDefault)
              ListTile(
                leading: const HugeIcon(icon: AppIcons.checkCircle),
                title: Text(context.l10n.addressMakeDefault),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_AddressAction.makeDefault),
              ),
            ListTile(
              leading: const AppAssetImage(
                AppAssets.iconTrash,
                width: 24,
                height: 24,
              ),
              title: Text(context.l10n.addressDelete),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_AddressAction.delete),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _AddressAction.edit:
        await _edit(current: item);
      case _AddressAction.makeDefault:
        await _makeDefault(item);
      case _AddressAction.delete:
        await _confirmRemove(item);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppPageAppBar(
      title: context.l10n.addressListTitle,
      actions: !_loading && _error == null && _items.length < _maxAddresses
          ? [
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.sm,
                  right: AppSpacing.page,
                ),
                child: Center(
                  child: _AddAddressButton(
                    onTap: () => _edit(initialType: 'other'),
                  ),
                ),
              ),
            ]
          : null,
    ),
    body: _loading && _items.isEmpty
        ? const Center(child: AppLoader())
        : _error != null && _items.isEmpty
        ? Center(
            child: TextButton(onPressed: _load, child: Text(_error!)),
          )
        : AppRefreshIndicator(
            onRefresh: _load,
            child: _items.isEmpty
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            AppSpacing.lg,
                            AppSpacing.page,
                            0,
                          ),
                          child: _EmptyAddresses(
                            onAddWork: () => _edit(
                              initialType: 'work',
                              initialName: context.l10n.addressNameWork,
                            ),
                            onAddHome: () => _edit(
                              initialType: 'home',
                              initialName: context.l10n.addressNameHome,
                            ),
                            onAddNew: () => _edit(initialType: 'other'),
                          ),
                        ),
                      ),
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: SizedBox.shrink(),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      AppSpacing.lg,
                      AppSpacing.page,
                      AppSpacing.lg,
                    ),
                    children: [
                      for (final item in _items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _AddressCard(
                            item: item,
                            onTap: () => _edit(current: item),
                            onEdit: () => _edit(current: item),
                            onMore: () => _showActions(item),
                          ),
                        ),
                      // Home and Work are added on their own rows for as long
                      // as the list lacks one, and "other" on a last row, until
                      // the list holds [_maxAddresses].
                      if (_items.length < _maxAddresses) ...[
                        if (!_items.any((item) => item.type == 'work'))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _AddAddressRow(
                              label: context.l10n.addressAddWork,
                              onTap: () => _edit(
                                initialType: 'work',
                                initialName: context.l10n.addressNameWork,
                              ),
                            ),
                          ),
                        if (!_items.any((item) => item.type == 'home'))
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _AddAddressRow(
                              label: context.l10n.addressAddHome,
                              onTap: () => _edit(
                                initialType: 'home',
                                initialName: context.l10n.addressNameHome,
                              ),
                            ),
                          ),
                        _AddAddressRow(
                          label: context.l10n.addressAddNew,
                          onTap: () => _edit(initialType: 'other'),
                        ),
                      ],
                    ],
                  ),
          ),
  );
}

enum _AddressAction { edit, makeDefault, delete }

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses({
    required this.onAddWork,
    required this.onAddHome,
    required this.onAddNew,
  });

  final VoidCallback onAddWork;
  final VoidCallback onAddHome;
  final VoidCallback onAddNew;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _AddAddressRow(label: context.l10n.addressAddWork, onTap: onAddWork),
      const SizedBox(height: AppSpacing.sm),
      _AddAddressRow(label: context.l10n.addressAddHome, onTap: onAddHome),
      const SizedBox(height: AppSpacing.sm),
      _AddAddressRow(label: context.l10n.addressAddNew, onTap: onAddNew),
    ],
  );
}

class _AddAddressRow extends StatelessWidget {
  const _AddAddressRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                HugeIcon(
                  icon: AppIcons.add,
                  size: 26,
                  color: isDark ? AppColors.white : AppColors.ink,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: isDark ? AppColors.white : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The "add" counterpart of the back button: the same pill, shadow and size.
class _AddAddressButton extends StatelessWidget {
  const _AddAddressButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: context.l10n.addressAddNew,
    child: AppBackButton(
      asset: AppAssets.iconAdd,
      semanticLabel: context.l10n.addressAddNew,
      width: AppBackButton.appBarWidth,
      buttonHeight: AppBackButton.appBarHeight,
      onPressed: onTap,
    ),
  );
}

/// A compact saved address row. Secondary actions live in its long-press menu.
class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onMore,
  });

  final SavedLocation item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onMore;

  String get _iconAsset => switch (item.type) {
    'home' => AppAssets.iconAddressHome,
    'work' => AppAssets.iconAddressWork,
    _ => AppAssets.iconAddressLocation,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detail = (item.address?.isNotEmpty ?? false)
        ? item.address!
        : (item.details ?? '');

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onMore,
        child: Padding(
          // Less on the right: the edit button brings its own tap padding.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                SvgPicture.asset(
                  _iconAsset,
                  width: 28,
                  height: 28,
                  colorFilter: isDark
                      ? const ColorFilter.mode(AppColors.white, BlendMode.srcIn)
                      : null,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (detail.isNotEmpty)
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.grey300
                                : AppColors.grey700,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  tooltip: context.l10n.addressEdit,
                  onPressed: onEdit,
                  // Snug: 24 px glyph with 6 px around it instead of the
                  // 48 px default box, so it sits closer to the card edge.
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const AppAssetImage(
                    AppAssets.iconEdit,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
