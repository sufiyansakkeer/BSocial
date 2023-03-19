import 'package:bsocial/core/colors.dart';
import 'package:bsocial/provider/bottom_navigation_provider.dart';
import 'package:bsocial/provider/google_button_provider.dart';
import 'package:bsocial/provider/login_screen_provider.dart';
import 'package:bsocial/provider/mobile_screen_provider.dart';
import 'package:bsocial/provider/users_provider.dart';
import 'package:bsocial/provider/sign_up_provider.dart';
import 'package:bsocial/view/layout/mobile_screen_layout.dart';
import 'package:bsocial/view/layout/web_screen_layout.dart';
import 'package:bsocial/view/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/layout/responsive_layout_building.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //* Initialize fire base
  //* KIsWeb is a constant that is true when its running in web
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCNm9bInJPhx4C-QMFDvGUPmGBcTZiqWQ4",
        appId: "1:788358758157:web:52a33c61c5f95b56f8ba44",
        messagingSenderId: "788358758157",
        projectId: "bsocial-9e6c3",
        storageBucket: "bsocial-9e6c3.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BSocial',
        theme: ThemeData.dark()
            .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          // initialData: initialData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            //here we checking our connection is made with the stream,active means we have made connection with the stream
            if (snapshot.connectionState == ConnectionState.active) {
              //here hasData is used to check if the user is authenticated or not
              if (snapshot.hasData) {
                return const ResponsiveLayout(
                  webScreenLayout: WebScreenLayout(),
                  mobileScreenLayout: MobileScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
