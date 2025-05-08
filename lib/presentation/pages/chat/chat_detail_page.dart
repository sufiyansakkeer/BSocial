import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/ui_constants.dart';
import '../../../domain/entities/chat_room.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/chat/chat_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/skeleton_loading.dart';
import '../profile/profile_page.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatRoom chatRoom;
  final User? otherUser;

  const ChatDetailPage({
    super.key,
    required this.chatRoom,
    this.otherUser,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.getMessages(widget.chatRoom.roomId);
  }

  Future<void> _markMessagesAsRead() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await chatProvider.markMessagesAsRead(
        widget.chatRoom.roomId,
        authProvider.currentUser!.uid,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      if (authProvider.currentUser == null) {
        SnackbarUtils.showSnackBar(
          'You must be logged in to send messages',
          context,
          type: SnackBarType.error,
        );
        return;
      }

      // Get the other participant's ID (not the current user)
      final currentUserId = authProvider.currentUser!.uid;
      final otherUserId = widget.chatRoom.participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isEmpty) {
        SnackbarUtils.showSnackBar(
          'Cannot determine message recipient',
          context,
          type: SnackBarType.error,
        );
        return;
      }

      final success = await chatProvider.sendMessage(
        roomId: widget.chatRoom.roomId,
        senderId: currentUserId,
        receiverId: otherUserId,
        content: message,
      );

      if (success) {
        _messageController.clear();
        // Scroll to the bottom after a short delay to allow the list to update
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        SnackbarUtils.showSnackBar(
          'Failed to send message',
          context,
          type: SnackBarType.error,
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            if (widget.otherUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userId: widget.otherUser!.uid,
                    isCurrentUser: false,
                  ),
                ),
              );
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryColor,
                backgroundImage: widget.otherUser != null
                    ? NetworkImage(widget.otherUser!.photoUrl)
                    : null,
                child: widget.otherUser == null
                    ? const Icon(Icons.person, color: Colors.white, size: 16)
                    : null,
              ),
              UiConstants.kWidth,
              Text(widget.otherUser?.userName ?? 'Unknown User'),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show chat info or options
              SnackbarUtils.showSnackBar(
                'Chat info coming soon',
                context,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.status == ChatStatus.loading) {
                  return _buildLoadingState();
                }

                if (chatProvider.status == ChatStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${chatProvider.errorMessage}'),
                        UiConstants.kHeight20,
                        ElevatedButton(
                          onPressed: _loadMessages,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (chatProvider.messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start a conversation!'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: UiConstants.paddingAll16,
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return _buildMessageItem(context, message);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: UiConstants.paddingAll16,
      itemCount: 5,
      itemBuilder: (context, index) {
        // Alternate between sent and received message skeletons
        return index % 2 == 0
            ? const MessageSentSkeleton()
            : const MessageReceivedSkeleton();
      },
    );
  }

  Widget _buildMessageItem(BuildContext context, Message message) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final isSentByMe = message.senderId == currentUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryColor,
              backgroundImage: widget.otherUser != null
                  ? NetworkImage(widget.otherUser!.photoUrl)
                  : null,
              child: widget.otherUser == null
                  ? const Icon(Icons.person, color: Colors.white, size: 16)
                  : null,
            ),
            UiConstants.kWidth,
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? AppColors.primaryColor
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isSentByMe
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  UiConstants.kHeight4,
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSentByMe
                          ? Colors.white.withOpacity(0.7)
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSentByMe) ...[
            UiConstants.kWidth,
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 16,
              color: message.isRead
                  ? AppColors.primaryColor
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () {
              // Add image functionality (future enhancement)
              SnackbarUtils.showSnackBar(
                'Image sharing coming soon',
                context,
              );
            },
          ),
          Expanded(
            child: CustomTextField(
              controller: _messageController,
              hintText: 'Type a message...',
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send),
            onPressed: _isSubmitting
                ? null
                : () {
                    // Add haptic feedback
                    HapticFeedback.mediumImpact();
                    _sendMessage();
                  },
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today, show time
      return DateFormat.jm().format(dateTime);
    } else if (messageDate == yesterday) {
      // Yesterday
      return 'Yesterday ${DateFormat.jm().format(dateTime)}';
    } else {
      // Other days, show date and time
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}

class MessageSentSkeleton extends StatelessWidget {
  const MessageSentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SkeletonLoading(
          width: 200,
          height: 60,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class MessageReceivedSkeleton extends StatelessWidget {
  const MessageReceivedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const SkeletonLoading(
              width: 32,
              height: 32,
              isCircle: true,
            ),
            UiConstants.kWidth,
            SkeletonLoading(
              width: 180,
              height: 60,
              borderRadius: BorderRadius.circular(18),
            ),
          ],
        ),
      ),
    );
  }
}
