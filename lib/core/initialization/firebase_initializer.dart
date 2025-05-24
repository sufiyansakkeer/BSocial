import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../config/app_config.dart';
import '../services/logger_service.dart';
import '../utils/notification_utils.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final logger = LoggerService(); // Assuming LoggerService can be instantiated like this
  logger.i('Handling a background message: ${message.messageId}');
  logger.d('Background Message data: ${message.data}');
  if (message.notification != null) {
    logger.d(
        'Background Notification: ${message.notification?.title} - ${message.notification?.body}');
  }
  // It's important to initialize NotificationUtils and its local notifications plugin
  // if you want to show a local notification from a background handler.
  await NotificationUtils().initializeLocalNotifications();
  NotificationUtils().showLocalNotification(message);
}

/// Handles all Firebase-related initialization
class FirebaseInitializer {
  FirebaseInitializer({
    required LoggerService logger,
  }) : _logger = logger;
  final LoggerService _logger;

  /// Initialize Firebase with a timeout to prevent hanging
  Future<FirebaseApp?> initializeFirebaseWithTimeout(
    Future<FirebaseApp> Function() initFunction,
  ) async {
    try {
      // Increase timeout to 15 seconds for Firebase initialization
      final app = await initFunction().timeout(const Duration(seconds: 15));
      _logger.i('Firebase initialized successfully');
      return app;
    } on TimeoutException {
      _logger
          .w('Firebase initialization timed out. Continuing without Firebase.');
      return null;
    } on Exception catch (e) {
      _logger.e('Error initializing Firebase: $e');
      return null;
    }
  }

  /// Initialize Firebase with default options
  Future<FirebaseApp?> initializeFirebase() async =>
      initializeFirebaseWithTimeout(
        () => Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
      );

  /// Set up Crashlytics for error reporting
  void setupCrashlytics() {
    if (!AppConfig().crashReportingEnabled) {
      return;
    }

    try {
      // Set up Crashlytics error reporting
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      // Set up error handling for async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        _logger.e('Unhandled error', error, stack);
        return true;
      };
      _logger.i('Crashlytics initialized successfully');
    } on Exception catch (e) {
      _logger.e('Error setting up Crashlytics', e);
    }
  }

  /// Initialize Firebase Messaging for notifications
  Future<void> initializeFirebaseMessaging() async {
    // if (kIsWeb || !AppConfig().analyticsEnabled) { // Original condition
    if (kIsWeb) { // Modified condition as per instructions
      _logger.i('FCM initialization skipped for web.');
      return;
    }

    try {
      // Request permission for notifications
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _logger.i('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('User granted permission');

        // Set a timeout for FCM token retrieval
        final fcmToken = await FirebaseMessaging.instance.getToken().timeout(
              const Duration(seconds: 10), // Increased timeout slightly
            );
        _logger.i("FCM Token: ${fcmToken ?? 'N/A'}");

        // Set up foreground message handler
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _logger.i('Got a message whilst in the foreground!');
          _logger.d('Message data: ${message.data}');

          if (message.notification != null) {
            _logger.d('Message also contained a notification: '
                '${message.notification?.title} - ${message.notification?.body}');
          }
          // Initialize local notifications if not already (should be done by AppInitializer)
          // NotificationUtils().initializeLocalNotifications(); // Ensure initialized
          NotificationUtils().showLocalNotification(message);
        });

        // Set up handler for when a message opens the app (from terminated state)
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _logger.i('Message opened app: ${message.messageId}');
          _logger.d('Message data: ${message.data}');
          if (message.notification != null) {
            _logger.d('Message also contained a notification: '
                '${message.notification?.title} - ${message.notification?.body}');
          }
          // Potentially call showLocalNotification or handle navigation
          // For now, just logging and showing local notification as per instructions.
          // NotificationUtils().initializeLocalNotifications(); // Ensure initialized
          NotificationUtils().showLocalNotification(message);
        });

        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        _logger.i('Firebase Messaging setup complete.');
      } else {
        _logger.i('User declined or has not accepted permission');
      }
    } on TimeoutException {
      _logger.w('FCM token retrieval timed out. Continuing without FCM token.');
    } on Exception catch (e, s) {
      _logger.e('Error initializing Firebase Messaging or getting FCM token', e, s);
      // Continue without FCM token or full setup if error occurs
    }
  }
}
