import 'package:bsocial/core/colors.dart';
import 'package:bsocial/provider/bottom_navigation_provider.dart';

import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

ValueNotifier<int> currentIndexNotifier = ValueNotifier(0);

class MobileScreenLayout extends StatelessWidget {
  const MobileScreenLayout({super.key});

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
      extendBody: true,
      bottomNavigationBar: Consumer<BottomNavigationProvider>(
          builder: (BuildContext context, provider, Widget? child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DotNavigationBar(
            margin: const EdgeInsets.only(left: 20, right: 20),
            currentIndex: provider.currentIndex,
            dotIndicatorColor: mobileBackgroundColor,
            unselectedItemColor: Colors.grey[300],
            enableFloatingNavBar: true,
            curve: Curves.easeInOutCubicEmphasized,
            onTap: (newIndex) {
              provider.onTapIcon(newIndex);
              HapticFeedback.lightImpact();
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
