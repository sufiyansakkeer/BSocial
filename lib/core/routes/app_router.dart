import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/features/auth/login_page.dart';
import '../../presentation/features/auth/signup_page.dart';
import '../../presentation/features/chat/chat_list_page.dart';
import '../../presentation/features/chat/chat_page.dart';
import '../../presentation/features/home/home_page.dart';
import '../../presentation/features/post/add_post_page.dart';
import '../../presentation/features/post/post_detail_page.dart';
import '../../presentation/features/profile/profile_page.dart';
import '../../presentation/features/search/search_page.dart';
import '../services/logger_service.dart';
import '../../presentation/widgets/auth/auth_wrapper.dart'; // Import AuthWrapper

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
                    return AuthWrapper(
                        child: ChatPage(
                      chatId: chatId,
                      receiverId: receiverId,
                      receiverName: receiverName,
                    )); // Wrap with AuthWrapper
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
