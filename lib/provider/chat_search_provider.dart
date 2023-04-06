import 'package:flutter/material.dart';

class ChatSearchProvider extends ChangeNotifier {
  final TextEditingController chatSearchController = TextEditingController();
  bool showUser = false;
  onSearchUserFunction() {
    showUser = true;
    notifyListeners();
  }

  onClearUserFunction() {
    showUser = false;
    notifyListeners();
  }
}
