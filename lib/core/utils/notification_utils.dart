import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../services/logger_service.dart';

/// Utility class for handling notifications
class NotificationUtils {
  // Factory constructor
  factory NotificationUtils() => _instance;

  // Private constructor
  NotificationUtils._internal();
  final _logger = LoggerService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Singleton instance
  static final NotificationUtils _instance = NotificationUtils._internal();

  // Router instance for navigation
  static GoRouter? _router;

  /// Initialize the router for navigation
  static void initializeRouter(GoRouter router) {
    _router = router;
  }

  /// Initialize local notifications
  Future<void> initializeLocalNotifications() async {
    if (_initialized) {
      return;
    }

    try {
      // Android initialization settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings();

      // Initialize settings
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      _logger.i('Local notifications initialized');
    } on Exception catch (e) {
      _logger.e('Error initializing local notifications', e);
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('Notification tapped with payload: ${response.payload}');

    if (_router == null) {
      _logger.e('Router not initialized in NotificationUtils');
      return;
    }

    if (response.payload == null || response.payload!.isEmpty) {
      _logger.e('Notification payload is null or empty');
      return;
    }

    try {
      final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
      final type = payload['type'] as String?;
      final id = payload['id'] as String?;

      if (type == null || id == null) {
        _logger.e('Notification payload is missing type or id');
        return;
      }

      _logger.i('Parsed notification payload: type=$type, id=$id');

      // It's good practice to ensure the router is available in the current context
      // However, _router.go() should work if GoRouter is set up correctly.
      // For robustness, consider checking if the current context has a GoRouter.
      // But for this task, direct call to _router.go() is assumed.

      switch (type) {
        case 'chat':
          // Assuming 'chat-detail' is a named route like '/chat/:roomId'
          // If direct path: _router!.go('/chat/$id');
          _router!.goNamed('chat-detail', pathParameters: {'roomId': id});
          _logger.i('Navigating to chat detail for room ID: $id');
          break;
        case 'post':
          // Assuming 'post-detail' is a named route like '/post/:postId'
          // If direct path: _router!.go('/post/$id');
          _router!.goNamed('post-detail', pathParameters: {'postId': id});
          _logger.i('Navigating to post detail for post ID: $id');
          break;
        case 'profile':
          // Assuming 'profile' is a named route like '/profile/:userId'
          // If direct path: _router!.go('/profile/$id');
          _router!.goNamed('profile', pathParameters: {'userId': id});
          _logger.i('Navigating to profile for user ID: $id');
          break;
        default:
          _logger.w('Unknown notification type: $type');
      }
    } on FormatException catch (e) {
      _logger.e('Error parsing notification payload: $e. Payload: ${response.payload}');
    } on Exception catch (e) {
      _logger.e('An unexpected error occurred during notification tap handling: $e');
    }
  }

  /// Show a local notification from a Firebase message
  void showLocalNotification(RemoteMessage message) {
    try {
      if (!_initialized) {
        _logger.w('Local notifications not initialized');
        return;
      }

      final notification = message.notification;
      if (notification == null) {
        _logger.w('No notification in message');
        return;
      }

      // Android notification details
      const androidDetails = AndroidNotificationDetails(
        'bsocial_channel',
        'BSocial Notifications',
        channelDescription: 'Notifications from BSocial',
        importance: Importance.high,
        priority: Priority.high,
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // General notification details
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        details,
        payload: message.data.toString(),
      );

      _logger.i('Local notification shown: ${notification.title}');
    } on Exception catch (e) {
      _logger.e('Error showing local notification', e);
    }
  }
}
