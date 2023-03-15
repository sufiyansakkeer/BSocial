import 'package:bsocial/core/colors.dart';
import 'package:bsocial/view/layout/mobile_screen_layout.dart';
import 'package:bsocial/view/layout/responsive_layout_building.dart';
import 'package:bsocial/view/layout/web_screen_layout.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BSocial',
        theme: ThemeData.dark()
            .copyWith(scaffoldBackgroundColor: mobileBackgroundColor),
        home: const ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobileScreenLayout: MobileScreenLayout()));
  }
}
