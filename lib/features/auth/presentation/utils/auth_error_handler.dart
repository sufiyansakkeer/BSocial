import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';

/// Enum representing different types of authentication errors
enum AuthErrorType {
  /// No user is currently signed in
  noCurrentUser,

  /// User data not found in database
  userDataNotFound,

  /// User credentials are invalid
  invalidCredentials,

  /// Network error
  networkError,

  /// Server error
  serverError,

  /// Permission denied
  permissionDenied,

  /// Account disabled or deleted
  accountDisabled,

  /// Session expired
  sessionExpired,

  /// Other unspecified error
  other
}

/// Class to handle authentication errors in a consistent way
class AuthErrorHandler {
  /// Private constructor to prevent instantiation
  const AuthErrorHandler._();

  /// Determine the type of authentication error from the error message
  static AuthErrorType getErrorType(String errorMessage) {
    final lowerCaseMessage = errorMessage.toLowerCase();

    if (lowerCaseMessage.contains('no user is currently signed in') ||
        lowerCaseMessage.contains('user not logged in')) {
      return AuthErrorType.noCurrentUser;
    } else if (lowerCaseMessage.contains('user data not found')) {
      return AuthErrorType.userDataNotFound;
    } else if (lowerCaseMessage.contains('wrong password') ||
        lowerCaseMessage.contains('invalid email') ||
        lowerCaseMessage.contains('user not found')) {
      return AuthErrorType.invalidCredentials;
    } else if (lowerCaseMessage.contains('network') ||
        lowerCaseMessage.contains('connection') ||
        lowerCaseMessage.contains('internet')) {
      return AuthErrorType.networkError;
    } else if (lowerCaseMessage.contains('server') ||
        lowerCaseMessage.contains('timeout') ||
        lowerCaseMessage.contains('unavailable') ||
        lowerCaseMessage.contains('internal error')) {
      return AuthErrorType.serverError;
    } else if (lowerCaseMessage.contains('permission') ||
        lowerCaseMessage.contains('access denied')) {
      return AuthErrorType.permissionDenied;
    } else if (lowerCaseMessage.contains('disabled') ||
        lowerCaseMessage.contains('deleted')) {
      return AuthErrorType.accountDisabled;
    } else if (lowerCaseMessage.contains('expired') ||
        lowerCaseMessage.contains('session')) {
      return AuthErrorType.sessionExpired;
    } else {
      return AuthErrorType.other;
    }
  }

  /// Handle authentication error based on its type
  static void handleError(
    BuildContext context,
    String errorMessage, {
    bool showSnackbar = true,
  }) {
    final errorType = getErrorType(errorMessage);

    // Log the error
    debugPrint('Auth Error: $errorMessage (Type: $errorType)');

    // Show error message in a snackbar if requested
    if (showSnackbar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getDisplayMessage(errorType, errorMessage)),
          backgroundColor: _getErrorColor(errorType),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }

    // Handle navigation based on error type
    _handleNavigation(context, errorType);
  }

  /// Get a user-friendly error message based on the error type
  static String _getDisplayMessage(
    AuthErrorType errorType,
    String originalMessage,
  ) {
    switch (errorType) {
      case AuthErrorType.noCurrentUser:
        return 'You need to sign in to continue';
      case AuthErrorType.userDataNotFound:
        return 'Your account information could not be found';
      case AuthErrorType.invalidCredentials:
        return 'Invalid email or password';
      case AuthErrorType.networkError:
        return 'Network error. Please check your connection';
      case AuthErrorType.serverError:
        return 'Server error. Please try again later';
      case AuthErrorType.permissionDenied:
        return 'You don\'t have permission to access this feature';
      case AuthErrorType.accountDisabled:
        return 'Your account has been disabled';
      case AuthErrorType.sessionExpired:
        return 'Your session has expired. Please sign in again';
      case AuthErrorType.other:
        // For other errors, use the original message but make it user-friendly
        return originalMessage.startsWith('Failed to')
            ? originalMessage
            : 'Authentication error: $originalMessage';
    }
  }

  /// Get appropriate color for the error type
  static Color _getErrorColor(AuthErrorType errorType) {
    switch (errorType) {
      case AuthErrorType.networkError:
        return Colors.orange;
      case AuthErrorType.serverError:
        return Colors.deepPurple;
      case AuthErrorType.permissionDenied:
        return Colors.deepOrange;
      case AuthErrorType.accountDisabled:
        return Colors.red.shade800;
      default:
        return Colors.red;
    }
  }

  /// Handle navigation based on error type
  static void _handleNavigation(BuildContext context, AuthErrorType errorType) {
    // For these error types, navigate to login page
    final shouldNavigateToLogin = [
      AuthErrorType.noCurrentUser,
      AuthErrorType.userDataNotFound,
      AuthErrorType.sessionExpired,
      AuthErrorType.accountDisabled,
    ].contains(errorType);

    // For server errors, we typically don't navigate automatically
    // as the user might want to retry the operation
    final isServerRelatedError = [
      AuthErrorType.serverError,
      AuthErrorType.networkError,
    ].contains(errorType);

    if (shouldNavigateToLogin) {
      // Use Future.microtask to avoid navigation during build
      Future.microtask(() {
        if (context.mounted) {
          context.go('/auth/login');
        }
      });
    } else if (isServerRelatedError) {
      // For server errors, we don't navigate automatically
      // The error page with retry option will be shown by the AuthWrapper
    }
  }

  /// Handle AuthFailure from repositories
  static void handleAuthFailure(BuildContext context, AuthFailure failure) {
    handleError(context, failure.message);
  }
}
