import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility functions for Firebase
class FirebaseUtils {
  /// Private constructor to prevent instantiation
  const FirebaseUtils._();

  /// Extract index creation URL from Firebase error message
  static String? extractIndexUrl(String errorMessage) {
    // Look for the URL pattern in the error message
    final urlRegex = RegExp(
      r'https:\/\/console\.firebase\.google\.com\/v1\/r\/project\/[^\/]+\/firestore\/indexes\?[^\s]+',
    );
    final match = urlRegex.firstMatch(errorMessage);

    if (match != null) {
      return match.group(0);
    }

    return null;
  }

  /// Show a dialog to inform the user about missing Firestore index
  static Future<void> showMissingIndexDialog(
    BuildContext context,
    String errorMessage,
  ) async {
    final indexUrl = extractIndexUrl(errorMessage);

    if (indexUrl == null) {
      log('Could not extract index URL from error message: $errorMessage',
          name: 'showMissingIndexDialog');
      return;
    }

    if (context.mounted) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Database Index Required'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'This feature requires a database index to be created. '
                  'As an admin, you need to create this index in the'
                  ' Firebase console.',
                ),
                SizedBox(height: 16),
                Text(
                  'Until the index is created, the app will use a fallback '
                  'method which may be slower or less accurate.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Create Index'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _launchUrl(indexUrl);
              },
            ),
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  /// Launch a URL
  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log('Could not launch $url', name: '_launchUrl');
    }
  }
}
