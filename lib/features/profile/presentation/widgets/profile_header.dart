import 'package:flutter/material.dart';

import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../features/auth/domain/entities/user.dart';

/// Widget that displays the profile header
class ProfileHeader extends StatelessWidget {
  /// Constructor
  const ProfileHeader({
    required this.user,
    super.key,
  });

  /// User
  final User user;

  @override
  Widget build(BuildContext context) => Padding(
        padding: UiConstants.paddingAll16,
        child: Column(
          children: [
            // Profile image with safe loading
            ImageWidgetExtensions.safeCircleAvatar(
              imageUrl: user.photoUrl,
              radius: 50,
            ),
            UiConstants.kHeight16,

            // Username
            Text(
              user.userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            UiConstants.kHeight8,

            // Email
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
              ),
            ),
            UiConstants.kHeight16,

            // Bio
            if (user.bio.isNotEmpty)
              Text(
                user.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      );
}
