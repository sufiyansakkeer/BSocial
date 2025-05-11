import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../data/datasources/remote/message_stream.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';
import '../blocs/chat_bloc.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_message_skeleton_loader.dart';
import '../widgets/chat_user_info.dart';

/// A chat page that uses a stream to get real-time updates
class StreamingChatPage extends StatefulWidget {
  /// Constructor
  const StreamingChatPage({
    required this.roomId,
    super.key,
  });

  /// Chat room ID
  final String roomId;

  @override
  State<StreamingChatPage> createState() => _StreamingChatPageState();
}

class _StreamingChatPageState extends State<StreamingChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final MessageStream _messageStream;
  StreamSubscription<List<Message>>? _messagesSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ChatRoom? _chatRoom;
  List<Message> _messages = [];
  final List<Message> _pendingMessages = [];
  bool _isLoading = false;
  bool _isLoadingMessages = true;
  bool _isConnected = true;
  String? _otherUserId;
  String? _currentUserId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _messageStream = MessageStream(
      firestore: FirebaseFirestore.instance,
    );

    // Get the current user ID
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.uid;
    }

    // Check connectivity
    _checkConnectivity();

    // Subscribe to connectivity changes
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);

    // Load the chat room
    _loadChatRoom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } on Exception catch (e) {
      setState(() {
        _isConnected = false;
        _errorMessage = 'Unable to check network connectivity: $e';
      });
    }
  }

  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isConnected = result != ConnectivityResult.none;
      if (!_isConnected) {
        _errorMessage = 'No internet connection';
      } else {
        _errorMessage = null;
      }
    });
  }

  /// Load the chat room and start listening for messages
  void _loadChatRoom() {
    if (!_isConnected) {
      setState(() {
        _errorMessage = 'No internet connection. '
            'Please check your connection and try again.';
      });
      return;
    }

    final currentState = context.read<ChatBloc>().state;

    if (currentState is ChatRoomLoaded &&
        currentState.chatRoom.roomId == widget.roomId) {
      // If we already have the chat room loaded, use it
      _chatRoom = currentState.chatRoom;
      _setupMessageStream();
      _findOtherUser();
    } else {
      // Otherwise, load the chat room
      context.read<ChatBloc>().add(GetChatRoomByIdEvent(roomId: widget.roomId));

      // Listen for the chat room to be loaded
      context.read<ChatBloc>().stream.listen((state) {
        if (!mounted) {
          return;
        }

        if (state is ChatRoomLoaded && state.chatRoom.roomId == widget.roomId) {
          setState(() {
            _chatRoom = state.chatRoom;
            _errorMessage = null;
          });
          _setupMessageStream();
          _findOtherUser();
        } else if (state is ChatError) {
          setState(() {
            _errorMessage = 'Failed to load chat room: ${state.message}';
          });
        }
      });

      // Set a timeout to handle cases where the chat room doesn't load
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _chatRoom == null && _errorMessage == null) {
          setState(() {
            _errorMessage = 'Failed to load chat room. Please try again.';
          });
        }
      });
    }
  }

  /// Find the other user in the chat room
  void _findOtherUser() {
    if (_chatRoom != null && _currentUserId != null) {
      setState(() {
        _otherUserId = _chatRoom!.participants.firstWhere(
          (id) => id != _currentUserId,
          orElse: () => 'Unknown',
        );
      });
    }
  }

  /// Setup the message stream
  void _setupMessageStream() {
    setState(() {
      _isLoadingMessages = true;
    });

    try {
      // Start listening for messages
      _messagesSubscription =
          _messageStream.getMessageStream(widget.roomId).listen(
        (messages) {
          setState(() {
            _messages = messages;
            _isLoadingMessages = false;
            _errorMessage = null;

            // Remove pending messages that have been sent
            _pendingMessages.removeWhere((pendingMsg) => _messages.any((msg) =>
                msg.content == pendingMsg.content &&
                msg.senderId == pendingMsg.senderId));
          });

          // Mark messages as read
          _markMessagesAsRead();
        },
        onError: (error) {
          setState(() {
            _isLoadingMessages = false;
            _errorMessage = 'Failed to load messages: $error';
          });
        },
      );
    } on Exception catch (e) {
      setState(() {
        _isLoadingMessages = false;
        _errorMessage = 'Failed to setup message stream: $e';
      });
    }
  }

  /// Mark messages as read
  void _markMessagesAsRead() {
    if (_currentUserId != null) {
      _messageStream.markMessagesAsRead(widget.roomId, _currentUserId!);
    }
  }

  /// Send a message
  Future<void> _sendMessage({String? content}) async {
    // Check connectivity first
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('No internet connection. Message saved as draft.'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              _checkConnectivity();
              if (_isConnected) {
                _sendMessage(content: content);
              }
            },
          ),
        ),
      );
      return;
    }

    // Use provided content or text from the controller
    final messageContent = content ?? _messageController.text;

    // Don't send empty messages
    if (messageContent.isEmpty) {
      return;
    }

    // Only proceed if we have the necessary information
    if (_currentUserId == null || _otherUserId == null || _chatRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot send message at this time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create a pending message for optimistic UI update
    final pendingMessage = Message(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId!,
      receiverId: _otherUserId!,
      content: messageContent,
      timestamp: DateTime.now(),
      isRead: false,
      roomId: widget.roomId,
      status: MessageStatus.sending,
    );

    // Add to pending messages for optimistic UI update
    setState(() {
      _pendingMessages.add(pendingMessage);
      _isLoading = true;
    });

    // Clear the text controller if we're sending a text message
    if (content == null) {
      _messageController.clear();
    }

    try {
      // Send the message
      await _messageStream.sendMessage(
        roomId: widget.roomId,
        senderId: _currentUserId!,
        receiverId: _otherUserId!,
        content: messageContent,
      );

      // Message sent successfully
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      // Message failed to send
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        // Update the pending message status to failed
        final index = _pendingMessages.indexOf(pendingMessage);
        if (index != -1) {
          _pendingMessages[index] = pendingMessage.copyWith(
            status: MessageStatus.failed,
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                if (mounted) {
                  _sendMessage(content: messageContent);
                }
              },
            ),
          ),
        );
      }
    }
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

  /// Delete a message
  void _deleteMessage(Message message) {
    _messageStream.deleteMessage(message.messageId, widget.roomId);
  }

  /// Get all messages including pending ones
  List<Message> get _allMessages => [..._messages, ..._pendingMessages]
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  /// Build the messages list with appropriate states
  Widget _buildMessagesList(ThemeData theme) {
    // If we have an error message, show it
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withAlpha(180),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (!_isConnected) {
                  _checkConnectivity();
                } else {
                  _setupMessageStream();
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    // If chat room is null, we're still loading the chat room
    if (_chatRoom == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // If we're loading messages, show skeleton loader
    if (_isLoadingMessages) {
      return const ChatMessageSkeletonLoader();
    }

    // If there are no messages, show empty state
    if (_allMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.primary.withAlpha(128),
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
      );
    }

    // Show the messages list
    return ListView.builder(
      controller: _scrollController,
      reverse: true, // To show latest messages at the bottom
      itemCount: _allMessages.length,
      itemBuilder: (context, index) {
        final message = _allMessages[index];
        final isMe = message.senderId == _currentUserId;

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
                      content: const Text('Are you sure you want to '
                          'delete this message?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _deleteMessage(message);
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              : null,
        );
      },
    );
  }

  /// Pick an image from the gallery
  void _pickImage() {
    // This would use image_picker package in a real implementation
    if (!mounted) {
      return;
    }

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
      if (mounted) {
        _sendMessage(content: imageUrl);
      }
    });
  }

  /// Take a photo with the camera
  void _takePhoto() {
    // This would use image_picker package in a real implementation
    if (!mounted) {
      return;
    }

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
    if (!mounted) {
      return;
    }

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
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location sharing would happen here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _otherUserId != null
            ? ChatUserInfo(
                userId: _otherUserId!,
                showAvatar: false,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show chat info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _buildMessagesList(theme),
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
                      fillColor: Theme.of(context).brightness == Brightness.dark
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
      ),
    );
  }
}
