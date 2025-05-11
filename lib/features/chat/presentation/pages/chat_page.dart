import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../blocs/chat_bloc.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_user_info.dart';

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
    // Check if we already have a loaded chat room
    final currentState = context.read<ChatBloc>().state;
    if (currentState is ChatRoomLoaded &&
        currentState.chatRoom.roomId == widget.roomId) {
      // If we already have the chat room loaded, just load the messages
      context.read<ChatBloc>().add(LoadMessagesEvent(roomId: widget.roomId));
    } else {
      // Otherwise, first get the chat room, then load messages
      context.read<ChatBloc>().add(GetChatRoomByIdEvent(roomId: widget.roomId));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Send a message
  void _sendMessage({String? content}) {
    // Use provided content or text from the controller
    final messageContent = content ?? _messageController.text;

    // Don't send empty messages
    if (messageContent.isEmpty) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    final chatState = context.read<ChatBloc>().state;

    if (authState is Authenticated) {
      final currentUser = authState.user;

      // Get the receiver ID based on the current state
      var receiverId = '';

      if (chatState is MessagesLoaded) {
        // If messages are loaded, get the receiver from the chat room
        final chatRoom = chatState.chatRoom;
        receiverId = chatRoom.participants
            .firstWhere((id) => id != currentUser.uid, orElse: () => '');
      } else if (chatState is ChatRoomLoaded) {
        // If only the chat room is loaded, get the receiver from there
        final chatRoom = chatState.chatRoom;
        receiverId = chatRoom.participants
            .firstWhere((id) => id != currentUser.uid, orElse: () => '');
      } else {
        // If neither is loaded, try to load messages first
        context.read<ChatBloc>().add(LoadMessagesEvent(roomId: widget.roomId));
        // Save the message to send after loading
        Future.delayed(const Duration(milliseconds: 500), () {
          _sendMessage(content: messageContent);
        });
        return;
      }

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
              content: messageContent,
            ),
          );

      // Only clear the text controller if we're sending a text message
      if (content == null) {
        _messageController.clear();
      }
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

  /// Pick an image from the gallery
  void _pickImage() {
    // This would use image_picker package in a real implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image picker would open here'),
        duration: Duration(seconds: 2),
      ),
    );

    // For demo purposes, let's simulate sending an image
    final imageUrl =
        'https://picsum.photos/500/300?random=${DateTime.now().millisecondsSinceEpoch}';

    // Show a loading indicator
    setState(() {
      _isLoading = true;
    });

    // Simulate a delay to mimic image upload
    Future.delayed(const Duration(seconds: 1), () {
      _sendMessage(content: imageUrl);
    });
  }

  /// Take a photo with the camera
  void _takePhoto() {
    // This would use image_picker package in a real implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera would open here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Pick a file from storage
  void _pickFile() {
    // This would use file_picker package in a real implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File picker would open here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Share current location
  void _shareLocation() {
    // This would use geolocator package in a real implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location sharing would happen here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Handle tapping on an image in a message
  void _onImageTap(String imageUrl) {
    // This would open a full-screen image viewer in a real implementation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image viewer would open for: $imageUrl'),
        duration: const Duration(seconds: 2),
      ),
    );
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
                  // Use ChatUserInfo to display the user's name
                  return ChatUserInfo(
                    userId: otherUserId,
                    showAvatar: false,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
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

            if (state is ChatRoomLoaded) {
              // When the chat room is loaded, load the messages
              context
                  .read<ChatBloc>()
                  .add(LoadMessagesEvent(roomId: widget.roomId));
            } else if (state is MessagesLoaded) {
              // Mark messages as read when they are loaded
              _markMessagesAsRead();
              // Scroll to the bottom when new messages are loaded
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            } else if (state is MessageSent) {
              // Reload messages to show the new message
              context
                  .read<ChatBloc>()
                  .add(LoadMessagesEvent(roomId: widget.roomId));
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
              final theme = Theme.of(context);

              // We'll use the AppBar title from the build method

              return Column(
                children: [
                  Expanded(
                    child: state.messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color:
                                      theme.colorScheme.primary.withAlpha(128),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Start typing to send a message!',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            reverse:
                                true, // To show latest messages at the bottom
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final isMe = message.senderId == currentUserId;

                              return ChatBubble(
                                message: message,
                                isMe: isMe,
                                onTapImage: _onImageTap,
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
                          color: Colors.black.withAlpha(13),
                          blurRadius: 5,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Attachment button with dropdown menu
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.add_circle_outline),
                          onSelected: (value) {
                            // Handle different attachment types
                            switch (value) {
                              case 'image':
                                _pickImage();
                                break;
                              case 'camera':
                                _takePhoto();
                                break;
                              case 'file':
                                _pickFile();
                                break;
                              case 'location':
                                _shareLocation();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'image',
                              child: Row(
                                children: [
                                  Icon(Icons.image),
                                  SizedBox(width: 8),
                                  Text('Gallery'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'camera',
                              child: Row(
                                children: [
                                  Icon(Icons.camera_alt),
                                  SizedBox(width: 8),
                                  Text('Camera'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'file',
                              child: Row(
                                children: [
                                  Icon(Icons.insert_drive_file),
                                  SizedBox(width: 8),
                                  Text('Document'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'location',
                              child: Row(
                                children: [
                                  Icon(Icons.location_on),
                                  SizedBox(width: 8),
                                  Text('Location'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Emoji button
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          onPressed: () {
                            // TODO: Implement emoji picker
                          },
                        ),
                        // Text input field
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
                            maxLines: 5,
                            minLines: 1,
                          ),
                        ),
                        // Voice message button
                        IconButton(
                          icon: const Icon(Icons.mic_none),
                          onPressed: () {
                            // TODO: Implement voice recording
                          },
                        ),
                        // Send button
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
              // Show loading indicator while waiting for messages
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading conversation...'),
                  ],
                ),
              );
            }
          },
        ),
      );
}
