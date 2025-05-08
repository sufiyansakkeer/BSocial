import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  
  // Getter for current index
  int get currentIndex => _currentIndex;
  
  // Change the current index
  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
  
  // Reset to home page
  void resetToHome() {
    _currentIndex = 0;
    notifyListeners();
  }
}
