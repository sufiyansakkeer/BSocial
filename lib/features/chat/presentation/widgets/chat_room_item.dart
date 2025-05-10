import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/ui_constants.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../domain/entities/chat_room.dart';

/// Widget that displays a chat room item in a list
class ChatRoomItem extends StatelessWidget {
  /// Constructor
  const ChatRoomItem({
    required this.chatRoom,
    required this.onTap,
    super.key,
  });

  /// Chat room to display
  final ChatRoom chatRoom;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.uid : null;

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
    final isLastMessageFromMe =
        chatRoom.lastMessageSenderId == currentUserId;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: UiConstants.paddingH16V12,
        child: Row(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                otherUserId.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            UiConstants.kWidth12,
            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  UiConstants.kHeight4,
                  Row(
                    children: [
                      if (isLastMessageFromMe)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Text(
                            'You: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chatRoom.lastMessage,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withAlpha(180),
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
                    color: theme.colorScheme.onSurface.withAlpha(150),
                    fontSize: 12,
                  ),
                ),
                UiConstants.kHeight4,
                // TODO: Add unread message indicator
              ],
            ),
          ],
        ),
      ),
    );
  }
}
