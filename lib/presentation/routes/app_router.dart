import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/logger_service.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/chat/chat_list_page.dart';
import '../features/chat/chat_page.dart';
import '../features/home/home_page.dart';
import '../features/post/add_post_page.dart';
import '../features/post/post_detail_page.dart';
import '../features/profile/profile_page.dart';
import '../features/search/search_page.dart';

/// Create a GoRouter instance for the app
GoRouter createAppRouter() {
  final logger = LoggerService();

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      // TODO: Implement auth redirection logic
      // final authState = ref.read(authStateProvider);
      // final isLoggedIn = authState.maybeWhen(
      //   authenticated: (_) => true,
      //   orElse: () => false,
      // );

      // // If the user is not logged in and not on the login or signup page,
      // // redirect to the login page
      // final isLoggingIn = state.matchedLocation == '/login' ||
      //                     state.matchedLocation == '/signup';

      // if (!isLoggedIn && !isLoggingIn) {
      //   return '/login';
      // }

      // // If the user is logged in and on the login or signup page,
      // // redirect to the home page
      // if (isLoggedIn && isLoggingIn) {
      //   return '/';
      // }

      // No redirection needed
      return null;
    },
    routes: [
      // Home route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          // Add post route
          GoRoute(
            path: 'post/add',
            name: 'add-post',
            builder: (context, state) => const AddPostPage(),
          ),
          // Post detail route
          GoRoute(
            path: 'post/:postId',
            name: 'post-detail',
            builder: (context, state) {
              final postId = state.pathParameters['postId'] ?? '';
              return PostDetailPage(postId: postId);
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
              return ProfilePage(userId: userId, isCurrentUser: isCurrentUser);
            },
          ),
          // Search route
          GoRoute(
            path: 'search',
            name: 'search',
            builder: (context, state) => const SearchPage(),
          ),
          // Chat list route
          GoRoute(
            path: 'chats',
            name: 'chats',
            builder: (context, state) => const ChatListPage(),
            routes: [
              // Chat detail route
              GoRoute(
                path: ':chatId',
                name: 'chat-detail',
                builder: (context, state) {
                  final chatId = state.pathParameters['chatId'] ?? '';
                  final receiverId =
                      state.uri.queryParameters['receiverId'] ?? '';
                  final receiverName =
                      state.uri.queryParameters['receiverName'] ?? '';
                  return ChatPage(
                    chatId: chatId,
                    receiverId: receiverId,
                    receiverName: receiverName,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
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
}

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
