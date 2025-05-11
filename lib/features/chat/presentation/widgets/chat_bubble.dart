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
    this.onTapImage,
    super.key,
  });

  /// Message to display
  final Message message;

  /// Whether the message was sent by the current user
  final bool isMe;

  /// Callback when the bubble is long-pressed
  final VoidCallback? onLongPress;

  /// Callback when an image in the message is tapped
  final Function(String)? onTapImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Format the message time
    final timeString = DateFormat.jm().format(message.timestamp);

    // Determine if the message contains an image URL
    // This is a simple check - in a real app, you'd have a more robust way to identify media
    final hasImage = message.content.startsWith('http') &&
        (message.content.contains('.jpg') ||
            message.content.contains('.jpeg') ||
            message.content.contains('.png') ||
            message.content.contains('.gif') ||
            message.content.contains('picsum.photos'));

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
          padding:
              hasImage ? const EdgeInsets.all(4) : UiConstants.paddingH16V8,
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
                color: Colors.black.withAlpha(13),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage) ...[
                // Image content
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(UiConstants.borderRadiusSmall),
                  child: GestureDetector(
                    onTap: () => onTapImage?.call(message.content),
                    child: Image.network(
                      message.content,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: isMe
                                  ? Colors.white
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 200,
                        height: 100,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.error_outline, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Text content
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : theme.colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ],
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
                    _buildMessageStatusIcon(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the message status icon based on message state
  Widget _buildMessageStatusIcon() {
    // Determine the icon and color based on message status
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.white.withAlpha(180);
        break;
      case MessageStatus.sent:
        icon = Icons.done;
        color = Colors.white.withAlpha(180);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white.withAlpha(180);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue.shade300;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red.shade300;
        break;
    }

    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }
}
