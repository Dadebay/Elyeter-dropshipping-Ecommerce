import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

/// Turns a map coordinate into a readable address after a user action.
abstract class AddressLookupService {
  Future<String?> reverse(LatLng point, Locale locale);
}

/// What a lookup found: the street address, plus the flat and floor when the
/// source happens to know them.
class ResolvedAddress {
  const ResolvedAddress(this.address, {this.apartment, this.floor});

  final String address;
  final String? apartment;
  final String? floor;
}

extension AddressLookupDetails on AddressLookupService {
  /// [reverse], with flat and floor where the service can supply them.
  Future<ResolvedAddress?> resolve(LatLng point, Locale locale) async {
    final self = this;
    if (self is DeviceAddressLookupService) {
      return self.resolveDetails(point, locale);
    }
    final text = await reverse(point, locale);
    return text == null ? null : ResolvedAddress(text);
  }
}

void _log(String message) {
  if (kDebugMode) debugPrint('[address] $message');
}

class DeviceAddressLookupService implements AddressLookupService {
  /// [dio] is the internet fallback used when the device has no geocoder (or
  /// it finds nothing). Pass null to disable it.
  DeviceAddressLookupService({Geocoding? geocoding, Dio? dio, bool web = true})
    : _geocoding = geocoding ?? Geocoding(),
      _dio = web ? (dio ?? Dio()) : null;

  final Geocoding _geocoding;
  final Dio? _dio;

  @override
  Future<String?> reverse(LatLng point, Locale locale) async =>
      (await resolveDetails(point, locale))?.address;

  /// Asks the device and the internet together; the device's wording wins,
  /// the internet fills in what it lacks (and the flat / floor, if any).
  Future<ResolvedAddress?> resolveDetails(LatLng point, Locale locale) async {
    _log(
      'lookup ${point.latitude}, ${point.longitude} (${locale.languageCode})',
    );
    final results = await Future.wait([
      _onDevice(point, locale),
      _overInternet(point, locale),
    ]);
    final device = results[0] as String?;
    final web = results[1] as _WebAddress?;
    // The device sometimes answers with little more than the city; the
    // internet's answer then carries the actual street or landmark.
    final deviceParts = device == null ? 0 : _readableParts(device).length;
    final webParts = web == null ? 0 : _readableParts(web.text).length;
    final text = device == null || (deviceParts <= 2 && webParts > deviceParts)
        ? (web?.text ?? device)
        : device;
    _log(
      'result: device=${device ?? 'none'} | web=${web?.text ?? 'none'} '
      '| apartment=${web?.apartment ?? '-'} floor=${web?.floor ?? '-'}',
    );
    if (text == null) return null;
    return ResolvedAddress(text, apartment: web?.apartment, floor: web?.floor);
  }

  Future<String?> _onDevice(LatLng point, Locale locale) async {
    try {
      if (!await _geocoding.isPresent()) {
        _log('device geocoder: not present');
        return null;
      }
      final places = await _geocoding.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
        locale: locale,
      );
      _log(
        'device geocoder: ${places.length} placemark(s) ${places.firstOrNull}',
      );
      if (places.isEmpty) return null;
      return formatPlacemark(places.first);
    } on Object catch (error) {
      _log('device geocoder ERROR: $error');
      return null;
    }
  }

  /// OpenStreetMap's public reverse geocoder: slower than the device, but it
  /// answers where the device cannot.
  Future<_WebAddress?> _overInternet(LatLng point, Locale locale) async {
    final dio = _dio;
    if (dio == null) return null;
    try {
      final response = await dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': point.latitude,
          'lon': point.longitude,
          'zoom': 18,
          'addressdetails': 1,
          'accept-language': locale.languageCode,
        },
        options: Options(
          headers: const {'User-Agent': 'ElyeterApp/1.0'},
          receiveTimeout: const Duration(seconds: 7),
          sendTimeout: const Duration(seconds: 7),
        ),
      );
      final data = response.data;
      _log('nominatim: ${data?['address']}');
      final text = (data?['display_name'] as String?)?.trim();
      if (text == null || text.isEmpty) return null;
      final details = data?['address'];
      String? pick(List<String> keys) {
        if (details is! Map) return null;
        for (final key in keys) {
          final value = '${details[key] ?? ''}'.trim();
          if (value.isNotEmpty) return value;
        }
        return null;
      }

      return _WebAddress(
        text,
        apartment: pick(const ['unit', 'flat', 'flats', 'apartment', 'door']),
        floor: pick(const ['level', 'floor']),
      );
    } on Object catch (error) {
      _log('nominatim ERROR: $error');
      return null;
    }
  }

  /// An Open Location Code such as `X86F+FC7`, which means nothing to a
  /// customer reading an address.
  static final _plusCode = RegExp(
    r'^[23456789CFGHJMPQRVWX]{2,8}\+[23456789CFGHJMPQRVWX]*$',
    caseSensitive: false,
  );

  /// The comma-separated pieces of [text] a person can read: plus codes and
  /// empty pieces dropped.
  static List<String> _readableParts(String text) => [
    for (final raw in text.split(','))
      if (raw.trim().isNotEmpty && !_plusCode.hasMatch(raw.trim())) raw.trim(),
  ];

  static String? formatPlacemark(Placemark place) {
    String clean(String? value) {
      final text = value?.trim() ?? '';
      if (text.toLowerCase() == 'null') return '';
      // The street field sometimes carries a whole line, plus code and all:
      // keep only the readable pieces.
      return _readableParts(text).join(', ');
    }

    final street = clean(place.street);
    final thoroughfare = clean(place.thoroughfare);
    final number = clean(place.subThoroughfare);
    final road = [
      thoroughfare,
      number,
    ].where((part) => part.isNotEmpty).join(' ');
    final firstLine = street.isNotEmpty
        ? street
        : (road.isNotEmpty ? road : clean(place.name));
    final locality = [
      place.locality,
      place.subLocality,
      place.subAdministrativeArea,
      place.administrativeArea,
    ].map(clean).firstWhere((part) => part.isNotEmpty, orElse: () => '');
    final country = clean(place.country);
    if (firstLine.isEmpty && locality.isEmpty) return null;

    final parts = <String>[];
    for (final piece in [firstLine, locality, country]) {
      for (final part in _readableParts(piece)) {
        if (parts.any(
          (existing) => existing.toLowerCase() == part.toLowerCase(),
        )) {
          continue;
        }
        parts.add(part);
      }
    }
    return parts.isEmpty ? null : parts.join(', ');
  }
}

class _WebAddress {
  const _WebAddress(this.text, {this.apartment, this.floor});

  final String text;
  final String? apartment;
  final String? floor;
}
