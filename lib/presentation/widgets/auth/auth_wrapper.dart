import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';

/// A widget that listens to auth state changes and redirects accordingly
class AuthWrapper extends StatelessWidget {
  /// Constructor
  const AuthWrapper({
    required this.child,
    super.key,
  });

  /// The child widget to display
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            // Redirect to login page when user is unauthenticated
            try {
              // Check if GoRouter is available in the context before navigating
              if (GoRouter.maybeOf(context) != null) {
                context.pushReplacement('/login');
              }
            } on Exception catch (e) {
              // Log the error but don't crash the app
              debugPrint('Error navigating to login: $e');
            }
          } else if (state is AuthError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: child,
      );
}
