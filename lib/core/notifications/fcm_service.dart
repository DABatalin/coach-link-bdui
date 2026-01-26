import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/domain/notifications_repository.dart';

// Must be top-level — runs in a separate isolate when app is terminated/background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by the system, no need to re-init here
  // System will show the notification automatically from the data payload
  // This handler is for custom background processing if needed
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class FCMService {
  FCMService._();

  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'coachlink_high_importance',
    'CoachLink уведомления',
    description: 'Уведомления о заданиях, заявках и отчётах',
    importance: Importance.high,
  );

  // Used for navigation from notification tap
  static GoRouter? _router;

  static Future<void> initialize({required GoRouter router}) async {
    _router = router;

    // Request permission (required on iOS, Android 13+)
    await _requestPermission();

    // Create Android notification channel
    await _setupAndroidChannel();

    // Initialize flutter_local_notifications (for foreground messages)
    await _initLocalNotifications();

    // Register handlers
    _setupHandlers();
  }

  static Future<void> requestPermissionAndRegisterToken({
    required NotificationsRepository repository,
  }) async {
    final token = await _messaging.getToken();
    if (token != null) {
      debugPrint('[FCM] Token: $token');
      await repository.registerDeviceToken(fcmToken: token);
    }

    // Re-register on token refresh (e.g. app reinstalled, token rotated)
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token refreshed');
      await repository.registerDeviceToken(fcmToken: newToken);
    });
  }

  // ── Private ──────────────────────────────────────────────────────

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }

  static Future<void> _setupAndroidChannel() async {
    if (!Platform.isAndroid) return;
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  static Future<void> _initLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false, // Already requested via FirebaseMessaging
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // User tapped a local notification (foreground message)
        final payload = response.payload;
        if (payload != null) _navigate(payload);
      },
    );
  }

  static void _setupHandlers() {
    // Foreground: Firebase delivers the message but does NOT show a notification.
    // We must show it manually via flutter_local_notifications.
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // Background/terminated → foreground: user tapped the notification.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = _routeForMessage(message);
      if (route != null) _navigate(route);
    });

    // Terminated → opened: check for initial message on app launch.
    _handleInitialMessage();
  }

  static Future<void> _handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message == null) return;
    final route = _routeForMessage(message);
    if (route != null) {
      // Delay to ensure the router is ready
      await Future.delayed(const Duration(milliseconds: 500));
      _navigate(route);
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final route = _routeForMessage(message);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: route,
    );
  }

  static String? _routeForMessage(RemoteMessage message) {
    final type = message.data['type'] as String?;
    final assignmentId = message.data['assignment_id'] as String?;

    return switch (type) {
      'training_assigned' when assignmentId != null =>
        '/athlete/assignments/$assignmentId',
      'training_deleted' => '/athlete/assignments',
      'report_submitted' when assignmentId != null =>
        '/coach/assignments/$assignmentId/report',
      'connection_request' => '/coach/requests',
      'connection_accepted' => '/athlete/my-coach',
      'connection_rejected' => '/athlete/find-coach',
      'group_added' => '/athlete/groups',
      'group_removed' => '/athlete/groups',
      _ => null,
    };
  }

  static void _navigate(String route) {
    _router?.go(route);
  }
}
