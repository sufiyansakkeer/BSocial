import 'package:bsocial/view/screens/home_screen.dart';
import 'package:bsocial/view/screens/post_screen.dart';
import 'package:bsocial/view/screens/profile_screen.dart';
import 'package:bsocial/view/screens/search_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigationProvider extends ChangeNotifier {
  final pages = [
    const HomeScreen(),
    const SearchScreen(),
    const PostScreen(),
    const ProfileScreen(),
  ];
  int currentIndex = 0;

  onTapIcon(int updatedIndex) {
    currentIndex = updatedIndex;
    notifyListeners();
  }
}
