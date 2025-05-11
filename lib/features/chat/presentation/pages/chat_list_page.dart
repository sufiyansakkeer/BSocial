import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../core/widgets/animations/bs_animated_container.dart';
import '../../../../core/widgets/animations/bs_staggered_list_view.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../blocs/chat_bloc.dart';
import '../widgets/chat_room_item.dart';
import '../widgets/chat_skeleton_loader.dart';
import '../../domain/entities/chat_room.dart';

/// Sorting options for chat list
enum SortOption { newest, oldest, unread }

/// Page that displays a list of chat rooms
class ChatListPage extends StatefulWidget {
  /// Constructor
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isSearching = false;
  String _searchQuery = '';
  final bool _isConnected = true;
  String? _errorMessage;

  // Current sort option
  SortOption _currentSortOption = SortOption.newest;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();

    // Setup animation controller for search bar
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload chat rooms when the page is revisited
    _loadChatRooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadChatRooms() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<ChatBloc>()
          .add(LoadChatRoomsEvent(userId: authState.user.uid));
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _animationController.forward();
        _searchFocusNode.requestFocus();
      } else {
        _animationController.reverse();
        _searchController.clear();
        _searchQuery = '';
        _searchFocusNode.unfocus();
      }
    });
  }

  void _changeSortOption(SortOption option) {
    setState(() {
      _currentSortOption = option;
    });
  }

  // Sort chat rooms based on current sort option
  List<ChatRoom> _sortChatRooms(List<ChatRoom> chatRooms) {
    final sortedRooms = List<ChatRoom>.from(chatRooms);

    switch (_currentSortOption) {
      case SortOption.newest:
        sortedRooms
            .sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        break;
      case SortOption.oldest:
        sortedRooms
            .sort((a, b) => a.lastMessageTime.compareTo(b.lastMessageTime));
        break;
      case SortOption.unread:
        // This would require tracking unread messages in the ChatRoom entity
        // For now, we'll just sort by newest
        sortedRooms
            .sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        break;
    }

    return sortedRooms;
  }

  // Filter chat rooms based on search query
  List<ChatRoom> _filterChatRooms(List<ChatRoom> chatRooms) {
    if (_searchQuery.isEmpty) {
      return chatRooms;
    }

    final query = _searchQuery.toLowerCase();

    return chatRooms.where((room) {
      // Search in last message
      if (room.lastMessage.toLowerCase().contains(query)) {
        return true;
      }

      // Search in participant IDs (ideally, we would search in usernames)
      for (final participant in room.participants) {
        if (participant.toLowerCase().contains(query)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? SizeTransition(
                sizeFactor: _animation,
                axis: Axis.horizontal,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(153)),
                  ),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              )
            : const Text('Conversations'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: _changeSortOption,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortOption.newest,
                child: Row(
                  children: [
                    Icon(Icons.access_time,
                        color: _currentSortOption == SortOption.newest
                            ? theme.colorScheme.primary
                            : null),
                    const SizedBox(width: 8),
                    const Text('Newest First'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.oldest,
                child: Row(
                  children: [
                    Icon(Icons.access_time_filled,
                        color: _currentSortOption == SortOption.oldest
                            ? theme.colorScheme.primary
                            : null),
                    const SizedBox(width: 8),
                    const Text('Oldest First'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.unread,
                child: Row(
                  children: [
                    Icon(Icons.mark_chat_unread,
                        color: _currentSortOption == SortOption.unread
                            ? theme.colorScheme.primary
                            : null),
                    const SizedBox(width: 8),
                    const Text('Unread First'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const ChatSkeletonLoader(itemCount: 10);
          } else if (state is ChatRoomsLoaded) {
            if (state.chatRooms.isEmpty) {
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
                      'No conversations yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start a conversation with someone!',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/chats/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('New Conversation'),
                    ),
                  ],
                ),
              );
            }

            // Sort and filter chat rooms
            final sortedChatRooms = _sortChatRooms(state.chatRooms);
            final filteredChatRooms = _filterChatRooms(sortedChatRooms);

            if (filteredChatRooms.isEmpty && _searchQuery.isNotEmpty) {
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

            return RefreshIndicator(
              onRefresh: () async {
                _loadChatRooms();
              },
              child: BSStaggeredListView(
                itemCount: filteredChatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = filteredChatRooms[index];
                  return ChatRoomItem(
                    chatRoom: chatRoom,
                    onTap: () {
                      context.read<ChatBloc>().add(
                            SetSelectedChatRoomEvent(chatRoom: chatRoom),
                          );
                      context.go('/chats/${chatRoom.roomId}');
                    },
                    hasUnreadMessages: index % 3 ==
                        0, // Placeholder for unread indicator logic
                  );
                },
                onRefresh: () async {
                  _loadChatRooms();
                },
                slideDirection: BSSlideDirection.fromRight,
                itemDuration: const Duration(milliseconds: 350),
                staggerDuration: const Duration(milliseconds: 60),
                initialDelay: const Duration(milliseconds: 50),
              ),
            );
          } else if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadChatRooms,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            // For any other state, show a loading indicator
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/chats/new');
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
