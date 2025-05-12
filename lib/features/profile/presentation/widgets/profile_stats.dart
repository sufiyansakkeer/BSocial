import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/animations/bs_animated_container.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/post/presentation/blocs/post_bloc.dart';

/// Widget that displays profile statistics
class ProfileStats extends StatelessWidget {
  /// Constructor
  const ProfileStats({
    required this.user,
    this.onFollowersPressed,
    this.onFollowingPressed,
    super.key,
  });

  /// User
  final User user;

  /// Callback when followers count is pressed
  final VoidCallback? onFollowersPressed;

  /// Callback when following count is pressed
  final VoidCallback? onFollowingPressed;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Posts count
          BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              var postCount = '0';

              // If we have user posts loaded and they belong to the current user
              if (state.status == PostStatus.userPostsLoaded &&
                  state.isUserPosts &&
                  state.posts.isNotEmpty &&
                  state.posts.first.uid == user.uid) {
                postCount = state.posts.length.toString();
              }
              // If posts are loading
              else if (state.status == PostStatus.loading) {
                postCount = '-';
              }
              // If we don't have the right posts loaded yet, trigger a load
              else if (state.status != PostStatus.loading) {
                // Only trigger once to avoid infinite loops
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context
                      .read<PostBloc>()
                      .add(LoadUserPostsEvent(userId: user.uid));
                });
              }

              return BSAnimatedContainer(
                animationType: BSAnimationType.fadeScale,
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 200),
                child: _buildStatColumn('Posts', postCount),
              );
            },
          ),

          // Followers count
          BSAnimatedContainer(
            key: ValueKey('followers-${user.followers.length}'),
            animationType: BSAnimationType.fadeScale,
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: () {
                if (onFollowersPressed != null) {
                  onFollowersPressed!();
                } else {
                  context.go('/profile/${user.uid}/followers');
                }
              },
              child: _buildStatColumn(
                  'Followers', user.followers.length.toString()),
            ),
          ),

          // Following count
          BSAnimatedContainer(
            key: ValueKey('following-${user.following.length}'),
            animationType: BSAnimationType.fadeScale,
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 400),
            child: GestureDetector(
              onTap: () {
                if (onFollowingPressed != null) {
                  onFollowingPressed!();
                } else {
                  context.go('/profile/${user.uid}/following');
                }
              },
              child: _buildStatColumn(
                  'Following', user.following.length.toString()),
            ),
          ),
        ],
      );

  Widget _buildStatColumn(String title, String count) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              if (title == 'Followers' || title == 'Following')
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey,
                ),
            ],
          ),
        ],
      );
}
