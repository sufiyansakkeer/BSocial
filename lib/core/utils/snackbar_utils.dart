import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui_constants.dart';

/// Enhanced snackbar utility functions with animations and micro-interactions
class SnackbarUtils {
  // Factory constructor
  factory SnackbarUtils() => _instance;

  // Private constructor
  SnackbarUtils._internal();

  // Singleton instance
  static final SnackbarUtils _instance = SnackbarUtils._internal();

  // Global key for accessing ScaffoldMessenger from anywhere
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Show an animated snackbar with the given content
  void showSnackBar(
    String content,
    BuildContext context, {
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool enableHapticFeedback = true,
  }) {
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    // Provide haptic feedback based on type
    if (enableHapticFeedback) {
      switch (type) {
        case SnackBarType.success:
          HapticFeedback.lightImpact();
          break;
        case SnackBarType.warning:
          HapticFeedback.mediumImpact();
          break;
        case SnackBarType.error:
          HapticFeedback.heavyImpact();
          break;
        case SnackBarType.info:
          // No haptic feedback for info type
          break;
      }
    }

    // Get colors and icon based on type
    final (Color backgroundColor, IconData icon) =
        _getSnackBarStyle(type, context);

    // Show the snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusMedium),
        ),
        margin: const EdgeInsets.all(12),
        duration: duration,
        action: action,
        animation: _createSnackBarAnimation(context),
      ),
    );
  }

  /// Show a snackbar with the global key
  /// (can be used outside of a build context)
  void showGlobalSnackBar(
    String content, {
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    // Get the current context from the global key
    final context = scaffoldMessengerKey.currentContext;
    if (context == null) {
      // Fallback to basic snackbar if context is not available
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(content),
          duration: duration,
          action: action,
        ),
      );
      return;
    }

    // Use the context-based method
    showSnackBar(
      content,
      context,
      type: type,
      duration: duration,
      action: action,
      enableHapticFeedback:
          false, // Disable haptic feedback for global snackbars
    );
  }

  /// Create a custom animation for the snackbar
  Animation<double> _createSnackBarAnimation(BuildContext context) {
    // Create a dummy controller for the animation
    // Note: This is just to create the animation curve, the actual animation
    // will be controlled by the SnackBar widget
    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 500),
    );

    // Create a custom animation that bounces slightly
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 75,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(controller);
  }

  /// Get the style for the snackbar based on type
  (Color, IconData) _getSnackBarStyle(SnackBarType type, BuildContext context) {
    final theme = Theme.of(context);

    switch (type) {
      case SnackBarType.success:
        return (Colors.green.shade700, Icons.check_circle);
      case SnackBarType.warning:
        return (Colors.orange.shade700, Icons.warning_amber);
      case SnackBarType.error:
        return (Colors.red.shade700, Icons.error);
      case SnackBarType.info:
        return (theme.colorScheme.primary, Icons.info);
    }
  }
}

/// Snackbar type enum
enum SnackBarType {
  info,
  success,
  warning,
  error,
}
