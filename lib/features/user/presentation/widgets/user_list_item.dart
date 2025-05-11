import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../auth/domain/entities/user.dart';
import '../blocs/user_bloc.dart';

/// Widget that displays a user item in a list
class UserListItem extends StatelessWidget {
  /// Constructor
  const UserListItem({
    required this.user,
    required this.onTap,
    this.showFollowButton = true,
    super.key,
  });

  /// User to display
  final User user;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  /// Whether to show the follow/unfollow button
  final bool showFollowButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        // Get current user ID from the state
        String? currentUserId;
        if (state is UserLoaded) {
          currentUserId = state.currentUserId;
        }

        // Determine if the current user is following this user
        final isFollowing = currentUserId != null && user.followers.contains(currentUserId);
        
        // Don't show follow button for the current user
        final isCurrentUser = currentUserId != null && user.uid == currentUserId;
        final shouldShowFollowButton = showFollowButton && !isCurrentUser;

        return ListTile(
          leading: ImageWidgetExtensions.safeCircleAvatar(
            imageUrl: user.photoUrl,
            radius: 24,
          ),
          title: Text(
            user.userName,
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            user.status,
            style: theme.textTheme.bodySmall,
          ),
          trailing: shouldShowFollowButton
              ? _buildFollowButton(context, isFollowing)
              : const Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: UiConstants.paddingH16V8,
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildFollowButton(BuildContext context, bool isFollowing) {
    return ElevatedButton(
      onPressed: () {
        if (isFollowing) {
          context.read<UserBloc>().add(UnfollowUserEvent(userId: user.uid));
        } else {
          context.read<UserBloc>().add(FollowUserEvent(userId: user.uid));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.grey[300] : Theme.of(context).colorScheme.primary,
        foregroundColor: isFollowing ? Colors.black : Colors.white,
        minimumSize: const Size(80, 36),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isFollowing ? 'Unfollow' : 'Follow',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
