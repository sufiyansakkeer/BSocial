import 'package:flutter/material.dart';

class PostCardProvider extends ChangeNotifier {
  bool isLikeAnimation = false;
  animationTrue() {
    isLikeAnimation = true;
    notifyListeners();
  }

  animationFalse() {
    isLikeAnimation = false;
    notifyListeners();
  }
}
