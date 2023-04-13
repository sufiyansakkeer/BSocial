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

  runApp(Phoenix(child: MyApp()));
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
          home: Main(),
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
    return StreamBuilder(
      // here we use authStateChanges to listen if there any changes in the user authentication
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //here we checking our connection is made with the stream,active means we have made connection with the stream
        if (snapshot.connectionState == ConnectionState.active) {
          //here hasData is used to check if the user is authenticated or not
          if (snapshot.hasData) {
            Provider.of<ProfileScreenProvider>(context, listen: false)
                .getData(FirebaseAuth.instance.currentUser!.uid);
            Provider.of<UpdateScreenProvider>(context, listen: false).getData();
            Provider.of<UsersProvider>(context, listen: false).refreshUi;
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
    );
  }
}
