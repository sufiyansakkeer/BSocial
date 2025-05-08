import 'package:flutter/material.dart';

// Snackbar utility functions moved from utils/utils.dart
class SnackbarUtils {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
      
  // Show a snackbar with the given content
  static void showSnackBar(String content, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
      ),
    );
  }
  
  // Show a snackbar with the global key (can be used outside of a build context)
  static void showGlobalSnackBar(String content) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(content),
      ),
    );
  }
}
