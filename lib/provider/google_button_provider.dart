import 'package:flutter/material.dart';

class GoogleButtonProvider extends ChangeNotifier {
  bool isSigningIn = false;
  signInTrue() {
    isSigningIn = true;
    notifyListeners();
  }

  signInFalse() {
    isSigningIn = false;
    notifyListeners();
  }
}
