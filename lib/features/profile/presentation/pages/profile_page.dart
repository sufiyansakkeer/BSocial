import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../features/post/presentation/blocs/post_bloc.dart';
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

    // Load user posts
    context.read<PostBloc>().add(LoadUserPostsEvent(userId: widget.userId));
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
        body: BlocConsumer<ProfileBloc, ProfileState>(
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
                  context
                      .read<PostBloc>()
                      .add(LoadUserPostsEvent(userId: widget.userId));
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile header
                      _isEditing
                          ? _buildEditProfileHeader(user)
                          : ProfileHeader(user: user),

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
      );

  /// Build the edit profile header
  Widget _buildEditProfileHeader(User user) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile image
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? MemoryImage(_selectedImage!)
                      : NetworkImage(user.photoUrl) as ImageProvider,
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
