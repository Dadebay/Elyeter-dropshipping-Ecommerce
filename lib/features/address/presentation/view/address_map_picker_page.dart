import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/widgets/app_loader.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/network/shop_api.dart';
import '../../../../core/services/address_lookup_service.dart';
import '../../../../core/services/device_location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/settings_opener.dart';
import '../../../../core/widgets/elyeter_map.dart';

class AddressMapPickerPage extends StatefulWidget {
  const AddressMapPickerPage({
    super.key,
    this.current,
    this.initialType = 'home',
    this.initialName,
    this.locationService,
    this.addressLookupService,
    this.autoLocate,
  });
  final SavedLocation? current;
  final String initialType;
  final String? initialName;
  final DeviceLocationService? locationService;
  final AddressLookupService? addressLookupService;

  /// Ask for permission and find the device as soon as the page opens, for a
  /// new address. An address being edited keeps its saved point.
  final bool? autoLocate;

  /// What [autoLocate] falls back to. Tests that open this page through the
  /// address list switch it off, since there is no device to locate.
  @visibleForTesting
  static bool autoLocateByDefault = true;

  @override
  State<AddressMapPickerPage> createState() => _AddressMapPickerPageState();
}

class _AddressMapPickerPageState extends State<AddressMapPickerPage> {
  /// Height of the form inside the sheet, from its top edge to just under
  /// the Save button.
  static const _sheetContentHeight = 436.0;

  static const _floorSeparator = ' · Floor: ';

  final _mapController = MapController();
  late final _location = widget.locationService ?? DeviceLocationService();
  late final _addressLookup =
      widget.addressLookupService ?? DeviceAddressLookupService();
  late final _name = TextEditingController(
    text: widget.current?.name ?? widget.initialName,
  );
  late final _address = TextEditingController(text: widget.current?.address);
  late final _apartment = TextEditingController(text: _initialApartment());
  late final _floor = TextEditingController(text: _initialFloor());
  late LatLng _point = widget.current == null
      ? ElyeterMap.defaultCenter
      : LatLng(widget.current!.latitude, widget.current!.longitude);
  late final String _type = widget.current?.type ?? widget.initialType;
  late bool _pointConfirmed = widget.current != null;
  bool _locating = false;
  bool _dragging = false;
  bool _resolvingAddress = false;
  String? _message;
  LocationProblem? _locationProblem;
  int _lookupRequest = 0;
  Timer? _mapLookupTimer;

