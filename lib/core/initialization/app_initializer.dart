import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app.dart';
import '../config/app_config.dart';
import '../routes/app_router.dart';
import '../services/hive_service.dart';
import '../services/logger_service.dart';
import 'dependency_initializer.dart';
import 'feature_bloc_providers.dart';
import 'firebase_initializer.dart';

/// Handles the initialization of the entire application
class AppInitializer {
  AppInitializer({
    required LoggerService logger,
  })  : _logger = logger,
        _firebaseInitializer = FirebaseInitializer(logger: logger);
  final LoggerService _logger;
  final FirebaseInitializer _firebaseInitializer;

  /// Initialize the app and run it
  Future<void> initialize() async {
    await runZonedGuarded(() async {
      await _initializeApp();
    }, (error, stackTrace) {
      // Log any errors that occur in the app
      _logger.e('Unhandled error in app', error, stackTrace);

      // Report to Crashlytics if enabled
      if (AppConfig().crashReportingEnabled) {
        FirebaseCrashlytics.instance
            .recordError(error, stackTrace, fatal: true);
      }
    });
  }

  /// Initialize all app components
  Future<void> _initializeApp() async {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize app configuration
    AppConfig().initialize(
      environment:
          kReleaseMode ? Environment.production : Environment.development,
    );

    // Initialize Firebase
    final firebaseApp = await _firebaseInitializer.initializeFirebase();
    final isFirebaseInitialized = firebaseApp != null;

    // Set up Crashlytics if Firebase is initialized
    if (isFirebaseInitialized && AppConfig().crashReportingEnabled) {
      _firebaseInitializer.setupCrashlytics();
    }

    // Initialize Firebase Messaging if needed
    if (isFirebaseInitialized && !kIsWeb && AppConfig().analyticsEnabled) {
      await _firebaseInitializer.initializeFirebaseMessaging();
    }

    // Initialize Hive for local storage
    try {
      await HiveService.init();
      _logger.i('Hive initialized successfully');
    } on Exception catch (e) {
      _logger.e('Error initializing local storage', e);
      // Continue without local storage if initialization fails
    }

    // Initialize dependencies
    final dependencyInitializer = DependencyInitializer(
      logger: _logger,
      isFirebaseInitialized: isFirebaseInitialized,
    );
    await dependencyInitializer.initialize();

    // Create BLoC providers
    final blocProviders = FeatureBlocProviders(
      authRepository: dependencyInitializer.authRepository,
      postRepository: dependencyInitializer.postRepository,
      chatRepository: dependencyInitializer.chatRepository,
    );

    // Create router
    final router = createAppRouter();

    // Run the app
    runApp(
      MultiBlocProvider(
        providers: blocProviders.getProviders(),
        child: App(router: router),
      ),
    );
  }
}
