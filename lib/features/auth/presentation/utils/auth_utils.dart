import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth_bloc.dart';
import 'auth_error_handler.dart';

/// Utility functions for authentication
class AuthUtils {
  /// Private constructor to prevent instantiation
  const AuthUtils._();

  /// Check if the user is authenticated and handle errors
  ///
  /// Returns true if the user is authenticated, false otherwise.
  /// If an error occurs, it will be handled by the [AuthErrorHandler].
  static bool checkAuthenticated(
    BuildContext context, {
    bool navigateToLogin = true,
    bool showErrorMessage = true,
  }) {
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      return true;
    } else if (authState is AuthError) {
      if (showErrorMessage) {
        AuthErrorHandler.handleError(
          context,
          authState.message,
          showSnackbar: showErrorMessage,
        );
      }
      return false;
    } else if (authState is Unauthenticated) {
      if (navigateToLogin) {
        // Navigate to login page
        Future.microtask(() {
          if (context.mounted) {
            context.go('/auth/login');
          }
        });
      }
      return false;
    }

    // For other states (like AuthLoading, AuthInitial), don't take action
    return false;
  }

  /// Force check authentication status by dispatching CheckAuthStatusEvent
  ///
  /// This is useful when you want to make sure the authentication status
  /// is up-to-date, for example when a protected page is loaded.
  static void forceCheckAuthStatus(BuildContext context) {
    context.read<AuthBloc>().add(CheckAuthStatusEvent());
  }

  /// Sign out the user
  static void signOut(BuildContext context) {
    context.read<AuthBloc>().add(const SignOutEvent());
  }

  /// Check if the current user has a specific permission
  static void checkPermission(
    BuildContext context,
    String permission, {
    Function({required bool hasPermission})? onResult,
  }) {
    final authBloc = context.read<AuthBloc>();

    // First check if the user is authenticated
    if (authBloc.state is! Authenticated) {
      if (onResult != null) {
        onResult(hasPermission: false);
      }
      return;
    }

    // Dispatch the check permission event
    authBloc.add(CheckPermissionEvent(permission: permission));

    // The result will be handled by the BlocListener in the UI
  }
}
