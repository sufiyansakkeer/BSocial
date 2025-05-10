import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../../../features/post/presentation/blocs/post_bloc.dart';
import '../../../../features/post/presentation/pages/add_post_page.dart';
import '../../../../features/post/presentation/widgets/post_card.dart';
import '../../../../features/profile/presentation/pages/profile_page.dart';
import '../../../../features/search/presentation/pages/search_page.dart';

/// Home page with bottom navigation
class HomePage extends StatefulWidget {
  /// Constructor
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load posts when the page is first loaded
    context.read<PostBloc>().add(LoadPostsEvent());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _buildAppBar(), // Call the new method
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Navigate based on the selected tab
            switch (index) {
              case 1: // Search
                // No navigation needed here, _buildBody handles it.
                break;
              case 2: // Add Post
                // No navigation needed here, _buildBody handles it.
                break;
              case 4: // Profile
                // No navigation needed here, _buildBody handles it.
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_outlined),
              activeIcon: Icon(Icons.favorite),
              label: 'Activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );

  /// Build the app bar based on the current tab
  PreferredSizeWidget? _buildAppBar() {
    switch (_currentIndex) {
      case 0: // Home
        return AppBar(
          title: const Text('BSocial'),
          actions: [
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () => context.go('/chats'),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(const SignOutEvent());
              },
            ),
          ],
        );
      case 1: // Search
        return AppBar(
          title: const Text('Search'),
        );
      case 2: // Add Post
        return AppBar(
          title: const Text('Add Post'),
        );
      case 3: // Activity
        return AppBar(
          title: const Text('Activity'),
        );
      case 4: // Profile
        // ProfilePage has its own AppBar, so HomePage doesn't need to show one.
        return null;
      default:
        return AppBar(title: const Text('BSocial'));
    }
  }

  /// Build the body based on the current tab
  Widget _buildBody() {
    // Return different screens based on the selected navigation index
    switch (_currentIndex) {
      case 0:
        return _buildFeedScreen();
      case 1:
        return const SearchPage();
      case 2:
        return const AddPostPage();
      case 3:
        return const Center(child: Text('Activity Screen'));
      case 4:
        // Display ProfilePage directly in the body
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          return ProfilePage(userId: authState.user.uid, isCurrentUser: true);
        }
        // AuthWrapper should prevent unauthenticated access to HomePage.
        // If somehow reached, show a placeholder or error.
        return const Center(child: Text('Please log in to see your profile.'));
      default:
        return _buildFeedScreen();
    }
  }

  /// Build the feed screen
  Widget _buildFeedScreen() => BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PostsLoaded) {
            if (state.posts.isEmpty) {
              return const Center(
                child: Text('No posts yet. Be the first to post!'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostBloc>().add(LoadPostsEvent());
              },
              child: ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return PostCard(post: post);
                },
              ),
            );
          } else if (state is PostError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PostBloc>().add(LoadPostsEvent());
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Feed Screen - To be implemented'),
            );
          }
        },
      );
}
