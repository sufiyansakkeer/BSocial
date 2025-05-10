import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth_bloc.dart';

/// A widget that wraps authenticated content and redirects to login if not
/// authenticated
class AuthWrapper extends StatelessWidget {
  /// Constructor
  const AuthWrapper({
    required this.child,
    super.key,
  });

  /// The child widget to display when authenticated
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            // Use a safer navigation approach with try-catch
            try {
              // Use Future.microtask to avoid navigation during build
              // and to ensure we're not in the middle of a build cycle
              Future.microtask(() {
                // Only navigate if the widget is still mounted
                if (context.mounted) {
                  context.go('/auth/login');
                }
              });
            } on Exception catch (e) {
              debugPrint('Navigation error: $e');
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              // User is authenticated, show the child
              return child;
            } else if (state is AuthLoading) {
              // Show loading indicator while checking auth status
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              // User is not authenticated, show loading while redirecting
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      );
}
