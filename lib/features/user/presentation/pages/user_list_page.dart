import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/animations/bs_staggered_list_view.dart';
import '../../../../core/widgets/animations/bs_animated_container.dart';
import '../../../../domain/entities/user.dart';
import '../../../auth/domain/entities/user.dart' as auth;
import '../blocs/user_bloc.dart';
import '../widgets/user_list_item.dart';

/// Type of user list to display
enum UserListType {
  /// Followers list
  followers,

  /// Following list
  following,
}

/// Page that displays a list of users (followers or following)
class UserListPage extends StatefulWidget {
  /// Constructor
  const UserListPage({
    required this.userId,
    required this.listType,
    this.title,
    super.key,
  });

  /// User ID to get followers or following for
  final String userId;

  /// Type of list to display (followers or following)
  final UserListType listType;

  /// Optional title override
  final String? title;

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    if (widget.listType == UserListType.followers) {
      context.read<UserBloc>().add(GetFollowersEvent(userId: widget.userId));
    } else {
      context.read<UserBloc>().add(GetFollowingEvent(userId: widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ??
        (widget.listType == UserListType.followers ? 'Followers' : 'Following');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FollowersLoaded &&
              widget.listType == UserListType.followers) {
            return _buildUserList(state.followers);
          } else if (state is FollowingLoaded &&
              widget.listType == UserListType.following) {
            return _buildUserList(state.following);
          } else if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUsers,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else {
            // Initial state or unexpected state
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildUserList(List<User> users) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          widget.listType == UserListType.followers
              ? 'No followers yet'
              : 'Not following anyone yet',
        ),
      );
    }

    return BSStaggeredListView(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserListItem(
          user: auth.User(
            uid: user.uid,
            email: user.email,
            userName: user.userName,
            photoUrl: user.photoUrl,
            followers: user.followers,
            following: user.following,
            status: user.status,
          ),
          onTap: () => context.go('/profile/${user.uid}'),
        );
      },
      onRefresh: () async {
        _loadUsers();
      },
      slideDirection: BSSlideDirection.fromRight,
      itemDuration: const Duration(milliseconds: 350),
      staggerDuration: const Duration(milliseconds: 60),
      initialDelay: const Duration(milliseconds: 50),
    );
  }
}
