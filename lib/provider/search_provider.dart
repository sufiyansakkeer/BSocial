import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  bool isShowUser = false;
  void disposeMethod() {
    searchController.clear();
  }

  void showUser() {
    isShowUser = true;
    notifyListeners();
  }

  void hideUser() {
    isShowUser = false;
    notifyListeners();
  }
}
