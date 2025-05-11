import 'package:flutter/material.dart';

import '../../../../core/utils/ui_constants.dart';
import '../../../../features/auth/domain/entities/user.dart';

/// Widget that displays profile action buttons (follow/unfollow, message, edit profile)
class ProfileActions extends StatelessWidget {
  /// Constructor
  const ProfileActions({
    required this.user,
    this.isCurrentUser = false,
    this.currentUserId = '',
    this.onFollowTap,
    this.onUnfollowTap,
    this.onMessageTap,
    this.onEditProfileTap,
    super.key,
  });

  /// User
  final User user;

  /// Whether this is the current user's profile
  final bool isCurrentUser;

  /// Current user ID
  final String currentUserId;

  /// Callback when follow button is tapped
  final VoidCallback? onFollowTap;

  /// Callback when unfollow button is tapped
  final VoidCallback? onUnfollowTap;

  /// Callback when message button is tapped
  final VoidCallback? onMessageTap;

  /// Callback when edit profile button is tapped
  final VoidCallback? onEditProfileTap;

  @override
  Widget build(BuildContext context) {
    // If it's the current user's profile, show edit profile button
    if (isCurrentUser) {
      return _buildEditProfileButton(context);
    }

    // Otherwise, show follow/unfollow and message buttons
    return _buildOtherUserActions(context);
  }

  /// Build edit profile button for current user
  Widget _buildEditProfileButton(BuildContext context) => ElevatedButton(
        onPressed: onEditProfileTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 16),
            SizedBox(width: 4),
            Text('Edit Profile'),
          ],
        ),
      );

  /// Build actions for other users' profiles
  Widget _buildOtherUserActions(BuildContext context) {
    // Check if current user is following this profile
    final isFollowing = user.followers.contains(currentUserId);

    // Use a key to force rebuild when follow status changes
    return Row(
      key: ValueKey('follow-status-$isFollowing'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Follow/Unfollow button
        Expanded(
          child: ElevatedButton(
            onPressed: isFollowing ? onUnfollowTap : onFollowTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing
                  ? Colors.grey[300]
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: isFollowing ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFollowing ? Icons.person_remove : Icons.person_add,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(isFollowing ? 'Unfollow' : 'Follow'),
              ],
            ),
          ),
        ),

        UiConstants.kWidth8,

        // Message button
        Expanded(
          child: OutlinedButton(
            onPressed: onMessageTap,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message, size: 16),
                SizedBox(width: 4),
                Text('Message'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
