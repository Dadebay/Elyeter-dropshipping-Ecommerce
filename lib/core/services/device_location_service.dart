import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

/// Foreground-only lookup for the address picker.
///
/// It tries every source it can, from the most to the least precise, and
/// stops at the first that answers:
///
/// 1. GPS (high accuracy) - best outdoors.
/// 2. The network provider (Wi-Fi / cell towers) - works indoors.
/// 3. An IP-based lookup over the internet - city level, but needs no
///    sensor at all.
/// 4. The last position this device was known at, remembered between runs.
///
/// Anything past step 1 is flagged through [lastFixWasApproximate] so the
/// picker can ask the customer to nudge the pin.
class DeviceLocationService {
  DeviceLocationService({loc.Location? platform, Dio? dio})
    : _platform = platform ?? loc.Location(),
      _dio = dio ?? Dio();

  /// The app serves Turkmenistan only, so a position outside this box is not
  /// a position it can use. Under a VPN, the IP lookup in particular reports
  /// the VPN server's country, so such readings are thrown away rather than
  /// shown.
  static const _south = 35.1;
  static const _north = 42.9;
  static const _west = 52.4;
  static const _east = 66.8;

  static bool isInTurkmenistan(LatLng point) =>
      point.latitude >= _south &&
      point.latitude <= _north &&
      point.longitude >= _west &&
      point.longitude <= _east;

  static const _latKey = 'device_location.last_lat';
  static const _lonKey = 'device_location.last_lon';

  final loc.Location _platform;
  final Dio _dio;
  LatLng? _recentPoint;
  bool lastFixWasApproximate = false;

  static void _log(String message) {
    if (kDebugMode) debugPrint('[location] $message');
  }

  Future<LatLng> locate() async {
    final problem = await _ensurePermission();
    _log('permission: ${problem ?? 'ok'}');
    final granted = problem == null;

    if (granted) {
      // 1. GPS.
      final precise = await _read(loc.LocationAccuracy.high, seconds: 8);
      _log('gps: ${precise?.point ?? 'none'}');
      if (precise != null) {
        lastFixWasApproximate = (precise.accuracy ?? 0) > 100;
        return _remember(precise.point);
      }
      // 2. Wi-Fi / cell network position.
      for (final accuracy in [
        loc.LocationAccuracy.balanced,
        loc.LocationAccuracy.low,
      ]) {
        final network = await _read(accuracy, seconds: 6);
        _log('network ($accuracy): ${network?.point ?? 'none'}');
        if (network != null) {
          lastFixWasApproximate = true;
          return _remember(network.point);
        }
      }
    }

    // 3. Position from the internet connection.
    final byIp = await _lookupByIp();
    _log('ip: ${byIp ?? 'none (or outside Turkmenistan)'}');
    if (byIp != null) {
      lastFixWasApproximate = true;
      return _remember(byIp);
    }

    // 4. Wherever the device was last seen.
    final last = await _lastKnown();
    _log('last known: ${last ?? 'none'}');
    if (last != null) {
      lastFixWasApproximate = true;
      return last;
    }

    throw LocationLookupException(
      problem == null
          ? 'Konum bulunamadı. Haritadan adresi seçebilirsiniz.'
          : 'Konum alınamadı.',
      problem: problem ?? LocationProblem.notFound,
    );
  }

  /// Switches the location service on and asks for permission. Null when the
  /// device may be read; otherwise why not, so the picker can say so rather
  /// than guess. The later, sensor-free steps still get their turn.
  Future<LocationProblem?> _ensurePermission() async {
    try {
      var enabled = await _platform.serviceEnabled();
      if (!enabled) enabled = await _platform.requestService();
      if (!enabled) return LocationProblem.serviceOff;

      var permission = await _platform.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await _platform.requestPermission();
      }
      return switch (permission) {
        loc.PermissionStatus.granted ||
        loc.PermissionStatus.grantedLimited => null,
        loc.PermissionStatus.deniedForever => LocationProblem.deniedForever,
        _ => LocationProblem.denied,
      };
    } on Object catch (error) {
      _log('permission ERROR: $error');
      return LocationProblem.failed;
    }
  }

  Future<_Reading?> _read(
    loc.LocationAccuracy accuracy, {
    required int seconds,
  }) async {
    try {
      await _platform.changeSettings(accuracy: accuracy);
      final data = await _platform.getLocation().timeout(
        Duration(seconds: seconds),
      );
      final lat = data.latitude;
      final lon = data.longitude;
      if (lat.abs() > 90 || lon.abs() > 180) return null;
      final point = LatLng(lat, lon);
      if (!isInTurkmenistan(point)) return null;
      return _Reading(point, data.accuracy);
    } on Object catch (error) {
      _log('read ($accuracy) ERROR: $error');
      return null;
    }
  }

  Future<LatLng?> _lookupByIp() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://ipwho.is/',
        options: Options(
          receiveTimeout: const Duration(seconds: 6),
          sendTimeout: const Duration(seconds: 6),
        ),
      );
      final data = response.data;
      if (data == null || data['success'] == false) return null;
      final lat = (data['latitude'] as num?)?.toDouble();
      final lon = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lon == null || lat.abs() > 90 || lon.abs() > 180) {
        return null;
      }
      final point = LatLng(lat, lon);
      return isInTurkmenistan(point) ? point : null;
    } on Object catch (error) {
      _log('ip ERROR: $error');
      return null;
    }
  }

  Future<LatLng?> _lastKnown() async {
    final recent = _recentPoint;
    if (recent != null && isInTurkmenistan(recent)) return recent;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_latKey);
      final lon = prefs.getDouble(_lonKey);
      if (lat != null && lon != null) {
        final point = LatLng(lat, lon);
        if (isInTurkmenistan(point)) return point;
      }
    } on Object {
      // Nothing stored.
    }
    return null;
  }

  LatLng _remember(LatLng point) {
    _recentPoint = point;
    unawaited(_persist(point));
    return point;
  }

  Future<void> _persist(LatLng point) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latKey, point.latitude);
      await prefs.setDouble(_lonKey, point.longitude);
    } on Object {
      // Remembering is a convenience only.
    }
  }
}

class _Reading {
  const _Reading(this.point, this.accuracy);

  final LatLng point;
  final double? accuracy;
}

/// Why the device could not be read.
enum LocationProblem {
  /// Location is switched off on the phone.
  serviceOff,

  /// The customer has not allowed it (they can be asked again).
  denied,

  /// Blocked for good: only the phone's settings can undo it.
  deniedForever,

  /// The platform call itself failed.
  failed,

  /// Allowed and working, but no usable position in Turkmenistan came back.
  notFound,
}

class LocationLookupException implements Exception {
  const LocationLookupException(
    this.message, {
    this.problem = LocationProblem.notFound,
  });
  final String message;
  final LocationProblem problem;
  @override
  String toString() => message;
}
