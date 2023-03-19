import 'package:bsocial/core/colors.dart';
import 'package:bsocial/provider/bottom_navigation_provider.dart';
import 'package:bsocial/view/screens/home_screen.dart';
import 'package:bsocial/view/screens/profile_screen.dart';
import 'package:bsocial/view/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

ValueNotifier<int> currentIndexNotifier = ValueNotifier(0);

class MobileScreenLayout extends StatelessWidget {
  MobileScreenLayout({super.key});
  final _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<UsersProvider>(context, listen: false).getUserName();
    });
    return Scaffold(
      body: Consumer<BottomNavigationProvider>(
          builder: (context, provider, child) {
        return provider.pages[provider.currentIndex];
      }),

      //  ValueListenableBuilder(
      //   valueListenable: currentIndexNotifier,
      //   builder: ((
      //     context,
      //     updatedIndex,
      //     child,
      //   ) {
      //     return _pages[updatedIndex];
      //   }),
      // ),
      extendBody: true,
      bottomNavigationBar: Consumer<BottomNavigationProvider>(
          builder: (BuildContext context, provider, Widget? child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DotNavigationBar(
            margin: const EdgeInsets.only(left: 20, right: 20),
            currentIndex: provider.currentIndex,
            dotIndicatorColor: Colors.white,
            unselectedItemColor: Colors.grey[300],
            // enableFloatingNavBar: false,
            onTap: (newIndex) {
              provider.onTapIcon(newIndex);
            },
            items: [
              /// Home
              DotNavigationBarItem(
                icon: const Icon(Icons.home),
                selectedColor: mobileBackgroundColor,
              ),

              /// Likes
              DotNavigationBarItem(
                icon: const Icon(Icons.search_outlined),
                selectedColor: mobileBackgroundColor,
              ),

              /// Search
              // DotNavigationBarItem(
              //   icon: const Icon(Icons.search),
              //   selectedColor: const Color(0xff73544C),
              // ),

              /// Profile
              DotNavigationBarItem(
                icon: const Icon(Icons.person),
                selectedColor: const Color(0xff73544C),
              ),
            ],
          ),
        );
      }),
    );
  }
}
