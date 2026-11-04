import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Draws a push as a native banner while the app is in the **foreground**.
///
/// `FirebaseMessaging.onMessage` fires in that case but — unlike a
/// background or terminated delivery, which the system draws itself — shows
/// nothing on Android. This is what fills that gap.
class LocalNotificationsService {
  LocalNotificationsService();

  /// Android needs the channel to exist before the first banner, and its
  /// importance is what decides whether one appears as a heads-up at all.
  static const _channelId = 'elyeter_default';
  static const _channelName = 'Elyeter';
  static const _channelDescription = 'Order updates and announcements';

  final _plugin = FlutterLocalNotificationsPlugin();
  void Function(String?)? onTap;

  bool _initialized = false;

  /// Ids only have to be distinct; the counter restarts with the process,
  /// which at worst replaces a banner from a previous run.
  int _nextId = 0;

  Future<void> init() async {
    if (_initialized) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(
          '@drawable/ic_stat_notification',
        ),
        // All three false: permission is asked once, explicitly, by
        // [PushService.init] — not as a side effect of plugin startup.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          onTap?.call(response.payload),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
          ),
        );

    _initialized = true;
  }

  Future<void> show(String? title, String? body, {String? payload}) =>
      _plugin.show(
        id: _nextId++,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.high,
            // The status-bar icon is always a silhouette; the full-colour
            // logo shows beside the text, and the silhouette is tinted yellow.
            color: Color(0xFFFFFC01),
            largeIcon: DrawableResourceAndroidBitmap('ic_notification_large'),
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
}
