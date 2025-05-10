import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../blocs/chat_bloc.dart';
import '../widgets/chat_room_item.dart';

/// Page that displays a list of chat rooms
class ChatListPage extends StatefulWidget {
  /// Constructor
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

  void _loadChatRooms() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<ChatBloc>()
          .add(LoadChatRoomsEvent(userId: authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search functionality
              },
            ),
          ],
        ),
        body: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is ChatRoomsLoaded) {
              if (state.chatRooms.isEmpty) {
                return const Center(
                  child: Text('No chats yet. Start a conversation!'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _loadChatRooms();
                },
                child: ListView.builder(
                  itemCount: state.chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = state.chatRooms[index];
                    return ChatRoomItem(
                      chatRoom: chatRoom,
                      onTap: () {
                        context.read<ChatBloc>().add(
                              SetSelectedChatRoomEvent(chatRoom: chatRoom),
                            );
                        context.go('/chats/${chatRoom.roomId}');
                      },
                    );
                  },
                ),
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
                      onPressed: _loadChatRooms,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('Chat List Page - To be implemented'),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to new chat page
          },
          child: const Icon(Icons.chat),
        ),
      );
}
