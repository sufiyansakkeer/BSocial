import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/domain/entities/user.dart' as auth;
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../../../features/user/presentation/blocs/user_bloc.dart';
import '../../../../features/user/presentation/widgets/user_list_item.dart';
import '../blocs/chat_bloc.dart';

/// Page that displays a list of users the current user is following
/// to start a new chat with
class NewChatPage extends StatefulWidget {
  /// Constructor
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<auth.User> _recentContacts = [];

  @override
  void initState() {
    super.initState();
    _loadFollowingUsers();
    _searchController.addListener(_onSearchChanged);

    // In a real app, you would load recent contacts from a database
    // For now, we'll just use an empty list that will be populated later
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  /// Load the list of users the current user is following
  void _loadFollowingUsers() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<UserBloc>()
          .add(GetFollowingEvent(userId: authState.user.uid));
    }
  }

  /// Start a chat with the selected user
  void _startChat(String userId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final currentUserId = authState.user.uid;
      final participants = [currentUserId, userId];

      // First, check if a chat room already exists with these participants
      context.read<ChatBloc>().add(
            GetChatRoomByParticipantsEvent(
              participants: participants,
            ),
          );

      // Listen for chat room events and navigate to chat page
      context.read<ChatBloc>().stream.listen((state) {
        if (!mounted) {
          return;
        }

        if (state is ChatRoomLoaded) {
          // Chat room exists, navigate to it
          context.go('/chats/${state.chatRoom.roomId}');
        } else if (state is ChatRoomNotFound) {
          // Chat room doesn't exist, create a new one
          context.read<ChatBloc>().add(
                CreateChatRoomEvent(
                  participants: participants,
                ),
              );
        } else if (state is ChatRoomCreated) {
          // New chat room created, navigate to it
          context.go('/chats/${state.chatRoom.roomId}');
        } else if (state is ChatError) {
          // Error occurred
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  // Filter users based on search query
  List<auth.User> _filterUsers(List<auth.User> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }

    final query = _searchQuery.toLowerCase();
    return users
        .where((user) =>
            user.userName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _searchController.clear,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // User list
          Expanded(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FollowingLoaded) {
                  // Convert to auth.User list for consistency
                  final followingUsers = state.following
                      .map((user) => auth.User(
                            uid: user.uid,
                            email: user.email,
                            userName: user.userName,
                            photoUrl: user.photoUrl,
                            followers: user.followers,
                            following: user.following,
                            status: user.status,
                          ))
                      .toList();

                  // Add to recent contacts if not already there
                  // In a real app, you'd manage this differently
                  for (final user in followingUsers) {
                    if (!_recentContacts
                        .any((contact) => contact.uid == user.uid)) {
                      if (_recentContacts.length < 5) {
                        _recentContacts.add(user);
                      }
                    }
                  }

                  // Filter users based on search
                  final filteredUsers = _filterUsers(followingUsers);

                  if (state.following.isEmpty) {
                    return const Center(
                      child: Text('You are not following anyone yet.'),
                    );
                  }

                  if (filteredUsers.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: theme.colorScheme.primary.withAlpha(128),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results for "$_searchQuery"',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      // Recent contacts section
                      if (_recentContacts.isNotEmpty &&
                          _searchQuery.isEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            child: Text(
                              'Recent Contacts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final user = _recentContacts[index];
                              return UserListItem(
                                user: user,
                                showFollowButton: false,
                                onTap: () => _startChat(user.uid),
                              );
                            },
                            childCount: _recentContacts.length,
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: Divider(height: 32, indent: 16, endIndent: 16),
                        ),
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 8, bottom: 8),
                            child: Text(
                              'All Contacts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // All users (filtered)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final user = filteredUsers[index];
                            return UserListItem(
                              user: user,
                              showFollowButton: false,
                              onTap: () => _startChat(user.uid),
                            );
                          },
                          childCount: filteredUsers.length,
                        ),
                      ),
                    ],
                  );
                } else if (state is UserError) {
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
                          onPressed: _loadFollowingUsers,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('Loading users...'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
