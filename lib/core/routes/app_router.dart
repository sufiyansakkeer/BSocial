import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/mfa_verification_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart'
    as auth_profile;
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/widgets/auth_wrapper.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/chat/presentation/pages/new_chat_page.dart';
import '../../features/chat/presentation/pages/streaming_chat_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/post/presentation/pages/add_post_page.dart';
import '../../features/post/presentation/pages/post_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/ui_showcase/presentation/pages/ui_showcase_page.dart';
import '../../features/user/presentation/pages/user_list_page.dart';
import '../services/logger_service.dart';

/// Custom GoRouter observer for logging navigation events
class GoRouterObserver extends NavigatorObserver {
  final logger = LoggerService();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.i(
      'Navigation: Pushed ${route.settings.name} '
      '(from ${previousRoute?.settings.name})',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.i(
      'Navigation: Popped ${route.settings.name} '
      '(to ${previousRoute?.settings.name})',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.i('Navigation: Removed ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    logger.i(
      'Navigation: Replaced ${oldRoute?.settings.name} '
      'with ${newRoute?.settings.name}',
    );
  }
}

/// Create a GoRouter instance for the app
GoRouter createAppRouter() => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      // Add redirect to handle authentication state
      redirect: (context, state) {
        // Get the current auth state
        final authBloc = context.read<AuthBloc>();
        final authState = authBloc.state;

        // Get the current location
        final location = state.uri.toString();
        final isAuthRoute = location.startsWith('/auth') ||
            location == '/login' ||
            location == '/signup';

        // If authenticated user tries to access auth routes, redirect to home
        if (authState is Authenticated && isAuthRoute) {
          return '/';
        }

        // Otherwise, allow the navigation to proceed
        return null;
      },
      routes: [
        // Home route
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) =>
              const AuthWrapper(child: HomePage()), // Wrap with AuthWrapper
          routes: [
            // Add post route
            GoRoute(
              path: 'post/add',
              name: 'add-post',
              builder: (context, state) => const AuthWrapper(
                  child: AddPostPage()), // Wrap with AuthWrapper
            ),
            // Post detail route
            GoRoute(
              path: 'post/:postId',
              name: 'post-detail',
              builder: (context, state) {
                final postId = state.pathParameters['postId'] ?? '';
                return AuthWrapper(
                    child: PostDetailPage(
                        postId: postId)); // Wrap with AuthWrapper
              },
            ),
            // Profile route
            GoRoute(
              path: 'profile/:userId',
              name: 'profile',
              builder: (context, state) {
                final userId = state.pathParameters['userId'] ?? '';
                final isCurrentUser =
                    state.uri.queryParameters['isCurrentUser'] == 'true';
                return AuthWrapper(
                    child: ProfilePage(
                        userId: userId,
                        isCurrentUser: isCurrentUser)); // Wrap with AuthWrapper
              },
              routes: [
                // Followers route
                GoRoute(
                  path: 'followers',
                  name: 'followers',
                  builder: (context, state) {
                    final userId = state.pathParameters['userId'] ?? '';
                    return AuthWrapper(
                      child: UserListPage(
                        userId: userId,
                        listType: UserListType.followers,
                      ),
                    );
                  },
                ),
                // Following route
                GoRoute(
                  path: 'following',
                  name: 'following',
                  builder: (context, state) {
                    final userId = state.pathParameters['userId'] ?? '';
                    return AuthWrapper(
                      child: UserListPage(
                        userId: userId,
                        listType: UserListType.following,
                      ),
                    );
                  },
                ),
              ],
            ),
            // Search route
            GoRoute(
              path: 'search',
              name: 'search',
              builder: (context, state) => const AuthWrapper(
                  child: SearchPage()), // Wrap with AuthWrapper
            ),
            // Chat list route
            GoRoute(
              path: 'chats',
              name: 'chats',
              builder: (context, state) => const AuthWrapper(
                  child: ChatListPage()), // Wrap with AuthWrapper
              routes: [
                // New chat route
                GoRoute(
                  path: 'new',
                  name: 'new-chat',
                  builder: (context, state) => const AuthWrapper(
                    child: NewChatPage(),
                  ),
                ),
                // Chat detail route
                GoRoute(
                  path: ':roomId',
                  name: 'chat-detail',
                  builder: (context, state) {
                    final roomId = state.pathParameters['roomId'] ?? '';
                    return AuthWrapper(
                      child: StreamingChatPage(roomId: roomId),
                    ); // Wrap with AuthWrapper
                  },
                ),
              ],
            ),
            // UI Showcase route
            GoRoute(
              path: 'ui-showcase',
              name: 'ui-showcase',
              builder: (context, state) => const UIShowcasePage(),
            ),
          ],
        ),
        // Auth routes
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) => const LoginPage(), // Default to login
          routes: [
            GoRoute(
              path: 'login',
              name: 'login',
              builder: (context, state) => const LoginPage(),
            ),
            GoRoute(
              path: 'signup',
              name: 'signup',
              builder: (context, state) => const SignupPage(),
            ),
            GoRoute(
              path: 'forgot-password',
              name: 'forgot-password',
              builder: (context, state) => const ForgotPasswordPage(),
            ),
            GoRoute(
              path: 'change-password',
              name: 'change-password',
              builder: (context, state) => const AuthWrapper(
                child: ChangePasswordPage(),
              ),
            ),
            GoRoute(
              path: 'mfa-verification',
              name: 'mfa-verification',
              builder: (context, state) => const MfaVerificationPage(),
            ),
            GoRoute(
              path: 'profile',
              name: 'auth-profile',
              builder: (context, state) => const AuthWrapper(
                child: auth_profile.ProfilePage(),
              ),
            ),
          ],
        ),
        // Legacy routes for backward compatibility
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
          redirect: (context, state) => '/auth/login',
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
          redirect: (context, state) => '/auth/signup',
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
      observers: [
        GoRouterObserver(),
      ],
    );
