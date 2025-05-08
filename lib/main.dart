import 'dart:async';
import 'dart:developer';

import 'package:bsocial/provider/chat_search_provider.dart';
import 'package:bsocial/provider/comment_provider.dart';
import 'package:bsocial/provider/followers_provider.dart';
import 'package:bsocial/provider/following_provider.dart';
import 'package:bsocial/provider/message_screen_provider.dart';
import 'package:bsocial/provider/post_card_provider.dart';
import 'package:bsocial/provider/post_image_provider.dart';
import 'package:bsocial/provider/profile_screen_provider.dart';
import 'package:bsocial/provider/search_provider.dart';
import 'package:bsocial/provider/update_screen_provider.dart';
import 'package:bsocial/utils/colors.dart';
import 'package:bsocial/provider/bottom_navigation_provider.dart';
import 'package:bsocial/provider/google_button_provider.dart';
import 'package:bsocial/provider/login_screen_provider.dart';
import 'package:bsocial/provider/mobile_screen_provider.dart';
import 'package:bsocial/provider/users_provider.dart';
import 'package:bsocial/provider/sign_up_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:bsocial/view/layout/mobile_screen_layout.dart';
import 'package:bsocial/view/layout/web_screen_layout.dart';
import 'package:bsocial/view/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'view/layout/responsive_layout_building.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
      await _initializeFirebaseWithTimeout(
        () => Firebase.initializeApp(),
      );
    }

    // Set up Crashlytics (only if Firebase initialized successfully)
    try {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
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

  // Run the app regardless of Firebase initialization status
  runApp(Phoenix(child: const MyApp()));
}

// Initialize Firebase with a timeout to prevent hanging
Future<void> _initializeFirebaseWithTimeout(
    Future<FirebaseApp> Function() initFunction) async {
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
    final fcmToken = await FirebaseMessaging.instance
        .getToken()
        .timeout(const Duration(seconds: 3));
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
    // FirebaseCrashlytics.instance.crash();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LoginScreenProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SignUpScreenProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UsersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MobileScreenProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BottomNavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => GoogleButtonProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PostImageProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PostCardProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CommentProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileScreenProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UpdateScreenProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FollowerProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FollowingProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatSearchProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => MessageProvider(),
        ),
      ],
      child: OverlaySupport.global(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BSocial',
          theme: ThemeData.dark(useMaterial3: true)
              .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
          home: const Main(),
        ),
      ),
    );
  }
}

class Main extends StatelessWidget {
  const Main({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Handle potential Firebase Auth errors
    try {
      return StreamBuilder(
        // here we use authStateChanges to listen if there any changes in the user authentication
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          // Handle connection errors
          if (snapshot.hasError) {
            log("Auth stream error: ${snapshot.error}");
            return _buildErrorScreen(
              context,
              "Authentication error",
              "There was a problem connecting to the authentication service.",
            );
          }

          // Handle different connection states
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              // User is authenticated
              if (snapshot.hasData && snapshot.data != null) {
                return _buildAuthenticatedScreen(context);
              }
              // User is not authenticated
              return const LoginScreen();

            case ConnectionState.waiting:
              // Show loading indicator while waiting for auth state
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );

            default:
              // Handle other connection states (none, done)
              return const LoginScreen();
          }
        },
      );
    } catch (e) {
      // Catch any errors in the Firebase Auth setup
      log("Critical error in Firebase Auth: ${e.toString()}");
      return _buildErrorScreen(
        context,
        "Authentication Service Unavailable",
        "Please check your internet connection and try again later.",
      );
    }
  }

  // Build the authenticated screen with proper error handling
  Widget _buildAuthenticatedScreen(BuildContext context) {
    try {
      // Load user data in a safe way, without blocking the UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (FirebaseAuth.instance.currentUser != null) {
            Provider.of<ProfileScreenProvider>(context, listen: false)
                .getData(FirebaseAuth.instance.currentUser!.uid);
            Provider.of<UpdateScreenProvider>(context, listen: false).getData();
            Provider.of<UsersProvider>(context, listen: false).refreshUi();
          }
        } catch (e) {
          log("Error loading user data: ${e.toString()}");
          // Show a snackbar with the error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error loading profile data: ${e.toString()}"),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });

      // Return the main app layout
      return const ResponsiveLayout(
        webScreenLayout: WebScreenLayout(),
        mobileScreenLayout: MobileScreenLayout(),
      );
    } catch (e) {
      log("Error building authenticated screen: ${e.toString()}");
      return _buildErrorScreen(
        context,
        "Error Loading App",
        "There was a problem loading the application. Please try again.",
      );
    }
  }

  // Build an error screen with a sign out button
  Widget _buildErrorScreen(BuildContext context, String title, String message) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 70, color: Colors.red[300]),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  try {
                    FirebaseAuth.instance.signOut();
                  } catch (e) {
                    log("Error signing out: ${e.toString()}");
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
