import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/notification/presentation/services/notification_navigation.dart';
import '../../app/cubit/locale_cubit.dart';
import '../../firebase_options.dart';
import '../network/interceptors/language_interceptor.dart';
import '../utils/app_logger.dart';
import 'local_notifications_service.dart';

/// Push notifications, open or closed.
///
/// Three deliveries, three paths: the system draws the banner itself when
/// the app is backgrounded or terminated, [_onForeground] draws it by hand
/// when the app is open, and [_backgroundHandler] runs in its own isolate so
/// a data-only push is still processed with the app closed.
class PushService {
  PushService(this._auth, this._local, this._locale, this._session);

  /// Everyone who opens the app joins this; broadcasts are sent here.
  static const topicTm = 'EVENT_TM';
  static const topicRu = 'EVENT_RU';

  final AuthRepository _auth;
  final LocalNotificationsService _local;
  final LocaleCubit _locale;
  final AuthCubit _session;

  String? _token;
  Future<void>? _initialization;

  /// Never throws: a phone without Play services, or a build whose Firebase
  /// config is missing, must still open the app.
  Future<void> init() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _local.onTap = _onLocalTap;
      await _local.init();

      final messaging = FirebaseMessaging.instance;

      // Configure foreground presentation without asking for permission at
      // launch. The permission prompt belongs to the signed-in flow below.
      if (Platform.isIOS) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      await _syncTopics();
      _locale.stream.listen((_) {
        unawaited(_syncTopics());
      });
      _session.stream.listen((state) {
        if (!state.isAuthenticated) unawaited(_syncTopics());
      });

      // Registered before the streams: a terminated-app delivery reaches the
      // isolate below, which has no Firebase of its own.
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

      // The notification that launched the app from a cold start; it never
      // reaches `onMessageOpenedApp`.
      final initial = await messaging.getInitialMessage();
      if (initial != null) _onOpened(initial);

      // Keep the current token locally; only a successful OTP login sends it.
      messaging.onTokenRefresh.listen((token) {
        _token = token;
        AppLogger.i('FCM token refreshed');
        unawaited(_syncTopics());
      });
    } on Object catch (e, s) {
      AppLogger.e('Push setup failed', e, s);
    }
  }

  /// Waits for APNs to hand iOS its device token, up to [_apnsWait].
  ///
  /// A no-op on Android and on the simulator, which never gets one — the
  /// loop just runs out and the app carries on without push, which is the
  /// right outcome there.
  Future<void> _awaitApns() async {
    if (!Platform.isIOS) return;

    final deadline = DateTime.now().add(_apnsWait);
    while (DateTime.now().isBefore(deadline)) {
      final apns = await FirebaseMessaging.instance.getAPNSToken();
      if (apns != null) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    AppLogger.w('APNs did not answer in ${_apnsWait.inSeconds}s');
  }

  /// Long enough for a fresh install on a slow network, short enough that
  /// nothing else at startup notices — this runs off the first frame.
  static const _apnsWait = Duration(seconds: 6);

  String get _language => LanguageInterceptor.resolve(
    _locale.state?.languageCode ??
        PlatformDispatcher.instance.locale.languageCode,
  );

  Future<void> _syncTopics() async {
    final messaging = FirebaseMessaging.instance;
    final selected = _language == 'ru' ? topicRu : topicTm;
    final other = selected == topicRu ? topicTm : topicRu;
    await messaging.unsubscribeFromTopic(other);
    await messaging.subscribeToTopic(selected);
  }

  /// Called only after successful OTP verification. Permission is requested
  /// here, after the customer chooses to sign in, rather than on app launch.
  Future<void> registerTokenAfterOtp() async {
    try {
      await init();
      final settings = await FirebaseMessaging.instance.requestPermission();
      AppLogger.i('Push permission: ${settings.authorizationStatus.name}');
      if (Platform.isIOS) await _awaitApns();
      final token = _token ??= await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      if (!await _auth.hasSession()) return;

      final result = await _auth.updateFcmToken(token, lang: _language);
      result.fold(
        (_) => AppLogger.i('FCM token registered with the backend'),
        (failure) => AppLogger.w('FCM token not registered: ${failure.code}'),
      );
    } on Object catch (e) {
      AppLogger.w('FCM token sync failed: $e');
    }
  }

  void _onForeground(RemoteMessage message) {
    final notification = message.notification;
    // iOS presents the remote message itself (configured in [init]); a local
    // one on top of it would be a duplicate banner.
    if (notification == null || Platform.isIOS) return;

    unawaited(
      _local.show(
        notification.title,
        notification.body,
        payload: jsonEncode(message.data),
      ),
    );
  }

  void _onOpened(RemoteMessage message) {
    _route(message.data);
  }

  void _onLocalTap(String? payload) {
    if (payload == null) return;
    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) _route(data);
    } on Object {
      /* Ignore malformed payloads. */
    }
  }

  void _route(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        NotificationNavigation.open(
          data['target_type'] as String?,
          data['target'] as String?,
          productRequestId: data['product_request_id']?.toString(),
        ),
      );
    });
  }
}

/// Runs in its own isolate with the app backgrounded or killed, so it shares
/// nothing with [PushService] and has to bring Firebase up itself.
@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
