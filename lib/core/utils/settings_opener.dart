import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the phone's own settings screens, for the customer who has to switch
/// something on there (location access, the location service).
///
/// Android goes through the app's own channel to `MainActivity`; a plugin for
/// this applies the Kotlin Gradle Plugin, which Flutter now warns about.
abstract final class SettingsOpener {
  static const _channel = MethodChannel('com.gurbanov.elyeter/system_ui');

  /// This app's page in the phone's settings, where permissions are changed.
  static Future<void> openAppSettings() => _open('openAppSettings');

  /// The location switch (Android); the app's page elsewhere.
  static Future<void> openLocationSettings() => _open('openLocationSettings');

  static Future<void> _open(String method) async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _channel.invokeMethod<void>(method);
      } else {
        await launchUrl(Uri.parse('app-settings:'));
      }
    } on Object {
      // Nothing more to do: the customer can open settings by hand.
    }
  }
}
