import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/post/presentation/blocs/post_bloc.dart';

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
  Widget build(BuildContext context) => BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserPostsLoaded) {
            if (state.posts.isEmpty) {
              return const Center(
                child: Text('No posts yet'),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
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
                      context
                          .read<PostBloc>()
                          .add(LoadUserPostsEvent(userId: userId));
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
        },
      );
}
