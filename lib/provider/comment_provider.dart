import 'package:flutter/material.dart';

class CommentProvider extends ChangeNotifier {
  final TextEditingController commentController = TextEditingController();

  void disposeController() {
    commentController.clear();
    notifyListeners();
  }
}
