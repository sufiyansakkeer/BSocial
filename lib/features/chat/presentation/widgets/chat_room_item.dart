import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../domain/entities/chat_room.dart';
import 'chat_user_info.dart';

/// Widget that displays a chat room item in a list
class ChatRoomItem extends StatelessWidget {
  /// Constructor
  const ChatRoomItem({
    required this.chatRoom,
    required this.onTap,
    this.hasUnreadMessages = false,
    super.key,
  });

  /// Chat room to display
  final ChatRoom chatRoom;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  /// Whether the chat room has unread messages
  final bool hasUnreadMessages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        authState is Authenticated ? authState.user.uid : null;

    // Find the other participant's ID
    final otherUserId = currentUserId != null
        ? chatRoom.participants.firstWhere(
            (id) => id != currentUserId,
            orElse: () => 'Unknown',
          )
        : 'Unknown';

    // Format the last message time
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      chatRoom.lastMessageTime.year,
      chatRoom.lastMessageTime.month,
      chatRoom.lastMessageTime.day,
    );

    final timeString = messageDate == today
        ? DateFormat.jm().format(chatRoom.lastMessageTime)
        : messageDate.difference(today).inDays == -1
            ? 'Yesterday'
            : DateFormat.MMMd().format(chatRoom.lastMessageTime);

    // Check if the last message was sent by the current user
    final isLastMessageFromMe = chatRoom.lastMessageSenderId == currentUserId;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: UiConstants.paddingH16V12,
        child: Row(
          children: [
            // User avatar
            ChatUserInfo(
              userId: otherUserId,
              showName: false,
            ),
            UiConstants.kWidth12,
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name
                  ChatUserInfo(
                    userId: otherUserId,
                    showAvatar: false,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  UiConstants.kHeight4,
                  Row(
                    children: [
                      if (isLastMessageFromMe)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            'You: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chatRoom.lastMessage,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withAlpha(179), // 0.7 * 255 = 179
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            UiConstants.kWidth8,
            // Time and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeString,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface
                        .withAlpha(153), // 0.6 * 255 = 153
                    fontSize: 12,
                  ),
                ),
                UiConstants.kHeight4,
                if (hasUnreadMessages)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
