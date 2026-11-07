import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/localization/failure_localizer.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/sign_in_required_dialog.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../product/domain/repositories/product_repository.dart';
import '../../../product/domain/entities/product_id.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/pre_order.dart';
import '../../domain/entities/pre_order_check.dart';
import '../../domain/entities/pre_order_line.dart';
import '../../domain/repositories/pre_order_repository.dart';
import '../widgets/order_address_dialog.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _comment = TextEditingController();
  List<PreOrderLine> _lines = [];
  PreOrderCheck? _check;
  List<SavedLocation> _savedLocations = [];
  int? _selectedLocationId;
  String? _error;
  bool _working = false;
  bool _ready = false;

  /// One per press of "Place order", kept through every retry of that press
  /// (a timeout, a 409 or 503) and dropped only once the order exists. A
  /// repeat then returns the order already made instead of making another.
  String? _idempotencyKey;

  static String _newKey() {
    final random = Random.secure();
    String hex(int n) =>
        List.generate(n, (_) => random.nextInt(16).toRadixString(16)).join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-'
        '${'89ab'[random.nextInt(4)]}${hex(3)}-${hex(12)}';
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final cubit = context.read<CartCubit>();
    await cubit.migrateLegacyProducts(getIt<ProductRepository>());
    if (!mounted) return;
    final cart = cubit.state;
    final selectedIds = cart.selectedIds.toList();
    final lines = <PreOrderLine>[];
    for (final id in selectedIds) {
      final productId = ProductId.tryParse(id);
      if (productId == null) continue;
      final detail = (await getIt<ProductRepository>().byId(
        productId,
      )).dataOrNull;
      if (detail == null) continue;
      final variantId = cart.variants[id];
      final variant = variantId == null
          ? null
          : detail.variants.where((v) => v.id == variantId).firstOrNull;
      lines.add(
        PreOrderLine(
          productId: detail.product.id,
          quantity: cart.quantityOf(id),
          variantId: variantId,
          // What the cart shows, so the server can say "was / now" honestly.
          price: variant?.price ?? detail.product.price,
        ),
      );
    }
    if (!mounted) return;
    if (context.read<AuthCubit>().state.isAuthenticated) {
      try {
        final locations = await getIt<ShopApi>().locations();
        if (mounted) {
          final defaults = locations.where(
            (location) =>
                location.isDefault && orderAddressText(location).isNotEmpty,
          );
          final selected = defaults.firstOrNull;
          setState(() {
            _savedLocations = locations;
            _selectedLocationId = selected?.id;
            _address.text = selected == null ? '' : orderAddressText(selected);
          });
        }
      } on Object {
        // The address picker retries loading before an order can be placed.
      }
    }
    if (!mounted) return;
    setState(() {
      _lines = lines;
      _ready = true;
      if (lines.length != selectedIds.length) {
        _error =
            'A product is no longer available. Remove it from the cart before ordering.';
      }
    });
    if (lines.length == selectedIds.length && lines.isNotEmpty) {
      await _verify();
    }
  }

  Future<void> _verify() async {
    if (_working ||
        _lines.isEmpty ||
        _error?.startsWith('A product is no longer') == true) {
      return;
    }
    if (!context.read<AuthCubit>().state.isAuthenticated) {
      if (!await promptSignIn(context) || !mounted) return;
    }
    setState(() {
      _working = true;
      _check = null;
      _error = null;
    });
    final result = await getIt<PreOrderRepository>().check(_lines);
    if (mounted) {
      setState(() {
        _check = result.dataOrNull;
        _error = result.failureOrNull?.localize(context.l10n);
        _working = false;
      });
    }
  }

  Future<void> _place() async {
    final check = _check;
    if (check == null || !check.available || _working) return;
    setState(() {
      _working = true;
      _error = null;
    });
    var address = _address.text.trim();
    if (_selectedLocationId == null || address.isEmpty) {
      final location = await requestOrderLocation(context);
      if (!mounted) return;
      if (location == null) {
        setState(() => _working = false);
        return;
      }
      address = orderAddressText(location);
      _useLocation(location);
    }
    final key = _idempotencyKey ??= _newKey();
    var result = await _create(check, address, key);
    // "Still being placed" is not an error: the earlier press is finishing.
    // Wait a couple of seconds and ask again with the same key.
    for (
      var attempt = 0;
      attempt < 5 &&
          mounted &&
          result.failureOrNull?.code == ApiCodes.preOrderInProgress;
      attempt++
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      if (!mounted) return;
      result = await _create(check, address, key);
    }
    if (!mounted) return;
    final order = result.dataOrNull;
    if (order != null) {
      _idempotencyKey = null;
      final cart = context.read<CartCubit>();
      for (final slug in cart.state.selectedIds.toList()) {
        cart.remove(slug);
      }
      // The cart underneath, the order on top, so back from the order has
      // somewhere to land.
      context.goNamed(AppRoutes.cart.name);
      unawaited(
        context.pushNamed(
          AppRoutes.orderDetail.name,
          pathParameters: {'id': order.id.toString()},
        ),
      );
      return;
    }
    setState(() {
      // A 409 carries the fresh check result (new prices, what ran out):
      // show it, and the next press sends its total as `expected_total`.
      _check = result.failureOrNull?.details.asPreOrderCheck ?? _check;
      _error = result.failureOrNull?.localize(context.l10n);
      _working = false;
    });
  }

  Future<Result<PreOrder>> _create(
    PreOrderCheck check,
    String address,
    String key,
  ) => getIt<PreOrderRepository>().create(
    lines: _lines,
    customerName: _name.text.trim().isEmpty ? null : _name.text.trim(),
    address: address,
    comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
    expectedTotal: check.totalPrice,
    locationId: _selectedLocationId,
    idempotencyKey: key,
  );

  void _selectLocation(int? id) {
    final matches = _savedLocations.where((location) => location.id == id);
    if (matches.isEmpty) return;
    _useLocation(matches.first);
  }

  void _useLocation(SavedLocation location) {
    setState(() {
      _savedLocations = [
        for (final saved in _savedLocations)
          if (saved.id == location.id) location else saved,
        if (!_savedLocations.any((saved) => saved.id == location.id)) location,
      ];
      _selectedLocationId = location.id;
      _address.text = orderAddressText(location);
    });
  }

  Future<void> _openSavedLocations() async {
    await context.pushNamed(AppRoutes.addresses.name);
    if (!mounted) return;
    try {
      final locations = await getIt<ShopApi>().locations();
      if (!mounted) return;
      setState(() {
        _savedLocations = locations;
        final selected = locations
            .where((location) => location.id == _selectedLocationId)
            .firstOrNull;
        final fallback = locations
            .where((location) => location.isDefault)
            .firstOrNull;
        final location = selected ?? fallback;
        _selectedLocationId = location?.id;
        _address.text = location == null ? '' : orderAddressText(location);
      });
    } on Object {
      // The address picker retries loading before an order can be placed.
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      clipBehavior: Clip.none,
      title: Text(context.l10n.commonCheckout),
    ),
    body: !_ready
        ? const Center(child: AppLoader())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_savedLocations.isNotEmpty)
                DropdownButtonFormField<int>(
                  key: ValueKey(_selectedLocationId),
                  initialValue: _selectedLocationId,
                  decoration: InputDecoration(
                    labelText: context.l10n.orderSelectAddressTitle,
                  ),
                  items: [
                    for (final location in _savedLocations)
                      DropdownMenuItem(
                        value: location.id,
                        child: Text(location.name),
                      ),
                  ],
                  onChanged: _selectLocation,
                ),
              TextButton.icon(
                onPressed: _openSavedLocations,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: Text(context.l10n.addressAddNew),
              ),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _address,
                readOnly: true,
                onTap: () async {
                  final location = await requestOrderLocation(
                    context,
                    alwaysAsk: true,
                  );
                  if (!mounted || location == null) return;
                  _useLocation(location);
                },
                decoration: InputDecoration(
                  labelText: context.l10n.orderPickupPoint,
                ),
              ),
              TextField(
                controller: _comment,
                decoration: const InputDecoration(labelText: 'Comment'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              if (_working) const Center(child: AppLoader()),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_check case final check?) ...[
                for (final item in check.items)
                  ListTile(
                    title: Text(item.name ?? '#${item.productId}'),
                    subtitle: Text(
                      [
                        if (item.variant != null) item.variant!,
                        if (item.message != null) item.message!,
                      ].join(' · '),
                    ),
                    trailing: Text(
                      item.lineTotal == null
                          ? item.status.name
                          : '${item.lineTotal} TMT',
                    ),
                  ),
                const Divider(),
                ListTile(
                  title: Text(context.l10n.commonTotal),
                  trailing: Text('${check.totalPrice} TMT'),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _working || _lines.isEmpty ? null : _verify,
                child: const Text('Check availability'),
              ),
              FilledButton(
                onPressed: _working || _check?.available != true
                    ? null
                    : _place,
                child: const Text('Place order'),
              ),
            ],
          ),
  );
}
