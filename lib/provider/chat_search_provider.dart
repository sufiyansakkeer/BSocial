import 'package:flutter/material.dart';

class ChatSearchProvider extends ChangeNotifier {
  final TextEditingController chatSearchController = TextEditingController();
  bool showUser = false;

  set showUserSet(bool value) => showUser = value;
  onSearchUserFunction() {
    showUser = true;
    notifyListeners();
  }

  onClearUserFunction() {
    showUser = false;
    notifyListeners();
  }
}
