import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/user_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

/// User profile page
class UserProfilePage extends StatefulWidget {
  /// Constructor
  const UserProfilePage({
    required this.userId,
    super.key,
    this.isCurrentUser = false,
  });

  /// User ID
  final String userId;

  /// Whether this is the current user's profile
  final bool isCurrentUser;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load user data when the page is initialized
    context.read<UserBloc>().add(GetUserByIdEvent(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            if (widget.isCurrentUser)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to edit profile page
                },
              ),
          ],
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserLoaded) {
              final user = state.user;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeader(
                      user: user,
                      isCurrentUser: widget.isCurrentUser,
                    ),
                    ProfileStats(
                      postsCount: 0, // This should come from PostBloc
                      followersCount: user.followers.length,
                      followingCount: user.following.length,
                    ),
                    const Divider(),
                    // Posts grid would go here
                    const Center(
                      child: Text('Posts will be displayed here'),
                    ),
                  ],
                ),
              );
            } else if (state is UserError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
          },
        ),
      );
}