  @override
  void initState() {
    super.initState();
    if ((widget.autoLocate ?? AddressMapPickerPage.autoLocateByDefault) &&
        widget.current == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_locate());
      });
    }
  }

  String _initialApartment() {
    final details = widget.current?.details ?? '';
    if (details.startsWith('Floor: ')) return '';
    final separator = details.lastIndexOf(_floorSeparator);
    return separator < 0 ? details : details.substring(0, separator);
  }

  String _initialFloor() {
    final details = widget.current?.details ?? '';
    if (details.startsWith('Floor: ')) return details.substring(7);
    final separator = details.lastIndexOf(_floorSeparator);
    return separator < 0
        ? ''
        : details.substring(separator + _floorSeparator.length);
  }

  String _combinedDetails() {
    final apartment = _apartment.text.trim();
    final floor = _floor.text.trim();
    if (floor.isEmpty) return apartment;
    if (apartment.isEmpty) return 'Floor: $floor';
    return '$apartment$_floorSeparator$floor';
  }

  @override
  void dispose() {
    _mapLookupTimer?.cancel();
    _mapController.dispose();
    _name.dispose();
    _address.dispose();
    _apartment.dispose();
    _floor.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    if (_locating) return;
    _mapLookupTimer?.cancel();
    final request = ++_lookupRequest;
    setState(() {
      _locating = true;
      _dragging = false;
      _resolvingAddress = false;
      _message = null;
      _locationProblem = null;
    });
    try {
      final point = await _location.locate();
      if (!mounted) return;
      _mapController.move(point, 16);
      _address.clear();
      setState(() {
        _point = point;
        _pointConfirmed = true;
        _resolvingAddress = true;
        if (_location.lastFixWasApproximate) {
          _message = context.l10n.addressLocationApproximate;
        }
      });
      await _resolveAddress(point, request, _address.text);
    } on LocationLookupException catch (error) {
      if (mounted) {
        final l10n = context.l10n;
        setState(() {
          _locationProblem = error.problem;
          _message = switch (error.problem) {
            LocationProblem.serviceOff => l10n.addressLocationServiceOff,
            LocationProblem.denied || LocationProblem.deniedForever =>
              l10n.addressLocationPermissionDenied,
            _ => l10n.addressLocationFailed,
          };
        });
      }
    } on Object {
      if (mounted) {
        setState(() => _message = context.l10n.addressLocationFailed);
      }
    } finally {
      if (mounted) {
        setState(() {
          _locating = false;
          if (request == _lookupRequest) _resolvingAddress = false;
        });
      }
    }
  }

  void _mapMoved(LatLng point, bool hasGesture) {
    _point = point;
    if (!hasGesture || !mounted) return;
    final request = ++_lookupRequest;
    _mapLookupTimer?.cancel();
    if (!_dragging) {
      _address.clear();
    }
    setState(() {
      _dragging = true;
      _resolvingAddress = true;
      _pointConfirmed = true;
      _message = null;
    });
    final addressBeforeLookup = _address.text;
    _mapLookupTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || request != _lookupRequest) return;
      setState(() => _dragging = false);
      unawaited(_resolveAddress(point, request, addressBeforeLookup));
    });
  }

  Future<void> _resolveAddress(
    LatLng point,
    int request,
    String addressBeforeLookup,
  ) async {
    ResolvedAddress? resolved;
    try {
      resolved = await _addressLookup
          .resolve(point, Localizations.localeOf(context))
          .timeout(const Duration(seconds: 9));
    } on Object catch (error) {
      // The selected point is still usable when the device has no geocoder.
      debugPrint('[address] lookup failed: $error');
    }
    if (!mounted || request != _lookupRequest) return;
    setState(() => _resolvingAddress = false);
    if (_address.text != addressBeforeLookup) return;
    if (resolved != null) {
      _fillAddress(resolved.address);
      // Flat and floor, when the lookup knew them: never over what was typed.
      if (_apartment.text.trim().isEmpty && resolved.apartment != null) {
        _apartment.text = resolved.apartment!;
      }
      if (_floor.text.trim().isEmpty && resolved.floor != null) {
        _floor.text = resolved.floor!;
      }
    } else {
      // Never put raw coordinates in front of the customer: leave the field
      // empty for them to type the address, which they can always do.
      _fillAddress('');
      setState(() => _message = context.l10n.addressLookupFailed);
    }
  }

  void _fillAddress(String text) {
    _address.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _coordinateText(LatLng point) =>
      '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';

  void _save() {
    if (_resolvingAddress) return;
    if (!_pointConfirmed) {
      setState(() => _message = context.l10n.addressPointRequired);
      return;
    }
    if (_name.text.trim().isEmpty) {
      setState(() => _message = context.l10n.addressNameRequired);
      return;
    }
    Navigator.of(context).pop(<String, dynamic>{
      'name': _name.text.trim(),
      'type': _type,
      'address': _address.text.trim().isEmpty
          ? _coordinateText(_point)
          : _address.text.trim(),
      'details': _combinedDetails(),
      'latitude': _point.latitude,
      'longitude': _point.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panel = isDark ? AppColors.surfaceDark : AppColors.white;

    // The keyboard never resizes the page, only lifts the sheet over it. With
    // the page resizing as well, the sheet's height was recomputed on every
    // frame of the keyboard animation, so it jumped up and back.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final keyboardOpen = keyboard > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Just tall enough for the form (handle, three fields, Save): the
          // sheet used to claim over 60% of the screen and leave a wide empty
          // band under the button. A notice or the settings button may push
          // past it, and the sheet scrolls for that.
          final fullSheetHeight = math.min(
            constraints.maxHeight,
            _sheetContentHeight + MediaQuery.paddingOf(context).bottom,
          );
          // Decided from the full layout, so the sheet's header does not swap
          // between handle and buttons as the keyboard opens.
          final roomForMapControls =
              constraints.maxHeight - fullSheetHeight >= 80;
          final showMapControls = roomForMapControls && !keyboardOpen;
          // Under the keyboard the sheet gives up height instead of moving
          // the map, and keeps clear of the status bar.
          final sheetHeight = keyboardOpen
              ? math.min(
                  fullSheetHeight,
                  constraints.maxHeight -
                      keyboard -
                      MediaQuery.paddingOf(context).top -
                      AppSpacing.sm,
                )
              : fullSheetHeight;
          const overlap = 24.0;
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: fullSheetHeight - overlap,
                child: Stack(
                  children: [
                    ElyeterMap(
                      center: _point,
                      showAttributionButton: false,
                      controller: _mapController,
                      onPositionChanged: (camera, hasGesture) =>
                          _mapMoved(camera.center, hasGesture),
                    ),
                    IgnorePointer(
                      child: Center(
                        child: Transform.translate(
                          offset: const Offset(0, -18),
                          child: AnimatedScale(
                            scale: _dragging ? 1.08 : 1,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            child: AnimatedSlide(
                              offset: Offset(0, _dragging ? -0.12 : 0),
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              child: const _MapPin(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showMapControls)
                Positioned(
                  key: const ValueKey('map-back'),
                  left: AppSpacing.page,
                  bottom: fullSheetHeight + AppSpacing.md,
                  child: _MapButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: HugeIcon(
                      icon: AppIcons.back,
                      size: 24,
                      color: isDark ? AppColors.white : AppColors.ink,
                    ),
                  ),
                ),
              if (showMapControls)
                Positioned(
                  key: const ValueKey('map-locate'),
                  right: AppSpacing.page,
                  bottom: fullSheetHeight + AppSpacing.md,
                  child: _MapButton(
                    onPressed: _locating ? null : _locate,
                    child: _locating
                        ? const SizedBox.square(
                            dimension: 20,
                            child: AppLoader(color: AppColors.primary),
                          )
                        : SvgPicture.asset(
                            AppAssets.iconCurrentLocation,
                            key: const Key('address-current-location'),
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              isDark ? AppColors.white : AppColors.ink,
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                ),
              // Keyed: the map buttons above come and go with the keyboard, and
              // without a key the sheet was matched against the wrong child,
              // rebuilt from scratch and its focused field lost, which closed
              // the keyboard the moment it opened.
              Positioned(
                key: const ValueKey('address-sheet'),
                left: 0,
                right: 0,
                bottom: keyboard,
                height: sheetHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 24,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    bottom: !keyboardOpen,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.lg,
                        AppSpacing.page,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (roomForMapControls)
                            const Center(child: _SheetHandle())
                          else
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: HugeIcon(
                                    icon: AppIcons.back,
                                    size: 24,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.ink,
                                  ),
                                ),
                                const Expanded(
                                  child: Center(child: _SheetHandle()),
                                ),
                                IconButton(
                                  onPressed: _locating ? null : _locate,
                                  icon: _locating
                                      ? const SizedBox.square(
                                          dimension: 20,
                                          child: AppLoader(),
                                        )
                                      : SvgPicture.asset(
                                          AppAssets.iconCurrentLocation,
                                          key: const Key(
                                            'address-current-location',
                                          ),
                                          width: 24,
                                          height: 24,
                                          colorFilter: ColorFilter.mode(
                                            isDark
                                                ? AppColors.white
                                                : AppColors.ink,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          const SizedBox(height: AppSpacing.xl),
                          _AddressField(
                            label: context.l10n.addressMapLocation,
                            controller: _address,
                            hint: context.l10n.addressMapHint,
                            loading: _resolvingAddress,
                            maxLength: 500,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: _AddressField(
                                  label: context.l10n.addressApartmentFlat,
                                  controller: _apartment,
                                  hint: context.l10n.addressApartmentHint,
                                  maxLength: 150,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _AddressField(
                                  label: context.l10n.addressFloor,
                                  controller: _floor,
                                  hint: context.l10n.addressFloorHint,
                                  maxLength: 30,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _AddressField(
                            label: context.l10n.addressNameLabel,
                            controller: _name,
                            maxLength: 60,
                            textInputAction: TextInputAction.done,
                          ),
                          if (_message != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            _Notice(_message!),
                            if (_locationProblem ==
                                    LocationProblem.serviceOff ||
                                _locationProblem == LocationProblem.denied ||
                                _locationProblem ==
                                    LocationProblem.deniedForever)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed:
                                      _locationProblem ==
                                          LocationProblem.serviceOff
                                      ? SettingsOpener.openLocationSettings
                                      : SettingsOpener.openAppSettings,
                                  child: Text(context.l10n.addressOpenSettings),
                                ),
                              ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          _SaveAddressButton(
                            label: _resolvingAddress
                                ? context.l10n.addressResolving
                                : context.l10n.addressSaveButton,
                            onPressed: _resolvingAddress ? null : _save,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 6,
    decoration: BoxDecoration(
      color: AppColors.grey300,
      borderRadius: BorderRadius.circular(AppRadius.pill),
    ),
  );
}

/// The supplied orange pin stays fixed while the map moves beneath it.
class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 15,
            child: Container(
              width: 12,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          SvgPicture.asset(
            AppAssets.iconAddressMapPin,
            key: const Key('address-map-pin'),
            width: 70,
            height: 74,
          ),
        ],
      ),
    );
  }
}

/// Round white button floating over the map.
class _MapButton extends StatelessWidget {
  const _MapButton({required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onPressed,
        child: SizedBox(width: 68, height: 48, child: Center(child: child)),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.label,
    required this.controller,
    this.hint,
    this.loading = false,
    this.maxLength,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool loading;
  final int? maxLength;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: AppTypography.fontFamily,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            textInputAction: textInputAction,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: AppTypography.fontFamily,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: loading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox.square(dimension: 20, child: AppLoader()),
                    )
                  : null,
              counterText: '',
              filled: true,
              fillColor: isDark ? AppColors.backgroundDark : AppColors.grey100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              // Dark mode: a thin grey edge, so the field stands off the sheet.
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.pill),
                ),
                borderSide: isDark
                    ? const BorderSide(color: Color(0xFF4A4A4A))
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.pill),
                ),
                borderSide: isDark
                    ? const BorderSide(color: Color(0xFF4A4A4A))
                    : BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveAddressButton extends StatelessWidget {
  const _SaveAddressButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(AppRadius.pill),
    clipBehavior: Clip.antiAlias,
    child: Ink(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
      ),
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const HugeIcon(
            icon: AppIcons.information,
            size: 18,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
