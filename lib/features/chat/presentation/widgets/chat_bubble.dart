import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../domain/entities/message.dart';

/// Widget that displays a chat message bubble
class ChatBubble extends StatelessWidget {
  /// Constructor
  const ChatBubble({
    required this.message,
    required this.isMe,
    this.onLongPress,
    super.key,
  });

  /// Message to display
  final Message message;

  /// Whether the message was sent by the current user
  final bool isMe;

  /// Callback when the bubble is long-pressed
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Format the message time
    final timeString = DateFormat.jm().format(message.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: EdgeInsets.only(
            left: isMe ? 64 : 16,
            right: isMe ? 16 : 64,
            top: 4,
            bottom: 4,
          ),
          padding: UiConstants.paddingH16V8,
          decoration: BoxDecoration(
            color: isMe
                ? isDarkMode
                    ? AppColors.primaryDark
                    : AppColors.primary
                : isDarkMode
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(UiConstants.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withAlpha(13), // 0.05 * 255 = 12.75, rounded to 13
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              UiConstants.kHeight4,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeString,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withAlpha(180)
                          : theme.colorScheme.onSurface.withAlpha(150),
                      fontSize: 12,
                    ),
                  ),
                  if (isMe) ...[
                    UiConstants.kWidth4,
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead
                          ? Colors.white.withAlpha(220)
                          : Colors.white.withAlpha(180),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
