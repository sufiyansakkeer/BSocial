import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../services/logger_service.dart';

/// Utility class for handling notifications
class NotificationUtils {
  static final _logger = LoggerService();
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialize local notifications
  static Future<void> initializeLocalNotifications() async {
    if (_initialized) return;

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
    } catch (e) {
      _logger.e('Error initializing local notifications', e);
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    _logger.i('Notification tapped: ${response.payload}');
    // TODO: Handle notification tap
  }

  /// Show a local notification from a Firebase message
  static void showLocalNotification(RemoteMessage message) {
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
    } catch (e) {
      _logger.e('Error showing local notification', e);
    }
  }
}
