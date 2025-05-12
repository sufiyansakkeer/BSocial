import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/cache_manager.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../core/widgets/animations/bs_staggered_list_view.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../../../features/post/domain/entities/post.dart';
import '../../../../features/post/presentation/blocs/post_bloc.dart';
import '../../../../features/post/presentation/pages/add_post_page.dart';
import '../../../../features/post/presentation/widgets/post_card.dart';
import '../../../../features/post/presentation/widgets/post_skeleton_loader.dart';
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

    // Check if we have cached posts
    final postState = context.read<PostBloc>().state;
    if (postState.hasLoadedData) {
      // If we already have data, refresh in the background
      context.read<PostBloc>().add(RefreshPostsEvent());
    } else {
      // Otherwise, load posts with loading indicator
      context.read<PostBloc>().add(LoadPostsEvent());
    }

    // Mark the home screen as visited
    CacheManager().markScreenVisited('home_feed');
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
              icon: const Icon(Icons.palette),
              tooltip: 'UI Showcase',
              onPressed: () => context.go('/ui-showcase'),
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
        // When on the home tab, load posts if they haven't been loaded yet
        final postState = context.read<PostBloc>().state;
        if (postState.status == PostStatus.initial) {
          context.read<PostBloc>().add(LoadPostsEvent());
        }
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
          // Load user posts when navigating to profile
          context
              .read<PostBloc>()
              .add(LoadUserPostsEvent(userId: authState.user.uid));
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
          // Handle initial state
          if (state.status == PostStatus.initial) {
            // Trigger loading if we're in initial state
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<PostBloc>().add(LoadPostsEvent());
            });
            return const PostSkeletonLoader();
          }

          // Handle loading state - only show skeleton if we don't have cached data
          if (state.status == PostStatus.loading && state.posts.isEmpty) {
            return const PostSkeletonLoader();
          }

          // Handle refreshing state - show posts with a subtle refresh indicator
          if (state.status == PostStatus.refreshing) {
            return _buildPostsList(
              state.posts,
              isRefreshing: true,
            );
          }

          // Handle loaded posts
          if (state.status == PostStatus.postsLoaded) {
            if (state.posts.isEmpty) {
              return const Center(
                child: Text('No posts yet. Be the first to post!'),
              );
            }

            return _buildPostsList(state.posts);
          }

          // Handle error state
          if (state.status == PostStatus.error) {
            // If we have cached posts, show them with an error indicator
            if (state.posts.isNotEmpty) {
              return Column(
                children: [
                  Container(
                    color: Colors.red.withAlpha(25),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage ?? 'Error refreshing data',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<PostBloc>().add(LoadPostsEvent());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildPostsList(state.posts)),
                ],
              );
            }

            // If no cached posts, show full error screen
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'An error occurred'),
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
          }

          // If we're in user posts loaded state but on the feed screen,
          // refresh feed posts in the background
          if (state.status == PostStatus.userPostsLoaded &&
              _currentIndex == 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // If we have posts, refresh in background, otherwise load with indicator
              if (state.posts.isNotEmpty) {
                context.read<PostBloc>().add(RefreshPostsEvent());
              } else {
                context.read<PostBloc>().add(LoadPostsEvent());
              }
            });

            // If we have posts, show them while refreshing
            if (state.posts.isNotEmpty) {
              return _buildPostsList(state.posts, isRefreshing: true);
            }

            return const PostSkeletonLoader();
          }

          // Default loading state for any other status
          return const PostSkeletonLoader();
        },
      );

  /// Build the posts list with refresh functionality
  Widget _buildPostsList(List<Post> posts, {bool isRefreshing = false}) =>
      Stack(
        children: [
          BSStaggeredListView(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(post: post);
            },
            onRefresh: () async {
              // Use regular load for pull-to-refresh (with loading indicator)
              context.read<PostBloc>().add(LoadPostsEvent());
            },
            itemDuration: const Duration(milliseconds: 400),
            staggerDuration: const Duration(milliseconds: 80),
            initialDelay: const Duration(milliseconds: 100),
            padding: const EdgeInsets.only(bottom: 16),
          ),
          if (isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 2,
                child: LinearProgressIndicator(),
              ),
            ),
        ],
      );
}
