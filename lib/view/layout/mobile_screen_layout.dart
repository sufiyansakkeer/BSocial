import 'package:bsocial/core/colors.dart';
import 'package:bsocial/view/screens/home_screen.dart';
import 'package:bsocial/view/screens/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';

ValueNotifier<int> currentIndexNotifier = ValueNotifier(0);

class MobileScreenLayout extends StatelessWidget {
  MobileScreenLayout({super.key});
  final _pages = [
    const HomeScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<UsersProvider>(context, listen: false).getUserName();
    });
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: currentIndexNotifier,
        builder: ((
          context,
          updatedIndex,
          child,
        ) {
          return _pages[updatedIndex];
        }),
      ),
      bottomNavigationBar: ValueListenableBuilder(
          valueListenable: currentIndexNotifier,
          builder: (BuildContext context, updatedIndex, Widget? child) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DotNavigationBar(
                margin: const EdgeInsets.only(left: 20, right: 20),
                currentIndex: updatedIndex,
                dotIndicatorColor: Colors.white,
                unselectedItemColor: Colors.grey[300],
                // enableFloatingNavBar: false,
                onTap: (newIndex) {
                  currentIndexNotifier.value = newIndex;
                },
                items: [
                  /// Home
                  DotNavigationBarItem(
                    icon: const Icon(Icons.home),
                    selectedColor: mobileBackgroundColor,
                  ),

                  /// Likes
                  DotNavigationBarItem(
                    icon: const Icon(Icons.favorite),
                    selectedColor: mobileBackgroundColor,
                  ),

                  /// Search
                  // DotNavigationBarItem(
                  //   icon: const Icon(Icons.search),
                  //   selectedColor: const Color(0xff73544C),
                  // ),

                  // /// Profile
                  // DotNavigationBarItem(
                  //   icon: const Icon(Icons.person),
                  //   selectedColor: const Color(0xff73544C),
                  // ),
                ],
              ),
            );
          }),
    );
  }
}
