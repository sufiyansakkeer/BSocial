import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'core/errors/error_handler.dart';
import 'core/services/cache_manager.dart';
import 'core/services/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/custom_scroll_physics.dart';
import 'core/utils/snackbar_utils.dart';
import 'di/injection_container.dart' as di;
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/providers/auth/auth_provider.dart';
import 'presentation/providers/chat/chat_provider.dart';
import 'presentation/providers/navigation/navigation_provider.dart';
import 'presentation/providers/post/post_provider.dart';
import 'presentation/providers/profile/profile_provider.dart';
import 'presentation/providers/user/user_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling and timeout
  try {
    // Set a timeout for Firebase initialization to prevent app from hanging
    if (kIsWeb) {
      await _initializeFirebaseWithTimeout(
        () => Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCNm9bInJPhx4C-QMFDvGUPmGBcTZiqWQ4",
            appId: "1:788358758157:web:52a33c61c5f95b56f8ba44",
            messagingSenderId: "788358758157",
            projectId: "bsocial-9e6c3",
            storageBucket: "bsocial-9e6c3.appspot.com",
          ),
        ),
      );
    } else {
      await _initializeFirebaseWithTimeout(() => Firebase.initializeApp());
    }

    // Set up Crashlytics (only if Firebase initialized successfully)
    try {
      // Set up Crashlytics error reporting
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      // Set up error handling for async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        // Use our custom error handler to log the error
        ErrorHandler().handleError(error);
        return true;
      };
    } catch (e) {
      log("Error setting up Crashlytics: ${e.toString()}");
    }

    // Try to get FCM token but don't block app startup if it fails
    if (!kIsWeb) {
      _initializeFirebaseMessaging();
    }
  } catch (e) {
    log("Error initializing Firebase: ${e.toString()}");
    // Continue without Firebase if initialization fails
  }

  // Initialize Hive for local storage
  try {
    await HiveService.init();
    log('Hive initialized successfully');

    // Initialize and schedule cache cleanup
    final cacheManager = CacheManager();
    await cacheManager.init();
    cacheManager.scheduleCacheCleanup(
      cleanupInterval: const Duration(days: 1),
      maxAge: const Duration(days: 7),
    );
    log('Cache manager initialized successfully');
  } catch (e) {
    log('Error initializing local storage: ${e.toString()}');
    // Continue without local storage if initialization fails
  }

  // Initialize dependency injection
  await di.init();

  // Run the app regardless of Firebase initialization status
  runApp(Phoenix(child: const MyApp()));
}

// Initialize Firebase with a timeout to prevent hanging
Future<void> _initializeFirebaseWithTimeout(
  Future<FirebaseApp> Function() initFunction,
) async {
  try {
    // Set a timeout of 5 seconds for Firebase initialization
    await initFunction().timeout(const Duration(seconds: 5));
  } on TimeoutException {
    log("Firebase initialization timed out. Continuing without Firebase.");
    throw Exception("Firebase initialization timed out");
  }
}

// Separate function to initialize Firebase Messaging
Future<void> _initializeFirebaseMessaging() async {
  try {
    // Set a timeout for FCM token retrieval
    final fcmToken = await FirebaseMessaging.instance.getToken().timeout(
          const Duration(seconds: 3),
        );
    log("FCM Token: ${fcmToken ?? 'null'}");
  } on TimeoutException {
    log("FCM token retrieval timed out. Continuing without FCM.");
  } catch (e) {
    log("Error getting FCM token: ${e.toString()}");
    // Continue without FCM token
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        // Navigation provider
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        // Profile provider
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),
        // Post provider
        ChangeNotifierProvider(create: (_) => di.sl<PostProvider>()),
        // User provider
        ChangeNotifierProvider(create: (_) => di.sl<UserProvider>()),
        // Chat provider
        ChangeNotifierProvider(create: (_) => di.sl<ChatProvider>()),
      ],
      child: OverlaySupport.global(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BSocial',
          theme: AppTheme.darkTheme,
          scaffoldMessengerKey: SnackbarUtils.scaffoldMessengerKey,
          scrollBehavior: CustomScrollBehavior(),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).init();
    });

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while checking auth state
        if (authProvider.status == AuthStatus.initial ||
            authProvider.status == AuthStatus.loading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Image.asset('assets/BSocial-1.png', height: 120),
                  ),
                  const SizedBox(height: 40),
                  // Pulsating loading indicator
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show login page if not authenticated
        if (authProvider.status == AuthStatus.unauthenticated ||
            authProvider.status == AuthStatus.error) {
          return const LoginPage();
        }

        // Show home page if authenticated
        return const HomePage();
      },
    );
  }
}
