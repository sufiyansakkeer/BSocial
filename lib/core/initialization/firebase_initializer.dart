import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../config/app_config.dart';
import '../services/logger_service.dart';

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
    if (kIsWeb || !AppConfig().analyticsEnabled) {
      return;
    }

    try {
      // Request permission for notifications
      final settings = await FirebaseMessaging.instance.requestPermission();

      _logger.i('Notification permission: ${settings.authorizationStatus}');

      // Set a timeout for FCM token retrieval
      final fcmToken = await FirebaseMessaging.instance.getToken().timeout(
            const Duration(seconds: 3),
          );
      _logger.i("FCM Token: ${fcmToken ?? 'null'}");
    } on TimeoutException {
      _logger.w('FCM token retrieval timed out. Continuing without FCM.');
    } on Exception catch (e) {
      _logger.e('Error getting FCM token', e);
      // Continue without FCM token
    }
  }
}
