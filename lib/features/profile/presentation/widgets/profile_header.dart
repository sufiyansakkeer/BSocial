import 'package:flutter/material.dart';

import '../../../../core/utils/ui_constants.dart';
import '../../../../core/widgets/animations/bs_animated_container.dart';
import '../../../../core/widgets/avatars/bs_avatar.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../widgets/profile_actions.dart';

/// Widget that displays the profile header
class ProfileHeader extends StatelessWidget {
  /// Constructor
  const ProfileHeader({
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
  Widget build(BuildContext context) => Padding(
        padding: UiConstants.paddingAll16,
        child: BSStaggeredList(
          itemAnimationType: BSAnimationType.fadeScale,
          itemDuration: const Duration(milliseconds: 400),
          staggerDuration: const Duration(milliseconds: 100),
          children: [
            // Profile image
            BSAvatar(
              imageUrl: user.photoUrl,
              size: BSAvatarSize.xxl,
              borderWidth: 2,
              borderColor: Theme.of(context).colorScheme.primary,
            ),
            UiConstants.kHeight16,

            // Username
            Text(
              user.userName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            UiConstants.kHeight8,

            // Email
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  ),
            ),
            UiConstants.kHeight16,

            // Bio
            if (user.bio.isNotEmpty)
              Text(
                user.bio,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

            UiConstants.kHeight16,

            // Profile actions (follow/unfollow, message, edit profile)
            ProfileActions(
              user: user,
              isCurrentUser: isCurrentUser,
              currentUserId: currentUserId,
              onFollowTap: onFollowTap,
              onUnfollowTap: onUnfollowTap,
              onMessageTap: onMessageTap,
              onEditProfileTap: onEditProfileTap,
            ),
          ],
        ),
      );
}
