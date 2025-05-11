import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/extensions/widget_extensions.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart' as auth;
import '../../../../features/chat/presentation/blocs/chat_bloc.dart';
import '../../../../features/post/presentation/blocs/post_bloc.dart';
import '../../../../features/user/presentation/blocs/user_bloc.dart'
    as user_bloc;

import '../../../auth/domain/entities/user.dart';
import '../blocs/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_posts_grid.dart';
import '../widgets/profile_stats.dart';

/// Profile page
class ProfilePage extends StatefulWidget {
  /// Constructor
  const ProfilePage({
    required this.userId,
    this.isCurrentUser = false,
    super.key,
  });

  /// User ID
  final String userId;

  /// Whether this is the current user's profile
  final bool isCurrentUser;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _selectedImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load profile
    context.read<ProfileBloc>().add(LoadProfileEvent(userId: widget.userId));

    // Load user posts with context for error handling
    context.read<PostBloc>().add(LoadUserPostsEvent(
          userId: widget.userId,
          context: context,
        ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  /// Select a profile image
  Future<void> _selectImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _selectedImage = imageBytes;
          });
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Toggle edit mode
  void _toggleEditMode(user) {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _bioController.text = user.bio;
        _usernameController.text = user.userName;
      } else {
        _selectedImage = null;
      }
    });
  }

  /// Save profile changes
  void _saveProfile() {
    context.read<ProfileBloc>().add(
          UpdateProfileEvent(
            userId: widget.userId,
            userName: _usernameController.text.trim(),
            bio: _bioController.text.trim(),
            profilePic: _selectedImage,
          ),
        );
    setState(() {
      _isEditing = false;
      _selectedImage = null;
    });
  }

  /// Get current user ID from auth bloc
  String _getCurrentUserId() {
    final authState = context.read<auth.AuthBloc>().state;
    if (authState is auth.Authenticated) {
      return authState.user.uid;
    }
    return '';
  }

  /// Follow a user
  void _followUser(String userId) {
    try {
      // Get the current user ID
      final currentUserId = _getCurrentUserId();
      if (currentUserId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to follow users'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update the profile state to show the user as followed
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        // Check if already following to prevent duplicate actions
        if (profileState.user.followers.contains(currentUserId)) {
          return; // Already following, no need to do anything
        }

        // Add follow event to ProfileBloc
        context.read<ProfileBloc>().add(
              FollowUserEvent(
                profileUser: profileState.user,
                currentUserId: currentUserId,
              ),
            );

        // Also add follow event to UserBloc to ensure consistency
        context.read<user_bloc.UserBloc>().add(
              user_bloc.FollowUserEvent(userId: userId),
            );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to follow user: ${e.toString()}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Unfollow a user
  void _unfollowUser(String userId) {
    try {
      // Get the current user ID
      final currentUserId = _getCurrentUserId();
      if (currentUserId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to unfollow users'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update the profile state to show the user as unfollowed
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        // Check if already not following to prevent duplicate actions
        if (!profileState.user.followers.contains(currentUserId)) {
          return; // Already not following, no need to do anything
        }

        // Add unfollow event to ProfileBloc
        context.read<ProfileBloc>().add(
              UnfollowUserEvent(
                profileUser: profileState.user,
                currentUserId: currentUserId,
              ),
            );

        // Also add unfollow event to UserBloc to ensure consistency
        context.read<user_bloc.UserBloc>().add(
              user_bloc.UnfollowUserEvent(userId: userId),
            );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unfollow user: ${e.toString()}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Navigate to chat with user
  void _navigateToChat(String userId) {
    final currentUserId = _getCurrentUserId();
    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to send messages'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Create a chat room with the two users
      context.read<ChatBloc>().add(
            CreateChatRoomEvent(
              participants: [currentUserId, userId],
            ),
          );

      // Listen for chat room creation and navigate to chat page
      context.read<ChatBloc>().stream.listen((state) {
        if (!mounted) {
          return;
        }

        if (state is ChatRoomCreated) {
          context.go('/chat/${state.chatRoom.roomId}');
        } else if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Messaging feature is not available at the moment'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.isCurrentUser ? 'My Profile' : 'User Profile'),
          actions: [
            if (widget.isCurrentUser && !_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  final profileState = context.read<ProfileBloc>().state;
                  if (profileState is ProfileLoaded) {
                    _toggleEditMode(profileState.user);
                  }
                },
              )
            else if (widget.isCurrentUser && _isEditing)
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveProfile,
              ),
          ],
        ),
        body: BlocListener<user_bloc.UserBloc, user_bloc.UserState>(
          listener: (context, state) {
            if (state is user_bloc.UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is user_bloc.UserActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );

              // We don't need to refresh the profile here
              // The ProfileBloc has already updated the UI optimistically
            }
          },
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is ProfileUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ProfileLoaded || state is ProfileUpdated) {
                final user = state is ProfileLoaded
                    ? state.user
                    : (state as ProfileUpdated).user;

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ProfileBloc>()
                        .add(LoadProfileEvent(userId: widget.userId));
                    context.read<PostBloc>().add(LoadUserPostsEvent(
                          userId: widget.userId,
                          context: context,
                        ));
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile header
                        _isEditing
                            ? _buildEditProfileHeader(user)
                            : ProfileHeader(
                                user: user,
                                isCurrentUser: widget.isCurrentUser,
                                currentUserId: _getCurrentUserId(),
                                onFollowTap: () => _followUser(user.uid),
                                onUnfollowTap: () => _unfollowUser(user.uid),
                                onMessageTap: () => _navigateToChat(
                                    user.uid), // Already correctly implemented
                                onEditProfileTap: () {
                                  final profileState =
                                      context.read<ProfileBloc>().state;
                                  if (profileState is ProfileLoaded) {
                                    _toggleEditMode(profileState.user);
                                  }
                                },
                              ),

                        // Profile stats
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: ProfileStats(user: user),
                        ),

                        // Tab bar
                        Material(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: TabBar(
                            controller: _tabController,
                            tabs: const [
                              Tab(icon: Icon(Icons.grid_on)),
                              Tab(icon: Icon(Icons.bookmark_border)),
                            ],
                          ),
                        ),

                        // Tab bar view
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ProfilePostsGrid(userId: user.uid),
                              const Center(
                                  child: Text('Saved posts will appear here')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is ProfileError) {
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
                              .read<ProfileBloc>()
                              .add(LoadProfileEvent(userId: widget.userId));
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('Something went wrong'),
                );
              }
            },
          ),
        ),
      );

  /// Build the edit profile header
  Widget _buildEditProfileHeader(User user) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile image
            Stack(
              children: [
                _selectedImage != null
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: MemoryImage(_selectedImage!),
                      )
                    : ImageWidgetExtensions.safeCircleAvatar(
                        imageUrl: user.photoUrl,
                        radius: 50,
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
                      onPressed: _selectImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Username field
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Bio field
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      );
}
