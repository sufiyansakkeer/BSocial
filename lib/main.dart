import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'core/config/app_config.dart';
import 'core/network/network_info.dart';
import 'core/services/hive_service.dart';
import 'core/services/logger_service.dart';
import 'data/datasources/local/hive_local_data_source.dart';
import 'data/datasources/local/storage_local_data_source.dart';
import 'data/datasources/remote/auth_remote_data_source.dart';
import 'data/datasources/remote/mock_auth_remote_data_source.dart';
import 'data/datasources/remote/mock_post_remote_data_source.dart';
import 'data/datasources/remote/post_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/cached_post_repository_impl.dart';
import 'firebase_options.dart';
import 'presentation/app.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/post/post_bloc.dart';
import 'presentation/blocs/search/search_bloc.dart';
import 'presentation/routes/app_router.dart';

final logger = LoggerService();

Future<void> main() async {
  await runZonedGuarded(() async {
    // Ensure Flutter is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize app configuration
    AppConfig().initialize(
      environment:
          kReleaseMode ? Environment.production : Environment.development,
    );

    // Initialize Firebase with error handling and timeout
    FirebaseApp? firebaseApp;
    var isFirebaseInitialized = false;

    try {
      // Set a timeout for Firebase initialization to prevent app from hanging
      firebaseApp = await _initializeFirebaseWithTimeout(
        () => Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
      );

      isFirebaseInitialized = firebaseApp != null;

      // Set up Crashlytics (only if Firebase initialized successfully)
      if (isFirebaseInitialized && AppConfig().crashReportingEnabled) {
        try {
          // Set up Crashlytics error reporting
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterError;

          // Set up error handling for async errors
          PlatformDispatcher.instance.onError = (error, stack) {
            FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
            logger.e('Unhandled error', error, stack);
            return true;
          };
          logger.i('Crashlytics initialized successfully');
        } on Exception catch (e) {
          logger.e('Error setting up Crashlytics', e);
        }
      }

      // Try to get FCM token but don't block app startup if it fails
      if (isFirebaseInitialized && !kIsWeb && AppConfig().analyticsEnabled) {
        await _initializeFirebaseMessaging();
      }
    } on Exception catch (e) {
      logger.e('Error initializing Firebase', e);
      isFirebaseInitialized = false;
      // Continue without Firebase if initialization fails
    }

    // Initialize Hive for local storage
    try {
      await HiveService.init();
      logger.i('Hive initialized successfully');
    } on Exception catch (e) {
      logger.e('Error initializing local storage', e);
      // Continue without local storage if initialization fails
    }

    // Create dependencies
    final connectionChecker = InternetConnectionChecker();
    final networkInfo = NetworkInfoImpl(connectionChecker: connectionChecker);

    // Initialize local data source first (doesn't depend on Firebase)
    final localDataSource = HiveLocalDataSourceImpl();

    // Initialize repositories based on Firebase availability
    late AuthRepositoryImpl authRepository;
    late CachedPostRepositoryImpl postRepository;

    if (isFirebaseInitialized) {
      try {
        // Firebase services
        final firestore = FirebaseFirestore.instance;
        final auth = FirebaseAuth.instance;
        final storage = FirebaseStorage.instance;
        final googleSignIn = GoogleSignIn();

        // Data sources that depend on Firebase
        final storageDataSource = StorageLocalDataSourceImpl(storage: storage);
        final authRemoteDataSource = AuthRemoteDataSourceImpl(
          auth: auth,
          firestore: firestore,
          googleSignIn: googleSignIn,
          storageDataSource: storageDataSource,
        );
        final postRemoteDataSource = PostRemoteDataSourceImpl(
          firestore: firestore,
          storageDataSource: storageDataSource,
        );

        // Create repositories with Firebase-dependent data sources
        authRepository = AuthRepositoryImpl(
          remoteDataSource: authRemoteDataSource,
          networkInfo: networkInfo,
        );

        postRepository = CachedPostRepositoryImpl(
          remoteDataSource: postRemoteDataSource,
          localDataSource: localDataSource,
          networkInfo: networkInfo,
        );

        logger.i('Firebase services initialized successfully');
      } on Exception catch (e) {
        logger.e('Error initializing Firebase services: $e');
        // Fall back to offline mode if Firebase services initialization fails
        isFirebaseInitialized = false;

        // Create repositories with offline-only capabilities
        authRepository = AuthRepositoryImpl(
          remoteDataSource: MockAuthRemoteDataSource(),
          networkInfo: networkInfo,
        );

        postRepository = CachedPostRepositoryImpl(
          remoteDataSource: MockPostRemoteDataSource(),
          localDataSource: localDataSource,
          networkInfo: networkInfo,
        );
      }
    } else {
      // Firebase is not initialized, create repositories with offline-only capabilities
      logger.w('Using offline mode due to Firebase initialization failure');

      // Create repositories with mock data sources for offline mode
      authRepository = AuthRepositoryImpl(
        remoteDataSource: MockAuthRemoteDataSource(),
        networkInfo: networkInfo,
      );

      postRepository = CachedPostRepositoryImpl(
        remoteDataSource: MockPostRemoteDataSource(),
        localDataSource: localDataSource,
        networkInfo: networkInfo,
      );
    }

    // Create router
    final router = createAppRouter();

    // Run the app
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: authRepository,
            )..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<PostBloc>(
            create: (context) => PostBloc(
              postRepository: postRepository,
            ),
          ),
          BlocProvider<SearchBloc>(
            create: (context) => SearchBloc(),
          ),
        ],
        child: MyApp(router: router),
      ),
    );
  }, (error, stackTrace) {
    // Log any errors that occur in the app
    logger.e('Unhandled error in app', error, stackTrace);

    // Report to Crashlytics if enabled
    if (AppConfig().crashReportingEnabled) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    }
  });
}

// Initialize Firebase with a timeout to prevent hanging
Future<FirebaseApp?> _initializeFirebaseWithTimeout(
  Future<FirebaseApp> Function() initFunction,
) async {
  try {
    // Increase timeout to 15 seconds for Firebase initialization
    final app = await initFunction().timeout(const Duration(seconds: 15));
    logger.i('Firebase initialized successfully');
    return app;
  } on TimeoutException {
    logger.w('Firebase initialization timed out. Continuing without Firebase.');
    return null;
  } on Exception catch (e) {
    logger.e('Error initializing Firebase: $e');
    return null;
  }
}

// Separate function to initialize Firebase Messaging
Future<void> _initializeFirebaseMessaging() async {
  try {
    // Request permission for notifications
    final settings = await FirebaseMessaging.instance.requestPermission();

    logger.i('Notification permission: ${settings.authorizationStatus}');

    // Set a timeout for FCM token retrieval
    final fcmToken = await FirebaseMessaging.instance.getToken().timeout(
          const Duration(seconds: 3),
        );
    logger.i("FCM Token: ${fcmToken ?? 'null'}");
  } on TimeoutException {
    logger.w('FCM token retrieval timed out. Continuing without FCM.');
  } on Exception catch (e) {
    logger.e('Error getting FCM token', e);
    // Continue without FCM token
  }
}
