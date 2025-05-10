import 'package:flutter/material.dart';

import '../../../../core/utils/ui_constants.dart';
import '../../../../features/auth/domain/entities/user.dart';

/// Widget that displays a user search result item
class UserSearchItem extends StatelessWidget {
  /// Constructor
  const UserSearchItem({
    required this.user,
    required this.onTap,
    super.key,
  });

  /// User
  final User user;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.photoUrl),
        ),
        title: Text(user.userName),
        subtitle: Text(user.email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        contentPadding: UiConstants.paddingH16V8,
        onTap: onTap,
      );
}
