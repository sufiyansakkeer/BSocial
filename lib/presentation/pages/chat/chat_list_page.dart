import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/ui_constants.dart';
import '../../../domain/entities/chat_room.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/chat/chat_provider.dart';
import '../../widgets/common/skeleton_loading.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await chatProvider.getChatRooms(authProvider.currentUser!.uid);
    }
  }

  // Extract and open the Firestore index URL from the error message
  Future<void> _openFirestoreIndexUrl(String errorMessage) async {
    final urlMatch = RegExp(r'https://console\.firebase\.google\.com[^\s"]+')
        .firstMatch(errorMessage);
    if (urlMatch != null) {
      final url = urlMatch.group(0) ?? '';
      if (url.isNotEmpty) {
        try {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              SnackbarUtils.showSnackBar(
                'Could not open URL: $url',
                context,
                type: SnackBarType.error,
              );
            }
          }
        } catch (e) {
          if (mounted) {
            SnackbarUtils.showSnackBar(
              'Error opening URL: $e',
              context,
              type: SnackBarType.error,
            );
          }
        }
      }
    } else {
      if (mounted) {
        SnackbarUtils.showSnackBar(
          'No Firestore index URL found in the error message',
          context,
          type: SnackBarType.warning,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.status == ChatStatus.loading) {
            return _buildLoadingState();
          }

          if (chatProvider.status == ChatStatus.error) {
            final isIndexError = chatProvider.errorMessage.contains('index') ||
                chatProvider.errorMessage.contains('Firestore index');

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isIndexError ? Icons.build : Icons.error_outline,
                      color: isIndexError ? Colors.orange : Colors.red,
                      size: 48,
                    ),
                    UiConstants.kHeight20,
                    Text(
                      isIndexError ? 'Firestore Index Required' : 'Error',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    UiConstants.kHeight,
                    Text(
                      chatProvider.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (isIndexError) ...[
                      UiConstants.kHeight20,
                      const Text(
                        'This is a one-time setup. After creating the index, it may take a few minutes to become active.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    UiConstants.kHeight20,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Check if the error message contains a URL
                        if (RegExp(r'https://console\.firebase\.google\.com')
                            .hasMatch(chatProvider.errorMessage)) ...[
                          ElevatedButton.icon(
                            onPressed: () => _openFirestoreIndexUrl(
                                chatProvider.errorMessage),
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Open Index URL'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          UiConstants.kWidth16,
                        ],
                        ElevatedButton(
                          onPressed: _loadChatRooms,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          if (chatProvider.chatRooms.isEmpty) {
            return const Center(
              child: Text('No messages yet. Start a conversation!'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadChatRooms,
            child: ListView.builder(
              itemCount: chatProvider.chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatProvider.chatRooms[index];
                return _buildChatRoomItem(context, chatRoom, chatProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const ChatRoomItemSkeleton();
      },
    );
  }

  Widget _buildChatRoomItem(
    BuildContext context,
    ChatRoom chatRoom,
    ChatProvider chatProvider,
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid ?? '';

    // Get the other participant's ID (not the current user)
    final otherUserId = chatRoom.participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    // Get the other user's data
    final otherUser = chatProvider.chatUsers[otherUserId];

    // Format the last message time
    final lastMessageTime = _formatLastMessageTime(chatRoom.lastMessageTime);

    // Check if the last message was sent by the current user
    final isLastMessageFromCurrentUser =
        chatRoom.lastMessageSenderId == currentUserId;

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primaryColor,
        backgroundImage:
            otherUser != null ? NetworkImage(otherUser.photoUrl) : null,
        child: otherUser == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(
        otherUser?.userName ?? 'Unknown User',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: [
          if (isLastMessageFromCurrentUser)
            const Text(
              'You: ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          Expanded(
            child: Text(
              chatRoom.lastMessage.isEmpty
                  ? 'Start a conversation'
                  : chatRoom.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            lastMessageTime,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          UiConstants.kHeight4,
          // Here you could add an unread message indicator
        ],
      ),
      onTap: () {
        // Navigate to chat detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              chatRoom: chatRoom,
              otherUser: otherUser,
            ),
          ),
        ).then((_) => _loadChatRooms());
      },
    );
  }

  String _formatLastMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today, show time
      return DateFormat.jm().format(dateTime);
    } else if (messageDate == yesterday) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      // Within the last week, show day name
      return DateFormat.E().format(dateTime);
    } else {
      // Older, show date
      return DateFormat.MMMd().format(dateTime);
    }
  }
}

class ChatRoomItemSkeleton extends StatelessWidget {
  const ChatRoomItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const SkeletonLoading(
        width: 48,
        height: 48,
        isCircle: true,
      ),
      title: const SkeletonLoading(
        width: 120,
        height: 16,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            const SkeletonLoading(
              width: 150,
              height: 12,
            ),
            const Spacer(),
            SkeletonLoading(
              width: 40,
              height: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
