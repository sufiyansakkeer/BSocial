import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/post/presentation/blocs/post_bloc.dart';

/// Widget that displays profile statistics
class ProfileStats extends StatelessWidget {
  /// Constructor
  const ProfileStats({
    required this.user,
    super.key,
  });

  /// User
  final User user;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Posts count
          BlocBuilder<PostBloc, PostState>(
            builder: (context, state) {
              var postCount = '0';
              if (state is UserPostsLoaded) {
                postCount = state.posts.length.toString();
              } else if (state is PostLoading) {
                postCount = '-';
              }
              return _buildStatColumn('Posts', postCount);
            },
          ),

          // Followers count
          _buildStatColumn('Followers', user.followers.length.toString()),

          // Following count
          _buildStatColumn('Following', user.following.length.toString()),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      );
}
