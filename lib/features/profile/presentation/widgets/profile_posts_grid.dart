import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/cache_manager.dart';
import '../../../../core/widgets/animations/bs_staggered_grid_view.dart';
import '../../../../features/post/domain/entities/post.dart';
import '../../../../features/post/presentation/blocs/post_bloc.dart';
import 'profile_posts_skeleton.dart';

/// Widget that displays a grid of user posts
class ProfilePostsGrid extends StatelessWidget {
  /// Constructor
  const ProfilePostsGrid({
    required this.userId,
    super.key,
  });

  /// User ID
  final String userId;

  @override
  Widget build(BuildContext context) {
    // Initialize loading on first build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.mounted) {
        final hasVisited = 
            await CacheManager().hasScreenBeenVisited('profile_$userId');
        if (context.mounted) {
          if (hasVisited) {
            context.read<PostBloc>().add(RefreshUserPostsEvent(userId: userId));
          } else {
            context.read<PostBloc>().add(LoadUserPostsEvent(userId: userId));
            await CacheManager().markScreenVisited('profile_$userId');
          }
        }
      }
    });
    
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        // Handle initial state
        if (state.status == PostStatus.initial) {
          return const ProfilePostsSkeleton();
        }

        // Handle loading state - only show skeleton if we don't have cached data
        if (state.status == PostStatus.loading &&
            (state.posts.isEmpty || !state.isUserPosts)) {
          return const ProfilePostsSkeleton();
        }

        // Handle refreshing state - show posts with a subtle refresh indicator
        if (state.status == PostStatus.refreshing && state.isUserPosts) {
          // Check if the loaded posts are for the current user
          if (state.posts.isNotEmpty && state.posts.first.uid != userId) {
            // If not, reload the correct user's posts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context
                  .read<PostBloc>()
                  .add(RefreshUserPostsEvent(userId: userId));
            });
            return const ProfilePostsSkeleton();
          }
          
          return _buildPostsGrid(state.posts, isRefreshing: true);
        }

        // Handle user posts loaded state
        if (state.status == PostStatus.userPostsLoaded) {
          // Check if the loaded posts are for the current user
          if (state.isUserPosts && state.posts.isNotEmpty) {
            // Check if the first post's user ID matches our user ID
            // This ensures we're showing the right user's posts
            if (state.posts.first.uid != userId) {
              // If not, reload the correct user's posts
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context
                    .read<PostBloc>()
                    .add(LoadUserPostsEvent(userId: userId));
              });
              return const ProfilePostsSkeleton();
            }
          }

          if (state.posts.isEmpty) {
            return const Center(
              child: Text('No posts yet'),
            );
          }

          return _buildPostsGrid(state.posts);
        }

        // Handle error state
        if (state.status == PostStatus.error) {
          // If we have cached posts, show them with an error indicator
          if (state.posts.isNotEmpty &&
              state.isUserPosts &&
              state.posts.first.uid == userId) {
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
                          context
                              .read<PostBloc>()
                              .add(LoadUserPostsEvent(userId: userId));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildPostsGrid(state.posts)),
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
                    context
                        .read<PostBloc>()
                        .add(LoadUserPostsEvent(userId: userId));
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // If we're in posts loaded state but on the profile screen,
        // load user posts
        if (state.status == PostStatus.postsLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (context.mounted) {
              final hasVisited = 
                  await CacheManager().hasScreenBeenVisited('profile_$userId');
              if (context.mounted) {
                if (hasVisited) {
                  context
                      .read<PostBloc>()
                      .add(RefreshUserPostsEvent(userId: userId));
                } else {
                  context
                      .read<PostBloc>()
                      .add(LoadUserPostsEvent(userId: userId));
                  await CacheManager().markScreenVisited('profile_$userId');
                }
              }
            }
          });

          // If we have posts, show them while refreshing
          if (state.posts.isNotEmpty) {
            return _buildPostsGrid(state.posts, isRefreshing: true);
          }

          return const ProfilePostsSkeleton();
        }

        // Default loading state for any other status
        return const ProfilePostsSkeleton();
      },
    );
  }

  /// Build the posts grid with optional refresh indicator
  Widget _buildPostsGrid(List<Post> posts, {bool isRefreshing = false}) =>
      Stack(
        children: [
          BSStaggeredGridView(
            padding: const EdgeInsets.all(2),
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return GestureDetector(
                onTap: () {
                  context.read<PostBloc>().add(
                        SetSelectedPostEvent(post: post),
                      );
                  context.go('/post/${post.postId}');
                },
                child: Image.network(
                  post.postUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              );
            },
            staggerDuration: const Duration(milliseconds: 40),
            initialDelay: const Duration(milliseconds: 100),
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
