import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../blocs/chat_bloc.dart';
import '../widgets/chat_bubble.dart';

/// Page that displays a chat conversation
class ChatPage extends StatefulWidget {
  /// Constructor
  const ChatPage({
    required this.roomId,
    super.key,
  });

  /// Chat room ID
  final String roomId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load messages when the page is first loaded
    context.read<ChatBloc>().add(LoadMessagesEvent(roomId: widget.roomId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Send a message
  void _sendMessage() {
    if (_messageController.text.isEmpty) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final chatState = context.read<ChatBloc>().state;

    if (authState is Authenticated && chatState is MessagesLoaded) {
      final currentUser = authState.user;
      final chatRoom = chatState.chatRoom;

      // Find the receiver ID (the other participant)
      final receiverId = chatRoom.participants
          .firstWhere((id) => id != currentUser.uid, orElse: () => '');

      if (receiverId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Could not determine message recipient'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<ChatBloc>().add(
            SendMessageEvent(
              roomId: widget.roomId,
              senderId: currentUser.uid,
              receiverId: receiverId,
              content: _messageController.text,
            ),
          );

      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to send messages'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Mark messages as read
  void _markMessagesAsRead() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ChatBloc>().add(
            MarkMessagesAsReadEvent(
              roomId: widget.roomId,
              userId: authState.user.uid,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is MessagesLoaded) {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  // Find the other participant's ID
                  final otherUserId = state.chatRoom.participants.firstWhere(
                    (id) => id != authState.user.uid,
                    orElse: () => 'Unknown',
                  );
                  return Text(otherUserId);
                }
                return const Text('Chat');
              }
              return const Text('Chat');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // TODO: Show chat info
              },
            ),
          ],
        ),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is MessageSending) {
              setState(() {
                _isLoading = true;
              });
            } else {
              setState(() {
                _isLoading = false;
              });
            }

            if (state is MessagesLoaded) {
              // Mark messages as read when they are loaded
              _markMessagesAsRead();
            } else if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is MessagesLoaded) {
              final authState = context.read<AuthBloc>().state;
              final currentUserId =
                  authState is Authenticated ? authState.user.uid : null;

              return Column(
                children: [
                  Expanded(
                    child: state.messages.isEmpty
                        ? const Center(
                            child:
                                Text('No messages yet. Start a conversation!'),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final isMe = message.senderId == currentUserId;

                              return ChatBubble(
                                message: message,
                                isMe: isMe,
                                onLongPress: isMe
                                    ? () {
                                        // Show delete option for own messages
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Message'),
                                            content: const Text(
                                                'Are you sure you want to '
                                                'delete this message?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  context.read<ChatBloc>().add(
                                                        DeleteMessageEvent(
                                                          messageId:
                                                              message.messageId,
                                                          roomId: widget.roomId,
                                                        ),
                                                      );
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    : null,
                              );
                            },
                          ),
                  ),
                  // Message input
                  Container(
                    padding: UiConstants.paddingAll8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.05 * 255).round()),
                          blurRadius: 5,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: () {
                            // TODO: Implement file attachment
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    UiConstants.borderRadiusMedium),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight,
                              contentPadding: UiConstants.paddingH16V8,
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          onPressed: _isLoading ? null : _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is ChatError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ChatBloc>()
                            .add(LoadMessagesEvent(roomId: widget.roomId));
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chat Page - To be implemented'),
                    const SizedBox(height: 8),
                    Text('Room ID: ${widget.roomId}'),
                  ],
                ),
              );
            }
          },
        ),
      );
}
