import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/user/presentation/blocs/user_bloc.dart';

/// A widget that displays user information (name, avatar) based on a user ID
/// This widget handles fetching the user data and caching it
class ChatUserInfo extends StatefulWidget {
  /// Constructor
  const ChatUserInfo({
    required this.userId,
    this.textStyle,
    this.avatarRadius = 28,
    this.showAvatar = true,
    this.showName = true,
    this.nameMaxLines = 1,
    super.key,
  });

  /// The user ID to fetch information for
  final String userId;

  /// Style for the user name text
  final TextStyle? textStyle;

  /// Radius of the avatar
  final double avatarRadius;

  /// Whether to show the avatar
  final bool showAvatar;

  /// Whether to show the name
  final bool showName;

  /// Maximum number of lines for the name
  final int nameMaxLines;

  @override
  State<ChatUserInfo> createState() => _ChatUserInfoState();
}

class _ChatUserInfoState extends State<ChatUserInfo> {
  // Cache of user data to avoid repeated fetches
  static final Map<String, Map<String, dynamic>> _userCache = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void didUpdateWidget(ChatUserInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _fetchUserData();
    }
  }

  void _fetchUserData() {
    // Check if we already have this user's data in the cache
    if (!_userCache.containsKey(widget.userId)) {
      // Initialize cache entry with default values
      _userCache[widget.userId] = {
        'name': widget.userId.substring(0, min(widget.userId.length, 8)),
        'photoUrl': '',
        'loading': true,
      };

      // Fetch user data
      context.read<UserBloc>().add(GetUserByIdEvent(userId: widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = theme.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.bold,
    );

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded && state.user.uid == widget.userId) {
          // Update cache with fetched user data
          _userCache[widget.userId] = {
            'name': state.user.userName,
            'photoUrl': state.user.photoUrl,
            'loading': false,
          };
          // Force rebuild with new data
          if (mounted) setState(() {});
        }
      },
      child: Row(
        children: [
          if (widget.showAvatar) ...[
            _buildAvatar(theme),
            const SizedBox(width: 12),
          ],
          if (widget.showName)
            Expanded(
              child: Text(
                _userCache[widget.userId]?['name'] ?? 'Loading...',
                style: widget.textStyle ?? defaultTextStyle,
                maxLines: widget.nameMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final isLoading = _userCache[widget.userId]?['loading'] ?? true;
    final photoUrl = _userCache[widget.userId]?['photoUrl'] as String? ?? '';
    final name = _userCache[widget.userId]?['name'] as String? ?? '';

    if (isLoading) {
      return CircleAvatar(
        radius: widget.avatarRadius,
        backgroundColor:
            theme.colorScheme.primary.withAlpha(51), // 0.2 * 255 = 51
        child: SizedBox(
          width: widget.avatarRadius,
          height: widget.avatarRadius,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: widget.avatarRadius,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: theme.colorScheme.primary,
      );
    }

    return CircleAvatar(
      radius: widget.avatarRadius,
      backgroundColor: theme.colorScheme.primary,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: widget.avatarRadius * 0.7,
        ),
      ),
    );
  }
}

// Helper function to get minimum of two integers
int min(int a, int b) => a < b ? a : b;
