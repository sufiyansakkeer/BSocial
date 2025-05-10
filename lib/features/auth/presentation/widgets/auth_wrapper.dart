import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth_bloc.dart';
import '../utils/auth_error_handler.dart';

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
          } else if (state is AuthError) {
            // Handle authentication errors
            AuthErrorHandler.handleError(context, state.message);
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
            } else if (state is AuthError) {
              // For auth errors that don't require immediate redirect,
              // show the error page with a button to go to login
              final errorType = AuthErrorHandler.getErrorType(state.message);

              // Only show error page for certain error types
              if (errorType == AuthErrorType.networkError ||
                  errorType == AuthErrorType.serverError) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Authentication Error'),
                  ),
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.go('/auth/login'),
                            child: const Text('Go to Login'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add(CheckAuthStatusEvent());
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // For other error types, show loading while redirecting
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
