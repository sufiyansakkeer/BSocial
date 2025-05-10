import 'package:bsocial/domain/entities/user.dart'; // Use package import for canonical User
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/user_bloc.dart';

/// Profile header widget
class ProfileHeader extends StatelessWidget {
  /// Constructor
  const ProfileHeader({
    required this.user,
    required this.isCurrentUser,
    super.key,
  });

  /// User
  final User user;

  /// Whether this is the current user's profile
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.photoUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${user.status}',
                        style: TextStyle(
                          color: user.status == 'online'
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // if (user.bio.isNotEmpty) // Canonical User does not have bio
            //   Text(
            //     user.bio,
            //     style: const TextStyle(fontSize: 16),
            //   ),
            // const SizedBox(height: 16),
            if (!isCurrentUser) _buildFollowButton(context),
          ],
        ),
      );

  Widget _buildFollowButton(BuildContext context) {
    final userBloc = context.read<UserBloc>();
    final isFollowing = user.followers.contains(
      // This should be the current user's ID
      // For now, we'll use a placeholder
      'currentUserId',
    );

    return ElevatedButton(
      onPressed: () {
        if (isFollowing) {
          userBloc.add(UnfollowUserEvent(userId: user.uid));
        } else {
          userBloc.add(FollowUserEvent(userId: user.uid));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.grey : Colors.blue,
        minimumSize: const Size(double.infinity, 36),
      ),
      child: Text(
        isFollowing ? 'Unfollow' : 'Follow',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
