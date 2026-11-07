import 'package:flutter/foundation.dart';

/// Build-time configuration. Pass values with `--dart-define`:
///
/// ```sh
/// flutter run --dart-define=FLAVOR=dev --dart-define=API_BASE_URL=https://elyeter-backend.sanlyadim.com/api
/// ```
enum Flavor { dev, staging, prod }

abstract final class AppEnvironment {
  static const _flavorName = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static Flavor get flavor => switch (_flavorName) {
    'prod' => Flavor.prod,
    'staging' => Flavor.staging,
    _ => Flavor.dev,
  };

  /// Every documented path is relative to this.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://elyeter-backend.sanlyadim.com/api',
  );

  /// File server for the few fields that return a storage path instead of a
  /// URL (category artwork, brand logos). See [MediaUrl].
  static const fileBaseUrl = String.fromEnvironment(
    'FILE_BASE_URL',
    defaultValue: 'https://elyeter-backend.sanlyadim.com/public',
  );

  static bool get isProd => flavor == Flavor.prod;

  /// Keep diagnostic request timing in development builds only. Even
  /// redacted logs are unnecessary in store builds and can reach logcat.
  static bool get enableLogging => !isProd && !kReleaseMode;
}
